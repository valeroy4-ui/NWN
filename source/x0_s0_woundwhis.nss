// Row 273: Wounding Whispers. Existing spell script; no new combat libraries.
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

const int WOUNDING_WHISPERS_ROUNDS_PER_LEVEL = 2;
const int WOUNDING_WHISPERS_BASE_LEVELS_PER_DAMAGE = 2;
const int WOUNDING_WHISPERS_GREATER_DAMAGE_PER_LEVEL = 2;
const int WOUNDING_WHISPERS_FIXED_DICE_DAMAGE = 1;
const int WOUNDING_WHISPERS_EPIC_SPOT_BONUS = 10;
const int WOUNDING_WHISPERS_EXTEND_MULTIPLIER = 2;

void main()
{
    spell.Dice = DAMAGE_BONUS_1;
    spell.DamageType = DAMAGE_TYPE_SONIC;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    if (!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();

    if (GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item) && spell.Class != CLASS_TYPE_BARD)
    { SendMessageToPC(spell.Caster,"Wounding Whispers requires Bard spellcasting.");return; }
    if (spell.Level <= 0) return;
    spell.Target = spell.Caster;
    int spotBefore=GetSkillRank(SKILL_SPOT,spell.Caster);
    int nDuration = WOUNDING_WHISPERS_ROUNDS_PER_LEVEL * spell.Level;
    int nDamage = spell.Level / WOUNDING_WHISPERS_BASE_LEVELS_PER_DAMAGE;
    int bEpicFocus = GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster);
    if (bEpicFocus || GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
        nDamage = WOUNDING_WHISPERS_GREATER_DAMAGE_PER_LEVEL * spell.Level;
    else if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
        nDamage = spell.Level;

    effect eLink = EffectLinkEffects(EffectVisualEffect(VFX_DUR_MIND_AFFECTING_POSITIVE),
                                     EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    if (nDamage > 0)
    {
        // Use a documented fixed DAMAGE_BONUS_1, with that point deducted
        // from the fixed component. There is no random damage die.
        effect eShield = EffectDamageShield(nDamage - WOUNDING_WHISPERS_FIXED_DICE_DAMAGE,
                                           spell.Dice, spell.DamageType);
        eLink = EffectLinkEffects(eShield, eLink);
    }
    if (bEpicFocus)
        eLink = EffectLinkEffects(eLink, EffectSkillIncrease(SKILL_SPOT,WOUNDING_WHISPERS_EPIC_SPOT_BONUS));
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    // Preserve the original module policy for simultaneous damage shields.
    if (GetModuleSwitchValue("72_DISABLE_DAMAGE_SHIELD_STACKING"))
        RemoveSpecificEffect(EFFECT_TYPE_ELEMENTALSHIELD, spell.Target);
    RemoveEffectsFromSpell(spell.Target,spell.Id);
    if (spell.Meta & METAMAGIC_EXTEND)
        nDuration *= WOUNDING_WHISPERS_EXTEND_MULTIPLIER;
    float fDuration = DurationToSeconds(nDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);

    if (GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)), "[test]") >= 0)
    {
        SetLocalObject(GetModule(), "WW273_LAST_CASTER", spell.Caster);
        string s = "[WW273] CL=" + IntToString(spell.Level)
            + " damage=" + IntToString(nDamage) + " type=sonic duration=" + FloatToString(fDuration, 0, 2)
            + " SF=" + IntToString(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " GSF=" + IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " ESF=" + IntToString(bEpicFocus)
            + " spotBonus=" + IntToString(bEpicFocus ? WOUNDING_WHISPERS_EPIC_SPOT_BONUS : 0)
            + " spotBefore=" + IntToString(spotBefore);
        WriteTimestampedLogEntry(s);
        SendMessageToPC(spell.Caster, s);
    }
}

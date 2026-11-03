// Row 266: Mestil's Acid Sheath.
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

const int MESTIL_ROUNDS_PER_LEVEL = 2;
const int MESTIL_FOCUS_DAMAGE_PER_LEVEL = 2;
const int MESTIL_GREATER_FLAT_DAMAGE = 20;
const int MESTIL_FIXED_DICE_DAMAGE = 1;
const int MESTIL_EXTEND_MULTIPLIER = 2;
const string MESTIL_EPIC_SHIELD_TAG = "MS266_EPIC_SHIELD";

void main()
{
    spell.Dice = DAMAGE_BONUS_1;
    spell.DamageType = DAMAGE_TYPE_ACID;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    if (!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    if (GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class != CLASS_TYPE_SORCERER && spell.Class != CLASS_TYPE_WIZARD)
    {
        SendMessageToPC(spell.Caster, "Mestil's Acid Sheath requires Sorcerer/Wizard spellcasting.");
        return;
    }
    if (spell.Level <= 0)
    { WriteTimestampedLogEntry("[MS266] Invalid caster level; no shield applied.");return; }
    spell.Target = spell.Caster;
    int bEpic = GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster);
    int nDamage = spell.Level;
    if (bEpic || GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
        nDamage = MESTIL_GREATER_FLAT_DAMAGE + MESTIL_FOCUS_DAMAGE_PER_LEVEL * spell.Level;
    else if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
        nDamage = MESTIL_FOCUS_DAMAGE_PER_LEVEL * spell.Level;
    int nDuration = MESTIL_ROUNDS_PER_LEVEL * spell.Level;
    if (spell.Meta & METAMAGIC_EXTEND) nDuration *= MESTIL_EXTEND_MULTIPLIER;
    // Native fixed DAMAGE_BONUS_1 contributes one; deduct it from the fixed part.
    effect eLink = EffectDamageShield(nDamage - MESTIL_FIXED_DICE_DAMAGE, spell.Dice, spell.DamageType);
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_PROT_ACIDSHIELD));
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    // The attack hook checks this actual shield, not a feat that can expire later.
    if (bEpic) eLink = TagEffect(eLink, MESTIL_EPIC_SHIELD_TAG);
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    if (GetModuleSwitchValue("72_DISABLE_DAMAGE_SHIELD_STACKING"))
        RemoveSpecificEffect(EFFECT_TYPE_ELEMENTALSHIELD, spell.Target);
    RemoveEffectsFromSpell(spell.Target, spell.Id);
    float fDuration = DurationToSeconds(nDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
    if (GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)), "[test]") >= 0)
    {
        SetLocalObject(GetModule(), "MS266_LAST_CASTER", spell.Caster);
        string s = "[MS266] CL=" + IntToString(spell.Level) + " class=" + IntToString(spell.Class)
            + " damage=" + IntToString(nDamage) + " type=acid duration=" + FloatToString(fDuration, 0, 2)
            + " SF=" + IntToString(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " GSF=" + IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " ESF=" + IntToString(bEpic) + " slow=" + IntToString(bEpic ? 10 : 0)
            + " slowSeconds=" + IntToString(bEpic ? 3 : 0);
        WriteTimestampedLogEntry(s);
        SendMessageToPC(spell.Caster, s);
    }
}

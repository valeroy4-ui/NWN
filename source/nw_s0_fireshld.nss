// Row 261: Elemental Shield. Existing spell script; no new combat libraries.
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

const int ELEMENTAL_SHIELD_ROUNDS_PER_LEVEL = 2;
const int ELEMENTAL_SHIELD_BASE_LEVELS_PER_DAMAGE = 2;
const int ELEMENTAL_SHIELD_GREATER_DAMAGE_PER_LEVEL = 2;
const int ELEMENTAL_SHIELD_FIXED_DICE_DAMAGE = 1;
const int ELEMENTAL_SHIELD_EPIC_IMMUNITY_PERCENT = 50;
const int ELEMENTAL_SHIELD_EXTEND_MULTIPLIER = 2;

void main()
{
    spell.Dice = DAMAGE_BONUS_1;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    if (!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();

    int nDuration = ELEMENTAL_SHIELD_ROUNDS_PER_LEVEL * spell.Level;
    int nDamage = spell.Level / ELEMENTAL_SHIELD_BASE_LEVELS_PER_DAMAGE;
    int bEpicFocus = GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster);
    if (bEpicFocus || GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
        nDamage = ELEMENTAL_SHIELD_GREATER_DAMAGE_PER_LEVEL * spell.Level;
    else if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
        nDamage = spell.Level;

    effect eLink = EffectLinkEffects(EffectVisualEffect(VFX_DUR_ELEMENTAL_SHIELD),
                                     EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    if (nDamage > 0)
    {
        // Use a documented fixed DAMAGE_BONUS_1, with that point deducted
        // from the fixed component. There is no random damage die.
        effect eShield = EffectDamageShield(nDamage - ELEMENTAL_SHIELD_FIXED_DICE_DAMAGE,
                                           spell.Dice, spell.DamageType);
        eLink = EffectLinkEffects(eShield, eLink);
    }
    if (bEpicFocus)
    {
        eLink = EffectLinkEffects(eLink, EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, ELEMENTAL_SHIELD_EPIC_IMMUNITY_PERCENT));
        eLink = EffectLinkEffects(eLink, EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, ELEMENTAL_SHIELD_EPIC_IMMUNITY_PERCENT));
        eLink = EffectLinkEffects(eLink, EffectDamageImmunityIncrease(DAMAGE_TYPE_ACID, ELEMENTAL_SHIELD_EPIC_IMMUNITY_PERCENT));
        eLink = EffectLinkEffects(eLink, EffectDamageImmunityIncrease(DAMAGE_TYPE_ELECTRICAL, ELEMENTAL_SHIELD_EPIC_IMMUNITY_PERCENT));
        eLink = EffectLinkEffects(eLink, EffectDamageImmunityIncrease(DAMAGE_TYPE_SONIC, ELEMENTAL_SHIELD_EPIC_IMMUNITY_PERCENT));
    }
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    // Preserve the original module policy for simultaneous damage shields.
    if (GetModuleSwitchValue("72_DISABLE_DAMAGE_SHIELD_STACKING"))
        RemoveSpecificEffect(EFFECT_TYPE_ELEMENTALSHIELD, spell.Target);
    if (GetHasSpellEffect(spell.Id, spell.Target))
        RemoveSpellEffects(spell.Id, spell.Caster, spell.Target);
    if (spell.Meta & METAMAGIC_EXTEND)
        nDuration *= ELEMENTAL_SHIELD_EXTEND_MULTIPLIER;
    float fDuration = DurationToSeconds(nDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);

    if (GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)), "[test]") >= 0)
    {
        SetLocalObject(GetModule(), "ES261_LAST_CASTER", spell.Caster);
        string s = "[ES261] CL=" + IntToString(spell.Level)
            + " damage=" + IntToString(nDamage) + " type=fire duration=" + FloatToString(fDuration, 0, 2)
            + " SF=" + IntToString(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " GSF=" + IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " ESF=" + IntToString(bEpicFocus)
            + " immunity=" + IntToString(bEpicFocus ? ELEMENTAL_SHIELD_EPIC_IMMUNITY_PERCENT : 0)
            + " elements=fire,cold,acid,electrical,sonic";
        WriteTimestampedLogEntry(s);
        SendMessageToPC(spell.Caster, s);
    }
}

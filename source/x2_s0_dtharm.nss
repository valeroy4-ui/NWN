// Row 260: Death Armor. Existing spell script; no additional runtime scripts.
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

const int DEATH_ARMOR_ROUNDS_PER_LEVEL = 2;
const int DEATH_ARMOR_BASE_LEVELS_PER_DAMAGE = 2;
const int DEATH_ARMOR_GREATER_DAMAGE_PER_LEVEL = 2;
const int DEATH_ARMOR_FIXED_DICE_DAMAGE = 1;

void main()
{
    spell.Dice = DAMAGE_BONUS_1;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();

    int nDuration = DEATH_ARMOR_ROUNDS_PER_LEVEL * spell.Level;
    int nDamage = spell.Level / DEATH_ARMOR_BASE_LEVELS_PER_DAMAGE;
    int bEpicFocus = GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster);
    // Check this school's existing feat constants directly. The shared focus
    // helper can fall through into other schools when a rank is absent.
    if (bEpicFocus || GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
        nDamage = DEATH_ARMOR_GREATER_DAMAGE_PER_LEVEL * spell.Level;
    else if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
        nDamage = spell.Level;

    effect eLink = EffectVisualEffect(VFX_DUR_DEATH_ARMOR);
    if (nDamage > 0)
    {
        // DAMAGE_BONUS_1 is a documented fixed +1, not a random die.
        // Subtract that point from the fixed component to get exactly nDamage.
        effect eShield = EffectDamageShield(nDamage - DEATH_ARMOR_FIXED_DICE_DAMAGE,
                                           spell.Dice, spell.DamageType);
        eLink = EffectLinkEffects(eShield, eLink);
    }
    if (bEpicFocus)
        eLink = EffectLinkEffects(eLink, EffectSpellResistanceIncrease(spell.Level));

    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    if (spell.Meta & METAMAGIC_EXTEND) nDuration *= 2;

    // Preserve the existing Cormyr damage-shield stacking policy.
    if (GetModuleSwitchValue("72_DISABLE_DAMAGE_SHIELD_STACKING"))
        RemoveSpecificEffect(EFFECT_TYPE_ELEMENTALSHIELD, spell.Target);
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    float fDuration = DurationToSeconds(nDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);

    // Diagnostics stay inside this original script; no probe script is added.
    if (GetIsPC(spell.Caster)
        && FindSubString(GetStringLowerCase(GetName(spell.Caster)), "[test]") >= 0)
    {
        SetLocalObject(GetModule(), "DA260_LAST_CASTER", spell.Caster);
        string s = "[DA260] CL=" + IntToString(spell.Level)
            + " damage=" + IntToString(nDamage) + " type=fire"
            + " duration=" + FloatToString(fDuration, 0, 2)
            + " SF=" + IntToString(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " GSF=" + IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " ESF=" + IntToString(bEpicFocus)
            + " SR=" + IntToString(bEpicFocus ? spell.Level : 0)
            + " actualSR=" + IntToString(GetSpellResistance(spell.Target));
        WriteTimestampedLogEntry(s);
        SendMessageToPC(spell.Caster, s);
    }
}

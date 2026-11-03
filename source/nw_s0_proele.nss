// Row 268: Protection from Elements. One native effect, one shared elemental pool.
#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

const int PROTECTION_ELEMENTS_ROUNDS_PER_LEVEL = 2;
const int PROTECTION_ELEMENTS_POOL_PER_LEVEL = 6;
const int PROTECTION_ELEMENTS_BASE_RESISTANCE = 15;
const int PROTECTION_ELEMENTS_SF_RESISTANCE = 20;
const int PROTECTION_ELEMENTS_GSF_RESISTANCE = 20;
const int PROTECTION_ELEMENTS_ESF_RESISTANCE = 20;
const int PROTECTION_ELEMENTS_SF_POOL_BONUS = 30;
const int PROTECTION_ELEMENTS_GSF_POOL_BONUS = 80;
const int PROTECTION_ELEMENTS_ESF_POOL_BONUS = 150;
const int PROTECTION_ELEMENTS_EXTEND_MULTIPLIER = 2;

void main()
{
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    if (!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    if (GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class != CLASS_TYPE_CLERIC && spell.Class != CLASS_TYPE_DRUID
        && spell.Class != CLASS_TYPE_RANGER && spell.Class != CLASS_TYPE_SORCERER
        && spell.Class != CLASS_TYPE_WIZARD)
    {
        SendMessageToPC(spell.Caster, "Protection from Elements requires Cleric, Druid, Ranger or Sorcerer/Wizard spellcasting.");
        return;
    }
    spell.Target = spell.Caster;
    // A native resistance limit of zero means unlimited, so reject invalid CL.
    if (spell.Level <= 0)
    { WriteTimestampedLogEntry("[PE268] Invalid caster level; no resistance applied."); return; }

    int nDuration = PROTECTION_ELEMENTS_ROUNDS_PER_LEVEL * spell.Level;
    int nAmount = PROTECTION_ELEMENTS_POOL_PER_LEVEL * spell.Level;
    int nResistance = PROTECTION_ELEMENTS_BASE_RESISTANCE;
    if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nResistance = PROTECTION_ELEMENTS_ESF_RESISTANCE;
        nAmount += PROTECTION_ELEMENTS_ESF_POOL_BONUS;
    }
    else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nResistance = PROTECTION_ELEMENTS_GSF_RESISTANCE;
        nAmount += PROTECTION_ELEMENTS_GSF_POOL_BONUS;
    }
    else if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nResistance = PROTECTION_ELEMENTS_SF_RESISTANCE;
        nAmount += PROTECTION_ELEMENTS_SF_POOL_BONUS;
    }
    int nElementalMask = DAMAGE_TYPE_COLD | DAMAGE_TYPE_FIRE | DAMAGE_TYPE_ACID
                      | DAMAGE_TYPE_SONIC | DAMAGE_TYPE_ELECTRICAL;
    // Do not split this into five effects: all five types consume this ONE limit.
    effect eLink = EffectDamageResistance(nElementalMask, nResistance, nAmount);
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_PROTECTION_ELEMENTS));
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    if (spell.Meta & METAMAGIC_EXTEND) nDuration *= PROTECTION_ELEMENTS_EXTEND_MULTIPLIER;
    RemoveEffectsFromSpell(spell.Target, spell.Id);
    float fDuration = DurationToSeconds(nDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION), spell.Target);

    if (GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)), "[test]") >= 0)
    {
        SetLocalObject(GetModule(), "PE268_LAST_CASTER", spell.Caster);
        string s = "[PE268] CL=" + IntToString(spell.Level) + " class=" + IntToString(spell.Class)
            + " resistance=" + IntToString(nResistance) + " sharedPool=" + IntToString(nAmount)
            + " duration=" + FloatToString(fDuration, 0, 2)
            + " SF=" + IntToString(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " GSF=" + IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " ESF=" + IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster));
        WriteTimestampedLogEntry(s);
        SendMessageToPC(spell.Caster, s);
    }
}

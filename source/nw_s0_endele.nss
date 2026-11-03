// Row 262: Endure Elements. One native effect, one shared elemental pool.
#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

const int ENDURE_ELEMENTS_ROUNDS_PER_LEVEL = 2;
const int ENDURE_ELEMENTS_POOL_PER_LEVEL = 3;
const int ENDURE_ELEMENTS_BASE_RESISTANCE = 5;
const int ENDURE_ELEMENTS_SF_RESISTANCE = 10;
const int ENDURE_ELEMENTS_GSF_RESISTANCE = 15;
const int ENDURE_ELEMENTS_ESF_RESISTANCE = 20;
const int ENDURE_ELEMENTS_SF_POOL_BONUS = 30;
const int ENDURE_ELEMENTS_GSF_POOL_BONUS = 80;
const int ENDURE_ELEMENTS_ESF_POOL_BONUS = 150;
const int ENDURE_ELEMENTS_EXTEND_MULTIPLIER = 2;

void main()
{
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    if (!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    if (GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class != CLASS_TYPE_CLERIC && spell.Class != CLASS_TYPE_DRUID
        && spell.Class != CLASS_TYPE_PALADIN)
    {
        SendMessageToPC(spell.Caster, "Endure Elements requires Cleric, Druid or Paladin spellcasting.");
        return;
    }
    // A native resistance limit of zero means unlimited, so reject invalid CL.
    if (spell.Level <= 0)
    { WriteTimestampedLogEntry("[EE262] Invalid caster level; no resistance applied."); return; }

    int nDuration = ENDURE_ELEMENTS_ROUNDS_PER_LEVEL * spell.Level;
    int nAmount = ENDURE_ELEMENTS_POOL_PER_LEVEL * spell.Level;
    int nResistance = ENDURE_ELEMENTS_BASE_RESISTANCE;
    if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nResistance = ENDURE_ELEMENTS_ESF_RESISTANCE;
        nAmount += ENDURE_ELEMENTS_ESF_POOL_BONUS;
    }
    else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nResistance = ENDURE_ELEMENTS_GSF_RESISTANCE;
        nAmount += ENDURE_ELEMENTS_GSF_POOL_BONUS;
    }
    else if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nResistance = ENDURE_ELEMENTS_SF_RESISTANCE;
        nAmount += ENDURE_ELEMENTS_SF_POOL_BONUS;
    }
    int nElementalMask = DAMAGE_TYPE_COLD | DAMAGE_TYPE_FIRE | DAMAGE_TYPE_ACID
                      | DAMAGE_TYPE_SONIC | DAMAGE_TYPE_ELECTRICAL;
    // Do not split this into five effects: all five types consume this ONE limit.
    effect eLink = EffectDamageResistance(nElementalMask, nResistance, nAmount);
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_PROTECTION_ELEMENTS));
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    if (spell.Meta & METAMAGIC_EXTEND) nDuration *= ENDURE_ELEMENTS_EXTEND_MULTIPLIER;
    RemoveEffectsFromSpell(spell.Target, spell.Id);
    float fDuration = DurationToSeconds(nDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION), spell.Target);

    if (GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)), "[test]") >= 0)
    {
        SetLocalObject(GetModule(), "EE262_LAST_CASTER", spell.Caster);
        string s = "[EE262] CL=" + IntToString(spell.Level) + " class=" + IntToString(spell.Class)
            + " resistance=" + IntToString(nResistance) + " sharedPool=" + IntToString(nAmount)
            + " duration=" + FloatToString(fDuration, 0, 2)
            + " SF=" + IntToString(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " GSF=" + IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " ESF=" + IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster));
        WriteTimestampedLogEntry(s);
        SendMessageToPC(spell.Caster, s);
    }
}

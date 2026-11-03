// Row 263: Energy Buffer. One native effect, one shared elemental pool.
#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

const int ENERGY_BUFFER_ROUNDS_PER_LEVEL = 2;
const int ENERGY_BUFFER_POOL_PER_LEVEL = 8;
const int ENERGY_BUFFER_BASE_RESISTANCE = 25;
const int ENERGY_BUFFER_SF_RESISTANCE = 30;
const int ENERGY_BUFFER_GSF_RESISTANCE = 35;
const int ENERGY_BUFFER_ESF_RESISTANCE = 40;
const int ENERGY_BUFFER_SF_POOL_BONUS = 30;
const int ENERGY_BUFFER_GSF_POOL_BONUS = 80;
const int ENERGY_BUFFER_ESF_POOL_BONUS = 150;
const int ENERGY_BUFFER_EXTEND_MULTIPLIER = 2;

void main()
{
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    if (!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    if (GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item))
    {
        if (spell.Class != CLASS_TYPE_BARD && spell.Class != CLASS_TYPE_CLERIC
            && spell.Class != CLASS_TYPE_DRUID && spell.Class != CLASS_TYPE_SORCERER
            && spell.Class != CLASS_TYPE_WIZARD)
        {
            SendMessageToPC(spell.Caster, "Energy Buffer requires Bard, Cleric, Druid or Sorcerer/Wizard spellcasting.");
            return;
        }
        if (spell.Class == CLASS_TYPE_CLERIC)
        {
            int nDomain1 = GetDomain(spell.Caster, 1, CLASS_TYPE_CLERIC);
            int nDomain2 = GetDomain(spell.Caster, 2, CLASS_TYPE_CLERIC);
            if (nDomain1 != DOMAIN_EARTH && nDomain2 != DOMAIN_EARTH
                && nDomain1 != DOMAIN_PROTECTION && nDomain2 != DOMAIN_PROTECTION)
            {
                SendMessageToPC(spell.Caster, "Energy Buffer requires the Earth or Protection domain for Cleric spellcasting.");
                return;
            }
        }
    }
    // A native resistance limit of zero means unlimited, so reject invalid CL.
    if (spell.Level <= 0)
    { WriteTimestampedLogEntry("[EB263] Invalid caster level; no resistance applied."); return; }

    int nDuration = ENERGY_BUFFER_ROUNDS_PER_LEVEL * spell.Level;
    int nAmount = ENERGY_BUFFER_POOL_PER_LEVEL * spell.Level;
    int nResistance = ENERGY_BUFFER_BASE_RESISTANCE;
    if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nResistance = ENERGY_BUFFER_ESF_RESISTANCE;
        nAmount += ENERGY_BUFFER_ESF_POOL_BONUS;
    }
    else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nResistance = ENERGY_BUFFER_GSF_RESISTANCE;
        nAmount += ENERGY_BUFFER_GSF_POOL_BONUS;
    }
    else if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nResistance = ENERGY_BUFFER_SF_RESISTANCE;
        nAmount += ENERGY_BUFFER_SF_POOL_BONUS;
    }
    int nElementalMask = DAMAGE_TYPE_COLD | DAMAGE_TYPE_FIRE | DAMAGE_TYPE_ACID
                      | DAMAGE_TYPE_SONIC | DAMAGE_TYPE_ELECTRICAL;
    // Do not split this into five effects: all five types consume this ONE limit.
    effect eLink = EffectDamageResistance(nElementalMask, nResistance, nAmount);
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_PROTECTION_ELEMENTS));
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    if (spell.Meta & METAMAGIC_EXTEND) nDuration *= ENERGY_BUFFER_EXTEND_MULTIPLIER;
    RemoveEffectsFromSpell(spell.Target, spell.Id);
    float fDuration = DurationToSeconds(nDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION), spell.Target);

    if (GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)), "[test]") >= 0)
    {
        SetLocalObject(GetModule(), "EB263_LAST_CASTER", spell.Caster);
        string s = "[EB263] CL=" + IntToString(spell.Level) + " class=" + IntToString(spell.Class)
            + " resistance=" + IntToString(nResistance) + " sharedPool=" + IntToString(nAmount)
            + " duration=" + FloatToString(fDuration, 0, 2)
            + " SF=" + IntToString(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " GSF=" + IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " ESF=" + IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster));
        WriteTimestampedLogEntry(s);
        SendMessageToPC(spell.Caster, s);
    }
}

// Row 267: Premonition. Existing impact script; no shared changes.
#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

const int PRM_ROUNDS_PER_LEVEL = 2;
const int PRM_BASE_REDUCTION = 20;
const int PRM_SF_REDUCTION = 25;
const int PRM_GSF_REDUCTION = 30;
const int PRM_ESF_REDUCTION = 35;
const int PRM_BASE_POOL_PER_LEVEL = 6;
const int PRM_SF_POOL_PER_LEVEL = 8;
const int PRM_GSF_POOL_PER_LEVEL = 10;
const int PRM_ESF_POOL_PER_LEVEL = 12;
const int PRM_EXTEND_MULTIPLIER = 2;

void main()
{
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    if (!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    if (GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class != CLASS_TYPE_CLERIC && spell.Class != CLASS_TYPE_DRUID && spell.Class != CLASS_TYPE_SORCERER
        && spell.Class != CLASS_TYPE_WIZARD)
    {
        SendMessageToPC(spell.Caster, "Premonition requires Cleric, Druid or Sorcerer/Wizard spellcasting.");
        return;
    }
    if (GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item) && spell.Class == CLASS_TYPE_CLERIC
        && GetDomain(spell.Caster, 1, CLASS_TYPE_CLERIC) != DOMAIN_PROTECTION
        && GetDomain(spell.Caster, 2, CLASS_TYPE_CLERIC) != DOMAIN_PROTECTION)
    {
        SendMessageToPC(spell.Caster, "Premonition requires the Protection domain for Cleric spellcasting.");
        return;
    }
    if (spell.Level <= 0)
    { WriteTimestampedLogEntry("[PR267] Invalid caster level; no reduction applied."); return; }
    // Self-only even if an old prepared spell or item supplies another target.
    spell.Target = spell.Caster;
    int nReduction = PRM_BASE_REDUCTION;
    int nPower = DAMAGE_POWER_PLUS_SIX;
    int nBypassBonus = 6;
    int nPoolPerLevel = PRM_BASE_POOL_PER_LEVEL;
    if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nReduction = PRM_ESF_REDUCTION;
        nPower = DAMAGE_POWER_PLUS_NINE;
        nBypassBonus = 9;
        nPoolPerLevel = PRM_ESF_POOL_PER_LEVEL;
    }
    else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nReduction = PRM_GSF_REDUCTION;
        nPower = DAMAGE_POWER_PLUS_EIGHT;
        nBypassBonus = 8;
        nPoolPerLevel = PRM_GSF_POOL_PER_LEVEL;
    }
    else if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nReduction = PRM_SF_REDUCTION;
        nPower = DAMAGE_POWER_PLUS_SEVEN;
        nBypassBonus = 7;
        nPoolPerLevel = PRM_SF_POOL_PER_LEVEL;
    }
    int nPool = nPoolPerLevel * spell.Level;
    int nDuration = PRM_ROUNDS_PER_LEVEL * spell.Level;
    if (spell.Meta & METAMAGIC_EXTEND) nDuration *= PRM_EXTEND_MULTIPLIER;
    effect eLink = EffectDamageReduction(nReduction, nPower, nPool);
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_PROT_PREMONITION));
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    RemoveEffectsFromSpell(spell.Target, spell.Id);
    float fDuration = DurationToSeconds(nDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
    if (GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)), "[test]") >= 0)
    {
        SetLocalObject(GetModule(), "PR267_LAST_CASTER", spell.Caster);
        string s = "[PR267] CL=" + IntToString(spell.Level) + " class=" + IntToString(spell.Class)
            + " reduction=" + IntToString(nReduction) + " bypass=+" + IntToString(nBypassBonus)
            + " pool=" + IntToString(nPool) + " duration=" + FloatToString(fDuration, 0, 2)
            + " SF=" + IntToString(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " GSF=" + IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " ESF=" + IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster));
        WriteTimestampedLogEntry(s);
        SendMessageToPC(spell.Caster, s);
    }
}

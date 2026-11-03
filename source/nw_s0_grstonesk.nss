// Row 264: Greater Stoneskin. Existing impact script; no shared changes.
#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

const int GST_ROUNDS_PER_LEVEL = 2;
const int GST_BASE_REDUCTION = 10;
const int GST_SF_REDUCTION = 15;
const int GST_GSF_REDUCTION = 20;
const int GST_ESF_REDUCTION = 25;
const int GST_BASE_POOL_PER_LEVEL = 3;
const int GST_SF_POOL_PER_LEVEL = 4;
const int GST_GSF_POOL_PER_LEVEL = 5;
const int GST_ESF_POOL_PER_LEVEL = 6;
const int GST_EXTEND_MULTIPLIER = 2;

void main()
{
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    if (!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    if (GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class != CLASS_TYPE_DRUID && spell.Class != CLASS_TYPE_SORCERER
        && spell.Class != CLASS_TYPE_WIZARD)
    {
        SendMessageToPC(spell.Caster, "Greater Stoneskin requires Druid or Sorcerer/Wizard spellcasting.");
        return;
    }
    if (spell.Level <= 0)
    { WriteTimestampedLogEntry("[GST264] Invalid caster level; no reduction applied."); return; }
    // Self-only even if an old prepared spell or item supplies another target.
    spell.Target = spell.Caster;
    int nReduction = GST_BASE_REDUCTION;
    int nPower = DAMAGE_POWER_PLUS_FIVE;
    int nBypassBonus = 5;
    int nPoolPerLevel = GST_BASE_POOL_PER_LEVEL;
    if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nReduction = GST_ESF_REDUCTION;
        nPower = DAMAGE_POWER_PLUS_EIGHT;
        nBypassBonus = 8;
        nPoolPerLevel = GST_ESF_POOL_PER_LEVEL;
    }
    else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nReduction = GST_GSF_REDUCTION;
        nPower = DAMAGE_POWER_PLUS_SEVEN;
        nBypassBonus = 7;
        nPoolPerLevel = GST_GSF_POOL_PER_LEVEL;
    }
    else if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nReduction = GST_SF_REDUCTION;
        nPower = DAMAGE_POWER_PLUS_SIX;
        nBypassBonus = 6;
        nPoolPerLevel = GST_SF_POOL_PER_LEVEL;
    }
    int nPool = nPoolPerLevel * spell.Level;
    int nDuration = GST_ROUNDS_PER_LEVEL * spell.Level;
    if (spell.Meta & METAMAGIC_EXTEND) nDuration *= GST_EXTEND_MULTIPLIER;
    effect eLink = EffectDamageReduction(nReduction, nPower, nPool);
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_PROT_STONESKIN));
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    RemoveEffectsFromSpell(spell.Target, spell.Id);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_POLYMORPH), spell.Target);
    float fDuration = DurationToSeconds(nDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
    if (GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)), "[test]") >= 0)
    {
        SetLocalObject(GetModule(), "GST264_LAST_CASTER", spell.Caster);
        string s = "[GST264] CL=" + IntToString(spell.Level) + " class=" + IntToString(spell.Class)
            + " reduction=" + IntToString(nReduction) + " bypass=+" + IntToString(nBypassBonus)
            + " pool=" + IntToString(nPool) + " duration=" + FloatToString(fDuration, 0, 2)
            + " SF=" + IntToString(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " GSF=" + IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " ESF=" + IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster));
        WriteTimestampedLogEntry(s);
        SendMessageToPC(spell.Caster, s);
    }
}

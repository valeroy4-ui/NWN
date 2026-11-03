// Row 272: Stoneskin. Existing impact script; no shared changes.
#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

const int SK_ROUNDS_PER_LEVEL = 2;
const int SK_BASE_REDUCTION = 5;
const int SK_SF_REDUCTION = 10;
const int SK_GSF_REDUCTION = 15;
const int SK_ESF_REDUCTION = 20;
const int SK_BASE_POOL_PER_LEVEL = 2;
const int SK_SF_POOL_PER_LEVEL = 3;
const int SK_GSF_POOL_PER_LEVEL = 4;
const int SK_ESF_POOL_PER_LEVEL = 5;
const int SK_EXTEND_MULTIPLIER = 2;

void main()
{
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    if (!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    if (GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class != CLASS_TYPE_CLERIC && spell.Class != CLASS_TYPE_DRUID && spell.Class != CLASS_TYPE_SORCERER
        && spell.Class != CLASS_TYPE_WIZARD)
    {
        SendMessageToPC(spell.Caster, "Stoneskin requires Cleric (Earth), Druid or Sorcerer/Wizard spellcasting.");
        return;
    }
    if (spell.Level <= 0)
    { WriteTimestampedLogEntry("[SK272] Invalid caster level; no reduction applied."); return; }
    if (GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item) && spell.Class == CLASS_TYPE_CLERIC
        && GetDomain(spell.Caster, 1, CLASS_TYPE_CLERIC) != DOMAIN_EARTH
        && GetDomain(spell.Caster, 2, CLASS_TYPE_CLERIC) != DOMAIN_EARTH)
    { SendMessageToPC(spell.Caster, "Stoneskin requires the Earth domain for Cleric spellcasting.");return; }
    // Touch spell: preserve the actual recipient, rather than forcing self.
    if (!GetIsObjectValid(spell.Target) || GetObjectType(spell.Target) != OBJECT_TYPE_CREATURE || GetIsDead(spell.Target)) return;
    int nReduction = SK_BASE_REDUCTION;
    int nPower = DAMAGE_POWER_PLUS_FOUR;
    int nBypassBonus = 4;
    int nPoolPerLevel = SK_BASE_POOL_PER_LEVEL;
    if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nReduction = SK_ESF_REDUCTION;
        nPower = DAMAGE_POWER_PLUS_SEVEN;
        nBypassBonus = 7;
        nPoolPerLevel = SK_ESF_POOL_PER_LEVEL;
    }
    else if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nReduction = SK_GSF_REDUCTION;
        nPower = DAMAGE_POWER_PLUS_SIX;
        nBypassBonus = 6;
        nPoolPerLevel = SK_GSF_POOL_PER_LEVEL;
    }
    else if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
    {
        nReduction = SK_SF_REDUCTION;
        nPower = DAMAGE_POWER_PLUS_FIVE;
        nBypassBonus = 5;
        nPoolPerLevel = SK_SF_POOL_PER_LEVEL;
    }
    int nPool = nPoolPerLevel * spell.Level;
    int nDuration = SK_ROUNDS_PER_LEVEL * spell.Level;
    if (spell.Meta & METAMAGIC_EXTEND) nDuration *= SK_EXTEND_MULTIPLIER;
    effect eLink = EffectDamageReduction(nReduction, nPower, nPool);
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_PROT_STONESKIN));
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    eLink = TagEffect(eLink, "SK272:" + GetObjectUUID(spell.Caster));
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    RemoveEffectsFromSpell(spell.Target, spell.Id);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SUPER_HEROISM), spell.Target);
    float fDuration = DurationToSeconds(nDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
    if (GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)), "[test]") >= 0)
    {
        SetLocalObject(GetModule(), "SK272_LAST_CASTER", spell.Caster);
        SetLocalObject(GetModule(), "SK272_LAST_TARGET", spell.Target);
        string s = "[SK272] CL=" + IntToString(spell.Level) + " class=" + IntToString(spell.Class)
            + " reduction=" + IntToString(nReduction) + " bypass=+" + IntToString(nBypassBonus)
            + " pool=" + IntToString(nPool) + " duration=" + FloatToString(fDuration, 0, 2)
            + " SF=" + IntToString(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " GSF=" + IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION, spell.Caster))
            + " ESF=" + IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION, spell.Caster)) + " target=" + GetName(spell.Target);
        WriteTimestampedLogEntry(s);
        SendMessageToPC(spell.Caster, s);
    }
}

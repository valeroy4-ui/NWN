//::///////////////////////////////////////////////
//:: Greater Restoration
//:: NW_S0_GrRestore.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Removes all negative effects of a temporary nature
    and all permanent effects of a supernatural nature
    from the character. Does not remove the effects
    relating to Mind-Affecting spells or movement alteration.
    Heals 250/270/300/350 HP by highest Enchantment focus; fixed amount.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
/*
Patch 1.72
- restoration doesn't remove horse related effects
Patch 1.71
- restoration doesn't remove effects of rage anymore (all rage variants)
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_runes"
#include "inc_heal_range"

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spell.Class = GetLastSpellCastClass();
    spellsDeclareMajorVariables();
    // update spell.Level for runic empowered spells
    if(runes_GetStandartSpellIdFromRunic(spell.Id) != RUNE_SPELL_ID_NONE)
        spell.Level = GetLevelByClass(GetLocalInt(spell.Caster, "RUNIC_CLASS"), spell.Caster);

    effect eVisual = EffectVisualEffect(VFX_IMP_RESTORATION_GREATER);

    int nativeId=GetSpellId();
    if((nativeId==SPELL_GREATER_RESTORATION || nativeId==GR277_DOMAIN_SPELL)
        && GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class!=CLASS_TYPE_CLERIC && spell.Class!=CLASS_TYPE_DRUID)
    {SendMessageToPC(spell.Caster,"Greater Restoration requires Cleric or Druid spellcasting.");return;}
    int healingBook=HealRange_HasDomain(spell.Caster,spell.Class);
    if(nativeId==GR277_DOMAIN_SPELL && (!healingBook || GetIsObjectValid(spell.Item)))return;
    if(nativeId==SPELL_GREATER_RESTORATION || nativeId==GR277_DOMAIN_SPELL)
        spell.Id=SPELL_GREATER_RESTORATION;

    // Fixed healing by the highest Enchantment focus. No caster-level,
    // metamagic, automatic Healing Domain or Healing Rune multiplier.
    int focus=0,iMaxHP=250;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=3;iMaxHP=350;}
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=2;iMaxHP=300;}
    else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=1;iMaxHP=270;}

    effect eBad = GetFirstEffect(spell.Target);
    //Search for negative effects
    while(GetIsEffectValid(eBad))
    {
        switch(GetEffectType(eBad))
        {
            case EFFECT_TYPE_ABILITY_DECREASE:
            case EFFECT_TYPE_AC_DECREASE:
            case EFFECT_TYPE_ATTACK_DECREASE:
            case EFFECT_TYPE_DAMAGE_DECREASE:
            case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE:
            case EFFECT_TYPE_SAVING_THROW_DECREASE:
            case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE:
            case EFFECT_TYPE_SKILL_DECREASE:
            case EFFECT_TYPE_BLINDNESS:
            case EFFECT_TYPE_DEAF:
            case EFFECT_TYPE_CURSE:
            case EFFECT_TYPE_DISEASE:
            case EFFECT_TYPE_POISON:
            case EFFECT_TYPE_PARALYZE:
            case EFFECT_TYPE_CHARMED:
            case EFFECT_TYPE_DOMINATED:
            case EFFECT_TYPE_DAZED:
            case EFFECT_TYPE_CONFUSED:
            case EFFECT_TYPE_FRIGHTENED:
            case EFFECT_TYPE_NEGATIVELEVEL:
            case EFFECT_TYPE_SLOW:
            case EFFECT_TYPE_STUNNED:
            case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE:
            //Remove effect if it is negative.
            if(!GetIsSupernaturalCurse(eBad))
            {
                RemoveEffect(spell.Target, eBad);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAttackIncrease(0), spell.Target); // for assist detection system
            }
            break;
            default:
            if(GetTag(GetEffectCreator(eBad)) == "70_EC_POISON" || GetTag(GetEffectCreator(eBad)) == "70_EC_DISEASE")
                RemoveEffect(spell.Target, eBad);
            break;
        }
        // remove holy sword move speed decrease
        if (GetEffectSpellId(eBad) == SPELL_BESTOW_CURSE)
        {
            RemoveEffect(spell.Target, eBad);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAttackIncrease(0), spell.Target); // for assist detection system
        }
        eBad = GetNextEffect(spell.Target);
    }

    int nHealed=0;
    if(!spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD))
    {
        // Apply the VFX impact and effects
        int nHeal = GetMaxHitPoints(spell.Target) - GetCurrentHitPoints(spell.Target);
        nHeal = (nHeal > 0) ? nHeal : 0;
        nHeal = (nHeal > iMaxHP) ? iMaxHP : nHeal;
        nHealed=nHeal;
        effect eHeal = EffectHeal(nHeal);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHeal, spell.Target);
    }
    if(GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0)
    {
        string report="[GR277] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)
            +" focus="+IntToString(focus)+" base="+IntToString(iMaxHP)
            +" final="+IntToString(nHealed)+" meta="+IntToString(spell.Meta)
            +" nativeId="+IntToString(nativeId)+" tableRange="+Get2DAString("spells","Range",nativeId)
            +" target="+GetName(spell.Target);
        PrintString(report);SendMessageToPC(spell.Caster,report);
    }
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spell.Target);
}

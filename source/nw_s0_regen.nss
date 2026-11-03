//::///////////////////////////////////////////////
//:: Regenerate
//:: NW_S0_Regen
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grants the selected target 6/8/10/12 HP of regeneration
    every round.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 22, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- removed stacking with itself
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spell.Class=GetLastSpellCastClass();
    spellsDeclareMajorVariables();


    int focus=0,iRegen=6;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=3;iRegen=12;}
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=2;iRegen=10;}
    else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=1;iRegen=8;}
    // Two rounds per actual caster class level; no automatic Healing Domain bonus.
    int nLevel=2*spell.Level;

    effect eRegen = EffectRegenerate(iRegen, 6.0);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eRegen, eDur);

    //Meta-Magic Checks
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nLevel *= 2;

    }
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //do not stack anymore, i know this is serious nerf, but this is obviously wrong
    RemoveEffectsFromSpell(spell.Target, spell.Id);
    //Apply effects and VFX
    float duration=DurationToSeconds(nLevel);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, duration);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    if(GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0)
    {
        string report="[RG284] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)
            +" focus="+IntToString(focus)+" regen="+IntToString(iRegen)+" interval=6.00"
            +" duration="+FloatToString(duration,0,2)+" meta="+IntToString(spell.Meta)
            +" target="+GetName(spell.Target);
        PrintString(report);SendMessageToPC(spell.Caster,report);
    }
}


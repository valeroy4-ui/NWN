//::///////////////////////////////////////////////
//:: Monstrous Regeneration
//:: X2_S0_MonRegen
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grants the selected target 3/4/5/6 HP of regeneration
    every round.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs May 09, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
/*
Patch 1.71

- duration doubled in order to balance with regenerate spell
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
        return;
    }

    //Declare major variables
    spell.Class=GetLastSpellCastClass();
    spellsDeclareMajorVariables();

    int focus=0,iRegen=3;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=3;iRegen=6;}
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=2;iRegen=5;}
    else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=1;iRegen=4;}
    // Two rounds per caster level; no automatic Healing Domain multiplier.
    int nLevel=2*spell.Level;

    effect eRegen = EffectRegenerate(iRegen, 6.0);

    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eRegen, eDur);

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nLevel *= 2;
    }

    // Stacking Spellpass, 2003-07-07, Georg   ... just in case
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Apply effects and VFX
    float duration=DurationToSeconds(nLevel);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eLink,spell.Target,duration);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    if(GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0)
    {
        string report="[MR283] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)
            +" focus="+IntToString(focus)+" regen="+IntToString(iRegen)+" interval=6.00"
            +" duration="+FloatToString(duration,0,2)+" meta="+IntToString(spell.Meta)
            +" target="+GetName(spell.Target);
        PrintString(report);SendMessageToPC(spell.Caster,report);
    }
}

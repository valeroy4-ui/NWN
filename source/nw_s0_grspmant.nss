//::///////////////////////////////////////////////
//:: Greater Spell Mantle
//:: NW_S0_GrSpTurn.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grants the caster 1d6 + 14/15/17/20 spell levels of
    absorbtion.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spell.Class=GetLastSpellCastClass();
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(SHADVFX_DUR_SPELLTURNING_M);
    eVis = EffectLinkEffects( EffectVisualEffect(SHADSFX_DUR_SPELLTURNING), eVis);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    int nDuration = spell.Level;
    int focus=0,flat=14;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=3;flat=20;}
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=2;flat=17;}
    else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=1;flat=15;}
    int roll=d6();
    int nAbsorb=roll+flat;
    //calculate the duration with proper metamagic handling
    //Enter Metamagic conditions
    if (spell.Meta == METAMAGIC_MAXIMIZE)
    {
        nAbsorb = 6+flat;
    }
    else if (spell.Meta == METAMAGIC_EMPOWER)
    {
        nAbsorb = nAbsorb + (nAbsorb/2);
    }
    else if (spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }
    //Link Effects
    effect eAbsob = EffectSpellLevelAbsorption(9, nAbsorb);
    effect eLink = EffectLinkEffects(eVis, eAbsob);
    eLink = EffectLinkEffects(eLink, eDur);
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    RemoveEffectsFromSpell(spell.Target, spell.Id);
    RemoveEffectsFromSpell(spell.Target, SPELL_LESSER_SPELL_MANTLE);
    RemoveEffectsFromSpell(spell.Target, SPELL_SPELL_MANTLE);
    //Apply the VFX impact and effects
    float duration=DurationToSeconds(nDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eLink,spell.Target,duration);
    if(GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0)
    {
        string report="[GSM278] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)
            +" focus="+IntToString(focus)+" roll="+IntToString(roll)+" flat="+IntToString(flat)
            +" capacity="+IntToString(nAbsorb)+" duration="+FloatToString(duration,0,2)
            +" meta="+IntToString(spell.Meta)+" target="+GetName(spell.Target);
        PrintString(report);SendMessageToPC(spell.Caster,report);
    }
}


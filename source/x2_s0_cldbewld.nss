//::///////////////////////////////////////////////
//:: Cloud of Bewilderment
//:: X2_S0_CldBewld
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A cone of noxious air goes forth from the caster.
    Enemies in the area of effect are stunned and blinded
    1d6 rounds. Foritude save negates effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: November 04, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if(!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    float fRadius = GetAreaOfEffectRadius(AOE_PER_FOG_OF_BEWILDERMENT);
    // no stacking
    if(CheckNearAoes(spell.Caster, spell.Loc, fRadius))
        return;
    // no cast near triggers
    if(GetNearTriggers(spell.Caster, spell.Loc))
        return;

    effect eAOE = EffectAreaOfEffect(AOE_PER_FOG_OF_BEWILDERMENT);
    int nDuration = spell.Level;
    effect eImpact = EffectVisualEffect(VFX_IMP_DUST_EXPLOSION);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    //Make metamagic check for extend
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Create the AOE object at the selected location
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, DurationToSeconds(nDuration));
    spellsSetupNewAOE(AOE_PER_FOG_OF_BEWILDERMENT, "x2_s0_cldbewldc");
    AddMarkersForAOE(spell.Caster, spell.Loc, DurationToSeconds(nDuration), fRadius);
}

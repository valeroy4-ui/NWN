//::///////////////////////////////////////////////
//:: Grease
//:: NW_S0_Grease.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creatures entering the zone of grease must make
    a reflex save or fall down.  Those that make
    their save have their movement reduced by 1/2.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 1, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();

    float fRadius = GetAreaOfEffectRadius(AOE_PER_GREASE);
    // no stacking
    if(CheckNearAoes(spell.Caster, spell.Loc, fRadius))
        return;
    // no cast near triggers
    if(GetNearTriggers(spell.Caster, spell.Loc))
        return;

    effect eAOE = EffectAreaOfEffect(AOE_PER_GREASE);
    int nDuration = spell.Level;
    effect eImpact = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_GREASE);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
    //Check Extend metamagic feat.
    if(spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration *2;    //Duration is +100%
    }

    int nDurationOverride = GetModuleSwitchValue("MODULE_SWITCH_CORMYR_MAX_LEVEL_AOE_DURATION_SEC");
    if (spell.Level == CORMYREAN_CHARACTER_MAX_LVL && nDurationOverride)
        nDuration = nDurationOverride;

    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, DurationToSeconds(nDuration));
    spellsSetupNewAOE(AOE_PER_GREASE, "nw_s0_greasec");
    AddMarkersForAOE(spell.Caster, spell.Loc, DurationToSeconds(nDuration), fRadius);
}

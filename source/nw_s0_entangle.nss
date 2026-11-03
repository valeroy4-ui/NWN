//::///////////////////////////////////////////////
//:: Entangle
//:: NW_S0_Enangle
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Area of effect spell that places the entangled
  effect on enemies if they fail a saving throw
  each round.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On:  Dec 12, 2001
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: July 31, 2001

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();

    float fRadius = GetAreaOfEffectRadius(AOE_PER_ENTANGLE);
    // no stacking
    if(CheckNearAoes(spell.Caster, spell.Loc, fRadius))
        return;
    // no cast near triggers
    if(GetNearTriggers(spell.Caster, spell.Loc))
        return;


    effect eAOE = EffectAreaOfEffect(AOE_PER_ENTANGLE);
    int nDuration = 3 + spell.Level / 2;
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
    spellsSetupNewAOE(AOE_PER_ENTANGLE, "nw_s0_entanglec");
    AddMarkersForAOE(spell.Caster, spell.Loc, DurationToSeconds(nDuration), fRadius);
}

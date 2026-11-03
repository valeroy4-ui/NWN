//::///////////////////////////////////////////////
//:: Poison
//:: NW_S0_Poison.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Must make a touch attack. If successful the target
    is struck down with wyvern poison.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 22, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();

    float fRadius = GetAreaOfEffectRadius(202 /*VFX_PER_FOGHOLY*/);
    // no stacking
    if(CheckNearAoes(spell.Caster, spell.Loc, fRadius))
        return;
    // no cast near triggers
    if(GetNearTriggers(spell.Caster, spell.Loc))
        return;

    effect eAOE = EffectAreaOfEffect(202 /*VFX_PER_FOGODD*/, "nw_s0_poisona", "", "nw_s0_poisonb");

    int nDuration = spell.Level;

    //Check Extend metamagic feat.
    if(spell.Meta & METAMAGIC_EXTEND)
        nDuration = nDuration *2;    //Duration is +100%

    int nDurationOverride = GetModuleSwitchValue("MODULE_SWITCH_CORMYR_MAX_LEVEL_AOE_DURATION_SEC");
    if (spell.Level == CORMYREAN_CHARACTER_MAX_LVL && nDurationOverride)
        nDuration = nDurationOverride;

    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, DurationToSeconds(nDuration));
    spellsSetupNewAOE(202 /*VFX_PER_FOGODD*/);
    AddMarkersForAOE(spell.Caster, spell.Loc, DurationToSeconds(nDuration), fRadius);
}

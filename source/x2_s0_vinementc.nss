//::///////////////////////////////////////////////
//:: Vine Mine, Entangle C
//:: X2_S0_VineMEntC
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Heartbeat healing for the persistent Vine Mine area.
    Spell529 uses its cast-time Enchantment focus snapshot.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Georg Zoeller, 14/08/2003
/*
Patch 1.70

- aoe signalized wrong spell ID
- incorporeal creatures could been affected
- added delay into applications of effects and VFXs
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "_inc_players"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    //Declare major variables
    aoesDeclareMajorVariables();

    //--------------------------------------------------------------------------
    // GZ 2003-Oct-15
    // When the caster is no longer there, all functions calling
    // GetAreaOfEffectCreator will fail. Its better to remove the barrier then
    //--------------------------------------------------------------------------

    if (!GetIsObjectValid(aoe.Creator) || GetIsDead(aoe.Creator))
    {
        ExecuteScript("_plc_aoe_destroy", OBJECT_SELF);
        DestroyObject(OBJECT_SELF, 1.0);
        return;
    }

    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(GetFactionEqual(oTarget, aoe.Creator))
        {

            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id, FALSE));
            // Only spell529 uses the new, cast-time snapshot. Shared legacy IDs retain2*CL.
            int updated=GetLocalInt(aoe.AOE,"VM286_READY");
            int nHealPoints=updated?GetLocalInt(aoe.AOE,"VM286_HEAL"):spell.Level*2;
            int nMaxHealPoints = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
            if(nMaxHealPoints < 0)
                nMaxHealPoints = 0;
            nHealPoints = (nHealPoints >= nMaxHealPoints) ? nMaxHealPoints : nHealPoints;

            if(updated && GetIsPC(aoe.Creator) && FindSubString(GetStringLowerCase(GetName(aoe.Creator)),"[test]")>=0)
            {
                string report="[VM286 TICK] target="+GetName(oTarget)+" heal="+IntToString(nHealPoints);
                PrintString(report);SendMessageToPC(aoe.Creator,report);
            }
            effect eHeal = EffectHeal(nHealPoints);
            effect eVis = EffectVisualEffect(CEPVFX_IMP_HEALING_S_GREEN);

            effect eLink = EffectLinkEffects(eHeal, eVis);

            //random delay so each creature in AOE will be affected in different moment
            float fDelay = GetRandomDelay();
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget));
            //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSeeInvisible(), oTarget, 60.0);
        }
        //Get next target in the AOE
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}

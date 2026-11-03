//::///////////////////////////////////////////////
//:: Henchman Death Script
//::
//:: NW_CH_AC7.nss
//::
//:: Copyright (c) 2001-2003 Bioware Corp.
//:://////////////////////////////////////////////
//:: Official Campaign Henchmen Respawn
//:://////////////////////////////////////////////
//::
//:: Modified by:   Brent, April 3 2002
//::                Removed delay in respawning
//::                the henchman - caused bugs
//:
//::                Georg, Oct 8 2003
//::                Rewrote teleport to temple routine
//::                because it was broken by
//::                some delicate timing issues in XP2
//:://////////////////////////////////////////////

#include "nw_i0_generic"
#include "nw_i0_plot"


// -----------------------------------------------------------------------------
// Georg, 2003-10-08
// Rewrote that jump part to get rid of the DelayCommand Code that was prone to
// timing problems. If want to see a really back hack, this function is just that.
// -----------------------------------------------------------------------------
void WrapJump(string sTarget)
{
    if (GetIsDead(OBJECT_SELF))
    {
        // * Resurrect and heal again, just in case
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectResurrection(), OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectHeal(GetMaxHitPoints(OBJECT_SELF)), OBJECT_SELF);

        // * recursively call self until we are alive again
        DelayCommand(1.0f,WrapJump(sTarget));
        return;
    }
    // * since the henchmen are teleporting very fast now, we leave a bloodstain on the ground
    object oBlood = CreateObject(OBJECT_TYPE_PLACEABLE,"plc_bloodstain", GetLocation(OBJECT_SELF));

    // * Remove blood after a while
    DestroyObject(oBlood,30.0f);

    // * Ensure the action queue is open to modification again
    SetCommandable(TRUE,OBJECT_SELF);

    // * Jump to Target
    JumpToObject(GetObjectByTag(sTarget), FALSE);

    // * Unset busy state
    ActionDoCommand(SetAssociateState(NW_ASC_IS_BUSY, FALSE));

    // * Make self vulnerable
    SetPlotFlag(OBJECT_SELF, FALSE);

    // * Set destroyable flag to leave corpse
    DelayCommand(6.0f, SetIsDestroyable(TRUE, TRUE, TRUE));
}

// -----------------------------------------------------------------------------
// Georg, 2003-10-08
// Changed to run the bad recursive function above.
// -----------------------------------------------------------------------------
void BringBack()
{
    object oSelf = OBJECT_SELF;
    SetLocalObject(oSelf,"NW_L_FORMERMASTER", GetMaster());
    RemoveEffects(oSelf);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectResurrection(), OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectHeal(GetMaxHitPoints(OBJECT_SELF)), OBJECT_SELF);

    object oWay = GetWaypointByTag("WP_ARMORATHING");

    if (GetIsObjectValid(oWay) == TRUE)
     {
      DelayCommand(1.0, WrapJump(GetTag(oWay)));
     }
}
void main()
{
    // * This is used by the advanced henchmen
    // * Let Brent know if it interferes with animal
    // * companions et cetera
    if (GetIsObjectValid(GetMaster()) == TRUE)
    {
        object oMe = OBJECT_SELF;
        if (GetAssociateType(oMe) == ASSOCIATE_TYPE_HENCHMAN
            // * this is to prevent 'double hits' from stopping
            // * the henchmen from moving to the temple of tyr
            // * I.e., henchmen dies 'twice', once after leaving  your party
            || GetLocalInt(oMe, "NW_L_HEN_I_DIED") == TRUE)
        {
            // -----------------------------------------------------------------------------
            // Georg, 2003-10-08
            // Rewrote code from here.
            // -----------------------------------------------------------------------------

           //SetPlotFlag(oMe, TRUE);
           SetAssociateState(NW_ASC_IS_BUSY, TRUE);
           AddJournalQuestEntry("Henchman", 99, GetMaster(), FALSE, FALSE, FALSE);
           SetIsDestroyable(FALSE, TRUE, TRUE);
           SetLocalInt(OBJECT_SELF, "NW_L_HEN_I_DIED", TRUE);
           BringBack();

           // -----------------------------------------------------------------------------
           // End of rewrite
           // -----------------------------------------------------------------------------

        }
        else
        if (GetAssociate(ASSOCIATE_TYPE_FAMILIAR, GetMaster()) == OBJECT_SELF || GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, GetMaster()) == OBJECT_SELF)
        {
            int nCurrentHP = GetCurrentHitPoints(GetMaster());
            if(nCurrentHP > 0)
            {
                effect eDam = EffectDamage(nCurrentHP / 2);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, GetMaster());

            }
            FloatingTextStrRefOnCreature(63489, GetMaster(), FALSE);
        }
    }
}

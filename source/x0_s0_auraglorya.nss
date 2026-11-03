//::///////////////////////////////////////////////
//:: Aura of Fear On Enter
//:: NW_S1_AuraFearA.nss
//:: Copyright (c) 2005 Cormyrean Prophencies
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: SpiderX
//:: Created On: November 23, 2005
//:://////////////////////////////////////////////

#include "nw_i0_spells"

void main()
{
    //Declare major variables
    object oCaster = GetAreaOfEffectCreator();
    object oTarget = GetEnteringObject();
    effect eFear = EffectImmunity(IMMUNITY_TYPE_FEAR);
    if (GetIsReactionTypeFriendly(oTarget, oCaster) || GetFactionEqual(oTarget, oCaster))
    {
        if (oTarget != oCaster)
        {
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eFear, oTarget);
        }
    }
}

//::///////////////////////////////////////////////
//:: Aura of Fear On Exit
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
    object oTarget = GetExitingObject();
    object oCaster = GetAreaOfEffectCreator();
    if (GetIsReactionTypeFriendly(oTarget, oCaster) || GetFactionEqual(oTarget, oCaster))
    if (oTarget != oCaster) RemoveEffectsFromSpell(oTarget, SPELL_AURAOFGLORY);
}

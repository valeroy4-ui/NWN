#include "nwnx_events"
#include "nwnx_creature"
#include "_inc_constants"
#include "_inc_generic"

void main()
{
    object oPC = OBJECT_SELF;
    object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));
    object oItem = StringToObject(NWNX_Events_GetEventData("ITEM_OBJECT_ID"));

    if(!GetIsPC(oPC) || GetIsDM(oPC))
        return;

    if(oTarget == oPC)
        generic_BrokenAnimationBlinkFix(oPC, oItem);


    int nItemBaseType = GetBaseItemType(oItem);
    if(nItemBaseType == BASE_ITEM_POTIONS && oTarget != oPC)
    {
        //FloatingColorTextStringOnCreature("You can only use potions on yourself.", TXT_COLOR_RED, oPC, FALSE);
        NWNX_Events_SkipEvent();
    }
}



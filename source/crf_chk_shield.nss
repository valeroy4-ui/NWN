#include "cr_craft_system"
// аромор на теле?

int StartingConditional()
{
    int iResult;
    if(GetItemInSlot(INVENTORY_SLOT_LEFTHAND,GetPCSpeaker())==OBJECT_INVALID)
    {
        iResult = FALSE;
    }
    else
    {
        if(GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_LEFTHAND,GetPCSpeaker()))==BASE_ITEM_SMALLSHIELD
            || GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_LEFTHAND,GetPCSpeaker()))==BASE_ITEM_LARGESHIELD
            || GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_LEFTHAND,GetPCSpeaker()))==BASE_ITEM_TOWERSHIELD)
        {
            iResult = TRUE;
        }
        else iResult = FALSE;
    }

    return iResult;
}







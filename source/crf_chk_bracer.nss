#include "cr_craft_system"
// аромор на теле?

int StartingConditional()
{
    int iResult = FALSE;
    object oPC = GetPCSpeaker();
    if(GetItemInSlot(INVENTORY_SLOT_ARMS,oPC)==OBJECT_INVALID)
    {
        iResult = FALSE;
    }
    else
    {   if(GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_ARMS,oPC))==BASE_ITEM_BRACER)
        iResult = TRUE;
    }

    return iResult;
}



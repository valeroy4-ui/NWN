#include "cr_craft_system"
// проверка абилок

int StartingConditional()
{
    int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    if(oItem!=OBJECT_INVALID)
    {

        if(CheckIPType(ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,-1,0,0,oItem)>0)
        {
             iResult = TRUE;
        }
        else
        {
             iResult = FALSE;
        }
    }
    else
    {
         iResult = FALSE;
    }
    // фикс крафта на вепоны
     if(GetLocalInt(GetPCSpeaker(),CONST_SLOT)==INVENTORY_SLOT_LEFTHAND)
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


#include "cr_craft_system"
// проверка дамага

int StartingConditional()
{
    int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    if(oItem!=OBJECT_INVALID)
    {

        if(CheckIPType(ITEM_PROPERTY_DAMAGE_BONUS,GetLocalInt(GetPCSpeaker(),CONST_DAMAGE),4,6,oItem)>0)
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

    return iResult;
}


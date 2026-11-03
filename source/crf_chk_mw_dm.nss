#include "cr_craft_system"
// проверка дамага

int StartingConditional()
{
    int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    if(oItem!=OBJECT_INVALID)
    {

        if(CheckIPType(ITEM_PROPERTY_DAMAGE_BONUS,0,4,1,oItem)>0)
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

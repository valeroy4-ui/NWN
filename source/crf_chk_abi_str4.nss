#include "cr_craft_system"
// проверка абилок

int StartingConditional()
{
    int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    if(oItem!=OBJECT_INVALID)
    {

        if(CheckIPType(ITEM_PROPERTY_ABILITY_BONUS,GetLocalInt(GetPCSpeaker(),CONST_ABILITY),0,4,oItem)>0)
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

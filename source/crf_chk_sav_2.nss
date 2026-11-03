#include "cr_craft_system"
// проверка абилок

int StartingConditional()
{
    int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    if(oItem!=OBJECT_INVALID)
    {

        if(CheckIPType(ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,GetLocalInt(GetPCSpeaker(),CONST_SAVE),0,2,oItem)>0 && CheckIPType(ITEM_PROPERTY_SAVING_THROW_BONUS,GetLocalInt(GetPCSpeaker(),CONST_SAVE),0,1,oItem)>0)
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



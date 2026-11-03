#include "cr_craft_system"
// проверка энчанта

int StartingConditional()
{
    int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    if(oItem!=OBJECT_INVALID && GetLocalInt(GetPCSpeaker(),CONST_SLOT)!=INVENTORY_SLOT_ARMS)
    {

        if(GetWeaponEnchant(oItem)>=0 && GetWeaponEnchant(oItem)<CONST_MAX_ENCHANT_BONUS)
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

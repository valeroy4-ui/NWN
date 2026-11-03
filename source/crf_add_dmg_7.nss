#include "cr_craft_system"
// добавление дамага

void main()
{
      int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    AddIP2Item(ITEM_PROPERTY_DAMAGE_BONUS,GetLocalInt(GetPCSpeaker(),CONST_DAMAGE),4,7,oItem);

}


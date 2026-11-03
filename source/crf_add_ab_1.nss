#include "cr_craft_system"
// добавление АБ

void main()
{
      int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    AddIP2Item(ITEM_PROPERTY_ATTACK_BONUS,0,2,1,oItem);

}




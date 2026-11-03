#include "cr_craft_system"
// добавление бонуса абилки

void main()
{
      int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    AddIP2Item(ITEM_PROPERTY_ABILITY_BONUS,GetLocalInt(GetPCSpeaker(),CONST_ABILITY),0,3,oItem);

}



#include "cr_craft_system"
// добавление Ёнчанта

void main()
{
      int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    AddIP2Item(ITEM_PROPERTY_ENHANCEMENT_BONUS,0,2,4,oItem);

}



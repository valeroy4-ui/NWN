#include "cr_craft_system"

void main()     // add enchantment bonus
{
    int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    AddIP2Item(ITEM_PROPERTY_ENHANCEMENT_BONUS,0,2,3,oItem);

}



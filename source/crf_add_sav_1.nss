#include "cr_craft_system"
// добавление бонуса спаса
void main()
{
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    AddIP2Item(ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC,GetLocalInt(GetPCSpeaker(),CONST_SAVE),0,1,oItem);
}




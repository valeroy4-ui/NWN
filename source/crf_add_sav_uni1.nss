#include "cr_craft_system"
// добавление бонуса спаса
void main()
{
      int iResult;
    object oItem = GetItemInSlot(GetLocalInt(GetPCSpeaker(),CONST_SLOT),GetPCSpeaker());
    AddIP2Item(ITEM_PROPERTY_SAVING_THROW_BONUS,GetLocalInt(GetPCSpeaker(),CONST_SAVE),0,1,oItem);

}





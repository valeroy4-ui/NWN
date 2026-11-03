#include "cr_craft_system"
// а в руках дрын есть?

int StartingConditional()
{
    int iResult;
    if(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,GetPCSpeaker())==OBJECT_INVALID)
    {
        iResult = FALSE;
    }
    else
    {
        iResult = TRUE;
    }

    return iResult;
}

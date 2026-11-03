#include "cr_craft_system"
// аромор на теле?

int StartingConditional()
{
    int iResult;
    if(GetItemInSlot(INVENTORY_SLOT_HEAD,GetPCSpeaker())==OBJECT_INVALID)
    {
        iResult = FALSE;
    }
    else
    {
        iResult = TRUE;
    }

    return iResult;
}







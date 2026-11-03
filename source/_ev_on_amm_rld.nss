#include "nwnx_events"
#include "nwnx_object"

void main()
{
    string sEvent = NWNX_Events_GetCurrentEvent();
    if (sEvent == NWNX_ON_ITEM_AMMO_RELOAD_BEFORE)
    {
        // unlimited ammo for creatures
        if(!GetIsPC(OBJECT_SELF))
        {
            int iBaseItemRequested = StringToInt(NWNX_Events_GetEventData("BASE_ITEM_ID"));
            object oItem = GetFirstItemInInventory();
            while(GetIsObjectValid(oItem))
            {
                if(GetBaseItemType(oItem) == iBaseItemRequested)
                {
                    object oAmmo = CopyItem(oItem, OBJECT_SELF);
                    SetDroppableFlag(oAmmo, FALSE);
                    SetItemStackSize(oAmmo, 500);
                    break;
                }
                oItem = GetNextItemInInventory();
            }
        }
    }
}

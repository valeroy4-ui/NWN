#include "nwnx_events"
#include "nwnx_util"


void main()
{
    object oInventoryOwner = OBJECT_SELF;
    object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));

    if(GetObjectType(oInventoryOwner) == OBJECT_TYPE_ITEM && NWNX_Events_GetCurrentEvent() == NWNX_ON_INVENTORY_ADD_ITEM_BEFORE)
    {
        int nContainer = StringToInt(Get2DAString("baseitems", "container", GetBaseItemType(oInventoryOwner)));
        // prevent server crash by gold dupe with container object
        if (nContainer && GetBaseItemType(oItem) == BASE_ITEM_GOLD)
            DestroyObject(oItem);
    }
}

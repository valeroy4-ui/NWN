#include "_inc_stashes"

void main()
{

    object oChest = OBJECT_SELF;
    int iStashID = GetLocalInt(oChest, STASH_ID_VAR);
    //SendMessageToPC(GetLastClosedBy(), "Stash OnClosed UUID=" + GetObjectUUID(oChest));
    if(iStashID > 0 && stashes_SaveStash(iStashID, oChest))
    {
        object oItem = GetFirstItemInInventory(oChest);
        while(GetIsObjectValid(oItem))
        {
            DestroyObject(oItem);
            oItem = GetNextItemInInventory(oChest);
        }
        DestroyObject(oChest);
    }
    else
    {
        SendMessageToPC(GetLastClosedBy(), "Error when saving stash UUID=" + GetObjectUUID(oChest) + ". Report to administrators.");
        // TODO handle ZERO Stash ID
    }
}

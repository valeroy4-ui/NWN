#include "nw_i0_plot"

void main()
{
    // Either open the store with that tag or let the user know that no store exists.
    string sStoreTag = GetLocalString(OBJECT_SELF, "STORE_TAG");
    object oStore = GetNearestObjectByTag(sStoreTag);
    if(GetObjectType(oStore) == OBJECT_TYPE_STORE)
        gplotAppraiseOpenStore(oStore, GetPCSpeaker());
    else
        ActionSpeakStringByStrRef(53090, TALKVOLUME_TALK);
}


void main()
{
    object oPC = GetLastSpeaker();
    object oItem = CreateItemOnObject("fl_temple_item", oPC);
    SetTag(oItem, GetLocalString(OBJECT_SELF, "TEMPLE_ITEM_TAG")) ;
    SetName(oItem, GetLocalString(OBJECT_SELF, "TEMPLE_ITEM_NAME"));
}

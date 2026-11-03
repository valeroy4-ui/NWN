int StartingConditional()
{
    object oPC = GetLastSpeaker();
    if (GetItemPossessedBy(oPC, GetLocalString(OBJECT_SELF, "TEMPLE_ITEM_TAG")) != OBJECT_INVALID) return TRUE;
    return FALSE;
}

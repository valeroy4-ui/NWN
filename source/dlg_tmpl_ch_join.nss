#include "_inc_generic"

int StartingConditional()
{
    object oPC = GetLastSpeaker();
    if (generic_GetHasResrefInInventory(oPC, "fl_temple_item")) return FALSE;
    return TRUE;
}

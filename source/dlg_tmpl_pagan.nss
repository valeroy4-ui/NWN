#include "_inc_generic"
#include "_inc_runes"
#include "_inc_loot_static"

const int DIALOG_TYPE_FAITH     = 1;
const int DIALOG_TYPE_RUNES     = 2;
const int DIALOG_TYPE_LUCKY     = 3;

void main()
{
    object oPC = GetLastSpeaker();
    int iDialogType = StringToInt(GetScriptParam("DIALOG_TYPE"));
    switch(iDialogType)
    {
        case DIALOG_TYPE_FAITH:
        {
            object oTempleItem = generic_FindResrefInInventory(oPC, "fl_temple_item");
            if(GetIsObjectValid(oTempleItem))
                DestroyObject(oTempleItem);
            else
                SendMessageToPC(oPC, "You do not yet believe in any of Gods.");
        }
        break;
        case DIALOG_TYPE_RUNES:
            runes_ClearRunes(oPC);
        break;
        case DIALOG_TYPE_LUCKY:
            int nCost = 500;
            if(SpendFame(oPC, nCost, TRUE, FALSE))
                CreateLootOnObject(oPC, LOOT_MOBS_LEVEL_09 /* epic runes */, 1);
            else
                SendMessageToPC(oPC, "Upgrade is not activated. Not enough fame. Need: " + IntToString(nCost));
        break;
    }
}

#include "_inc_stashes"

void main()
{
    object oChest = OBJECT_SELF;
    int iStashID = GetLocalInt(oChest, STASH_ID_VAR);

    object oPC = GetObjectByUUID(GetScriptParam(STASH_DISTURB_OBJECT_UUID));

    if(iStashID > 0 && GetIsObjectValid(oPC))
    {
        if(stashes_SaveStash(iStashID, oChest))
            if(!GetIsDM(oPC)) ExportSingleCharacter(oPC);
        else
            SendMessageToPC(oPC, "Error when saving stash UUID = " + GetObjectUUID(oChest) +
                                 ". Report to administrators.");
    }
}

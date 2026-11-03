#include "_inc_constants"
#include "nwnx_object"
#include "_inc_itemprop"

void sync_DelayCopy(object oPC,object oContainer);
void SyncPlayerBossLootWithPalette(object oPC);


void SyncPlayerBossLootWithPalette(object oPC)
{
    AssignCommand(oPC, ClearAllActions(TRUE));

    string sContainerTag = "CHEST_SYNC_PALETTE";
    object oContainer = GetObjectByTag(sContainerTag);
    if(!GetIsObjectValid(oContainer))
    {
         AssignCommand(oPC, ActionSpeakString("ERROR: Container: " + sContainerTag + " not found."));
         return;
    }
    SetLocalInt(oContainer, "SYNC", TRUE);

    object oNewItem;
    object oOldItem = GetFirstItemInInventory(oPC);
    while(GetIsObjectValid(oOldItem))
    {
        if(!GetPlotFlag(oOldItem) &&
           (GetLocalString(oOldItem, "LOOT_CATEGORY") == "BLUE"    ||
            GetLocalString(oOldItem, "LOOT_CATEGORY") == "GREEN"   ||
            GetLocalString(oOldItem, "LOOT_CATEGORY") == "PURPLE"  ||
            GetLocalString(oOldItem, "LOOT_CATEGORY") == "RED"     ||
            GetLocalString(oOldItem, "LOOT_CATEGORY") == "ARTIFACT")
          )
        {

            oNewItem = CreateItemOnObject(GetResRef(oOldItem), oContainer, GetItemStackSize(oOldItem), GetTag(oOldItem));

            SetIdentified(oNewItem, GetIdentified(oOldItem));
            SetName(oNewItem, GetName(oOldItem));
            SetStolenFlag(oNewItem, GetStolenFlag(oOldItem));
            SetPickpocketableFlag(oNewItem, GetPickpocketableFlag(oOldItem));
            SetItemCursedFlag(oNewItem, GetItemCursedFlag(oOldItem));

            struct NWNX_Object_LocalVariable stVar;
            int iVarCount;
            for (iVarCount = 0; iVarCount < NWNX_Object_GetLocalVariableCount(oOldItem); iVarCount++)
            {
                stVar = NWNX_Object_GetLocalVariable(oOldItem, iVarCount);
                switch(stVar.type)
                {
                    case NWNX_OBJECT_LOCALVAR_TYPE_INT:
                        SetLocalInt(oNewItem, stVar.key, GetLocalInt(oOldItem, stVar.key));
                    break;
                    case NWNX_OBJECT_LOCALVAR_TYPE_FLOAT:
                        SetLocalFloat(oNewItem, stVar.key, GetLocalFloat(oOldItem, stVar.key));
                    break;
                    case NWNX_OBJECT_LOCALVAR_TYPE_STRING:
                        SetLocalString(oNewItem, stVar.key, GetLocalString(oOldItem, stVar.key));
                    break;
                    case NWNX_OBJECT_LOCALVAR_TYPE_OBJECT:
                        SetLocalObject(oNewItem, stVar.key, GetLocalObject(oOldItem, stVar.key));
                    break;
                    case NWNX_OBJECT_LOCALVAR_TYPE_LOCATION:
                        SetLocalLocation(oNewItem, stVar.key, GetLocalLocation(oOldItem, stVar.key));
                    break;
                }
            }
            DestroyObject(oOldItem);
            // clear cormyr IP cash
            DeleteLocalInt(oNewItem, "CORMYR_VORPAL");
        }
        oOldItem = GetNextItemInInventory(oPC);
    }
    DelayCommand(1.0, sync_DelayCopy(oPC, oContainer));
    DelayCommand(2.0, SetLocalInt(oContainer, "SYNC", FALSE));
}

void sync_DelayCopy(object oPC,object oContainer)
{
    object oContainerItem = GetFirstItemInInventory(oContainer);
    while(GetIsObjectValid(oContainerItem))
    {
        CopyItem(oContainerItem, oPC, TRUE);
        DestroyObject(oContainerItem);

        oContainerItem = GetNextItemInInventory(oContainer);
    }
    AssignCommand(oPC, ActionSpeakString("Synchronization is complete."));
}

void main()
{
    object oPC = GetPCSpeaker();
    if(!GetIsPC(oPC)) return;

    SyncPlayerBossLootWithPalette(oPC);
}

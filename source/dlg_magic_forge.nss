#include "_inc_generic"
#include "_inc_runes"
#include "_inc_loot_static"

const int REWARD_FOR_MELTED_GREEN           = 1;
const int REWARD_FOR_MELTED_PURPLE          = 2;
const int REWARD_FOR_MELTED_RED             = 4;
const int REWARD_FOR_MELTED_ARTIFACT        = 16;

const int REWARD_FOR_MELTED_MASSCAST_RUNE   = 50000;
const int REWARD_FOR_MELTED_EPIC_RUNE       = 500000;

const int DIALOG_TYPE_MELT_DOWN             = 1;
const int DIALOG_TYPE_CONVERT_RUNES         = 2;


void CheckAndDestroy(object oPlaceable)
{
    if (!GetIsObjectValid(GetFirstItemInInventory(oPlaceable)))
        DestroyObject(oPlaceable);
}

void main()
{
    object oPC = GetPCSpeaker();
    object oPersonalMagicForge = GetLocalObject(OBJECT_SELF, GetObjectUUID(oPC));

    int iDlgType = StringToInt(GetScriptParam("DLG_TYPE"));
    switch(iDlgType)
    {
        case DIALOG_TYPE_MELT_DOWN:
        {
            int nRewardGreenCount = 0;
            int nRewardPurpleCount = 0;
            int nRewardRedCount = 0;
            int nRewardArtifactsCount = 0;
            int nRewardRuneMassCastCount = 0;
            int nRewardRuneEpicCount = 0;

            object oItem = GetFirstItemInInventory(oPersonalMagicForge);
            while (GetIsObjectValid(oItem))
            {
                int bDestroy = FALSE;
                string sLootCategory = GetLocalString(oItem, "LOOT_CATEGORY");

                // fucking crutch with sorc loot ==>
                if(sLootCategory == "RED" && FindSubString(GetStringLowerCase(GetName(oItem)), "sorcerer") >= 0)
                   sLootCategory = "PURPLE";
                // fucking crutch with sorc loot <==

                if      (sLootCategory == "GREEN") {
                    nRewardGreenCount++;
                    bDestroy = TRUE;
                }
                else if (sLootCategory == "PURPLE") {
                    nRewardPurpleCount++;
                    bDestroy = TRUE;
                }
                else if (sLootCategory == "RED") {
                    nRewardRedCount++;
                    bDestroy = TRUE;
                }
                else if (sLootCategory == "ARTIFACT") {
                    nRewardArtifactsCount++;
                    bDestroy = TRUE;
                }

                if (FindSubString(GetTag(oItem), "fl_rune_") != -1)
                {
                    int iRuneType = GetLocalInt(oItem, "RUNE_TYPE");
                    if(iRuneType == RUNE_TYPE_MASS_CAST)
                        nRewardRuneMassCastCount++;
                    else if(iRuneType == RUNE_TYPE_EPIC_SPELLS || iRuneType == RUNE_TYPE_EPIC_MISC || iRuneType == RUNE_TYPE_EPIC_COMBAT)
                        nRewardRuneEpicCount++;
                    else
                        WriteLog("Unknown rune detected by Magic Forge.", LOG_LEVEL_ERROR);

                    bDestroy = TRUE;
                }

                if (!bDestroy)
                    AssignCommand(GetModule(), DelayCommand(0.0, generic_MoveItem(oItem, oPC, FALSE)));
                else
                    DestroyObject(oItem);

                oItem = GetNextItemInInventory(oPersonalMagicForge);
            }
            // calculate soulstones reward
            int nSoulStonesReward = nRewardGreenCount * REWARD_FOR_MELTED_GREEN +
                                    nRewardPurpleCount * REWARD_FOR_MELTED_PURPLE +
                                    nRewardRedCount * REWARD_FOR_MELTED_RED +
                                    nRewardArtifactsCount * REWARD_FOR_MELTED_ARTIFACT;
            // calculate gold reward
            int nGoldReward = nRewardRuneMassCastCount * REWARD_FOR_MELTED_MASSCAST_RUNE +
                              nRewardRuneEpicCount * REWARD_FOR_MELTED_EPIC_RUNE;

            generic_ChangeSoulStonesAmount(oPC, nSoulStonesReward);
            GiveGoldToCreature(oPC, nGoldReward);

            DelayCommand(0.0, CheckAndDestroy(oPersonalMagicForge));
            break;
        } // end case DIALOG_TYPE_MELT_DOWN
        case DIALOG_TYPE_CONVERT_RUNES:
        {
            int nRuneMassCastCount = 0;
            int nRuneEpicCount = 0;
            object oItem = GetFirstItemInInventory(oPersonalMagicForge);
            while (GetIsObjectValid(oItem))
            {
                int iRuneType = GetLocalInt(oItem, "RUNE_TYPE");
                if(iRuneType == RUNE_TYPE_MASS_CAST)
                {
                    ++nRuneMassCastCount;
                    SetLocalObject(oPC, "RUNE_MASS_CAST_" + IntToString(nRuneMassCastCount), oItem);
                    AssignCommand(GetModule(), DelayCommand(0.5, DeleteLocalObject(oPC, "RUNE_MASS_CAST_" + IntToString(nRuneMassCastCount))));
                }
                else if(iRuneType == RUNE_TYPE_EPIC_SPELLS || iRuneType == RUNE_TYPE_EPIC_MISC || iRuneType == RUNE_TYPE_EPIC_COMBAT)
                {
                    ++nRuneEpicCount;
                    SetLocalObject(oPC, "RUNE_EPIC_" + IntToString(nRuneEpicCount), oItem);
                    AssignCommand(GetModule(), DelayCommand(0.5, DeleteLocalObject(oPC, "RUNE_EPIC_" + IntToString(nRuneEpicCount))));
                }
                else
                    AssignCommand(GetModule(), DelayCommand(0.0, generic_MoveItem(oItem, oPC, FALSE)));
                // convert 3 runes to 1 if mod by division 3 is 0 and set block for this counter
                if(nRuneMassCastCount % 3 == 0 && nRuneMassCastCount > 0 && !GetLocalInt(oPC, "RUNE_MASS_CAST_BLOCK" + IntToString(nRuneMassCastCount)))
                {
                    SetLocalInt(oPC, "RUNE_MASS_CAST_BLOCK" + IntToString(nRuneMassCastCount), TRUE);
                    AssignCommand(GetModule(), DelayCommand(0.5, DeleteLocalInt(oPC, "RUNE_MASS_CAST_BLOCK" + IntToString(nRuneMassCastCount))));
                    int i;
                    for(i = nRuneMassCastCount - 2; i <= nRuneMassCastCount; i++)
                    {
                        object oRune = GetLocalObject(oPC, "RUNE_MASS_CAST_" + IntToString(i));
                        DestroyObject(oRune);
                    }
                    CreateLootOnObject(oPC, LOOT_MOBS_LEVEL_08, 1);
                }
                if(nRuneEpicCount % 3 == 0 && nRuneEpicCount > 0 && !GetLocalInt(oPC, "RUNE_EPIC_BLOCK_" + IntToString(nRuneEpicCount)))
                {
                    SetLocalInt(oPC, "RUNE_EPIC_BLOCK_" + IntToString(nRuneEpicCount), TRUE);
                    AssignCommand(GetModule(), DelayCommand(0.5, DeleteLocalInt(oPC, "RUNE_EPIC_BLOCK_" + IntToString(nRuneEpicCount))));
                    int i;
                    for(i = nRuneEpicCount - 2; i <= nRuneEpicCount; i++)
                    {
                        object oRune = GetLocalObject(oPC, "RUNE_EPIC_" + IntToString(i));
                        DestroyObject(oRune);
                    }
                    CreateLootOnObject(oPC, LOOT_MOBS_LEVEL_09, 1);
                }
                oItem = GetNextItemInInventory(oPersonalMagicForge);
            }
            break;
        }
    } // end case
}

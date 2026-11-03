#include "_inc_generic"
#include "_inc_factions"
#include "nwnx_util"
#include "_inc_death"
#include "_inc_onhit"

// verification that the killer meets the necessary conditions
int GetIsKillerValid(object oKiller);

// send PK message to server's shout
void SendPKInfo(object oKiller, object oKilled, int bDislike);

// returns killer if killer is PC, else returns OBJECT_INVALID if killer mob or dm etc
object GetKiller(object oVictim);

// returns true if there are hostile players in area
int GetEnemyPCsInArea(object oPC);

// count drop chance and select items for drop
void ItemLoss(object oPC, object oKiller, int nItemsAmount = 1, int bInventoryDrop = TRUE, int bDropInventoryOnly = FALSE);

// return part of stack to PC
void ReturnPartOfItemStackToPC(object oSourceItem, object oPC, int nStackSizeSource, int nStackSizeCopy);

//
string death_ShowTop3DPS(object oTarget);

//
void death_PlayAnnouncer(object oPC, object oKiller);


void main()
{
    object oPC = OBJECT_SELF;
    object oKiller = GetKiller(oPC);
    object oLKiller = GetLastKiller();
    object oDeathArea = GetIsObjectValid(GetArea(oPC)) ? GetArea(oPC) :
                        GetAreaFromLocation(GetLocalLocation(oPC, "LAST_PLAYER_LOCATION"));

    int iKilledPlayerID = players_GetPCPersistentID(oPC);
    int iKilledHitDice = GetHitDice(oPC);

    int bDeathByPvP = FALSE;
    int bDeathByPlayer = GetIsPC(oKiller) & !GetIsDM(oKiller);
    int bDropConditionsAreValid = StringToInt(db_GetModuleParameter(MODULE_SETTING_ENABLE_ITEM_DROP)) && iKilledHitDice >= 20 ||
                                  GetResRef(oDeathArea) == CONST_CORMYR_SHOP_AREA_RESREF || GetLocalInt(oDeathArea, "POTIONS_DROP");

    if(GetIsObjectValid(oKiller))
    {
        // slayer last hit healing
        onhit_LastHitHealing(oKiller, oPC, SPELL_LAST_HIT, TRUE);
        // handle Head Hunter
        if(GetHasFeat(FEAT_HEAD_HUNTER, oKiller) && !players_GetFactionsEqual(oKiller, oPC))
        {
            object oHead = CreateItemOnObject("fl_headhunter", oKiller);
            //SetIdentified(oHead, TRUE);
            SetLocalInt(oHead, "VICTIM_LEVEL", GetHitDice(oPC));
            SetLocalString(oHead, "VICTIM_NAME", GetName(oPC));
        }
        if(GetHitDice(oPC) > 1)
        {
            int nReaction = GetIsReactionTypeHostile(oKiller, oPC);
            if(!nReaction) nReaction = GetIsReactionTypeHostile(oPC, oKiller);
            if(!nReaction) nReaction = GetIsEnemy(oKiller, oPC);
            if(!nReaction) nReaction = !players_GetFactionsEqual(oKiller, oPC);

            SendPKInfo(oKiller, oPC, nReaction);
            if(nReaction)
            {
                // give PVP experience
                factions_GivePvPXP(oKiller, oPC);
                // drop item
                if(bDropConditionsAreValid) ItemLoss(oPC, oKiller);
                // detect PVP death
                bDeathByPvP = TRUE;
                if(iKilledHitDice > 1)
                {
                    if(!players_GetFactionsEqual(oKiller, oPC))
                    {
                        factions_GiveKillsAndAssistsReward(oKiller, oPC); // give fame
                        death_PlayAnnouncer(oPC, oKiller); // play announcer
                        if(iKilledHitDice >= 35)       // give soulstone
                        {
                            string sNoPvPReward = IntToString(iKilledPlayerID) + "_NO_PVP_REWARD";
                            if(!GetLocalInt(GetModule(), sNoPvPReward))
                            {
                                generic_ChangeSoulStonesAmount(oKiller, 1);
                                AssignCommand(GetModule(), DelayCommand(5.0, SetLocalInt(GetModule(), sNoPvPReward, TRUE)));
                                AssignCommand(GetModule(), DelayCommand(30.0 * 60.0, DeleteLocalInt(GetModule(), sNoPvPReward)));
                            }
                        }    // give soulstone end
                    }
                }
            }
            // if killer is friendly
            else if(bDropConditionsAreValid)
                ItemLoss(oPC, oKiller, 0, TRUE, TRUE);
        }
        else
        {
            // fucking newbie killer
        }
    }
    else
    {
        if(GetEnemyPCsInArea(oPC) && iKilledHitDice >= 20 && !GetLocalInt(oLKiller, "IMGUARD"))
        {
            SendColorMessageToPC(oPC, "You died in the area with hostile players. Roll the dice!", TXT_COLOR_RED);
            ItemLoss(oPC, OBJECT_INVALID);
        }
    }

    // create corpse and tomb, set death type
    int nDeathType = DEATH_TYPE_DEFAULT;
    if(GetHasSpellEffect(SPELL_VASELINE_POTION, oPC))
        nDeathType = DEATH_TYPE_VASELINED;
    else if(bDeathByPvP)
        nDeathType = DEATH_TYPE_ENEMY_PLAYER;
    else if(GetLocalInt(oDeathArea, "BOSS_AREA"))
        nDeathType = DEATH_TYPE_BOSS;
    else if(bDeathByPlayer)
        nDeathType = DEATH_TYPE_FRIENDLY_PLAYER;

    RipPlayerAfterDeath(oPC, iKilledPlayerID, nDeathType);
    // clear top3 dps locals
    DeleteLocalJson(oPC, "JSON_STORED_DPS_VALUE");
    DeleteLocalJson(oPC, "JSON_STORED_DPS_FACTION");
}

int GetIsKillerValid(object oKiller)
{
    if(GetIsPC(oKiller) && !GetIsDM(oKiller) && !GetIsDMPossessed(oKiller))
        return TRUE;
    return FALSE;
}

void SendPKInfo(object oKiller, object oKilled, int bDislike)
{
    int nKillerFaction = players_GetFaction(oKiller);
    int nKilledFaction = players_GetFaction(oKilled);
    string sKiller = players_GetFactionColor(nKillerFaction) + NWNX_Util_StripColors(GetName(oKiller)) +
                                    " ("+IntToString(GetHitDice(oKiller))+")" + TXT_COLOR_END;
    string sKilled = players_GetFactionColor(nKilledFaction) + NWNX_Util_StripColors(GetName(oKilled)) +
                                    " ("+IntToString(GetHitDice(oKilled))+")" + TXT_COLOR_END;

    object oArea = GetIsObjectValid(GetArea(oKilled)) ? GetArea(oKilled): GetAreaFromLocation(GetLocalLocation(oKilled, "LAST_PLAYER_LOCATION"));
    // killer
    string sKillerPlayersAreaVar = "FACTION_" + IntToString(nKillerFaction) + "_PLAYERS_COUNT";
    int nKillerPlayersCount = GetLocalInt(oArea, sKillerPlayersAreaVar);
    nKillerPlayersCount = nKillerPlayersCount > 0 ? nKillerPlayersCount : 1;
    string sKillerPlayersCount = players_GetFactionColor(nKillerFaction) + IntToString(nKillerPlayersCount) + TXT_COLOR_END;
    // killed
    string sKilledPlayersAreaVar = "FACTION_" + IntToString(nKilledFaction) + "_PLAYERS_COUNT";
    int nKilledPlayersCount = GetLocalInt(oArea, sKilledPlayersAreaVar);
    nKilledPlayersCount = nKilledPlayersCount > 0 ? nKilledPlayersCount : 1;
    string sKilledPlayersCount = players_GetFactionColor(nKilledFaction) + IntToString(nKilledPlayersCount) + TXT_COLOR_END;

    string szMessage = TXT_COLOR_GREEN_L;
    if (bDislike)
        szMessage = TXT_COLOR_RED;

    /*
    int nPhraseCount = 30;
    int nCurrentPhrase = Random(nPhraseCount);
    switch(nCurrentPhrase)
    {
    case 0:
        szMessage += sKilled + " is a rotting meatbag now!";
    break;
    case 1:
        szMessage += sKilled + " was at the wrong place at the wrong time!";
    break;
    case 2:
        szMessage += "Now is the best time to loot " + sKilled + "!";
    break;
    case 3:
        szMessage += sKilled + " now sees dead people, because was killed!";
    break;
    case 4:
        szMessage += sKilled + " was an easy prey for someone!";
    break;
    case 5:
        szMessage += "Rotting body of " + sKilled + " only attracts flies and zombies now!";
    break;
    case 6:
        szMessage += "That was unlucky day for "+ sKilled + "!";
    break;
    case 7:
        szMessage += sKilled + " was weak and was killed!";
    break;
    case 8:
        szMessage += sKilled + " once again became a rotting body!";
    break;
    case 9:
        szMessage += sKilled + " is no more!";
    break;
    case 10:
        szMessage += sKilled + " just became zombie chow!";
    break;
    case 11:
        szMessage += "Another soul for the reaper: " + sKilled + "!";
    break;
    case 12:
        szMessage += sKilled + " tripped into eternity!";
    break;
    case 13:
        szMessage += "The gods claim " + sKilled + " as their latest sacrifice!";
    break;
    case 14:
        szMessage += sKilled + " danced too close to the blade!";
    break;
    case 15:
        szMessage += "Farewell, " + sKilled + ", your loot awaits the living!";
    break;
    case 16:
        szMessage += sKilled + " met the sharp end of fate!";
    break;
    case 17:
        szMessage += "In the game of thrones, " + sKilled + " lost their head!";
    break;
    case 18:
        szMessage += sKilled + " is now fertilizing the dungeon floor!";
    break;
    case 19:
        szMessage += "RIP " + sKilled + ", may your respawn be swift!";
    break;
    case 20:
        szMessage += sKilled + " was outplayed and outslayed!";
    break;
    case 21:
        szMessage += "The shadows claim " + sKilled + " tonight!";
    break;
    case 22:
        szMessage += sKilled + " rolled a natural 1 on survival!";
    break;
    case 23:
        szMessage += "Alas, poor " + sKilled + ", we hardly knew ye... or your inventory!";
    break;
    case 24:
        szMessage += sKilled + " joined the choir invisible!";
    break;
    case 25:
        szMessage += "One less adventurer: " + sKilled + " bites the dust!";
    break;
    case 26:
        szMessage += sKilled + " became a permanent resident of the morgue!";
    break;
    case 27:
        szMessage += "The dice gods have spoken: " + sKilled + " is toast!";
    break;
    case 28:
        szMessage += sKilled + " found the exit... to the afterlife!";
    break;
    case 29:
        szMessage += "No more quests for " + sKilled + ", just eternal rest!";
    break;
    }



    szMessage += "\nKiller: " + sKiller;
    */
    szMessage += sKiller + " killed " + sKilled + " [" + sKillerPlayersCount + "vs" + sKilledPlayersCount + "]";
    szMessage += "\nArea: " + TXT_COLOR_YELLOW + GetName(oArea);
    szMessage += TXT_COLOR_END;
    szMessage += death_ShowTop3DPS(oKilled);

    ServerShout(szMessage);
    WriteLog("PVP: " + GetName(oKilled) + "(" + IntToString(GetHitDice(oKilled)) +
         ") killed by " +
         GetName(oKiller) + "(" +IntToString(GetHitDice(oKiller))+
         "). Area: " + GetName(oArea) +
         ". Dislike: " + IntToString(bDislike));
}

object GetKiller(object oVictim)
{
    object oKiller = GetLastKiller();
    object oMaster = GetMaster(oKiller);

    if (GetIsObjectValid(oMaster) && !GetIsDMPossessed(oKiller))
        oKiller = oMaster;

    // killer is PC or his summom
    if (GetIsObjectValid(oKiller) && GetIsKillerValid(oKiller))
        return oKiller;

    // killer is someone who dealt damage or attacked
    object oHostile = GetLastHostileActor(oVictim);
    if(GetIsObjectValid(oHostile) && GetIsKillerValid(oHostile))
        return oHostile;

    // killer = trap creator
    object oTrapCreatorKiller = GetTrapCreator(oKiller);
    if(oTrapCreatorKiller != oKiller && GetIsKillerValid(oTrapCreatorKiller))
        return oTrapCreatorKiller;

    // killer is not PC and not PC's summon
    if(GetIsObjectValid(oKiller)    &&
       !GetIsPC(oKiller)            &&
       !GetIsDM(oKiller)            &&
       !GetIsDMPossessed(oKiller)   &&
        GetObjectType(oKiller) == OBJECT_TYPE_CREATURE)
    {
        // seems killer is mob, send message to victim and write log
        SendMessageToPC(oVictim, "You was killed by NPC: " + GetName(oKiller));
        WriteLog(GetName(oVictim) + " was killed by NPC: " + GetName(oKiller));
        return OBJECT_INVALID;
    }
    if(GetIsObjectValid(oKiller) && oKiller == GetModule())
    {
        SendColorMessageToPC(oVictim, "Seems you are victim of divine intervention.", TXT_COLOR_YELLOW_T);
        return OBJECT_INVALID;
    }
    // if the versions above is incorrect then PIZDETS and killer is unknown
    if(!GetIsObjectValid(oKiller) && !GetIsObjectValid(oHostile) &&!GetIsObjectValid(oMaster) &&
       !GetIsObjectValid(oTrapCreatorKiller))
    {
        SendColorMessageToPC(oVictim,"ERROR: You were killed by an unknown force.", TXT_COLOR_RED);
    }
    return OBJECT_INVALID;
}

int GetEnemyPCsInArea(object oPC)
{
    object oArea = GetArea(oPC);
    object oEnemy = GetFirstObjectInArea(oArea, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(oEnemy))
    {
        if(GetIsPC(oEnemy) && !GetIsDM(oEnemy) && !GetIsDMPossessed(oEnemy))
        {
            if(GetIsEnemy(oPC, oEnemy) || GetIsEnemy(oEnemy, oPC))
                return TRUE;
        }
        oEnemy = GetNextObjectInArea(oArea, OBJECT_TYPE_CREATURE);
    }
    return FALSE;
}

void ItemLoss(object oPC, object oKiller, int nItemsAmount = 1, int bInventoryDrop = TRUE, int bDropInventoryOnly = FALSE)
{
    int iFactionPC              = players_GetFaction(oPC);
    // drop settings
    int iSavePercent            = 50; // save chance for boss items and gold in inventory
    int nBaseMiniDropChance     = 25; // base drop chance for mini loot
    int nBaseEpicDropChance     = 25; // base drop chance for epic loot
    int nTotalFactionsFame      = factions_GetTotalFactionsFame(); // total fame
    int nDropChanceIncreaseStep = 50000;
    // end drop settings

    // calculate chances
    nBaseMiniDropChance += nTotalFactionsFame/nDropChanceIncreaseStep;
    nBaseMiniDropChance = nBaseMiniDropChance > 100 ? 100: nBaseMiniDropChance;

    nBaseEpicDropChance += nTotalFactionsFame/nDropChanceIncreaseStep;
    nBaseEpicDropChance = nBaseEpicDropChance > 50 ? 50: nBaseEpicDropChance;

    // declare cash arrays tags
    string DROP_GARBAGE_CASH_TABLE  = "DROP_GARBAGE_CASH_TABLE";
    string DROP_BLUE_CASH_TABLE     = "DROP_BLUE_CASH_TABLE";
    string DROP_GREEN_CASH_TABLE    = "DROP_GREEN_CASH_TABLE";
    string DROP_PURPLE_CASH_TABLE   = "DROP_PURPLE_CASH_TABLE";
    string DROP_RED_CASH_TABLE      = "DROP_RED_CASH_TABLE";
    string DROP_ARTIFACT_CASH_TABLE = "DROP_ARTIFACT_CASH_TABLE";

    // clear arrays before use
    Array_Clear(DROP_GARBAGE_CASH_TABLE, oPC);
    Array_Clear(DROP_BLUE_CASH_TABLE, oPC);
    Array_Clear(DROP_GREEN_CASH_TABLE, oPC);
    Array_Clear(DROP_PURPLE_CASH_TABLE, oPC);
    Array_Clear(DROP_RED_CASH_TABLE, oPC);
    Array_Clear(DROP_ARTIFACT_CASH_TABLE, oPC);

    // cash all eqiupped PC items
    int iInventorySlot;
    for (iInventorySlot = 0; iInventorySlot <= 13; iInventorySlot++)
    {
        object oItemInSlot = GetItemInSlot(iInventorySlot, oPC);
        if (!GetIsObjectValid(oItemInSlot))
            continue;
        if (iInventorySlot != INVENTORY_SLOT_ARROWS  && iInventorySlot != INVENTORY_SLOT_BOLTS &&
            iInventorySlot != INVENTORY_SLOT_BULLETS && iInventorySlot != INVENTORY_SLOT_RIGHTHAND &&
            GetBaseItemType(oItemInSlot) != BASE_ITEM_TORCH)
        {
            //
            if     (GetLocalString(oItemInSlot, "LOOT_CATEGORY") == "BLUE")
                Array_PushBack_Str(DROP_BLUE_CASH_TABLE, GetObjectUUID(oItemInSlot), oPC);
            else if(GetLocalString(oItemInSlot, "LOOT_CATEGORY") == "GREEN")
                Array_PushBack_Str(DROP_GREEN_CASH_TABLE, GetObjectUUID(oItemInSlot), oPC);
            else if(GetLocalString(oItemInSlot, "LOOT_CATEGORY") == "PURPLE")
                Array_PushBack_Str(DROP_PURPLE_CASH_TABLE, GetObjectUUID(oItemInSlot), oPC);
            else if(GetLocalString(oItemInSlot, "LOOT_CATEGORY") == "RED")
                Array_PushBack_Str(DROP_RED_CASH_TABLE, GetObjectUUID(oItemInSlot), oPC);
            else if(GetLocalString(oItemInSlot, "LOOT_CATEGORY") == "ARTIFACT")
                Array_PushBack_Str(DROP_ARTIFACT_CASH_TABLE, GetObjectUUID(oItemInSlot), oPC);
            else
                Array_PushBack_Str(DROP_GARBAGE_CASH_TABLE, GetObjectUUID(oItemInSlot), oPC);
        }
    }

    location lPcLoc = GetLocation(oPC);
    if(!GetIsObjectValid(GetAreaFromLocation(lPcLoc)))
    {
        lPcLoc = GetLocalLocation(oPC, "sm_location");
        if(!GetIsObjectValid(GetAreaFromLocation(lPcLoc)))
        {
            lPcLoc = GetLocalLocation(oPC, "LAST_PLAYER_LOCATION");
        }
    }

    object oArea = GetAreaFromLocation(lPcLoc);
    if(!GetIsObjectValid(oArea))
        return;

    float fOrientation = GetFacingFromLocation(lPcLoc);
    vector vNewPos = GetPositionFromLocation(lPcLoc) + Vector(0.0, 0.0, 2.0);
    location lLootLoc = Location(oArea, vNewPos, fOrientation);
    object oLootBag = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_pvp_loot", lLootLoc);
    if(!GetIsObjectValid(oLootBag))
        return;

    int iItemsCount;
    for (iItemsCount = 0; iItemsCount < nItemsAmount; iItemsCount++)
    {
        object oDroppedItem;
        int nRandomDice100 = d100();
        int nTriggeredPercent = Array_Size(DROP_RED_CASH_TABLE, oPC) +
                                Array_Size(DROP_PURPLE_CASH_TABLE, oPC) > 0 ? nBaseEpicDropChance : nBaseMiniDropChance;
        /* artifacts drop disabled
        if (Array_Size(DROP_ARTIFACT_CASH_TABLE, oPC) > 0)
        {
            Array_Shuffle(DROP_ARTIFACT_CASH_TABLE, oPC);
            oDroppedItem = GetObjectByUUID(Array_At_Str(DROP_ARTIFACT_CASH_TABLE, 0, oPC));
            Array_Erase(DROP_ARTIFACT_CASH_TABLE, 0, oPC);
        } */
        // red loot
        if (Array_Size(DROP_RED_CASH_TABLE, oPC) > 0 && nRandomDice100 <= nBaseEpicDropChance)
        {
            Array_Shuffle(DROP_RED_CASH_TABLE, oPC);
            oDroppedItem = GetObjectByUUID(Array_At_Str(DROP_RED_CASH_TABLE, 0, oPC));
            Array_Erase(DROP_RED_CASH_TABLE, 0, oPC);
        }
        // purple loot
        else if (Array_Size(DROP_PURPLE_CASH_TABLE, oPC) > 0 && nRandomDice100 <= nBaseEpicDropChance)
        {
            Array_Shuffle(DROP_PURPLE_CASH_TABLE, oPC);
            oDroppedItem = GetObjectByUUID(Array_At_Str(DROP_PURPLE_CASH_TABLE, 0, oPC));
            Array_Erase(DROP_PURPLE_CASH_TABLE, 0, oPC);
        }
        // green loot
        else if (Array_Size(DROP_GREEN_CASH_TABLE, oPC) > 0 && nRandomDice100 <= nBaseMiniDropChance)
        {
            Array_Shuffle(DROP_GREEN_CASH_TABLE, oPC);
            oDroppedItem = GetObjectByUUID(Array_At_Str(DROP_GREEN_CASH_TABLE, 0, oPC));
            Array_Erase(DROP_GREEN_CASH_TABLE, 0, oPC);
        }
        // blue loot
        else if (Array_Size(DROP_BLUE_CASH_TABLE, oPC) > 0 && nRandomDice100 <= nBaseMiniDropChance)
        {
            Array_Shuffle(DROP_BLUE_CASH_TABLE, oPC);
            oDroppedItem = GetObjectByUUID(Array_At_Str(DROP_BLUE_CASH_TABLE, 0, oPC));
            Array_Erase(DROP_BLUE_CASH_TABLE, 0, oPC);
        }
        // craft and other garbage
        else if (Array_Size(DROP_GARBAGE_CASH_TABLE, oPC) > 0 && nRandomDice100 <= nBaseMiniDropChance)
        {
            Array_Shuffle(DROP_GARBAGE_CASH_TABLE, oPC);
            oDroppedItem = GetObjectByUUID(Array_At_Str(DROP_GARBAGE_CASH_TABLE, 0, oPC));
            Array_Erase(DROP_GARBAGE_CASH_TABLE, 0, oPC);
        }
        if (GetIsObjectValid(oDroppedItem) && !bDropInventoryOnly)
        {
            SendColorMessageToPC(oKiller, "Equipped item's drop chance: " + IntToString(nTriggeredPercent)+"%", TXT_COLOR_GREEN_L);
            SendColorMessageToPC(oKiller, "Your victim's dice: " + IntToString(nRandomDice100) +
                                          ". You won jackpot!", TXT_COLOR_GREEN_L);

            SendColorMessageToPC(oPC,     "Equipped item's drop chance: " + IntToString(nTriggeredPercent) + "%", TXT_COLOR_RED);
            SendColorMessageToPC(oPC,     "Your dice: " + IntToString(nRandomDice100) +
                                          ". You're bankrupt now!", TXT_COLOR_RED);
            AssignCommand(GetModule(), DelayCommand(0.0, generic_MoveItem(oDroppedItem, oLootBag)));
            SendColorMessageToPC(oPC,     ColorText("Equipped: ", TXT_COLOR_YELLOW_T) +
                                          GetName(oDroppedItem), TXT_COLOR_WHITE);
            SendColorMessageToPC(oKiller, ColorText("Equipped: ", TXT_COLOR_YELLOW_T) +
                                          GetName(oDroppedItem), TXT_COLOR_WHITE);
        }   /*
        else if (nRandomDice100 <= nTriggeredPercent)
        {
            SendColorMessageToPC(oKiller, "Item's drop chance: " + IntToString(nTriggeredPercent) + "%", TXT_COLOR_GREEN_L);
            SendColorMessageToPC(oKiller, "Your victim's dice: " + IntToString(nRandomDice100) +
                                          ". Victim is a fucking exhibitionist! Time to shake his inventory!", TXT_COLOR_GREEN_L);

            SendColorMessageToPC(oPC,     "Item's drop chance: " + IntToString(nTriggeredPercent) + "%", TXT_COLOR_RED);
            SendColorMessageToPC(oPC,     "Your dice: " + IntToString(nRandomDice100) +
                                          ". You naked freak, get ready for inventory drop!", TXT_COLOR_RED);
            nInventoryDrop = TRUE;
        }       */
        else if(!bDropInventoryOnly)
        {
            SendColorMessageToPC(oKiller, "Item's drop chance: " + IntToString(nTriggeredPercent) + "%", TXT_COLOR_RED);
            SendColorMessageToPC(oKiller, "Your victim's dice: " + IntToString(nRandomDice100) +
                                          ". Luck is not on your side!", TXT_COLOR_RED);

            SendColorMessageToPC(oPC,     "Item's drop chance: " + IntToString(nTriggeredPercent) + "%", TXT_COLOR_GREEN_L);
            SendColorMessageToPC(oPC,     "Your dice: " + IntToString(nRandomDice100) +
                                          ". You don't lost your equipment!", TXT_COLOR_GREEN_L);
        }
    }
    if (bInventoryDrop || bDropInventoryOnly)
    {
        // drop inventory items
        object oInventoryDrop = GetFirstItemInInventory(oPC);
        while(GetIsObjectValid(oInventoryDrop))
        {
            string sLootCategory = GetLocalString(oInventoryDrop, "LOOT_CATEGORY");
            if ((sLootCategory == "BLUE"      || sLootCategory == "GREEN" ||
                 sLootCategory == "PURPLE"    || sLootCategory == "RED"   ||
                 sLootCategory == "ARTIFACT"  || GetLocalInt(oArea, "POTIONS_DROP") &&
                 GetBaseItemType(oInventoryDrop) == BASE_ITEM_POTIONS &&
                 FindSubString(GetTag(oInventoryDrop), "Tele_PC_") == -1) &&
                 GetTag(oInventoryDrop) != CONST_LIGHTNING_STONE &&
                 GetTag(oInventoryDrop) != "fl_inst_key" /* no drop instance key */)
            {
                if (d100() <= 100 - iSavePercent)
                {
                    // handle stackable items
                    int nStack = GetNumStackedItems(oInventoryDrop);
                    if(nStack > 1)
                    {
                        int nRandomStackPart = Random(nStack) + 1;
                        if(nRandomStackPart < nStack)
                            DelayCommand(0.1, ReturnPartOfItemStackToPC(oInventoryDrop, oPC, nStack - nRandomStackPart, nRandomStackPart));
                    }
                    // move item to lootbag
                    AssignCommand(GetModule(), DelayCommand(0.0, generic_MoveItem(oInventoryDrop, oLootBag)));
                    SendColorMessageToPC(oPC,     ColorText("Inventory: ", TXT_COLOR_YELLOW_T) +
                                                  GetName(oInventoryDrop), TXT_COLOR_WHITE);
                    SendColorMessageToPC(oKiller, ColorText("Inventory: ", TXT_COLOR_YELLOW_T) +
                                                  GetName(oInventoryDrop), TXT_COLOR_WHITE);
                }
            }
            oInventoryDrop = GetNextItemInInventory(oPC);
        }
        // take 50% gold
        int iGold = GetGold(oPC);
        iGold = iGold * (100 - iSavePercent) / 100;
        AssignCommand(oLootBag, TakeGoldFromCreature(iGold, oPC, FALSE));
    }
}

void ReturnPartOfItemStackToPC(object oSourceItem, object oPC, int nStackSizeSource, int nStackSizeCopy)
{
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, TRUE, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_RECEIVED, TRUE, oPC);
    object oCopy = CopyItem(oSourceItem, oPC, TRUE);
    SetItemStackSize(oSourceItem, nStackSizeSource);
    SetItemStackSize(oCopy, nStackSizeCopy);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, FALSE, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_RECEIVED, FALSE, oPC);
}

string death_ShowTop3DPS(object oTarget)
{
    json jStoredDamage = GetLocalJson(oTarget, "JSON_STORED_DPS_VALUE");
    if (JsonGetType(jStoredDamage) == JSON_TYPE_NULL)
        return "";

    int nCount = JsonGetLength(jStoredDamage);
    int nTop = (nCount < 3) ? nCount : 3;
    string sResult = "\nTop-3 DMG: ";
    json jKeys = JsonObjectKeys(jStoredDamage);

    int k;
    for(k = 0; k < nTop; k++)
    {
        int nBestVal = -1;
        string sBestKey = "";
        int i;
        for (i = 0; i < nCount; i++)
        {
            string sKey = JsonGetString(JsonArrayGet(jKeys, i));
            int nVal = JsonGetInt(JsonObjectGet(jStoredDamage, sKey));
            if (nVal > nBestVal)
            {
                nBestVal = nVal;
                sBestKey = sKey;
            }
        }
        if (sBestKey != "")
        {
            json jStoredFaction = GetLocalJson(oTarget, "JSON_STORED_DPS_FACTION");
            int nFaction = JsonGetInt(JsonObjectGet(jStoredFaction, sBestKey));
            string sColor = players_GetFactionColor(nFaction);
            if(sColor == "")
                sColor = TXT_COLOR_ORANGE;
            if(k == nTop - 1)
                sResult += sColor + sBestKey + TXT_COLOR_END + " - " + IntToString(nBestVal) + ".";
            else
                sResult += sColor + sBestKey + TXT_COLOR_END + " - " + IntToString(nBestVal) + ", ";
            JsonObjectSetInplace(jStoredDamage, sBestKey, JsonInt(-1));
        }
    }
    //DeleteLocalJson(oTarget, "JSON_STORED_DPS_VALUE");
    //DeleteLocalJson(oTarget, "JSON_STORED_DPS_FACTION");
    return sResult;
}

void death_PlayAnnouncer(object oPC, object oKiller)
{
    json jStoredAnnouncer = GetLocalJson(oKiller, "JSON_STORED_ANNOUNCER");
    if (JsonGetType(jStoredAnnouncer) == JSON_TYPE_NULL)
        jStoredAnnouncer = JSON_ARRAY;
    // add new timestamp
    int nNow = SQLite_GetTimeStamp();
    JsonArrayInsertInplace(jStoredAnnouncer, JsonInt(nNow));

    int nLength = JsonGetLength(jStoredAnnouncer);

    int nChainCount = 1;
    int MAX_DIFF = 30;

    json jNewStoredAnnouncer = JSON_ARRAY;
    // add last element
    JsonArrayInsertInplace(jNewStoredAnnouncer, JsonInt(nNow));
    // iter backward
    int i;
    for (i = nLength - 1; i > 0; i--)
    {
        int nCur  = JsonGetInt(JsonArrayGet(jStoredAnnouncer, i));
        int nPrev = JsonGetInt(JsonArrayGet(jStoredAnnouncer, i - 1));

        if (nCur - nPrev <= MAX_DIFF)
        {
            nChainCount++;
            JsonArrayInsertInplace(jNewStoredAnnouncer, JsonInt(nPrev));
        }
        else
            break;
    }
    // sort chain
    jNewStoredAnnouncer = JsonArrayTransform(jNewStoredAnnouncer, JSON_ARRAY_SORT_ASCENDING);
    // save
    SetLocalJson(oKiller, "JSON_STORED_ANNOUNCER", jNewStoredAnnouncer);
    // play sound
    if (nChainCount >= 6)
        generic_PlayAudioStreamForAllPlayers("mus_godlike");
    else if (nChainCount == 5)
        generic_PlayAudioStreamForAllPlayers("mus_rampage");
    else if (nChainCount == 4)
        generic_PlayAudioStreamForAllPlayers("mus_ultrakill");
    else if (nChainCount == 3)
        generic_PlayAudioStreamForAllPlayers("mus_hattrick");
    else if (nChainCount == 2)
        generic_PlayAudioStreamForAllPlayers("mus_doublekill");
}




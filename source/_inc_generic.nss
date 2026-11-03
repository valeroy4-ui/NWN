#include "_inc_players"
#include "_inc_log"
#include "_inc_feat2skin"
#include "_inc_db_funcs"
#include "nw_i0_spells"
#include "nwnx_util"
#include "_inc_sqlite_time"
#include "nwnx_creature"
#include "_inc_array"
#include "_inc_sqlocals"
#include "_inc_areas"
#include "nwnx_item"
#include "nwnx_encounter"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// returns damage constant for nNumber value, where 1 <= nNumber <=40
int GetDamageBonusConstantFromNumber(int nNumber);

// send message to oPC's party
void SendMessageToParty(object oPC, string sMessage);

// send FloatingTextString to oPC's party
void FloatingTextStringOnParty(string sMessage, object oPC);

// send Server's message to shout channel
void ServerShout(string sMessage);

// decrease creature XP for iXP value
void generic_TakeXPFromCreature(object oCreature, int iXP);

// return TRUE if oPC has item with sItemResRef in inventory
int generic_GetHasResrefInInventory(object oPC, string sItemResRef);

// return first oItem with sItemResRef in oPC inventory
object generic_FindResrefInInventory(object oPC, string sItemResRef);

// returns feat name using iFeat ID
string GetFeatNameFrom2DA(int iFeat);

// returns account's amount of soulstones
int generic_GetSoulStones(string sAccount);

// set soulstones amount for specific account
void generic_SetSoulStones(string sAccount, int nValue);

// change soulstones amount for specific account
// returns FALSE if result value < 0
int generic_ChangeSoulStonesAmount(object oPC, int nAmount);

// remove nCost soulstones from oPC and give him key with sKeyTag
void generic_BuyKeyForSoulStones(object oPC, int nCost, string sKeyTag);

// give gold to creature without feedback message
void GiveGoldToCreatureSilently(object oCreature, int nGP);

// destroy item posessed by oPC without log message
void DestroyItemSilently(object oPC, object oItem);

// returns SQL table for sLootCategory
string GetLootTableByLootCategory(string sLootCategory);

// returns Color of boss loot category
string GetLootColorByLootCategory(string sLootCategory);

// set player ID who last acquired boss item in loot table
void UpdateAcquiredInfo(object oPC, object oItem);

// set player ID who last eqipped boss item in loot table
void UpdateEqippedInfo(object oPC, object oItem);

// count party members that are in the same area
int GetPartySizeInSameArea(object oPC);

// update hostile actor's table for oPC
void UpdateHostileActorsList(object oPC, object oAgressor);

// update support actor's table for oPC
void UpdateSupportActorsList(object oPC, object oSupport);

// move oItem to oTarget's inventory and update acquired info
// NOTE: must be used with delay in loops
void generic_MoveItem(object oItem, object oTarget, int bHideAllFeedback = TRUE, int nUpdateDatabaseInfo = TRUE);

// fixes blinks after items uses and spelllike abilities
void generic_BrokenAnimationBlinkFix(object oPC, object oItem, int nFeat = -1);

// return TRUE if oItem is fame item and player is not in TestRoom
int generic_CheckFameItems(object oPC, object oItem);

// delete specific equipped item, using INVENTORY_SLOT_* constants
void generic_DeleteEquippedItemInSlot(int iSlotID, object oCreature);

// destroy all equipped and inventory items for oCreature
void generic_DeleteAllItemsOnObject(object oCreature);

// safely destroy creature
int generic_DestroyCreature(object oCreature, int bForce = FALSE);

// return ability name using 2da
string generic_GetAbilityNameFrom2DA(int nAbility);

// set encounter events and inactive state
void generic_InitEncounters();

// returns respawn time in seconds for specific sCreatureResRef
int generic_GetRespawnTime(object oEncounterHolder, string sCreatureResRef);

// play audio to target and players in target's area
void generic_PlayAudioStreamForPlayerArea(object oTarget, string sStreamName, int nStreamID = AUDIOSTREAM_IDENTIFIER_0);

// play audio to all PCs
void generic_PlayAudioStreamForAllPlayers(string sStreamName, int nStreamID = AUDIOSTREAM_IDENTIFIER_9);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int GetDamageBonusConstantFromNumber(int nNumber)
{
    switch (nNumber)
    {
        case 1: return DAMAGE_BONUS_1;
        case 2: return DAMAGE_BONUS_2;
        case 3: return DAMAGE_BONUS_3;
        case 4: return DAMAGE_BONUS_4;
        case 5: return DAMAGE_BONUS_5;
        case 6: return DAMAGE_BONUS_6;
        case 7: return DAMAGE_BONUS_7;
        case 8: return DAMAGE_BONUS_8;
        case 9: return DAMAGE_BONUS_9;
        case 10: return DAMAGE_BONUS_10;
        case 11: return DAMAGE_BONUS_11;
        case 12: return DAMAGE_BONUS_12;
        case 13: return DAMAGE_BONUS_13;
        case 14: return DAMAGE_BONUS_14;
        case 15: return DAMAGE_BONUS_15;
        case 16: return DAMAGE_BONUS_16;
        case 17: return DAMAGE_BONUS_17;
        case 18: return DAMAGE_BONUS_18;
        case 19: return DAMAGE_BONUS_19;
        case 20: return DAMAGE_BONUS_20;
        // cormyr extension
        case 21: return IP_CONST_DAMAGEBONUS_21;
        case 22: return IP_CONST_DAMAGEBONUS_22;
        case 23: return IP_CONST_DAMAGEBONUS_23;
        case 24: return IP_CONST_DAMAGEBONUS_24;
        case 25: return IP_CONST_DAMAGEBONUS_25;
        case 26: return IP_CONST_DAMAGEBONUS_26;
        case 27: return IP_CONST_DAMAGEBONUS_27;
        case 28: return IP_CONST_DAMAGEBONUS_28;
        case 29: return IP_CONST_DAMAGEBONUS_29;
        case 30: return IP_CONST_DAMAGEBONUS_30;
        case 31: return IP_CONST_DAMAGEBONUS_31;
        case 32: return IP_CONST_DAMAGEBONUS_32;
        case 33: return IP_CONST_DAMAGEBONUS_33;
        case 34: return IP_CONST_DAMAGEBONUS_34;
        case 35: return IP_CONST_DAMAGEBONUS_35;
        case 36: return IP_CONST_DAMAGEBONUS_36;
        case 37: return IP_CONST_DAMAGEBONUS_37;
        case 38: return IP_CONST_DAMAGEBONUS_38;
        case 39: return IP_CONST_DAMAGEBONUS_39;
        case 40: return IP_CONST_DAMAGEBONUS_40;
    }
    if (nNumber > 40)
        return IP_CONST_DAMAGEBONUS_40;
    else
        return 0;
}

void SendMessageToParty(object oPC, string sMessage)
{
    object oPartyPC = GetFirstPC();
    while(GetIsObjectValid(oPartyPC))
    {
        if(GetFactionEqual(oPartyPC, oPC))
        {
            SendMessageToPC(oPartyPC, sMessage);
        }
        oPartyPC = GetNextPC();
    }
}

void FloatingTextStringOnParty(string sMessage, object oPC)
{
    object oPartyPC = GetFirstPC();
    while(GetIsObjectValid(oPartyPC))
    {
        if(GetFactionEqual(oPartyPC, oPC))
        {
            FloatingTextStringOnCreature(sMessage, oPC);
        }
        oPartyPC = GetNextPC();
    }
}

void ServerShout(string sMessage)
{
    AssignCommand(GetModule(), SpeakString(sMessage, TALKVOLUME_SHOUT));
}

void RemoveVisualEffects(object oObject)
{
    effect eEff = GetFirstEffect(oObject);
    while(GetIsEffectValid(eEff))
    {
        if(GetEffectType(eEff) == EFFECT_TYPE_VISUALEFFECT)
            RemoveEffect(oObject, eEff);
        eEff = GetNextEffect(oObject);
    }
}

void generic_TakeXPFromCreature(object oCreature, int iXP)
{
    SetXP(oCreature, GetXP(oCreature) - iXP);
    players_UpdateXpBar(oCreature);
}

int generic_GetHasResrefInInventory(object oPC, string sItemResRef)
{
    if (GetIsObjectValid(generic_FindResrefInInventory(oPC, sItemResRef)))
        return TRUE;
    else
        return FALSE;
}

object generic_FindResrefInInventory(object oPC, string sItemResRef)
{
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (GetResRef(oItem) == sItemResRef) return oItem;
        oItem = GetNextItemInInventory(oPC);
    }
    return OBJECT_INVALID;
}

string GetFeatNameFrom2DA(int iFeat)
{
    return GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", iFeat)));
}

int generic_GetSoulStones(string sAccount)
{
    string sSQL = "SELECT soulstones FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    else
    {
        return 0;
    }
}

void generic_SetSoulStones(string sAccount, int nValue)
{
    string sSQL = "UPDATE players SET soulstones = ? WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, nValue);
    NWNX_SQL_PreparedString(1, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
}

int generic_ChangeSoulStonesAmount(object oPC, int nAmount)
{
    string sAccount = GetPCPlayerName(oPC);
    int nCurrentAmount = generic_GetSoulStones(sAccount);
    int nCalculatedAmount = nCurrentAmount + nAmount;

    if (nCalculatedAmount >= 0)
    {
        generic_SetSoulStones(sAccount, nCalculatedAmount);
        string sSuffixPart = " soulstone(s). Total: " + ColorText(IntToString(nCalculatedAmount), TXT_COLOR_GREEN_L) + ".";
        if (nAmount > 0)
            SendMessageToPC(oPC, "You got " + ColorText(IntToString(nAmount), TXT_COLOR_GREEN_L) + sSuffixPart);
        else if (nAmount < 0)
            SendMessageToPC(oPC, "You lost " + ColorText(IntToString(abs(nAmount)), TXT_COLOR_RED) + sSuffixPart);

        return TRUE;
    }
    else
    {
        SendColorMessageToPC(oPC, "Not enough Soul Stones.", TXT_COLOR_RED);
        return FALSE;
    }
}

void generic_BuyKeyForSoulStones(object oPC, int nCost, string sKeyTag)
{
    if(generic_ChangeSoulStonesAmount(oPC, -nCost))
    {
        object oKey = CreateItemOnObject(CONST_ITEM_SOUL_KEY, oPC, 1, sKeyTag);
        string sCharName = NWNX_Util_StripColors(GetName(oPC));

        string sSQL = "INSERT INTO loot_keys(name, looter_id, looter_char_name) VALUES (?, ?, ?)";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedString(0, GetName(oKey, TRUE));
        NWNX_SQL_PreparedInt(1, players_GetPCPersistentID(oPC));
        NWNX_SQL_PreparedString(2, sCharName);
        if(NWNX_SQL_ExecutePreparedQuery())
        {
            int iKeyID = db_GetDatabaseLastInsertID();
            if(iKeyID > 0)
            {
                string  sOrigName           = GetName(oKey, TRUE);
                int     iFactionPC          = players_GetFaction(oPC);
                string  sFactionColor       = players_GetFactionColor(iFactionPC);
                SetName(oKey, sOrigName + " of " + sFactionColor + sCharName + TXT_COLOR_END + " #" + IntToString(iKeyID));
                // write logs
                WriteLog(GetName(oPC) + "(" + GetPCPlayerName(oPC) + ")" + " exchanged Soul Stones to Soul Key #" + IntToString(iKeyID));
                SendColorMessageToPC(oPC, IntToString(nCost) + " Soul Stones successfully exchanged to Soul Key.", TXT_COLOR_GREEN_L);
            }
        }
    }
}

void GiveGoldToCreatureSilently(object oCreature, int nGP)
{
    int bCurrent = NWNX_Feedback_GetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_GAINED, oCreature);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_GAINED, TRUE, oCreature);
    GiveGoldToCreature(oCreature, nGP);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_GAINED, bCurrent, oCreature);
}

void DestroyItemSilently(object oPC, object oItem)
{
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, TRUE, oPC);
    DestroyObject(oItem);
    DelayCommand(0.25, NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, FALSE, oPC));
}

string GetLootTableByLootCategory(string sLootCategory)
{
    string sTableName = "";
    if(sLootCategory == "BLUE")
        sTableName = "loot_info_blue";
    else if(sLootCategory == "GREEN")
        sTableName = "loot_info_green";
    else if(sLootCategory == "PURPLE")
        sTableName = "loot_info_purple";
    else if(sLootCategory == "RED")
        sTableName = "loot_info_red";
    else if(sLootCategory == "ARTIFACT")
        sTableName = "loot_info_artifact";
    return sTableName;
}

string GetLootColorByLootCategory(string sLootCategory)
{
    string sColor = "";
    sLootCategory = GetStringUpperCase(sLootCategory);
    if(sLootCategory == "BLUE")
        sColor = LOOT_COLOR_BLUE;
    else if(sLootCategory == "GREEN")
        sColor = LOOT_COLOR_GREEN;
    else if(sLootCategory == "PURPLE")
        sColor = LOOT_COLOR_PURPLE;
    else if(sLootCategory == "RED")
        sColor = LOOT_COLOR_RED;
    else if(sLootCategory == "ARTIFACT")
        sColor = LOOT_COLOR_ARTIFACT;
    return sColor;
}

void UpdateAcquiredInfo(object oPC, object oItem)
{
    string sLootCategory = GetLocalString(oItem, "LOOT_CATEGORY");
    if (sLootCategory == "") return;
    int iLootID = GetLocalInt(oItem, "ID");

    //SendMessageToPC(oPC, "[DEBUG]" + " pcID: " + IntToString(GetPCPersistentID(oPC)) + " itemID:" + IntToString(iLootID));

    string sTableName = GetLootTableByLootCategory(sLootCategory);
    if(GetStringLength(sTableName) > 0 && iLootID > 0)
    {
        string sSQL = "UPDATE " + sTableName + " SET last_acquired_by = ? WHERE id = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, players_GetPCPersistentID(oPC));
        NWNX_SQL_PreparedInt(1, iLootID);
        NWNX_SQL_ExecutePreparedQuery();
    }
}

void UpdateEqippedInfo(object oPC, object oItem)
{
    string sLootCategory = GetLocalString(oItem, "LOOT_CATEGORY");
    if (sLootCategory == "") return;

    int iLootID = GetLocalInt(oItem, "ID");
    string sTableName = GetLootTableByLootCategory(sLootCategory);
    if(GetStringLength(sTableName) > 0 && iLootID > 0)
    {
        string sSQL = "UPDATE " + sTableName + " SET last_equipped_by = ? WHERE id = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, players_GetPCPersistentID(oPC));
        NWNX_SQL_PreparedInt(1, iLootID);
        NWNX_SQL_ExecutePreparedQuery();
    }
}

int GetPartySizeInSameArea(object oPC)
{
    object oArea = GetArea(oPC);
    object oPartyMember = GetFirstFactionMember(oPC, TRUE);
    int iPlayers = 0;
    while(GetIsObjectValid(oPartyMember))
    {
        if (oArea == GetArea(oPartyMember))
        {
            iPlayers++;
        }
        oPartyMember = GetNextFactionMember(oPC, TRUE);
    }
    return iPlayers;
}

void UpdateHostileActorsList(object oVictim, object oAgressor)
{
    string sAgressorUUID = GetObjectUUID(oAgressor);
    /* debug
    if (SQLite_GetTimeStamp() - SQLocals_GetLastUpdated_UnixEpoch(oVictim, sAgressorUUID, SQLOCALS_TYPE_INT) > 0)
    {
        ServerShout(ColorText(GetName(oAgressor), GetFactionColor(GetFaction(oAgressor))) + " done " + ColorText("HOSTILE", TXT_COLOR_RED) + " action VS " +
                    ColorText(GetName(oVictim), GetFactionColor(GetFaction(oVictim))));
    }
    end debug */
    SQLocals_SetInt(oVictim, sAgressorUUID, TRUE);
    if (!Array_Contains_Str("HOSTILE_ACTORS_LIST", sAgressorUUID, oVictim))
         Array_PushBack_Str("HOSTILE_ACTORS_LIST", sAgressorUUID, oVictim);
}

void UpdateSupportActorsList(object oKiller, object oSupport)
{
    string sSupportUUID = GetObjectUUID(oSupport);
    /* debug
    if (SQLite_GetTimeStamp() - SQLocals_GetLastUpdated_UnixEpoch(oKiller, sSupportUUID, SQLOCALS_TYPE_INT) > 0)
    {
        ServerShout(ColorText(GetName(oSupport), GetFactionColor(GetFaction(oSupport))) + " done " + ColorText("SUPPORT", TXT_COLOR_BLUE_L) + " action VS " +
                    ColorText(GetName(oKiller), GetFactionColor(GetFaction(oKiller))));
    }
    end debug */
    SQLocals_SetInt(oKiller, sSupportUUID, TRUE);
    if(!Array_Contains_Str("SUPPORT_ACTORS_LIST", sSupportUUID, oKiller))
        Array_PushBack_Str("SUPPORT_ACTORS_LIST", sSupportUUID, oKiller);
}

void generic_MoveItem(object oItem, object oTarget, int bHideAllFeedback = TRUE, int nUpdateDatabaseInfo = TRUE)
{
    NWNX_Item_MoveTo(oItem, oTarget, bHideAllFeedback);
    if(nUpdateDatabaseInfo)
        UpdateAcquiredInfo(OBJECT_INVALID, oItem);
}

void generic_BrokenAnimationBlinkFix(object oPC, object oItem, int nFeat = -1)
{
    float fSlowDuration = 1.35f;

    int bSlow = FALSE;
    if(GetIsObjectValid(oItem))
    {
        int iBaseItem = GetBaseItemType(oItem);

        if(iBaseItem == BASE_ITEM_HEALERSKIT)
            return;

        if(iBaseItem == BASE_ITEM_SPELLSCROLL)
            fSlowDuration = 3.5f;
        bSlow = TRUE;
    }
    else if(nFeat != 65535 && nFeat != -1 && StringToInt(Get2DAString("feat", "SPELLID", nFeat)))
        bSlow = TRUE;

    if(bSlow)
    {
        NWNX_Creature_SetMovementRate(oPC, CORMYREAN_SPEED_ITEM_USE_SLOW);
        DelayCommand(fSlowDuration, NWNX_Creature_SetMovementRate(oPC, NWNX_CREATURE_MOVEMENT_RATE_PC));
    }
}

int generic_CheckFameItems(object oPC, object oItem)
{
    if (GetResRef(GetArea(oPC)) == "_loc_testarea" ||
        GetResRef(oItem) == CONST_LIGHTNING_STONE  ||
        GetLocalString(oItem, "LOOT_CATEGORY") != "ARTIFACT")  // exceptions
        return TRUE;

    if(GetIsObjectValid(GetItemPossessedBy(oPC, GetResRef(oItem) + "L")))
        return TRUE;
    else
        return FALSE;
}

void generic_DeleteEquippedItemInSlot(int iSlotID, object oCreature)
{
     object oItem = GetItemInSlot(iSlotID, oCreature);
     if(GetIsObjectValid(oItem) && !GetDroppableFlag(oItem))
        DestroyObject(oItem);
}

void generic_DeleteAllItemsOnObject(object oCreature)
{
    int iSlotID;
    for(iSlotID = 0; iSlotID <= NUM_INVENTORY_SLOTS; iSlotID++)
        generic_DeleteEquippedItemInSlot(iSlotID, oCreature);
    object oItem = GetFirstItemInInventory(oCreature);
    while (GetIsObjectValid(oItem))
    {
        if(!GetDroppableFlag(oItem))
            DestroyObject(oItem);
        oItem = GetNextItemInInventory(oCreature);
    }
    TakeGoldFromCreature(GetGold(), oCreature, TRUE);
}

int generic_DestroyCreature(object oCreature, int bForce = FALSE)
{
    object oArea = GetArea(oCreature);
    if (GetIsObjectValid(oArea) && (!areas_GetNumberOfPlayersInArea(oArea, FALSE) || bForce))
    {
       generic_DeleteAllItemsOnObject(oCreature);
       AssignCommand(oCreature, SetIsDestroyable(TRUE, FALSE, FALSE));
       SetPlotFlag(oCreature, FALSE);
       SetImmortal(oCreature, FALSE);
       SetLootable(oCreature, FALSE);
       DestroyObject(oCreature, 0.25);
       return TRUE;
    }
    return FALSE;
}

string generic_GetAbilityNameFrom2DA(int nAbility)
{
    return GetStringByStrRef(StringToInt(Get2DAString("iprp_abilities", "Name", nAbility)));
}

void generic_InitEncounters()
{
    object oArea = GetFirstArea();
    while(GetIsObjectValid(oArea))
    {
        object oEncounter = GetFirstObjectInArea(oArea, OBJECT_TYPE_ENCOUNTER);
        while(GetIsObjectValid(oEncounter))
        {
            SetEncounterActive(FALSE, oEncounter);
            NWNX_Encounter_SetCanReset(oEncounter, FALSE);
            NWNX_Encounter_SetPlayerTriggeredOnly(oEncounter, TRUE);
            SetEventScript(oEncounter, EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER, "_on_encounter");
            oEncounter = GetNextObjectInArea(oArea, OBJECT_TYPE_ENCOUNTER);
        }
        oArea = GetNextArea();
    }
}

int generic_GetRespawnTime(object oEncounterHolder, string sCreatureResRef)
{
    if(sCreatureResRef == "")
        return -1;
    int nResult = GetLocalInt(oEncounterHolder, sCreatureResRef);
    if(nResult)
        return nResult;

    string sSQL = "select mob_respawn_time from encounters where mob_resref = '" + sCreatureResRef + "'";
    if(NWNX_SQL_ExecuteQuery(sSQL) && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nResult = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    else
        nResult = -1;

    SetLocalInt(oEncounterHolder, sCreatureResRef, nResult);

    return nResult;
}

void generic_PlayAudioStreamForPlayerArea(object oTarget, string sStreamName, int nStreamID = AUDIOSTREAM_IDENTIFIER_0)
{
    object oArea = GetArea(oTarget);
    object oAlarm = GetFirstObjectInArea(oArea, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(oAlarm))
    {
        if(GetIsPC(oAlarm))
        {

            float fDistance = GetDistanceBetween(oTarget, oAlarm);
            float fVolume = 1.0 / (1.0 + 0.2 * fDistance);
            StartAudioStream(oAlarm, nStreamID, sStreamName, FALSE, 0.0, -1.0, fVolume);
        }
        oAlarm = GetNextObjectInArea(oArea, OBJECT_TYPE_CREATURE);
    }
}

void generic_PlayAudioStreamForAllPlayers(string sStreamName, int nStreamID = AUDIOSTREAM_IDENTIFIER_9)
{
    object oAlarm = GetFirstPC();
    while(GetIsObjectValid(oAlarm))
    {
        StartAudioStream(oAlarm, nStreamID, sStreamName);
        oAlarm = GetNextPC();
    }
}

//void main(){}

#include "_inc_factions"
#include "_inc_bank"
#include "nwnx_admin"
#include "nwnx_player"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

const int STATISTIC_TIMEFRAME_ONE_DAY       = 86400;
const int STATISTIC_TIMEFRAME_THREE_DAYS    = 259200;
const int STATISTIC_TIMEFRAME_ONE_WEEK      = 604800;
const int STATISTIC_TIMEFRAME_ONE_MONTH     = 2592000;
const float FAME_RESTORE_COEFFICIENT        = 1.00;

// restarts server if oChater == DM
void chat_Restart(object oChater);

// print !lstat
void chat_PrintLootStats(object oChater);

// print !boss
void chat_PrintBossStatuses(object oChater);

// print boss statuses by category for !boss command
void chat_PrintBossStatusesByCategory(object oChater, string sBossCategory);

// print !topd
void chat_PrintDynamicTop(object oChater);

// subfunction for !topd
void chat_PrintTopForPeriod(object oChater, int iTimeFrame, int iStatType = 0 /* 0 - kills + assists, 1 - kills only, 2 - assists only */);

// get character stat from DB
int chat_GetCharacterStatistics(object oPC, int iEventType /* 1 - kills, 2 - assists */);

// return nFaction online players and send messages to oSpeaker with info
int chat_CountFactionPlayersAndSendStat(object oSpeaker, int nFaction, int bDM);

// print !stat
void chat_PrintPVPStats(object oPC);

// sends message with treasure gold info
void chat_SendFactionTreasureStat(object oSpeaker);

// print !top
void chat_PrintTop10(object oSpeaker);

// get faction stat from DB
int chat_GetFactionStatistics(int iStatType /* 1 - kills, 2 - assists, 3 deaths*/, int iFaction);

// print !fstat
void chat_PrintFactionPVPStats(object oChater);

// executes !delete command
void chat_DeleteCharacter(object oChater);

// add curly brackets to oPC level value (ex. 40 -> (40) )
string chat_GetValidStringLevel(int nLvl);

// send money to other PC
void chat_SendMoney(object oPC, string sMsg);

// send fame to other faction member
void chat_SendFame(object oPC, string sMsg);

// returns only pvp+pve fame for sAccount
int chat_GetAccountFame(object oPC);

// return players favorite enemy
string chat_GetPlayerFavoriteEnemy(int iPlayerID);

// return players worst enemy
string chat_GetPlayerWorstEnemy(int iPlayerID);

// mapnotes checker
void chat_MapNotesChecker();

// get waypoint from next side trigger
object chat_MapNotesFindNextSideTransition(object oTrigger, object oTargetWaypoint);

// dump shout message in database
void chat_SaveShoutMessageIntoDB(int nPlayerID, string sPlayerName, string sMsg);

// oPC receives party invitation
void chat_InvitePlayerIntoFactionParty(object oPC);

// oPC takes party leader
void chat_ChangePartyLeader(object oPC);

// oPC enters Target Mode and have to select DPS calculator target
void chat_RunDPSCalculator(object oPC, int nRounds=20);

// clear cashed module settings
void chat_DeleteModuleParameters(object oPC);

//
string chat_GetItemTypeString(int iInventorySlot);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void chat_Restart(object oChater)
{
    if (GetIsDM(oChater))
    {
        ServerShout("The server will be rebooted after 5 seconds");
        DelayCommand(5.0, NWNX_Administration_ShutdownServer());
    }
    else SendMessageToPC(oChater, TXT_COLOR_RED + "This is DM only command");
}

void chat_PrintLootStats(object oChater)
{
    // LOOTED blue
    int iBlueEmpire = factions_CountLootFromTableByConditions("loot_info_blue", "looter_id", FACTION_EMPIRE);
    int iBlueUnderdark = factions_CountLootFromTableByConditions("loot_info_blue", "looter_id", FACTION_UNDERDARK);
    int iBlueIronThrone = factions_CountLootFromTableByConditions("loot_info_blue", "looter_id", FACTION_IRON_THRONE);
    int iBlueCult = factions_CountLootFromTableByConditions("loot_info_blue", "looter_id", FACTION_DRAGON_CULT);
    // LOOTED green
    int iGreenEmpire = factions_CountLootFromTableByConditions("loot_info_green", "looter_id", FACTION_EMPIRE);
    int iGreenUnderdark = factions_CountLootFromTableByConditions("loot_info_green", "looter_id", FACTION_UNDERDARK);
    int iGreenIronThrone = factions_CountLootFromTableByConditions("loot_info_green", "looter_id", FACTION_IRON_THRONE);
    int iGreenCult = factions_CountLootFromTableByConditions("loot_info_green", "looter_id", FACTION_DRAGON_CULT);
    // LOOTED purple
    int iPurpleEmpire = factions_CountLootFromTableByConditions("loot_info_purple", "looter_id", FACTION_EMPIRE);
    int iPurpleUnderdark = factions_CountLootFromTableByConditions("loot_info_purple", "looter_id", FACTION_UNDERDARK);
    int iPurpleIronThrone = factions_CountLootFromTableByConditions("loot_info_purple", "looter_id", FACTION_IRON_THRONE);
    int iPurpleCult = factions_CountLootFromTableByConditions("loot_info_purple", "looter_id", FACTION_DRAGON_CULT);
    // LOOTED red
    int iRedEmpire = factions_CountLootFromTableByConditions("loot_info_red", "looter_id", FACTION_EMPIRE);
    int iRedUnderdark = factions_CountLootFromTableByConditions("loot_info_red", "looter_id", FACTION_UNDERDARK);
    int iRedIronThrone = factions_CountLootFromTableByConditions("loot_info_red", "looter_id", FACTION_IRON_THRONE);
    int iRedCult = factions_CountLootFromTableByConditions("loot_info_red", "looter_id", FACTION_DRAGON_CULT);
    // LOOTED artifact
    int iArtifactEmpire = factions_CountLootFromTableByConditions("loot_info_artifact", "looter_id", FACTION_EMPIRE);
    int iArtifactUnderdark = factions_CountLootFromTableByConditions("loot_info_artifact", "looter_id", FACTION_UNDERDARK);
    int iArtifactIronThrone = factions_CountLootFromTableByConditions("loot_info_artifact", "looter_id", FACTION_IRON_THRONE);
    int iArtifactCult = factions_CountLootFromTableByConditions("loot_info_artifact", "looter_id", FACTION_DRAGON_CULT);

    // OWNS blue
    int iOwnsBlueEmpire = factions_CountLootFromTableByConditions("loot_info_blue", "last_acquired_by", FACTION_EMPIRE);
    int iOwnsBlueUnderdark = factions_CountLootFromTableByConditions("loot_info_blue", "last_acquired_by", FACTION_UNDERDARK);
    int iOwnsBlueIronThrone = factions_CountLootFromTableByConditions("loot_info_blue", "last_acquired_by", FACTION_IRON_THRONE);
    int iOwnsBlueCult = factions_CountLootFromTableByConditions("loot_info_blue", "last_acquired_by", FACTION_DRAGON_CULT);
    // OWNS green
    int iOwnsGreenEmpire = factions_CountLootFromTableByConditions("loot_info_green", "last_acquired_by", FACTION_EMPIRE);
    int iOwnsGreenUnderdark = factions_CountLootFromTableByConditions("loot_info_green", "last_acquired_by", FACTION_UNDERDARK);
    int iOwnsGreenIronThrone = factions_CountLootFromTableByConditions("loot_info_green", "last_acquired_by", FACTION_IRON_THRONE);
    int iOwnsGreenCult = factions_CountLootFromTableByConditions("loot_info_green", "last_acquired_by", FACTION_DRAGON_CULT);
    // OWNS purple
    int iOwnsPurpleEmpire = factions_CountLootFromTableByConditions("loot_info_purple", "last_acquired_by", FACTION_EMPIRE);
    int iOwnsPurpleUnderdark = factions_CountLootFromTableByConditions("loot_info_purple", "last_acquired_by", FACTION_UNDERDARK);
    int iOwnsPurpleIronThrone = factions_CountLootFromTableByConditions("loot_info_purple", "last_acquired_by", FACTION_IRON_THRONE);
    int iOwnsPurpleCult = factions_CountLootFromTableByConditions("loot_info_purple", "last_acquired_by", FACTION_DRAGON_CULT);
    // OWNS red
    int iOwnsRedEmpire = factions_CountLootFromTableByConditions("loot_info_red", "last_acquired_by", FACTION_EMPIRE);
    int iOwnsRedUnderdark = factions_CountLootFromTableByConditions("loot_info_red", "last_acquired_by", FACTION_UNDERDARK);
    int iOwnsRedIronThrone = factions_CountLootFromTableByConditions("loot_info_red", "last_acquired_by", FACTION_IRON_THRONE);
    int iOwnsRedCult = factions_CountLootFromTableByConditions("loot_info_red", "last_acquired_by", FACTION_DRAGON_CULT);
    // OWNS artifact
    int iOwnsArtifactEmpire = factions_CountLootFromTableByConditions("loot_info_artifact", "last_acquired_by", FACTION_EMPIRE);
    int iOwnsArtifactUnderdark = factions_CountLootFromTableByConditions("loot_info_artifact", "last_acquired_by", FACTION_UNDERDARK);
    int iOwnsArtifactIronThrone = factions_CountLootFromTableByConditions("loot_info_artifact", "last_acquired_by", FACTION_IRON_THRONE);
    int iOwnsArtifactCult = factions_CountLootFromTableByConditions("loot_info_artifact", "last_acquired_by", FACTION_DRAGON_CULT);

    // count total looted
    int iBlueTotal = iBlueEmpire + iBlueUnderdark + iBlueIronThrone + iBlueCult;
    int iGreenTotal = iGreenEmpire + iGreenUnderdark + iGreenIronThrone + iGreenCult;
    int iPurpleTotal = iPurpleEmpire + iPurpleUnderdark + iPurpleIronThrone + iPurpleCult;
    int iRedTotal = iRedEmpire + iRedUnderdark + iRedIronThrone + iRedCult;
    int iArtifactTotal = iArtifactEmpire + iArtifactUnderdark + iArtifactIronThrone + iArtifactCult;
    // prevent division by zero
    iBlueTotal = iBlueTotal > 0 ? iBlueTotal : -1;
    iGreenTotal = iGreenTotal > 0 ? iGreenTotal : -1;
    iPurpleTotal = iPurpleTotal > 0 ? iPurpleTotal : -1;
    iRedTotal = iRedTotal > 0 ? iRedTotal : -1;
    iArtifactTotal = iArtifactTotal > 0 ? iArtifactTotal : -1;

    // count total owns
    int iOwnsBlueTotal = iOwnsBlueEmpire + iOwnsBlueUnderdark + iOwnsBlueIronThrone + iOwnsBlueCult;
    int iOwnsGreenTotal = iOwnsGreenEmpire + iOwnsGreenUnderdark + iOwnsGreenIronThrone + iOwnsGreenCult;
    int iOwnsPurpleTotal = iOwnsPurpleEmpire + iOwnsPurpleUnderdark + iOwnsPurpleIronThrone + iOwnsPurpleCult;
    int iOwnsRedTotal = iOwnsRedEmpire + iOwnsRedUnderdark + iOwnsRedIronThrone + iOwnsRedCult;
    int iOwnsArtifactTotal = iOwnsArtifactEmpire + iOwnsArtifactUnderdark + iOwnsArtifactIronThrone + iOwnsArtifactCult;
    // prevent division by zero
    iOwnsBlueTotal = iOwnsBlueTotal > 0 ? iOwnsBlueTotal : 1;
    iOwnsGreenTotal = iOwnsGreenTotal > 0 ? iOwnsGreenTotal : 1;
    iOwnsPurpleTotal = iOwnsPurpleTotal > 0 ? iOwnsPurpleTotal : 1;
    iOwnsRedTotal = iOwnsRedTotal > 0 ? iOwnsRedTotal : 1;
    iOwnsArtifactTotal = iOwnsArtifactTotal > 0 ? iOwnsArtifactTotal : 1;

    // count faction looted percent in every category
    float fBlueEmpirePercent = 100*IntToFloat(iBlueEmpire)/IntToFloat(abs(iBlueTotal));
    float fBlueUnderdarkPercent = 100*IntToFloat(iBlueUnderdark)/IntToFloat(abs(iBlueTotal));
    float fBlueIronThronePercent = 100*IntToFloat(iBlueIronThrone)/IntToFloat(abs(iBlueTotal));
    float fBlueCultPercent = 100*IntToFloat(iBlueCult)/IntToFloat(abs(iBlueTotal));

    float fGreenEmpirePercent = 100*IntToFloat(iGreenEmpire)/IntToFloat(abs(iGreenTotal));
    float fGreenUnderdarkPercent = 100*IntToFloat(iGreenUnderdark)/IntToFloat(abs(iGreenTotal));
    float fGreenIronThronePercent = 100*IntToFloat(iGreenIronThrone)/IntToFloat(abs(iGreenTotal));
    float fGreenCultPercent = 100*IntToFloat(iGreenCult)/IntToFloat(abs(iGreenTotal));

    float fPurpleEmpirePercent = 100*IntToFloat(iPurpleEmpire)/IntToFloat(abs(iPurpleTotal));
    float fPurpleUnderdarkPercent = 100*IntToFloat(iPurpleUnderdark)/IntToFloat(abs(iPurpleTotal));
    float fPurpleIronThronePercent = 100*IntToFloat(iPurpleIronThrone)/IntToFloat(abs(iPurpleTotal));
    float fPurpleCultPercent = 100*IntToFloat(iPurpleCult)/IntToFloat(abs(iPurpleTotal));

    float fRedEmpirePercent = 100*IntToFloat(iRedEmpire)/IntToFloat(abs(iRedTotal));
    float fRedUnderdarkPercent = 100*IntToFloat(iRedUnderdark)/IntToFloat(abs(iRedTotal));
    float fRedIronThronePercent = 100*IntToFloat(iRedIronThrone)/IntToFloat(abs(iRedTotal));
    float fRedCultPercent = 100*IntToFloat(iRedCult)/IntToFloat(abs(iRedTotal));

    float fArtifactEmpirePercent = 100*IntToFloat(iArtifactEmpire)/IntToFloat(abs(iArtifactTotal));
    float fArtifactUnderdarkPercent = 100*IntToFloat(iArtifactUnderdark)/IntToFloat(abs(iArtifactTotal));
    float fArtifactIronThronePercent = 100*IntToFloat(iArtifactIronThrone)/IntToFloat(abs(iArtifactTotal));
    float fArtifactCultPercent = 100*IntToFloat(iArtifactCult)/IntToFloat(abs(iArtifactTotal));

    // count faction owns percent in every category
    float fOwnsBlueEmpirePercent = 100*IntToFloat(iOwnsBlueEmpire)/IntToFloat(abs(iOwnsBlueTotal));
    float fOwnsBlueUnderdarkPercent = 100*IntToFloat(iOwnsBlueUnderdark)/IntToFloat(abs(iOwnsBlueTotal));
    float fOwnsBlueIronThronePercent = 100*IntToFloat(iOwnsBlueIronThrone)/IntToFloat(abs(iOwnsBlueTotal));
    float fOwnsBlueCultPercent = 100*IntToFloat(iOwnsBlueCult)/IntToFloat(abs(iOwnsBlueTotal));

    float fOwnsGreenEmpirePercent = 100*IntToFloat(iOwnsGreenEmpire)/IntToFloat(abs(iOwnsGreenTotal));
    float fOwnsGreenUnderdarkPercent = 100*IntToFloat(iOwnsGreenUnderdark)/IntToFloat(abs(iOwnsGreenTotal));
    float fOwnsGreenIronThronePercent = 100*IntToFloat(iOwnsGreenIronThrone)/IntToFloat(abs(iOwnsGreenTotal));
    float fOwnsGreenCultPercent = 100*IntToFloat(iOwnsGreenCult)/IntToFloat(abs(iOwnsGreenTotal));

    float fOwnsPurpleEmpirePercent = 100*IntToFloat(iOwnsPurpleEmpire)/IntToFloat(abs(iOwnsPurpleTotal));
    float fOwnsPurpleUnderdarkPercent = 100*IntToFloat(iOwnsPurpleUnderdark)/IntToFloat(abs(iOwnsPurpleTotal));
    float fOwnsPurpleIronThronePercent = 100*IntToFloat(iOwnsPurpleIronThrone)/IntToFloat(abs(iOwnsPurpleTotal));
    float fOwnsPurpleCultPercent = 100*IntToFloat(iOwnsPurpleCult)/IntToFloat(abs(iOwnsPurpleTotal));

    float fOwnsRedEmpirePercent = 100*IntToFloat(iOwnsRedEmpire)/IntToFloat(abs(iOwnsRedTotal));
    float fOwnsRedUnderdarkPercent = 100*IntToFloat(iOwnsRedUnderdark)/IntToFloat(abs(iOwnsRedTotal));
    float fOwnsRedIronThronePercent = 100*IntToFloat(iOwnsRedIronThrone)/IntToFloat(abs(iOwnsRedTotal));
    float fOwnsRedCultPercent = 100*IntToFloat(iOwnsRedCult)/IntToFloat(abs(iOwnsRedTotal));

    float fOwnsArtifactEmpirePercent = 100*IntToFloat(iOwnsArtifactEmpire)/IntToFloat(abs(iOwnsArtifactTotal));
    float fOwnsArtifactUnderdarkPercent = 100*IntToFloat(iOwnsArtifactUnderdark)/IntToFloat(abs(iOwnsArtifactTotal));
    float fOwnsArtifactIronThronePercent = 100*IntToFloat(iOwnsArtifactIronThrone)/IntToFloat(abs(iOwnsArtifactTotal));
    float fOwnsArtifactCultPercent = 100*IntToFloat(iOwnsArtifactCult)/IntToFloat(abs(iOwnsArtifactTotal));

    // output
    string sTabulation = "    ";

    SendColorMessageToPC(oChater, "\n            Loot statistics      ", TXT_COLOR_GREEN_L);
    SendColorMessageToPC(oChater,   "Mini loot:", LOOT_COLOR_BLUE);
    SendMessageToPC(oChater, sTabulation + players_GetFactionName(FACTION_EMPIRE)+      ": "+IntToString(iBlueEmpire)         + ", looted " + FloatToString(fBlueEmpirePercent, 2, 2)          + "%, owns " + FloatToString(fOwnsBlueEmpirePercent, 2, 2)         + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_UNDERDARK)+   ": "+IntToString(iBlueUnderdark)      + ", looted " + FloatToString(fBlueUnderdarkPercent, 2, 2)       + "%, owns " + FloatToString(fOwnsBlueUnderdarkPercent, 2, 2)      + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_IRON_THRONE)+ ": "+IntToString(iBlueIronThrone)     + ", looted " + FloatToString(fBlueIronThronePercent, 2, 2)      + "%, owns " + FloatToString(fOwnsBlueIronThronePercent, 2, 2)     + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_DRAGON_CULT)+ ": "+IntToString(iBlueCult)           + ", looted " + FloatToString(fBlueCultPercent, 2, 2)            + "%, owns " + FloatToString(fOwnsBlueCultPercent, 2, 2)           + "%" + "\n"  +
                             sTabulation + "Total: " + IntToString(iBlueTotal < 0 ? 0 : iBlueTotal));

    SendColorMessageToPC(oChater, "Advanced loot:", LOOT_COLOR_GREEN);
    SendMessageToPC(oChater, sTabulation + players_GetFactionName(FACTION_EMPIRE)+      ": "+IntToString(iGreenEmpire)        + ", looted " + FloatToString(fGreenEmpirePercent, 2, 2)         + "%, owns " + FloatToString(fOwnsGreenEmpirePercent, 2, 2)        + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_UNDERDARK)+   ": "+IntToString(iGreenUnderdark)     + ", looted " + FloatToString(fGreenUnderdarkPercent, 2, 2)      + "%, owns " + FloatToString(fOwnsGreenUnderdarkPercent, 2, 2)     + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_IRON_THRONE)+ ": "+IntToString(iGreenIronThrone)    + ", looted " + FloatToString(fGreenIronThronePercent, 2, 2)     + "%, owns " + FloatToString(fOwnsGreenIronThronePercent, 2, 2)    + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_DRAGON_CULT)+ ": "+IntToString(iGreenCult)          + ", looted " + FloatToString(fGreenCultPercent, 2, 2)           + "%, owns " + FloatToString(fOwnsGreenCultPercent, 2, 2)          + "%" + "\n"  +
                             sTabulation + "Total: " + IntToString(iGreenTotal < 0 ? 0 : iGreenTotal));

    SendColorMessageToPC(oChater, "Lesser set:", LOOT_COLOR_PURPLE);
    SendMessageToPC(oChater, sTabulation + players_GetFactionName(FACTION_EMPIRE)+      ": "+IntToString(iPurpleEmpire)       + ", looted " + FloatToString(fPurpleEmpirePercent, 2, 2)        + "%, owns " + FloatToString(fOwnsPurpleEmpirePercent, 2, 2)       + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_UNDERDARK)+   ": "+IntToString(iPurpleUnderdark)    + ", looted " + FloatToString(fPurpleUnderdarkPercent, 2, 2)     + "%, owns " + FloatToString(fOwnsPurpleUnderdarkPercent, 2, 2)    + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_IRON_THRONE)+ ": "+IntToString(iPurpleIronThrone)   + ", looted " + FloatToString(fPurpleIronThronePercent, 2, 2)    + "%, owns " + FloatToString(fOwnsPurpleIronThronePercent, 2, 2)   + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_DRAGON_CULT)+ ": "+IntToString(iPurpleCult)         + ", looted " + FloatToString(fPurpleCultPercent, 2, 2)          + "%, owns " + FloatToString(fOwnsPurpleCultPercent, 2, 2)         + "%" + "\n"  +
                             sTabulation + "Total: " + IntToString(iPurpleTotal < 0 ? 0 : iPurpleTotal));

    SendColorMessageToPC(oChater, "Greater set:", LOOT_COLOR_RED);
    SendMessageToPC(oChater, sTabulation + players_GetFactionName(FACTION_EMPIRE)+      ": "+IntToString(iRedEmpire)          + ", looted " + FloatToString(fRedEmpirePercent, 2, 2)           + "%, owns " + FloatToString(fOwnsRedEmpirePercent, 2, 2)          + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_UNDERDARK)+   ": "+IntToString(iRedUnderdark)       + ", looted " + FloatToString(fRedUnderdarkPercent, 2, 2)        + "%, owns " + FloatToString(fOwnsRedUnderdarkPercent, 2, 2)       + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_IRON_THRONE)+ ": "+IntToString(iRedIronThrone)      + ", looted " + FloatToString(fRedIronThronePercent, 2, 2)       + "%, owns " + FloatToString(fOwnsRedIronThronePercent, 2, 2)      + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_DRAGON_CULT)+ ": "+IntToString(iRedCult)            + ", looted " + FloatToString(fRedCultPercent, 2, 2)             + "%, owns " + FloatToString(fOwnsRedCultPercent, 2, 2)            + "%" + "\n"  +
                             sTabulation + "Total: " + IntToString(iRedTotal < 0 ? 0 : iRedTotal));

    SendColorMessageToPC(oChater, "Artifacts:", LOOT_COLOR_ARTIFACT);
    SendMessageToPC(oChater, sTabulation + players_GetFactionName(FACTION_EMPIRE)+      ": "+IntToString(iArtifactEmpire)     + ", looted " + FloatToString(fArtifactEmpirePercent, 2, 2)      + "%, owns " + FloatToString(fOwnsArtifactEmpirePercent, 2, 2)     + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_UNDERDARK)+   ": "+IntToString(iArtifactUnderdark)  + ", looted " + FloatToString(fArtifactUnderdarkPercent, 2, 2)   + "%, owns " + FloatToString(fOwnsArtifactUnderdarkPercent, 2, 2)  + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_IRON_THRONE)+ ": "+IntToString(iArtifactIronThrone) + ", looted " + FloatToString(fArtifactIronThronePercent, 2, 2)  + "%, owns " + FloatToString(fOwnsArtifactIronThronePercent, 2, 2) + "%" + "\n"  +
                             sTabulation + players_GetFactionName(FACTION_DRAGON_CULT)+ ": "+IntToString(iArtifactCult)       + ", looted " + FloatToString(fArtifactCultPercent, 2, 2)        + "%, owns " + FloatToString(fOwnsArtifactCultPercent, 2, 2)       + "%" + "\n"  +
                             sTabulation + "Total: " + IntToString(iArtifactTotal < 0 ? 0 : iArtifactTotal));

}

void chat_PrintBossStatuses(object oChater)
{
    SendMessageToPC(oChater, ColorText("\n            Bosses cooldowns      ", TXT_COLOR_GREEN_L));
    chat_PrintBossStatusesByCategory(oChater, "artifact");
    chat_PrintBossStatusesByCategory(oChater, "red");
    chat_PrintBossStatusesByCategory(oChater, "purple");
    chat_PrintBossStatusesByCategory(oChater, "green");
    chat_PrintBossStatusesByCategory(oChater, "blue");
}

void chat_PrintBossStatusesByCategory(object oChater, string sBossCategory)
{
    string sBossResref;
    string sBossName;
    int iBossCooldownSec, iDeathTimeStamp, iRandomShift;

    string sSQL = "SELECT boss_resref, boss_name, boss_cooldown_sec, last_death_timestamp, boss_random_shift FROM boss_cooldowns WHERE category = ? ORDER BY rating";
    NWNX_SQL_PrepareQuery(sSQL); NWNX_SQL_PreparedString(0, sBossCategory); NWNX_SQL_ExecutePreparedQuery();
    while (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sBossResref      = NWNX_SQL_ReadDataInActiveRow(0);
        sBossName        = NWNX_SQL_ReadDataInActiveRow(1);
        iBossCooldownSec = StringToInt(NWNX_SQL_ReadDataInActiveRow(2));
        iDeathTimeStamp  = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
        iRandomShift     = StringToInt(NWNX_SQL_ReadDataInActiveRow(4));

        if (iDeathTimeStamp  <= 0) iDeathTimeStamp  = GetLocalInt(GetModule(), sBossResref);

        string sResult;
        int nTimeLeft = SQLite_GetTimeStamp() - iDeathTimeStamp;
        if     (nTimeLeft >= iBossCooldownSec - BOSS_RANDOM_SPAWN_WINDOW_SIZE/2 &&
                nTimeLeft < iBossCooldownSec + BOSS_RANDOM_SPAWN_WINDOW_SIZE/2)
            sResult = ColorText(" possible ready!", TXT_COLOR_ORANGE);
        else if(SQLite_GetTimeStamp() - iDeathTimeStamp >= iBossCooldownSec + BOSS_RANDOM_SPAWN_WINDOW_SIZE/2)
            sResult = ColorText(" ready!", TXT_COLOR_GREEN_L);
        else
            sResult = ColorText(" not ready! ~" + IntToString((iBossCooldownSec - SQLite_GetTimeStamp() +
                                iDeathTimeStamp)/60) + " minute(s) left.", TXT_COLOR_RED);
        SendMessageToPC(oChater, " - " + ColorText(sBossName, GetLootColorByLootCategory(sBossCategory)) + " status:" + sResult);
    }
}

void chat_PrintDynamicTop(object oChater)
{
    SendMessageToPC(oChater, ColorText("\n            Dynamic top      ", TXT_COLOR_GREEN_L));

    chat_PrintTopForPeriod(oChater, STATISTIC_TIMEFRAME_ONE_DAY, 0);
    chat_PrintTopForPeriod(oChater, STATISTIC_TIMEFRAME_ONE_DAY, 1);
    chat_PrintTopForPeriod(oChater, STATISTIC_TIMEFRAME_ONE_DAY, 2);

    chat_PrintTopForPeriod(oChater, STATISTIC_TIMEFRAME_ONE_WEEK, 0);
    chat_PrintTopForPeriod(oChater, STATISTIC_TIMEFRAME_ONE_WEEK, 1);
    chat_PrintTopForPeriod(oChater, STATISTIC_TIMEFRAME_ONE_WEEK, 2);
}

void chat_PrintTopForPeriod(object oChater, int iTimeFrame, int iStatType = 0 /* 0 - kills+assists, 1 - kills only, 2 - assists only */)
{
    string sRank, sPlayerName, sTotalFame, sCount;
    string sTabulation = "\n    ";
    string sMessage = "";

    json jCash = GetLocalJson(GetModule(), "TOP_STAT");
    if(jCash == JSON_NULL)
        jCash = JSON_OBJECT;

    string sSqlSubCondition;
    string sStatTypeDesc;
    switch (iStatType)
    {
        case 0:
            sSqlSubCondition = "AND (famestat.event_type = '" + IntToString(FAME_GAIN_TYPE_KILL) + "' OR famestat.event_type = '" + IntToString(FAME_GAIN_TYPE_ASSIST) + "') ";
            sStatTypeDesc = ColorText("kills+assists: ", TXT_COLOR_WHITE_T);
        break;
        case 1:
            sSqlSubCondition = "AND famestat.event_type = '" + IntToString(FAME_GAIN_TYPE_KILL) + "' ";
            sStatTypeDesc = ColorText("kills: ", TXT_COLOR_WHITE_T);
        break;
        case 2:
            sSqlSubCondition = "AND famestat.event_type = '" + IntToString(FAME_GAIN_TYPE_ASSIST) + "' ";
            sStatTypeDesc = ColorText("assists: ", TXT_COLOR_WHITE_T);
        break;
        case 3:
            sSqlSubCondition = "AND famestat.event_type = '" + IntToString(FAME_GAIN_TYPE_PVE) + "' ";
            sStatTypeDesc = ColorText("pve: ", TXT_COLOR_WHITE_T);
        break;
        case 4:
            sSqlSubCondition = "AND famestat.event_type = '" + IntToString(FAME_GAIN_TYPE_TRANSFER) + "' ";
            sStatTypeDesc = ColorText("transfer: ", TXT_COLOR_WHITE_T);
        break;
        default:
            sSqlSubCondition = "";
            sStatTypeDesc = ColorText("unknown", TXT_COLOR_WHITE_T);
    }
    string sTimeFrameName;
    switch (iTimeFrame)
    {
        case STATISTIC_TIMEFRAME_ONE_DAY:       sTimeFrameName = "24 hours";       break;
        case STATISTIC_TIMEFRAME_THREE_DAYS:    sTimeFrameName = "3 days";         break;
        case STATISTIC_TIMEFRAME_ONE_WEEK:      sTimeFrameName = "7 days";         break;
        case STATISTIC_TIMEFRAME_ONE_MONTH:     sTimeFrameName = "30 days";        break;
        default: sTimeFrameName = " unknown timeframe";
    }

    sMessage += "Top players with the most " + sStatTypeDesc + " in the last " + sTimeFrameName;
    // if cashed
    int n = 1;
    string sKey = "STAT_TYPE_" + IntToString(iStatType) + "_TIMEFRAME_" + IntToString(iTimeFrame);
    if(JsonObjectGet(jCash, sKey + "_CHAR_" + IntToString(n)) != JSON_NULL)
    {
        while(n <= 10)
        {
            sPlayerName = JsonGetString(JsonObjectGet(jCash, sKey + "_CHAR_" + IntToString(n)));
            if(sPlayerName == "") break; // dont iterate if first is empty
            sTotalFame = JsonGetString(JsonObjectGet(jCash, sKey + "_FAME_" + IntToString(n)));
            sCount = JsonGetString(JsonObjectGet(jCash, sKey + "_COUNT_" + IntToString(n)));
            sMessage += sTabulation + IntToString(n) + ". " + sPlayerName + " - " + sTotalFame + ", " + sStatTypeDesc + sCount;
            n++;
        }
    }
    else
    {
        string sSQL = "SELECT RANK() OVER (ORDER BY results.count DESC) AS rank, `name`, totalfame, results.count, faction " +
                    "FROM " +
                    "( " +
                            "SELECT player_id AS player, SUM(fame) AS totalfame, COUNT(player_id) as count " +
                            "FROM famestat " +
                            "WHERE famestat.`timestamp` > ? " + sSqlSubCondition +
                            "GROUP BY player " +
                    ") AS results " +
                    "JOIN characters ON characters.id = results.player " +
                    "LIMIT 10";

        NWNX_SQL_PrepareQuery(sSQL);
        int iPeriod = SQLite_GetTimeStamp() - iTimeFrame;
        NWNX_SQL_PreparedInt(0, iPeriod);
        NWNX_SQL_ExecutePreparedQuery();
        while (NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            //sRank       = NWNX_SQL_ReadDataInActiveRow(0);
            sRank       = IntToString(n);
            sPlayerName = ColorText(NWNX_SQL_ReadDataInActiveRow(1), players_GetFactionColor(StringToInt(NWNX_SQL_ReadDataInActiveRow(4))));
            sTotalFame  = ColorText("fame: ", TXT_COLOR_RED) + NWNX_SQL_ReadDataInActiveRow(2);
            sCount      = NWNX_SQL_ReadDataInActiveRow(3);
            jCash = JsonObjectSet(jCash, sKey + "_CHAR_"  + sRank, JsonString(sPlayerName));
            jCash = JsonObjectSet(jCash, sKey + "_FAME_"  + sRank, JsonString(sTotalFame));
            jCash = JsonObjectSet(jCash, sKey + "_COUNT_" + sRank, JsonString(sCount));
            sMessage += sTabulation + sRank + ". " + sPlayerName + " - " + sTotalFame + ", " + sStatTypeDesc + sCount;
            n++;
        }
    }
    SetLocalJson(GetModule(), "TOP_STAT", jCash);
    SendMessageToPC(oChater, sMessage);
}

int chat_GetCharacterStatistics(object oPC, int iEventType /* 1 - kills, 2 - assists */)
{
    int iPlayerID = players_GetPCPersistentID(oPC);
    string FAMESTAT_PLAYER_VAR = "FAMESTAT_PLAYER_ID_" + IntToString(players_GetPCPersistentID(oPC)) + "_EVENT_" + IntToString(iEventType);
    int nResult = GetLocalInt(oPC, FAMESTAT_PLAYER_VAR);
    if(nResult)
        return nResult > 0 ? nResult : 0;

    string sSQL = "SELECT COUNT(*) FROM famestat WHERE player_id = ? AND event_type = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_PreparedInt(1, iEventType);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nResult = StringToInt(NWNX_SQL_ReadDataInActiveRow());

    }
    if(nResult)
        SetLocalInt(oPC, FAMESTAT_PLAYER_VAR, nResult);
    else
        SetLocalInt(oPC, FAMESTAT_PLAYER_VAR, -1);

    return nResult;
}

int chat_CountFactionPlayersAndSendStat(object oSpeaker, int nFaction, int bDM)
{
    int nResult = 0;
    SendMessageToPC(oSpeaker, players_GetFactionName(nFaction));
    string sTabulation = "    ";
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        if(!GetIsDM(oPC) && players_GetFaction(oPC) == nFaction)
        {
            int iPlayerKillCount = chat_GetCharacterStatistics(oPC, FAME_GAIN_TYPE_KILL);
            int iPlayerAssists   = chat_GetCharacterStatistics(oPC, FAME_GAIN_TYPE_ASSIST);
            string sAccount = GetPCPlayerName(oPC);
            int iFame = chat_GetAccountFame(oPC);
            string sName = GetName(oPC);
            nResult++;
            if(oPC != oSpeaker)
            {
                string sBuildForPlayer = class_GetClassNameById(class_GetDisplayedClassIdForPlayers(oPC));
                string sBuildForDM     = class_GetClassNameById(GetClassByPosition(1,oPC)) + chat_GetValidStringLevel(GetLevelByPosition(1,oPC)) + " " +
                                         class_GetClassNameById(GetClassByPosition(2,oPC)) + chat_GetValidStringLevel(GetLevelByPosition(2,oPC)) + " " +
                                         class_GetClassNameById(GetClassByPosition(3,oPC)) + chat_GetValidStringLevel(GetLevelByPosition(3,oPC));

                SendColorMessageToPC(oSpeaker, "\n" +
                                    sTabulation + "Name: "    + sName       + " (Level: "       + IntToString(GetHitDice(oPC)) + ")\n" +
                                    sTabulation + "Account: " + sAccount    + ", Fame: "        + IntToString(iFame)           + "\n"  +
                                    sTabulation + "Main class: " + sBuildForPlayer                                             + "\n"  +
                                    sTabulation + "Kills: "   + IntToString(iPlayerKillCount)   + " " +
                                    sTabulation + "Assists: "  + IntToString(iPlayerAssists)  + " " +
                                    sTabulation + "Kills+Assists: "     + IntToString(iPlayerKillCount + iPlayerAssists), TXT_COLOR_NONE);
                if(bDM)
                {
                    SendColorMessageToPC(oSpeaker,
                                    sTabulation + "Build: "      + sBuildForDM              + "\n"  +
                                    sTabulation + "IP: "         + GetPCIPAddress(oPC)      + "\n"  +
                                    sTabulation + "CdKey: "      + GetPCPublicCDKey(oPC)    + "\n"  +
                                    sTabulation + "Experience: " + IntToString(GetXP(oPC))  + "\n"  +
                                    sTabulation + "Area: " + GetName(GetArea(oPC)), TXT_COLOR_NONE);
                }
            }
        }
        oPC = GetNextPC();
    }
    return nResult;
}

void chat_PrintPVPStats(object oSpeaker)
{
    int bDM = GetIsDM(oSpeaker);
    SendColorMessageToPC(oSpeaker, "\n            PVP statistics", TXT_COLOR_GREEN_L);
    string sTabulation = "    ";
    int nEmpirePlayers     = chat_CountFactionPlayersAndSendStat(oSpeaker, FACTION_EMPIRE, bDM);
    int nUnderdarkPlayers  = chat_CountFactionPlayersAndSendStat(oSpeaker, FACTION_UNDERDARK, bDM);
    int nIronThronePlayers = chat_CountFactionPlayersAndSendStat(oSpeaker, FACTION_IRON_THRONE, bDM);
    int nDragonCultPlayers = chat_CountFactionPlayersAndSendStat(oSpeaker, FACTION_DRAGON_CULT, bDM);
    // personal stat
    if(!bDM)
    {
        int iPlayerKillCount = chat_GetCharacterStatistics(oSpeaker, 1);
        int iPlayerAssists   = chat_GetCharacterStatistics(oSpeaker, 2);
        int iFame = chat_GetAccountFame(oSpeaker);
        SendColorMessageToPC(oSpeaker,
            "\n"+
            "Personal statistics \n" +
            sTabulation + "Kills: "   + IntToString(iPlayerKillCount) + " " +
            sTabulation + "Assists: " + IntToString(iPlayerAssists)+ " " +
            sTabulation + "Kills+Assists: " + IntToString(iPlayerKillCount + iPlayerAssists) + "\n" +
            sTabulation + "Fame: "    + IntToString(iFame),TXT_COLOR_RED);
    }
    SendMessageToPC(oSpeaker, "Online");
    SendMessageToPC(oSpeaker, sTabulation + players_GetFactionName(FACTION_EMPIRE)        + ": " + IntToString(nEmpirePlayers));
    SendMessageToPC(oSpeaker, sTabulation + players_GetFactionName(FACTION_UNDERDARK)     + ": " + IntToString(nUnderdarkPlayers));
    SendMessageToPC(oSpeaker, sTabulation + players_GetFactionName(FACTION_IRON_THRONE)   + ": " + IntToString(nIronThronePlayers));
    SendMessageToPC(oSpeaker, sTabulation + players_GetFactionName(FACTION_DRAGON_CULT)   + ": " + IntToString(nDragonCultPlayers));
    int nTotalPlayers = nEmpirePlayers + nUnderdarkPlayers + nIronThronePlayers + nDragonCultPlayers;
    SendMessageToPC(oSpeaker, sTabulation + "Total: " + ": " + IntToString(nTotalPlayers));

    string sMiniTotal     = IntToString(factions_CountAllLootFromTable("loot_info_blue", FALSE));
    string sEpicTotal     = IntToString(factions_CountAllLootFromTable("loot_info_green", FALSE));
    string sSetTotal      = IntToString(factions_CountAllLootFromTable("loot_info_red", FALSE));
    string sPurpleTotal   = IntToString(factions_CountAllLootFromTable("loot_info_purple", FALSE));
    string sArtifactTotal = IntToString(factions_CountAllLootFromTable("loot_info_artifact", FALSE));
    SendMessageToPC(oSpeaker, "Total loot");
    SendMessageToPC(oSpeaker, sTabulation + LOOT_COLOR_BLUE     + "Mini loot: "     + sMiniTotal      + TXT_COLOR_END);
    SendMessageToPC(oSpeaker, sTabulation + LOOT_COLOR_GREEN    + "Advanced loot: " + sEpicTotal      + TXT_COLOR_END);
    SendMessageToPC(oSpeaker, sTabulation + LOOT_COLOR_PURPLE   + "Lesser set: "    + sPurpleTotal    + TXT_COLOR_END);
    SendMessageToPC(oSpeaker, sTabulation + LOOT_COLOR_RED      + "Greater set:  "  + sSetTotal       + TXT_COLOR_END);
    SendMessageToPC(oSpeaker, sTabulation + LOOT_COLOR_ARTIFACT + "Artifacts: "     + sArtifactTotal  + TXT_COLOR_END + "\n");

    string sLootDrop = db_GetModuleParameter(MODULE_SETTING_ENABLE_ITEM_DROP) == "0" ? "disabled." : "enabled.";

    SendMessageToPC(oSpeaker, "Fame statistics");
    SendMessageToPC(oSpeaker, sTabulation + players_GetFactionName(FACTION_EMPIRE)      + ": " + IntToString(factions_GetFactionFame(FACTION_EMPIRE))      +
                    ", Bonus XP: "+ IntToString(factions_GetFactionXPBoost(FACTION_EMPIRE)));
    SendMessageToPC(oSpeaker, sTabulation + players_GetFactionName(FACTION_UNDERDARK)   + ": " + IntToString(factions_GetFactionFame(FACTION_UNDERDARK))   +
                    ", Bonus XP: "+ IntToString(factions_GetFactionXPBoost(FACTION_UNDERDARK)));
    SendMessageToPC(oSpeaker, sTabulation + players_GetFactionName(FACTION_IRON_THRONE) + ": " + IntToString(factions_GetFactionFame(FACTION_IRON_THRONE)) +
                    ", Bonus XP: "+ IntToString(factions_GetFactionXPBoost(FACTION_IRON_THRONE)));
    SendMessageToPC(oSpeaker, sTabulation + players_GetFactionName(FACTION_DRAGON_CULT) + ": " + IntToString(factions_GetFactionFame(FACTION_DRAGON_CULT)) +
                    ", Bonus XP: "+ IntToString(factions_GetFactionXPBoost(FACTION_DRAGON_CULT)));

    SendMessageToPC(oSpeaker, sTabulation + "Total Fame: " + IntToString(factions_GetTotalFactionsFame()) +  ", Total experience bonus: "
                    + TXT_COLOR_WHITE + IntToString(factions_GetTotalXPBoost()));
    // treasure gold info
    chat_SendFactionTreasureStat(oSpeaker);
    // drop status
    SendMessageToPC(oSpeaker, TXT_COLOR_WHITE + "PvP loot drop: " + sLootDrop + TXT_COLOR_END + "\n");
}

void chat_SendFactionTreasureStat(object oSpeaker)
{
    string sShowGoldToPlayer = "";
    string sTabulation = "    ";
    SendMessageToPC(oSpeaker, "\nGold in the treasury");
    NWNX_SQL_PrepareQuery("select F.id, F.name, F.faction_gold from factions F WHERE F.id > 0 ORDER BY F.id");
    NWNX_SQL_ExecutePreparedQuery();
    while(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        int nFaction = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
        string sFactionName = ColorText(NWNX_SQL_ReadDataInActiveRow(1), players_GetFactionColor(nFaction));
        string sGoldValue = NWNX_SQL_ReadDataInActiveRow(2);
        sShowGoldToPlayer += sTabulation + sFactionName + ": " + sGoldValue + "\n";
    }
    SendMessageToPC(oSpeaker, sShowGoldToPlayer);
}

void chat_PrintTop10(object oSpeaker)
{
    string account, fame, character, kills;
    int faction;
    string sTabulation = "\n    ";
    string sMessage = ColorText("\n            Top 10 players", TXT_COLOR_GREEN_L);

    json jCash = GetLocalJson(GetModule(), "TOP_STAT");
    if(jCash == JSON_NULL)
        jCash = JSON_OBJECT;
    // fame PvP only score
    sMessage += "\nTop accounts by PvP fame";
    string sKey = "TOP10_BY_PVP_FAME";
    int n = 1;
    if(JsonObjectGet(jCash, sKey + "_ACCOUNT_" + IntToString(n)) != JSON_NULL)
    {
        while(n <= 10)
        {
            account = JsonGetString(JsonObjectGet(jCash, sKey + "_ACCOUNT_" + IntToString(n)));
            fame = JsonGetString(JsonObjectGet(jCash, sKey + "_FAME_" + IntToString(n)));
            sMessage += sTabulation + IntToString(n) + ". " + ColorText(account, TXT_COLOR_GREEN_L) + " - " + ColorText(fame, TXT_COLOR_RED);
            n++;
        }
    }
    else
    {
        NWNX_SQL_ExecuteQuery(
            "SELECT account, SUM(totalfame) as pvpfame " +
            "FROM " +
                "(SELECT " +
                        "player_id AS player, SUM(fame) AS totalfame " +
                "FROM " +
                        "famestat " +
                "WHERE " +
                        "famestat.`timestamp` > 0 AND (famestat.event_type = 1 OR famestat.event_type = 2 OR famestat.event_type = 5) " +
                "GROUP BY player) as tfame " +
            "LEFT JOIN characters ON characters.id = tfame.player " +
            "GROUP BY account " +
            "ORDER BY pvpfame DESC " +
            "LIMIT 10");
        while (NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            account = NWNX_SQL_ReadDataInActiveRow(0);
            fame = NWNX_SQL_ReadDataInActiveRow(1);
            jCash = JsonObjectSet(jCash, sKey + "_ACCOUNT_" + IntToString(n), JsonString(account));
            jCash = JsonObjectSet(jCash, sKey + "_FAME_"    + IntToString(n), JsonString(fame));
            sMessage += sTabulation + IntToString(n) + ". " + ColorText(account, TXT_COLOR_GREEN_L) + " - " + ColorText(fame, TXT_COLOR_RED);
            n++;
        }
    }
    // fame PvP+PvE score
    sMessage += "\nTop accounts by PvP+PvE fame";
    sKey = "TOP10_BY_PVP_AND_PVE_FAME";
    n = 1;
    if(JsonObjectGet(jCash, sKey + "_ACCOUNT_" + IntToString(n)) != JSON_NULL)
    {
        while(n <= 10)
        {
            account = JsonGetString(JsonObjectGet(jCash, sKey + "_ACCOUNT_" + IntToString(n)));
            fame = JsonGetString(JsonObjectGet(jCash, sKey + "_FAME_" + IntToString(n)));
            sMessage += sTabulation + IntToString(n) + ". " + ColorText(account, TXT_COLOR_GREEN_L) + " - " + ColorText(fame, TXT_COLOR_RED);
            n++;
        }
    }
    else
    {
        NWNX_SQL_ExecuteQuery(
            "SELECT account, SUM(totalfame) as pvpfame " +
            "FROM " +
                "(SELECT " +
                        "player_id AS player, SUM(fame) AS totalfame " +
                "FROM " +
                        "famestat " +
                "WHERE " +
                        "famestat.`timestamp` > 0 AND (famestat.event_type = 1 OR famestat.event_type = 2 OR famestat.event_type = 3 OR famestat.event_type = 5) " +
                "GROUP BY player) as tfame " +
            "LEFT JOIN characters ON characters.id = tfame.player " +
            "GROUP BY account " +
            "ORDER BY pvpfame DESC " +
            "LIMIT 10");
        while (NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            account = NWNX_SQL_ReadDataInActiveRow(0);
            fame = NWNX_SQL_ReadDataInActiveRow(1);
            jCash = JsonObjectSet(jCash, sKey + "_ACCOUNT_" + IntToString(n), JsonString(account));
            jCash = JsonObjectSet(jCash, sKey + "_FAME_"    + IntToString(n), JsonString(fame));
            sMessage += sTabulation + IntToString(n) + ". " + ColorText(account, TXT_COLOR_GREEN_L) + " - " + ColorText(fame, TXT_COLOR_RED);
            n++;
        }
    }
    // kill score
    sMessage += "\nTop characters by kills";
    sKey = "TOP10_CHARS_BY_KILLS";
    n = 1;
    if(JsonObjectGet(jCash, sKey + "_NAME_" + IntToString(n)) != JSON_NULL)
    {
        while(n <= 10)
        {
            character = JsonGetString(JsonObjectGet(jCash, sKey + "_NAME_" + IntToString(n)));
            kills = JsonGetString(JsonObjectGet(jCash, sKey + "_KILLS_" + IntToString(n)));
            int nFaction = JsonGetInt(JsonObjectGet(jCash, sKey + "_FACTION_" + IntToString(n)));
            sMessage += sTabulation + IntToString(n) + ". " + ColorText(character, players_GetFactionColor(nFaction)) + " - " +
                                                              ColorText(kills, TXT_COLOR_RED);

            n++;
        }
    }
    else
    {
        NWNX_SQL_ExecuteQuery(
            "SELECT RANK() OVER (ORDER BY results.count DESC) AS rank, `name`, results.count, faction " +
            "FROM " +
            "( " +
                "SELECT player_id AS player, SUM(fame) AS totalfame, COUNT(player_id) as count   " +
                "FROM famestat " +
                "WHERE famestat.`timestamp` > 0 AND (famestat.event_type = 1 OR famestat.event_type = 0) " +
                "GROUP BY player " +
            ") AS results " +
            "JOIN characters ON characters.id = results.player " +
            "LIMIT 10");
        while (NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            //string sRank = NWNX_SQL_ReadDataInActiveRow(0);
            string sRank = IntToString(n);
            faction = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
            character = NWNX_SQL_ReadDataInActiveRow(1);
            kills = NWNX_SQL_ReadDataInActiveRow(2);
            jCash = JsonObjectSet(jCash, sKey + "_NAME_"  + sRank, JsonString(character));
            jCash = JsonObjectSet(jCash, sKey + "_KILLS_" + sRank, JsonString(kills));
            jCash = JsonObjectSet(jCash, sKey + "_FACTION_" + sRank, JsonInt(faction));
            sMessage += sTabulation + sRank + ". " + ColorText(character, players_GetFactionColor(faction)) + " - " +
                                                     ColorText(kills, TXT_COLOR_RED);;
            n++;
        }
    }
    // top killers by account
    sMessage += "\nTop accounts by kills";
    sKey = "TOP10_ACCOUNTS_BY_KILLS";
    n = 1;
    if(JsonObjectGet(jCash, sKey + "_ACCOUNT_" + IntToString(n)) != JSON_NULL)
    {
        while(n <= 10)
        {
            account = JsonGetString(JsonObjectGet(jCash, sKey + "_ACCOUNT_" + IntToString(n)));
            kills = JsonGetString(JsonObjectGet(jCash, sKey + "_KILLS_" + IntToString(n)));
            sMessage += sTabulation + IntToString(n) + ". " + account + " - " + kills;
            n++;
        }
    }
    else
    {
        NWNX_SQL_ExecuteQuery(
            "SELECT RANK() OVER (ORDER BY totalkills DESC) AS rank, account, SUM(count) as totalkills " +
            "FROM " +
            "( " +
                "SELECT player_id AS player, COUNT(player_id) as count " +
                "FROM famestat " +
                "WHERE famestat.`timestamp` > 0 AND famestat.event_type = 1 " +
                "GROUP BY player " +
            ") AS results " +
            "JOIN characters ON characters.id = results.player " +
            "GROUP BY account " +
            "ORDER BY totalkills DESC " +
            "LIMIT 10");

        while (NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            //string sRank = NWNX_SQL_ReadDataInActiveRow(0);
            string sRank = IntToString(n);
            account = ColorText(NWNX_SQL_ReadDataInActiveRow(1), TXT_COLOR_GREEN_L);
            kills = ColorText(NWNX_SQL_ReadDataInActiveRow(2), TXT_COLOR_RED);
            jCash = JsonObjectSet(jCash, sKey + "_ACCOUNT_"  + sRank, JsonString(account));
            jCash = JsonObjectSet(jCash, sKey + "_KILLS_" + sRank, JsonString(kills));
            sMessage += sTabulation + sRank + ". " + account + " - " + kills;
            n++;
        }
    }
    SetLocalJson(GetModule(), "TOP_STAT", jCash);
    SendMessageToPC(oSpeaker, sMessage);
}

int chat_GetFactionStatistics(int iStatType /* 1 - kills, 2 - assists, 3 deaths*/, int iFaction)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    json jCash = GetLocalJson(oFactionCashObject, "FACTION_STATISTICS");
    string sKey = "FACTION_" + IntToString(iFaction) + "_STAT_TYPE_" + IntToString(iStatType);
    if(JsonObjectGet(jCash, sKey) != JSON_NULL)
        return JsonGetInt(JsonObjectGet(jCash, sKey));
    else if(jCash == JSON_NULL)
        jCash = JSON_OBJECT;

    int iEventType;
    string sTableType;
    switch (iStatType)
    {
        case 1:
            iEventType = FAME_GAIN_TYPE_KILL;
            sTableType = "player_id";
        break;
        case 2:
            iEventType = FAME_GAIN_TYPE_ASSIST;
            sTableType = "player_id";
        break;
        case 3:
            iEventType = FAME_GAIN_TYPE_KILL;
            sTableType = "victim_id";
        break;
        default: return 0;
    }
    string sSQL =
    "SELECT COUNT(found_id) as sum  " +
    "FROM " +
    "( " +
        "SELECT " + sTableType + " as found_id " +
        "FROM famestat " +
        "WHERE famestat.event_type = ? " +
    ") as result " +
    "JOIN characters ON characters.id = result.found_id " +
    "WHERE faction = ? ";

    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iEventType);
    NWNX_SQL_PreparedInt(1, iFaction);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        if(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            int nResult = StringToInt(NWNX_SQL_ReadDataInActiveRow());
            jCash = JsonObjectSet(jCash, sKey, JsonInt(nResult));
            SetLocalJson(oFactionCashObject, "FACTION_STATISTICS", jCash);
            return nResult;
        }
    }
    return 0;
}

void chat_PrintFactionPVPStats(object oChater)
{
    SendColorMessageToPC(oChater, "\n            Kills/Deaths statistics      ", TXT_COLOR_GREEN_L);

    SendMessageToPC(oChater, players_GetFactionName(FACTION_EMPIRE) + ":" +
                             " Kills: "   + IntToString(chat_GetFactionStatistics(1, FACTION_EMPIRE)) +
                             " Assists: " + IntToString(chat_GetFactionStatistics(2, FACTION_EMPIRE)) +
                             " Deaths: "  + IntToString(chat_GetFactionStatistics(3, FACTION_EMPIRE)));

    SendMessageToPC(oChater, players_GetFactionName(FACTION_UNDERDARK) + ":" +
                             " Kills: "   + IntToString(chat_GetFactionStatistics(1, FACTION_UNDERDARK)) +
                             " Assists: " + IntToString(chat_GetFactionStatistics(2, FACTION_UNDERDARK)) +
                             " Deaths: "  + IntToString(chat_GetFactionStatistics(3, FACTION_UNDERDARK)));

    SendMessageToPC(oChater, players_GetFactionName(FACTION_IRON_THRONE) + ":" +
                             " Kills: "   + IntToString(chat_GetFactionStatistics(1, FACTION_IRON_THRONE)) +
                             " Assists: " + IntToString(chat_GetFactionStatistics(2, FACTION_IRON_THRONE)) +
                             " Deaths: "  + IntToString(chat_GetFactionStatistics(3, FACTION_IRON_THRONE)));

    SendMessageToPC(oChater, players_GetFactionName(FACTION_DRAGON_CULT) + ":" +
                             " Kills: "   + IntToString(chat_GetFactionStatistics(1, FACTION_DRAGON_CULT)) +
                             " Assists: " + IntToString(chat_GetFactionStatistics(2, FACTION_DRAGON_CULT)) +
                             " Deaths: "  + IntToString(chat_GetFactionStatistics(3, FACTION_DRAGON_CULT)));
}

void chat_DeleteCharacter(object oChater)
{
    string sAccount = GetPCPlayerName(oChater);
    int iPlayerID   = players_GetPCPersistentID(oChater);

    NWNX_Administration_DeletePlayerCharacter(oChater);

    int iCharacterSpentFame = GetCharacterSpentFame(iPlayerID);
    SetSpentFame(sAccount, GetSpentFame(sAccount) - FloatToInt(IntToFloat(iCharacterSpentFame)*
                           FAME_RESTORE_COEFFICIENT));
}

string chat_GetValidStringLevel(int nLvl)
{
    return (nLvl > 0) ? "("+IntToString(nLvl)+")" : "";;
}

void chat_SendMoney(object oPC, string sMsg)
{
    if (GetNumberTokens(sMsg, " ") == 1)
    {
        SendMessageToPC(oPC, "Your account balance " +
                             ColorText(bank_FormatOutputValue(IntToString(bank_GetAccountBalance(oPC))), TXT_COLOR_GREEN_L) +
                             " GP.");
        return;
    }

    int nMoneyAmount = StringToInt(GetTokenByPosition(sMsg, " ", 1));

    if (nMoneyAmount > 0)
    {
        SetLocalInt(oPC, "TARGET_MODE", TARGET_MODE_SEND_MONEY);
        SetLocalInt(oPC, "MONEY_TRANSFER_AMOUNT", nMoneyAmount);
        EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_MAGIC, MOUSECURSOR_NOMAGIC);
    }
    else
    {
        // exception
        SendColorMessageToPC(oPC, "You entered incorrect number or this number is too long.", TXT_COLOR_RED);
    }
}

void chat_SendFame(object oPC, string sMsg)
{
    if (GetNumberTokens(sMsg, " ") == 1)
    {
        SendMessageToPC(oPC, "You have " +
                             ColorText(bank_FormatOutputValue(IntToString(GetFreeFame(oPC))), TXT_COLOR_GREEN_L) +
                             " free fame.");
        return;
    }
    int nFameAmount = StringToInt(GetTokenByPosition(sMsg, " ", 1));

    if (nFameAmount > 0)
    {
        SetLocalInt(oPC, "TARGET_MODE", TARGET_MODE_SEND_FAME);
        SetLocalInt(oPC, "FAME_TRANSFER_AMOUNT", nFameAmount);
        EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_MAGIC, MOUSECURSOR_NOMAGIC);
    }
    else
    {
        // exception
        SendColorMessageToPC(oPC, "You entered incorrect number or this number is too long.", TXT_COLOR_RED);
    }
}

void chat_SendSoulStones(object oPC, string sMsg)
{
    if (GetNumberTokens(sMsg, " ") == 1)
    {
        SendMessageToPC(oPC, "You have " +
                             ColorText((IntToString(generic_GetSoulStones(GetPCPlayerName(oPC)))), TXT_COLOR_GREEN_L) +
                             " Soul Stones.");
        return;
    }
    int nSoulStonesAmount = StringToInt(GetTokenByPosition(sMsg, " ", 1));

    if (nSoulStonesAmount > 0)
    {
        SetLocalInt(oPC, "TARGET_MODE", TARGET_MODE_SEND_SOUL_STONES);
        SetLocalInt(oPC, "SOUL_STONES_TRANSFER_AMOUNT", nSoulStonesAmount);
        EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_MAGIC, MOUSECURSOR_NOMAGIC);
    }
    else
    {
        // exception
        SendColorMessageToPC(oPC, "You entered incorrect number or this number is too long.", TXT_COLOR_RED);
    }
}

int chat_GetAccountFame(object oPC)
{
    string sAccount = GetPCPlayerName(oPC);
    string PVP_FAME_VAR = "PVP_FAME_ACCOUNT_" + GetStringUpperCase(sAccount);
    int nResult = GetLocalInt(oPC, PVP_FAME_VAR);
    if(nResult)
        return nResult > 0 ? nResult : 0;

    string sSQL =
        "SELECT " +
           "    sum( fame ) AS pvpfame " +
        "FROM " +
                "( SELECT player_id, fame, event_type FROM famestat WHERE " +
                     "event_type = '" + IntToString(FAME_GAIN_TYPE_KILL) +
                "' OR event_type = '" + IntToString(FAME_GAIN_TYPE_ASSIST) +
                      "' OR event_type = '" + IntToString(FAME_GAIN_TYPE_PVE) +
                      "' OR event_type = '" + IntToString(FAME_GAIN_TYPE_USELESS) + "') AS results " +
        "LEFT JOIN nwn.characters ON results.player_id = characters.id " +
        "WHERE " +
           "    account = ? " +
        "GROUP BY " +
           "    account " +
        "ORDER BY " +
           "pvpfame DESC";

    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nResult = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    if(nResult > 0)
        SetLocalInt(oPC, PVP_FAME_VAR, nResult);
    else
        SetLocalInt(oPC, PVP_FAME_VAR, -1);

    return nResult;
}

string chat_GetPlayerFavoriteEnemy(int iPlayerID)
{
    string sSQL =
        "SELECT " +
            "   player_id as killer_id, `name` as victim_name, faction, COUNT(victim_id) as deaths " +
        "FROM " +
            "   ( SELECT player_id, victim_id FROM famestat WHERE event_type = '1' and player_id = ?) AS results " +
        "LEFT JOIN nwn.characters ON results.victim_id = characters.id " +
        "GROUP BY " +
            "   victim_id " +
        "ORDER BY " +
            "   deaths DESC " +
        "LIMIT 1 ";

    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return NWNX_SQL_ReadDataInActiveRow(1) + "|" + NWNX_SQL_ReadDataInActiveRow(2) + "|" + NWNX_SQL_ReadDataInActiveRow(3);
    }
    else
    {
        return "";
    }
}

string chat_GetPlayerWorstEnemy(int iPlayerID)
{
    string sSQL =
        "SELECT " +
               "victim_id, `name` as killer_name, faction, COUNT(victim_id) as kills " +
        "FROM " +
            "   ( SELECT player_id, victim_id FROM famestat WHERE event_type = '1' and victim_id = ?) AS results " +
        "LEFT JOIN nwn.characters ON results.player_id = characters.id " +
        "GROUP BY " +
               "player_id " +
        "ORDER BY " +
            "kills DESC " +
        "LIMIT 1"   ;

    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return NWNX_SQL_ReadDataInActiveRow(1) + "|" + NWNX_SQL_ReadDataInActiveRow(2) + "|" + NWNX_SQL_ReadDataInActiveRow(3);
    }
    else
    {
        return "";
    }
}


void chat_MapNotesChecker()
{
    string sLogMessage = "\n--------------------MapNotes Checker--------------------\n";
    object oArea = GetFirstArea();
    while(GetIsObjectValid(oArea))
    {
        object oTransition = GetFirstObjectInArea(oArea, OBJECT_TYPE_TRIGGER | OBJECT_TYPE_DOOR);
        string sAreaName = GetName(oArea);
        // for all valid triggers
        while(GetIsObjectValid(oTransition))
        {
            int nTransitionObjectType = GetObjectType(oTransition);
            // if destination target is exists
            object oTransitionTarget = GetTransitionTarget(oTransition);
            object oTransitionTargetArea = GetArea(oTransitionTarget);
            if(GetIsObjectValid(oTransitionTarget) && oArea != oTransitionTargetArea)
            {
                location lCenter = GetLocation(oTransition);
                // let's try to find an existing mapnote
                object oMapNote = GetNearestObjectToLocation(OBJECT_TYPE_WAYPOINT, lCenter);
                int bFoundedFromTrigger = FALSE;
                if(nTransitionObjectType == OBJECT_TYPE_TRIGGER)
                {
                    object oNearestWaypoint = chat_MapNotesFindNextSideTransition(oTransition, oTransitionTarget);
                    if(GetIsObjectValid(oNearestWaypoint))
                    {
                        oMapNote = oNearestWaypoint;
                        bFoundedFromTrigger = TRUE;
                    }
                }
                string sTransitionTargetAreaName = GetName(oTransitionTargetArea);

                // override not correct mapnote
                if(GetIsObjectValid(oMapNote) && GetDistanceBetweenLocations(lCenter, GetLocation(oMapNote)) <= 7.5 ||
                   bFoundedFromTrigger)
                {
                    string sMapnoteText = NWNX_Object_GetMapNote(oMapNote);
                    if(FindSubString(GetStringLowerCase(sTransitionTargetAreaName), GetStringLowerCase(sMapnoteText)) == -1)
                    {
                        sLogMessage += "[MAPNOTE INFO] mapnote with tag <" + GetTag(oMapNote) + "> and name [" + sMapnoteText + "] != [" +
                                       sTransitionTargetAreaName + "] in Area <" + sAreaName + ">\n";
                    }
                }
                else
                {
                    sLogMessage += "[MAPNOTE INFO] need waypoint in Area ["+ sAreaName + "] with name [" +
                                   sTransitionTargetAreaName + "]\n";
                }
            }
            oTransition = GetNextObjectInArea(oArea, OBJECT_TYPE_TRIGGER | OBJECT_TYPE_DOOR);
        }
        oArea = GetNextArea();
    }
    WriteTimestampedLogEntry(sLogMessage);
}

object chat_MapNotesFindNextSideTransition(object oTrigger, object oTargetWaypoint)
{
    object oNextSideTrigger = GetNearestObject(OBJECT_TYPE_TRIGGER, oTargetWaypoint);
    object oResult = GetTransitionTarget(oNextSideTrigger);
    if(GetArea(oTrigger) == GetArea(oResult))
        return oResult;
    else
        return OBJECT_INVALID;
}

int chat_CreatureReportBonuses_GetAbility(object oCreature, int nAbility)
{
    return NWNX_Creature_GetTotalEffectBonus(oCreature,
                                          /*bonusType*/NWNX_CREATURE_BONUS_TYPE_ABILITY,
                                          /*target*/OBJECT_INVALID,
                                          /*isElemental*/0,
                                          /*isForceMax*/0,
                                          /*savetype*/-1,
                                          /*saveSpecificType*/-1,
                                          /*skill*/-1,
                                          /*abilityScore*/nAbility,
                                          /*isOffhand*/FALSE);
}

int chat_CreatureReportBonuses_GetSaves(object oCreature, int nSaves)
{
    return NWNX_Creature_GetTotalEffectBonus(oCreature,
                                          /*bonusType*/NWNX_CREATURE_BONUS_TYPE_SAVING_THROW,
                                          /*target*/OBJECT_INVALID,
                                          /*isElemental*/0,
                                          /*isForceMax*/0,
                                          /*savetype*/nSaves,
                                          /*saveSpecificType*/-1,
                                          /*skill*/-1,
                                          /*abilityScore*/-1,
                                          /*isOffhand*/FALSE);
}

int chat_CreatureReportBonuses_GetSkills(object oCreature, int nSkill)
{
    return NWNX_Creature_GetTotalEffectBonus(oCreature,
                                          /*bonusType*/NWNX_CREATURE_BONUS_TYPE_SKILL,
                                          /*target*/OBJECT_INVALID,
                                          /*isElemental*/0,
                                          /*isForceMax*/0,
                                          /*savetype*/-1,
                                          /*saveSpecificType*/-1,
                                          /*skill*/nSkill,
                                          /*abilityScore*/-1,
                                          /*isOffhand*/FALSE);
}

string chat_CreatureReportBonuses(object oCreature)
{
    string sResult = ColorText("\n            Active effects bonuses", TXT_COLOR_GREEN_L);
    string sTabulation = "    ";
    int nAttack = NWNX_Creature_GetTotalEffectBonus(oCreature,
                                          /*bonusType*/NWNX_CREATURE_BONUS_TYPE_ATTACK,
                                          /*target*/OBJECT_INVALID,
                                          /*isElemental*/0,
                                          /*isForceMax*/0,
                                          /*savetype*/-1,
                                          /*saveSpecificType*/-1,
                                          /*skill*/-1,
                                          /*abilityScore*/-1,
                                          /*isOffhand*/FALSE);
    int nTouchAttack = NWNX_Creature_GetTotalEffectBonus(oCreature,
                                          /*bonusType*/NWNX_CREATURE_BONUS_TYPE_TOUCH_ATTACK,
                                          /*target*/OBJECT_INVALID,
                                          /*isElemental*/0,
                                          /*isForceMax*/0,
                                          /*savetype*/-1,
                                          /*saveSpecificType*/-1,
                                          /*skill*/-1,
                                          /*abilityScore*/-1,
                                          /*isOffhand*/FALSE);
    if(nAttack + nTouchAttack > 0)
        sResult += "\nCombat:";
    if(nAttack > 0)
        sResult += "\n" + sTabulation + "Attack: " + IntToString(nAttack);
    if(nTouchAttack > 0)
        sResult += "\n" + sTabulation + "Touch Attack: " + IntToString(nTouchAttack);

    int nAbilitySTR = chat_CreatureReportBonuses_GetAbility(oCreature, ABILITY_STRENGTH);
    int nAbilityDEX = chat_CreatureReportBonuses_GetAbility(oCreature, ABILITY_DEXTERITY);
    int nAbilityCON = chat_CreatureReportBonuses_GetAbility(oCreature, ABILITY_CONSTITUTION);
    int nAbilityINT = chat_CreatureReportBonuses_GetAbility(oCreature, ABILITY_INTELLIGENCE);
    int nAbilityWIS = chat_CreatureReportBonuses_GetAbility(oCreature, ABILITY_WISDOM);
    int nAbilityCHA = chat_CreatureReportBonuses_GetAbility(oCreature, ABILITY_CHARISMA);
    if(nAbilitySTR + nAbilityDEX + nAbilityCON + nAbilityINT + nAbilityWIS + nAbilityCHA)
        sResult += "\nAbilities:";
    if(nAbilitySTR > 0)
        sResult += "\n" + sTabulation + "Strength: " + IntToString(nAbilitySTR);
    if(nAbilityDEX > 0)
        sResult += "\n" + sTabulation + "Dexterity: " + IntToString(nAbilityDEX);
    if(nAbilityCON > 0)
        sResult += "\n" + sTabulation + "Constitution: " + IntToString(nAbilityCON);
    if(nAbilityINT > 0)
        sResult += "\n" + sTabulation + "Intelligence: " + IntToString(nAbilityINT);
    if(nAbilityWIS > 0)
        sResult += "\n" + sTabulation + "Wisdom: " + IntToString(nAbilityWIS);
    if(nAbilityCHA > 0)
        sResult += "\n" + sTabulation + "Charisma: " + IntToString(nAbilityCHA);

    int nFort = chat_CreatureReportBonuses_GetSaves(oCreature, SAVING_THROW_FORT);
    int nRefl = chat_CreatureReportBonuses_GetSaves(oCreature, SAVING_THROW_REFLEX);
    int nWill = chat_CreatureReportBonuses_GetSaves(oCreature, SAVING_THROW_WILL);
    if(nFort + nRefl + nWill)
        sResult += "\nSaves:";
    if(nFort > 0)
        sResult += "\n" + sTabulation + "Fortitude: " + IntToString(nFort);
    if(nRefl > 0)
        sResult += "\n" + sTabulation + "Reflex: " + IntToString(nRefl);
    if(nWill > 0)
        sResult += "\n" + sTabulation + "Will: " + IntToString(nWill);

    int nSkillDisc = chat_CreatureReportBonuses_GetSkills(oCreature, SKILL_DISCIPLINE);
    int nSkillConc = chat_CreatureReportBonuses_GetSkills(oCreature, SKILL_CONCENTRATION);
    int nSkillTaunt = chat_CreatureReportBonuses_GetSkills(oCreature, SKILL_TAUNT);
    int nSkillPerform = chat_CreatureReportBonuses_GetSkills(oCreature, SKILL_PERFORM);
    int nSkillHeal = chat_CreatureReportBonuses_GetSkills(oCreature, SKILL_HEAL);
    int nSkillHide = chat_CreatureReportBonuses_GetSkills(oCreature, SKILL_HIDE);
    int nSkillMove = chat_CreatureReportBonuses_GetSkills(oCreature, SKILL_MOVE_SILENTLY);
    int nSkillSpot = chat_CreatureReportBonuses_GetSkills(oCreature, SKILL_SPOT);
    int nSkillListen = chat_CreatureReportBonuses_GetSkills(oCreature, SKILL_LISTEN);
    int nSkillUMD = chat_CreatureReportBonuses_GetSkills(oCreature, SKILL_USE_MAGIC_DEVICE);

    if(nSkillDisc + nSkillConc + nSkillTaunt + nSkillPerform + nSkillHeal + nSkillHide + nSkillMove + nSkillSpot + nSkillListen + nSkillUMD > 0)
        sResult += "\nSkills:";
    if(nSkillDisc > 0)
        sResult += "\n" + sTabulation + "Discipline: " + IntToString(nSkillDisc);
    if(nSkillConc > 0)
        sResult += "\n" + sTabulation + "Concentration: " + IntToString(nSkillConc);
    if(nSkillTaunt > 0)
        sResult += "\n" + sTabulation + "Taunt: " + IntToString(nSkillTaunt);
    if(nSkillPerform > 0)
        sResult += "\n" + sTabulation + "Perform: " + IntToString(nSkillPerform);
    if(nSkillHeal > 0)
        sResult += "\n" + sTabulation + "Heal: " + IntToString(nSkillHeal);
    if(nSkillHide > 0)
        sResult += "\n" + sTabulation + "Hide: " + IntToString(nSkillHide);
    if(nSkillMove > 0)
        sResult += "\n" + sTabulation + "Move silently: " + IntToString(nSkillMove);
    if(nSkillSpot > 0)
        sResult += "\n" + sTabulation + "Spot: " + IntToString(nSkillSpot);
    if(nSkillListen > 0)
        sResult += "\n" + sTabulation + "Listen: " + IntToString(nSkillListen);
    if(nSkillUMD > 0)
        sResult += "\n" + sTabulation + "UMD: " + IntToString(nSkillUMD);

    return sResult;
}

void chat_SaveShoutMessageIntoDB(int nPlayerID, string sPlayerName, string sMsg)
{
    string sQuery = "INSERT INTO shout (player_id, player_name, msg_text, is_sent) VALUES (?, ?, ?, ?)";
    NWNX_SQL_PrepareQuery(sQuery);
    NWNX_SQL_PreparedInt(0, nPlayerID);
    NWNX_SQL_PreparedString(1, sPlayerName);
    NWNX_SQL_PreparedString(2, sMsg);
    NWNX_SQL_PreparedInt(3, 1);

    int iResult = 0;
    if(NWNX_SQL_ExecutePreparedQuery())
        iResult = db_GetDatabaseLastInsertID();
    if(!iResult)
        WriteLog("Shout message has not been stored.", LOG_LEVEL_ERROR);
}

void chat_InvitePlayerIntoFactionParty(object oPC)
{
    object oFoundPartyLeader;
    int nMaxPartyMemvers = 0;
    object oLoop = GetFirstPC();
    while(GetIsObjectValid(oLoop))
    {
        if(players_GetFactionsEqual(oPC, oLoop) && oPC != oLoop)
        {
            int nCalculatedPartyMembers = 0;
            object oPartyMember = GetFirstFactionMember(oLoop);
            while(GetIsObjectValid(oPartyMember))
            {
                nCalculatedPartyMembers++;
                oPartyMember = GetNextFactionMember(oLoop);
            }
            if(nCalculatedPartyMembers > nMaxPartyMemvers)
            {
                oFoundPartyLeader = oLoop;
                nMaxPartyMemvers = nCalculatedPartyMembers;
            }
        }
        oLoop = GetNextPC();
    }
    if(GetIsObjectValid(oFoundPartyLeader))
        NWNX_Player_SendPartyInvite(oPC, oFoundPartyLeader, TRUE);
}

/*
void chat_ChangePartyLeader(object oPC)
{
    object oPartyLeader = GetFactionLeader(oPC);
    if(oPartyLeader != oPC)
    {
        RemoveFromParty(oPartyLeader);
        AddToParty(oPartyLeader, GetFactionLeader(oPC));
    }
}
*/

void chat_ChangePartyLeader(object oPC)
{
    object oPartyLeader = GetFactionLeader(oPC);
    if(oPartyLeader == oPC)
    {
        SendColorMessageToPC(oPC, "You are already party leader.", TXT_COLOR_RED);
        return;
    }
    RemoveFromParty(oPC);
    int nIter = 1;
    object oPartyMember = GetFirstFactionMember(oPartyLeader);
    while(GetIsObjectValid(oPartyMember))
    {
        if(oPartyMember != oPartyLeader)
        {
            AssignCommand(GetModule(), DelayCommand(0.0, RemoveFromParty(oPartyMember)));
            AssignCommand(GetModule(), DelayCommand(0.5 * nIter, AddToParty(oPartyMember, oPC)));
        }
        nIter++;
        oPartyMember = GetNextFactionMember(oPartyLeader);
    }
    AssignCommand(GetModule(), DelayCommand(0.5 * nIter, AddToParty(oPartyLeader, oPC)));
}

void chat_RunDPSCalculator(object oPC, int nRounds=20)
{
    EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_MAGIC, MOUSECURSOR_NOMAGIC);
    SetLocalInt(oPC, "TARGET_MODE", TARGET_MODE_DPS_CALCULATOR);
    SetLocalInt(oPC, "DPS_CALCULATOR_ON", TRUE);
    SetLocalInt(oPC, "DPS_CALCULATOR_ROUNDS", nRounds + 1);
    // clear non-actual locals
    DeleteLocalInt(oPC, "DPS_CALCULATOR_ROUNDS_DONE");
    DeleteLocalInt(oPC, "DPS_CALCULATOR_FULL_DMG");
    DeleteLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG");
    DeleteLocalInt(oPC, "DPS_CALCULATOR_HIT_COUNT");
    DeleteLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG_MIN");
    DeleteLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG_MAX");
    DeleteLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG");
    DeleteLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_COUNT");
    DeleteLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG_MIN");
    DeleteLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG_MAX");
    DeleteLocalInt(oPC, "DPS_CALCULATOR_MISS_COUNT");
}

void chat_DeleteModuleParameters(object oPC)
{
    if(!GetIsDM(oPC))
        return;
    string sSQL = "select parameter from settings";
    NWNX_SQL_PrepareQuery(sSQL);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            string sParameter = NWNX_SQL_ReadDataInActiveRow();
            string MODULE_SETTING = "MODULE_SETTING_" + GetStringUpperCase(sParameter);
            DeleteLocalString(GetModule(), MODULE_SETTING);
        }
    }
}

string chat_GetItemTypeString(int iInventorySlot)
{
    switch(iInventorySlot)
    {
        case INVENTORY_SLOT_ARMS: return "arms";
        case INVENTORY_SLOT_ARROWS: return "arrs";
        case INVENTORY_SLOT_BELT: return "belt";
        case INVENTORY_SLOT_BOLTS: return "blts";
        case INVENTORY_SLOT_BOOTS: return "boot";
        case INVENTORY_SLOT_BULLETS: return "bull";
        case INVENTORY_SLOT_CARMOUR: return "carm";
        case INVENTORY_SLOT_CHEST: return "armr";
        case INVENTORY_SLOT_CLOAK: return "cape";
        case INVENTORY_SLOT_CWEAPON_B: return "cweb";
        case INVENTORY_SLOT_CWEAPON_L: return "cwel";
        case INVENTORY_SLOT_CWEAPON_R: return "cwer";
        case INVENTORY_SLOT_HEAD: return "head";
        case INVENTORY_SLOT_LEFTHAND: return "hnd1";
        case INVENTORY_SLOT_LEFTRING: return "rng1";
        case INVENTORY_SLOT_NECK: return "neck";
        case INVENTORY_SLOT_RIGHTHAND: return "hnd2";
        case INVENTORY_SLOT_RIGHTRING: return "rng2";
    }
    return "";
}

void chat_UseBardAsYourSlave(object oChater)
{
    SetLocalInt(oChater, "TARGET_MODE", TARGET_MODE_USE_BARD_AS_YOUR_SLAVE);
    EnterTargetingMode(oChater, OBJECT_TYPE_CREATURE, MOUSECURSOR_MAGIC, MOUSECURSOR_NOMAGIC);
}

//void main() {}

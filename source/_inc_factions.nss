#include "_inc_fameshop"
#include "_inc_citykeeper"
#include "_inc_discord_rpt"
#include "_inc_generic"
#include "_inc_bank"

///////////////////////////////////////////////////////////////////
//////////                  Constants                    //////////
///////////////////////////////////////////////////////////////////

// fame transfer constants
const int CONST_NEED_FAME_PC = 3000;
const int CONST_NEED_FAME_FACTION = 15000;
const float CONST_PERCENT_GAIN_FAME = 1.0;  // 100%

// pvp expirience constants
const int lvlXP = 100;
const int lvlUP = 500;

// famestat constants
const int FAME_GAIN_TYPE_UNKNOWN    = 0;
const int FAME_GAIN_TYPE_KILL       = 1;
const int FAME_GAIN_TYPE_ASSIST     = 2;
const int FAME_GAIN_TYPE_PVE        = 3;
const int FAME_GAIN_TYPE_TRANSFER   = 4;
const int FAME_GAIN_TYPE_USELESS    = 5;

// buff zone constants
const string BUFFZONE_TEMPLATE_RESREF   = "area_buffzone";
const string BUFFZONE_AREA_OBJECT       = "BUFFZONE_AREA_OBJECT";
const string BUFFZONE_ENTER_WAYPOINT    = "BUFFZONE_ENTER_WAYPOINT";
const string BUFFZONE_EXIT_TRIGGER      = "BUFFZONE_EXIT_TRIGGER";
const string BUFFZONE_STARGATE_WAYPOINT = "BUFFZONE_STARGATE_WAYPOINT";

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// read base fame from 2da
float factions_GetFameBase(object oPC);

// add fame to oPC
void factions_AddFame(object oPC, int iFame, string sMessage="");

// sum of fame faction1+faction2 etc
int factions_GetTotalFactionsFame();

// returns fame of iFaction
int factions_GetFactionFame(int iFaction);

// add fame to faction
void factions_AddFameToFaction(int iFaction, int iFame);

// store fame event data into DB
void factions_StoreFameEventToDatabase(object oPlayer, object oVictim, int iPlayerLvl, int iVictimLvl, int iTimestamp, string sAreaTag, int nFame, int nFameGainType);

// get total XP boost
int factions_GetTotalXPBoost();

// get faction XP boost
int factions_GetFactionXPBoost(int iFaction);

// gives PvP XP
void factions_GivePvPXP(object oKiller, object oPC);

// get killer and victim levels diff
int factions_GetLevelDifference(object oKiller, object oPC);

// counts loot from table by conditions where columns (looter_id or last_equipped_by or last_acquired_by) in iFaction
int factions_CountLootFromTableByConditions(string sTable, string sByColumn, int iFaction);

// counts all loot from table, if bAcquired = TRUE count only not lost items
int factions_CountAllLootFromTable(string sTable, int bAcquired = TRUE);

// give pvp fame reward for party
void factions_GiveKillsAndAssistsReward(object oKiller, object oVictim);

// give PVE reward to player's party
void factions_GivePVEReward(object oKiller, int nFame, float fRandomLow = 0.0, float fRandomUp = 0.0);

// set sqlocal int where value=reward_coeff and var_name=victim's_uuid and return sum of reward coefficient
// for calculating fame per 1 reward_coeff
int faction_MarkAndCalculatePartyPTS(object oKiller, object oVictim, object oKillerArea, int KILLER_REWARD_COEFFICIENT, int ASSIST_REWARD_COEFFICIENT, int USELESS_REWARD_COEFFICIENT, int nAssistLifeTime = 18 /* sec */);

// get personal faction XP bonus
int factions_GetFactionXPBonus(int iFaction);

// set personal faction XP bonus
void factions_SetFactionXPBonus(int iFaction, int iValue);

// get faction buffer level
int factions_GetFactionBufferLevel(int iFaction);

// set faction buffer level
void factions_SetFactionBufferLevel(int iFaction, int iValue);

// get faction fameshop buffer DC bonus vs dispel
int factions_GetFactionBufferBonusDC(int iFaction);

// set faction fameshop buffer DC bonus vs dispel
void factions_SetFactionBufferBonusDC(int iFaction, int iValue);

// get faction fameshop buffer perform skill
int factions_GetFactionBufferPerformSkill(int iFaction);

// set faction fameshop buffer perform skill
void factions_SetFactionBufferPerformSkill(int iFaction, int iValue);

// get faction fameshop buffer song grade level
int factions_GetFactionBufferSongUpgradeLevel(int iFaction);

// set faction fameshop buffer song grade level
void factions_SetFactionBufferSongUpgradeLevel(int iFaction, int iValue);

// return TRUE and open portal if money successfully taken from PC
int factions_TryToActivateStargate(object oPC, object oStargate, int nCost);

// return activated stargates number for iFaction
int factions_GetFactionActiveStargates(int iFaction);

// set activated stargates number for iFaction
void factions_SetFactionActiveStargates(int iFaction, int iValue);

// create nFaction buff zone area if not exists
object factions_CreateFactionBuffzone(int nFaction);

// return cleric ResRef for nFaction
string factions_GetFactionClericResref(int nFaction);

// create faction Cleric
void factions_CreateFactionCleric(string sResRef, location lLoc);

// get faction guards level
int factions_GetFactionGuardsLevel(int iFaction);

// set faction guards level
void factions_SetFactionGuardsLevel(int iFaction, int iValue);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

float factions_GetFameBase(object oPC)
{
    return StringToFloat(Get2DAString("srv_fame_coeff", "Value", GetHitDice(oPC)));
}

void factions_AddFame(object oPC, int iFame, string sMessage="")
{
    string sFloatingFameMessage = "+" + IntToString(iFame) + " FP";
    if (sMessage != "")
        sFloatingFameMessage+=", " + sMessage;
    SetTotalFame(GetPCPlayerName(oPC), GetTotalFame(GetPCPlayerName(oPC)) + iFame);
    FloatingColorTextStringOnCreature(sFloatingFameMessage, TXT_COLOR_RED, oPC);
    SendMessageToPC(oPC, "You got " + IntToString(iFame)+ " FP.");
    WriteLog("Player " + GetName(oPC) + "(" + GetPCPlayerName(oPC) + ") get " + IntToString(iFame) + " fame points.");
}

int factions_GetTotalFactionsFame()
{
    return factions_GetFactionFame(FACTION_EMPIRE)      + factions_GetFactionFame(FACTION_UNDERDARK) +
           factions_GetFactionFame(FACTION_IRON_THRONE) + factions_GetFactionFame(FACTION_DRAGON_CULT);
}

int factions_GetFactionFame(int nFaction)
{
    object oFactionCashObject = players_GetFactionSystemNPC(nFaction);
    int nFactionFame = GetLocalInt(oFactionCashObject, "FACTION_FAME");
    if(nFactionFame > 0)
        return nFactionFame;

    string sSQL = "SELECT fame FROM factions WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, nFaction);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nFactionFame = StringToInt(NWNX_SQL_ReadDataInActiveRow());
        SetLocalInt(oFactionCashObject, "FACTION_FAME", nFactionFame);
        return nFactionFame;
    }
    else
        return 0;
}

void factions_AddFameToFaction(int nFaction, int iFame)
{
    object oFactionCashObject = players_GetFactionSystemNPC(nFaction);
    DeleteLocalInt(oFactionCashObject, "FACTION_FAME");
    string sSQL = "UPDATE factions SET fame = fame + ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iFame);
    NWNX_SQL_PreparedInt(1, nFaction);
    NWNX_SQL_ExecutePreparedQuery();
}

void factions_StoreFameEventToDatabase(object oPlayer, object oVictim, int iPlayerLvl, int iVictimLvl,
                                       int iTimestamp, string sAreaTag, int nFame, int nFameGainType)
{
    int iPlayerID = players_GetPCPersistentID(oPlayer);
    int iVictimID = players_GetPCPersistentID(oVictim);
    // clear cashed values
    if(nFameGainType != FAME_GAIN_TYPE_TRANSFER)
    {
        // clear cashed value, used for print kills/assists stat and PvP account fame
        string FAMESTAT_PLAYER_VAR = "FAMESTAT_PLAYER_ID_" + IntToString(iPlayerID) + "_EVENT_" + IntToString(nFameGainType);
        DeleteLocalInt(oPlayer, FAMESTAT_PLAYER_VAR);
        string PVP_FAME_VAR = "PVP_FAME_ACCOUNT_" + GetStringUpperCase(GetPCPlayerName(oPlayer));
        DeleteLocalInt(oPlayer, PVP_FAME_VAR);
        // clear cashed values for factions KDA stat
        object oPlayerFactionCashObject = players_GetFactionSystemNPC(players_GetFaction(oPlayer));
        DeleteLocalJson(oPlayerFactionCashObject, "FACTION_STATISTICS");
        object oVictimFactionCashObject = players_GetFactionSystemNPC(players_GetFaction(oVictim));
        DeleteLocalJson(oVictimFactionCashObject, "FACTION_STATISTICS");
        // clear top10 cash
        DeleteLocalJson(GetModule(), "TOP_STAT");
    }
    // insert data into DB
    string sSQL = "INSERT INTO famestat (player_id, victim_id, player_lvl, victim_lvl, timestamp, area_tag, fame, event_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_PreparedInt(1, iVictimID);
    NWNX_SQL_PreparedInt(2, iPlayerLvl);
    NWNX_SQL_PreparedInt(3, iVictimLvl);
    NWNX_SQL_PreparedInt(4, iTimestamp);
    NWNX_SQL_PreparedString(5, sAreaTag);
    NWNX_SQL_PreparedInt(6, nFame);
    NWNX_SQL_PreparedInt(7, nFameGainType);
    if(!NWNX_SQL_ExecutePreparedQuery())
        WriteLog("Function factions_StoreFameEventToDatabase(...) generates error. SQL query executed unsuccessfully.", LOG_LEVEL_ERROR);
}

int factions_GetTotalXPBoost()
{
    int iPercent = factions_GetTotalFactionsFame()/5000;
    return iPercent <= 150 ? iPercent : 150;
}

int factions_GetFactionXPBoost(int iFaction)
{
    int iFactionXPLevel = factions_GetFactionXPBonus(iFaction);
    return iFactionXPLevel*10;
}

void factions_GivePvPXP(object oKiller, object oPC)
{
    if(!players_GetFactionsEqual(oKiller, oPC) && factions_GetLevelDifference(oKiller, oPC) >= 0)
    {
        int iXP = GetHitDice(oPC)*lvlXP + lvlUP*factions_GetLevelDifference(oKiller, oPC);
        SendColorMessageToPC(oKiller, "PvP experience: " + IntToString(iXP), TXT_COLOR_WHITE_T);
        GiveXPToCreature(oKiller, iXP);
    }
}

int factions_GetLevelDifference(object oKiller, object oPC)
{
    return GetHitDice(oPC) - GetHitDice(oKiller);
}

int factions_CountLootFromTableByConditions(string sTable, string sByColumn, int iFaction)
{
    json jCash = GetLocalJson(GetModule(), "LOOT_STAT");
    string sKey = GetStringUpperCase(sTable) + "_" + GetStringUpperCase(sByColumn) + "_" + IntToString(iFaction);
    if(JsonObjectGet(jCash, sKey) != JSON_NULL)
        return JsonGetInt(JsonObjectGet(jCash, sKey));
    else if(jCash == JSON_NULL)
        jCash = JSON_OBJECT;
    int iResult = 0;
    string sSQL = "SELECT COUNT(*) FROM " + sTable + " WHERE " + sByColumn + " IN (SELECT id FROM characters WHERE faction = ?)";
    NWNX_SQL_PrepareQuery(sSQL); NWNX_SQL_PreparedInt(0, iFaction); NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iResult = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    jCash = JsonObjectSet(jCash, sKey, JsonInt(iResult));
    SetLocalJson(GetModule(), "LOOT_STAT", jCash);
    return iResult;
}

int factions_CountAllLootFromTable(string sTable, int bAcquired = TRUE)
{
    int iResult = 0;
    string sSQL = "SELECT COUNT(*) FROM " + sTable;
    if (bAcquired)
        sSQL += " WHERE last_acquired_by > 0";
    NWNX_SQL_ExecuteQuery(sSQL);
    if (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iResult = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    return iResult;
}

void factions_GiveKillsAndAssistsReward(object oKiller, object oVictim)
{
    // settings
    int KILLER_REWARD_COEFFICIENT  = 4;
    int ASSIST_REWARD_COEFFICIENT  = 3;
    int USELESS_REWARD_COEFFICIENT = 2;
    // end settings

    object oKillerArea = GetArea(oKiller);
    if(!GetIsObjectValid(oKillerArea))
    {
        oKillerArea = GetAreaFromLocation(GetLocalLocation(oKiller, "sm_location"));
        if (!GetIsObjectValid(oKillerArea))
            oKillerArea = GetAreaFromLocation(GetLocalLocation(oKiller, "LAST_PLAYER_LOCATION"));
    }

    // calculate party PTS
    int nTotalPartyPTS = faction_MarkAndCalculatePartyPTS(oKiller, oVictim, oKillerArea, KILLER_REWARD_COEFFICIENT, ASSIST_REWARD_COEFFICIENT, USELESS_REWARD_COEFFICIENT);
    // no PTS - no fame
    if (nTotalPartyPTS <= 0)
        return;

    // calculate fame total fame for kill
    int nFameTotal = FloatToInt(factions_GetFameBase(oVictim) * db_GetModuleFameCoefficient());
    int bFirstBlood = GetLocalInt(GetModule(), "FIRST_BLOOD_DONE");
    if(!bFirstBlood)
    {
        SetLocalInt(GetModule(), "FIRST_BLOOD_DONE", TRUE);
        generic_PlayAudioStreamForAllPlayers("mus_firstblood");
        nFameTotal = nFameTotal * 2;
    }

    int iVictimFactionFame = factions_GetFactionFame(players_GetFaction(oVictim));
    int iKillerFactionFame = factions_GetFactionFame(players_GetFaction(oKiller));

    iVictimFactionFame = iVictimFactionFame > 0 ? iVictimFactionFame : 1; // prevent division by zero
    iKillerFactionFame = iKillerFactionFame > 0 ? iKillerFactionFame : 1; // prevent division by zero

    float fBalanceCoeff = IntToFloat(iVictimFactionFame)/IntToFloat(iKillerFactionFame);
    fBalanceCoeff = fBalanceCoeff < 1.0 ? 1.0 : fBalanceCoeff;
    fBalanceCoeff = fBalanceCoeff > 1.5 ? 1.5 : fBalanceCoeff;

    float fFameTotal = IntToFloat(nFameTotal) * fBalanceCoeff;
    nFameTotal = FloatToInt(fFameTotal);
    // end calculate fame total fame for kill

    // give fame to killer's party
    float fOnePtsCost = fFameTotal/IntToFloat(nTotalPartyPTS);
    int nFameGainersCount = 0;
    string sVictimUUID = GetObjectUUID(oVictim);

    object oPartyMember = GetFirstFactionMember(oKiller, TRUE);
    while(GetIsObjectValid(oPartyMember))
    {
        int nPartyMemberRewardCoeff = (SQLocals_GetInt(oPartyMember, sVictimUUID) &&
                                       SQLite_GetTimeStamp() - SQLocals_GetLastUpdated_UnixEpoch(oPartyMember, sVictimUUID, SQLOCALS_TYPE_INT) <= 1) ?
                                       SQLocals_GetInt(oPartyMember, sVictimUUID) : 0;

        int nFameReward = FloatToInt(IntToFloat(nPartyMemberRewardCoeff) * fOnePtsCost);
        string sRewardType;

        if (nPartyMemberRewardCoeff == KILLER_REWARD_COEFFICIENT)
        {
            sRewardType = "Kill";
            nFameGainersCount++;
            factions_StoreFameEventToDatabase(oPartyMember, oVictim, GetHitDice(oPartyMember), GetHitDice(oVictim),
                                              SQLite_GetTimeStamp(), GetTag(oKillerArea), nFameReward, FAME_GAIN_TYPE_KILL);
        }
        else if (nPartyMemberRewardCoeff == ASSIST_REWARD_COEFFICIENT)
        {
            sRewardType = "Assist";
            nFameGainersCount++;
            factions_StoreFameEventToDatabase(oPartyMember, oVictim, GetHitDice(oPartyMember), GetHitDice(oVictim),
                                              SQLite_GetTimeStamp(), GetTag(oKillerArea), nFameReward, FAME_GAIN_TYPE_ASSIST);
        }
        else if (nPartyMemberRewardCoeff == USELESS_REWARD_COEFFICIENT)
        {
            sRewardType = "Useless";
            nFameGainersCount++;
            factions_StoreFameEventToDatabase(oPartyMember, oVictim, GetHitDice(oPartyMember), GetHitDice(oVictim),
                                              SQLite_GetTimeStamp(), GetTag(oKillerArea), nFameReward, FAME_GAIN_TYPE_USELESS);
        }
        if (nFameReward > 0)
            factions_AddFame(oPartyMember, nFameReward, sRewardType);

        oPartyMember = GetNextFactionMember(oKiller, TRUE);
    }
    if(nFameTotal > 0)
    {
        // add faction fame
        factions_AddFameToFaction(players_GetFaction(oKiller), nFameTotal);
        //webhook message
        string sAreaName = GetName(oKillerArea);
        ReportPlayerKillToDiscord(oKiller, oVictim, players_GetFaction(oKiller), players_GetFaction(oVictim),  sAreaName, nFameTotal, nFameGainersCount);
        ReportPlayerKillToTelegram(oKiller, oVictim, players_GetFaction(oKiller), players_GetFaction(oVictim), sAreaName, nFameTotal, nFameGainersCount);
        //webhook message end
    }
}

void factions_GivePVEReward(object oKiller, int nFame, float fRandomLow = 0.0, float fRandomUp = 0.0)
{
    // calculate random fame value in fRandomLow .. fRandomUp range
    if (fRandomLow > 0.0 && fRandomUp > 0.0 && fRandomUp > fRandomLow)
    {
        nFame = FloatToInt(IntToFloat(nFame)*fRandomLow + IntToFloat(Random(FloatToInt((fRandomUp - fRandomLow)*100))*nFame)/100.0);
    }

    int nFameReward = FloatToInt(IntToFloat(nFame) * db_GetModuleFameCoefficient()/IntToFloat(GetPartySizeInSameArea(oKiller)));

    object oKillerArea = GetArea(oKiller);
    object oPartyMember = GetFirstFactionMember(oKiller, TRUE);
    while(GetIsObjectValid(oPartyMember))
    {
        if (oKillerArea == GetArea(oPartyMember))
        {
            if (nFameReward > 0)
                factions_AddFame(oPartyMember, nFameReward);
            factions_StoreFameEventToDatabase(oPartyMember, OBJECT_INVALID, GetHitDice(oPartyMember), 0,
                                              SQLite_GetTimeStamp(), GetTag(oKillerArea), nFameReward, FAME_GAIN_TYPE_PVE);
        }
        oPartyMember = GetNextFactionMember(oKiller, TRUE);
    }
    // add faction fame
    factions_AddFameToFaction(players_GetFaction(oKiller), nFame);
}

int faction_MarkAndCalculatePartyPTS(object oKiller, object oVictim, object oKillerArea, int KILLER_REWARD_COEFFICIENT, int ASSIST_REWARD_COEFFICIENT,
                                     int USELESS_REWARD_COEFFICIENT, int nAssistLifeTime = 18 /* sec */)
{
    int nResult = 0;
    string sVictimUUID = GetObjectUUID(oVictim);

    int iAreaFaction = players_GetFaction(oKillerArea);
    int bIsEnemyArea = (iAreaFaction != FACTION_UNKNOWN && iAreaFaction != players_GetFaction(oVictim));

    // return 0 PTS for party if victim_lvl - killer_lvl < -5
    if (factions_GetLevelDifference(oKiller, oVictim) < -5 && !bIsEnemyArea)
        return 0;

    object oPartyMember = GetFirstFactionMember(oKiller);
    while (GetIsObjectValid(oPartyMember))
    {
        // set PTS only if party_member_lvl - victim_lvl < 5
        if ((factions_GetLevelDifference(oPartyMember, oVictim) >= -5 || bIsEnemyArea))
        {
            string sPartyMemberUUID = GetObjectUUID(oPartyMember);
            if (oPartyMember == oKiller)
            {
                SQLocals_SetInt(oPartyMember, sVictimUUID, KILLER_REWARD_COEFFICIENT);
                nResult += KILLER_REWARD_COEFFICIENT;
            }
            else if ( (Array_Contains_Str("SUPPORT_ACTORS_LIST", sPartyMemberUUID, oKiller) &&
                       SQLite_GetTimeStamp() - SQLocals_GetLastUpdated_UnixEpoch(oKiller, sPartyMemberUUID, SQLOCALS_TYPE_INT) <= nAssistLifeTime) ||
                      (Array_Contains_Str("HOSTILE_ACTORS_LIST", sPartyMemberUUID, oVictim) &&
                       SQLite_GetTimeStamp() - SQLocals_GetLastUpdated_UnixEpoch(oVictim, sPartyMemberUUID, SQLOCALS_TYPE_INT) <= nAssistLifeTime)
                    )
            {
                SQLocals_SetInt(oPartyMember, sVictimUUID, ASSIST_REWARD_COEFFICIENT);
                nResult += ASSIST_REWARD_COEFFICIENT;
            }
            else if (oKillerArea == GetArea(oPartyMember))
            {
                SQLocals_SetInt(oPartyMember, sVictimUUID, USELESS_REWARD_COEFFICIENT);
                nResult += USELESS_REWARD_COEFFICIENT;
            }
        }
        oPartyMember = GetNextFactionMember(oKiller);
    }
    return nResult;
}

int factions_GetFactionXPBonus(int iFaction)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    int nFactionXPBonus = GetLocalInt(oFactionCashObject, "FACTION_XP_BONUS");
    if(nFactionXPBonus > 0)
        return nFactionXPBonus - 1;

    string sSQL = "SELECT faction_experience_lvl FROM factions WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iFaction);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nFactionXPBonus = StringToInt(NWNX_SQL_ReadDataInActiveRow()) + 1;
        SetLocalInt(oFactionCashObject, "FACTION_XP_BONUS", nFactionXPBonus);
        return nFactionXPBonus - 1;
    }
    return 0;
}

void factions_SetFactionXPBonus(int iFaction, int iValue)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    DeleteLocalInt(oFactionCashObject, "FACTION_XP_BONUS");
    string sSQL = "UPDATE factions SET faction_experience_lvl = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedInt(1, iFaction);
    NWNX_SQL_ExecutePreparedQuery();
}

int factions_GetFactionBufferLevel(int iFaction)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    int nBufferLevel = GetLocalInt(oFactionCashObject, "BUFFER_LEVEL");
    if(nBufferLevel > 0)
        return nBufferLevel;

    string sSQL = "SELECT faction_buffer_caster_lvl FROM factions WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iFaction);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nBufferLevel = StringToInt(NWNX_SQL_ReadDataInActiveRow());
        SetLocalInt(oFactionCashObject, "BUFFER_LEVEL", nBufferLevel);
        return nBufferLevel;
    }
    return 0;
}

void factions_SetFactionBufferLevel(int iFaction, int iValue)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    DeleteLocalInt(oFactionCashObject, "BUFFER_LEVEL");
    string sSQL = "UPDATE factions SET faction_buffer_caster_lvl = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedInt(1, iFaction);
    NWNX_SQL_ExecutePreparedQuery();
}

int factions_GetFactionBufferBonusDC(int iFaction)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    int nBufferBonusDC = GetLocalInt(oFactionCashObject, "BUFFER_BONUS_DC");
    if(nBufferBonusDC > 0)
        return nBufferBonusDC - 1;

    string sSQL = "SELECT faction_buffer_bonus_dc FROM factions WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iFaction);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nBufferBonusDC = StringToInt(NWNX_SQL_ReadDataInActiveRow()) + 1;
        SetLocalInt(oFactionCashObject, "BUFFER_BONUS_DC", nBufferBonusDC);
        return nBufferBonusDC - 1;
    }
    return 0;
}

void factions_SetFactionBufferBonusDC(int iFaction, int iValue)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    DeleteLocalInt(oFactionCashObject, "BUFFER_BONUS_DC");
    string sSQL = "UPDATE factions SET faction_buffer_bonus_dc = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedInt(1, iFaction);
    NWNX_SQL_ExecutePreparedQuery();
}

int factions_GetFactionBufferPerformSkill(int iFaction)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    int nBufferPerformSkill = GetLocalInt(oFactionCashObject, "BUFFER_PERFORM_SKILL");
    if(nBufferPerformSkill > 0)
        return nBufferPerformSkill - 1;

    string sSQL = "SELECT faction_buffer_perform_skill FROM factions WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iFaction);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nBufferPerformSkill = StringToInt(NWNX_SQL_ReadDataInActiveRow()) + 1;
        SetLocalInt(oFactionCashObject, "BUFFER_PERFORM_SKILL", nBufferPerformSkill);
        return nBufferPerformSkill - 1;

    }
    return 0;
}

void factions_SetFactionBufferPerformSkill(int iFaction, int iValue)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    DeleteLocalInt(oFactionCashObject, "BUFFER_PERFORM_SKILL");
    string sSQL = "UPDATE factions SET faction_buffer_perform_skill = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedInt(1, iFaction);
    NWNX_SQL_ExecutePreparedQuery();
}

int factions_GetFactionBufferSongUpgradeLevel(int iFaction)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    int nBufferSongUpgradeLevel = GetLocalInt(oFactionCashObject, "BUFFER_SONG_UPGRADE_LEVEL");
    if(nBufferSongUpgradeLevel > 0)
        return nBufferSongUpgradeLevel - 1;

    string sSQL = "SELECT faction_buffer_song_upgrade FROM factions WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iFaction);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nBufferSongUpgradeLevel = StringToInt(NWNX_SQL_ReadDataInActiveRow()) + 1;
        SetLocalInt(oFactionCashObject, "BUFFER_SONG_UPGRADE_LEVEL", nBufferSongUpgradeLevel);
        return nBufferSongUpgradeLevel - 1;
    }
    return 0;
}

void factions_SetFactionBufferSongUpgradeLevel(int iFaction, int iValue)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    DeleteLocalInt(oFactionCashObject, "BUFFER_SONG_UPGRADE_LEVEL");
    string sSQL = "UPDATE factions SET faction_buffer_song_upgrade = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedInt(1, iFaction);
    NWNX_SQL_ExecutePreparedQuery();
}

int factions_TryToActivateStargate(object oPC, object oStargate, int nCost)
{
    int bSuccess = FALSE;
    if(GetGold(oPC) >= nCost)
    {
        TakeGoldFromCreature(nCost, oPC, TRUE);
        bSuccess = TRUE;
    }
    else if(bank_GetAccountBalance(oPC) >= nCost)
    {
        bank_DecrementAccountBalance(oPC, nCost);
        bSuccess = TRUE;
    }
    if(!bSuccess)
        SendColorMessageToPC(oPC, "Not enough gold.", TXT_COLOR_WHITE);
    return bSuccess;
}

int factions_GetFactionActiveStargates(int iFaction)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    int nActiveStargates = GetLocalInt(oFactionCashObject, "FACTION_ACTIVE_STARGATES");
    if(nActiveStargates > 0)
        return nActiveStargates - 1;

    string sSQL = "SELECT active_stargates FROM factions WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iFaction);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nActiveStargates = StringToInt(NWNX_SQL_ReadDataInActiveRow()) + 1;
        SetLocalInt(oFactionCashObject, "FACTION_ACTIVE_STARGATES", nActiveStargates);
        return nActiveStargates - 1;
    }
    return 0;
}

void factions_SetFactionActiveStargates(int iFaction, int iValue)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    DeleteLocalInt(oFactionCashObject, "FACTION_ACTIVE_STARGATES");
    string sSQL = "UPDATE factions SET active_stargates = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedInt(1, iFaction);
    NWNX_SQL_ExecutePreparedQuery();
}

object factions_CreateFactionBuffzone(int nFaction)
{
    object oCash = players_GetFactionSystemNPC(nFaction);
    // create buffzone area and set as local object
    object oBuffZoneArea = CreateArea(BUFFZONE_TEMPLATE_RESREF,
                           BUFFZONE_TEMPLATE_RESREF + "_faction_" + IntToString(nFaction),
                           " * Buffzone of " + players_GetFactionName(nFaction, FALSE) + " *");
    SetLocalObject(oCash, BUFFZONE_AREA_OBJECT, oBuffZoneArea);
    // set local vars
    players_SetFaction(oBuffZoneArea, nFaction);   // set faction
    SetLocalInt(oBuffZoneArea, "bProtectedByKeeper", TRUE); // set city keeper defence
    // set tag for entrance WP/create clerics/
    object oLoop = GetFirstObjectInArea(oBuffZoneArea, OBJECT_TYPE_WAYPOINT | OBJECT_TYPE_TRIGGER);
    string sClericResref = factions_GetFactionClericResref(nFaction);
    while(GetIsObjectValid(oLoop))
    {
        if(GetTag(oLoop) == "WP_buffzone_enter")
            SetLocalObject(oCash, BUFFZONE_ENTER_WAYPOINT, oLoop);
        else if(GetTag(oLoop) == "WP_clr_anchor")
            DelayCommand(0.0, factions_CreateFactionCleric(sClericResref, GetLocation(oLoop)));
        else if(GetTag(oLoop) == "trigger_buffzone_exit")
        {
            SetLocalObject(oCash, BUFFZONE_EXIT_TRIGGER, oLoop);
            SetTransitionTarget(oLoop, players_GetFactionEntryPoint(nFaction));
        }
        if(GetTag(oLoop) == "WP_startgate_exit_faction")
        {
            SetLocalObject(oCash, BUFFZONE_STARGATE_WAYPOINT, oLoop);
            SetLocalInt(oLoop, "WAYPOYNT_EXIT_TYPE", 1 /* buffzone */);
        }
        oLoop = GetNextObjectInArea(oBuffZoneArea, OBJECT_TYPE_WAYPOINT | OBJECT_TYPE_TRIGGER);
    }
    return oBuffZoneArea;
}

string factions_GetFactionClericResref(int nFaction)
{
    switch(nFaction)
    {
        case FACTION_EMPIRE:      return "cr_empire_clr";
        case FACTION_UNDERDARK:   return "cr_kulg_clr";
        case FACTION_IRON_THRONE: return "cr_reno_clr";
        case FACTION_DRAGON_CULT: return "cr_dragon_clr";
    }
    return "";
}

void factions_CreateFactionCleric(string sResRef, location lLoc)
{
    CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc);
}

int factions_GetFactionGuardsLevel(int iFaction)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    int nFactionGuardsLevel = GetLocalInt(oFactionCashObject, "FACTION_GUARDS_LEVEL");
    if(nFactionGuardsLevel > 0)
        return nFactionGuardsLevel - 1;

    string sSQL = "SELECT faction_guards_level FROM factions WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iFaction);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nFactionGuardsLevel = StringToInt(NWNX_SQL_ReadDataInActiveRow()) + 1;
        SetLocalInt(oFactionCashObject, "FACTION_GUARDS_LEVEL", nFactionGuardsLevel);
        return nFactionGuardsLevel - 1;
    }
    return 0;
}

void factions_SetFactionGuardsLevel(int iFaction, int iValue)
{
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    DeleteLocalInt(oFactionCashObject, "FACTION_GUARDS_LEVEL");
    string sSQL = "UPDATE factions SET faction_guards_level = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedInt(1, iFaction);
    NWNX_SQL_ExecutePreparedQuery();
}

//void main() {}


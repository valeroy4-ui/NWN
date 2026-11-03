#include "_inc_players"
#include "nwnx_sql"

// module settings constants

const string MODULE_SETTING_DEBUG_MAX_ALLOWED_CLASS_LEVEL = "debug_max_allowed_class_level";
const string MODULE_SETTING_EXPERIENCE_MULTIPLIER = "experience_multiplier";
const string MODULE_SETTING_ENABLE_CDKEY_CHECK = "enable_key_check";
const string MODULE_SETTING_ENABLE_ITEM_DROP = "enable_loot_drop";
const string MODULE_SETTING_ENABLE_SHOUT_CHANNEL = "enable_shout";

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////


// set total deaths for iPlayerID
int db_GetPlayerTotalDeaths(int iPlayerID);

// get total deaths for iPlayerID
void db_SetPlayerTotalDeaths(int iPlayerID);

// get module parameter
string db_GetModuleParameter(string sParameter);

// set module parameter
void db_SetModuleParameter(string sParameter, string sValue);

// set CDKey check mode 1/0 (on/off)
void db_SetCdKeyCheckMode(int iStatus);

// get CDKey check mode 1/0 (on/off)
int db_GetCdKeyCheckMode();

// add iValue XP into DB for oPartyMember
void db_AddDBXP(object oPartyMember, int iValue);

// get module XP coeff (1.0 is base)
float db_GetModuleExpCoefficient();

// get module FAME coeff (1.0 is base)
float db_GetModuleFameCoefficient();

// get saved VFX for player account name
int db_GetVFX(string sPCPlayerName);

// set saved VFX for player account name
void db_SetVFX(string sPCPlayerName, int iValue);

// get last inserted database ID
int db_GetDatabaseLastInsertID();

// return server name in HH:MM format (ex. 23:15)
string db_GetCurrentServerTime();

// returns TRUE if current time is server's primetime
int db_GetIsPrimeTime();

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int db_GetPlayerTotalDeaths(int iPlayerID)
{
    string sSQL = "SELECT totaldeaths FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
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

void db_SetPlayerTotalDeaths(int iPlayerID)
{
    string sSQL = "UPDATE characters SET totaldeaths = totaldeaths + 1 WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
}

string db_GetModuleParameter(string sParameter)
{
    string MODULE_SETTING = "MODULE_SETTING_" + GetStringUpperCase(sParameter);
    string sResult = GetLocalString(GetModule(), MODULE_SETTING);
    if(sResult != "")
        return sResult;

    string sSQL = "SELECT val FROM settings WHERE parameter = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sParameter);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sResult = NWNX_SQL_ReadDataInActiveRow();
        SetLocalString(GetModule(), MODULE_SETTING, sResult);
    }

    return sResult;
}

void db_SetModuleParameter(string sParameter, string sValue)
{
    string sSQL = "UPDATE settings SET val = ? WHERE parameter = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sValue);
    NWNX_SQL_PreparedString(1, sParameter);
    NWNX_SQL_ExecutePreparedQuery();
}

void db_SetCdKeyCheckMode(int iStatus)
{
    db_SetModuleParameter("enable_key_check", IntToString(iStatus));
}

int db_GetCdKeyCheckMode()
{
    return StringToInt(db_GetModuleParameter("enable_key_check"));
}

void db_AddDBXP(object oPartyMember, int iValue)
{
    string sSQL = "UPDATE characters SET experience = experience + ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedInt(1, players_GetPCPersistentID(oPartyMember));
    NWNX_SQL_ExecutePreparedQuery();
    players_UpdateXpBar(oPartyMember);
}

float db_GetModuleExpCoefficient()
{
    return StringToFloat(db_GetModuleParameter("experience_multiplier"));
}

float db_GetModuleFameCoefficient()
{
    return StringToFloat(db_GetModuleParameter("fame_multiplier"));
}

int db_GetVFX(string sPCPlayerName)
{
    if(NWNX_SQL_ExecuteQuery("SELECT vfx FROM players WHERE name='"+sPCPlayerName+"'") && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    return FALSE;
}

void db_SetVFX(string sPCPlayerName, int iValue)
{
    string sSQL = "UPDATE players SET vfx = ? WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedString(1, sPCPlayerName);
    NWNX_SQL_ExecutePreparedQuery();
}

int db_GetDatabaseLastInsertID()
{
    int iResult;
    if(NWNX_SQL_ExecuteQuery("SELECT LAST_INSERT_ID()") && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iResult = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    return iResult;
}

string db_GetCurrentServerTime()
{
    int iCurrentHour   = GetLocalInt(GetModule(), SERVER_HOUR);
    int iCurrentMinute = GetLocalInt(GetModule(), SERVER_MINUTE);
    return IntToString(iCurrentHour) + ":" + IntToString(iCurrentMinute);
}

int db_GetIsPrimeTime()
{
    int nHour    = GetLocalInt(GetModule(), SERVER_HOUR);
    int nMinute  = GetLocalInt(GetModule(), SERVER_MINUTE);
    int nWeekday = GetLocalInt(GetModule(), SERVER_WEEKDAY);
    if     (nWeekday <  5 && nHour >= 21)
        return TRUE;
    else if(nWeekday >= 5 && (nHour >= 19 || nHour < 2))
        return TRUE;
    return FALSE;
}

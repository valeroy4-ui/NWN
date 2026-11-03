#include "_inc_players"
#include "nwnx_util"
#include "nwnx_sql"
#include "_inc_sqlite_time"

void RecordDatabaseBossKill(string sKiller, string sBossName, int iFaction, int iPlayerID)
{
    string sSQL = "INSERT INTO boss (name, faction, killer_id, killer_name) VALUES (?, ?, ?, ?)";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sBossName);
    NWNX_SQL_PreparedInt(1, iFaction);
    NWNX_SQL_PreparedInt(2, iPlayerID);
    NWNX_SQL_PreparedString(3, NWNX_Util_StripColors(sKiller));
    NWNX_SQL_ExecutePreparedQuery();
}

void SendAllPC()
{
    object oVictim = OBJECT_SELF;
    object oPC = GetFirstPC();
    object oKiller = GetLastKiller();
    if(!GetIsPC(oKiller)) return;
    while(GetIsObjectValid(oPC))
    {
        FloatingColorTextStringOnCreature(GetName(oVictim) + " has been killed by " + players_GetFactionColor(players_GetFaction(oKiller))
        + NWNX_Util_StripColors(GetName(oKiller)) + TXT_COLOR_END, TXT_COLOR_GREEN_L, oPC);
        oPC = GetNextPC();
    }
}

void main()
{
    int iPlayerID;
    object oKiller = GetLastKiller();
    string sBossName = GetName(OBJECT_SELF);
    string sKillerName = GetName(oKiller);
    if(!GetIsPC(oKiller)) oKiller = GetMaster(oKiller);
    if(GetIsPC(oKiller) && !GetIsDM(oKiller)) iPlayerID = players_GetPCPersistentID(oKiller);
    if(iPlayerID > 0) RecordDatabaseBossKill(sKillerName, sBossName, players_GetFaction(oKiller), iPlayerID);
    SendAllPC();

    ExecuteScript("nw_c2_default7", OBJECT_SELF);
}


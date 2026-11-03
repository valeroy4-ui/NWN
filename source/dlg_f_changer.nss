//#include "_inc_constants"
#include "_inc_players"

void main()
{
    int nFaction = StringToInt(GetScriptParam("CHOSEN_FACTION"));
    if(!nFaction)
        return;

    object oPC = GetLastSpeaker();
    int nPlayerID = players_GetPCPersistentID(oPC);

    string sQuery = "UPDATE characters SET faction = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sQuery);
    NWNX_SQL_PreparedInt(0, nFaction);
    NWNX_SQL_PreparedInt(1, nPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    BootPC(oPC);
}

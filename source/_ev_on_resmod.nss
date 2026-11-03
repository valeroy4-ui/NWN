#include "nwnx_events"
#include "_inc_generic"

const string DISCORD_TRIGGER_RESREF = "_discord_";

void main()
{
    if (NWNX_Events_GetCurrentEvent() == NWNX_ON_RESOURCE_MODIFIED)
    {
        //
        string sResref = NWNX_Events_GetEventData("RESREF");
        string sType = NWNX_Events_GetEventData("TYPE");
        if(sResref == DISCORD_TRIGGER_RESREF)
        {
            //NWNX_SQL_ExecuteQuery("SET NAMES 'cp1251'");
            string sSql = "SELECT player_name, msg_text FROM shout WHERE player_id = ? and is_sent = ?";
            NWNX_SQL_PrepareQuery(sSql);
            NWNX_SQL_PreparedInt(0, -1);
            NWNX_SQL_PreparedInt(1,  0);
            NWNX_SQL_ExecutePreparedQuery();
            while(NWNX_SQL_ReadyToReadNextRow())
            {
                NWNX_SQL_ReadNextRow();
                string sPlayerName = NWNX_SQL_ReadDataInActiveRow(0);
                string sMsgText = NWNX_SQL_ReadDataInActiveRow(1);
                ServerShout(ColorText(sPlayerName, TXT_COLOR_ORANGE) + ": " + sMsgText);
            }
            NWNX_SQL_ExecuteQuery("UPDATE shout SET is_sent = 1 WHERE is_sent = 0");
        }
    }
}

#include "_inc_players"
#include "pdkl_native"
void main()
{
    PrintString("[CORMYR CHECK] SQL="+NWNX_SQL_GetDatabaseType()+" PDK="+IntToString(PDKL_NativeReady()));
    if(NWNX_SQL_ExecuteQuery("SELECT (SELECT COUNT(*) FROM players),(SELECT COUNT(*) FROM characters),(SELECT COUNT(*) FROM boss_cooldowns),(SELECT COUNT(*) FROM settings)"))
    {
        if(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            PrintString("[CORMYR CHECK] accounts="+NWNX_SQL_ReadDataInActiveRow(0)+" characters="+NWNX_SQL_ReadDataInActiveRow(1)+" bosses="+NWNX_SQL_ReadDataInActiveRow(2)+" settings="+NWNX_SQL_ReadDataInActiveRow(3));
        }
    }
    object p=GetFirstPC();
    while(GetIsObjectValid(p))
    {
        if(!GetIsDM(p))
            PrintString("[CORMYR CHECK] PC="+GetName(p,TRUE)+" id="+IntToString(players_GetPCPersistentID(p))+" faction="+IntToString(players_GetFaction(p))+" PDKlevel="+IntToString(GetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT,p)));
        p=GetNextPC();
    }
}

#include "_inc_fameshop"

const int CT_PDK_UPGRADE_COST = 200;

void main()
{
    object p=GetPCSpeaker();
    if(!GetIsPC(p) || GetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT,p)<1)
    { SendMessageToPC(p,"This improvement requires Purple Dragon Knight.");return; }
    int kind=StringToInt(GetScriptParam("PDK_UPGRADE"));
    string column="";
    if(kind==1) column="pdk_fame_slot";
    else if(kind==2) column="pdk_fame_range";
    else return;
    int id=players_GetPCPersistentID(p);
    if(id<=0 || !NWNX_SQL_ExecuteQuery("START TRANSACTION")) return;
    NWNX_SQL_PrepareQuery("SELECT "+column+" FROM characters WHERE id=? FOR UPDATE");
    NWNX_SQL_PreparedInt(0,id);
    if(!NWNX_SQL_ExecutePreparedQuery() || !NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ExecuteQuery("ROLLBACK");return; }
    NWNX_SQL_ReadNextRow();
    if(StringToInt(NWNX_SQL_ReadDataInActiveRow())!=0)
    { NWNX_SQL_ExecuteQuery("ROLLBACK");SendMessageToPC(p,"This improvement is already purchased.");return; }
    NWNX_SQL_PrepareQuery("UPDATE players SET fame_spent=fame_spent+? WHERE name=? AND fame_total-fame_spent>=?");
    NWNX_SQL_PreparedInt(0,CT_PDK_UPGRADE_COST);NWNX_SQL_PreparedString(1,GetPCPlayerName(p));
    NWNX_SQL_PreparedInt(2,CT_PDK_UPGRADE_COST);
    if(!NWNX_SQL_ExecutePreparedQuery() || NWNX_SQL_GetAffectedRows()!=1)
    { NWNX_SQL_ExecuteQuery("ROLLBACK");SendMessageToPC(p,"Not enough Fame.");return; }
    NWNX_SQL_PrepareQuery("UPDATE characters SET "+column+"=1,fame_spent=fame_spent+? WHERE id=?");
    NWNX_SQL_PreparedInt(0,CT_PDK_UPGRADE_COST);NWNX_SQL_PreparedInt(1,id);
    if(!NWNX_SQL_ExecutePreparedQuery() || !NWNX_SQL_ExecuteQuery("COMMIT"))
    { NWNX_SQL_ExecuteQuery("ROLLBACK");return; }
    ExecuteScript("ct_pdk_sync",p);
    SendMessageToPC(p,"PDK Link improvement purchased. Spent 200 Fame. Available: "+IntToString(GetFreeFame(p)));
}

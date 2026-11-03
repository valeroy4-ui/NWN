#include "_inc_players"
#include "pdk_battle"

void main()
{
    object p=OBJECT_SELF;
    int id=players_GetPCPersistentID(p);
    if(id<=0) return;
    NWNX_SQL_PrepareQuery("SELECT pdk_fame_slot,pdk_fame_range,pdk_rune_slot FROM characters WHERE id=?");
    NWNX_SQL_PreparedInt(0,id);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        SetLocalInt(p,"PDKL_FAME_SLOT",StringToInt(NWNX_SQL_ReadDataInActiveRow(0)));
        SetLocalInt(p,"PDKL_FAME_RANGE",StringToInt(NWNX_SQL_ReadDataInActiveRow(1)));
        SetLocalInt(p,"PDKL_RUNE3_SLOT",StringToInt(NWNX_SQL_ReadDataInActiveRow(2)));
    }
    PKB_Grant(p);
    PDKL_Refresh(p);
}

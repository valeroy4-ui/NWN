// Console-only test adapter for the production entitlement PDKL_RUNE3_SLOT.
// Does not spend/replace any existing rune or claim a new production rune price.
#include "_inc_players"
void main()
{
    if(OBJECT_SELF!=GetModule()) return;
    object p=GetFirstPC();
    string wanted=GetLocalString(GetModule(),"CT_PDK_PC_NAME");
    while(GetIsObjectValid(p))
    {
        if(!GetIsDM(p) && (wanted=="" || GetName(p,TRUE)==wanted)) break;
        p=GetNextPC();
    }
    if(!GetIsObjectValid(p)) { PrintString("[PDK TEST] Target PC not found");return; }
    int id=players_GetPCPersistentID(p);
    if(id<=0) return;
    NWNX_SQL_PrepareQuery("UPDATE characters SET pdk_rune_slot=1-pdk_rune_slot WHERE id=?");
    NWNX_SQL_PreparedInt(0,id);
    if(!NWNX_SQL_ExecutePreparedQuery()) return;
    ExecuteScript("ct_pdk_sync",p);
    PrintString("[PDK TEST] "+GetName(p,TRUE)+" rune III slot="+IntToString(GetLocalInt(p,"PDKL_RUNE3_SLOT")));
}

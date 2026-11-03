#include "dq_store"
#include "nwnx_events"
void main()
{
    if(NWNX_Events_GetCurrentEvent()!="NWNX_ON_SERVER_CHARACTER_SAVE_AFTER")return;
    object pc=OBJECT_SELF;string receipt=GetLocalString(pc,"DQR_WAITING_SAVE");string uuid=GetLocalString(pc,"DQR_WAITING_UUID");
    if(receipt=="" || uuid=="" || !GetIsPC(pc))return;
    int owner=players_GetPCPersistentID(pc);if(owner<=0)return;
    SetLocalInt(pc,"DQR_SAVE_OBSERVED",TRUE);
    NWNX_SQL_PrepareQuery("UPDATE dq_reward_items_v06 R JOIN characters C ON C.id=R.character_id SET R.status='delivered',R.resolved_at=? WHERE R.character_id=? AND R.receipt_id=? AND R.status='issuing' AND R.item_uuid=? AND C.account=?");
    NWNX_SQL_PreparedInt(0,DQC_Now());NWNX_SQL_PreparedInt(1,owner);NWNX_SQL_PreparedString(2,receipt);
    NWNX_SQL_PreparedString(3,uuid);NWNX_SQL_PreparedString(4,GetPCPlayerName(pc));
    int ok=NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_GetAffectedRows()==1;
    DeleteLocalString(pc,"DQR_WAITING_SAVE");DeleteLocalString(pc,"DQR_WAITING_UUID");DeleteLocalInt(pc,"DQR_DELIVERING");
    string message=ok?"Item reward delivered and saved.":"Item saved; delivery confirmation needs review. It will not be issued again automatically.";
    SetLocalString(pc,"DQR_DELIVERY_MESSAGE",message);SendMessageToPC(pc,"[Daily] "+message);
    if(ok)DelayCommand(0.2,ExecuteScript("dq_deliver",pc));
}

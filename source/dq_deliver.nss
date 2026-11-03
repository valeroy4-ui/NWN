#include "dq_store"
#include "nwnx_events"
void DeliveryMessage(object pc, string message)
{
    SetLocalString(pc,"DQR_DELIVERY_MESSAGE",message);
    SendMessageToPC(pc,"[Daily] "+message);
}
void SaveTimeout(object pc,string receipt)
{
    if(GetLocalString(pc,"DQR_WAITING_SAVE")==receipt)ExecuteScript("dq_item_timeout",pc);
}
// Identify only already delivered items stamped by Daily for this character.
void IdentifyDailyItems(object pc, int owner)
{
    object item = GetFirstItemInInventory(pc);
    while (GetIsObjectValid(item))
    {
        if (GetLocalInt(item,"DQR_OWNER") == owner && GetLocalString(item,"DQR_RECEIPT") != "" && !GetIdentified(item))
            SetIdentified(item,TRUE);
        item = GetNextItemInInventory(pc);
    }
}
void main()
{
    object pc = OBJECT_SELF; int owner = players_GetPCPersistentID(pc);
    if (!GetIsPC(pc) || GetIsDM(pc) || GetIsDMPossessed(pc) || owner <= 0 || GetLocalInt(pc,"DQR_DELIVERING")) return;
    IdentifyDailyItems(pc,owner);
    if (players_IsTestCharacter(pc))
    { DeliveryMessage(pc,"Item reward saved; delivery is paused for [test] characters whose saves are disabled."); return; }
    // Ownership is checked on each attempt. An ambiguous issuing state is NEVER
    // automatically replayed after a crash, disconnect or uncertain save.
    // Review is per entitlement: pending rewards must not be blocked by an older
    // uncertain item. An issuing row is still never replayed. Busy/save guards remain.
    NWNX_SQL_PrepareQuery("SELECT R.receipt_id,R.status,R.payload FROM dq_reward_items_v06 R JOIN characters C ON C.id=R.character_id WHERE R.character_id=? AND C.account=? AND R.status IN ('pending','issuing') ORDER BY (R.status='pending') DESC,R.created_at,R.receipt_id LIMIT 1");
    NWNX_SQL_PreparedInt(0,owner); NWNX_SQL_PreparedString(1,GetPCPlayerName(pc));
    if (!NWNX_SQL_ExecutePreparedQuery() || !NWNX_SQL_ReadyToReadNextRow()) return;
    NWNX_SQL_ReadNextRow(); string receipt = NWNX_SQL_ReadDataInActiveRow(0); string status = NWNX_SQL_ReadDataInActiveRow(1);
    SetLocalString(pc,"DQR_DELIVERY_MESSAGE","Item reward saved for delivery. Reopen the journal to retry.");
    json itemData = JsonParse(NWNX_SQL_ReadDataInActiveRow(2));
    if (status == "issuing")
    { DeliveryMessage(pc,"Earlier reward ("+DQC_Str(itemData,"label")+") needs review. Other pending rewards are not blocked."); return; }
    if (!DQR_ItemValid(itemData))
    { DeliveryMessage(pc,"Stored item reward is invalid; delivery paused for review."); return; }
    if (!DQC_Query("START TRANSACTION")) return;
    NWNX_SQL_PrepareQuery("UPDATE dq_reward_items_v06 R JOIN characters C ON C.id=R.character_id SET R.status='issuing' WHERE R.character_id=? AND R.receipt_id=? AND C.account=? AND R.status='pending'");
    NWNX_SQL_PreparedInt(0,owner); NWNX_SQL_PreparedString(1,receipt); NWNX_SQL_PreparedString(2,GetPCPlayerName(pc));
    if (!NWNX_SQL_ExecutePreparedQuery() || NWNX_SQL_GetAffectedRows() != 1) { DQC_Abort(); return; }
    if (!DQC_Query("COMMIT")) { DQC_Abort(); return; }
    SetLocalInt(pc,"DQR_DELIVERING",TRUE);
    object item = CreateObject(OBJECT_TYPE_ITEM,DQC_Str(itemData,"resref"),GetStartingLocation());
    if (!GetIsObjectValid(item))
    {
        NWNX_SQL_PrepareQuery("UPDATE dq_reward_items_v06 SET status='pending' WHERE character_id=? AND receipt_id=? AND status='issuing' AND item_uuid=''");
        NWNX_SQL_PreparedInt(0,owner); NWNX_SQL_PreparedString(1,receipt); NWNX_SQL_ExecutePreparedQuery();
        DeleteLocalInt(pc,"DQR_DELIVERING"); return;
    }
    // Daily item rewards arrive identified, including potions, scrolls and wands.
    SetIdentified(item,TRUE);
    if(DQC_Str(itemData,"resref")=="fl_inst_key")
    {
        SetLocalString(item,"LOOT_CATEGORY",DQC_Str(itemData,"category"));
        SetName(item,"Newbie Instance Key");
        if(GetLocalString(item,"LOOT_CATEGORY")!="BLUE")
        {DestroyObject(item);DeleteLocalInt(pc,"DQR_DELIVERING");return;}
    }
    int originalPlot = GetPlotFlag(item);
    SetPlotFlag(item,TRUE); SetLocalString(item,"DQR_RECEIPT",receipt); SetLocalInt(item,"DQR_OWNER",owner);
    SetItemStackSize(item,DQC_Int(itemData,"quantity"));
    if (DQC_Int(itemData,"charges") > 0) SetItemCharges(item,DQC_Int(itemData,"charges"));
    if (GetItemStackSize(item) != DQC_Int(itemData,"quantity") ||
        (DQC_Int(itemData,"charges") > 0 && GetItemCharges(item) != DQC_Int(itemData,"charges")))
    {
        DestroyObject(item); DeleteLocalInt(pc,"DQR_DELIVERING");
        DeliveryMessage(pc,"Item quantity or charges could not be prepared; reward saved for review."); return;
    }
    string uuid = GetObjectUUID(item);
    NWNX_SQL_PrepareQuery("UPDATE dq_reward_items_v06 SET item_uuid=? WHERE character_id=? AND receipt_id=? AND status='issuing' AND item_uuid=''");
    NWNX_SQL_PreparedString(0,uuid); NWNX_SQL_PreparedInt(1,owner); NWNX_SQL_PreparedString(2,receipt);
    if (uuid == "" || !NWNX_SQL_ExecutePreparedQuery() || NWNX_SQL_GetAffectedRows() != 1)
    {
        DestroyObject(item); DeleteLocalInt(pc,"DQR_DELIVERING");
        DeliveryMessage(pc,"Item reward needs delivery review; it has not been issued again."); return;
    }
    // No SQL transaction is held across inventory callbacks or character save.
    int acquired = NWNX_Object_AcquireItem(pc,item);
    if (!acquired || GetItemPossessor(item) != pc)
    {
        if (GetIsObjectValid(item) && !GetIsObjectValid(GetItemPossessor(item)))
        {
            DestroyObject(item);
            NWNX_SQL_PrepareQuery("UPDATE dq_reward_items_v06 SET status='pending',item_uuid='' WHERE character_id=? AND receipt_id=? AND status='issuing' AND item_uuid=?");
            NWNX_SQL_PreparedInt(0,owner); NWNX_SQL_PreparedString(1,receipt); NWNX_SQL_PreparedString(2,uuid); NWNX_SQL_ExecutePreparedQuery();
            DeliveryMessage(pc,"Make room in your inventory and reopen the journal to receive the item reward.");
        }
        else DeliveryMessage(pc,"Item reward needs delivery review; it has not been issued again.");
        DeleteLocalInt(pc,"DQR_DELIVERING"); return;
    }
    SetPlotFlag(item,originalPlot);
    if (!GetLocalInt(GetModule(),"DQR_SAVE_SUBSCRIBED"))
    {
        NWNX_Events_SubscribeEvent("NWNX_ON_SERVER_CHARACTER_SAVE_AFTER","dq_rewards_save");
        SetLocalInt(GetModule(),"DQR_SAVE_SUBSCRIBED",TRUE);
    }
    SetSkinString(pc,"DQR_LAST_ITEM_RECEIPT",receipt);
    SetLocalString(pc,"DQR_WAITING_SAVE",receipt);SetLocalString(pc,"DQR_WAITING_UUID",uuid);
    DeleteLocalInt(pc,"DQR_SAVE_OBSERVED");
    // ExportSingleCharacter queues the export in this pinned engine. Its real
    // AFTER event finalizes the entitlement; never assume a synchronous save.
    ExportSingleCharacter(pc);
    DeliveryMessage(pc,"Item received; waiting for its server save confirmation.");
    DelayCommand(30.0,SaveTimeout(pc,receipt));
}

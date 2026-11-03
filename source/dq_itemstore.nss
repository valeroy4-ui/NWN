int DQR_ItemValid(json item)
{
    string ref = DQC_Str(item,"resref"); int quantity = DQC_Int(item,"quantity"); int charges = DQC_Int(item,"charges");
    if(ref=="fl_inst_key")return quantity>=1 && quantity<=250 && charges==0 && DQC_Str(item,"category")=="BLUE";
    if (quantity < 1 || quantity > 200) return FALSE;
    if (ref == "dq_wand_rest" || ref == "dq_wand_clar" || ref == "dq_wand_free")
        return quantity == 1 && charges >= 25 && charges <= 250;
    return (ref == "nw_it_mpotion012" || ref == "fl_scr_grtsanc" || ref == "fl_scr_grtspml") && charges == 0;
}
int DQR_OutboxReady()
{
    if (!DQC_Query("SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='dq_reward_items_v06'") || !NWNX_SQL_ReadyToReadNextRow()) return FALSE;
    NWNX_SQL_ReadNextRow(); if (GetStringLowerCase(NWNX_SQL_ReadDataInActiveRow()) != "innodb") return FALSE;
    if (!DQC_Query("SELECT character_id,receipt_id,payload,status,item_uuid,created_at,resolved_at FROM dq_reward_items_v06 LIMIT 0")) return FALSE;
    if (!DQC_Query("SELECT COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='dq_reward_items_v06' AND CONSTRAINT_NAME='PRIMARY' ORDER BY ORDINAL_POSITION")) return FALSE;
    string key;
    while (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow(); if (key != "") key += ","; key += GetStringLowerCase(NWNX_SQL_ReadDataInActiveRow());
    }
    return key == "character_id,receipt_id";
}
int DQR_RecordEntitlement(object pc, json reward, string receipt)
{
    json items = JsonObjectGet(reward,"items");
    if (JsonGetType(items) == JSON_TYPE_NULL || JsonGetLength(items) == 0) return TRUE;
    if (JsonGetType(items) != JSON_TYPE_ARRAY || JsonGetLength(items) != 1) return FALSE;
    json item = JsonArrayGet(items,0); if (!DQR_ItemValid(item)) return FALSE;
    int count=DQC_Str(item,"resref")=="fl_inst_key"?DQC_Int(item,"quantity"):1;int i;
    for(i=0;i<count;i++)
    {
        json payload=JsonParse(JsonDump(item));string itemReceipt=receipt;
        if(DQC_Str(item,"resref")=="fl_inst_key")
        {JsonObjectSetInplace(payload,"quantity",JsonInt(1));itemReceipt+=":key:"+IntToString(i);}
        NWNX_SQL_PrepareQuery("INSERT INTO dq_reward_items_v06 (character_id,receipt_id,payload,status,item_uuid,created_at,resolved_at) VALUES (?,?,?,'pending','',?,0)");
        NWNX_SQL_PreparedInt(0,players_GetPCPersistentID(pc));NWNX_SQL_PreparedString(1,itemReceipt);
        NWNX_SQL_PreparedString(2,JsonDump(payload));NWNX_SQL_PreparedInt(3,GetLocalInt(pc,"DQ_TX_NOW"));
        if(!NWNX_SQL_ExecutePreparedQuery() || NWNX_SQL_GetAffectedRows()!=1)return FALSE;
    }
    return TRUE;
}
int DQR_BackupReady()
{
    if (!DQC_Query("SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='dq_config_backup_v06'") || !NWNX_SQL_ReadyToReadNextRow()) return FALSE;
    NWNX_SQL_ReadNextRow(); if (GetStringLowerCase(NWNX_SQL_ReadDataInActiveRow()) != "innodb") return FALSE;
    if (!DQC_Query("SELECT id,previous_json FROM dq_config_backup_v06 LIMIT 0")) return FALSE;
    if (!DQC_Query("SELECT COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='dq_config_backup_v06' AND CONSTRAINT_NAME='PRIMARY' ORDER BY ORDINAL_POSITION")) return FALSE;
    string key;
    while (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow(); if (key != "") key += ","; key += GetStringLowerCase(NWNX_SQL_ReadDataInActiveRow());
    }
    return key == "id";
}

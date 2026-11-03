#include "dq_store"
void main()
{
    if (OBJECT_SELF != GetModule() && !GetIsDM(OBJECT_SELF)) return;
    if (!DQC_Ready(TRUE)) { PrintString("[DQ REWARDS BLOCKED] Existing Daily config is not ready."); return; }
    string previousRaw = GetLocalString(GetModule(),"DQ_CONFIG_RAW_V05");
    json cfg = JsonParse(previousRaw);
    if (DQC_Int(cfg,"reward_policy") == 2)
    { PrintString("[DQ REWARDS] policy=2 already enabled; saved rewards and settings retained."); return; }
    if (!DQC_Query("CREATE TABLE IF NOT EXISTS dq_reward_items_v06 (character_id INT NOT NULL,receipt_id VARCHAR(100) NOT NULL,payload LONGTEXT NOT NULL,status VARCHAR(16) NOT NULL DEFAULT 'pending',item_uuid VARCHAR(36) NOT NULL DEFAULT '',created_at INT NOT NULL,resolved_at INT NOT NULL DEFAULT 0,PRIMARY KEY(character_id,receipt_id)) ENGINE=InnoDB") ||
        !DQC_Query("CREATE TABLE IF NOT EXISTS dq_config_backup_v06 (id INT NOT NULL PRIMARY KEY,previous_json LONGTEXT NOT NULL) ENGINE=InnoDB") || !DQR_OutboxReady() || !DQR_BackupReady())
    { PrintString("[DQ REWARDS BLOCKED] Entitlement schema validation failed."); return; }
    // Verify item spell properties in a private, unowned object before enabling.
    json refs = JsonParse("[\"nw_it_mpotion012\",\"dq_wand_rest\",\"dq_wand_clar\",\"dq_wand_free\",\"fl_scr_grtsanc\",\"fl_scr_grtspml\"]");
    json spells = JsonParse("[139,238,46,118,374,130]"); int i;
    for (i = 0; i < 6; i++)
    {
        object item = CreateObject(OBJECT_TYPE_ITEM,JsonGetString(JsonArrayGet(refs,i)),GetStartingLocation());
        int valid = GetIsObjectValid(item); int found = FALSE;
        if (valid)
        {
            itemproperty ip = GetFirstItemProperty(item);
            while (GetIsItemPropertyValid(ip))
            {
                if (GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL && GetItemPropertySubType(ip) == JsonGetInt(JsonArrayGet(spells,i)) && GetItemPropertyCostTableValue(ip) == (i >= 1 && i <= 3 ? 6 : 1)) found = TRUE;
                ip = GetNextItemProperty(item);
            }
            // Reject incompatible live HAK stack/charge limits before activating
            // rewards that would otherwise be saved but impossible to deliver.
            int quantity = i == 0 ? 51 : (i >= 4 ? 8 : 1);
            SetItemStackSize(item,quantity);
            valid = valid && GetItemStackSize(item) == quantity;
            if (i >= 1 && i <= 3)
            {
                SetItemCharges(item,100);
                valid = valid && GetItemCharges(item) == 100;
            }
            DestroyObject(item);
        }
        if (!valid || !found)
        { PrintString("[DQ REWARDS BLOCKED] Item verification failed: "+JsonGetString(JsonArrayGet(refs,i))); return; }
    }
    JsonObjectSetInplace(cfg,"reward_policy",JsonInt(2)); JsonObjectSetInplace(cfg,"reward_v06",DQR_Defaults());
    if (!DQC_ValidConfig(cfg)) { PrintString("[DQ REWARDS BLOCKED] New reward config invalid."); return; }
    // Permanent activation marker makes pre-activation binary restore fail closed.
    // Never delete it to bypass the required audit of v06 reward/entitlement data.
    SetCampaignInt("dq_reward_v06","enabled",TRUE);
    if (!GetCampaignInt("dq_reward_v06","enabled")) { PrintString("[DQ REWARDS BLOCKED] Activation marker could not be saved."); return; }
    if (!DQC_Query("START TRANSACTION")) return;
    if (!DQC_Query("INSERT IGNORE INTO dq_config_backup_v06 (id,previous_json) SELECT id,config_json FROM dq_meta_v05 WHERE id=1")) { DQC_Abort(); return; }
    NWNX_SQL_PrepareQuery("UPDATE dq_meta_v05 SET config_json=? WHERE id=1 AND schema_version=1 AND BINARY config_json=BINARY ?");
    NWNX_SQL_PreparedString(0,JsonDump(cfg)); NWNX_SQL_PreparedString(1,previousRaw);
    if (!NWNX_SQL_ExecutePreparedQuery() || NWNX_SQL_GetAffectedRows() != 1) { DQC_Abort(); PrintString("[DQ REWARDS BLOCKED] Config changed concurrently; no replacement performed."); return; }
    if (!DQC_Query("COMMIT")) { DQC_Abort(); return; }
    PrintString(DQC_Ready(TRUE) ? "[DQ REWARDS OK] policy=2; NEW snapshots use CR/count pools and increasing chests. Existing snapshots retained." : "[DQ REWARDS BLOCKED] Config reload failed; retained entitlements require review.");
}

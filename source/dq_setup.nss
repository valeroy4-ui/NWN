#include "dq_store"
#include "dq_migration"

void SetupBlocked(string table, string reason)
{
    PrintString("[DQ SETUP BLOCKED] table="+table+" reason="+reason+". Existing table/data were not changed.");
}
void ReportIndexes(string table)
{
    NWNX_SQL_PrepareQuery("SELECT INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? ORDER BY INDEX_NAME, SEQ_IN_INDEX");
    NWNX_SQL_PreparedString(0,table);
    if (!NWNX_SQL_ExecutePreparedQuery())
    { PrintString("[DQ INDEX] table="+table+" metadata_query_failed=1"); return; }
    int count = 0;
    while (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow(); count++;
        PrintString("[DQ INDEX] table="+table+" index="+NWNX_SQL_ReadDataInActiveRow(0)+
            " non_unique="+NWNX_SQL_ReadDataInActiveRow(1)+" position="+NWNX_SQL_ReadDataInActiveRow(2)+
            " column="+NWNX_SQL_ReadDataInActiveRow(3));
    }
    if (!count) PrintString("[DQ INDEX] table="+table+" no_index_rows_returned=1");
}
int CheckTable(string name, string columns)
{
    NWNX_SQL_PrepareQuery("SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?");
    NWNX_SQL_PreparedString(0,name);
    if (!NWNX_SQL_ExecutePreparedQuery() || !NWNX_SQL_ReadyToReadNextRow())
    { SetupBlocked(name,"table missing or engine metadata unavailable"); return FALSE; }
    NWNX_SQL_ReadNextRow(); string engine = NWNX_SQL_ReadDataInActiveRow();
    if (GetStringLowerCase(engine) != "innodb")
    { SetupBlocked(name,"transactional InnoDB required; observed engine="+engine); return FALSE; }
    if (!DQC_Query("SELECT "+columns+" FROM "+name+" LIMIT 0"))
    { SetupBlocked(name,"required columns unavailable: "+columns); return FALSE; }

    // Existing server identity keys may be UNIQUE without being the PRIMARY KEY.
    // A different surrogate primary key is valid too. Never alter these tables.
    if (name == "players" || name == "characters")
    {
        string identity = name == "players" ? "name" : "id";
        NWNX_SQL_PrepareQuery("SELECT INDEX_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND NON_UNIQUE = 0 GROUP BY INDEX_NAME HAVING COUNT(*) = 1 AND MAX(COLUMN_NAME) = ? ORDER BY INDEX_NAME");
        NWNX_SQL_PreparedString(0,name); NWNX_SQL_PreparedString(1,identity);
        if (!NWNX_SQL_ExecutePreparedQuery())
        { SetupBlocked(name,"cannot verify unique identity index on "+identity); ReportIndexes(name); return FALSE; }
        if (!NWNX_SQL_ReadyToReadNextRow())
        { SetupBlocked(name,"no single-column PRIMARY or UNIQUE identity index on "+identity); ReportIndexes(name); return FALSE; }
        NWNX_SQL_ReadNextRow();
        PrintString("[DQ SETUP] table="+name+" identity="+identity+" unique_index="+NWNX_SQL_ReadDataInActiveRow()+" accepted=1");
        return TRUE;
    }

    // Own Daily tables keep their exact primary-key requirements, including
    // the composite receipt identity that prevents duplicate reward delivery.
    NWNX_SQL_PrepareQuery("SELECT COLUMN_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND CONSTRAINT_NAME = 'PRIMARY' ORDER BY ORDINAL_POSITION");
    NWNX_SQL_PreparedString(0,name);
    if (!NWNX_SQL_ExecutePreparedQuery()) { SetupBlocked(name,"cannot read primary-key metadata"); return FALSE; }
    string primary;
    while (NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); if (primary != "") primary += ","; primary += GetStringLowerCase(NWNX_SQL_ReadDataInActiveRow()); }
    string expected = "character_id";
    if (name == "dq_meta_v05") expected = "id";
    else if (name == "dq_receipts_v05") expected = "character_id,receipt_id";
    if (primary != expected)
    { SetupBlocked(name,"Daily primary key mismatch; expected="+expected+" observed="+primary); ReportIndexes(name); return FALSE; }
    return TRUE;
}
void main()
{
    if (OBJECT_SELF != GetModule() && !GetIsDM(OBJECT_SELF)) return;
    PrintString("[DQ SETUP] schema_check=2 Checking character, bank and Fame schema; existing game tables are read-only.");
    if (!CheckTable("players","name,gold_deposit,fame_total")) return;
    if (!CheckTable("characters","id,account")) return;
    if (!DQC_ValidConfig(DQC_DefaultConfig())) { PrintString("[DQ SETUP BLOCKED] Invalid configuration."); return; }
    if (!DQC_CreateTables()) { PrintString("[DQ SETUP BLOCKED] Additive Daily migration failed; no gameplay rewards enabled."); return; }
    if (!CheckTable("dq_meta_v05","id,schema_version,config_json") ||
        !CheckTable("dq_contract_state_v05","character_id,revision,payload") ||
        !CheckTable("dq_wallet_v05","character_id,rune_coins") ||
        !CheckTable("dq_receipts_v05","character_id,receipt_id,gold,rune_coins,fame,created_at")) return;
    NWNX_SQL_PrepareQuery("INSERT IGNORE INTO dq_meta_v05 (id,schema_version,config_json) VALUES (1,1,?)");
    NWNX_SQL_PreparedString(0,JsonDump(DQC_DefaultConfig()));
    if (!NWNX_SQL_ExecutePreparedQuery() || !DQC_Ready(TRUE)) { PrintString("[DQ SETUP BLOCKED] Configuration could not be loaded."); return; }
    PrintString("[DQ SETUP OK] 15 contracts, 3 replacements, killer-only credit, Rune Coins in dq_wallet_v05. Gold: existing bank. Unverified categories disabled.");
}

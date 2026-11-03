// Generated additive DDL. Existing game tables are not altered.
int DQC_CreateTables()
{
    if (!DQC_Query("CREATE TABLE IF NOT EXISTS dq_meta_v05 (\n  id INT NOT NULL PRIMARY KEY,\n  schema_version INT NOT NULL,\n  config_json LONGTEXT NOT NULL\n) ENGINE=InnoDB")) return FALSE;
    if (!DQC_Query("CREATE TABLE IF NOT EXISTS dq_contract_state_v05 (\n  character_id INT NOT NULL PRIMARY KEY,\n  revision INT NOT NULL DEFAULT 0,\n  payload LONGTEXT NOT NULL\n) ENGINE=InnoDB")) return FALSE;
    if (!DQC_Query("CREATE TABLE IF NOT EXISTS dq_wallet_v05 (\n  character_id INT NOT NULL PRIMARY KEY,\n  rune_coins BIGINT UNSIGNED NOT NULL DEFAULT 0\n) ENGINE=InnoDB")) return FALSE;
    if (!DQC_Query("CREATE TABLE IF NOT EXISTS dq_receipts_v05 (\n  character_id INT NOT NULL,\n  receipt_id VARCHAR(100) NOT NULL,\n  gold INT NOT NULL,\n  rune_coins INT NOT NULL,\n  fame INT NOT NULL,\n  created_at INT NOT NULL,\n  PRIMARY KEY (character_id, receipt_id)\n) ENGINE=InnoDB")) return FALSE;
    return TRUE;
}

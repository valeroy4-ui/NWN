#include "dq_store"
void main()
{
    PrintString("[DQ CHECK] stability=1 phases=T1-T4 replacements_display=used carry_conflicts=sequential");
    PrintString("[DQ CHECK] definitions="+IntToString(JsonGetLength(DQC_Definitions()))+" daily=15 rerolls=3 milestones=5/10/15 killer_only=1");
    PrintString("[DQ CHECK] live_config_ready="+IntToString(DQC_Ready(TRUE))+" rune_coin_store=dq_wallet_v05 gold_store=players.gold_deposit fame_store=players.fame_total");
    PrintString("[DQ REWARDS CHECK] code=2 policy="+IntToString(DQC_Int(DQC_Config(),"reward_policy"))+" physical_delivery=outbox");
    if (!GetIsPC(OBJECT_SELF) || GetIsDM(OBJECT_SELF)) return;
    json state = DQC_Read(OBJECT_SELF);
    if (JsonGetType(state) != JSON_TYPE_OBJECT) { SendMessageToPC(OBJECT_SELF,"No stored daily contracts for this character."); return; }
    SendMessageToPC(OBJECT_SELF,"Daily rewards claimed: "+IntToString(DQC_Int(state,"claimed_count"))+"/15; replacements used: "+IntToString(3-DQC_Int(state,"rerolls_remaining"))+"/3.");
    NWNX_SQL_PrepareQuery("SELECT rune_coins FROM dq_wallet_v05 WHERE character_id = ?");
    NWNX_SQL_PreparedInt(0,players_GetPCPersistentID(OBJECT_SELF));
    if (NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow(); SendMessageToPC(OBJECT_SELF,"Rune Coins: "+NWNX_SQL_ReadDataInActiveRow()); }
}

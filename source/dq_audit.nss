#include "dq_store"
void main()
{
    if (OBJECT_SELF != GetModule() && !GetIsDM(OBJECT_SELF)) return;
    PrintString("[DQ AUDIT] Observed module phase="+IntToString(GetLocalInt(GetModule(),CORMYREAN_WIPE_PHASE))+" (test _mod_load forces T4; not live evidence)");
    if (!DQC_Query("SELECT boss_resref,category,boss_cooldown_sec FROM boss_cooldowns ORDER BY boss_resref"))
    { PrintString("[DQ AUDIT] boss_cooldowns unavailable; boss/instance assignment disabled."); return; }
    // Read every row before any other NWNX SQL query can replace its result set.
    while (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        string ref = NWNX_SQL_ReadDataInActiveRow(0);
        string category = NWNX_SQL_ReadDataInActiveRow(1);
        string cooldown = NWNX_SQL_ReadDataInActiveRow(2);
        object wp = GetObjectByTag("wp_"+ref+"_spawn_point");
        PrintString("[DQ BOSS] resref="+ref+" category="+category+" cooldown="+cooldown+" waypoint="+IntToString(GetIsObjectValid(wp)));
    }
    PrintString("[DQ AUDIT] Flags: CHAMPIONSPAWNED / ELITECHAMPIONSPAWNED / BOSS_TYPE / MUTATED. Whole-instance chest-count proof unavailable.");
}

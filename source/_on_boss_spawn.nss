#include "nwnx_sql"
#include "_inc_generic"
#include "_inc_sqlite_time"

void main()
{
    object oTrigger     = OBJECT_SELF;
    object oBoss        = GetLocalObject(oTrigger, "SPAWNED_BOSS");
    if (GetIsObjectValid(oBoss)) // boss already spawned
        return;

    int bBossInstance = GetLocalInt(GetArea(oTrigger), AREA_FLAG_INSTANCE_BOSS);
    int bInstanceBossKilled = GetLocalInt(GetArea(oTrigger), AREA_FLAG_INSTANCE_BOSS_KILLED);

    object oPC          = GetEnteringObject();
    string sBossResref  = GetLocalString(oTrigger, "BOSS_RESREF");

    int nHour = GetLocalInt(GetModule(), "SERVER_HOUR");
    if (sBossResref == "cr_boss_chauntea" && !db_GetIsPrimeTime() && !bBossInstance)
        return;

    // read cooldown and last death timestamp from DB or module/trigger's local
    int iBossCooldownSec, iDeathTimeStamp, iRandomShift;

    NWNX_SQL_ExecuteQuery("SELECT boss_cooldown_sec, last_death_timestamp, boss_random_shift FROM boss_cooldowns WHERE boss_resref = '" + sBossResref + "'");
    if (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iBossCooldownSec = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
        iDeathTimeStamp  = StringToInt(NWNX_SQL_ReadDataInActiveRow(1));
        iRandomShift     = StringToInt(NWNX_SQL_ReadDataInActiveRow(2));
    }
    if (iBossCooldownSec <= 0) iBossCooldownSec = GetLocalInt(oTrigger, "BOSS_TIMEOUT_SEC");
    if (iDeathTimeStamp  <= 0) iDeathTimeStamp  = GetLocalInt(GetModule(), sBossResref);
    if (iDeathTimeStamp  <= 0) iRandomShift     = GetLocalInt(oTrigger, "BOSS_RANDOM_SHIFT");

    // spawn boss first time or check CD
    if(bBossInstance && !bInstanceBossKilled || !bBossInstance && SQLite_GetTimeStamp() - iDeathTimeStamp >= iBossCooldownSec + iRandomShift && !GetIsDM(oPC) && GetIsPC(oPC))
    {
        location lBossSpawnPoint  = GetLocation(GetNearestObjectByTag(GetLocalString(oTrigger, "BOSS_SPAWN_WAYPOINT_TAG")));
        object oBoss              = CreateObject(OBJECT_TYPE_CREATURE, sBossResref, lBossSpawnPoint, TRUE);
        if(bBossInstance)
            SetName(oBoss, "Instance " + GetName(oBoss));
        SetLocalObject(oTrigger, "SPAWNED_BOSS", oBoss);
    }
}

// Champion Rift v1. The only dependency of the normal OnDeath hook.
// 10000 / 10000 = 100% for the requested test build.
const int CRF_PORTAL_CHANCE = 10000;
const float CRF_LIFETIME = 3600.0;

void CRF_Register(object mob)
{
    object area = GetArea(mob);
    if (!GetLocalInt(area, "CRIFT_AREA") || GetIsPC(mob) ||
        (GetIsObjectValid(GetMaster(mob)) && !GetLocalInt(mob, "CRIFT_COUNTED")) ||
        GetLocalInt(mob, "CRIFT_FINAL_GRAND"))
        return;
    // Track custom/stock death callbacks too; retain the exact original callback.
    string death = GetEventScript(mob, EVENT_SCRIPT_CREATURE_ON_DEATH);
    if (death != "crift_death")
    {
        SetLocalString(mob, "CRIFT_ORIG_DEATH", death);
        SetEventScript(mob, EVENT_SCRIPT_CREATURE_ON_DEATH, "crift_death");
    }
    if (GetLocalInt(mob, "CRIFT_COUNTED")) return;
    SetLocalInt(mob, "CRIFT_COUNTED", TRUE);
    SetLocalInt(area, "CRIFT_CREATED", GetLocalInt(area, "CRIFT_CREATED") + 1);
}

void CRF_OnDeath(object mob)
{
    object area = GetArea(mob);
    if (!GetLocalInt(area, "CRIFT_AREA") || GetIsPC(mob) ||
        (GetIsObjectValid(GetMaster(mob)) && !GetLocalInt(mob, "CRIFT_COUNTED")) ||
        GetLocalInt(mob, "CRIFT_DEAD") ||
        GetLocalInt(mob, "CRIFT_FINAL_GRAND"))
        return;
    // The fallback covers stock OnSpawn scripts before the watcher sees a mob.
    if (!GetLocalInt(mob, "CRIFT_COUNTED") && !GetIsEncounterCreature(mob) &&
        !GetLocalInt(mob, "BOSS_TYPE"))
        return;
    CRF_Register(mob);
    SetLocalInt(mob, "CRIFT_DEAD", TRUE);
    SetLocalInt(area, "CRIFT_KILLED", GetLocalInt(area, "CRIFT_KILLED") + 1);
    SetLocalLocation(area, "CRIFT_LAST_KILL", GetLocation(mob));
}

void CRF_TryPortal(object mob, object killer)
{
    object area = GetArea(mob);
    if (GetLocalInt(area, "CRIFT_AREA") ||
        GetLocalInt(area, "AREA_FLAG_INSTANCE_BOSS") ||
        GetLocalInt(area, "CRIFT_PENDING") ||
        GetIsObjectValid(GetLocalObject(area, "CRIFT_ACTIVE")) ||
        GetIsPC(mob) || GetIsObjectValid(GetMaster(mob)))
        return;
    if (GetIsObjectValid(GetMaster(killer))) killer = GetMaster(killer);
    if (!GetIsPC(killer) || GetIsDM(killer)) return;
    if (Random(10000) >= CRF_PORTAL_CHANCE) return;
    SetLocalInt(area, "CRIFT_PENDING", TRUE);
    SetLocalObject(area, "CRIFT_REQUEST_PC", killer);
    SetLocalLocation(area, "CRIFT_REQUEST_LOC", GetLocation(mob));
    // Run outside the death/loot stack; the area outlives a disappearing corpse.
    AssignCommand(GetModule(), DelayCommand(0.0, ExecuteScript("crift_open", area)));
}

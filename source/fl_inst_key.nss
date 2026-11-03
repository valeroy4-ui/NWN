#include "nwnx_creature"
#include "_inc_generic"
#include "nwnx_sql"
#include "x0_i0_position"

//
object inst_GetRandomBossWaypoint(object oActivator, string sCategory);

void main()
{
    object oItem = GetItemActivated();
    object oActivator = GetItemPossessor(oItem);
    if(GetIsInCombat(oActivator))
    {
        SendColorMessageToPC(oActivator, "Do not activate during combat.", TXT_COLOR_WHITE);
        return;
    }

    string sCategory = GetLocalString(oItem, "LOOT_CATEGORY");
    object oWaypoint = inst_GetRandomBossWaypoint(oActivator, sCategory);
    if(!GetIsObjectValid(oWaypoint))
    {
        SendColorMessageToPC(oActivator, "Invalid destination. Please, report to DM.", TXT_COLOR_WHITE);
        return;
    }
    SetLocalInt(oWaypoint, "WAYPOYNT_EXIT_TYPE", 2 /* instance */);
    NWNX_Creature_DoItemCastSpell(oActivator, oActivator, LOCATION_INVALID, SPELL_GATE,
                                  40, 0.0, PROJECTILE_PATH_TYPE_DEFAULT, -1, oWaypoint, "nw_s0_gate");
    DestroyObject(oItem, 0.0);
}

object inst_GetRandomBossWaypoint(object oActivator, string sCategory)
{
    string sBossResref;
    string sSQL = "SELECT B.boss_resref FROM boss_cooldowns B WHERE B.category = ? ORDER BY RAND() LIMIT 1";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, GetStringLowerCase(sCategory));
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sBossResref = NWNX_SQL_ReadDataInActiveRow(0);
    }
    object oBossWP = GetObjectByTag("wp_" + sBossResref + "_spawn_point");
    if(!GetIsObjectValid(oBossWP))
    {
        SendColorMessageToPC(oActivator, "Intance waypoint not found. Please, report to DM.", TXT_COLOR_WHITE);
        return OBJECT_INVALID;
    }
    object oInstanceArea = CreateArea(GetResRef(GetArea(oBossWP)));
    SetLocalInt(oInstanceArea, AREA_FLAG_INSTANCE_BOSS, TRUE);
    SetName(oInstanceArea, ColorText(GetName(oInstanceArea), GetLootColorByLootCategory(sCategory)));
    // remove instance garbage and find entry point
    object oInstanceBossWP;
    object oDelete = GetFirstObjectInArea(oInstanceArea, OBJECT_TYPE_DOOR | OBJECT_TYPE_ENCOUNTER | OBJECT_TYPE_TRIGGER | OBJECT_TYPE_WAYPOINT);
    while(GetIsObjectValid(oDelete))
    {

        if(GetObjectType(oDelete) == OBJECT_TYPE_WAYPOINT && NWNX_Object_GetMapNote(oDelete) != "")
            DestroyObject(oDelete);
        else if(GetObjectType(oDelete) == OBJECT_TYPE_WAYPOINT && GetTag(oDelete) == "wp_" + sBossResref + "_spawn_point")
            oInstanceBossWP = oDelete;
        else if(GetObjectType(oDelete) == OBJECT_TYPE_DOOR && GetIsObjectValid(GetTransitionTarget(oDelete)))
            SetTransitionTarget(oDelete, OBJECT_INVALID);
        else if(GetObjectType(oDelete) == OBJECT_TYPE_TRIGGER && GetIsObjectValid(GetTransitionTarget(oDelete)))
            DestroyObject(oDelete);
        else if(GetObjectType(oDelete) == OBJECT_TYPE_ENCOUNTER)
        {
            SetEncounterActive(FALSE, oDelete);
            SetEventScript(oDelete, EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER, "_on_encounter");
            SetEventScript(oDelete, EVENT_SCRIPT_ENCOUNTER_ON_ENCOUNTER_EXHAUSTED, "_on_encounter");
        }
        oDelete = GetNextObjectInArea(oInstanceArea, OBJECT_TYPE_DOOR | OBJECT_TYPE_ENCOUNTER | OBJECT_TYPE_TRIGGER | OBJECT_TYPE_WAYPOINT);
    }
    vector vOldPos = GetPositionFromLocation(GetLocation(oInstanceBossWP));
    vector vNewPos = GetChangedPosition(vOldPos, 10.0 + IntToFloat(Random(6)), IntToFloat(Random(360)));
    location lEntry = Location(oInstanceArea, vNewPos, IntToFloat(Random(360)));
    int nAreaSize = GetAreaSize(AREA_HEIGHT, oInstanceArea) * GetAreaSize(AREA_WIDTH, oInstanceArea) / 2;
    while(TRUE)
    {
        if(NWNX_Area_GetPathExists(oInstanceArea, vOldPos, vNewPos, nAreaSize) &&
           GetIsWalkableLocation(lEntry) && vOldPos.z == vNewPos.z)
        {
            break;
        }
        vNewPos = GetChangedPosition(vOldPos, 10.0 + IntToFloat(Random(6)), IntToFloat(Random(360)));
        lEntry = Location(oInstanceArea, vNewPos, IntToFloat(Random(360)));
    }
    object oEntryPoint = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lEntry);

    return oEntryPoint;
}

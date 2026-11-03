#include "_inc_players"
#include "x0_i0_stringlib"
#include "x2_inc_switches"
#include "_inc_npc_cast"
#include "_inc_loot_static"

const string LIST_AREA_TAGS_EMPIRE_ARABEL = "_loc_arab_appr|arabcastle|_loc_arab_core";
const string LIST_AREA_TAGS_EMPIRE_OUTPOST = "_loc_inn_outpost";

const string LIST_AREA_TAGS_UNDERDARK_KULG = "_loc_kulg_appr|kulgcastle|_loc_kulg_core";
const string LIST_AREA_TAGS_UNDERDARK_OUTPOST = "_loc_kulg_out";

const string LIST_AREA_TAGS_IRONTHRONE_NEWRENO = "_loc_reno_appr|renocastle|_loc_reno_core";
const string LIST_AREA_TAGS_IRONTHRONE_OUTPOST = "_loc_it_outpost";

const string LIST_AREA_TAGS_DRAGONCULT_DRAGONTEMPLE = "area_dragon_cstl|area_dcult_appr|area_dcult_core";
const string LIST_AREA_TAGS_DRAGONCULT_OUTPOST = "area_dcult_out";

const string LIST_AREA_TAGS_BUFFERS = "arabcastle|kulgcastle|renocastle|area_dragon_cstl|_loc_inn_outpost|_loc_kulg_out|_loc_it_outpost|area_dcult_out";

const int CAPTAINS_COUNT_FOR_TREASURE_UNLOCK = 3;
const int TREASURE_LOOTING_MAX_GOLD = 5000000;

/////////////// Prototypes /////////////////

//
float GetFactionGuardHitpointMultiplier(object oGuard);

//
object CreateGuardAtLocation(int ObjectType, string sResRef, location lLoc, int bUseAppearAnimation, string sNewTag);

//
void CreateGuardsOnArea(object oArea, int iFaction = FACTION_UNKNOWN);

//
void CreateGuardOnWaypoint(object oWP);

//
void RecreateGuardOnWaypoint(object oWP);

//
void CreateDoorOnWaypoint(object oWP, int iFaction = FACTION_UNKNOWN);

//
void SpawnGuardsOnModule();

//
void RespawnGuards(object oArea);

//
void RespawnGuardsInAreas(string sAreasTags);

//
void RespawnFactionGuards(int iFaction);

//
int guard_GetIsCaptain(object oGuard);

//
void guard_SetLockedFactionTreasureDoor(int nFaction, int nState);

//
void guard_GenerateGoldInTreasureChest(int nFaction);

//
void guard_ReturnGoldInTreasure(int nFaction);

//
void guard_SpawnNpcBuffers();

//
void guard_CreateFactionsWeaponShops();

///////////////////////////////////////////////////

float GetFactionGuardHitpointMultiplier(object oGuard)
{
    float fResult = 1.0;
    int nFaction = players_GetFaction(oGuard);
    int nGuardsLevel = factions_GetFactionGuardsLevel(nFaction);
    switch(nGuardsLevel)
    {
        case 1: fResult = 1.5; break;
        case 2: fResult = 2.0; break;
        case 3: fResult = 3.0; break;
        case 4: fResult = 4.0; break;
    }
    return fResult;
}

object CreateGuardAtLocation(int ObjectType, string sResRef, location lLoc, int bUseAppearAnimation, string sNewTag)
{
     object oGuard = CreateObject(ObjectType, sResRef, lLoc, TRUE, sNewTag);
     ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectRegenerate(10, 6.0)), oGuard);
     SetLocalInt(oGuard, "IMGUARD", TRUE);
     // Fameshop HP staff
     int oCurrentHP = NWNX_Object_GetCurrentHitPoints(oGuard);
     int nMaxHitpoints = FloatToInt(oCurrentHP * GetFactionGuardHitpointMultiplier(oGuard));
     NWNX_Object_SetMaxHitPoints(oGuard, nMaxHitpoints);
     NWNX_Object_SetCurrentHitPoints(oGuard, nMaxHitpoints);

     return oGuard;
}

void CreateGuardsOnArea(object oArea, int iFaction = FACTION_UNKNOWN)
{
    if(oArea == OBJECT_INVALID) return;

    string SPAWN_TAG_GUARD = "WPSG_"; //ID of guard spawn
    string SPAWN_TAG_DOOR = "WPSD_"; //ID of door spawn
    object oObject = GetFirstObjectInArea(oArea, OBJECT_TYPE_WAYPOINT | OBJECT_TYPE_DOOR);
    while(GetIsObjectValid(oObject))
    {
        if(GetObjectType(oObject) == OBJECT_TYPE_WAYPOINT)
        {
            if(GetStringLeft(GetTag(oObject), 5) == SPAWN_TAG_GUARD)
                DelayCommand(0.0, CreateGuardOnWaypoint(oObject));
            else if(GetStringLeft(GetTag(oObject), 5) == SPAWN_TAG_DOOR)
                DelayCommand(0.0, CreateDoorOnWaypoint(oObject, iFaction));
        }
        else if(GetObjectType(oObject) == OBJECT_TYPE_DOOR)
        {
            if(players_GetFaction(oObject) > 0)
            {
                AssignCommand(oObject, ActionCloseDoor(oObject));
                DeleteLocalInt(oObject, "Destroyed");
                DeleteLocalInt(oObject, "CURRENT_DAMAGE_AMOUNT");
            }
        }
        oObject = GetNextObjectInArea(oArea, OBJECT_TYPE_WAYPOINT | OBJECT_TYPE_DOOR);
    }
}

void CreateGuardOnWaypoint(object oWP)
{
    // extract creature resref from oWP tag
    string sResRef = GetStringRight(GetTag(oWP), GetStringLength(GetTag(oWP)) - 5);
    // extract area tag from oWP tag
    string sArea = GetStringRight(GetTag(GetArea(oWP)), 8);
    location lLoc = GetLocation(oWP);
    WriteLog("Adding guard #" + IntToString(GetLocalInt(GetModule(), "GUARD_COUNT")) + " with ResRef: " + sResRef + " in Area: " + GetName(GetArea(oWP)), LOG_LEVEL_DEBUG);
    object oGuardWaypoint = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lLoc, FALSE, "POST_G" + sArea + IntToString(GetLocalInt(GetModule(), "GUARD_COUNT")));
    SetLocalInt(oGuardWaypoint, WAYPOINT_VAR_FORCE_SETFACING, TRUE);
    object oGuard = CreateGuardAtLocation(OBJECT_TYPE_CREATURE, sResRef, lLoc, FALSE, "G" + sArea + IntToString(GetLocalInt(GetModule(), "GUARD_COUNT")));
    // save info about guard for re-create
    SetLocalObject(oWP, "SpawnedGuard", oGuard);
    SetLocalString(oWP, "SpawnedGuardTag", GetTag(oGuard));
    SetLocalInt(GetModule(), "GUARD_COUNT", GetLocalInt(GetModule(), "GUARD_COUNT") + 1);
}

void RecreateGuardOnWaypoint(object oWP)
{
    // extract creature resref from oWP tag
    string sResRef = GetStringRight(GetTag(oWP), GetStringLength(GetTag(oWP)) - 5);
    // extract area tag from oWP tag
    string sArea = GetStringRight(GetTag(GetArea(oWP)), 8);
    location lLoc = GetLocation(oWP);
    string sGuardTag = GetLocalString(oWP, "SpawnedGuardTag");
    object oGuard = CreateGuardAtLocation(OBJECT_TYPE_CREATURE, sResRef, lLoc, FALSE, sGuardTag);
    // save info about guard for re-create
    SetLocalObject(oWP, "SpawnedGuard", oGuard);
}

void CreateDoorOnWaypoint(object oWP, int iFaction = FACTION_UNKNOWN)
{
    // extract creature resref from oWP tag
    string sResRef = GetStringRight(GetTag(oWP), GetStringLength(GetTag(oWP)) - 5);
    location lLoc = GetLocation(oWP);
    WriteLog("Adding door with ResRef: " + sResRef + " in Area: " + GetName(GetArea(oWP)), LOG_LEVEL_DEBUG);
    object oDoor = CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, lLoc, FALSE);
    if(iFaction != FACTION_UNKNOWN)
        players_SetFaction(oDoor, iFaction);
}

void SpawnGuardsOnModule()
{
    string sAreasTags = LIST_AREA_TAGS_EMPIRE_ARABEL            + "|" + LIST_AREA_TAGS_EMPIRE_OUTPOST      + "|" +
                        LIST_AREA_TAGS_UNDERDARK_KULG           + "|" + LIST_AREA_TAGS_UNDERDARK_OUTPOST   + "|" +
                        LIST_AREA_TAGS_IRONTHRONE_NEWRENO       + "|" + LIST_AREA_TAGS_IRONTHRONE_OUTPOST  + "|" +
                        LIST_AREA_TAGS_DRAGONCULT_DRAGONTEMPLE  + "|" + LIST_AREA_TAGS_DRAGONCULT_OUTPOST;

    struct sStringTokenizer stAreasTok = GetStringTokenizer(sAreasTags, "|");
    string sAreaTag;
    object oArea;
    while(HasMoreTokens(stAreasTok))
    {
        stAreasTok = AdvanceToNextToken(stAreasTok);
        sAreaTag = GetNextToken(stAreasTok);
        oArea = GetObjectByTag(sAreaTag);
        int nAreaFaction = players_GetFaction(oArea);
        if(GetIsObjectValid(oArea) && players_GetIsFactionEnabled(nAreaFaction))
            CreateGuardsOnArea(oArea, nAreaFaction);
        else
            WriteLog("Invalid or disabled Area with tag '" + sAreaTag + "', skipping...", LOG_LEVEL_WARNING);
    }
    AssignCommand(GetModule(), DelayCommand(10.0, DeleteLocalInt(GetModule(), "GUARD_COUNT")));
}

void RespawnGuards(object oArea)
{
    if(!GetIsObjectValid(oArea))
        return;
    string SPAWN_TAG_GUARD = "WPSG_"; // ID for guards spawn
    object oWaypointSpawn = GetFirstObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
    while(GetIsObjectValid(oWaypointSpawn))
    {
        if(GetStringLeft(GetTag(oWaypointSpawn), 5) == SPAWN_TAG_GUARD)
        {
            if(GetIsObjectValid(GetLocalObject(oWaypointSpawn, "SpawnedGuard")))
                ForceRest(GetLocalObject(oWaypointSpawn, "SpawnedGuard"));
            else
                DelayCommand(0.0, RecreateGuardOnWaypoint(oWaypointSpawn));
        }
        oWaypointSpawn = GetNextObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
    }
}

void RespawnGuardsInAreas(string sAreasTags)
{
    string sAreasTags;
    struct sStringTokenizer stAreasTok = GetStringTokenizer(sAreasTags, "|");
    string sAreaTag;
    object oArea;
    while(HasMoreTokens(stAreasTok))
    {
        stAreasTok = AdvanceToNextToken(stAreasTok);
        sAreaTag = GetNextToken(stAreasTok);
        oArea = GetObjectByTag(sAreaTag);
        if(GetIsObjectValid(oArea))
            RespawnGuards(oArea);
        else
            WriteLog("Invalid Area with tag '" + sAreaTag + "', skipping...", LOG_LEVEL_ERROR);
    }
}

void RespawnFactionGuards(int iFaction)
{
    string sAreasTags;
    switch(iFaction)
    {
        case FACTION_EMPIRE:        sAreasTags = LIST_AREA_TAGS_EMPIRE_ARABEL           + "|" + LIST_AREA_TAGS_EMPIRE_OUTPOST;     break;
        case FACTION_UNDERDARK:     sAreasTags = LIST_AREA_TAGS_UNDERDARK_KULG          + "|" + LIST_AREA_TAGS_UNDERDARK_OUTPOST;  break;
        case FACTION_IRON_THRONE:   sAreasTags = LIST_AREA_TAGS_IRONTHRONE_NEWRENO      + "|" + LIST_AREA_TAGS_IRONTHRONE_OUTPOST; break;
        case FACTION_DRAGON_CULT:   sAreasTags = LIST_AREA_TAGS_DRAGONCULT_DRAGONTEMPLE + "|" + LIST_AREA_TAGS_DRAGONCULT_OUTPOST; break;
    }
    struct sStringTokenizer stAreasTok = GetStringTokenizer(sAreasTags, "|");
    string sAreaTag;
    object oArea;
    while(HasMoreTokens(stAreasTok))
    {
        stAreasTok = AdvanceToNextToken(stAreasTok);
        sAreaTag = GetNextToken(stAreasTok);
        oArea = GetObjectByTag(sAreaTag);
        if(GetIsObjectValid(oArea))
            RespawnGuards(oArea);
        else
            WriteLog("Invalid Area with tag '" + sAreaTag + "', skipping...", LOG_LEVEL_ERROR);
    }
}

int guard_GetIsCaptain(object oGuard)
{
    string sGuardResref = GetResRef(oGuard);
    if(sGuardResref == "cr_gu_ar_cap" || sGuardResref == "cr_gu_ku_cap" || sGuardResref == "cr_gu_re_cap" || sGuardResref == "cr_gu_dr_cap")
        return TRUE;
    return FALSE;
}

void guard_SetLockedFactionTreasureDoor(int nFaction, int nState)
{
    object oDoor = GetObjectByTag("DOOR_2_TreasureRoom_Faction_" + IntToString(nFaction));
    if(GetIsObjectValid(oDoor))
    {
        AssignCommand(oDoor, ActionCloseDoor(oDoor));
        SetLocked(oDoor, nState);
    }
}

void guard_GenerateGoldInTreasureChest(int nFaction)
{
    // dont create gold if disabled
    if(!players_GetIsFactionEnabled(nFaction)) return;
    // find faction treasure chest at fill it with gold
    object oChest = GetObjectByTag("treasure_chest_faction_" + IntToString(nFaction));
    AssignCommand(oChest, SetLocked(oChest, FALSE));
    int nFactionChestGoldValue = npc_Caster_GetFactionGold(nFaction);
    if(nFactionChestGoldValue > TREASURE_LOOTING_MAX_GOLD)
        nFactionChestGoldValue = TREASURE_LOOTING_MAX_GOLD;
    npc_Caster_UpdateFactionGold(nFaction, -nFactionChestGoldValue);
    GenerateCustomGoldOnTarget(oChest, nFactionChestGoldValue, nFaction);
    WriteLog(IntToString(nFactionChestGoldValue) + " GP has been generated in " + players_GetFactionName(nFaction, FALSE) + " faction treasure chest!");
}

void guard_ReturnGoldInTreasure(int nFaction)
{
    object oChest = GetObjectByTag("treasure_chest_faction_" + IntToString(nFaction));
    object oGold = GetFirstItemInInventory(oChest);
    while(GetIsObjectValid(oGold))
    {
        if(GetResRef(oGold) == CONST_ITEM_GOLD)
        {
            int nGoldValue = GetLocalInt(oGold, "GENERATED_GOLD_PIECE");
            if(nGoldValue > 0)
                npc_Caster_UpdateFactionGold(nFaction, nGoldValue);
            DestroyObject(oGold);
        }
        oGold = GetNextItemInInventory(oChest);
    }
}

void guard_SpawnNpcBuffers()
{
    struct sStringTokenizer stAreasTok = GetStringTokenizer(LIST_AREA_TAGS_BUFFERS, "|");
    string sAreaTag;
    object oArea;
    while(HasMoreTokens(stAreasTok))
    {
        stAreasTok = AdvanceToNextToken(stAreasTok);
        sAreaTag = GetNextToken(stAreasTok);
        oArea = GetObjectByTag(sAreaTag);
        int nFaction = players_GetFaction(oArea);
        // dont create NPCs if disabled
        if(!players_GetIsFactionEnabled(nFaction)) continue;
        // iterate by waiponts and create clerics
        string sClericResref = factions_GetFactionClericResref(nFaction);
        if(GetIsObjectValid(oArea))
        {
            object oWaypoint = GetFirstObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
            while(GetIsObjectValid(oWaypoint))
            {
                if(GetTag(oWaypoint) == "WP_clr_anchor")
                    DelayCommand(0.0, factions_CreateFactionCleric(sClericResref, GetLocation(oWaypoint)));
                oWaypoint = GetNextObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
            }
        }
    }
}


void guard_CreateFactionsWeaponShops()
{
    object oTemplate = GetObjectByTag("weapon_shop_template");
    int nFaction;
    for(nFaction = 1; nFaction <= 4; nFaction++)
    {
        if(!players_GetIsFactionEnabled(nFaction)) continue;
        int nNth = 0;
        object oWP = GetObjectByTag("WP_FACTION_" + IntToString(nFaction) + "_WEAPON_SHOP", nNth);
        while(GetIsObjectValid(oWP))
        {
            string sTag = "";
            switch(nFaction)
            {
                case FACTION_EMPIRE:      sTag = "empire_weapon_shop"; break;
                case FACTION_UNDERDARK:   sTag = "underdark_weapon_shop"; break;
                case FACTION_IRON_THRONE: sTag = "iron_throne_weapon_shop"; break;
                case FACTION_DRAGON_CULT: sTag = "dragoncult_weapon_shop"; break;
            }
            if(sTag != "")
                CopyObject(oTemplate, GetLocation(oWP), OBJECT_INVALID, sTag);
            oWP = GetObjectByTag("WP_FACTION_" + IntToString(nFaction) + "_WEAPON_SHOP", ++nNth);
        }
    }
}

//void main(){}

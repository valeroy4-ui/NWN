#include "_inc_champ_boss"
#include "nw_inc_gff"
#include "crift_hook"
#include "nwnx_area"

int CRF_Category(string resref)
{
    string cache = "CRIFT_CAT_" + resref;
    object module = GetModule();
    int cached = GetLocalInt(module, cache);
    if (cached) return cached - 1;
    int result = 0;
    NWNX_SQL_PrepareQuery("SELECT category FROM boss_cooldowns WHERE boss_resref = ?");
    NWNX_SQL_PreparedString(0, resref);
    if (NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        string category = GetStringLowerCase(NWNX_SQL_ReadDataInActiveRow(0));
        if (category == "blue") result = 1;
        else if (category == "green") result = 2;
        else if (category == "purple") result = 3;
        else if (category == "red") result = 4;
        else if (category == "artifact") result = 5;
    }
    SetLocalInt(module, cache, result + 1);
    return result;
}

int CRF_IsMob(object mob)
{
    if (GetIsPC(mob) || GetIsDM(mob) || GetIsObjectValid(GetMaster(mob))) return FALSE;
    if (GetIsEncounterCreature(mob) || GetLocalInt(mob, "BOSS_TYPE") ||
        GetLocalInt(mob, "CRIFT_COUNTED")) return TRUE;
    object pc = GetLocalObject(GetArea(mob), "CRIFT_OPENER");
    return GetIsObjectValid(pc) && GetIsEnemy(mob, pc);
}

void CRF_Enhance(object mob)
{
    object area = GetArea(mob);
    if (!GetLocalInt(area, "CRIFT_AREA") || GetLocalInt(area, "CRIFT_CLOSED") ||
        !CRF_IsMob(mob) || GetIsDead(mob) || GetLocalInt(mob, "CRIFT_FINAL_GRAND") ||
        GetLocalInt(area, "CRIFT_GRAND_CREATING")) return;
    int boss = GetLocalInt(mob, "BOSS_TYPE");
    if (!boss) boss = CRF_Category(GetResRef(mob));
    if (boss == 1)
    {
        SetLocalInt(area, "CRIFT_HAS_MINI", TRUE);
        if (!GetLocalInt(mob, "MUTATED"))
        {
            champion_ApplyAllBonuses(mob, FALSE, TRUE);
            SetLocalInt(mob, "MUTATED", TRUE);
        }
    }
    else if (!boss && !champion_GetIsChampion(mob) && !champion_GetIsEliteChampion(mob))
        champion_ApplyAllBonuses(mob);
    CRF_Register(mob);
}

object CRF_CreatePortal(location loc, string tag)
{
    json portal = GffCreateObject(OBJECT_TYPE_PLACEABLE);
    portal = GffAddDword(portal, "Appearance", 4308);
    portal = GffAddByte(portal, "AnimationState", 0);
    portal = GffAddShort(portal, "CurrentHP", 100);
    portal = GffAddLocString(portal, "LocName", "Champion Rift");
    portal = GffAddLocString(portal, "Description", "An open passage to a champion-filled echo of this area. Lasts one hour.");
    portal = GffAddResRef(portal, "OnUsed", "crift_use");
    portal = GffAddResRef(portal, "TemplateResRef", "crift_portal");
    portal = GffAddByte(portal, "Plot", TRUE);
    portal = GffAddByte(portal, "Useable", TRUE);
    portal = GffAddString(portal, "Tag", tag);
    return JsonToObject(portal, loc);
}

void CRF_InspectTemplate(object area)
{
    object obj = GetFirstObjectInArea(area, OBJECT_TYPE_ENCOUNTER | OBJECT_TYPE_TRIGGER | OBJECT_TYPE_CREATURE);
    float best = 35.0;
    string grand;
    int mini = FALSE;
    while (GetIsObjectValid(obj))
    {
        int type = GetObjectType(obj);
        if (type == OBJECT_TYPE_ENCOUNTER)
        {
            int i;
            for (i = 0; i < NWNX_Encounter_GetNumberOfCreaturesInEncounterList(obj); i++)
            {
                struct NWNX_Encounter_CreatureListEntry entry = NWNX_Encounter_GetEncounterCreatureByIndex(obj, i);
                int category = CRF_Category(entry.resref);
                if (category == 1) mini = TRUE;
                if (!category && entry.challengeRating > best)
                {
                    best = entry.challengeRating;
                    grand = entry.resref;
                }
            }
        }
        else if (type == OBJECT_TYPE_TRIGGER && GetLocalString(obj, "BOSS_RESREF") != "")
        {
            if (CRF_Category(GetLocalString(obj, "BOSS_RESREF")) == 1) mini = TRUE;
        }
        else if (type == OBJECT_TYPE_CREATURE && CRF_IsMob(obj))
        {
            int category = CRF_Category(GetResRef(obj));
            if (category == 1) mini = TRUE;
            if (!category && GetChallengeRating(obj) > best)
            {
                best = GetChallengeRating(obj);
                grand = GetResRef(obj);
            }
        }
        obj = GetNextObjectInArea(area, OBJECT_TYPE_ENCOUNTER | OBJECT_TYPE_TRIGGER | OBJECT_TYPE_CREATURE);
    }
    SetLocalInt(area, "CRIFT_HAS_MINI", mini);
    SetLocalString(area, "CRIFT_GRAND_REF", grand);
}

void CRF_ConfigureClone(object area)
{
    int total = 0;
    object obj = GetFirstObjectInArea(area, OBJECT_TYPE_ENCOUNTER | OBJECT_TYPE_DOOR | OBJECT_TYPE_TRIGGER);
    while (GetIsObjectValid(obj))
    {
        int type = GetObjectType(obj);
        if (type == OBJECT_TYPE_ENCOUNTER)
        {
            SetEncounterActive(FALSE, obj);
            NWNX_Encounter_SetCanReset(obj, FALSE);
            NWNX_Encounter_SetPlayerTriggeredOnly(obj, TRUE);
            SetEventScript(obj, EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER, "crift_enc");
            SetEventScript(obj, EVENT_SCRIPT_ENCOUNTER_ON_ENCOUNTER_EXHAUSTED, "crift_enc_done");
            DeleteLocalInt(obj, "CRIFT_FIRED");
            if (NWNX_Encounter_GetNumberOfCreaturesInEncounterList(obj) > 0) total++;
        }
        else if (type == OBJECT_TYPE_DOOR)
            SetTransitionTarget(obj, OBJECT_INVALID);
        else if (type == OBJECT_TYPE_TRIGGER && GetIsObjectValid(GetTransitionTarget(obj)))
            DestroyObject(obj);
        obj = GetNextObjectInArea(area, OBJECT_TYPE_ENCOUNTER | OBJECT_TYPE_DOOR | OBJECT_TYPE_TRIGGER);
    }
    SetLocalInt(area, "CRIFT_ENCOUNTERS", total);
}

int CRF_AllCleared(object area)
{
    if (GetLocalInt(area, "CRIFT_FIRED_COUNT") < GetLocalInt(area, "CRIFT_ENCOUNTERS") ||
        GetLocalInt(area, "CRIFT_SPAWN_WAIT") || GetLocalInt(area, "CRIFT_CREATED") <= 0 ||
        GetLocalInt(area, "CRIFT_CREATED") != GetLocalInt(area, "CRIFT_KILLED")) return FALSE;
    object obj = GetFirstObjectInArea(area, OBJECT_TYPE_ENCOUNTER | OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(obj))
    {
        if (GetObjectType(obj) == OBJECT_TYPE_ENCOUNTER && NWNX_Encounter_GetCurrentNumSpawned(obj) > 0)
            return FALSE;
        if (GetObjectType(obj) == OBJECT_TYPE_CREATURE && CRF_IsMob(obj) && !GetIsDead(obj))
            return FALSE;
        obj = GetNextObjectInArea(area, OBJECT_TYPE_ENCOUNTER | OBJECT_TYPE_CREATURE);
    }
    return TRUE;
}

void CRF_Grand(object area)
{
    if (GetLocalInt(area, "CRIFT_HAS_MINI") || GetLocalInt(area, "CRIFT_GRAND_DONE") ||
        GetLocalInt(area, "CRIFT_CLOSED") || GetLocalString(area, "CRIFT_GRAND_REF") == "" ||
        !CRF_AllCleared(area)) return;
    // Latch before creation: two death/encounter notifications cannot spawn two grands.
    SetLocalInt(area, "CRIFT_GRAND_DONE", TRUE);
    location loc = GetLocalLocation(area, "CRIFT_LAST_KILL");
    if (GetAreaFromLocation(loc) != area) loc = GetLocalLocation(area, "CRIFT_ENTRY");
    SetLocalInt(area, "CRIFT_GRAND_CREATING", TRUE);
    object grand = CreateObject(OBJECT_TYPE_CREATURE, GetLocalString(area, "CRIFT_GRAND_REF"), loc, TRUE);
    if (!GetIsObjectValid(grand))
    {
        DeleteLocalInt(area, "CRIFT_GRAND_CREATING");
        DeleteLocalInt(area, "CRIFT_GRAND_DONE");
        PrintString("[CRIFT ERROR] Grand template failed: " + GetLocalString(area, "CRIFT_GRAND_REF"));
        return;
    }
    SetLocalInt(grand, "CRIFT_FINAL_GRAND", TRUE);
    DeleteLocalInt(grand, "IAMCHAMPION");
    champion_ApplyAllBonuses(grand, TRUE);
    DeleteLocalInt(area, "CRIFT_GRAND_CREATING");
    SetLocalObject(area, "CRIFT_GRAND", grand);
    PrintString("[CRIFT] Final grand spawned: " + GetResRef(grand));
    object pc = GetFirstObjectInArea(area, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(pc))
    {
        if (GetIsPC(pc)) SendMessageToPC(pc, "The last wave is defeated. A Grand Champion has appeared!");
        pc = GetNextObjectInArea(area, OBJECT_TYPE_CREATURE);
    }
}

#include "crift_inc"
#include "crift_routes"
#include "crift_music"
void main()
{
    object source = OBJECT_SELF;
    if (!GetIsObjectValid(source) || !GetLocalInt(source, "CRIFT_PENDING")) return;
    DeleteLocalInt(source, "CRIFT_PENDING");
    if (GetIsObjectValid(GetLocalObject(source, "CRIFT_ACTIVE")) || GetLocalInt(source, "CRIFT_AREA")) return;
    location origin = GetLocalLocation(source, "CRIFT_REQUEST_LOC");
    object opener = GetLocalObject(source, "CRIFT_REQUEST_PC");
    if (!NWNX_SQL_ExecuteQuery("SELECT category FROM boss_cooldowns LIMIT 1"))
    {
        PrintString("[CRIFT ERROR] Boss category database unavailable; no copy created");
        return;
    }
    object area = CreateArea(GetResRef(source));
    if (!GetIsObjectValid(area) || area == source)
    {
        PrintString("[CRIFT ERROR] Cannot clone " + GetResRef(source));
        return;
    }
    SetLocalInt(area, "CRIFT_AREA", TRUE);
    // Existing boss spawners bypass the world's cooldown only in this new copy.
    SetLocalInt(area, AREA_FLAG_INSTANCE_BOSS, TRUE);
    SetLocalObject(area, "CRIFT_SOURCE", source);
    SetLocalString(area, "CRIFT_TEMPLATE", GetResRef(source));
    SetLocalObject(area, "CRIFT_OPENER", opener);
    SetLocalLocation(area, "CRIFT_RETURN", origin);
    SetName(area, GetName(source) + " - Champion Rift");
    // Arrival anchors in a copy must never shadow the world's transition targets.
    if (!CRF_IsolateRoutes(area, source))
    {
        AssignCommand(GetModule(), DelayCommand(0.1, ExecuteScript("crift_close", area)));
        PrintString("[CRIFT ERROR] Cannot isolate copy routes; copy queued for cleanup");
        return;
    }
    CRF_InspectTemplate(area);
    CRF_ConfigureClone(area);
    CRFM_Apply(area);
    location entry = Location(area, GetPositionFromLocation(origin), GetFacingFromLocation(origin));
    SetLocalLocation(area, "CRIFT_ENTRY", entry);
    string tag = "CRIFT_" + ObjectToString(area);
    object entrance = CRF_CreatePortal(origin, tag);
    object exit = CRF_CreatePortal(entry, tag);
    if (!GetIsObjectValid(entrance) || !GetIsObjectValid(exit))
    {
        if (GetIsObjectValid(entrance)) DestroyObject(entrance);
        if (GetIsObjectValid(exit)) DestroyObject(exit);
        AssignCommand(GetModule(), DelayCommand(0.1, ExecuteScript("crift_close", area)));
        PrintString("[CRIFT ERROR] Portal pair failed; copy queued for cleanup");
        return;
    }
    SetLocalObject(source, "CRIFT_ACTIVE", area);
    SetLocalObject(area, "CRIFT_ENTRANCE", entrance);
    SetLocalObject(area, "CRIFT_EXIT", exit);
    SetLocalObject(entrance, "CRIFT_AREA", area);
    SetLocalObject(exit, "CRIFT_AREA", area);
    SetLocalLocation(entrance, "CRIFT_DEST", entry);
    SetLocalLocation(exit, "CRIFT_DEST", origin);
    AssignCommand(GetModule(), DelayCommand(0.1, ExecuteScript("crift_watch", area)));
    AssignCommand(GetModule(), DelayCommand(CRF_LIFETIME, ExecuteScript("crift_close", area)));
    PrintString("[CRIFT] Opened " + GetResRef(source) + " copy=" + ObjectToString(area) +
        " encounters=" + IntToString(GetLocalInt(area, "CRIFT_ENCOUNTERS")) +
        " mini=" + IntToString(GetLocalInt(area, "CRIFT_HAS_MINI")) +
        " grand=" + GetLocalString(area, "CRIFT_GRAND_REF"));
    if (GetIsPC(opener)) SendMessageToPC(opener, "A Champion Rift has opened nearby. It will close in one hour.");
}

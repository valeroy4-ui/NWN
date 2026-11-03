// Isolate arrival anchors of a new Champion Rift from global world routing.
// Retain tags of local chests, boss triggers and ordinary non-transition doors.
int CRF_IsolateRoutes(object area, object source)
{
    if (!GetIsObjectValid(area) || !GetIsObjectValid(source) || area == source ||
        !GetLocalInt(area, "CRIFT_AREA") || GetLocalObject(area, "CRIFT_SOURCE") != source)
        return FALSE;
    string prefix = "CRF_" + ObjectToString(area) + "_";
    string originalAreaTag = GetTag(area);
    SetTag(area, prefix + originalAreaTag);
    if (GetTag(area) != prefix + originalAreaTag) return FALSE;
    SetLocalString(area, "CRIFT_ROUTE_PREFIX", prefix);
    object obj = GetFirstObjectInArea(area, OBJECT_TYPE_WAYPOINT | OBJECT_TYPE_DOOR);
    while (GetIsObjectValid(obj))
    {
        if (GetArea(obj) != area) return FALSE;
        string tag = GetTag(obj);
        if (tag != "" && (GetObjectType(obj) == OBJECT_TYPE_WAYPOINT ||
            GetIsObjectValid(GetTransitionTarget(obj))))
        {
            string isolated = prefix + tag;
            SetLocalString(obj, "CRIFT_ORIG_TAG", tag);
            SetTag(obj, isolated);
            if (GetTag(obj) != isolated) return FALSE;
            SetLocalString(area, "CRIFT_ROUTE_" + tag, isolated);
        }
        obj = GetNextObjectInArea(area, OBJECT_TYPE_WAYPOINT | OBJECT_TYPE_DOOR);
    }
    // Boss spawn uses nearest waypoint by tag. Keep the link within this copy.
    obj = GetFirstObjectInArea(area, OBJECT_TYPE_TRIGGER);
    while (GetIsObjectValid(obj))
    {
        if (GetArea(obj) != area) return FALSE;
        // These three ordinary exits teleport by script, without a native transition target.
        string enter = GetEventScript(obj, EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER);
        if (enter == "_port_adventures" || enter == "_port_buffzone" || enter == "_port_temple")
            SetEventScript(obj, EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER, "");
        string waypoint = GetLocalString(obj, "BOSS_SPAWN_WAYPOINT_TAG");
        if (waypoint != "")
        {
            string isolated = GetLocalString(area, "CRIFT_ROUTE_" + waypoint);
            if (isolated == "") return FALSE;
            SetLocalString(obj, "BOSS_SPAWN_WAYPOINT_TAG", isolated);
        }
        obj = GetNextObjectInArea(area, OBJECT_TYPE_TRIGGER);
    }
    return TRUE;
}

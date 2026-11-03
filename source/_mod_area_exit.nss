#include "_inc_players"
#include "_inc_areas"
void main()
{
    object area = OBJECT_SELF;
    object pc = GetExitingObject();
    object dest = GetLocalObject(pc, "CRIFT_MOVE_DEST");
    int ownCopy = GetLocalInt(area, "CRIFT_AREA");
    int enteringCopy = GetLocalInt(dest, "CRIFT_AREA") &&
        GetLocalObject(dest, "CRIFT_SOURCE") == area &&
        GetLocalObject(area, "CRIFT_ACTIVE") == dest;
    if (GetResRef(area) == "_loc_testarea" && (ownCopy || enteringCopy))
    {
        // Preserve the TestRoom boot for every unrelated exit.
        if (GetIsPC(pc) && !GetIsDM(pc) && players_GetPCPersistentID(pc) > 0)
        {
            string key = "FACTION_" + IntToString(players_GetFaction(pc)) + "_PLAYERS_COUNT";
            int count = GetLocalInt(area, key) - 1;
            SetLocalInt(area, key, count > 0 ? count : 0);
            SetLocalObject(pc, "LAST_AREA", area);
        }
        DeleteLocalInt(area, AREA_FLAG_PLAYERS_COUNT_WITH_DMS);
        DeleteLocalInt(area, AREA_FLAG_PLAYERS_COUNT_WITHOUT_DMS);
    }
    else ExecuteScript("crf_base_exit", area);
    DeleteLocalObject(pc, "CRIFT_MOVE_DEST");
}

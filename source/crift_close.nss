#include "nwnx_area"
void main()
{
    object area = OBJECT_SELF;
    if (!GetIsObjectValid(area) || !GetLocalInt(area, "CRIFT_AREA")) return;
    SetLocalInt(area, "CRIFT_CLOSED", TRUE);
    object entrance = GetLocalObject(area, "CRIFT_ENTRANCE");
    object exit = GetLocalObject(area, "CRIFT_EXIT");
    if (GetIsObjectValid(entrance)) DestroyObject(entrance);
    if (GetIsObjectValid(exit)) DestroyObject(exit);
    location back = GetLocalLocation(area, "CRIFT_RETURN");
    object mob = GetFirstObjectInArea(area, OBJECT_TYPE_CREATURE | OBJECT_TYPE_ENCOUNTER);
    while (GetIsObjectValid(mob))
    {
        if (GetObjectType(mob) == OBJECT_TYPE_ENCOUNTER) SetEncounterActive(FALSE, mob);
        else if (GetIsPC(mob) && GetIsObjectValid(GetAreaFromLocation(back)))
        {
            SendMessageToPC(mob, "The Champion Rift has closed. You are returned to the entrance.");
            AssignCommand(mob, ClearAllActions(TRUE));
            AssignCommand(mob, JumpToLocation(back));
        }
        mob = GetNextObjectInArea(area, OBJECT_TYPE_CREATURE | OBJECT_TYPE_ENCOUNTER);
    }
    // Never destroy an occupied area; movement/area events may finish next frame.
    if (NWNX_Area_GetNumberOfPlayersInArea(area) > 0)
    {
        AssignCommand(GetModule(), DelayCommand(1.0, ExecuteScript("crift_close", area)));
        return;
    }
    object source = GetLocalObject(area, "CRIFT_SOURCE");
    if (GetLocalObject(source, "CRIFT_ACTIVE") == area) DeleteLocalObject(source, "CRIFT_ACTIVE");
    if (DestroyArea(area) <= 0)
        AssignCommand(GetModule(), DelayCommand(5.0, ExecuteScript("crift_close", area)));
    else PrintString("[CRIFT] Copy destroyed");
}

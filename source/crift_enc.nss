#include "crift_inc"
void main()
{
    object area = GetArea(OBJECT_SELF);
    if (!GetLocalInt(area, "CRIFT_AREA") || GetLocalInt(area, "CRIFT_CLOSED") ||
        !GetIsPC(GetEnteringObject()) || GetLocalInt(OBJECT_SELF, "CRIFT_FIRED")) return;
    SetLocalInt(OBJECT_SELF, "CRIFT_FIRED", TRUE);
    SetLocalInt(area, "CRIFT_FIRED_COUNT", GetLocalInt(area, "CRIFT_FIRED_COUNT") + 1);
    SetLocalInt(area, "CRIFT_SPAWN_WAIT", GetLocalInt(area, "CRIFT_SPAWN_WAIT") + 1);
    // Same native encounter activation used by Cormyr's _on_encounter.
    SetEncounterActive(TRUE);
    SetEncounterActive(FALSE);
    object mob = GetFirstObjectInArea(area, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(mob))
    {
        if (NWNX_Creature_GetEncounter(mob) == OBJECT_SELF) CRF_Enhance(mob);
        mob = GetNextObjectInArea(area, OBJECT_TYPE_CREATURE);
    }
    AssignCommand(GetModule(), DelayCommand(1.0, SetLocalInt(area, "CRIFT_SPAWN_WAIT",
        GetLocalInt(area, "CRIFT_SPAWN_WAIT") - 1)));
}

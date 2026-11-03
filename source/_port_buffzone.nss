#include "_inc_factions"


void main()
{
    object oPC = GetEnteringObject();

    // sanity check
    if(GetIsDM(oPC) || !players_GetIsFactionAndAlignmentValid(oPC))
        return;
    int nFaction = players_GetFaction(oPC);
    if(!players_GetIsFactionEnabled(nFaction))
    {
        AssignCommand(oPC, ClearAllActions());
        DelayCommand(0.2, FloatingColorTextStringOnCreature("Faction disabled.", TXT_COLOR_RED, oPC, FALSE));
        return;
    }
    // get or create faction buffzone!
    object oCash = players_GetFactionSystemNPC(nFaction);
    object oBuffZoneArea = GetLocalObject(oCash, BUFFZONE_AREA_OBJECT);
    if(!GetIsObjectValid(oBuffZoneArea))
        factions_CreateFactionBuffzone(nFaction);
    // teleport player into created buffzone
    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, ActionJumpToObject(GetLocalObject(oCash, BUFFZONE_ENTER_WAYPOINT)));
}



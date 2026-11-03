#include "_inc_players"


void main()
{
    object oPC = GetEnteringObject();
    // sanity check
    if(GetIsDM(oPC) || !players_GetIsFactionAndAlignmentValid(oPC))
        return;
    if(!players_GetIsFactionEnabled(players_GetFaction(oPC)))
    {
        AssignCommand(oPC, ClearAllActions());
        DelayCommand(0.2, FloatingColorTextStringOnCreature("Faction disabled.", TXT_COLOR_RED, oPC, FALSE));
        return;
    }
    AssignCommand (oPC, ClearAllActions());
    AssignCommand (oPC, ActionJumpToObject(players_GetFactionEntryPoint(players_GetFaction(oPC))));
}

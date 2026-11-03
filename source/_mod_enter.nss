#include "_inc_players"

void EnterNamedTestRoom(object p)
{
    if(!GetIsObjectValid(p) || !GetIsPC(p) || GetIsDM(p) || !players_IsTestCharacter(p)) return;
    object waypoint=GetWaypointByTag("toTestArea");
    if(!GetIsObjectValid(waypoint))
    { SendMessageToPC(p,"[TESTROOM] Waypoint toTestArea not found; no transfer.");return; }
    AssignCommand(p,ClearAllActions());
    AssignCommand(p,JumpToLocation(GetLocation(waypoint)));
    PrintString("[TESTROOM] "+GetName(p,TRUE)+" entered "+GetName(GetArea(waypoint)));
}

void main()
{
    object oPC = GetEnteringObject();
    if (!GetIsPC(oPC) || GetIsDM(oPC)) return;
    ExecuteScript("ct_cormyr_login", oPC);
    if(GetLocalInt(oPC,"CT_LOGIN_READY")) ExecuteScript("cs_login_restore", oPC);
    DelayCommand(0.5, ExecuteScript("sv257_ui_watch", oPC));

    SendMessageToPC(oPC, "Cormyr test: J opens the Fame Shop.");
    SendMessageToPC(oPC, "Type !lab in chat to enter the spell laboratory.");

    if(players_IsTestCharacter(oPC)) DelayCommand(0.3,EnterNamedTestRoom(oPC));
    PrintString("[CORMYR TEST] Player entered");
}

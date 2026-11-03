// anti speedhack

const string CURRENT_DAMAGE_AMOUNT_VAR = "CURRENT_DAMAGE_AMOUNT";

void main()
{
    object oPC = GetSpellTargetObject();
    SetLocalInt(oPC, "sm_disable", TRUE);
/*
    object oPC = GetSpellTargetObject();
    if(!GetIsObjectValid(GetAreaFromLocation(GetLocalLocation(oPC, "sm_location"))))
    {
        ExecuteScript("spdmon_start", oPC);
        SendMessageToAllDMs("[DistanceMonitor]: started on Player: " + GetName(oPC)+ " ("+ GetPCPlayerName(oPC) + ")");
    }
    else
    {
        SetLocalInt(oPC, "sm_disable", TRUE);
    }
*/
    DeleteLocalInt(oPC, "Destroyed");
    AssignCommand(oPC, ActionCloseDoor(oPC));
    DeleteLocalInt(oPC, CURRENT_DAMAGE_AMOUNT_VAR);
}

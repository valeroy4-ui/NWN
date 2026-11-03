#include "_inc_death"
#include "_inc_generic"

void main()
{
    object oDamager = GetLastDamager();
    string sKilledName = GetLocalString(OBJECT_SELF, "CORPSENAME");
    string sTombKillerName = GetName(oDamager);
    object oKilled = GetLocalObject(OBJECT_SELF, "DEAD_OPC");

    DeleteLocalObject(death_GetCorpseHolder(), "GRAVESTONE_OF_" + IntToString(GetLocalInt(OBJECT_SELF, "PLAYERID")));  // clear cashed gravestone

    object oSender = GetFirstPC();
    while (GetIsObjectValid(oSender))
    {
        if (oSender == oKilled)
            FloatingTextStringOnCreature(sTombKillerName+" has desecrated gravestone of " + sKilledName, oSender, FALSE);
        else
            SendMessageToPC(oSender, sTombKillerName+" has desecrated gravestone of " + sKilledName);
        oSender = GetNextPC();
    }
    generic_PlayAudioStreamForPlayerArea(OBJECT_SELF, "mus_wrecker");
}

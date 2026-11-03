#include "_inc_death"
#include "_inc_areas"
#include "_inc_generic"


void main()
{
    object oPC              = GetLastPlayerDied();
    ExecuteScript("pdk_srv_death", oPC);
    object oArea            = GetIsObjectValid(GetArea(oPC)) ? GetArea(oPC) : GetAreaFromLocation(GetLocalLocation(oPC, "LAST_PLAYER_LOCATION"));
    int iKilledPlayerID     = players_GetPCPersistentID(oPC);

    if (GetAreaFlag(oArea, AREA_FLAG_NO_DEATH))
    {
        death_Ressurect(oPC);
        RemoveEffectsAfterDeath(oPC);
        DelayCommand(0.0, ExecuteScript("_mod_instant_eff", oPC));
    }
    else
    {
        ExecuteScript("_pc_death", oPC);
        // set immortal flag to prevent double kills before fugue teleportation
        SetImmortal(oPC, TRUE);
        DeleteLocalInt(oPC, "GODMODE_ON");
        death_Ressurect(oPC);
        DelayCommand(0.0,  ExecuteScript("_port_abyss", oPC));
    }
}

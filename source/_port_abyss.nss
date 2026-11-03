#include "_inc_death"
#include "nwnx_player"

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    if(GetResRef(oArea) == CONST_AREA_ABYSS_RESREF)
    {
        DelayCommand(0.1, RemoveEffectsAfterDeath(OBJECT_SELF));
        DelayCommand(0.25, ExecuteScript("_mod_instant_eff", OBJECT_SELF));
        // play Shao Kahn's laugh :)
        DelayCommand(0.5, StartAudioStream(OBJECT_SELF, AUDIOSTREAM_IDENTIFIER_0, "mus_shao_kahn"));
        return;
    }
    if(GetIsObjectValid(oArea))
    {
        location lAbyssLocation =  GetLocation(GetWaypointByTag("abyss_enter"));
        ClearAllActions(TRUE);
        JumpToLocation(lAbyssLocation);
        SendMessageToPC(OBJECT_SELF, "You are dead.");
    }
    DelayCommand(0.5, ExecuteScript("_port_abyss", OBJECT_SELF));
}

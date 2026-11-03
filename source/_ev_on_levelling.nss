#include "nwnx_events"
#include "_inc_psv_bonuses"
#include "_inc_pres_class"

void main()
{
    object oPC = OBJECT_SELF;
    string sEvent = NWNX_Events_GetCurrentEvent();

    if (sEvent == "NWNX_ON_LEVEL_DOWN_AFTER")
    {
        ExecuteScript("_mod_instant_eff", oPC);
    }
    else if (sEvent == "NWNX_ON_CLIENT_LEVEL_UP_BEGIN_BEFORE") // open level up GUI event
    {
        //
    }
    pres_RunValidator(oPC);
}

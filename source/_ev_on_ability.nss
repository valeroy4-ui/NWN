#include "nwnx_events"
#include "_inc_psv_bonuses"

void main()
{
    object oPC = OBJECT_SELF;
    //int nAbility = StringToInt(NWNX_Events_GetEventData("ABILITY"));
    //int nValue = StringToInt(NWNX_Events_GetEventData("VALUE"));
    //int nMod = StringToInt(NWNX_Events_GetEventData("MOD"));

    // delays because script works too early and provokes duplicating bug with player's skin
    DelayCommand(1.5, SetArchmageAncientAC(oPC));
    DelayCommand(1.5, AddMonkBonuses(oPC));
    // add bonus saves
    DelayCommand(1.5, psv_AdjustCustomSaves(oPC));
}

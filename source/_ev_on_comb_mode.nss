// runs after combat mode activated

#include "nwnx_events"
#include "_inc_colortext"

// NWNX combat mode constants

const int NWNX_COMBAT_MODE_NONE                      = 0;
const int NWNX_COMBAT_MODE_PARRY                     = 1;
const int NWNX_COMBAT_MODE_POWER_ATTACK              = 2;
const int NWNX_COMBAT_MODE_IMPROVED_POWER_ATTACK     = 3;
const int NWNX_COMBAT_MODE_COUNTERSPELL              = 4;
const int NWNX_COMBAT_MODE_FLURRY_OF_BLOWS           = 5;
const int NWNX_COMBAT_MODE_RAPID_SHOT                = 6;
const int NWNX_COMBAT_MODE_EXPERTISE                 = 7;
const int NWNX_COMBAT_MODE_IMPROVED_EXPERTISE        = 8;
const int NWNX_COMBAT_MODE_DEFENSIVE_CASTING         = 9;
const int NWNX_COMBAT_MODE_DIRTY_FIGHTING            = 10;
const int NWNX_COMBAT_MODE_DEFENSIVE_STANCE          = 11;

void main()
{
    string sCombatMode = NWNX_Events_GetEventData("COMBAT_MODE_ID");
    int iCombatMode = StringToInt(sCombatMode);

    if (NWNX_Events_GetCurrentEvent()=="NWNX_ON_COMBAT_MODE_ON")
    {
        // skip counterspell
        if (iCombatMode == NWNX_COMBAT_MODE_COUNTERSPELL)
        {
            NWNX_Events_SkipEvent();
            AssignCommand(OBJECT_SELF, ClearAllActions(TRUE));
            FloatingColorTextStringOnCreature("Counterspell is not allowed.", TXT_COLOR_RED, OBJECT_SELF, FALSE);
        }
        if(iCombatMode == NWNX_COMBAT_MODE_IMPROVED_EXPERTISE && GetIsPC(OBJECT_SELF) &&
           (GetAbilityModifier(ABILITY_WISDOM, OBJECT_SELF) >= 15 || GetAbilityModifier(ABILITY_CHARISMA, OBJECT_SELF) > 15))
        {
            NWNX_Events_SkipEvent();
            AssignCommand(OBJECT_SELF, ClearAllActions(TRUE));
            FloatingColorTextStringOnCreature("You cannot use this feat if you have a 15+ charisma or wisdom modifier.", TXT_COLOR_RED, OBJECT_SELF, FALSE);
        }
    }
}

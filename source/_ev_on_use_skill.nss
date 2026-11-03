#include "nwnx_events"
#include "nwnx_creature"
#include "_inc_colortext"
#include "_inc_constants"


void main()
{
    string sCurrentEvent = NWNX_Events_GetCurrentEvent();
    int nSkill = StringToInt(NWNX_Events_GetEventData("SKILL_ID"));
    object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));

    if(sCurrentEvent == "NWNX_ON_USE_SKILL_BEFORE")
    {
        if(!GetIsPC(OBJECT_SELF))
            return;

        switch(nSkill)
        {
            case SKILL_PICK_POCKET:
                NWNX_Events_SkipEvent();
                FloatingColorTextStringOnCreature("No Pickpocket skill use allowed.", TXT_COLOR_RED, OBJECT_SELF, FALSE);
                break;
            case SKILL_TAUNT:
                if(GetHasFeat(FEAT_IMPROVED_TAUNT, OBJECT_SELF) || GetPCIPAddress(OBJECT_SELF) == "192.168.128.100" /* debug */)
                {
                    NWNX_Events_SkipEvent();
                    ClearAllActions();
                    ActionUseSkill(SKILL_TAUNT, oTarget);
                }
                break;
        }
    }
}

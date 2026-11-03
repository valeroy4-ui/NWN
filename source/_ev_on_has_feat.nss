#include "nwnx_events"

void main()
{
    object oPC = OBJECT_SELF;
    if (NWNX_Events_GetCurrentEvent() == NWNX_ON_HAS_FEAT_BEFORE)
    {
        int nFeat = StringToInt(NWNX_Events_GetEventData("FEAT_ID"));
        switch(nFeat)
        {
            case FEAT_AMBIDEXTERITY:
            case FEAT_TWO_WEAPON_FIGHTING:
            if(GetHasFeat(374 /* ranger dual-wield */, oPC))
            {
                NWNX_Events_SetEventResult("1");
                NWNX_Events_SkipEvent();
            }
            break;
        }
    }
}

#include "nwnx_events"
#include "_inc_constants"

void main()
{
    string sEvent = NWNX_Events_GetCurrentEvent();
    if(sEvent == NWNX_ON_COMBAT_ATTACK_OF_OPPORTUNITY_BEFORE)
    {
        object oAttacker = OBJECT_SELF;
        if(GetHasFeat(FEAT_WOODEN_BODY, oAttacker))
            NWNX_Events_SkipEvent();
    }
}

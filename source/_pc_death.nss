#include "dq_store"
#include "_inc_areas"
void main()
{
    object victim=OBJECT_SELF;
    if(!GetLocalInt(victim,"DQS_PVP_DEATH_BUSY"))
    {
        SetLocalInt(victim,"DQS_PVP_DEATH_BUSY",TRUE);
        if(!GetAreaFlag(GetArea(victim),AREA_FLAG_NO_DEATH))DQS_PvPDeath(victim,GetLastKiller());
        ExecuteScript("dq_pvp_base",victim);
        DeleteLocalInt(victim,"DQS_PVP_DEATH_BUSY");
    }
}

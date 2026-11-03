// Silence OnExit: timed failure tails persist until their normal expiry.
#include "70_inc_spells"
#include "nw_i0_spells"
void main()
{
    aoesDeclareMajorVariables();
    if(GetExitingObject()==aoe.Owner)
        aoesCheckStillValid(aoe.AOE,aoe.Owner,aoe.Creator,spell.Id);
}

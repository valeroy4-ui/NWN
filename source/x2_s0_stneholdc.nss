#include "st256_inc"
void main()
{
    aoesDeclareMajorVariables();
    if(!GetIsObjectValid(aoe.Creator) || GetIsDead(aoe.Creator))
    {ExecuteScript("_plc_aoe_destroy",OBJECT_SELF);DestroyObject(OBJECT_SELF);return;}
    ST256_Scan(OBJECT_SELF);
}

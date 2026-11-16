#include "malv_inc"
void main()
{
    MV_Reset(OBJECT_SELF);
    ExecuteScript("ai_boss_ondeath",OBJECT_SELF);
}

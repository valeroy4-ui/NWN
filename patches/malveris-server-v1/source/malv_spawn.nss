#include "malv_inc"
void main()
{
    MV_Reset(OBJECT_SELF);
    ExecuteScript("ai_boss_onspawn",OBJECT_SELF);
    PrintString("[MALVERIS v1] spawned; native spawn="+ResManGetAliasFor("ai_boss_onspawn",RESTYPE_NCS)+
        " native heartbeat="+ResManGetAliasFor("ai_boss_onheart",RESTYPE_NCS));
}

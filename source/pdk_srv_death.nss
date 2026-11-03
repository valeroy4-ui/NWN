#include "pdk_battle"
void main()
{
    PKB_Save(OBJECT_SELF); PKS_SaveCooldowns(OBJECT_SELF);
    PKB_Stop(OBJECT_SELF); PKS_Stop(OBJECT_SELF);
    PDKL_Disconnect(OBJECT_SELF);
}

// Call while exiting PC is still valid, before other code destroys its state.
#include "pdk_battle"
void main()
{
    object p=OBJECT_SELF;
    if(!GetIsPC(p)) return;
    PKB_Save(p); PKB_Stop(p);
    PKS_SaveCooldowns(p); PKS_Stop(p);
    PDKL_Disconnect(p);
}

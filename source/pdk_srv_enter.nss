// OBJECT_SELF must be the entering PC, after server identity/entitlements load.
// No feat removal/grant migration here; see docs/02_INTEGRATION_RU.md.
#include "pdk_battle"
void main()
{
    object p=OBJECT_SELF;
    if(!GetIsPC(p) || GetIsDM(p)) return;
    PDKL_Disconnect(p);
    PDKL_ResetClient(p);
    PKB_Restore(p); PKB_Stop(p);
    PKS_RestoreCooldowns(p); PKS_Stop(p);
    SetLocalInt(p,"PDKL_BEAM_DIRECT",TRUE);
}

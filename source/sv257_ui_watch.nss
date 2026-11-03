// One-time startup and legacy cleanup; no polling loop.
#include "sv257_ui_inc"
#include "nwnx_events"
void main()
{
    object o=OBJECT_SELF;
    if(!GetIsPC(o) || GetIsDM(o) || GetLocalInt(GetModule(),"SV257_UI_STOPPED")) return;
    if(!GetLocalInt(GetModule(),"SV257_INPUT_REGISTERED"))
    {
        NWNX_Events_SubscribeEvent(NWNX_ON_INPUT_CAST_SPELL_BEFORE,"sv257_input");
        SetLocalInt(GetModule(),"SV257_INPUT_REGISTERED",TRUE);
    }
    SVUI_ClearSelection(o,TRUE);
    SVUI_Sync(o);
}

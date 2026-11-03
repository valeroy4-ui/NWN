#include "dq_ui"
void main()
{
    object pc = OBJECT_SELF;
    if (!GetIsPC(pc)) return;
    int old = NuiFindWindow(pc,DQ_WINDOW);
    if (old) { NuiDestroy(pc,old); return; }
    int live = DQC_Enter(pc);
    SetLocalInt(pc,"DQ_UI_PREVIEW",FALSE);
    SetLocalInt(pc,"DQ_UI_UNAVAILABLE",!live);
    float sw = IntToFloat(GetPlayerDeviceProperty(pc,PLAYER_DEVICE_PROPERTY_GUI_WIDTH));
    float sh = IntToFloat(GetPlayerDeviceProperty(pc,PLAYER_DEVICE_PROPERTY_GUI_HEIGHT));
    if (sw < 540.0) sw = 800.0;
    if (sh < 400.0) sh = 600.0;
    float width = sw - 40.0;
    float height = sh - 26.0;
    if (width > 960.0) width = 960.0;
    if (height > 732.0) height = 732.0;
    string tab = GetLocalString(pc,"DQ_PREVIEW_TAB");
    json catalog = DQ_CatalogFor(pc);
    if (!DQ_HasTab(catalog,tab))
        tab = JsonGetString(JsonObjectGet(JsonArrayGet(JsonObjectGet(catalog,"tabs"),0),"id"));
    json window = NuiWindow(DQ_Layout(catalog,width,height,tab),JsonBool(FALSE),
        NuiRect((sw-width)/2.0,(sh-height)/2.0,width,height),JsonBool(FALSE),JsonBool(FALSE),
        JsonBool(FALSE),JsonBool(FALSE),JsonBool(FALSE));
    int token = NuiCreate(pc,window,DQ_WINDOW);
    if (!token) { SendMessageToPC(pc,"Quest journal could not open. Please report this to the tester."); return; }
    NuiSetUserData(pc,token,JsonObjectSet(JsonObjectSet(JsonObject(),"width",JsonFloat(width)),"height",JsonFloat(height)));
    DQ_SelectTab(pc,token,tab,FALSE);
    DQ_StartAnimation(pc,token);
    if (!live) DQ_SetFeedback(pc,token,"Daily temporarily unavailable. Close and reopen the journal to retry. Stored progress is retained.");
    else if (DQC_Int(GetLocalJson(pc,"DQ_LIVE_STATE"),"issuance_blocked"))
        DQ_SetFeedback(pc,token,"Insufficient eligible targets for 15 distinct quests. Carried progress is preserved.");
}

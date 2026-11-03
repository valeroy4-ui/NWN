#include "dq_ui"
void main()
{
    object pc = OBJECT_SELF; int token = NuiFindWindow(pc,DQ_WINDOW);
    if (!token || GetLocalInt(pc,"DQ_UI_PREVIEW") || GetLocalInt(pc,"DQ_UI_UNAVAILABLE")) return;
    int now = DQC_Now();
    if (now <= 0)
    { DQ_SetFeedback(pc,token,"Daily clock unavailable. Stored progress is retained; retry shortly."); return; }
    if (DQC_Cycle(now) != DQC_Int(GetLocalJson(pc,"DQ_LIVE_STATE"),"cycle") && !DQC_Enter(pc))
    { DQ_SetFeedback(pc,token,"Daily refresh unavailable. Stored progress remains safe; retry after reconnecting."); return; }
    // Kills only change bindings. Rebuild rows when rotation changes their IDs.
    json items = DQ_Items(DQ_CatalogFor(pc),"daily"); json ids = JsonArray(); int i;
    for (i = 0; i < JsonGetLength(items); i++) JsonArrayInsertInplace(ids,JsonObjectGet(JsonArrayGet(items,i),"id"));
    if (JsonDump(ids) != JsonDump(JsonObjectGet(NuiGetUserData(pc,token),"ids"))) DQ_SelectTab(pc,token,"daily",TRUE);
    else DQ_Refresh(pc,token,"daily");
}

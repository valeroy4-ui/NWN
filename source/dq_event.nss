#include "dq_ui"
void Reload(object pc, int token)
{
    if (token) DQ_SelectTab(pc,token,"daily",TRUE);
}
void ConfirmReplacement(object pc, json q, int refresh = FALSE)
{
    int old = NuiFindWindow(pc,"dq_confirm");
    json window = DQ_ReplacementWindow(q); int token;
    if (old && refresh)
    {
        // Refresh a changed-progress warning without moving the open popup.
        NuiSetGroupLayout(pc,old,"_window_",JsonObjectGet(window,"root")); token = old;
    }
    else
    {
        if (old) NuiDestroy(pc,old);
        token = NuiCreate(pc,window,"dq_confirm");
    }
    if (!token) return;
    NuiSetUserData(pc,token,JsonObjectSet(JsonObjectSet(JsonObject(),"id",JsonObjectGet(q,"id")),"progress",JsonObjectGet(q,"progress")));
}
json FindQuest(object pc, string id)
{
    json all = JsonObjectGet(GetLocalJson(pc,"DQ_LIVE_STATE"),"quests"); int i;
    for (i = 0; i < JsonGetLength(all); i++)
        if (DQC_Str(JsonArrayGet(all,i),"id") == id) return JsonArrayGet(all,i);
    return JsonNull();
}
void main()
{
    object pc = NuiGetEventPlayer(); int token = NuiGetEventWindow();
    string window = NuiGetWindowId(pc,token); string eventType = NuiGetEventType();
    if (window != DQ_WINDOW && window != "dq_confirm") return;
    if (eventType == "close" || eventType == "closed")
    { if (NuiFindWindow(pc,window) == token) NuiDestroy(pc,token); return; }
    if (eventType != "click") return;
    string element = NuiGetEventElement();
    if (window == "dq_confirm")
    {
        if (element == "cancel_replace") { NuiDestroy(pc,token); return; }
        if (element != "confirm_replace" || GetLocalInt(pc,"DQ_UI_PREVIEW") || GetLocalInt(pc,"DQ_UI_UNAVAILABLE")) return;
        json data = NuiGetUserData(pc,token); string id = DQC_Str(data,"id");
        json current = DQC_Read(pc); if (JsonGetType(current) != JSON_TYPE_OBJECT) return;
        SetLocalJson(pc,"DQ_LIVE_STATE",current); json q = FindQuest(pc,id);
        if (!DQ_ReplacementEligible(current,q))
        {
            NuiDestroy(pc,token); int journal = NuiFindWindow(pc,DQ_WINDOW); Reload(pc,journal);
            if (journal) DQ_SetFeedback(pc,journal,"Replacement unavailable. No attempt was spent.");
            return;
        }
        if (DQC_Int(data,"progress") != DQC_Int(q,"progress")) { ConfirmReplacement(pc,q,TRUE); return; }
        int ok = DQC_LiveReroll(pc,id,TRUE); NuiDestroy(pc,token);
        int journal = NuiFindWindow(pc,DQ_WINDOW); Reload(pc,journal);
        if (journal) DQ_SetFeedback(pc,journal,ok ? "Quest replaced. Only this quest's progress was reset." : "Replacement unavailable. No attempt was spent.");
        return;
    }
    if (element == "close") { NuiDestroy(pc,token); return; }
    string tab = "daily";
    if (element == "preview")
    {
        SetLocalInt(pc,"DQ_UI_UNAVAILABLE",FALSE);
        int mode = GetLocalInt(pc,"DQ_PREVIEW_MODE_daily");
        if (!GetLocalInt(pc,"DQ_UI_PREVIEW")) { SetLocalInt(pc,"DQ_UI_PREVIEW",TRUE); mode = 0; }
        else mode = (mode+1)%3;
        SetLocalInt(pc,"DQ_PREVIEW_MODE_daily",mode);
        json items = DQ_Items(DQ_CatalogFor(pc),tab); int i;
        for (i = 0; i < 3; i++) DeleteLocalInt(pc,"DQ_PREVIEW_CHEST_daily_"+IntToString(i));
        for (i = 0; i < JsonGetLength(items); i++)
        {
            int status = mode == 2 ? 2 : (mode == 1 && i < 5 ? 2 : (mode == 1 && i == 5 ? 1 : 0));
            SetLocalInt(pc,"DQ_PREVIEW_"+DQC_Str(JsonArrayGet(items,i),"id"),status);
        }
        Reload(pc,token); // Pure preview: no SQL calls or real reward/state writes.
        return;
    }
    if (GetLocalInt(pc,"DQ_UI_UNAVAILABLE")) return;
    if (GetStringLeft(element,10) == "milestone_")
    {
        int chest = StringToInt(GetSubString(element,10,2));
        if (chest < 0 || chest >= 3) return;
        if (GetLocalInt(pc,"DQ_UI_PREVIEW"))
        {
            json data = DQ_Bindings(pc,DQ_Items(DQ_CatalogFor(pc),tab),tab);
            if (!DQC_Int(data,"dq_chest_ready_"+IntToString(chest))) return;
            SetLocalInt(pc,"DQ_PREVIEW_CHEST_daily_"+IntToString(chest),TRUE);
            Reload(pc,token); DQ_SetFeedback(pc,token,"Bonus chest preview opened. No rewards were granted.");
        }
        else
        {
            if (!JsonGetInt(NuiGetBind(pc,token,"dq_chest_ready_"+IntToString(chest))))
            { DQ_SetFeedback(pc,token,"Bonus chest: "+JsonGetString(NuiGetBind(pc,token,"dq_chest_label_"+IntToString(chest)))); return; }
            int ok = DQC_LiveClaim(pc,"",chest); Reload(pc,token);
            DQ_SetFeedback(pc,token,ok ? DQC_RewardMessage(pc) : "Bonus unavailable or already claimed. No additional reward.");
        }
        return;
    }
    int index = -1; string eventAction;
    if (GetStringLeft(element,8) == "details_") { index = StringToInt(GetSubString(element,8,8)); eventAction = "details"; }
    else if (GetStringLeft(element,7) == "reward_") { index = StringToInt(GetSubString(element,7,8)); eventAction = "reward"; }
    else if (GetStringLeft(element,6) == "claim_") { index = StringToInt(GetSubString(element,6,8)); eventAction = "replace"; }
    json displayed = NuiGetUserData(pc,token); json ids = JsonObjectGet(displayed,"ids");
    if (index < 0 || index >= JsonGetLength(ids)) return;
    string id = JsonGetString(JsonArrayGet(ids,index));
    if (GetLocalInt(pc,"DQ_UI_PREVIEW"))
    {
        json items = DQ_Items(DQ_CatalogFor(pc),tab); json q = JsonArrayGet(items,index);
        if (eventAction == "details") DQ_SetFeedback(pc,token,DQC_Str(q,"title")+": "+DQC_Str(q,"locations"));
        else if (eventAction == "reward" && GetLocalInt(pc,"DQ_PREVIEW_"+id) == 1)
        { SetLocalInt(pc,"DQ_PREVIEW_"+id,2); Reload(pc,token); DQ_SetFeedback(pc,token,"Reward preview opened. No rewards were granted."); }
        return;
    }
    json current = DQC_Read(pc); if (JsonGetType(current) != JSON_TYPE_OBJECT) return;
    SetLocalJson(pc,"DQ_LIVE_STATE",current); json q = FindQuest(pc,id);
    if (JsonGetType(q) != JSON_TYPE_OBJECT) { Reload(pc,token); return; }
    if (eventAction == "details")
    {
        if (DQC_Waiting(q,DQC_CarryRefs(current),DQC_Int(current,"cycle")))
            DQ_SetFeedback(pc,token,"Waiting: finish and claim the matching carried quest first. Then this quest starts counting kills.");
        else DQ_SetFeedback(pc,token,DQC_Str(q,"title")+": "+DQC_Str(q,"locations")+".");
        return;
    }
    if (eventAction == "replace")
    {
        if (!DQ_ReplacementEligible(current,q)) return;
        ConfirmReplacement(pc,q);
        return;
    }
    if (eventAction != "reward") return;
    int wasReady = JsonGetInt(JsonArrayGet(JsonObjectGet(displayed,"ready"),index));
    if (!wasReady || !DQC_Int(q,"objective_completed")) { Reload(pc,token); return; }
    int ok = DQC_LiveClaim(pc,id); Reload(pc,token);
    DQ_SetFeedback(pc,token,ok ? DQC_RewardMessage(pc) : "Reward unavailable or already claimed. No additional reward.");
}

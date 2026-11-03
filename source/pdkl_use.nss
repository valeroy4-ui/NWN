#include "pdkl_core"

// Prefer the oldest link on the selected target at capacity. If the target has
// no link, the caller falls back to the oldest connection across all targets.
// Connection order is separate from LAST, which is refreshed on every heartbeat.
int PDKL_OldestTargetSlot(object owner,object target)
{
    int slot,best,oldest;
    for(slot=1;slot<=PDKL_Limit(owner);slot++)
    {
        if(GetLocalInt(owner,PDKL_Key("KIND",slot))<=0
            || (GetIsObjectValid(target) && GetLocalObject(owner,PDKL_Key("TARGET",slot))!=target)) continue;
        int order=GetLocalInt(owner,PDKL_Key("ORDER",slot));
        if(best==0 || order<oldest) { best=slot;oldest=order; }
    }
    return best;
}

int PDKL_Cast(object oPDK, object oTarget, int nSpell)
{
    int nKind = StringToInt(Get2DAString("pdkl_spells", "Kind", nSpell));
    int nEnabled = StringToInt(Get2DAString("pdkl_spells", "Enabled", nSpell));
    if(!PDKL_Alive(oPDK) || PDKL_Level(oPDK) < 1) return 0;
    DeleteLocalInt(oPDK,"PDKL_BUSY");
    DeleteLocalInt(oPDK,"PDKL_READY");
    if(!(nKind >= 1 && nKind <= 20) || !nEnabled)
    {
        SendMessageToPC(oPDK, "Link: this selection is reserved for a later test stage.");
        return 0;
    }
    if(!PDKL_Ally(oPDK, oTarget))
    {
        SendMessageToPC(oPDK, "Link: choose another living ally.");
        return 0;
    }
    PDKL_Refresh(oPDK);
    int nSlot;
    // Recasting the exact same selection on the same ally releases that slot.
    // Cancellation is immediate, including outside range.
    for(nSlot = 1; nSlot <= PDKL_MAX; nSlot++)
    {
        if(GetLocalObject(oPDK, PDKL_Key("TARGET", nSlot)) == oTarget
            && GetLocalInt(oPDK, PDKL_Key("KIND", nSlot)) == nKind)
        {
            PDKL_ClearSlot(oPDK, nSlot);
            PDKL_UpdateAC(oPDK);
            SendMessageToPC(oPDK, "Link released. Occupied slot is free.");
            return -1;
        }
    }
    int required=StringToInt(Get2DAString("pdkl_spells","MinLevel",nSpell));
    if(PDKL_Level(oPDK)<required)
    {
        SendMessageToPC(oPDK,"Link: requires PDK level "+IntToString(required)+".");
        return 0;
    }
    if(!PDKL_InRange(oPDK, oTarget))
    {
        SendMessageToPC(oPDK, "Link: ally is outside link range (" + FloatToString(PDKL_Range(oPDK), 2, 1) + " m).");
        return 0;
    }
    // One connection per branch, across all targets. A new valid selection
    // reuses that branch's slot; validation precedes replacement.
    nSlot = PDKL_GroupSlot(oPDK, PDKL_Group(nKind));
    if(nSlot == 0)
        for(nSlot = 1; nSlot <= PDKL_Limit(oPDK); nSlot++)
            if(GetLocalInt(oPDK, PDKL_Key("KIND", nSlot)) == 0) break;
    if(nSlot > PDKL_Limit(oPDK)) nSlot=PDKL_OldestTargetSlot(oPDK,oTarget);
    if(nSlot == 0) nSlot=PDKL_OldestTargetSlot(oPDK,OBJECT_INVALID);
    if(nSlot == 0)
    {
        SendMessageToPC(oPDK, "Link: no available connection slot.");
        return 0;
    }
    int replacing=GetLocalInt(oPDK, PDKL_Key("KIND", nSlot)) > 0;
    object oldTarget=GetLocalObject(oPDK,PDKL_Key("TARGET",nSlot));
    if(replacing) PDKL_ClearSlot(oPDK, nSlot, FALSE);
    SetLocalObject(oPDK, PDKL_Key("TARGET", nSlot), oTarget);
    SetLocalInt(oPDK, PDKL_Key("KIND", nSlot), nKind);
    SetLocalInt(oPDK, PDKL_Key("LAST", nSlot), PDKL_Now());
    int order=GetLocalInt(oPDK,"PDKL_SEQUENCE")+1;
    SetLocalInt(oPDK,"PDKL_SEQUENCE",order);
    SetLocalInt(oPDK,PDKL_Key("ORDER",nSlot),order);
    PDKL_Refresh(oPDK);
    PDKL_NotifyRelink(oPDK,oldTarget,oTarget);
    string sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
    SendMessageToPC(oPDK, sName + " -> " + GetName(oTarget) + ". Slot " + IntToString(nSlot) + "/" + IntToString(PDKL_Limit(oPDK)) + ".");
    if(GetIsPC(oTarget)) SendMessageToPC(oTarget, GetName(oPDK) + " established " + sName + ".");
    return 1;
}

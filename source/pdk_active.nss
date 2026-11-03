#include "_inc_players"
// Knowledge / Swap alignment / Exhausted, transferred from the original Cormyr PDK.
#include "pdkl_core"
#include "nwnx_creature"
#include "pdk_visuals"

int PKS_Now()
{ NWNXCall("NWNX_PDK","UnixTime");return NWNXPopInt(); }
void PKS_ClearMarks(object viewer)
{ NWNXPushObject(viewer);NWNXCall("NWNX_PDK","KnowledgeClear"); }
void PKS_Mark(object viewer,object target,int visual,int until)
{
    NWNXPushInt(until);NWNXPushInt(visual);NWNXPushObject(target);NWNXPushObject(viewer);
    NWNXCall("NWNX_PDK","KnowledgeMark");
}
int PKS_State(object viewer,object target,int mode=0)
{
    NWNXPushInt(mode);NWNXPushObject(target);NWNXPushObject(viewer);
    NWNXCall("NWNX_PDK","KnowledgeState");return NWNXPopInt();
}
// Keep cooldowns in the running module as well as on the character: a fresh
// character object on reconnect must not lose a still-running cooldown.
string PKS_Identity(object p)
{
    if(!GetIsPC(p)) return "";
    int id=players_GetPCPersistentID(p);
    return id>0 ? "character:"+IntToString(id) : "";
}
void PKS_DBPut(object p,string key,int value)
{
    int id=players_GetPCPersistentID(p);if(id<=0) return;
    NWNX_SQL_PrepareQuery("INSERT INTO ct_pdk_state(character_id,state_key,value) VALUES(?,?,?) ON DUPLICATE KEY UPDATE value=VALUES(value)");
    NWNX_SQL_PreparedInt(0,id);NWNX_SQL_PreparedString(1,key);NWNX_SQL_PreparedInt(2,value);
    NWNX_SQL_ExecutePreparedQuery();
}
int PKS_DBGet(object p,string key)
{
    int id=players_GetPCPersistentID(p);if(id<=0) return 0;
    NWNX_SQL_PrepareQuery("SELECT value FROM ct_pdk_state WHERE character_id=? AND state_key=?");
    NWNX_SQL_PreparedInt(0,id);NWNX_SQL_PreparedString(1,key);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    { NWNX_SQL_ReadNextRow();return StringToInt(NWNX_SQL_ReadDataInActiveRow()); }
    return 0;
}
void PKS_SaveAs(object p,string identity)
{
    if(identity=="") return;
    object m=GetModule();string k="PKS_K_"+identity,s="PKS_S_"+identity,e="PKS_E_"+identity;
    int kr=GetLocalInt(p,"PKS_KREADY"),sr=GetLocalInt(p,"PKS_SREADY"),er=GetLocalInt(p,"PKS_EREADY");
    if(kr>GetLocalInt(m,k)) SetLocalInt(m,k,kr);
    if(sr>GetLocalInt(m,s)) SetLocalInt(m,s,sr);
    if(er>GetLocalInt(m,e)) SetLocalInt(m,e,er);
    PKS_DBPut(p,"PKS_KREADY",GetLocalInt(m,k));
    PKS_DBPut(p,"PKS_SREADY",GetLocalInt(m,s));
    PKS_DBPut(p,"PKS_EREADY",GetLocalInt(m,e));
}
void PKS_RestoreAs(object p,string identity)
{
    if(identity=="") return;
    int k=PKS_DBGet(p,"PKS_KREADY"),s=PKS_DBGet(p,"PKS_SREADY"),e=PKS_DBGet(p,"PKS_EREADY");
    if(k>GetLocalInt(p,"PKS_KREADY")) SetLocalInt(p,"PKS_KREADY",k);
    if(s>GetLocalInt(p,"PKS_SREADY")) SetLocalInt(p,"PKS_SREADY",s);
    if(e>GetLocalInt(p,"PKS_EREADY")) SetLocalInt(p,"PKS_EREADY",e);
    PKS_SaveAs(p,identity);object m=GetModule();
    SetLocalInt(p,"PKS_KREADY",GetLocalInt(m,"PKS_K_"+identity));
    SetLocalInt(p,"PKS_SREADY",GetLocalInt(m,"PKS_S_"+identity));
    SetLocalInt(p,"PKS_EREADY",GetLocalInt(m,"PKS_E_"+identity));
}
void PKS_SaveCooldowns(object p) { PKS_SaveAs(p,PKS_Identity(p)); }
void PKS_RestoreCooldowns(object p) { PKS_RestoreAs(p,PKS_Identity(p)); }
int PKS_Remaining(object p,string key)
{ int n=GetLocalInt(p,key)-PKS_Now();return n>0?n:0; }
int PKS_Duration(object p)
{ int mod=GetAbilityModifier(ABILITY_CHARISMA,p);return mod>0?mod*6:0; }
void PKS_Feedback(object p,string text)
{ if(GetIsPC(p)) SendMessageToPC(p,text); }
int PKS_Enemy(object p,object target)
{
    return p!=target && PDKL_Alive(target) && GetArea(p)==GetArea(target)
        && (GetIsEnemy(target,p) || GetIsEnemy(p,target));
}
void PKS_Grant(object p)
{
    int level=PDKL_Level(p);
    if(level>=1)
    {
        // Retire the original Oath and class-granted mounted feats.
    }
    if(level>=3 && !GetHasFeat(1082,p,TRUE)) NWNX_Creature_AddFeat(p,1082);
    if(level>=1 && !GetHasFeat(1084,p,TRUE)) NWNX_Creature_AddFeat(p,1084);
    if(level>=2 && !GetHasFeat(1085,p,TRUE)) NWNX_Creature_AddFeat(p,1085);
    if(level>=4 && !GetHasFeat(1086,p,TRUE)) NWNX_Creature_AddFeat(p,1086);
}
void PKS_Stop(object p)
{
    PKS_ClearMarks(p);
    if(!GetIsObjectValid(p)) return;
    DeleteLocalInt(p,"PKS_KEND");DeleteLocalObject(p,"PKS_KAREA");
    SetLocalInt(p,"PKS_KTOKEN",GetLocalInt(p,"PKS_KTOKEN")+1);
    // KREADY / SREADY / EREADY deliberately survive death, area changes and reconnects.
}
int PKS_Refresh(object p)
{
    PKS_ClearMarks(p);
    if(!PDKL_Alive(p) || PDKL_Level(p)<1 || PKS_Remaining(p,"PKS_KEND")<=0
        || GetArea(p)!=GetLocalObject(p,"PKS_KAREA")) return 0;
    int count;object target=GetFirstObjectInArea(GetArea(p),OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(target))
    {
        if(PKS_Enemy(p,target))
        {
            int alignment=GetAlignmentGoodEvil(target);int visual=0;
            if(alignment==ALIGNMENT_GOOD) visual=VFX_DUR_GLOW_BLUE;
            else if(alignment==ALIGNMENT_EVIL) visual=VFX_DUR_GLOW_RED;
            if(visual>0)
            { PKS_Mark(p,target,visual,GetLocalInt(p,"PKS_KEND"));count++; }
        }
        target=GetNextObjectInArea(GetArea(p),OBJECT_TYPE_CREATURE);
    }
    return count;
}
void PKS_Pulse(object p,int token)
{
    if(!GetIsObjectValid(p)) { PKS_ClearMarks(p);return; }
    if(GetLocalInt(p,"PKS_KTOKEN")!=token) return;
    if(!PDKL_Alive(p) || PDKL_Level(p)<1 || PKS_Remaining(p,"PKS_KEND")<=0
        || GetArea(p)!=GetLocalObject(p,"PKS_KAREA")) { PKS_Stop(p);return; }
    PKS_Refresh(p);
    AssignCommand(GetModule(),DelayCommand(0.5,PKS_Pulse(p,token)));
}
int PKS_Knowledge(object p)
{
    if(!PDKL_Alive(p) || PDKL_Level(p)<1) return 0;
    PKS_RestoreCooldowns(p);
    int remaining=PKS_Remaining(p,"PKS_KREADY");
    if(remaining>0)
    { PKS_Feedback(p,"Knowledge cooldown: "+IntToString(remaining)+" seconds.");return 0; }
    int duration=PKS_Duration(p);
    if(duration<=0)
    { PKS_Feedback(p,"Knowledge: a positive CHA modifier is needed for any highlight duration. No cooldown spent.");return 0; }
    PKS_Stop(p);int now=PKS_Now();
    SetLocalInt(p,"PKS_KREADY",now+60);SetLocalInt(p,"PKS_KEND",now+duration);
    SetLocalObject(p,"PKS_KAREA",GetArea(p));
    PKS_SaveCooldowns(p);
    int token=GetLocalInt(p,"PKS_KTOKEN");int count=PKS_Refresh(p);
    AssignCommand(GetModule(),DelayCommand(0.5,PKS_Pulse(p,token)));
    PKV_Knowledge(p);
    PKS_Feedback(p,"Knowledge: "+IntToString(count)+" enemies highlighted for "+IntToString(duration)+
        " seconds. Good=blue, Evil=red; Neutral has no glow. Visible only to you. Cooldown: 60 seconds.");
    return 1;
}
int PKS_Swap(object p,object target)
{
    if(!PDKL_Alive(p) || PDKL_Level(p)<2) return 0;
    if(!PKS_Enemy(p,target))
    { PKS_Feedback(p,"Swap alignment: choose a living enemy in this area.");return 0; }
    int alignment=GetAlignmentGoodEvil(target);
    if(alignment==ALIGNMENT_NEUTRAL)
    { PKS_Feedback(p,"Swap alignment: Neutral has no opposite on the Good/Evil axis. No cooldown spent.");return 0; }
    PKS_RestoreCooldowns(p);
    int remaining=PKS_Remaining(p,"PKS_SREADY");
    if(remaining>0)
    { PKS_Feedback(p,"Swap alignment cooldown: "+IntToString(remaining)+" seconds.");return 0; }
    AdjustAlignment(target,alignment==ALIGNMENT_GOOD?ALIGNMENT_EVIL:ALIGNMENT_GOOD,99,FALSE);
    SetLocalInt(p,"PKS_SREADY",PKS_Now()+60);PKS_SaveCooldowns(p);
    PKS_Refresh(p);PKV_Swap(target);
    PKS_Feedback(p,"Swap alignment: "+GetName(target)+" is now "+
        (GetAlignmentGoodEvil(target)==ALIGNMENT_GOOD?"Good":"Evil")+". Law/Chaos unchanged. Cooldown: 60 seconds.");
    return 1;
}

float PKS_TouchRange(object p,object target)
{
    NWNXPushObject(target);NWNXPushObject(p);NWNXCall("NWNX_PDK","TouchRange");
    return NWNXPopFloat();
}
float PKS_RangedTouchRange(object p,object target)
{
    NWNXPushObject(target);NWNXPushObject(p);NWNXCall("NWNX_PDK","RangedTouchRange");
    return NWNXPopFloat();
}
// Return -1 on a genuine touch miss, 0 on rejection, 1 on a hit.
// Only a hit spends cooldown; slow immunity still consumes a successful attack.
int PKS_Exhausted(object p,object target)
{
    if(!PDKL_Alive(p) || PDKL_Level(p)<3) return 0;
    if(!PKS_Enemy(p,target))
    { PKS_Feedback(p,"Exhausted: choose a living enemy.");return 0; }
    PKS_RestoreCooldowns(p);
    int remaining=PKS_Remaining(p,"PKS_EREADY");
    if(remaining>0)
    { PKS_Feedback(p,"Exhausted cooldown: "+IntToString(remaining)+" seconds.");return 0; }
    float range=PKS_RangedTouchRange(p,target);
    if(range<=0.0 || GetDistanceBetween(p,target)>range)
    { PKS_Feedback(p,"Exhausted: target is outside ranged touch range (20m). No cooldown spent.");return 0; }
    if(TouchAttackRanged(target,TRUE,p)==0)
    { PKS_Feedback(p,"Exhausted: ranged touch attack missed. No cooldown spent.");return -1; }
    SetLocalInt(p,"PKS_EREADY",PKS_Now()+60);PKS_SaveCooldowns(p);
    if(GetIsImmune(target,IMMUNITY_TYPE_SLOW,p))
    { PKS_Feedback(p,"Exhausted: touch hit, but target is immune to slow. Cooldown: 60 seconds.");return 1; }
    // Refresh only this caster's Exhausted; leave other movement effects alone.
    string tag="PKS_EXHAUSTED_"+ObjectToString(p);
    effect old=GetFirstEffect(target);
    while(GetIsEffectValid(old))
    {
        if(GetEffectTag(old)==tag) RemoveEffect(target,old);
        old=GetNextEffect(target);
    }
    effect slow=SetEffectCreator(TagEffect(EffectMovementSpeedDecrease(50),tag),p);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,slow,target,12.0);
    // Original Cormyr Fear visuals: PRC vampiric burst, then the Slow impact.
    // Only the presentation is delayed; the 12-second movement debuff starts now.
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(922),target);
    AssignCommand(GetModule(),DelayCommand(1.0,ApplyEffectToObject(DURATION_TYPE_INSTANT,
        EffectVisualEffect(VFX_IMP_SLOW),target)));
    PKS_Feedback(p,"Exhausted: touch hit. Movement speed -50% for 2 rounds. Cooldown: 60 seconds.");
    return 1;
}

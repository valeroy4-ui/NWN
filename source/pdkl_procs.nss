#include "pdkl_core"
#include "nwnx_damage"

string PDKL_ProcName(int kind)
{
    if(kind==14) return "Slow";
    if(kind==15) return "Stun";
    if(kind==16) return "Flesh to Stone";
    if(kind==17) return "CON damage";
    if(kind==18) return "Finger of Death";
    return "Vorpal";
}
string PDKL_ProcTag(object owner,int kind)
{ return "PDKL_PROC_"+ObjectToString(owner)+"_"+IntToString(kind); }
int PDKL_ProcImmunity(object victim,object attacker,int kind)
{
    if((kind==15 || kind==16 || kind>=18) && GetImmortal(victim)) return TRUE;
    if(kind>=17 && GetIsImmune(victim,IMMUNITY_TYPE_CRITICAL_HIT,attacker)) return TRUE;
    if(kind==14) return GetIsImmune(victim,IMMUNITY_TYPE_SLOW,attacker);
    if(kind==15) return GetIsImmune(victim,IMMUNITY_TYPE_STUN,attacker);
    if(kind==16) return GetIsImmune(victim,IMMUNITY_TYPE_PARALYSIS,attacker);
    if(kind==17) return GetIsImmune(victim,IMMUNITY_TYPE_ABILITY_DECREASE,attacker);
    if(kind==19 && GetLocalInt(victim,"IHAVEDEVASTIMMUNITY")) return TRUE;
    return GetPlotFlag(victim) || GetIsImmune(victim,IMMUNITY_TYPE_DEATH,attacker);
}
void PDKL_ProcFeedback(object owner,object attacker,object victim,int kind,int dc,int outcome)
{
    string result=outcome==1?"saved":(outcome==2?"immune":"applied");
    if(GetLocalInt(owner,"PDKA_LOG"))
        SendMessageToPC(owner,"[Link proc] "+PDKL_ProcName(kind)+" -> "+GetName(victim)+
            ": "+result+", DC="+IntToString(dc)+".");
    if(GetLocalInt(GetModule(),"PDKA_PROC_TRACE"))
    {
        SetLocalInt(owner,"PDKL_PROC_OUTCOME",outcome);
        SetLocalInt(owner,"PDKL_PROC_KIND",kind);
        SetLocalInt(owner,"PDKL_PROC_DC",dc);
        if(outcome==3) SetLocalInt(owner,"PDKL_PROC_APPLIED_"+IntToString(kind),
            GetLocalInt(owner,"PDKL_PROC_APPLIED_"+IntToString(kind))+1);
        WriteTimestampedLogEntry("PDK PROC EVENT: owner="+ObjectToString(owner)+" attacker="+
            ObjectToString(attacker)+" victim="+ObjectToString(victim)+" kind="+IntToString(kind)+
            " DC="+IntToString(dc)+" outcome="+result);
    }
}
// Return 0=not eligible, 1=saved, 2=immune, 3=effect submitted.
// Stats are the PDK's snapshot at the hit; the linked attacker owns the effect
// and kill credit. One call applies exactly one selected variant.
int PDKL_ResolveProc(object owner,object attacker,object victim,int kind,
    int level,int strength,int dexterity,int attackResult)
{
    if(!PDKL_ProcTriggers(kind,level,attackResult) || !PDKL_Alive(owner)
        || !PDKL_Alive(attacker) || !PDKL_Alive(victim)
        || attacker==victim || GetObjectType(victim)!=OBJECT_TYPE_CREATURE) return 0;
    int dc=PDKL_ProcDC(kind,level,strength,dexterity);
    if(PDKL_ProcImmunity(victim,attacker,kind))
    { PDKL_ProcFeedback(owner,attacker,victim,kind,dc,2);return 2; }
    int saved;int save=PDKL_ProcSaveType(kind);
    int subtype=kind>=18?SAVING_THROW_TYPE_DEATH:SAVING_THROW_TYPE_NONE;
    if(save==SAVING_THROW_WILL) saved=WillSave(victim,dc,subtype,attacker);
    else if(save==SAVING_THROW_FORT) saved=FortitudeSave(victim,dc,subtype,attacker);
    else saved=ReflexSave(victim,dc,subtype,attacker);
    if(saved)
    { PDKL_ProcFeedback(owner,attacker,victim,kind,dc,1);return 1; }
    effect e;
    if(kind==14) e=EffectSlow();
    else if(kind==15) e=EffectStunned();
    else if(kind==16) e=EffectPetrify();
    else if(kind==17) e=EffectAbilityDecrease(ABILITY_CONSTITUTION,level/10);
    else e=EffectDeath(FALSE,TRUE);
    string tag=PDKL_ProcTag(owner,kind);
    if(kind<=16)
    {
        // Refresh this PDK's same control effect, preserving other owners.
        effect old=GetFirstEffect(victim);
        while(GetIsEffectValid(old))
        {
            if(GetEffectTag(old)==tag) RemoveEffect(victim,old);
            old=GetNextEffect(victim);
        }
    }
    // CON damage on separate critical hits uses standard temporary ability
    // decrease stacking/caps. Each application expires independently.
    e=TagEffect(SetEffectCreator(SupernaturalEffect(e),attacker),tag);
    if(kind<=17) ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e,victim,RoundsToSeconds(level/10));
    else ApplyEffectToObject(DURATION_TYPE_INSTANT,e,victim);
    PDKL_ProcFeedback(owner,attacker,victim,kind,dc,3);
    return 3;
}
void PDKL_DispatchProc(object owner,object attacker,object victim,int slot,int kind,
    int level,int strength,int dexterity,int attackResult)
{
    if(GetLocalObject(owner,PDKL_Key("TARGET",slot))!=attacker
        || GetLocalInt(owner,PDKL_Key("KIND",slot))!=kind || !PDKL_BenefitActive(owner,slot)) return;
    PDKL_ResolveProc(owner,attacker,victim,kind,level,strength,dexterity,attackResult);
}
void PDKL_QueueProcsForOwner(object owner,object attacker,struct NWNX_Damage_AttackEventData d)
{
    object victim=d.oTarget;int attackResult=d.iAttackResult;
    int slot;int level=PDKL_Level(owner);
    int strength=GetAbilityModifier(ABILITY_STRENGTH,owner);
    int dexterity=GetAbilityModifier(ABILITY_DEXTERITY,owner);
    for(slot=1;slot<=PDKL_MAX;slot++)
    {
        int kind=GetLocalInt(owner,PDKL_Key("KIND",slot));
        if(GetLocalObject(owner,PDKL_Key("TARGET",slot))!=attacker
            || !PDKL_ProcTriggers(kind,level,attackResult) || !PDKL_BenefitActive(owner,slot)) continue;
        // Commit NWNX's current attack data before effects can run death/damage
        // scripts. Scheduling on the module also survives actor action changes.
        AssignCommand(GetModule(),DelayCommand(0.0,PDKL_DispatchProc(owner,attacker,victim,
            slot,kind,level,strength,dexterity,attackResult)));
    }
}

#include "pdk_active"
int PKB_Duration(int kind) { if(kind==2) return 300;return 180; }
string PKB_CD(int kind) { return "PKB_CD"+IntToString(kind); }
void PKB_SaveAs(object p,string identity)
{
    if(identity=="") return;
    object m=GetModule();int i;
    for(i=1;i<=3;i++)
    {
        string key=PKB_CD(i),stored=key+":"+identity;
        if(GetLocalInt(p,key)>GetLocalInt(m,stored)) SetLocalInt(m,stored,GetLocalInt(p,key));
        PKS_DBPut(p,key,GetLocalInt(m,stored));
    }
    for(i=1;i<=2;i++)
    {
        string key="PKB_SMREF"+IntToString(i),used="PKB_SMUSED"+IntToString(i);
        if(GetLocalInt(p,key)>=GetLocalInt(m,key+":"+identity))
        { SetLocalInt(m,key+":"+identity,GetLocalInt(p,key));SetLocalInt(m,used+":"+identity,GetLocalInt(p,used)); }
        PKS_DBPut(p,key,GetLocalInt(m,key+":"+identity));
        PKS_DBPut(p,used,GetLocalInt(m,used+":"+identity));
    }
}
void PKB_RestoreAs(object p,string identity)
{
    if(identity=="") return;
    int j;
    for(j=1;j<=3;j++)
    {
        string key=PKB_CD(j);int deadline=PKS_DBGet(p,key);
        if(deadline>GetLocalInt(p,key)) SetLocalInt(p,key,deadline);
    }
    for(j=1;j<=2;j++)
    {
        string ref="PKB_SMREF"+IntToString(j),used="PKB_SMUSED"+IntToString(j);
        int deadline=PKS_DBGet(p,ref);
        if(deadline>=GetLocalInt(p,ref))
        { SetLocalInt(p,ref,deadline);SetLocalInt(p,used,PKS_DBGet(p,used)); }
    }
    PKB_SaveAs(p,identity);object m=GetModule();int i;
    for(i=1;i<=3;i++) SetLocalInt(p,PKB_CD(i),GetLocalInt(m,PKB_CD(i)+":"+identity));
    for(i=1;i<=2;i++)
    {
        string key="PKB_SMREF"+IntToString(i),used="PKB_SMUSED"+IntToString(i);
        SetLocalInt(p,key,GetLocalInt(m,key+":"+identity));SetLocalInt(p,used,GetLocalInt(m,used+":"+identity));
    }
}
void PKB_Save(object p) { PKB_SaveAs(p,PKS_Identity(p)); }
void PKB_Restore(object p) { PKB_RestoreAs(p,PKS_Identity(p)); }
int PKB_MinLevel(int kind) { if(kind==2) return 6;if(kind==3) return 5;return 1; }
int PKB_Value(int kind,int level,int self)
{
    if(kind==3) return level/3;
    if(!self) return level/18;
    if(kind==2) return level/9;
    return level/10;
}
string PKB_Tag(int kind) { return "PKB_AURA_"+IntToString(kind); }
void PKB_Buff(object owner,object target,int kind,int level,int alignment)
{
    int value=PKB_Value(kind,level,owner==target);
    string tag=PKB_Tag(kind);effect old=GetFirstEffect(target);
    while(GetIsEffectValid(old))
    {
        if(GetEffectTag(old)==tag && GetEffectCreator(old)==owner) RemoveEffect(target,old);
        old=GetNextEffect(target);
    }
    if(value<=0) return;
    effect bonus=EffectRunScript("","","",0.0,IntToString(value));
    if(kind==1) bonus=EffectAttackIncrease(value);
    // The native weapon-damage hook consumes this timed marker. An ordinary
    // EffectDamageIncrease with BASE_WEAPON does not add this damage reliably.
    else if(kind==3) bonus=EffectRunScript("","","",0.0,IntToString(value)+":"+IntToString(alignment));
    // Same spell id per aura: ordinary native AB/damage stacking rules apply.
    int spell=806;if(kind==2) spell=807;else if(kind==3) spell=809;
    bonus=SetEffectSpellId(SetEffectCreator(TagEffect(SupernaturalEffect(bonus),tag),owner),spell);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,bonus,target,30.0);
    PKV_AuraBuff(target,kind);
}
int PKB_StandBonus(object target)
{
    int best;effect e=GetFirstEffect(target);
    while(GetIsEffectValid(e))
    {
        if(GetEffectTag(e)==PKB_Tag(2))
        { int value=StringToInt(GetEffectString(e,0));if(value>best) best=value; }
        e=GetNextEffect(target);
    }
    return best;
}
int PKB_HornTargetRoll(object target,int die)
{ return GetAbilityScore(target,ABILITY_STRENGTH)+die+PKB_StandBonus(target); }
int PKB_HornWins(int casterRoll,object target,int die)
{ return casterRoll>PKB_HornTargetRoll(target,die); }
void PKB_Stop(object p)
{
    int kind;for(kind=1;kind<=3;kind++)
    { DeleteLocalInt(p,"PKB_END"+IntToString(kind));SetLocalInt(p,"PKB_TOKEN"+IntToString(kind),GetLocalInt(p,"PKB_TOKEN"+IntToString(kind))+1); }
}
void PKB_Pulse(object p,int kind,int token)
{
    if(!GetIsObjectValid(p) || GetLocalInt(p,"PKB_TOKEN"+IntToString(kind))!=token) return;
    if(!PDKL_Alive(p) || PDKL_Level(p)<PKB_MinLevel(kind)
        || PKS_Remaining(p,"PKB_END"+IntToString(kind))<=0) return;
    int level=PDKL_Level(p),alignment=GetLocalInt(p,"PKB_WRATH_ALIGN");
    PKV_AuraPulse(p,kind,alignment);
    // Auras follow the caster's current area, not the initial cast point.
    object target=GetFirstObjectInArea(GetArea(p),OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(target))
    {
        if(PDKL_Alive(target) && (target==p || ((GetIsFriend(target,p) || GetFactionEqual(target,p))
            && !GetIsEnemy(target,p) && !GetIsEnemy(p,target)))
            && GetDistanceBetween(p,target)<=PDKA_RADIUS) PKB_Buff(p,target,kind,level,alignment);
        target=GetNextObjectInArea(GetArea(p),OBJECT_TYPE_CREATURE);
    }
    SetLocalInt(p,"PKB_PULSES"+IntToString(kind),GetLocalInt(p,"PKB_PULSES"+IntToString(kind))+1);
    AssignCommand(GetModule(),DelayCommand(30.0,PKB_Pulse(p,kind,token)));
}
int PKB_Aura(object p,int kind,int alignment=ALIGNMENT_EVIL)
{
    if(kind<1 || kind>3 || !PDKL_Alive(p) || PDKL_Level(p)<PKB_MinLevel(kind)) return 0;
    if(kind==3 && alignment!=ALIGNMENT_GOOD && alignment!=ALIGNMENT_EVIL) return 0;
    PKB_Restore(p);int remaining=PKS_Remaining(p,PKB_CD(kind));
    if(remaining>0) { PKS_Feedback(p,"Aura cooldown: "+IntToString(remaining)+" seconds.");return 0; }
    int duration=PKB_Duration(kind),token=GetLocalInt(p,"PKB_TOKEN"+IntToString(kind))+1;
    SetLocalInt(p,PKB_CD(kind),PKS_Now()+duration);SetLocalInt(p,"PKB_END"+IntToString(kind),PKS_Now()+duration);
    SetLocalInt(p,"PKB_TOKEN"+IntToString(kind),token);
    if(kind==3) SetLocalInt(p,"PKB_WRATH_ALIGN",alignment);
    PKB_Save(p);PKB_Pulse(p,kind,token);
    PKS_Feedback(p,(kind==1?"Dragon Knight Inspire":(kind==2?"Dragon Knight Stand":"Dragon Knight Wrath"))+
        " active: "+IntToString(duration)+" seconds, radius 10m, pulse every 30s.");
    return 1;
}

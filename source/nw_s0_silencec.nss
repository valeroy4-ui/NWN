// Existing Silence heartbeat also receives native EffectRunScript interval callbacks.
const string SI270_FAILURE_TAG="SI270_FAILURE";
void SI270_Pulse(object field)
{
    if(!GetIsObjectValid(field) || !GetLocalInt(field,"SI270_READY")) return;
    object caster=GetAreaOfEffectCreator(field),owner=GetLocalObject(field,"AOE_OWNER");
    if(!GetIsObjectValid(caster) || !GetIsObjectValid(owner) || GetIsDead(caster) || GetIsDead(owner)
        || GetArea(owner)!=GetArea(field)) {DestroyObject(field);return;}
    int percent=GetLocalInt(field,"SI270_PERCENT");
    float tail=GetLocalFloat(field,"SI270_TAIL");
    if(percent<1 || percent>100 || tail<=0.0) return;
    string failureTag=SI270_FAILURE_TAG+":"+GetObjectUUID(caster);
    int count=GetLocalInt(field,"SI270_PULSES")+1,affected=0;
    SetLocalInt(field,"SI270_PULSES",count);
    location center=GetLocation(owner);
    object target=GetFirstObjectInShape(SHAPE_SPHERE,3.0,center,FALSE,OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(target))
    {
        if(target!=caster && target!=owner && !GetIsDead(target) && !GetIsDM(target) && GetIsEnemy(target,caster))
        {
            // Refresh only this caster's failure debuff; never remove the target's own aura.
            effect e=GetFirstEffect(target);
            while(GetIsEffectValid(e))
            {
                if(GetEffectType(e)==EFFECT_TYPE_SPELL_FAILURE && GetEffectSpellId(e)==SPELL_SILENCE
                    && GetEffectTag(e)==failureTag) RemoveEffect(target,e);
                e=GetNextEffect(target);
            }
            SignalEvent(target,EventSpellCastAt(caster,SPELL_SILENCE));
            AssignCommand(caster,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
                TagEffect(SetEffectSpellId(EffectSpellFailure(percent,SPELL_SCHOOL_GENERAL,SPELL_FAILURE_TYPE_ALL),SPELL_SILENCE),failureTag),
                target,tail));
            affected++;
        }
        target=GetNextObjectInShape(SHAPE_SPHERE,3.0,center,FALSE,OBJECT_TYPE_CREATURE);
    }
    if(GetIsPC(caster) && FindSubString(GetStringLowerCase(GetName(caster)),"[test]")>=0)
    {
        string s="[SI270 PULSE] number="+IntToString(count)+" failure="+IntToString(percent)
            +" seconds="+FloatToString(tail,0,2)+" affected="+IntToString(affected);
        PrintString(s);SendMessageToPC(caster,s);
    }
}
void main()
{
    effect timer=GetLastRunScriptEffect();
    if(GetIsEffectValid(timer) && GetEffectSpellId(timer)==SPELL_SILENCE)
    {
        object field=GetLocalObject(OBJECT_SELF,"OWNER_"+IntToString(SPELL_SILENCE));
        if(GetIsObjectValid(field) && GetLocalObject(field,"AOE_OWNER")==OBJECT_SELF
            && GetEffectTag(timer)==GetLocalString(field,"SI270_AURA_TAG")) SI270_Pulse(field);
        return;
    }
    if(GetObjectType(OBJECT_SELF)!=OBJECT_TYPE_AREA_OF_EFFECT) return;
    object caster=GetAreaOfEffectCreator(),owner=GetLocalObject(OBJECT_SELF,"AOE_OWNER");
    if(!GetIsObjectValid(caster) || GetIsDead(caster) || (GetIsObjectValid(owner) && GetIsDead(owner)))
    {DestroyObject(OBJECT_SELF);return;}
    // Engine heartbeats do lifecycle checks only; exactly one immediate pulse is allowed.
    if(GetLocalInt(OBJECT_SELF,"SI270_READY") && !GetLocalInt(OBJECT_SELF,"SI270_FIRST_PULSE"))
    {SetLocalInt(OBJECT_SELF,"SI270_FIRST_PULSE",TRUE);SI270_Pulse(OBJECT_SELF);}
}

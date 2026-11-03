// Row 270: pulse spell failure; existing Silence resources only.
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

const string SI270_AURA_TAG="SI270_AURA";
void main()
{
    spell.DurationType=SPELL_DURATION_TYPE_ROUNDS;
    if(!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    if(GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class!=CLASS_TYPE_BARD && spell.Class!=CLASS_TYPE_CLERIC)
    {SendMessageToPC(spell.Caster,"Silence requires Bard or Cleric spellcasting.");return;}
    if(!GetIsObjectValid(spell.Target) || GetObjectType(spell.Target)!=OBJECT_TYPE_CREATURE || GetIsDead(spell.Target)) return;
    int rank=0;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION,spell.Caster)) rank=3;
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION,spell.Caster)) rank=2;
    else if(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION,spell.Caster)) rank=1;
    int percent=5+5*rank;
    float tail=15.0+3.0*IntToFloat(rank),interval=36.0-6.0*IntToFloat(rank);
    int rounds=spell.Level;
    if(spell.Meta & METAMAGIC_EXTEND) rounds*=2;
    float duration=DurationToSeconds(rounds);
    int token=GetLocalInt(spell.Target,"SI270_CAST_TOKEN")+1;
    SetLocalInt(spell.Target,"SI270_CAST_TOKEN",token);
    string castTag=SI270_AURA_TAG+":"+GetObjectUUID(spell.Caster)+":"+IntToString(token);
    effect aura=EffectAreaOfEffect(AOE_MOB_SILENCE);
    effect timer=EffectRunScript("","","nw_s0_silencec",interval);
    effect link=EffectLinkEffects(aura,timer);
    link=EffectLinkEffects(link,EffectVisualEffect(VFX_DUR_AURA_SILENCE));
    link=EffectLinkEffects(link,EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE));
    link=TagEffect(link,castTag);
    SignalEvent(spell.Target,EventSpellCastAt(spell.Caster,spell.Id,GetIsEnemy(spell.Target,spell.Caster)));
    RemoveEffectsFromSpell(spell.Target,spell.Id);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,link,spell.Target,duration);
    object field=spellsSetupNewAOE(AOE_MOB_SILENCE);
    if(GetIsObjectValid(field))
    {
        SetLocalString(field,"SI270_AURA_TAG",castTag);
        SetLocalInt(field,"SI270_PERCENT",percent);
        SetLocalFloat(field,"SI270_TAIL",tail);
        SetLocalFloat(field,"SI270_INTERVAL",interval);
        SetLocalInt(field,"SI270_READY",TRUE);
        // First pulse now; subsequent pulses use the linked native interval effect.
        ExecuteScript("nw_s0_silencec",field);
    }
    if(GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0)
    {
        SetLocalObject(GetModule(),"SI270_LAST_CASTER",spell.Caster);
        SetLocalObject(GetModule(),"SI270_LAST_OWNER",spell.Target);
        string s="[SI270] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)
            +" duration="+FloatToString(duration,0,2)+" radius=3.00 failure="+IntToString(percent)
            +" effectSeconds="+FloatToString(tail,0,2)+" pulseSeconds="+FloatToString(interval,0,2)
            +" rank="+IntToString(rank)+" baseCooldown=180 enemiesOnly=1";
        WriteTimestampedLogEntry(s);SendMessageToPC(spell.Caster,s);
    }
}

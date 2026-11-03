// Row 271: Spell Resistance. Original two includes, existing impact script.
#include "70_inc_spells"
#include "x2_inc_spellhook"
const int SR271_ROUNDS_PER_LEVEL=2;
const int SR271_BASE_BONUS=8;
const int SR271_SF_BONUS=10;
const int SR271_GSF_BONUS=12;
const int SR271_ESF_BONUS=14;
void main()
{
    spell.DurationType=SPELL_DURATION_TYPE_ROUNDS;
    if(!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    if(GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class!=CLASS_TYPE_CLERIC && spell.Class!=CLASS_TYPE_DRUID)
    {SendMessageToPC(spell.Caster,"Spell Resistance requires Cleric or Druid spellcasting.");return;}
    if(spell.Level<=0) return;
    spell.Target=spell.Caster;
    int bonus=SR271_BASE_BONUS;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION,spell.Caster)) bonus=SR271_ESF_BONUS;
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION,spell.Caster)) bonus=SR271_GSF_BONUS;
    else if(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION,spell.Caster)) bonus=SR271_SF_BONUS;
    int sr=spell.Level+bonus,rounds=SR271_ROUNDS_PER_LEVEL*spell.Level;
    if(spell.Meta & METAMAGIC_EXTEND) rounds*=2;
    int before=GetSpellResistance(spell.Target);
    // Replace only this spell; never directly change innate/item SR.
    effect e=GetFirstEffect(spell.Target);
    while(GetIsEffectValid(e))
    {
        if(GetEffectSpellId(e)==spell.Id) RemoveEffect(spell.Target,e);
        e=GetNextEffect(spell.Target);
    }
    effect link=EffectLinkEffects(EffectSpellResistanceIncrease(sr),EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    link=EffectLinkEffects(link,EffectVisualEffect(VFX_DUR_MAGIC_RESISTANCE));
    SignalEvent(spell.Target,EventSpellCastAt(spell.Caster,spell.Id,FALSE));
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_MAGIC_PROTECTION),spell.Target);
    float duration=DurationToSeconds(rounds);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,link,spell.Target,duration);
    if(GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0)
    {
        SetLocalObject(GetModule(),"SR271_LAST_CASTER",spell.Caster);
        string s="[SR271] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)+" SR="+IntToString(sr)
            +" duration="+FloatToString(duration,0,2)+" SF="+IntToString(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION,spell.Caster))
            +" GSF="+IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION,spell.Caster))
            +" ESF="+IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION,spell.Caster))+" nativeSRBefore="+IntToString(before);
        PrintString(s);SendMessageToPC(spell.Caster,s);
    }
}

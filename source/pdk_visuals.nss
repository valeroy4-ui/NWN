#include "pdka_vfx"
// Presentation only: native NWN models, instant effects, no bonus or damage effects.
void PKV_Flash(object target,int visual,float scale=1.0)
{
    if(!GetIsObjectValid(target)) return;
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(visual,FALSE,scale),target);
}
int PKV_AuraWave(int kind)
{
    if(kind==1) return PDKA_WAVE_INSPIRE;
    if(kind==2) return PDKA_WAVE_STAND;
    return PDKA_WAVE_WRATH;
}
int PKV_AuraBuffVFX(int kind)
{
    if(kind==1) return PDKA_BUFF_INSPIRE;
    if(kind==2) return PDKA_BUFF_STAND;
    return PDKA_BUFF_WRATH;
}
void PKV_EmitAuraPulse(object caster,int kind,int token)
{
    // Resolve the live caster at actual visual onset, never a saved location.
    if(!GetIsObjectValid(caster) || GetIsDead(caster)
        || GetLocalInt(caster,"PKB_TOKEN"+IntToString(kind))!=token) return;
    effect pulse=TagEffect(EffectVisualEffect(PKV_AuraWave(kind),FALSE,1.0),
        "PDKA_PULSE_"+IntToString(kind));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,pulse,caster,2.6);
}
void PKV_AuraPulse(object caster,int kind,int alignment)
{
    if(!GetIsObjectValid(caster) || kind<1 || kind>3) return;
    int token=GetLocalInt(caster,"PKB_TOKEN"+IntToString(kind));
    float phase=IntToFloat(kind-1)*0.4;
    if(phase==0.0) PKV_EmitAuraPulse(caster,kind,token);
    else AssignCommand(GetModule(),DelayCommand(phase,PKV_EmitAuraPulse(caster,kind,token)));
}
void PKV_AuraBuff(object target,int kind)
{
    PKV_Flash(target,PKV_AuraBuffVFX(kind),1.0);
}
void PKV_SmiteCast(object caster,int kind)
{
    PKV_Flash(caster,kind==1?VFX_IMP_EVIL_HELP:VFX_IMP_HOLY_AID,0.7);
}
void PKV_SmiteImpact(object caster,object target,int feat,int result,int ranged)
{
    if((feat!=1422 && feat!=1423) || ranged || !GetIsObjectValid(target)) return;
    if(result!=1 && result!=3 && result!=7 && result!=10) return;
    if(GetLevelByClass(41,caster)<1) return;
    int alignment=feat==1422?ALIGNMENT_GOOD:ALIGNMENT_EVIL;
    if(GetAlignmentGoodEvil(target)!=alignment) return;
    // These flashes do not add holy/negative damage: Smite remains physical.
    PKV_Flash(target,feat==1422?VFX_IMP_NEGATIVE_ENERGY:VFX_IMP_DIVINE_STRIKE_HOLY,0.7);
}
void PKV_Knowledge(object caster) { PKV_Flash(caster,VFX_IMP_HEAD_MIND,0.7); }
void PKV_Swap(object target)
{
    PKV_Flash(target,GetAlignmentGoodEvil(target)==ALIGNMENT_GOOD?VFX_IMP_HEAD_HOLY:VFX_IMP_HEAD_EVIL,0.8);
}

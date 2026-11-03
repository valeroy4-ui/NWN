// Row 255: Sound Burst. Bard/Cleric 2; Earth affects only Cleric DC bonus.
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

int SB255_Earth(object o)
{
    return GetDomain(o,1,CLASS_TYPE_CLERIC)==DOMAIN_EARTH || GetDomain(o,2,CLASS_TYPE_CLERIC)==DOMAIN_EARTH;
}
int SB255_Focus(object o)
{
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION,o)) return 6;
    if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION,o)) return 3;
    if(GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION,o)) return 1;
    return 0;
}
int SB255_Bonus(object o,int nClass,int nCL)
{
    int n=0,cap=8;
    if(nClass==CLASS_TYPE_BARD) {n=nCL-29;cap=11;}
    else if(nClass==CLASS_TYPE_CLERIC && SB255_Earth(o)) n=(nCL-23)/2;
    if(n<0) n=0;
    if(n>cap) n=cap;
    return n;
}
int SB255_DC(object o,int nClass,int nCL,int nSpellLevel)
{
    if(nSpellLevel<0) nSpellLevel=2;
    if(nSpellLevel>9) nSpellLevel=9;
    int ability=ABILITY_CHARISMA;
    if(nClass==CLASS_TYPE_CLERIC) ability=ABILITY_WISDOM;
    return 10+GetAbilityModifier(ability,o)+nSpellLevel+SB255_Focus(o)+SB255_Bonus(o,nClass,nCL);
}
void main()
{
    spell.Dice=8;
    spell.DamageType=DAMAGE_TYPE_SONIC;
    spell.Range=3.3;
    spell.SavingThrow=SAVING_THROW_WILL;
    if(!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    spell.Range=3.3;
    int nClass=GetLastSpellCastClass();
    int nSlot=GetLastSpellLevel();
    if(GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item))
    {
        if(nClass!=CLASS_TYPE_BARD && nClass!=CLASS_TYPE_CLERIC)
        {SendMessageToPC(spell.Caster,"Sound Burst requires Bard or Cleric spellcasting.");return;}
        spell.DC=SB255_DC(spell.Caster,nClass,spell.Level,nSlot);
    }
    // User decision: instantaneous Sound Burst has no ground-AoE placement restrictions.
    if(GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0)
    {
        SetLocalObject(GetModule(),"SB255_LAST_CASTER",spell.Caster);
        string s="[SB255] CL="+IntToString(spell.Level)+" class="+IntToString(nClass)
            +" Earth="+IntToString(SB255_Earth(spell.Caster))+" spellLevel="+IntToString(nSlot)+" DC="+IntToString(spell.DC)
            +" focus="+IntToString(SB255_Focus(spell.Caster))+" classBonus="+IntToString(SB255_Bonus(spell.Caster,nClass,spell.Level))
            +" radius=3.30 damage=1d8 sonic stun=12s cooldown=30s";
        WriteTimestampedLogEntry(s);SendMessageToPC(spell.Caster,s);
    }
    effect eLink=EffectLinkEffects(EffectStunned(),EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE));
    eLink=EffectLinkEffects(eLink,EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_FNF_SOUND_BURST),spell.Loc);
    object target=GetFirstObjectInShape(SHAPE_SPHERE,spell.Range,spell.Loc,TRUE,OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(target))
    {
        // Literal all creatures includes allies and caster; normal SR/immunities remain.
        if(!GetIsDead(target) && !GetIsDM(target))
        {
            SignalEvent(target,EventSpellCastAt(spell.Caster,spell.Id));
            if(!MyResistSpell(spell.Caster,target))
            {
                int damage=MaximizeOrEmpower(8,1,spell.Meta);
                // Preserve the original sound descriptor: deaf/silenced targets cannot be stunned.
                if(GetIsAbleToHear(target) && !MySavingThrow(SAVING_THROW_WILL,target,spell.DC,spell.SaveType,spell.Caster))
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eLink,target,12.0);
                ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(spell.DmgVfxS),target);
                DelayCommand(0.01,ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(damage,DAMAGE_TYPE_SONIC),target));
            }
        }
        target=GetNextObjectInShape(SHAPE_SPHERE,spell.Range,spell.Loc,TRUE,OBJECT_TYPE_CREATURE);
    }
}

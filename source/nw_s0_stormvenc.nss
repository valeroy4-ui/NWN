// Preserve original per-round acid/electric damage; shock is six seconds.
#include "sv257_inc"
#include "_inc_spells"
void main()
{
    aoesDeclareMajorVariables();
    if(!GetLocalInt(OBJECT_SELF,"SV257_READY")) return;
    if(!GetIsObjectValid(aoe.Creator) || GetIsDead(aoe.Creator))
    {ExecuteScript("_plc_aoe_destroy",OBJECT_SELF);DestroyObject(OBJECT_SELF,1.0);return;}
    object target=GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(target))
    {
        if(!GetIsDead(target) && !GetIsDM(target) && spellsIsTarget(target,SPELL_TARGET_SELECTIVEHOSTILE,aoe.Creator)
            && GetDistanceBetweenLocations(GetLocation(aoe.AOE),GetLocation(target))<=GetLocalFloat(aoe.AOE,"SV257_RADIUS"))
        {
            SignalEvent(target,EventSpellCastAt(aoe.AOE,spell.Id));
            float delay=GetRandomDelay(0.5,2.0);
            if(!MyResistSpell(aoe.Creator,target,delay))
            {
                RemoveSpecificEffect(EFFECT_TYPE_INVISIBILITY,target);
                DelayCommand(delay,ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_ACID_S),target));
                DelayCommand(delay,ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(d6(6),DAMAGE_TYPE_ACID),target));
                if(!MySavingThrow(GetLocalInt(aoe.AOE,"SV257_SAVE"),target,spell.DC,SAVING_THROW_TYPE_ELECTRICITY,aoe.Creator,delay))
                {
                    DelayCommand(delay,ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_LIGHTNING_M),target));
                    DelayCommand(delay,ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(d6(6),DAMAGE_TYPE_ELECTRICAL),target));
                    int chance=GetLocalInt(aoe.AOE,"SV257_IGNORE_CHANCE");
                    int bypass=chance>0 && d100()<=chance;
                    int immune=GetIsImmune(target,IMMUNITY_TYPE_MIND_SPELLS,aoe.Creator);
                    if((!immune || bypass) && !GetHasSpellEffect(SPELL_SHOCK,target))
                    {
                        // Fresh linked effect per target; never reuse a bypassed effect.
                        effect shock=EffectLinkEffects(spells_Shock(),EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED));
                        shock=EffectLinkEffects(shock,EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE));
                        shock=SetEffectSpellId(shock,SPELL_SHOCK);
                        if(bypass) shock=IgnoreEffectImmunity(shock);
                        DelayCommand(delay,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,shock,target,6.0));
                        if(SV257_Test(aoe.Creator))
                        {
                            string s="[SV257 SHOCK ATTEMPT] target="+GetName(target)+" seconds=6 bypass="+IntToString(bypass)+" chance="+IntToString(chance)+" spellId="+IntToString(SPELL_SHOCK);
                            WriteTimestampedLogEntry(s);SendMessageToPC(aoe.Creator,s);
                        }
                    }
                }
            }
        }
        target=GetNextInPersistentObject(aoe.AOE);
    }
}

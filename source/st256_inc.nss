// Private implementation for row 256. No shared libraries are changed.
#include "70_inc_spells"
#include "x0_i0_spells"
#include "_inc_runes"
int ST256_Earth(object o)
{
    return GetDomain(o,1,CLASS_TYPE_CLERIC)==DOMAIN_EARTH || GetDomain(o,2,CLASS_TYPE_CLERIC)==DOMAIN_EARTH;
}
int ST256_Rank(object o)
{
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION,o)) return 3;
    if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION,o)) return 2;
    if(GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION,o)) return 1;
    return 0;
}
int ST256_Focus(object o)
{
    int rank=ST256_Rank(o);
    return rank==3?6:(rank==2?3:rank);
}
int ST256_Bonus(object o,int cls,int cl)
{
    if(cls!=CLASS_TYPE_DRUID && !(cls==CLASS_TYPE_CLERIC && ST256_Earth(o))) return 0;
    int n=(cl-23)/2;
    if(n<0) n=0;
    if(n>8) n=8;
    return n;
}
// Grant contract: rune/fame-shop systems can set a positive local on the caster;
// an item grants the same property only while equipped. No property is implicit.
int ST256_Property(object o,string key)
{
    if(GetLocalInt(o,key)>0) return TRUE;
    int slot;
    for(slot=0;slot<18;slot++)
    {
        object item=GetItemInSlot(slot,o);
        if(GetIsObjectValid(item) && GetLocalInt(item,key)>0) return TRUE;
    }
    return FALSE;
}
int ST256_Chance(object o)
{
    int epic=10*(runes_GetHasRune(o,RUNE_TYPE_EPIC_SPELLS,RUNE_EPIC_SPELLS_AOE_POWER_I)
        +runes_GetHasRune(o,RUNE_TYPE_EPIC_SPELLS,RUNE_EPIC_SPELLS_AOE_POWER_II)
        +runes_GetHasRune(o,RUNE_TYPE_EPIC_SPELLS,RUNE_EPIC_SPELLS_AOE_POWER_III)
        +runes_GetHasRune(o,RUNE_TYPE_EPIC_SPELLS,RUNE_EPIC_SPELLS_AOE_POWER_IV)
        +runes_GetHasRune(o,RUNE_TYPE_EPIC_SPELLS,RUNE_EPIC_SPELLS_AOE_POWER_V));
    int extra=ST256_Property(o,"STONEHOLD_IGNORE_IMMUNITY_15")?15:0;
    return epic>extra?epic:extra;
}
int ST256_Test(object o)
{
    return GetIsPC(o) && FindSubString(GetStringLowerCase(GetName(o)),"[test]")>=0;
}
void ST256_Attempt(object cloud,object target)
{
    if(!GetLocalInt(cloud,"ST256_READY")) return;
    object caster=GetAreaOfEffectCreator(cloud);
    if(!GetIsObjectValid(caster) || GetIsDead(caster) || !GetIsObjectValid(target)
        || GetObjectType(target)!=OBJECT_TYPE_CREATURE || GetIsDead(target) || GetIsDM(target)
        || GetHasSpellEffect(547,target)) return;
    SignalEvent(target,EventSpellCastAt(caster,547));
    if(MyResistSpell(caster,target)) return;
    int chance=GetLocalInt(cloud,"ST256_IGNORE_CHANCE");
    int bypass=chance>0 && d100()<=chance;
    // Preserve original mind/paralysis descriptors on the ordinary path. Bypass
    // must also skip MySavingThrow's immunity short-circuit, not just the effect.
    int subtype=GetIsImmune(target,IMMUNITY_TYPE_PARALYSIS,caster)?20:SAVING_THROW_TYPE_MIND_SPELLS;
    if(bypass) subtype=SAVING_THROW_TYPE_NONE;
    if(MySavingThrow(GetLocalInt(cloud,"ST256_SAVE"),target,GetLocalInt(cloud,"AOE_DC"),subtype,caster)) return;
    int seconds=6*MaximizeOrEmpower(3,1,GetLocalInt(cloud,"AOE_META")-1)+GetLocalInt(cloud,"ST256_DURATION_ADD");
    effect hold=EffectLinkEffects(EffectParalyze(),EffectVisualEffect(VFX_DUR_STONEHOLD));
    hold=ExtraordinaryEffect(hold);
    if(bypass) hold=IgnoreEffectImmunity(hold);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,hold,target,IntToFloat(seconds));
    if(ST256_Test(caster))
    {
        string s="[ST256 HIT] target="+GetName(target)+" seconds="+IntToString(seconds)
            +" bypass="+IntToString(bypass)+" chance="+IntToString(chance);
        WriteTimestampedLogEntry(s);SendMessageToPC(caster,s);
    }
}
void ST256_Scan(object cloud)
{
    object target=GetFirstInPersistentObject(cloud,OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(target))
    {
        ST256_Attempt(cloud,target);
        target=GetNextInPersistentObject(cloud,OBJECT_TYPE_CREATURE);
    }
}

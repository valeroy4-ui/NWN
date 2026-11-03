// Private implementation for row 257. No shared libraries are changed.
#include "70_inc_spells"
#include "x0_i0_spells"
#include "_inc_runes"
int SV257_Water(object o)
{
    return GetDomain(o,1,CLASS_TYPE_CLERIC)==DOMAIN_WATER || GetDomain(o,2,CLASS_TYPE_CLERIC)==DOMAIN_WATER;
}
int SV257_Rank(object o)
{
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION,o)) return 3;
    if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION,o)) return 2;
    if(GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION,o)) return 1;
    return 0;
}
int SV257_Focus(object o)
{
    int rank=SV257_Rank(o);
    return rank==3?6:(rank==2?3:rank);
}
int SV257_Bonus(object o,int cls,int cl)
{
    if(cls!=CLASS_TYPE_DRUID && !(cls==CLASS_TYPE_CLERIC && SV257_Water(o))) return 0;
    int n=(cl-23)/2;
    if(n<0) n=0;
    if(n>8) n=8;
    return n;
}
// Grant contract: rune/fame-shop systems can set a positive local on the caster;
// an item grants the same property only while equipped. No property is implicit.
int SV257_Property(object o,string key)
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
int SV257_Chance(object o)
{
    int epic=10*(runes_GetHasRune(o,RUNE_TYPE_EPIC_SPELLS,RUNE_EPIC_SPELLS_AOE_POWER_I)
        +runes_GetHasRune(o,RUNE_TYPE_EPIC_SPELLS,RUNE_EPIC_SPELLS_AOE_POWER_II)
        +runes_GetHasRune(o,RUNE_TYPE_EPIC_SPELLS,RUNE_EPIC_SPELLS_AOE_POWER_III)
        +runes_GetHasRune(o,RUNE_TYPE_EPIC_SPELLS,RUNE_EPIC_SPELLS_AOE_POWER_IV)
        +runes_GetHasRune(o,RUNE_TYPE_EPIC_SPELLS,RUNE_EPIC_SPELLS_AOE_POWER_V));
    int extra=SV257_Property(o,"STORM_IGNORE_IMMUNITY_15")?15:0;
    return epic>extra?epic:extra;
}
int SV257_Test(object o)
{
    return GetIsPC(o) && FindSubString(GetStringLowerCase(GetName(o)),"[test]")>=0;
}

// Row 256: Druid 6, Cleric only through Earth 6.
#include "st256_inc"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "nwnx_object"
void main()
{
    spell.DurationType=SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow=SAVING_THROW_FORT;
    if(!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    int cls=GetLastSpellCastClass(),slot=GetLastSpellLevel();
    if(GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item))
    {
        if(cls!=CLASS_TYPE_DRUID && !(cls==CLASS_TYPE_CLERIC && ST256_Earth(spell.Caster)))
        {SendMessageToPC(spell.Caster,"Stonehold requires Druid or Earth-domain Cleric spellcasting.");return;}
        int circle=slot;
        if(circle<0) circle=6;
        if(circle>9) circle=9;
        spell.DC=10+GetAbilityModifier(ABILITY_WISDOM,spell.Caster)+circle
            +ST256_Focus(spell.Caster)+ST256_Bonus(spell.Caster,cls,spell.Level);
    }
    if(ST256_Property(spell.Caster,"STONEHOLD_WILL_VARIANT"))
    {spell.SavingThrow=SAVING_THROW_WILL;spell.DC-=5;}
    float radius=GetAreaOfEffectRadius(AOE_PER_STONEHOLD);
    if(CheckNearAoes(spell.Caster,spell.Loc,radius)) return;
    if(GetNearTriggers(spell.Caster,spell.Loc,16.0)) return;
    float duration=6.0*IntToFloat(spell.Level);
    if(spell.Meta & METAMAGIC_EXTEND) duration*=2.0;
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_NATURE),spell.Loc);
    effect cloud=EffectAreaOfEffect(AOE_PER_STONEHOLD,"x2_s0_stneholda","x2_s0_stneholdc");
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,cloud,spell.Loc,duration);
    spell.Target=OBJECT_INVALID;
    object ao=spellsSetupNewAOE(AOE_PER_STONEHOLD);
    if(!GetIsObjectValid(ao)) {WriteTimestampedLogEntry("[ST256] Area setup failed");return;}
    SetLocalInt(ao,"AOE_GROUND_RULES",TRUE);
    SetLocalInt(ao,"ST256_SAVE",spell.SavingThrow);
    SetLocalInt(ao,"ST256_DURATION_ADD",3*ST256_Rank(spell.Caster));
    SetLocalInt(ao,"ST256_IGNORE_CHANCE",ST256_Chance(spell.Caster));
    SetLocalInt(ao,"ST256_READY",TRUE);
    // Inhabitants may have entered before metadata initialization; process them now.
    ExecuteScript("x2_s0_stneholdc",ao);
    AddMarkersForAOE(spell.Caster,spell.Loc,duration,radius);
    if(ST256_Test(spell.Caster))
    {
        SetLocalObject(GetModule(),"ST256_LAST_CASTER",spell.Caster);
        string s="[ST256] CL="+IntToString(spell.Level)+" class="+IntToString(cls)+" Earth="+IntToString(ST256_Earth(spell.Caster))
            +" DC="+IntToString(spell.DC)+" focus="+IntToString(ST256_Focus(spell.Caster))+" classBonus="+IntToString(ST256_Bonus(spell.Caster,cls,spell.Level))
            +" save="+(spell.SavingThrow==SAVING_THROW_WILL?"Will":"Fortitude")+" duration="+FloatToString(duration,0,2)
            +" actualRemaining="+FloatToString(NWNX_Object_GetAoEObjectDurationRemaining(ao),0,2)
            +" radius="+FloatToString(radius,0,2)+" hold=1d3*6+"+IntToString(3*ST256_Rank(spell.Caster))
            +" ignoreChance="+IntToString(ST256_Chance(spell.Caster))+" cooldown=60s";
        WriteTimestampedLogEntry(s);SendMessageToPC(spell.Caster,s);
    }
}

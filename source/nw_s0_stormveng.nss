// Row 257: Druid/Cleric 9, Water affects only Cleric DC bonus.
#include "sv257_inc"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "nwnx_object"
#include "sv257_ui_inc"
void main()
{
    spell.Dice=6;
    spell.DamageType=DAMAGE_TYPE_ELECTRICAL;
    spell.DurationType=SPELL_DURATION_TYPE_SECONDS;
    spell.SavingThrow=SAVING_THROW_REFLEX;
    spell.TargetType=SPELL_TARGET_SELECTIVEHOSTILE;
    if(!X2PreSpellCastCode()) return;
    spellsDeclareMajorVariables();
    spell.Id=173;
    int cls=GetLastSpellCastClass(),slot=GetLastSpellLevel();
    if(GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item))
    {
        if(cls!=CLASS_TYPE_DRUID && cls!=CLASS_TYPE_CLERIC)
        {SendMessageToPC(spell.Caster,"Storm of Vengeance requires Druid or Cleric spellcasting.");return;}
        int circle=slot;
        if(circle<0) circle=9;
        if(circle>9) circle=9;
        spell.DC=10+GetAbilityModifier(ABILITY_WISDOM,spell.Caster)+circle
            +SV257_Focus(spell.Caster)+SV257_Bonus(spell.Caster,cls,spell.Level);
    }
    // Primary mode always uses Reflex; the optional property selects Will -4.
    spell.SavingThrow=SAVING_THROW_REFLEX;
    if(SV257_Property(spell.Caster,"STORM_WILL_VARIANT"))
    {spell.SavingThrow=SAVING_THROW_WILL;spell.DC-=4;}
    int medium=GetSpellId()==SVUI_RANGE;
    if(!medium) spell.Loc=GetLocation(spell.Caster);
    else
    {
        if(!SV257_Property(spell.Caster,"STORM_MEDIUM_VARIANT"))
        {SendMessageToPC(spell.Caster,"The Storm range property is no longer active.");return;}
        // The engine provides the point the PLAYER just selected. Never read a saved point.
        spell.Loc=GetSpellTargetLocation();
        if(GetAreaFromLocation(spell.Loc)!=GetArea(spell.Caster)
            || GetDistanceBetweenLocations(GetLocation(spell.Caster),spell.Loc)>20.0
            || !LineOfSightVector(GetPosition(spell.Caster),GetPositionFromLocation(spell.Loc)))
        {SendMessageToPC(spell.Caster,"Storm of Vengeance: target must be visible within 20m in the same area.");return;}
    }
    float radius=medium?5.0:10.0;
    float duration=60.0;
    if(CheckNearAoes(spell.Caster,spell.Loc,radius)) return;
    if(GetNearTriggers(spell.Caster,spell.Loc,16.0)) return;
    int areaType=medium?255:AOE_PER_STORM;
    effect cloud=EffectAreaOfEffect(areaType,"","nw_s0_stormvenc","");
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_FNF_STORM,FALSE,medium?0.5:1.0),spell.Loc);
    cloud=SetEffectSpellId(cloud,173);
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,cloud,spell.Loc,duration);
    spell.Target=OBJECT_INVALID;
    object ao=spellsSetupNewAOE(areaType);
    if(!GetIsObjectValid(ao)) {WriteTimestampedLogEntry("[SV257] Area setup failed");return;}
    NWNX_Object_SetAoEObjectRadius(ao,radius);
    SetLocalFloat(ao,"AOE_RANGE",radius);
    SetLocalFloat(ao,"SV257_RADIUS",radius);
    SetLocalInt(ao,"AOE_GROUND_RULES",TRUE);
    SetLocalInt(ao,"SV257_SAVE",spell.SavingThrow);
    SetLocalInt(ao,"SV257_IGNORE_CHANCE",SV257_Chance(spell.Caster));
    SetLocalInt(ao,"SV257_READY",TRUE);
    if(medium)
    {
        object visual=CreateObject(OBJECT_TYPE_PLACEABLE,"sv257_vanchor",spell.Loc,FALSE,"SV257_VANCHOR");
        if(GetIsObjectValid(visual))
        {
            SetLocalObject(visual,"SV257_CLOUD",ao);
            SetLocalObject(ao,"SV257_VISUAL",visual);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectVisualEffect(248,FALSE,0.5),visual,duration);
            ExecuteScript("sv257_vwatch",visual);
        }
        else WriteTimestampedLogEntry("[SV257 VISUAL] Visual anchor missing");
    }
    AddMarkersForAOE(spell.Caster,spell.Loc,duration,radius);
    if(SV257_Test(spell.Caster))
    {
        SetLocalObject(GetModule(),"SV257_LAST_CASTER",spell.Caster);
        string s="[SV257] CL="+IntToString(spell.Level)+" class="+IntToString(cls)+" Water="+IntToString(SV257_Water(spell.Caster))
            +" DC="+IntToString(spell.DC)+" focus="+IntToString(SV257_Focus(spell.Caster))+" classBonus="+IntToString(SV257_Bonus(spell.Caster,cls,spell.Level))
            +" save="+(spell.SavingThrow==SAVING_THROW_WILL?"Will":"Reflex")+" duration=60 actualRemaining="
            +FloatToString(NWNX_Object_GetAoEObjectDurationRemaining(ao),0,2)+" radius="+FloatToString(radius,0,2)+" actualRadius="+FloatToString(NWNX_Object_GetAoEObjectRadius(ao),0,2)+" shock=6s acid=6d6 electricOnFail=6d6"
            +" ignoreChance="+IntToString(SV257_Chance(spell.Caster))+" medium="+IntToString(medium)
            +" centerDistance="+FloatToString(GetDistanceBetweenLocations(GetLocation(spell.Caster),spell.Loc),0,2)
            +" visualType="+IntToString(areaType);
        WriteTimestampedLogEntry(s);SendMessageToPC(spell.Caster,s);
    }
}

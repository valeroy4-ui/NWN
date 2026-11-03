//::///////////////////////////////////////////////
//:: Vine Mine, Entangle
//:: X2_S0_VineMEnt
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Persistent5m healing field: CL+0/10/30/60 HP per round.
  Existing faction filter and ground-area restrictions are retained.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- extend metamagic didn't worked
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_generic"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spell.Class=GetLastSpellCastClass();
    spellsDeclareMajorVariables();

    float fRadius = GetAreaOfEffectRadius(201 /*VFX_PER_FOGHOLY*/);
    // no stacking
    if(CheckNearAoes(spell.Caster, spell.Loc, fRadius))
        return;
    // no cast near triggers
    if(GetNearTriggers(spell.Caster, spell.Loc))
        return;

    effect eAOE = EffectAreaOfEffect(201 /*VFX_PER_FOGHOLY*/);

    //--------------------------------------------------------------------------
    // 1 turn per caster is not fun, so we do 1 round per casterlevel
    //--------------------------------------------------------------------------
    int nDuration = spell.Level;
    //Check Extend metamagic feat.
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;    //Duration is +100%
    }

    int nDurationOverride = GetModuleSwitchValue("MODULE_SWITCH_CORMYR_MAX_LEVEL_AOE_DURATION_SEC");
    float duration;
    if(spell.Id==529)
    {
        duration=DurationToSeconds(nDuration);
        // This module switch is in SECONDS, not rounds. Keep the level40 ground cap.
        if(spell.Level==CORMYREAN_CHARACTER_MAX_LVL && nDurationOverride>0
            && duration>IntToFloat(nDurationOverride))
            duration=IntToFloat(nDurationOverride);
    }
    else
    {
        // Preserve the legacy behavior of other IDs sharing this impact script.
        if(spell.Level==CORMYREAN_CHARACTER_MAX_LVL && nDurationOverride)
            nDuration=nDurationOverride;
        duration=DurationToSeconds(nDuration);
    }

    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, duration);
    object field=spellsSetupNewAOE(201 /*VFX_PER_FOGHOLY*/, "x2_s0_vinementc");
    if(spell.Id==529 && GetIsObjectValid(field))
    {
        int focus=0,bonus=0;
        if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=3;bonus=60;}
        else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=2;bonus=30;}
        else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=1;bonus=10;}
        SetLocalInt(field,"VM286_HEAL",spell.Level+bonus);
        SetLocalInt(field,"VM286_FOCUS",focus);
        SetLocalFloat(field,"VM286_DURATION",duration);
        SetLocalInt(field,"VM286_READY",TRUE);
        if(GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0)
        {
            string report="[VM286] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)
                +" focus="+IntToString(focus)+" heal="+IntToString(spell.Level+bonus)
                +" interval=6.00 duration="+FloatToString(duration,0,2)+" meta="+IntToString(spell.Meta)
                +" radius="+FloatToString(fRadius,0,2)+" groundCap="+IntToString(nDurationOverride);
            PrintString(report);SendMessageToPC(spell.Caster,report);
        }
    }
    AddMarkersForAOE(spell.Caster, spell.Loc, duration, fRadius);
}

//::///////////////////////////////////////////////
//:: Shield of Faith
//:: x0_s0_ShieldFait.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
 +2 deflection AC bonus, +1 every 6 levels (max +5)
 Duration: 1 turn/level
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: September 6, 2002
//:://////////////////////////////////////////////


#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_runes"
#include "_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;
    //spell.Limit = 5;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    effect eVis = EffectVisualEffect(VFX_IMP_AC_BONUS);
    int nCasterLevel = spell.Level;
    /*
    if (!GetIsPC(spell.Caster)&& GetLocalInt(spell.Caster, "CastForMoney"))
    {
        OnMobSpellCast(spell.Target, spell.Caster, spell.Id);
        nCasterLevel = 20;
    }*/

    int nValue = 2 + (nCasterLevel)/5;
    nValue = nValue > 5 ? 5 : nValue;

    if(!GetIsObjectValid(spell.Item))
    {
        if(GetHasFeat(FEAT_PROTECTION_DOMAIN_POWER, spell.Caster) && spell.Class == CLASS_TYPE_CLERIC)
        {
            if(nCasterLevel > 29)      nValue = 7;
            else if(nCasterLevel > 19) nValue = 6;
        }
    }

    effect eAC = EffectACIncrease(nValue, AC_DEFLECTION_BONUS);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAC, eDur);

    int nDuration = nCasterLevel;                   // * Duration 1 turn/level
    if (spell.Meta & METAMAGIC_EXTEND) nDuration *= 2;   //Duration is +100%

    int bMassEffect = GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_MASS_CAST, RUNE_SPELL_MASS_CAST_SHIELD_OF_FAITH) && !GetIsObjectValid(spell.Item);

    if(bMassEffect)
    {
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        while(GetIsObjectValid(oTarget))
        {
            if(GetFactionEqual(oTarget, spell.Caster))
            {
                if(GetHitDice(oTarget) < 40)
                {
                    float fDelay = GetRandomDelay();
                    // recast
                    DelayCommand(fDelay*0.5, OnAreaSpellCast(spell.Caster, oTarget, spell.Id));
                    //Fire cast spell at event for the specified target
                    SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                    //Fire spell cast at event for target
                    //Apply VFX impact and bonus effects
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(nDuration)));
                }

            }
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        }
    }
    else
    {
        if(GetHitDice(spell.Target) < 40)
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
            //Apply VFX impact and bonus effects
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
        }
        else
        {
            SendColorMessageToPC(OBJECT_SELF, "Spell may only be used on characters below level 40.", TXT_COLOR_RED);
            return;
        }
    }
}


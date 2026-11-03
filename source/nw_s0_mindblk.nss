//::///////////////////////////////////////////////
//:: Mind Blank
//:: NW_S0_MindBlk.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All allies are granted immunity to mental effects
    in the AOE.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;
    spell.Range = RADIUS_SIZE_HUGE;
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    effect eImm1 = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
    effect eVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_POSITIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eImm1, eVis);
    eLink = EffectLinkEffects(eLink, eDur);
    effect eSearch;
    int bValid;
    int nDuration = spell.Level;
    float fDelay;
    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay();
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

            // DC Fix
            DelayCommand(fDelay*0.5, OnAreaSpellCast(spell.Caster, oTarget, spell.Id));
            //

            eSearch = GetFirstEffect(oTarget);
            //Search through effects
            while(GetIsEffectValid(eSearch))
            {
                bValid = FALSE;
                //Check to see if the effect matches a particular type defined below
                switch(GetEffectType(eSearch))
                {
                case EFFECT_TYPE_DAZED:
                case EFFECT_TYPE_CHARMED:
                case EFFECT_TYPE_SLEEP:
                case EFFECT_TYPE_CONFUSED:
                case EFFECT_TYPE_STUNNED:
                case EFFECT_TYPE_DOMINATED:
                    bValid = TRUE;
                break;
                default:
                    switch(GetEffectSpellId(eSearch))
                    {
                    case SPELL_FEEBLEMIND:
                    case SPELL_BANE:
                        bValid = TRUE;
                    break;
                    }
                break;
                }
                //Apply damage and remove effect if the effect is a match
                if(bValid && !GetIsSupernaturalCurse(eSearch))
                {
                    RemoveEffect(oTarget,eSearch);
                }
                eSearch = GetNextEffect(oTarget);
            }
            //After effects are removed we apply the immunity to mind spells to the target
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(nDuration)));
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}



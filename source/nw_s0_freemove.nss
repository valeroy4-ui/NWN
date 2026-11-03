//::///////////////////////////////////////////////
//:: Freedom of Movement
//:: NW_S0_FreeMove.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target creature gains immunity to the
    Entangle, Slow and Paralysis effects
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 29, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 21, 2001

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "nw_i0_spells"
#include "_inc_runes"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDuration       = spell.Level;
    effect eParal       = EffectImmunity(IMMUNITY_TYPE_PARALYSIS);
    effect eEntangle    = EffectImmunity(IMMUNITY_TYPE_ENTANGLE);
    effect eSlow        = EffectImmunity(IMMUNITY_TYPE_SLOW);
    effect eMove        = EffectImmunity(IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE);
    effect eVis         = EffectVisualEffect(VFX_DUR_FREEDOM_OF_MOVEMENT);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //Link effects
    effect eLink = EffectLinkEffects(eParal, eEntangle);
    eLink = EffectLinkEffects(eLink, eSlow);
    eLink = EffectLinkEffects(eLink, eVis);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eMove);
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_FREEDOM), HideEffectIcon(eLink));

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Search for and remove the above negative effects
    int bValid;
    effect eSearch = GetFirstEffect(spell.Target);
    while(GetIsEffectValid(eSearch))
    {
        bValid = FALSE;
        //Check to see if the effect matches a particular type defined below
        switch(GetEffectType(eSearch))
        {
            case EFFECT_TYPE_PARALYZE:
            case EFFECT_TYPE_ENTANGLE:
            case EFFECT_TYPE_SLOW:
            case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE:
                bValid = TRUE;
            break;
        }
        //Apply damage and remove effect if the effect is a match
        if(bValid && !GetIsSupernaturalCurse(eSearch))
            RemoveEffect(spell.Target, eSearch);

        // remove holy sword move speed decrease
        // and icestorm speed decrease
        int nSpellID = GetEffectSpellId(eSearch);
        if (nSpellID == SPELL_BESTOW_CURSE)
        {
            //SendMessageToPC(spell.Target, IntToString(nSpellID));
            RemoveEffect(spell.Target, eSearch);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAttackIncrease(0), spell.Target); // for assist detection system
        }
        eSearch = GetNextEffect(spell.Target);
    }

    // Meta-Magic Checks
    if(spell.Meta == METAMAGIC_EXTEND)
        nDuration *= 2;

    int bMassEffect = GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_II) && !GetIsObjectValid(spell.Item);
    if(bMassEffect)
    {
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        while(GetIsObjectValid(oTarget))
        {
            if(GetFactionEqual(oTarget, spell.Caster))
            {
                float fDelay = GetRandomDelay(0.4, 1.1);
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                // recast
                DelayCommand(fDelay * 0.5, OnAreaSpellCast(spell.Caster, oTarget, spell.Id));
                // apply main effect
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(nDuration)));
                // apply runic KD immunity
                if(runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_III) && !GetIsObjectValid(spell.Item))
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectImmunity(IMMUNITY_TYPE_KNOCKDOWN), oTarget, 6.0));

            }
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        }
    }
    else
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    }
}



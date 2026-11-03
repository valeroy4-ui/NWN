//::///////////////////////////////////////////////
//:: Clarity
//:: NW_S0_Clarity.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This spell removes Charm, Daze, Confusion, Stunned
    and Sleep.  It also protects the user from these
    effects for 1 turn / level.  Does 1 point of
    damage for each effect removed.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 25, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_runes"

void main()
{
    // 1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eImm1 = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
    effect eDam = EffectDamage(1, DAMAGE_TYPE_NEGATIVE);
    effect eVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_POSITIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eImm1, eVis);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_CLARITY), HideEffectIcon(eLink));

    effect eSearch = GetFirstEffect(spell.Target);
    int nDuration = spell.Level;

    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
        nDuration *= 2; //Duration is +100%

    int bValid;
    int bVisual;
    // Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    // Search through effects
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
        bValid = TRUE;
        break;
        }
        //Apply damage and remove effect if the effect is a match
        if(bValid && !GetIsSupernaturalCurse(eSearch))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
            RemoveEffect(spell.Target, eSearch);
            bVisual = TRUE;
        }
        eSearch = GetNextEffect(spell.Target);
    }

    float fTime = 30.0  + DurationToSeconds(nDuration) * (1.0 + 0.3 * runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_CLARITY_II));
    //ServerShout("fTime = " + FloatToString( fTime, 2, 2) );
    int bMassEffect = GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_CLARITY_III) && !GetIsObjectValid(spell.Item);
    if(bMassEffect)
    {
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        while(GetIsObjectValid(oTarget))
        {
            if(GetFactionEqual(oTarget, spell.Caster))
            {
                float fDelay = GetRandomDelay(0.4, 1.1);
                // Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                // recast
                DelayCommand(fDelay * 0.5, OnAreaSpellCast(spell.Caster, oTarget, spell.Id));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, fTime));

            }
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        }
    }
    else
    {
        // Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fTime);
    }
}


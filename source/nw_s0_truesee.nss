//::///////////////////////////////////////////////
//:: True Seeing
//:: NW_S0_TrueSee.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The creature can seen all invisible, sanctuared,
    or hidden opponents.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: [date]
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_runes"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_SECONDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }
    //Declare major variables
    spellsDeclareMajorVariables();
    spell.Range = RADIUS_SIZE_LARGE;

    effect eVis = EffectVisualEffect(HGVFX_DUR_MAGICAL_SIGHT_RED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    eDur = EffectLinkEffects(eDur, EffectVisualEffect(HGVFX_DUR_STAR_HEAD_PURPLE));
    effect eSight = EffectTrueSeeing();
    effect eLink = EffectLinkEffects(eVis, eSight);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, EffectUltravision());
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_TRUESEEING), HideEffectIcon(eLink));

    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    // TODO remove magic numbers such as 0.3 in code below, replace with float constants
    // len' bylo dobavlyat' konstanty i pisat' ysloviya
    float fRunicCoeff = 1.0 + 0.3 * (runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_TRUE_SEEING_II));   /* +
                                     runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_TRUE_SEEING_III)); */
    float fDuration = 4.5 /* magic number from old cormyr */ * DurationToSeconds(spell.Level) * fRunicCoeff;
    //ServerShout("fDuration = " + FloatToString( fDuration, 2, 2) );

    if (spell.Meta & METAMAGIC_EXTEND)
        fDuration *= 2.0; //Duration is +100%

    // apply mass effect if caster has epic rune III
    int bMassEffect = GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_TRUE_SEEING_III) && !GetIsObjectValid(spell.Item);
    if(bMassEffect)
    {
        object oLoop = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, FALSE);
        while(GetIsObjectValid(oLoop))
        {
            if(GetFactionEqual(oLoop, spell.Caster))
            {
                float fDelay = GetRandomDelay(0.4, 1.1);
                // recast
                DelayCommand(fDelay * 0.5, OnAreaSpellCast(spell.Caster, oLoop, spell.Id));

                //Fire cast spell at event for the specified target
                SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                //Apply VFX impact and effect
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(PRCVFX_FNF_DEATH_WATCH), oLoop));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oLoop, fDuration));

            }
            oLoop = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, FALSE);
        }
    }
    else
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(PRCVFX_FNF_DEATH_WATCH), spell.Target);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
    }
}

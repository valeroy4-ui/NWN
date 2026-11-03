///::///////////////////////////////////////////////
//:: Improved Invisibility
//:: NW_S0_ImprInvis.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Target creature can attack and cast spells while
    invisible
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

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

    if (GetHasEffect(EFFECT_TYPE_DARKNESS, spell.Target)) return;

    int iDuration = spell.Level;
    int iConcealment = spell.Level;
    if(iConcealment < 20)
        iConcealment = 20;

    // domain bonus fix
    if(!GetIsObjectValid(spell.Item))
    {
        if(GetHasFeat(FEAT_TRICKERY_DOMAIN_POWER, spell.Caster) && spell.Class == CLASS_TYPE_CLERIC)
           iConcealment = 50;
    }
    else
        iConcealment = 20;
    // domain bonus fix <--

    effect eImpact = EffectVisualEffect(VFX_IMP_HEAD_MIND);
    effect eInvisibily = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
    effect eVisusal = EffectVisualEffect(VFX_DUR_INVISIBILITY);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eConcealment = EffectLinkEffects(eDuration, EffectConcealment(iConcealment));
    eConcealment = EffectLinkEffects(eVisusal, eConcealment);

    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    if (spell.Meta == METAMAGIC_EXTEND)
        iDuration *= 2;

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eConcealment, spell.Target, DurationToSeconds(iDuration));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eInvisibily, spell.Target, DurationToSeconds(iDuration));
}

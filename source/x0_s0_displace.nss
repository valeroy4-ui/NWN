//::///////////////////////////////////////////////
//:: Displacement
//:: x0_s0_displace
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Target gains a 50% concealment bonus.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 7, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_runes"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eDisplace = EffectConcealment(50);
    effect eVis = EffectVisualEffect(VFX_IMP_AC_BONUS);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    int nRaise = spell.Level / 2;
    int nDuration = spell.Level;

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    effect eLink = EffectLinkEffects(eDisplace, eDur);
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_DISPLACEMENT), HideEffectIcon(eLink));

    int bMassEffect = GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_MASS_CAST, RUNE_SPELL_MASS_CAST_DISPLACEMENT) && !GetIsObjectValid(spell.Item);

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
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(nDuration)));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));

            }
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        }
    }
    else
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    }
}

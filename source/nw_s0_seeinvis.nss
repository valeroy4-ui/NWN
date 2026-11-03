//::///////////////////////////////////////////////
//:: See Invisibility
//:: NW_S0_SeeInvis.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Allows the mage to see creatures that are
    invisible
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_runes"
#include "_inc_spellhook"

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

    effect eVis = EffectVisualEffect(HGVFX_DUR_MAGICAL_SIGHT_GREEN);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eSight = EffectSeeInvisible();
    effect eLink = EffectLinkEffects(eVis, eSight);
    eLink = EffectLinkEffects(eLink, eDur);
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    int nDuration = spell.Level;
    //Enter Metamagic conditions
    if (spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    int bMassEffect = GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_MASS_CAST, RUNE_SPELL_MASS_CAST_SEE_INVISIBLE) && !GetIsObjectValid(spell.Item);

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
                DelayCommand(fDelay*0.5, OnAreaSpellCast(spell.Caster, oTarget, spell.Id));

                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(nDuration)));

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

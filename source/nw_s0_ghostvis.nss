//::///////////////////////////////////////////////
//:: Ghostly Visage
//:: NW_S0_MirrImage.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Caster gains 5/+1 Damage reduction and immunity
    to 1st level spells.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "nw_i0_spells"

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

    // remove Ethereal Visage
    RemoveEffectsFromSpell(spell.Caster, SPELL_ETHEREAL_VISAGE);

    effect eVis = EffectVisualEffect(VFX_DUR_GHOSTLY_VISAGE);
    effect eDam = EffectDamageReduction(5, DAMAGE_POWER_PLUS_ONE);
    effect eSpell = EffectSpellLevelAbsorption(1);
    effect eConceal = EffectConcealment(10);
    effect eSpellImm = EffectSpellImmunity(SPELL_ISAACS_LESSER_MISSILE_STORM);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eDam, eVis);
    eLink = EffectLinkEffects(eLink, eSpell);
    eLink = EffectLinkEffects(eLink, eConceal);
    eLink = EffectLinkEffects(eLink, eSpellImm);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_GHOSTLY_VISAGE), HideEffectIcon(eLink));

    int nDuration = spell.Level;
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

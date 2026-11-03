//::///////////////////////////////////////////////
//:: Haste
//:: NW_S0_Haste.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the targeted creature one extra partial
    action per round.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 29, 2001
//:://////////////////////////////////////////////
// Modified March 2003: Remove Expeditious Retreat effects
/*
Patch 1.71

- haste from other sources won't be removed anymore
*/

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

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

    if (GetHasSpellEffect(SPELL_EXPEDITIOUS_RETREAT, spell.Target) == TRUE)
    {
        RemoveSpellEffects(SPELL_EXPEDITIOUS_RETREAT, spell.Caster, spell.Target);
    }

    if (GetHasSpellEffect(SPELLABILITY_EPIC_SHAPE_DRAGON, spell.Target) == TRUE)
    {
        RemoveSpellEffects(SPELLABILITY_EPIC_SHAPE_DRAGON, spell.Caster, spell.Target);
    }

    if (GetHasSpellEffect(SPELL_MASS_HASTE, spell.Target) == TRUE)
    {
        RemoveSpellEffects(SPELL_MASS_HASTE, spell.Caster, spell.Target);
    }

    effect eHaste = EffectHaste();
    effect eVis = EffectVisualEffect(GAOVFX_IMP_HASTE_GREEN);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eHaste, eDur);

    if(!GetIsObjectValid(spell.Item))
    {
        if(GetHasFeat(FEAT_TRAVEL_DOMAIN_POWER, spell.Caster) && spell.Class == CLASS_TYPE_CLERIC)
        {
            eLink = SupernaturalEffect(eLink);
        }
    }

    int nDuration = spell.Level;
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Check for metamagic extension
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;  //Duration is +100%
    }
    /*
    if (!GetIsPC(OBJECT_SELF) && GetLocalInt(OBJECT_SELF, "CastForMoney") == TRUE)
    {
        nDuration = 10;
    }  */

    // Apply effects to the currently selected target.
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}

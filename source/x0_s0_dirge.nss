//::///////////////////////////////////////////////
//:: Dirge
//:: x0_s0_dirge.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures within the AoE take 4 points of Strength
    and Dexterity ability score damage.
    Lasts 1 round/level
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "70_inc_spells"


void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_MEDIUM;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nStrPenalty = 4;
    int nDexPenalty = 4;

    effect eExplode = EffectVisualEffect(PRCVFX_FNF_LOS_PURPLE_10); //Replace with Negative Pulse
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eBad = EffectLinkEffects(EffectAbilityDecrease(ABILITY_STRENGTH, nStrPenalty), eDur);
    eBad = EffectLinkEffects(EffectAbilityDecrease(ABILITY_DEXTERITY, nDexPenalty), eBad);

    //Apply the explosion at the location captured above.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spell.Loc);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            float fDelay = GetRandomDelay();
            if(!MyResistSpell(spell.Caster, oTarget, fDelay) && !GetHasSpellEffect(spell.Id, oTarget))
            {
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eBad, oTarget));
            }
        }
        //Select the next target within the spell shape.
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}

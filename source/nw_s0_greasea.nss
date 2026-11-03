//::///////////////////////////////////////////////
//:: Grease: On Enter
//:: NW_S0_GreaseA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creatures entering the zone of grease must make
    a reflex save or fall down.  Those that make
    their save have their movement reduced by 1/2.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 1, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- incorporeal creatures could been affected
- flying creatures are immune
- speed decrease was dispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_generic"
#include "_inc_runes"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_SLOW);
    effect eSlow = EffectMovementSpeedDecrease(50);
    effect eLink = EffectLinkEffects(eVis, eSlow);
    eLink = ExtraordinaryEffect(eLink);

    object oTarget = GetEnteringObject();
    if(!GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL)&&
       !spellsIsFlying(oTarget) /* && !GetHasSpellEffect(spell.Id, oTarget) */)
    {
        if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
        {
            //Fire cast spell at event for the target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            //Spell resistance check
            if(!MyResistSpell(aoe.Creator, oTarget))
            {
                // calc AoE Power Rune chance ==>
                int nChance = 10 * (runes_GetHasRune(aoe.Creator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_AOE_POWER_I) +
                                    runes_GetHasRune(aoe.Creator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_AOE_POWER_II) +
                                    runes_GetHasRune(aoe.Creator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_AOE_POWER_III) +
                                    runes_GetHasRune(aoe.Creator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_AOE_POWER_IV) +
                                    runes_GetHasRune(aoe.Creator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_AOE_POWER_V));
                int nRoll = d100();
                if(nChance > 0)
                {
                    string sMessage = "Rune of AoE Power chance: " + IntToString(nChance) + " vs d100 roll: " + IntToString(nRoll);
                    SendColorMessageToPC(aoe.Creator, sMessage, TXT_COLOR_VIOLET_L);
                    SendColorMessageToPC(oTarget, sMessage, TXT_COLOR_VIOLET_L);
                    if(nChance > nRoll)
                        eSlow = IgnoreEffectImmunity(eSlow);
                }
                // calc AoE Power Rune chance <==

                //Apply reduced movement effect and VFX_Impact
                RemoveEffectsFromSpell(oTarget, spell.Id);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
            }
        }
    }
}

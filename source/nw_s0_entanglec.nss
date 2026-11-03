//::///////////////////////////////////////////////
//:: Entangle
//:: NW_S0_EntangleC.NSS
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the AOE the target must make
    a reflex save or be entangled by vegitation
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 30, 2001
//:://////////////////////////////////////////////
//::Updated Aug 14, 2003 Georg: removed some artifacts
/*
Patch 1.71

- incorporeal creatures could been affected
- added delay into applications of effects and VFXs
- AOE effects made undispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_runes"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();

    //--------------------------------------------------------------------------
    // GZ 2003-Oct-15
    // When the caster is no longer there, all functions calling
    // GetAreaOfEffectCreator will fail.
    //--------------------------------------------------------------------------

    if (!GetIsObjectValid(aoe.Creator) || GetIsDead(aoe.Creator))
    {
        ExecuteScript("_plc_aoe_destroy", OBJECT_SELF);
        DestroyObject(OBJECT_SELF, 1.0);
        return;
    }

    effect eHold = EffectEntangle();
    effect eEntangle = EffectVisualEffect(VFX_DUR_ENTANGLE);
    //Link Entangle and Hold effects
    effect eLink = EffectLinkEffects(eHold, eEntangle);
    eLink = ExtraordinaryEffect(eLink);
    float fDelay;
    object oTarget = GetFirstInPersistentObject(aoe.AOE);

    while(GetIsObjectValid(oTarget))
    {
        if(!GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL))
        {
            if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
                //random delay so each creature in AOE will be affected in different moment
                fDelay = GetRandomDelay();
                //Make SR check
                if(!GetHasEffect(EFFECT_TYPE_ENTANGLE, oTarget) && !MyResistSpell(aoe.Creator, oTarget, fDelay))
                {

                    // calc AoE Power Rune chance ==>
                    int nChance = 10 * (runes_GetHasRune(aoe.Creator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_AOE_POWER_I) +
                                        runes_GetHasRune(aoe.Creator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_AOE_POWER_II) +
                                        runes_GetHasRune(aoe.Creator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_AOE_POWER_III) +
                                        runes_GetHasRune(aoe.Creator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_AOE_POWER_IV) +
                                        runes_GetHasRune(aoe.Creator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_AOE_POWER_V));
                    if(nChance > 0)
                    {
                        int nRoll = d100();
                        string sMessage = "Rune of AoE Power chance: " + IntToString(nChance) + " vs d100 roll: " + IntToString(nRoll);
                        SendColorMessageToPC(aoe.Creator, sMessage, TXT_COLOR_VIOLET_L);
                        SendColorMessageToPC(oTarget, sMessage, TXT_COLOR_VIOLET_L);
                        if(nChance > nRoll)
                            eLink = IgnoreEffectImmunity(eLink);
                    }
                    // calc AoE Power Rune chance <==

                    //Make reflex save
                    if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, aoe.Creator, fDelay))
                    {
                        //Apply linked effects
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(2)));
                    }
                }
            }
        }
        //Get next target in the AOE
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}

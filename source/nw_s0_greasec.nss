//::///////////////////////////////////////////////
//:: Grease: Heartbeat
//:: NW_S0_GreaseC.nss
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
Patch 1.71

- incorporeal creatures could been affected
- added missing signal event
- flying creatures are immune
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
        DestroyObject(OBJECT_SELF);
        return;
    }

    effect eFall = EffectKnockdown();
    eFall = ExtraordinaryEffect(eFall);
    float fDelay;
    //Get first target in spell area
    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(!GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL) && !spellsIsFlying(oTarget))
        {
            if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));

                // Make an SR Check
                float fDelay = GetRandomDelay(0.5, 2.0);

                if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
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
                        eFall = IgnoreEffectImmunity(eFall);
                    }
                    // calc AoE Power Rune chance <==

                    if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, aoe.Creator, fDelay))
                    {
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFall, oTarget, 4.0));
                    }
                }
            }
        }
        //Get next target in spell area
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}

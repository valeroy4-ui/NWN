//::///////////////////////////////////////////////
//:: Bestow Curse
//:: NW_S0_BesCurse.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Afflicted creature must save or suffer a -2 penalty
    to all ability scores. This is a supernatural effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Bob McCabe
//:: Created On: March 6, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 20, 2001
/*
Patch 1.70

- wrong signal event fixed
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_dispel"
#include "_inc_itemprop"
#include "_inc_runes"

int GetSlowSaveDC(object oWeapon)
{
    return GetLocalInt(oWeapon, "SLOWDC");
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    if (spell.Item == OBJECT_INVALID)
        spell.Item = GetSpellCastItem();

    if (GetObjectType(spell.Target) != OBJECT_TYPE_CREATURE || !GetIsObjectValid(spell.Item))
        return;

    if(ip_GetHasIpWithTag(spell.Item, "IP_CONST_ADDITIONAL_CORMYR_DEAFCLANG"))
    {
        dispel_DispelTarget(spell.Caster, spell.Target, SPELL_BESTOW_CURSE);
    }

    if(ip_GetHasIpWithTag(spell.Item, "IP_CONST_ADDITIONAL_CORMYR_HOLYAVENGER"))
    {
        if (!MySavingThrow(SAVING_THROW_WILL, spell.Target, GetSlowSaveDC(spell.Item)))
        {
            // determine duration
            int nBonus = (GetBaseItemType(spell.Item) == BASE_ITEM_LONGSWORD) * 7;
            int iPaladinLevel = GetLevelByClass(CLASS_TYPE_PALADIN, spell.Caster);
            float fSlowDuration = IntToFloat(iPaladinLevel / 6) + 2.0 +
                                  (runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_DIVINE_NATURE_II)) * 4.0;
            // determine effect
            effect eSlow = EffectMovementSpeedIncrease(-1 * (iPaladinLevel + nBonus));
            effect eVis = EffectVisualEffect(VFX_IMP_SLOW);
            eSlow = EffectLinkEffects(eSlow, eVis);
            eSlow = EffectLinkEffects(EffectIcon(EFFECT_ICON_SPELL_HOLY_SWORD_SLOW), HideEffectIcon(eSlow));
            eSlow = ExtraordinaryEffect(eSlow);
            // remove effects
            RemoveEffectsFromSpell(spell.Target, SPELL_FREEDOM_OF_MOVEMENT);
            RemoveEffectsFromSpell(spell.Target, spell.Id);
            // apply effect
            DelayCommand(0.1, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, spell.Target, fSlowDuration));
        }
    }
}

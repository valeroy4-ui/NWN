//::///////////////////////////////////////////////
//:: [Scare]
//:: [NW_S0_Scare.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Will save or the target is scared for 1d4 rounds.
//:: NOTE THIS SPELL IS EQUAL TO **CAUSE FEAR** NOT SCARE.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 30, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: Modified March 2003 to give -2 attack and damage penalties


#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_fshop_spell"

// calc paralize DC
int GetDCAss(object oCaster, int nSpellId);

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    // calc duration
    int iAssassinLevel = GetLevelByClass(CLASS_TYPE_ASSASSIN, spell.Caster);
    int nDuration = 1 + iAssassinLevel / 10;
    // determine effects
    effect eParalize = EffectParalyze();
    effect eVis = EffectVisualEffect(VFX_DUR_PARALYZED);
    effect eVis2 = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);
    effect eLink = EffectLinkEffects(eVis, eVis2);
    eLink = EffectLinkEffects(eParalize, eLink);
    eLink = EffectLinkEffects(EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION), eLink);
    // make save and apply effect on fail
    if(!MySavingThrow(SAVING_THROW_WILL, spell.Target, GetDCAss(spell.Caster, spell.Id)))
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    }
}

int GetDCAss(object oCaster, int nSpellId)
{
    return 10 + GetLevelByClass(CLASS_TYPE_ASSASSIN, oCaster) / 2 + GetAbilityModifier(ABILITY_DEXTERITY, oCaster) + GetCustomOnhitFameBonus(oCaster, nSpellId); // TODO fameshop
}


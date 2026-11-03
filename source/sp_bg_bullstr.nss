//::///////////////////////////////////////////////
//:: BG Bull Strength
//:: sp_bg_bullstr
//:://////////////////////////////////////////////
/*
    AB +2 +1*(lvl_BG/8), max 2+3, 3 use/day. If your STR<50 only 2 AB.
    Duration = mod Charisma*turn
*/
//:://////////////////////////////////////////////
//:: Created By: Psionix
//:: Created On: Sep 30, 2015
//:://////////////////////////////////////////////

#include "x2_inc_spellhook"
#include "nw_i0_spells"
#include "nwnx_object"

void main()
{
    /*
      Spellcast Hook Code
      Added 2003-06-23 by GeorgZ
      If you want to make changes to all spells,
      check x2_inc_spellhook.nss to find out more

    */
    if (!X2PreSpellCastCode())
    {
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }
    // End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();

    int nStrModify = 4;

    int iAbilityModifier = GetAbilityModifier(ABILITY_CHARISMA);
    if(iAbilityModifier <= 0)
        return;

    float fDuration = TurnsToSeconds(iAbilityModifier);

    effect eStr = EffectAbilityIncrease(ABILITY_STRENGTH, nStrModify);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    int iBonus = 2; // base attack bonus effect
    // no bonus for dex chars
    //if(GetAbilityScore(spell.Target, ABILITY_STRENGTH) > GetAbilityScore(spell.Target, ABILITY_DEXTERITY))
    //    iBonus += GetLevelByClass(CLASS_TYPE_BLACKGUARD, spell.Target)/8;

    effect eBonusAB = EffectAttackIncrease(iBonus);
    effect eLink = EffectLinkEffects(eStr, eDur);
    eLink = EffectLinkEffects(eBonusAB, eLink);
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_SPELL_BLACKGUARD_STRENGTH), HideEffectIcon(eLink));
    eLink = ExtraordinaryEffect(eLink);

    //Signal the spell cast at event
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELLABILITY_BG_BULLS_STRENGTH, FALSE));

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(HGVFX_FNF_STRIKE_EVIL), spell.Target);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DESTRUCTION_LOW), spell.Target);
    SendColorMessageToPC(spell.Caster, "+" + IntToString(iBonus) + " AB", TXT_COLOR_GREEN_L);
}


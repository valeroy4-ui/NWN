//::///////////////////////////////////////////////
//:: Divine Shield
//:: x0_s2_divshield.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////

#include "x0_i0_spells"
#include "_inc_constants"
#include "_inc_colortext"
#include "nwnx_object"

// returns TRUE if oPC has large melee weapon epic focus
int GetHasLargeSizeMeleeWeaponFocus(object oPC);

// return TRUE if oPC is meet shield AC conditions
// no Ancient or Monk AC, base dex < 20, bard_lvl < 30
int GetIsShieldACTarget(object oPC);

void main()
{
    if (!GetHasFeat(FEAT_TURN_UNDEAD, OBJECT_SELF))
    {
        FloatingTextStrRefOnCreature(40550, OBJECT_SELF);
        return;
    }

    int nLevel  = GetCasterLevel(OBJECT_SELF);
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    int nCharismaBonus = GetAbilityModifier(ABILITY_CHARISMA);
    int iAcType = AC_DODGE_BONUS;
    string sAcType = " Dodge AC.";

    if(GetIsShieldACTarget(OBJECT_SELF))
    {
        sAcType = " Shield AC.";
        iAcType = AC_SHIELD_ENCHANTMENT_BONUS;
    }
    /*
    if(GetPCIPAddress(OBJECT_SELF) == "192.168.128.100")
    {
        nCharismaBonus = nCharismaBonus * 3 / 2;
    } */

    effect eAC = EffectACIncrease(nCharismaBonus, iAcType);
    effect eLink = EffectLinkEffects(eAC, eDur);
    eLink = EffectLinkEffects(EffectVisualEffect(PRCVFX_DUR_ENERGY_ADAPTATION_ALL), eLink);
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_SPELL_DIVINE_SHIELD), HideEffectIcon(eLink));
    eLink = ExtraordinaryEffect(eLink);

     // * Do not allow this to stack
    RemoveEffectsFromSpell(OBJECT_SELF, GetSpellId());
    // remove harper sleep
    RemoveEffectsFromSpell(OBJECT_SELF, SPELL_HARPER_SHIELD);
    //Fire cast spell at event for the specified target
    SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, SPELL_DIVINE_SHIELD, FALSE));

    //Apply Link and VFX effects to the target
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, OBJECT_SELF, RoundsToSeconds(nCharismaBonus*2));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_PDK_HEROIC_SHIELD), OBJECT_SELF);

    SendColorMessageToPC(OBJECT_SELF, "+" + IntToString(nCharismaBonus) + sAcType, TXT_COLOR_GREEN_L);

    DecrementRemainingFeatUses(OBJECT_SELF, FEAT_TURN_UNDEAD);
}


int GetHasLargeSizeMeleeWeaponFocus(object oPC)
{
    if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_GREATSWORD, oPC))          return TRUE;
    else if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_GREATAXE, oPC))       return TRUE;
    else if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SCYTHE, oPC))         return TRUE;
    else if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_DOUBLEAXE, oPC))      return TRUE;
    else if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_HALBERD, oPC))        return TRUE;
    else if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_QUARTERSTAFF, oPC))   return TRUE;
    else if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_TWOBLADEDSWORD, oPC)) return TRUE;
    else if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_TRIDENT, oPC))        return TRUE;
    else if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_DIREMACE, oPC))       return TRUE;
    else if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_SHORTSPEAR, oPC))     return TRUE;
    else if(GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_HEAVYFLAIL, oPC))     return TRUE;

    return FALSE;
}

int GetIsShieldACTarget(object oPC)
{
    if(/*GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oPC) ||  */
      (GetAbilityScore(oPC, ABILITY_DEXTERITY, TRUE) >= 20 && GetLevelByClass(CLASS_TYPE_BARD, oPC) >= 30) ||
       GetHasFeat(FEAT_MONK_AC_BONUS, oPC) ||
       GetHasFeat(EPIC_FEAT_ANCIENT_MAGE_ARMOR, oPC))
    {
        return FALSE;
    }
    else if(GetHasLargeSizeMeleeWeaponFocus(oPC))
    {
        return TRUE;
    }

    return FALSE;
}

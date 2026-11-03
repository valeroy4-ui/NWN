//::///////////////////////////////////////////////
//:: Purple Dragon Knight - Heroic Shield
//:: x3_s2_pdk_shield.nss
//:://////////////////////////////////////////////
//:: Applies a temporary AC bonus to one ally
//:://////////////////////////////////////////////
//:: Created By: Stratovarius
//:://////////////////////////////////////////////

#include "x0_i0_spells"
#include "_inc_colortext"

void main()
{
    object oPDK = OBJECT_SELF;
    object oTarget = GetSpellTargetObject();
    int iMod = GetAbilityModifier(ABILITY_CHARISMA,oPDK);
    int iLvl = GetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT, oPDK);
    int nAmount = 5*iMod*iLvl;
    float fDuration = TurnsToSeconds(iLvl);

    effect eCold = EffectDamageResistance(DAMAGE_TYPE_COLD, 10, nAmount/3);
    effect eFire = EffectDamageResistance(DAMAGE_TYPE_FIRE, 10, nAmount/3);
    effect eAcid = EffectDamageResistance(DAMAGE_TYPE_ACID, 10, nAmount/3);
    effect eSonic = EffectDamageResistance(DAMAGE_TYPE_SONIC, 10, nAmount/3);
    effect eElec = EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, 10, nAmount/3);
    effect eReduc = EffectDamageReduction(20, DAMAGE_POWER_PLUS_NINE, nAmount);

    effect eVis = EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION);
    effect eLink1 = EffectLinkEffects(eCold, eFire);
    eLink1 = EffectLinkEffects(eAcid, eLink1);
    eLink1 = EffectLinkEffects(eSonic, eLink1);
    eLink1 = EffectLinkEffects(eElec, eLink1);
    eLink1 = EffectLinkEffects(eVis, eLink1);

    effect eLink2 = EffectLinkEffects(eVis, eReduc);

    eLink1 = SupernaturalEffect(eLink1);
    eLink2 = SupernaturalEffect(eLink2);

    RemoveEffectsFromSpell(oTarget, GetSpellId());
    SendColorMessageToPC(oPDK, "PDK Shield provides " + IntToString(nAmount/3) + " points 10/- energy buffer and " +
                                IntToString(nAmount) + " points 20/+9 reduction", TXT_COLOR_GREEN_L);
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oTarget, fDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink2, oTarget, fDuration);
}


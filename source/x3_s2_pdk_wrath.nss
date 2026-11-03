//::///////////////////////////////////////////////
//:: Purple Dragon Knight - Oath of Wrath
//:: x3_s2_pdk_wrath.nss
//:://////////////////////////////////////////////
//:: Applies a temporary Attack, Save, Damage, Skill bonus vs
//:: monsters of the targets racial type
//:://////////////////////////////////////////////
//:: Created By: Stratovarius
//:: Created On: Sept 22, 2005
//:://////////////////////////////////////////////

#include "x0_i0_spells"
#include "x2_inc_itemprop"

void main()
{
    object oPDK = OBJECT_SELF;
    object oTarget = GetSpellTargetObject();
    int iMod = GetAbilityModifier(ABILITY_CHARISMA,oPDK);
    int iLvl = GetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT,oPDK);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    int nDamage1 = IPGetDamageBonusConstantFromNumber(iMod);
    effect eDamage1 = EffectDamageIncrease(nDamage1,DAMAGE_TYPE_MAGICAL);
    effect eLink = EffectLinkEffects(eDamage1, eDur);
    eLink = SupernaturalEffect(eLink);

    RemoveEffectsFromSpell(oTarget, GetSpellId());
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(iMod*3));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
}


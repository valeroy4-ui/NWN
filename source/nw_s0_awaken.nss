//::///////////////////////////////////////////////
//:: Awaken
//:: NW_S0_Awaken
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This spell makes an animal ally more
    powerful, intelligent and robust for the
    duration of the spell.  Requires the caster to
    make a Will save to succeed.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 10, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- maximized version fixed
- the spell stacked before
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x0_i0_spells"

void ElementalDamageResistance(object oTarget, int iDamage, int nDuration, int iElementalDamageType = DAMAGE_TYPE_FIRE, int iAllElementalDamage=FALSE)
{
    effect eElementalDamage = EffectDamageResistance(iElementalDamageType, iDamage);
    if (iAllElementalDamage)
    {
        eElementalDamage = EffectDamageResistance(DAMAGE_TYPE_ACID, iDamage);
        eElementalDamage = EffectLinkEffects(EffectDamageResistance(DAMAGE_TYPE_COLD, iDamage), eElementalDamage);
        eElementalDamage = EffectLinkEffects(EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, iDamage), eElementalDamage);
        eElementalDamage = EffectLinkEffects(EffectDamageResistance(DAMAGE_TYPE_FIRE, iDamage), eElementalDamage);
        eElementalDamage = EffectLinkEffects(EffectDamageResistance(DAMAGE_TYPE_SONIC, iDamage), eElementalDamage);
        eElementalDamage = EffectLinkEffects(EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, iDamage), eElementalDamage);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eElementalDamage, oTarget, RoundsToSeconds(nDuration));
     }
     else
     {
        eElementalDamage = EffectDamageResistance(iElementalDamageType, iDamage);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eElementalDamage, oTarget, RoundsToSeconds(nDuration));
     }
}

//Applies Effects to companion
//oTarget - Object to apply effects
//nDuration - Effects duration
//iStrength, iConstitution, iNaturalAC, iAttack, iSaves, iDamageReduction
//iDamagePower, iDexterity=0, iRegeneration=0, iHaste=FALSE, iDeath=FALSE
void ApplyCompanionBonuses(object oTarget, int nDuration, int iStrength, int iConstitution, int iNaturalAC, int iDodgeAC, int iDeflectionAC, int iAttack, int iSaves, int iDamageReduction, int iDamagePower, int iDiscipline, int iDexterity=FALSE, int iRegeneration=FALSE, int iHaste=FALSE, int iDeath=FALSE, int iMindBlank=FALSE, int iMoveIncrease=FALSE)
{
    effect eEff = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    eEff = EffectLinkEffects(EffectAbilityIncrease(ABILITY_STRENGTH, iStrength), eEff);
    eEff = EffectLinkEffects(EffectAbilityIncrease(ABILITY_CONSTITUTION, iConstitution), eEff);
    eEff = EffectLinkEffects(EffectACIncrease(iNaturalAC, AC_NATURAL_BONUS), eEff);
    eEff = EffectLinkEffects(EffectACIncrease(iDodgeAC, AC_DODGE_BONUS), eEff);
    eEff = EffectLinkEffects(EffectACIncrease(iDeflectionAC, AC_DEFLECTION_BONUS), eEff);
    eEff = EffectLinkEffects(EffectAttackIncrease(iAttack), eEff);
    eEff = EffectLinkEffects(EffectSavingThrowIncrease(SAVING_THROW_ALL, iSaves), eEff);
    eEff = EffectLinkEffects(EffectDamageReduction(iDamageReduction, iDamagePower), eEff);
    eEff = EffectLinkEffects(EffectSkillIncrease(SKILL_DISCIPLINE, iDiscipline), eEff);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEff, oTarget, RoundsToSeconds(nDuration));
    if (iDexterity)
    {
        eEff = EffectAbilityIncrease(ABILITY_DEXTERITY, iDexterity);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEff, oTarget, RoundsToSeconds(nDuration));
    }
    if (iRegeneration)
    {
        eEff = EffectRegenerate(iRegeneration, 6.0);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEff, oTarget, RoundsToSeconds(nDuration));
    }
    if (iHaste)
    {
        eEff = EffectHaste();
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEff, oTarget, RoundsToSeconds(nDuration));
    }
    if (iDeath)
    {
        eEff = EffectImmunity(IMMUNITY_TYPE_DEATH);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEff, oTarget, RoundsToSeconds(nDuration));
    }
    if (iMindBlank)
    {
        effect eImpact = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget);
        spellApplyMindBlank(oTarget, GetSpellId(), GetRandomDelay());
    }
    if (iMoveIncrease)
    {
        eEff = EffectMovementSpeedIncrease(50);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEff, oTarget, RoundsToSeconds(nDuration));
    }
}

void main()
{

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int iCasterLevel = spell.Level;

    if (!GetIsObjectValid(spell.Item)) iCasterLevel = GetLevelByClass(CLASS_TYPE_DRUID,     spell.Caster)   +
                                                      GetLevelByClass(CLASS_TYPE_RANGER,    spell.Caster)   +
                                                      GetLevelByClass(CLASS_TYPE_ARCHMAGE,  spell.Caster);
    int nDuration = 10 * iCasterLevel;
    effect eVis = EffectVisualEffect(VFX_IMP_HOLY_AID);

    if (GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION) == spell.Target)
    {
        RemoveEffectsFromSpell(spell.Target, spell.Id);
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        //Enter Metamagic conditions
        if (spell.Meta & METAMAGIC_EXTEND) nDuration *= 2; //Duration is +100%
        //Apply the VFX impact and effects
        if (iCasterLevel >= 9 && iCasterLevel < 12)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            ApplyCompanionBonuses(spell.Target, nDuration, 8, 4, 6, 6, 6, 1, 4, 10, DAMAGE_POWER_PLUS_TWO, 12);
        }
        else if (iCasterLevel >= 12 && iCasterLevel < 15)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            ApplyCompanionBonuses(spell.Target, nDuration, 8, 4, 7, 7, 7, 4, 4, 10, DAMAGE_POWER_PLUS_THREE, 18);
            ElementalDamageResistance(spell.Target, 5, nDuration, DAMAGE_TYPE_FIRE);
        }
        else if (iCasterLevel >= 15 && iCasterLevel < 18)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            ApplyCompanionBonuses(spell.Target, nDuration, 8, 6, 8, 8, 8, 5, 5, 10, DAMAGE_POWER_PLUS_FOUR, 24, 4, 3);
            ElementalDamageResistance(spell.Target, 5, nDuration, DAMAGE_TYPE_FIRE);
            ElementalDamageResistance(spell.Target, 5, nDuration, DAMAGE_TYPE_ELECTRICAL);
        }
        else if (iCasterLevel >= 18 && iCasterLevel < 20)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            ApplyCompanionBonuses(spell.Target, nDuration, 10, 8, 9, 9, 9, 7, 7, 10, DAMAGE_POWER_PLUS_FIVE, 30, 5, 3, TRUE);
            ElementalDamageResistance(spell.Target, 10, nDuration, DAMAGE_TYPE_FIRE);
        }
        else if (iCasterLevel >= 20 && iCasterLevel < 22)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            ApplyCompanionBonuses(spell.Target, nDuration, 12, 10, 10, 10, 10, 10, 10, 10, DAMAGE_POWER_PLUS_SIX, 36, 6, 7, TRUE, TRUE);
            ElementalDamageResistance(spell.Target, 15, nDuration, DAMAGE_TYPE_FIRE);
        }
        else if (iCasterLevel >= 22 && iCasterLevel < 24)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            ApplyCompanionBonuses(spell.Target, nDuration, 12, 12, 12, 12, 12, 15, 15, 30, DAMAGE_POWER_PLUS_SEVEN, 42, 8, 10, TRUE, TRUE, TRUE, TRUE);
            ElementalDamageResistance(spell.Target, 10, nDuration, DAMAGE_TYPE_FIRE, TRUE);
        }
        else if (iCasterLevel >= 24)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            ApplyCompanionBonuses(spell.Target, nDuration, 12, 12, 14, 14, 14, 20, 20, 30, DAMAGE_POWER_PLUS_EIGHT, 50, 12, 15, TRUE, TRUE, TRUE, TRUE);
            ElementalDamageResistance(spell.Target, 20, nDuration, DAMAGE_TYPE_FIRE, TRUE);
        }
    }
}

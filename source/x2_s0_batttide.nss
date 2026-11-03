//::///////////////////////////////////////////////
//:: Battletide
//:: X2_S0_BattTide
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    You create an aura that steals energy from your
    enemies. Your enemies suffer a -2 circumstance
    penalty on saves, attack rolls, and damage rolls,
    once entering the aura. On casting, you gain a
    +2 circumstance bonus to your saves, attack rolls,
    and damage rolls.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Dec 04, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs 06/06/03

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_generic"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;
    spell.Range = RADIUS_SIZE_MEDIUM;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    effect eVisual = EffectVisualEffect(VFX_FNF_LOS_HOLY_30);
    //effect eAOE = EffectAreaOfEffect(AOE_MOB_CIRCGOOD, "x2_s0_batttidea", "x2_s0_batttidec", "x2_s0_batttideb");
    int nDuration = spell.Level;
    effect eSkillIncrease = EffectSkillIncrease(SKILL_ALL_SKILLS, 2);
    effect eAttackIncrease = EffectAttackIncrease(2);
    int nDamage = 2;

    if(!GetIsObjectValid(spell.Item) && spell.Class == CLASS_TYPE_CLERIC)
    {
        if(GetHasFeat(FEAT_STRENGTH_DOMAIN_POWER, spell.Caster)) nDamage += 3;
        if(GetHasFeat(FEAT_WAR_DOMAIN_POWER,      spell.Caster)) nDamage += 3;
    }

    effect eDamageIncrease = EffectDamageIncrease(GetDamageBonusConstantFromNumber(nDamage), DAMAGE_TYPE_BASE_WEAPON);
    effect eLink = EffectLinkEffects(eSkillIncrease, eAttackIncrease);

    if(nDamage > 0) eLink = EffectLinkEffects(eDamageIncrease, eLink);

    //Make nDuration at least 1 round.
    if (nDuration < 1) nDuration = 1;

    //Make metamagic check for extend
    if (spell.Meta == METAMAGIC_EXTEND) nDuration = nDuration * 2;   //Duration is +100%
    //Create the AOE object at the selected location
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE,  spell.Caster, DurationToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spell.Caster);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Caster, DurationToSeconds(nDuration));

    //spellsSetupNewAOE("VFX_MOB_BATTLETIDE");
}

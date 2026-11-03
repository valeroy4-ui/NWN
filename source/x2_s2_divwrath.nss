//::///////////////////////////////////////////////
//:: Divine Wrath
//:: x2_s2_DivWrath
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////

#include "nw_i0_spells"

void main()
{
    //Declare major variables
    int nDuration = GetAbilityModifier(ABILITY_CHARISMA, OBJECT_SELF) * 3;

    //Check that if nDuration is not above 0, make it 1.
    if(nDuration <= 0)
    {
        FloatingTextStrRefOnCreature(100967, OBJECT_SELF);
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();


    int nRDDLvl = GetLevelByClass(CLASS_TYPE_DRAGONDISCIPLE, spell.Target) ;
    int iChaMod = GetAbilityModifier(ABILITY_CHARISMA);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Target, SPELLABILITY_DC_DIVINE_WRATH, FALSE));

    int nAttackB = 0;
    int nDamageB = DAMAGE_BONUS_3;
    int nSaveB = 3 ;
    int nDmgRedB = 5;
    int nDmgRedP = DAMAGE_POWER_PLUS_ONE;

    // --------------- Epic Progression ---------------------------

    int nLevel = GetLevelByClass(CLASS_TYPE_DIVINECHAMPION, spell.Target);
    int nLevelB = (nLevel / 5) - 1;

    if (nLevelB <= 0)
        nLevelB = 0;
    else
        nSaveB += (nLevelB*2); // +2 to saves every 5 levels past 5

    nAttackB = nLevel / 3; // +1 to ab every 3 lvls
    nAttackB += abs(iChaMod / 5); // +5 to ab every 5 mod Cha

    if( nLevel > 10 && nRDDLvl > 0)
        nAttackB -= 2;
    if (nLevelB >6 )
    {
        nDmgRedP = DAMAGE_POWER_PLUS_FIVE;
        nDmgRedB = 7*5;
        nDamageB = DAMAGE_BONUS_17;
    }
    else if (nLevelB > 5)
    {
        nDmgRedP = DAMAGE_POWER_PLUS_FIVE;
        nDmgRedB = 6 * 5;
        nDamageB = DAMAGE_BONUS_15;
    }
    else if (nLevelB > 4)
    {
        nDmgRedP = DAMAGE_POWER_PLUS_FIVE;
        nDmgRedB = 5 * 5;
        nDamageB = DAMAGE_BONUS_13;
    }
    else if (nLevelB > 3)
    {
        nDmgRedP = DAMAGE_POWER_PLUS_FOUR;
        nDmgRedB = 4*5;
        nDamageB = DAMAGE_BONUS_11;
    }
    else if (nLevelB > 2)
    {
        nDmgRedP = DAMAGE_POWER_PLUS_THREE;
        nDmgRedB = 3 * 5;
        nDamageB = DAMAGE_BONUS_9;
    }
    else if (nLevelB > 1)
    {
        nDmgRedP = DAMAGE_POWER_PLUS_TWO;
        nDmgRedB = 2 * 5;
        nDamageB = DAMAGE_BONUS_7;
    }
    else if (nLevelB > 0)
    {
        nDamageB = DAMAGE_BONUS_5;
    }
    //--------------------------------------------------------------
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    eVis = EffectLinkEffects(EffectVisualEffect(VFX_IMP_GOOD_HELP), eVis);

    effect eAttack = EffectAttackIncrease(nAttackB, ATTACK_BONUS_MISC);
    effect eDamage = EffectDamageIncrease(nDamageB, DAMAGE_TYPE_DIVINE);
    effect eSaving = EffectSavingThrowIncrease(SAVING_THROW_ALL, nSaveB, SAVING_THROW_TYPE_ALL);
    effect eReduction = EffectDamageReduction(nDmgRedB, nDmgRedP);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eDex = EffectAbilityIncrease(ABILITY_DEXTERITY, 4);

    effect eLink = EffectLinkEffects(eAttack, eDamage);
    eLink = EffectLinkEffects(eSaving, eLink);
    eLink = EffectLinkEffects(eReduction, eLink);
    eLink = EffectLinkEffects(eDex, eLink);
    eLink = EffectLinkEffects(eDur, eLink);
    eLink = EffectLinkEffects(EffectVisualEffect(VFX_DUR_PDK_FEAR), eLink);
    eLink = EffectLinkEffects(HideEffectIcon(eLink), EffectIcon(EFFECT_ICON_DIVINE_WRATH));
    eLink = ExtraordinaryEffect(eLink);

    // prevent stacking with self
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    SendColorMessageToPC(spell.Caster, "+" + IntToString(nAttackB) + " AB", TXT_COLOR_GREEN_L);
    //Apply the armor bonuses and the VFX impact
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, RoundsToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}



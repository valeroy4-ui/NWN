//::///////////////////////////////////////////////
//:: Lay_On_Hands
//:: NW_S2_LayOnHand.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The Paladin is able to heal his Chr Bonus times
    his level.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 15, 2001
//:: Updated On: Oct 20, 2003
//:://////////////////////////////////////////////

#include "nw_i0_spells"
#include "_inc_constants"

void main()
{

    object oTarget = GetSpellTargetObject();
    int nChr = GetAbilityModifier(ABILITY_CHARISMA);
    if (nChr < 0)
    {
        nChr = 0;
    }
    int nLevel = GetLevelByClass(CLASS_TYPE_PALADIN);

    //--------------------------------------------------------------------------
    // July 2003: Add Divine Champion levels to lay on hands ability
    //--------------------------------------------------------------------------
    nLevel = nLevel + GetLevelByClass(CLASS_TYPE_DIVINECHAMPION);

    //--------------------------------------------------------------------------
    // Caluclate the amount to heal, min is 1 hp
    //--------------------------------------------------------------------------
    int nHeal = nLevel * nChr;
    if(nHeal <= 0)
    {
        nHeal = 1;
    }
    effect eHeal = EffectHeal(nHeal);
    effect eVis = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eVis2 = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eDam;
    int nTouch;

    //--------------------------------------------------------------------------
    // A paladine can use his lay on hands ability to damage undead creatures
    // having undead class levels qualifies as undead as well
    //--------------------------------------------------------------------------
    if(GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD || GetLevelByClass(CLASS_TYPE_UNDEAD,oTarget)>0)
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_LAY_ON_HANDS));
        //Make a ranged touch attack
        nTouch = TouchAttackMelee(oTarget,TRUE);

        //----------------------------------------------------------------------
        // GZ: The PhB classifies Lay on Hands as spell like ability, so it is
        //     subject to SR. No more cheesy demi lich kills on touch, sorry.
        //----------------------------------------------------------------------
        int nResist = MyResistSpell(OBJECT_SELF,oTarget);
        if (nResist == 0 )
        {
            if(nTouch > 0)
            {
                if(nTouch == 2)
                {
                    nHeal *= 2;
                }
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_LAY_ON_HANDS));
                eDam = EffectDamage(nHeal, DAMAGE_TYPE_DIVINE);
                DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
            }
        }
    }
    else
    {
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_LAY_ON_HANDS, FALSE));

        int iCurrentHitpoints = GetCurrentHitPoints(oTarget);
        if(iCurrentHitpoints < 1) iCurrentHitpoints = 1;

        int iTargetMaxHp = GetMaxHitPoints(oTarget);
        int iTargetCurrentHpPercent = iCurrentHitpoints * 100 / iTargetMaxHp;
        int iTargetIsNearDeath = (iTargetCurrentHpPercent < 35) ? TRUE : FALSE;
        // цель при смерти, и она не кастер
        if(iTargetIsNearDeath && oTarget != OBJECT_SELF)
        {
            // хилим (уровень кастера * 2)%  хп, если хил в процентах меньше обычного ванильного, значит хилим ванильным
            int iSuperHeal = iTargetMaxHp * (nLevel * 2) / 100;
            if(nHeal > iSuperHeal)
                iSuperHeal = nHeal;

            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(iSuperHeal), oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_LOS_HOLY_10), oTarget);
            int iImmunityValue = nLevel;
            float fDuration = GetAbilityModifier(ABILITY_CHARISMA, OBJECT_SELF) * 1.5f;
            //длительность не дольше 12 секунд(2 раунда)
            if(fDuration > 12.0) fDuration = 12.0;

            if(fDuration > 0.0)
            {
                effect eImmune = EffectDamageImmunityIncrease(DAMAGE_TYPE_BLUDGEONING, iImmunityValue);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_PIERCING, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_SLASHING, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_MAGICAL, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_ACID, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_DIVINE, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_ELECTRICAL, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_POSITIVE, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_SONIC, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_BASE_WEAPON, iImmunityValue), eImmune);
                eImmune = EffectLinkEffects(EffectVisualEffect(PRCVFX_DUR_CROWN_OF_GLORY), eImmune);
                eImmune = SupernaturalEffect(eImmune);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eImmune, oTarget, fDuration);
            }
        }
        else
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget);
        }

        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }

}

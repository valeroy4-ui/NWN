//::///////////////////////////////////////////////
//:: Lesser Restoration
//:: NW_S0_LsRestor.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Removes all supernatural effects related to ability
    damage, as well as AC, Damage,
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72
- restoration doesn't remove horse related effects
Patch 1.71
- restoration doesn't remove effects of rage anymore (all rage variants)
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVisual = EffectVisualEffect(VFX_IMP_RESTORATION_LESSER);
    effect eBad = GetFirstEffect(spell.Target);
    //Search for negative effects
    while(GetIsEffectValid(eBad))
    {
        switch(GetEffectType(eBad))
        {
            case EFFECT_TYPE_ABILITY_DECREASE:
            case EFFECT_TYPE_AC_DECREASE:
            case EFFECT_TYPE_ATTACK_DECREASE:
            case EFFECT_TYPE_DAMAGE_DECREASE:
            case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE:
            case EFFECT_TYPE_SAVING_THROW_DECREASE:
            case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE:
            case EFFECT_TYPE_SKILL_DECREASE:
            //Remove effect if it is negative.
            if(!GetIsSupernaturalCurse(eBad))
            {
                RemoveEffect(spell.Target, eBad);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAttackIncrease(0), spell.Target); // for assist detection system
            }
        }
        eBad = GetNextEffect(spell.Target);
    }
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spell.Target);
}



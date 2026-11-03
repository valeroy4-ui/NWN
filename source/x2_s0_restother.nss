//::///////////////////////////////////////////////
//:: Restoration
//:: x2_s0_restother.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Removes all negative effects unless they come
    from Poison, Disease or Curses.
    Can only be cast on Others - not on oneself.
    Caster takes 5 points of damage when this
    spell is cast.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Jan 3/03
//:://////////////////////////////////////////////
/*
Patch 1.72
- spell won't remove horse and rage related effects anymore
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
    effect eVisual = EffectVisualEffect(VFX_IMP_RESTORATION);
    int bValid;
    if (spell.Target != spell.Caster)
    {
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
                case EFFECT_TYPE_BLINDNESS:
                case EFFECT_TYPE_DEAF:
                case EFFECT_TYPE_PARALYZE:
                case EFFECT_TYPE_NEGATIVELEVEL:
                //Remove effect if it is negative.
                if(!GetIsSupernaturalCurse(eBad))
                RemoveEffect(spell.Target, eBad);
                break;
            }
            eBad = GetNextEffect(spell.Target);
        }
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_RESTORATION, FALSE));

        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, spell.Target);

        //Apply Damage Effect to the Caster
        DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(5), spell.Caster));
    }
}

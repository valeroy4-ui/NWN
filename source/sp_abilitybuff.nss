//::///////////////////////////////////////////////
//:: Ability buffs Multi-spell script
//:: sp_abilitybuff
//:://////////////////////////////////////////////
/*
ќбщий скрипт дл¤ спеллов баффающих абилки.
*/
//:://////////////////////////////////////////////
//:: Created By: Psionix
//:: Created On: Sep 30, 2015
//:://////////////////////////////////////////////

#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spellhook"
#include "_inc_runes"

void main()
{
/*
  Spellcast Hook Code
  Added 2003-06-20 by Georg
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    spell.DurationType = SPELL_DURATION_TYPE_TURNS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    // End of Spell Cast Hook
    spellsDeclareMajorVariables();


    int iAbility, iModify = 4;
    int iVisual;
    switch(spell.Id)
    {
        case SPELL_GREATER_BULLS_STRENGTH:
        case SPELL_BULLS_STRENGTH:
        case SPELLABILITY_BG_BULLS_STRENGTH:
            iAbility = ABILITY_STRENGTH;
            if(GetHasFeat(FEAT_STRENGTH_DOMAIN_POWER))
            {
                iModify = 12;
            }
            iVisual = PRCVFX_IMP_BONUS_STRENGTH;
            break;
        case SPELL_GREATER_FOXS_CUNNING:
        case SPELL_FOXS_CUNNING:
            iAbility = ABILITY_INTELLIGENCE;
            iVisual = PRCVFX_IMP_BONUS_INTELLIGENCE;
            break;
        case SPELL_GREATER_OWLS_WISDOM:
        case SPELL_OWLS_WISDOM:
            iAbility = ABILITY_WISDOM;
            iVisual = PRCVFX_IMP_BONUS_WISDOM;
            break;
        case SPELL_GREATER_ENDURANCE:
        case SPELL_ENDURANCE:
            iAbility = ABILITY_CONSTITUTION;
            iVisual = PRCVFX_IMP_BONUS_CONSTITUTION;
            break;
        case SPELL_GREATER_EAGLE_SPLENDOR:
        case SPELL_EAGLE_SPLEDOR:
            iAbility = ABILITY_CHARISMA;
            iVisual = PRCVFX_IMP_BONUS_CHARISMA;
            break;
        case SPELL_GREATER_CATS_GRACE:
        case SPELL_CATS_GRACE:
            iAbility = ABILITY_DEXTERITY;
            iVisual = PRCVFX_IMP_BONUS_DEXTERITY;
            break;
    }
    /*
    if (!GetIsPC(spell.Caster) && GetLocalInt(spell.Caster, "CastForMoney"))
    {
        OnMobSpellCast(spell.Target, spell.Caster, spell.Id);
        spell.Level = 20;
        iModify = GetScalableModifyByLevel(GetHitDice(spell.Target), spell.Id);
    }     */

    effect eVis = EffectVisualEffect(iVisual);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    int iDuration = spell.Level;

    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        iDuration *= 2; //Duration is +100%
    }
    if (spell.Meta & METAMAGIC_MAXIMIZE)
    {
        iModify = 8;
    }
    if (spell.Meta & METAMAGIC_EMPOWER)
    {
        iModify = 6;
    }

    //Set Adjust Ability Score effect
    effect eRaise = EffectAbilityIncrease(iAbility, iModify);
    effect eLink = EffectLinkEffects(eRaise, eDur);

    int bMassEffect = FALSE; // Im Commander Shepard!
    int iRuneId = RUNE_NONE;
    switch(spell.Id)
    {
        case SPELL_GREATER_BULLS_STRENGTH:
        case SPELL_BULLS_STRENGTH:
            iRuneId = RUNE_SPELL_MASS_CAST_BULLS_STRENGTH;
            break;
        case SPELL_GREATER_FOXS_CUNNING:
        case SPELL_FOXS_CUNNING:
            iRuneId = RUNE_SPELL_MASS_CAST_FOXS_CUNNING;
            break;
        case SPELL_GREATER_OWLS_WISDOM:
        case SPELL_OWLS_WISDOM:
            iRuneId = RUNE_SPELL_MASS_CAST_OWLS_WISDOM;
            break;
        case SPELL_GREATER_ENDURANCE:
        case SPELL_ENDURANCE:
            iRuneId = RUNE_SPELL_MASS_CAST_ENDURANCE;
            break;
        case SPELL_GREATER_EAGLE_SPLENDOR:
        case SPELL_EAGLE_SPLEDOR:
            iRuneId = RUNE_SPELL_MASS_CAST_EAGLE_SPLEDOR;
            break;
        case SPELL_GREATER_CATS_GRACE:
        case SPELL_CATS_GRACE:
            iRuneId = RUNE_SPELL_MASS_CAST_CATS_GRACE;
            break;
    }


    // cleric domain
    if(!GetIsObjectValid(GetSpellCastItem()) && spell.Id == SPELL_BULLS_STRENGTH)
    {
        if(GetHasFeat(FEAT_STRENGTH_DOMAIN_POWER) && GetLastSpellCastClass() == CLASS_TYPE_CLERIC)
        {
            iModify = 12;
        }
    }

    bMassEffect = iRuneId && GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_MASS_CAST, iRuneId) && !GetIsObjectValid(spell.Item);

    if(bMassEffect)
    {
        location lLoc = GetLocation(spell.Target);
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, lLoc, FALSE);
        while(GetIsObjectValid(oTarget))
        {
            if(GetFactionEqual(oTarget, spell.Caster))
            {
                if(GetHitDice(oTarget) < 40)
                {
                    float fDelay = GetRandomDelay();
                    //Fire cast spell at event for the specified target
                    SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

                    // recast fix
                    DelayCommand(fDelay*0.5, OnAreaSpellCast(spell.Caster, oTarget, spell.Id));

                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(iDuration)));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }

            }
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, 5.0, lLoc, FALSE);
        }
    }
    else
    {
            if(GetHitDice(spell.Target) < 40)
            {
                //Fire cast spell at event for the specified target
                SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                //Apply the VFX impact and effects
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(iDuration));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            }
            else
            {
                SendColorMessageToPC(OBJECT_SELF, "Spell may only be used on characters below level 40.", TXT_COLOR_RED);
                return;
            }

    }
}




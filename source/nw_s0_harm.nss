//::///////////////////////////////////////////////
//:: [Harm]
//:: [NW_S0_Harm.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Reduces target to 1d4 HP on successful touch
//:: attack.  If the target is undead it is healed.
//:://////////////////////////////////////////////
//:: Created By: Keith Soleski
//:: Created On: Jan 18, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: Aug 1, 2001
/* edited by evenflw
- capped at 150, or 225 if has destruction domain
*/

#include "X0_I0_SPELLS"
#include "x2_inc_spellhook"
#include "_inc_colortext"
#include "_inc_spells"


int GetBonusDamageDestructionDomain(int iCasterLevel)
{
    return iCasterLevel - 30 > 0 ? (iCasterLevel - 30) * 10 : 0;
}

int GetDruidBonusDamage(int iCasterLevel)
{
    return iCasterLevel - 30 > 0 ? (iCasterLevel - 30) * 6 : 0;
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageType = DAMAGE_TYPE_NEGATIVE;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    // Declare major variables
    spellsDeclareMajorVariables();

    if(GetObjectType(spell.Target) != OBJECT_TYPE_CREATURE)
        return;

    if(GetIsPC(spell.Target) && GetIsPC(spell.Caster) && spells_GetHasSpellCooldown(spell.Id, spell.Target, CORMYR_SPELL_COOLDOWN_TARGET))
    {
        DelayCommand(1.0, FloatingColorTextStringOnCreature("The target is temporarily immune to damage from Harm", TXT_COLOR_RED, spell.Caster));
        DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GLOBE_USE), spell.Target));
        return;
    }

    int nDamage, nHeal;
    int nTouch = TouchAttackMelee(spell.Target);
    int bHasDestructionDomain = GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER);
    effect eVis = EffectVisualEffect(VFX_IMP_HARM);
    effect eVis2 = EffectVisualEffect(VFX_IMP_HEALING_G);
    effect eHeal, eDam;
    // Check that the target is undead
    if (GetRacialType(spell.Target) == RACIAL_TYPE_UNDEAD)
    {
        nHeal = spell.Level * 5 + 70;
        if(bHasDestructionDomain)
            nHeal += GetBonusDamageDestructionDomain(spell.Level + GetLevelByClass(CLASS_TYPE_ARCHMAGE, spell.Caster));

        if(bHasDestructionDomain && d100() <= 2)
        {
            FloatingColorTextStringOnCreature("Double Heal!", TXT_COLOR_RED, spell.Caster, FALSE);
            nHeal *= 2;
        }
        // Set the heal effect
        eHeal = EffectHeal(nHeal);
        // Apply heal effect and VFX impact
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spell.Target);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);
        // Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    }
    else if (nTouch) //== TRUE) 1 or 2 are valid return numbers from TouchAttackMelee
    {
        if(!GetIsReactionTypeFriendly(spell.Target))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            if(!MyResistSpell(spell.Caster, spell.Target) && !GetHasSpellEffect(SPELL_NEGATIVE_ENERGY_PROTECTION, spell.Target))
            {
                nDamage = spell.Level * 5 + 70;    // base damage

                if(bHasDestructionDomain) // apply destruction domain bonuses
                {
                    nDamage += GetBonusDamageDestructionDomain(spell.Level);
                    int iCritChance = ((spell.Level - 30) > 0) ? 5 * (spell.Level - 30) : 0;
                    if (Random(1000) + 1 <= iCritChance)
                    {
                        FloatingColorTextStringOnCreature("Critical Hit!", TXT_COLOR_RED, spell.Caster, FALSE);
                        nDamage = (nDamage*3)/2;
                    }
                }
                else if (GetLevelByClass(CLASS_TYPE_DRUID, spell.Caster))  // druid bonuses
                {
                    nDamage += GetDruidBonusDamage(spell.Level);
                    int iCritChance = ((spell.Level - 30) > 0) ? 5 * (spell.Level - 30) : 0;
                    if (Random(1000) + 1 <= iCritChance)
                    {
                        FloatingColorTextStringOnCreature("Critical Hit!", TXT_COLOR_RED, spell.Caster, FALSE);
                        nDamage *= 2;
                    }
                }
                eDam = EffectDamage(nDamage, DAMAGE_TYPE_NEGATIVE);
                //Apply the VFX impact and effects
                DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                //  set personal cooldown
                if(GetIsPC(spell.Target) && GetIsPC(spell.Caster))
                    spells_SetSpellCooldown(spell.Id, spell.Target, 5.5, CORMYR_SPELL_COOLDOWN_DONT_SHOW_MESSAGES, CORMYR_SPELL_COOLDOWN_TARGET);
            }
            else if(GetHasSpellEffect(SPELL_NEGATIVE_ENERGY_PROTECTION, spell.Target))
            {
                DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GLOBE_USE), spell.Target));
            }
        }
    }
}

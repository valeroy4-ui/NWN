//::///////////////////////////////////////////////
//:: Finger of Death
//:: NW_S0_FingDeath
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// You can slay any one living creature within range.
// The victim is entitled to a Fortitude saving throw to
// survive the attack. If he succeeds, he instead
// sustains 3d6 points of damage +1 point per caster
// level.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 17, 2000
//:://////////////////////////////////////////////
//:: Updated By: Georg Z, On: Aug 21, 2003 - no longer affects placeables
/*
Patch 1.71

- target selection scheme changed from selective to singe-target to allow target neutral creatures
- corrected immunity check (now handled in engine)
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_NEGATIVE;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDamage;
    effect eDam;
    effect eDamage = EffectDamage(FloatToInt(IntToFloat(GetMaxHitPoints(spell.Target)) * 0.7)); // 70% of max HP
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH_L);
    effect eVis2 = EffectVisualEffect(spell.DmgVfxL);
    float fDelay = GetRandomDelay();

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //GZ: I still signal this event for scripting purposes, even if a placeable
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        if(GetObjectType(spell.Target) == OBJECT_TYPE_CREATURE)
        {

            //Make SR check
            if(!MyResistSpell(spell.Caster, spell.Target))
            {
                // Roll damage
                nDamage = d6(spell.Level / 4) + spell.Level;
                // Make metamagic checks
                if (spell.Meta == METAMAGIC_MAXIMIZE) nDamage  = 6 * (spell.Level / 4) + spell.Level;
                if (spell.Meta == METAMAGIC_EMPOWER)  nDamage += nDamage / 2;

                //Make Fortitude save
                switch(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_DEATH, spell.Caster))
                {
                    case 0: //failed in save
                        //Apply the death effect and VFX impact
                        if (players_GetRealSavingThrowValue(spell.Target, SAVING_THROW_FORT) >= spell.DC && !GetIsImmune(spell.Target, IMMUNITY_TYPE_DEATH, spell.Caster))
                            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spell.Target));
                        else
                            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), spell.Target));
                    break;
                    case 1: //succeded in save
                        // do normal damage
                    break;
                    case 2: //immune to the death - double damage
                        nDamage*=2;
                    break;
                }
                if (nDamage > 0)
                {
                    eDam = EffectDamage(nDamage, DAMAGE_TYPE_NEGATIVE);
                    //Apply damage effect and VFX impact
                    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target));
                }
            }
        }
    }
}



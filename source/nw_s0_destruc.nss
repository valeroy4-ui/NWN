//::///////////////////////////////////////////////
//:: Destruction
//:: NW_S0_Destruc
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target creature is destroyed if it fails a
    Fort save, otherwise it takes 10d6 damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 13, 2001
//:://////////////////////////////////////////////

#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageType    = DAMAGE_TYPE_DIVINE;
    spell.SavingThrow   = SAVING_THROW_FORT;
    spell.TargetType    = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDamage;
    effect eDeath = EffectDeath();
    effect eDamage = EffectDamage(FloatToInt(IntToFloat(GetMaxHitPoints(spell.Target)) * 0.7)); // 70% of max HP
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_DESTRUCTION);
    float fDelay = GetRandomDelay();

    if(GetObjectType(spell.Target) == OBJECT_TYPE_CREATURE && spellsIsTarget(spell.Target, SPELL_TARGET_STANDARDHOSTILE, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make SR check
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            //Make a saving throw check
            if(!/*Fort Save*/ MySavingThrow(spell.SavingThrow, spell.Target, spell.DC))
            {
                //Apply the VFX impact and effects
                if (players_GetRealSavingThrowValue(spell.Target, SAVING_THROW_FORT) >= spell.DC && !GetIsImmune(spell.Target, IMMUNITY_TYPE_DEATH, spell.Caster))
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spell.Target));
                else
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spell.Target));
            }

            nDamage = d6(10);
            //Enter Metamagic conditions
            if (spell.Meta == METAMAGIC_MAXIMIZE)
                nDamage = 60;// Damage is at max
            else if (spell.Meta == METAMAGIC_EMPOWER)
                nDamage = nDamage + (nDamage/2); // Damage/Healing is +50%

            //Set damage effect
            eDam = EffectDamage(nDamage, spell.DamageType);
            // Crypton -->
            if(GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER))
            {
                effect eDam2 = EffectDamage(40, DAMAGE_TYPE_POSITIVE);
                DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam2, spell.Target));
            }
            DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
            DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target));
        }
    }
}


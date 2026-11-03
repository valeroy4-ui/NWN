//::///////////////////////////////////////////////
//:: Melf's Acid Arrow
//:: MelfsAcidArrow.nss
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
School: Conjuration
Duration: Caster_Level / 10 rounds
Description: «аклинатель поражает существо зар¤дом кислоты, урон равен (3 + Caster_Level/3)d6 Acid урона. (X - уровень заклинател¤. ћаксимум 8d6).
*/
/////////////////////////////////////////////////////////
//:://////////////////////////////////////////////


#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x2_i0_spells"

void RunImpact(int nDamage);

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_ACID;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    //--------------------------------------------------------------------------
    // Calculate the duration
    //--------------------------------------------------------------------------
    int nDuration = spell.Level/10;
    int nDamage = ((3 + spell.Level/3) > 8) ? 8: (3 + spell.Level/3);

    if (nDuration < 1)
    {
        nDuration = 1;
    }

    if (spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration * 2;
    }

    //--------------------------------------------------------------------------
    // Setup VFX
    //--------------------------------------------------------------------------
    effect eVis      = EffectVisualEffect(spell.DmgVfxL);
    effect eDur      = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eArrow    = EffectVisualEffect(VFX_DUR_MIRV_ACID);
    int bInEffect    = GetHasSpellEffect(spell.Id, spell.Target);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eArrow, spell.Target);
    //--------------------------------------------------------------------------
    // Set the VFX to be non dispelable, because the acid is not magic
    //--------------------------------------------------------------------------
    eDur = ExtraordinaryEffect(eDur);
     // * Dec 2003- added the reaction check back i
    if (spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

        float fDist = GetDistanceToObject(spell.Target);
        float fDelay = fDist/25.0;//(3.0 * log(fDist) + 2.0);


        if(!MyResistSpell(spell.Caster, spell.Target, fDelay))
        {
            //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
            if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
            {
                //----------------------------------------------------------------------
                // Do the initial 3d6 points of damage
                //----------------------------------------------------------------------
                int iDamage = MaximizeOrEmpower(spell.Dice, nDamage, spell.Meta);
                effect eDam = EffectDamage(iDamage, spell.DamageType);

                DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target));
                DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                //--------------------------------------------------------------------------
                // This spell no longer stacks. If there is one of that type, thats ok
                //--------------------------------------------------------------------------
                if (bInEffect)
                {
                    FloatingTextStrRefOnCreature(100775,spell.Caster,FALSE);
                    return;
                }
                //----------------------------------------------------------------------
                // Apply the VFX that is used to track the spells duration
                //----------------------------------------------------------------------
                DelayCommand(fDelay + 0.1, ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eDur,spell.Target,DurationToSeconds(nDuration)));
                DelayCommand(6.0, RunImpact(nDamage));
            }
        }
    }
}


void RunImpact(int iDamage)
{
    //--------------------------------------------------------------------------
    // Check if the spell has expired (check also removes effects)
    //--------------------------------------------------------------------------
    if (GZGetDelayedSpellEffectsExpired(spell.Id,spell.Target,spell.Caster))
    {
        return;
    }

    if (!GetIsDead(spell.Target))
    {
        //----------------------------------------------------------------------
        // Calculate Damage
        //----------------------------------------------------------------------
        int nDamage = MaximizeOrEmpower(spell.Dice, iDamage, spell.Meta);
        effect eDam = EffectDamage(nDamage, spell.DamageType);
        effect eVis = EffectVisualEffect(spell.DmgVfxS);
        eDam = EffectLinkEffects(eVis,eDam); // flare up
        ApplyEffectToObject (DURATION_TYPE_INSTANT,eDam,spell.Target);
        DelayCommand(6.0,RunImpact(iDamage));
    }
}




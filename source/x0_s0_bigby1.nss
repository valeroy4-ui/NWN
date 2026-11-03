//::///////////////////////////////////////////////
//:: Bigby's Interposing Hand
//:: [x0_s0_bigby1]
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grants -10 to hit to target for 1 round / level
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 7, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
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
    // int nDuration = spell.Level;
    int nDuration = 2;
    int bTimeOut = FALSE;


    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster) && !spells_GetHasTimeStopEffect(spell.Caster, spell.Target))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, TRUE));
        //Check for metamagic extend
        if (spell.Meta & METAMAGIC_EXTEND) //Duration is +100%
        {
             nDuration = nDuration * 2;
        }
        if (!MyResistSpell(spell.Caster, spell.Target))
        {
            //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
            if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster))
            {
                effect eAC1 = EffectAttackDecrease(15);
                effect eVis = EffectVisualEffect(VFX_DUR_BIGBYS_INTERPOSING_HAND);
                effect eLink = EffectLinkEffects(eAC1, eVis);

                if(GetIsPC(spell.Caster))
                    bTimeOut = TRUE;

                //Apply the TO HIT PENALTIES bonuses and the VFX impact
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
            }
        }
    }
    if(bTimeOut)
        spells_SetSpellCooldown(spell.Id, spell.Caster, GetSpellTimeoutDuration(spell.Id));

}

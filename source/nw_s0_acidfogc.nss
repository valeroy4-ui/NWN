//::///////////////////////////////////////////////
//:: Acid Fog: Heartbeat
//:: NW_S0_AcidFogC.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures within the AoE take 2d6 acid damage
    per round and upon entering if they fail a Fort Save
    their movement is halved.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- damage is now different target by target
- needless saving throw removed
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice          = 6;
    spell.DamageType    = DAMAGE_TYPE_ACID;
    spell.TargetType    = SPELL_TARGET_STANDARDHOSTILE;
    spell.SavingThrow   = SAVING_THROW_REFLEX;

    //Declare major variables
    aoesDeclareMajorVariables();

    int nDamage;
    effect eDam;
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    float fDelay;

    //--------------------------------------------------------------------------
    // GZ 2003-Oct-15
    // When the caster is no longer there, all functions calling
    // GetAreaOfEffectCreator will fail. Its better to remove the barrier then
    //--------------------------------------------------------------------------
    if (!GetIsObjectValid(aoe.Creator) || GetIsDead(aoe.Creator))
    {
        ExecuteScript("_plc_aoe_destroy", OBJECT_SELF);
        DestroyObject(OBJECT_SELF);
        return;
    }

    //Start cycling through the AOE Object for viable targets including doors and placable objects.
    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
        {
            nDamage = MaximizeOrEmpower(spell.Dice, 20, spell.Meta);
            fDelay = GetRandomDelay(0.4, 1.2);

            if(MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_ACID, aoe.Creator, fDelay))
            {
                 nDamage /= 2;
            }

            //Set the damage effect
            eDam = EffectDamage(nDamage, spell.DamageType);

            //Fire cast spell at event for the affected target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            //Spell resistance check
            if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
            {
               //Apply damage and visuals
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            }
        }
        //Get next target.
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}

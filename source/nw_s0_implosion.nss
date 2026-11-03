//::///////////////////////////////////////////////
//:: Implosion
//:: NW_S0_Implosion.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All persons within a 5ft radius of the spell must
    save at +3 DC or die.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 13, 2001
//:://////////////////////////////////////////////

#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_runes"

void main()
{
    SendMessageToPC(OBJECT_SELF,
        "Module spellhook: ["
        + GetModuleOverrideSpellscript() + "]");

    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_SMALL;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }
    //Declare major variables
    spellsDeclareMajorVariables();

    // declare effects
    effect eDeath = SupernaturalEffect(EffectDeath());  // death ward dont works
    effect eImplode = EffectVisualEffect(VFX_FNF_IMPLOSION);
    if (GetHasFeat(FEAT_DEATH_DOMAIN_POWER, spell.Caster))
        eImplode = EffectVisualEffect(GAOVFX_FNF_IMPLOSION_BLUE);  // visual effect for empowered by domain spell

    float fDelay;
    //Apply the implose effect
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImplode, spell.Loc);
    //Get the first target in the shape
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    while (GetIsObjectValid(oTarget))
    {
        if (/* oTarget != spell.Caster && */spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
           //Fire cast spell at event for the specified target
           SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
           fDelay = GetRandomDelay(0.4, 1.2);
           //Make SR check
           if (!MyResistSpell(spell.Caster, oTarget, fDelay))
           {
                //Make Fort save
                if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC + 3, SAVING_THROW_TYPE_NONE, spell.Caster, fDelay))
                {
                    if(runes_GetHasRunicDeathWard(oTarget))
                        SendMessageToPC(spell.Caster, "Target " + GetName(oTarget) + " has runic Death Ward.");
                    // if Fort >= DC apply damage effect, else death effect
                    else if(players_GetRealSavingThrowValue(oTarget, SAVING_THROW_FORT) >= spell.DC + 3 /*&& !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, spell.Caster) */)
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(FloatToInt(IntToFloat(GetMaxHitPoints(oTarget)) * 0.8)), oTarget));
                    else
                        DelayCommand(fDelay, spells_FixLastKillerAfterDeath(spell.Caster, oTarget, eDeath));

                }
           }
        }
        //Get next target in the shape
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    }
}

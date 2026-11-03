//::///////////////////////////////////////////////
//:: [Shadow Daze]
//:: [x0_S2_Daze.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Shadow dancer.
//:: Will save or be dazed for 5 rounds.
//:: Can only daze humanoid-type creatures
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 23, 2002
//:://////////////////////////////////////////////
//:: Update Pass By:
//:: March 2003: Removed humanoid and level checks to
//:: make this a more powerful daze

#include "X0_I0_SPELLS"

void main()
{
    //Declare major variables
    object oTarget = GetSpellTargetObject();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDaze = EffectStunned();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eMind, eDaze);
    eLink = EffectLinkEffects(eLink, eDur);
    effect eVis = EffectVisualEffect(VFX_IMP_STUN);
    int nDuration = 5;
    int nRacial = GetRacialType(oTarget);
    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_SHADOW_DAZE));

    if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
    {
        //Make SR check
        if (!MyResistSpell(OBJECT_SELF, oTarget))
        {
            //Make Will Save to negate effect
            int nDC = 10 + GetLevelByClass(CLASS_TYPE_SHADOWDANCER) + GetAbilityModifier(ABILITY_DEXTERITY);
            if (!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS))
            {
                //Apply VFX Impact and daze effect
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            }
        }
    }
}



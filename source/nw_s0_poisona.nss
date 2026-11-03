#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "nwnx_effect"
#include "_inc_fshop_spell"

//
effect EffectPlague(int nPercent);

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();

    // determine effect data
    effect ePlague = EffectPlague(10 + 5 * GetSpellUpgradeLevel(aoe.Creator, spell.Id));
    ePlague = ExtraordinaryEffect(ePlague);

    object oTarget = GetEnteringObject();
    float fDelay = GetRandomDelay(1.0, 2.2);
    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire cast spell at event for the target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Spell resistance check
        if(!MyResistSpell(aoe.Creator, oTarget))
        {
            //Apply reduced movement effect and VFX_Impact
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePlague, oTarget);
        }
    }
}

effect EffectPlague(int nPercent)
{
    effect ePlague = EffectIcon(EFFECT_ICON_PLAGUE);
    struct NWNX_EffectUnpacked eEffUnpacked = NWNX_Effect_UnpackEffect(ePlague);
    eEffUnpacked.nSpellId  = SPELL_POISON; // set spell id
    eEffUnpacked.nParam2 = nPercent; // set penalty percent;
    ePlague = NWNX_Effect_PackEffect(eEffUnpacked);
    return ePlague;
}


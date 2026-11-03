//::///////////////////////////////////////////////
//:: Aid
//:: NW_S0_Aid.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Target creature gains +1 to attack rolls and
    saves vs fear. Also gain +1d8 temporary HP.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 6, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
/*
Patch 1.70

- was stacking temp HP
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_runes"
#include "_inc_spellhook"


void ApplyAidToCreature(object oTarget, effect eLink, effect eHP, float fDuration)
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HOLY_AID), oTarget);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, fDuration);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHP, oTarget, fDuration);
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDuration = spell.Level;
    int nBonus = d8(1);
    int nAB;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_MAXIMIZE)
    {
        nBonus = 8; //Damage is at max
    }
    else if (spell.Meta & METAMAGIC_EMPOWER)
    {
        nBonus = nBonus + (nBonus / 2); //Damage/Healing is +50%
    }
    else if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2; //Duration is +100%
    }
    if (GetLevelByClass(CLASS_TYPE_PALADIN, spell.Caster) >= 20)
    {
        nAB = 2;
    }
    else
    {
        nAB = 1;
    }

    effect eAttack = EffectAttackIncrease(nAB);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_ALL, 1, SAVING_THROW_TYPE_FEAR);
    effect eHP = EffectTemporaryHitpoints(nBonus);

    effect eLink = EffectLinkEffects(eAttack, eSave);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, EffectVisualEffect(PRCVFX_DUR_AURA_LAW));
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_AID), HideEffectIcon(eLink));

    int bMassEffect = GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_MASS_CAST, RUNE_SPELL_MASS_CAST_AID) && !GetIsObjectValid(spell.Item);

    if(bMassEffect)
    {
        object oLoop = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        while(GetIsObjectValid(oLoop))
        {
            if(GetFactionEqual(oLoop, spell.Caster))
            {
                float fDelay = GetRandomDelay(0.4, 1.1);
                // recast
                DelayCommand(fDelay * 0.5, OnAreaSpellCast(spell.Caster, oLoop, spell.Id));
                //Fire cast spell at event for the specified target
                SignalEvent(oLoop, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                if (GetLevelByClass(CLASS_TYPE_PALADIN, oLoop) >= 20)
                    DelayCommand(fDelay, ApplyAidToCreature(oLoop, SupernaturalEffect(eLink), SupernaturalEffect(eHP),
                                                            DurationToSeconds(nDuration)));
                else
                    DelayCommand(fDelay, ApplyAidToCreature(oLoop, eLink, eHP, DurationToSeconds(nDuration)));
            }
            oLoop = GetNextObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        }
    }
    else
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        //Fire spell cast at event for target
        //Apply VFX impact and bonus effects
        if (GetLevelByClass(CLASS_TYPE_PALADIN, spell.Caster) >= 20 && GetLevelByClass(CLASS_TYPE_PALADIN, spell.Target) >= 20)
                ApplyAidToCreature(spell.Target, SupernaturalEffect(eLink), SupernaturalEffect(eHP), DurationToSeconds(nDuration));
        else
                ApplyAidToCreature(spell.Target, eLink, eHP, DurationToSeconds(nDuration));
    }
}



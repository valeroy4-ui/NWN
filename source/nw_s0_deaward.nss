//::///////////////////////////////////////////////
//:: Death Ward
//:: NW_S0_DeaWard.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target creature is protected from the instant
    death effects for the duration of the spell
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 27, 2001
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: July 27, 2001

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_runes"
#include "_inc_spellhook"

void ApplyDeathWardToCreature(object oCreature, effect eLink, effect eVis, float fDuration);

void main()
{
    // 1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    spell.Range = RADIUS_SIZE_LARGE;

    if (!X2PreSpellCastCode())
    {
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    // Declare major variables
    spellsDeclareMajorVariables();

    effect eDeath = EffectImmunity(IMMUNITY_TYPE_DEATH);
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH_WARD);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eDeath, eDur);

    // update spell.Level/spell.Meta and visual effect for runic Death Ward
    if(runes_GetStandartSpellIdFromRunic(spell.Id) != RUNE_SPELL_ID_NONE)
    {
        spell.Level  = GetLevelByClass(GetLocalInt(spell.Caster, "RUNIC_CLASS"), spell.Caster);
        spell.Meta   = GetLocalInt(spell.Caster, "RUNIC_META");
        eVis = EffectVisualEffect(GAOVFX_IMP_DEATHWARD_ORANGE);
    }

    // >>> runic negative immune
    int nRunicNegativeImmune = 0;
    //if     (runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_DEATH_WARD_III))
    //    nRunicNegativeImmune = RUNE_EPIC_SPELLS_DEATH_WARD_III_VALUE;
    if(runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_DEATH_WARD_II))
        nRunicNegativeImmune = RUNE_EPIC_SPELLS_DEATH_WARD_II_VALUE;
    if(nRunicNegativeImmune)
        eLink = EffectLinkEffects(eLink, EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, nRunicNegativeImmune));
    // <<< runic negative immune

    int nDuration = spell.Level;

    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
        nDuration = nDuration * 2;   //Duration is +100%

    int bMassEffect = GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_MASS_CAST, RUNE_SPELL_MASS_CAST_DEATH_WARD) && !GetIsObjectValid(spell.Item);

    if(bMassEffect)
    {
        object oLoop = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, FALSE);
        while(GetIsObjectValid(oLoop))
        {
            if(GetFactionEqual(oLoop, spell.Caster))
            {
                float fDelay = GetRandomDelay(0.4, 1.1);
                // recast
                DelayCommand(fDelay * 0.5, OnAreaSpellCast(spell.Caster, oLoop, spell.Id));

                //Fire cast spell at event for the specified target
                SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                //Apply VFX impact and death immunity effect
                DelayCommand(fDelay, ApplyDeathWardToCreature(oLoop, eLink, eVis, DurationToSeconds(nDuration)));

            }
            oLoop = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, FALSE);
        }
    }
    else
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        ApplyDeathWardToCreature(spell.Target, eLink, eVis, DurationToSeconds(nDuration));
    }
}

void ApplyDeathWardToCreature(object oCreature, effect eLink, effect eVis, float fDuration)
{
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCreature, fDuration);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCreature, fDuration);
}

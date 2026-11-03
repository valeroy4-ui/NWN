//::///////////////////////////////////////////////
//:: Undeath's Eternal Foe
//:: x0_s0_udetfoe.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grants many protections against undead
    to allies in a small area
    of effect (everyone gets negative energy protection)
    immunity to poison and disease too
    +4 AC bonus to all creatures
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 31, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spellhook"
#include "_inc_runes"

void GrantProtection(object oTarget, int iAC, int iDuration, int iSpellID, int nRuneLevel);
void GrantFoeRunicBonuses(object oPC);

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    object oTarget;
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    effect eImpact = EffectVisualEffect(PRCVFX_FNF_LOS_WHITE_30);

    int nDuration = spell.Level;
    int nAC = 4;
    int iDispelDCModifier = 0;

    if(!GetIsObjectValid(spell.Item))
    {
        if(GetHasFeat(FEAT_PROTECTION_DOMAIN_POWER) && spell.Class == CLASS_TYPE_CLERIC)
        {
            if(spell.Level > 32)
                nAC += 2;
        }
    }

    // check runes bonuses
    int nRuneLevel = runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_III) +
                     runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_II) +
                     runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_I);

    //Apply Impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    //Get the first target in the radius around the caster
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget,spell.TargetType,spell.Caster))
        {
            //Fire spell cast at event for target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
            GrantProtection(oTarget, nAC, nDuration, spell.Id, nRuneLevel);
        }
        //Get the next target in the specified area around the caster
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    }
}

void GrantProtection(object oTarget, int iAC, int iDuration, int iSpellID, int nRuneLevel)
{
    float fDelay = GetRandomDelay();

    // rebuff
    DelayCommand(fDelay * 0.5, OnAreaSpellCast(spell.Caster, oTarget, spell.Id));

    effect eVis = EffectVisualEffect(VFX_IMP_PDK_OATH);
    effect eNeg = EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, 20);
    effect eLevel = EffectImmunity(IMMUNITY_TYPE_NEGATIVE_LEVEL);
    effect eAbil = EffectImmunity(IMMUNITY_TYPE_ABILITY_DECREASE);

    effect eAC = EffectACIncrease(iAC);
    //Link Effects
    effect eLink = EffectLinkEffects(eNeg, eLevel);
    eLink = EffectLinkEffects(eLink, eAbil);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_FOE), HideEffectIcon(eLink));

    //float fDuration = RoundsToSeconds(iDuration) * (1.0 + RUNE_EPIC_SPELLS_UEF_DUR_COEFF * nRuneLevel);
    //ServerShout("fDuration = " + FloatToString( fDuration, 2, 2) );

    //Apply the VFX impact and effects
    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(iDuration) * (1.0 + RUNE_EPIC_SPELLS_UEF_DUR_COEFF * (nRuneLevel > 0))));
    // apply runic bonuses
    if(nRuneLevel > 2)
        DelayCommand(fDelay, GrantFoeRunicBonuses(oTarget));
}

void GrantFoeRunicBonuses(object oPC)
{
    effect eBlindness = GetFirstEffect(oPC);
    //Search for negative effects
    while(GetIsEffectValid(eBlindness))
    {
        switch(GetEffectType(eBlindness))
        {
            case EFFECT_TYPE_BLINDNESS:
            //Remove effect if it is negative.
            if(!GetIsSupernaturalCurse(eBlindness))
                RemoveEffect(oPC, eBlindness);
        }
        eBlindness = GetNextEffect(oPC);
    }
    effect eBlindnessImmunity = EffectImmunity(IMMUNITY_TYPE_BLINDNESS);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBlindnessImmunity, oPC, 12.0);
}

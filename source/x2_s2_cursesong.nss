//::///////////////////////////////////////////////
//:: Curse Song
//:: X2_S2_CurseSong
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////

#include "x2_i0_spells"
#include "_inc_runes"

void main()
{
    if (!GetHasFeat(FEAT_BARD_SONGS, OBJECT_SELF))
    {
        FloatingTextStrRefOnCreature(85587, OBJECT_SELF); // no more bardsong uses left
        return;
    }
    if (GetHasEffect(EFFECT_TYPE_SILENCE, OBJECT_SELF))
    {
        FloatingTextStrRefOnCreature(85764, OBJECT_SELF); // not useable when silenced
        return;
    }

    //Declare major variables
    int nLevel = GetLevelByClass(CLASS_TYPE_BARD) + GetLevelByClass(CLASS_TYPE_HARPER)/2 + GetLevelByClass(CLASS_TYPE_ARCHMAGE);

    int nRanks = GetSkillRank(SKILL_PERFORM);
    int nPerform = nRanks;
    int nDuration = 10;

    effect eAttack;
    effect eDamage;
    effect eWill;
    effect eFort;
    effect eReflex;
    effect eHP;
    effect eAC;
    effect eSkill;
    int nAttack;
    int nDamage;
    int nWill;
    int nFort;
    int nReflex;
    int nHP;
    int nAC;
    int nSkill;

    //Check to see if the caster has Lasting Impression and increase duration.
    if(GetHasFeat(FEAT_EPIC_LASTING_INSPIRATION))
        nDuration *= 10;
    // lingering song
    if(GetHasFeat(FEAT_LINGERING_SONG))
        nDuration += 5;

    if(nPerform >= 80)
    {
        if(nLevel >= 21)
        {
            nAttack = 2;
            nDamage = 2;
            nWill = 2;
            nFort = 2;
            nReflex = 2;
            nAC = 2;
        }
        else
        {
            nAttack = 1;
            nDamage = 1;
            nWill = 1;
            nFort = 1;
            nReflex = 1;
            nAC = 1;
        }
    }
    else if(nPerform >= 40)
    {
        nAttack = 1;
        nDamage = 1;
        nWill = 1;
        nFort = 1;
        nReflex = 1;
        nAC = 1;
    }

    if(nLevel > 6)
        nSkill = (nLevel - 6)/ 5;

    nHP = nLevel * 2;

    // check runes bonuses
    int nRuneLevel = runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_MISC, RUNE_EPIC_MISC_CURSE_SONG_I) +
                     runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_MISC, RUNE_EPIC_MISC_CURSE_SONG_II) +
                     runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_MISC, RUNE_EPIC_MISC_CURSE_SONG_III);

    //ServerShout("nRuneLevel = " + IntToString(nRuneLevel));

    if(nRuneLevel >= 1)
        nSkill  += 1;
    if(nRuneLevel >= 2)
    {
        nWill   += 1;
        nFort   += 1;
        nReflex += 1;
    }
    if(nRuneLevel >= 3)
        eHP = EffectDamage(RUNE_EPIC_MISC_CURSE_SONG_III_DAMAGE_VALUE, DAMAGE_TYPE_MAGICAL);


    effect eVis = EffectVisualEffect(VFX_IMP_DOOM);
    eAttack = EffectAttackDecrease(nAttack);
    eDamage = EffectDamageDecrease(nDamage, DAMAGE_TYPE_SLASHING);
    effect eLink = EffectLinkEffects(eAttack, eDamage);

    if(nWill > 0)
    {
        eWill = EffectSavingThrowDecrease(SAVING_THROW_WILL, nWill);
        eLink = EffectLinkEffects(eLink, eWill);
    }
    if(nFort > 0)
    {
        eFort = EffectSavingThrowDecrease(SAVING_THROW_FORT, nFort);
        eLink = EffectLinkEffects(eLink, eFort);
    }
    if(nReflex > 0)
    {
        eReflex = EffectSavingThrowDecrease(SAVING_THROW_REFLEX, nReflex);
        eLink = EffectLinkEffects(eLink, eReflex);
    }
    if(nHP > 0)
    {
        eHP = EffectLinkEffects(eHP, EffectDamage(nHP, DAMAGE_TYPE_SONIC));
    }
    if(nAC > 0)
    {
        eAC = EffectACDecrease(nAC, AC_DODGE_BONUS);
        eLink = EffectLinkEffects(eLink, eAC);
    }
    if(nSkill > 0)
    {
        eSkill = EffectSkillDecrease(SKILL_ALL_SKILLS, nSkill);
        eLink = EffectLinkEffects(eLink, eSkill);
    }
    effect eDur  = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2 = EffectVisualEffect(507);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eImpact = EffectVisualEffect(VFX_IMP_HEAD_SONIC);
    effect eFNF = EffectVisualEffect(HGVFX_FNF_LOS_CURSE_SONG);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFNF, GetLocation(OBJECT_SELF));

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(OBJECT_SELF));

    eHP = ExtraordinaryEffect(eHP);
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_SPELL_CURSE_SONG), HideEffectIcon(eLink));
    eLink = ExtraordinaryEffect(eLink);

    float fDelay;
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, OBJECT_SELF))
        {
            if(!GetHasSpellEffect(GetSpellId(), oTarget))
            {
                if (nHP > 0)
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SONIC), oTarget);
                    DelayCommand(0.01, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHP, oTarget));
                }

                if (!GetIsDead(oTarget))
                {
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
                    DelayCommand(GetRandomDelay(0.1, 0.5), ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }

        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(OBJECT_SELF));
    }
    DecrementRemainingFeatUses(OBJECT_SELF, FEAT_BARD_SONGS);
}

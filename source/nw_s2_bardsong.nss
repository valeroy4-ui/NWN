//::///////////////////////////////////////////////
//:: Bard Song
//:: NW_S2_BardSong
//:: Copyright (c) 2001 Bioware Corp.
//::///////////////////////////////////////////////

#include "x0_i0_spells"
#include "_inc_constants"
#include "_inc_sqlite_time"
#include "_inc_sqlocals"
#include "_inc_fshop_spell"
#include "_inc_factions"

//
int bardsong_GetFactionBitArray(int nFaction);

//
void bardsong_RemoveFear(object oTarget);

void main()
{
    if (GetHasEffect(EFFECT_TYPE_SILENCE, OBJECT_SELF))
    {
        FloatingTextStrRefOnCreature(85764, OBJECT_SELF); // not useable when silenced
        return;
    }

    int bCityBufferSong = SQLite_GetTimeStamp() - SQLocals_GetLastUpdated_UnixEpoch(OBJECT_SELF, "BARD_SONG_CASTER_LEVEL", SQLOCALS_TYPE_INT) <= 1;

    //Declare major variables
    int nLevel = GetLevelByClass(CLASS_TYPE_BARD) + GetLevelByClass(CLASS_TYPE_HARPER)/2 + GetLevelByClass(CLASS_TYPE_ARCHMAGE);
    int nPerform = GetSkillRank(SKILL_PERFORM);
    int nSongUpgradesBitArray = 0;

    if(bCityBufferSong)
    {
        nLevel   = SQLocals_GetInt(OBJECT_SELF, "BARD_SONG_CASTER_LEVEL");
        nPerform = SQLocals_GetInt(OBJECT_SELF, "BARD_SONG_PERFORM_SKILL");
        nSongUpgradesBitArray = bardsong_GetFactionBitArray(players_GetFaction(OBJECT_SELF));
    }
    else if(GetIsPC(OBJECT_SELF))
        nSongUpgradesBitArray = GetPCSongBitArray(OBJECT_SELF);

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
    if(GetHasFeat(FEAT_EPIC_LASTING_INSPIRATION) || bCityBufferSong)
        nDuration *= 10;

    // lingering song
    if(GetHasFeat(FEAT_LINGERING_SONG) || bCityBufferSong) // lingering song
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

    nSkill = nLevel / 5;
    nHP = nLevel * (2 + (nSongUpgradesBitArray & FAMESHOP_BARD_SONG_TEMP_HITPOINTS));
    //SendMessageToPC(OBJECT_SELF, IntToString(nHP));

    if(nSkill > 5)
        nSkill = 5;
    if(nSkill > nPerform/10)
        nSkill = nPerform/10;

    effect eVis = EffectVisualEffect(VFX_DUR_BARD_SONG);

    eAttack = EffectAttackIncrease(nAttack);
    //eAttack = EffectAttackIncrease(20);
    eDamage = EffectDamageIncrease(nDamage, DAMAGE_TYPE_BLUDGEONING);
    effect eLink = EffectLinkEffects(eAttack, eDamage);

    if(nWill > 0)
    {
        eWill = EffectSavingThrowIncrease(SAVING_THROW_WILL, nWill);
        eLink = EffectLinkEffects(eLink, eWill);
    }
    if(nFort > 0)
    {
        eFort = EffectSavingThrowIncrease(SAVING_THROW_FORT, nFort);
        eLink = EffectLinkEffects(eLink, eFort);
    }
    if(nReflex > 0)
    {
        eReflex = EffectSavingThrowIncrease(SAVING_THROW_REFLEX, nReflex);
        eLink = EffectLinkEffects(eLink, eReflex);
    }
    if(nHP > 0)
    {
        eHP = EffectTemporaryHitpoints(nHP);
    }
    if(nAC > 0)
    {
        eAC = EffectACIncrease(nAC, AC_DODGE_BONUS);
        eLink = EffectLinkEffects(eLink, eAC);
    }
    if(nSkill > 0)
    {
        eSkill = EffectSkillIncrease(SKILL_ALL_SKILLS, nSkill);
        eLink = EffectLinkEffects(eLink, eSkill);
    }
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    eDur = EffectLinkEffects(EffectVisualEffect(HGVFX_DUR_BARD_SONG_OTHERS), eDur);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eImpact = EffectVisualEffect(VFX_IMP_HEAD_SONIC);
    effect eFNF = EffectVisualEffect(HGVFX_FNF_LOS_BARD_SONG);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFNF, GetLocation(OBJECT_SELF));

    // fameshop bonus buffs ==>
    int nNegativeImmunity = nLevel / 10;
    if(nSongUpgradesBitArray & FAMESHOP_BARD_SONG_NEGATIVE_IMMUNITY && nNegativeImmunity > 0)
    {
        effect eNegativeImmunity = EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, nNegativeImmunity);
        eLink = EffectLinkEffects(eLink, eNegativeImmunity);
    }
    if(nSongUpgradesBitArray & FAMESHOP_BARD_SONG_REGENERATION)
    {
        effect eRegeneration = EffectRegenerate(1 + nLevel / 10, 6.0);
        eLink = EffectLinkEffects(eLink, eRegeneration);
    }
    if(nSongUpgradesBitArray & FAMESHOP_BARD_SONG_CONCEALMENT)
    {
        effect eConcealment = EffectConcealment(10);
        eLink = EffectLinkEffects(eLink, eConcealment);
    }
    if(nSongUpgradesBitArray & FAMESHOP_BARD_SONG_MAGIC_DAMAGE)
    {
        effect eMagicDamage = EffectDamageIncrease(1 + nLevel / 10, DAMAGE_TYPE_MAGICAL);
        eLink = EffectLinkEffects(eLink, eMagicDamage);
    }
    // fameshop bonus buffs <==

    eHP = HideEffectIcon(eHP);
    eHP = ExtraordinaryEffect(eHP);

    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_SPELL_BARD_SONG), HideEffectIcon(eLink));
    eLink = ExtraordinaryEffect(eLink);

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(OBJECT_SELF));
    while(GetIsObjectValid(oTarget))
    {

         // * GZ Oct 2003: If we are silenced, we can not benefit from bard song
         //if (!GetHasEffect(EFFECT_TYPE_SILENCE,oTarget) && !GetHasEffect(EFFECT_TYPE_DEAF,oTarget))
         //{
            if(oTarget == OBJECT_SELF)
            {
                RemoveEffectsFromSpell(oTarget, SPELL_BARD_SONG);
                effect eLinkBard = EffectLinkEffects(eLink, eVis);
                eLinkBard = ExtraordinaryEffect(eLinkBard);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLinkBard, oTarget, RoundsToSeconds(nDuration));
                if (nHP > 0)
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHP, oTarget, RoundsToSeconds(nDuration));
            }
            else if(GetFactionEqual(oTarget))
            {
                RemoveEffectsFromSpell(oTarget, SPELL_BARD_SONG);
                if(nSongUpgradesBitArray & FAMESHOP_BARD_SONG_REMOVE_FEAR)
                    bardsong_RemoveFear(oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
                if (nHP > 0)
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHP, oTarget, RoundsToSeconds(nDuration));
            }
        //}
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(OBJECT_SELF));
    }
}

int bardsong_GetFactionBitArray(int nFaction)
{
    int nBitArray = 0;
    int nPcSongUpgradeLevel = factions_GetFactionBufferSongUpgradeLevel(nFaction);
    if(nPcSongUpgradeLevel >= 1)
        nBitArray |= FAMESHOP_BARD_SONG_TEMP_HITPOINTS;
    if(nPcSongUpgradeLevel >= 2)
        nBitArray |= FAMESHOP_BARD_SONG_NEGATIVE_IMMUNITY;
    if(nPcSongUpgradeLevel >= 3)
        nBitArray |= FAMESHOP_BARD_SONG_REGENERATION;
    if(nPcSongUpgradeLevel >= 4)
        nBitArray |= FAMESHOP_BARD_SONG_CONCEALMENT;
    if(nPcSongUpgradeLevel >= 5)
        nBitArray |= FAMESHOP_BARD_SONG_MAGIC_DAMAGE;
    return nBitArray;
}

void bardsong_RemoveFear(object oTarget)
{
    effect eFear = GetFirstEffect(oTarget);
    //Get the first effect on the current target
    while(GetIsEffectValid(eFear))
    {
        if (GetEffectType(eFear) == EFFECT_TYPE_FRIGHTENED)
            RemoveEffect(oTarget, eFear);
        eFear = GetNextEffect(oTarget);
    }
}

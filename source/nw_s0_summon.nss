//::///////////////////////////////////////////////
//:: Summon Creature Series
//:: NW_S0_Summon
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Carries out the summoning of the appropriate
    creature for the Summon Monster Series of spells
    1 to 9
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 8, 2002
//:://////////////////////////////////////////////

effect SetSummonEffect(int nSpellID);

#include "x2_inc_spellhook"
//#include "inc_spells"

void main()
{

/*
  Spellcast Hook Code
  Added 2003-06-23 by GeorgZ
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

   if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook


    //Declare major variables
    int nSpellID = GetSpellId();
    int nDuration = 2 * GetCasterLevel(OBJECT_SELF);
    effect eSummon = SetSummonEffect(nSpellID);
    //Apply the VFX impact and summon effect

    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, GetSpellTargetLocation(), RoundsToSeconds(nDuration));
}


effect SetSummonEffect(int nSpellID)
{
    int nFocus;
    int nLvl = GetCasterLevel(OBJECT_SELF);
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION,OBJECT_SELF))
                nFocus = 3;
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION,OBJECT_SELF))
                nFocus = 2;
    else if(GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION,OBJECT_SELF))
                nFocus = 1;
    int nFNF_Effect;
    string sSummon;
    if(nSpellID == SPELL_SUMMON_CREATURE_I)
    {
        nFNF_Effect = VFX_FNF_SUMMON_MONSTER_1;
        sSummon = "cr_summon_1_nf";
    }
    else if(nSpellID == SPELL_SUMMON_CREATURE_II && nLvl >= 6)
    {
        nFNF_Effect = VFX_FNF_SUMMON_MONSTER_1;
        sSummon = "cr_summon_2_nf";
    }
    else if(nSpellID == SPELL_SUMMON_CREATURE_III && nLvl >= 9)
    {
        nFNF_Effect = VFX_FNF_SUMMON_MONSTER_1;
        sSummon = "cr_summon_3_nf";
    }
    else if(nSpellID == SPELL_SUMMON_CREATURE_IV && nLvl >= 12)
    {
        nFNF_Effect = VFX_FNF_SUMMON_MONSTER_2;
        sSummon = "cr_summon_4_nf";
    }
    else if(nSpellID == SPELL_SUMMON_CREATURE_V && nLvl >= 15)
    {
        nFNF_Effect = VFX_FNF_SUMMON_MONSTER_2;
        sSummon = "cr_summon_5_nf";
    }
    else if(nSpellID == SPELL_SUMMON_CREATURE_VI && nLvl >= 18)
    {
        nFNF_Effect = VFX_FNF_SUMMON_MONSTER_2;
        sSummon = "cr_summon_6_nf";

        switch(nFocus)
        {
            case 1: sSummon = "cr_summon_6_f"; break;
            case 2: sSummon = "cr_summon_6_gf"; break;
            case 3: sSummon = "cr_summon_6_ef"; break;
        }
    }
    else if(nSpellID == SPELL_SUMMON_CREATURE_VII && nLvl > 21)
    {
        nFNF_Effect = VFX_FNF_SUMMON_MONSTER_2;
        sSummon = "cr_summon_7_nf";
        switch(nFocus)
        {
            case 1: sSummon = "cr_summon_7_f"; break;
            case 2: sSummon = "cr_summon_7_gf"; break;
            case 3: sSummon = "cr_summon_7_ef"; break;
        }
    }
    else if(nSpellID == SPELL_SUMMON_CREATURE_VIII && nLvl > 24)
    {
        nFNF_Effect = VFX_FNF_SUMMON_MONSTER_2;
        sSummon = "cr_summon_8_nf";
        switch(nFocus)
        {
            case 1: sSummon = "cr_summon_8_f"; break;
            case 2: sSummon = "cr_summon_8_gf"; break;
            case 3: sSummon = "cr_summon_8_ef"; break;
        }
    }
    else if(nSpellID == SPELL_SUMMON_CREATURE_IX && nLvl > 30)
    {
        nFNF_Effect = VFX_FNF_SUMMON_MONSTER_3;
        sSummon = "cr_summon_9_nf";
        switch(nFocus)
        {
            case 1: sSummon = "cr_summon_9_f"; break;
            case 2: sSummon = "cr_summon_9_gf"; break;
            case 3: sSummon = "cr_summon_9_ef"; break;
        }
    }
    effect eVis = EffectVisualEffect(nFNF_Effect);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetSpellTargetLocation());
    if(sSummon == "")
        sSummon = "summon_3_nf";
    effect eSummonedMonster = EffectSummonCreature(sSummon, nFNF_Effect);
    return eSummonedMonster;
}


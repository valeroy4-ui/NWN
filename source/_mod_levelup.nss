#include "_inc_colortext"
#include "_inc_players"
#include "_inc_fameshop"
#include "nwnx_util"

void ReLevel(object oPC, int iLevel = 1)
{
    int nXP1 = StringToInt(Get2DAString("exptable", "XP", GetHitDice(oPC) - 1));
    int nXP2 = GetXP(oPC);
    SetXP(oPC, nXP1 - 1);
    DelayCommand(0.5, SetXP(oPC, nXP2));
    players_UpdateXpBar(oPC);
}


int GetMeetsMaxClassLevelRequirements(object oPC)
{
    int iMeets = TRUE;
    int iClassPos;
    int iClassType = CLASS_TYPE_INVALID;
    for(iClassPos = 1; iClassPos <= 3; iClassPos++)
    {
        iClassType = GetClassByPosition(iClassPos, oPC);
        if(iClassType == CLASS_TYPE_INVALID)
            break;
        if(GetLevelByClass(iClassType, oPC) > GetMaxClassLevelForPC(oPC, iClassType))
            iMeets = FALSE;
    }
    return iMeets;
}

void PostLevelEvent(object oPC, int iLevel)
{
    if(GetHitDice(oPC) == iLevel)
    {
        string sName        = NWNX_Util_StripColors(GetName(oPC));
        string sColoredName = players_GetFactionColor(players_GetFaction(oPC)) + sName + TXT_COLOR_END;
        if(!GetLocalInt(oPC, "HideLevelUp"))
        {
            FloatingTextStringOnCreature(sColoredName + TXT_COLOR_DM_BLUE + " has advanced to level " + IntToString(iLevel) + TXT_COLOR_END, oPC);
            AssignCommand(GetModule(), SpeakString(sColoredName + TXT_COLOR_DM_BLUE +
                                                   " has advanced to level " + IntToString(iLevel) +
                                                   TXT_COLOR_END, TALKVOLUME_SHOUT));
        }
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(ANTHVFX_IMP_PROT_OGHMA), oPC);
        WriteTimestampedLogEntry(sName + " level up: " + IntToString(iLevel));
        NWNX_SQL_ExecuteQuery("UPDATE characters SET `level` = "+IntToString(GetHitDice(oPC))+" WHERE `id` ="+IntToString(players_GetPCPersistentID(oPC)));

        ExecuteScript("_mod_instant_eff", oPC);
        ExecuteScript("ct_pdk_sync", oPC);
        if (!players_IsTestCharacter(oPC)) ExportSingleCharacter(oPC);
    }
}

void main()
{
    object oPC = GetPCLevellingUp();
    int iLevel = GetHitDice(oPC);
    int iReLevel = FALSE;

    effect eEffect = GetFirstEffect(oPC);
    while(GetIsEffectValid(eEffect))
    {
        if(GetEffectType(eEffect) == EFFECT_TYPE_POLYMORPH) //no levelling in polymorph to avoid exploits
        {
            iReLevel = TRUE;
            break;
        }
        eEffect = GetNextEffect(oPC);
    }

    if(!players_IsTestCharacter(oPC) && !GetMeetsMaxClassLevelRequirements(oPC))
    {
        SendColorMessageToPC(oPC, "Access to class level is closed. Please use Player Wand in your inventory to purchase.", TXT_COLOR_RED);
        iReLevel = TRUE;
    }
    // no expertise for bard
    else if(class_GetMainClass(oPC) == CLASS_TYPE_BARD && (GetHasFeat(FEAT_EXPERTISE,oPC) || GetHasFeat(FEAT_IMPROVED_EXPERTISE,oPC)))
    {
        SendColorMessageToPC(oPC, "Feats Expertise and Improved Expertise are not allowed for class Bard.", TXT_COLOR_RED);
        iReLevel = TRUE;
    }
    // no expertise for bard
    else if((GetLevelByClass(CLASS_TYPE_CLERIC,   oPC)  < 38 && GetHasFeat(EPIC_FEAT_ANCIENT_MAGE_ARMOR, oPC))  &&
            (GetLevelByClass(CLASS_TYPE_DRUID,    oPC)  < 38 && GetHasFeat(EPIC_FEAT_ANCIENT_MAGE_ARMOR, oPC))  &&
            (GetLevelByClass(CLASS_TYPE_SORCERER, oPC)  < 35 && GetHasFeat(EPIC_FEAT_ANCIENT_MAGE_ARMOR, oPC))  &&
            (GetLevelByClass(CLASS_TYPE_BARD,     oPC)  < 38 && GetHasFeat(EPIC_FEAT_ANCIENT_MAGE_ARMOR, oPC))
           )
    {
        SendColorMessageToPC(oPC, "Ancient Armor is not allowed in your build.", TXT_COLOR_RED);
        iReLevel = TRUE;
    }
    else if (GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oPC)  &&
            (GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oPC)   ||
             GetLevelByClass(CLASS_TYPE_SHADOWDANCER, oPC)      ||
             GetLevelByClass(CLASS_TYPE_WEAPON_MASTER, oPC)))
    {
        //SendMessageToPC(oPC, "Red Dragon Disciple, Weapon Master and Shadow Dancer are not allowed as multiclass for Dwarven Defender.");
        SendColorMessageToPC(oPC, "Red Dragon Disciple, Weapon Master and Shadow Dancer are not allowed as multiclass for Dwarven Defender.", TXT_COLOR_RED);
        iReLevel = TRUE;
    }
    else if((GetLevelByClass(CLASS_TYPE_ROGUE, oPC) && GetLevelByClass(CLASS_TYPE_ASSASSIN, oPC) && GetLevelByClass(CLASS_TYPE_SHIFTER, oPC)) && GetHasFeat(FEAT_EPIC_FORTITUDE, oPC))
    {
        iReLevel = TRUE;
    }
    else if(GetLevelByClass(CLASS_TYPE_SORCERER, oPC)) // do not multiclass sorcerer
    {
        if(GetLevelByClass(CLASS_TYPE_SORCERER, oPC) + GetLevelByClass(CLASS_TYPE_ARCHMAGE, oPC) != GetHitDice(oPC))
        {
            SendColorMessageToPC(oPC, "Sorcerer allows multiclass only with Archmage.", TXT_COLOR_RED);
            iReLevel = TRUE;
        }
    }

    if(iReLevel)
        ReLevel(oPC);

    DelayCommand(0.1, PostLevelEvent(oPC, iLevel));
    players_UpdateXpBar(oPC);
}

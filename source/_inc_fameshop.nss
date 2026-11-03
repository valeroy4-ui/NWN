#include "_inc_db_funcs"
#include "_inc_log"
#include "_inc_players"
#include "_inc_dispel"
#include "_inc_fshop_const"
#include "_inc_classes"
#include "_inc_feat2skin"
#include "nwnx_util"
#include "nwnx_player"
#include "_inc_generic"
#include "_inc_divbuffer"


// Fameshop constants

string CONST_FAMESHOP_CLASS_OPENED = TXT_COLOR_GREEN_L+"[opened]"+TXT_COLOR_END;
string CONST_FAMESHOP_CLASS_CLOSED = TXT_COLOR_RED+"[closed]"+TXT_COLOR_END;

string CONST_FAMESHOP_UNLOCKED = TXT_COLOR_GREEN_L+"[unlocked]"+TXT_COLOR_END;
string CONST_FAMESHOP_LOCKED = TXT_COLOR_RED+"[locked]"+TXT_COLOR_END;

const string CONST_FAMESHOP_CRITICAL_HIT_BIT_ARRAY = "CONST_FAMESHOP_CRITICAL_HIT_BIT_ARRAY";

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// refresh dialog tokens (classes, epic toughness etc)
void RefreshTokensForPlayer(object oPC);

// resfresh dispel tokens
void RefreshTokensForPlayerDispel(object oPC);

// get all player fame
int GetTotalFame(string sAccount);

// set all player fame
void SetTotalFame(string sAccount, int iValue);

// get spended fame
int GetSpentFame(string sAccount);

// set spended fame
void SetSpentFame(string sAccount, int iValue);

// calculate free fame
int GetFreeFame(object oPC);

// get character spent fame
int GetCharacterSpentFame(int iPlayerID);

// set character spent fame
void SetCharacterSpentFame(int iPlayerID, int iValue);

// spend fame for purchases, use bSaveSpentValueForCharacter = FALSE if this name can not be restored after
// character delete
int SpendFame(object oPC, int iValue, int bPrintPlayerLog = TRUE, int bSaveSpentValueForCharacter = TRUE);

// set max class level for PC
void SetMaxClassLevelForPC(object oPC, int iClass, int iLevel);

// get max class level for PC
int GetMaxClassLevelForPC(object oPC, int iClass);

// try to buy class in fameshop
void TryToUnlockClassLevel(object oPC, int iClassType, int iWantedLevel, int iCost, int iRequiredMinLevel = 0);

////////////////////////////////////////
//            GENERAL FEATS           //
////////////////////////////////////////

// resfresh general feats tokens
void RefreshGeneralFeatTokens(object oPC);

// try to buy one of general feats
int TryToBuyGeneralFeat(object oPC, int iDatabaseFeat, int iCost);

////////////////////////////////////////
//       TOUGHNESS/EPIC TOUGHNESS     //
////////////////////////////////////////

// set epic toughness purchased bonus
void SetEpicToughnessBonus(int iPlayerID, int iToughnessLevel);

// get epic toughness purchased bonus
int GetEpicToughnessBonus(int iPlayerID);

// return feat value for bonus level ID
int ReturnEpicToughnessFeatByNumber(int iToughnessLevel);

// applies epic toughness as character skin feat
void ApplyEpicToughnessBonus(object oPC, int iToughnessLevel);

// tries to buy epic tougness, if successful spends fame and applies epic toughness
int TryToUnlockEpicToughness(object oPC, int iCost, int iToughnessLevel);

// buy fame license
void TryToBuyFameWeapon(object oPC, string sWeaponResref, int iCost);

////////////////////////////////////////
//               DISPELS              //
////////////////////////////////////////

// set additional dispel checks for dispel type
void SetDispellingSpellsBonus(string sAccount, int nDispelType, int nBonus);

// set additional dispel attack roll bonus for dispel type
void SetDispelBonusDC(string sAccount, int iDispelType, int iBonus);

// try to buy additional dispel checks for dispel type
int TryToBuyDispellingSpellsBonus(object oPC, int iDispelType, int iBonus, int iCost);

// try to buy additional dispel attack roll bonus for dispel type
int TryToUnlockDispelBonusDC(object oPC, int iDispelType, int iBonus, int iCost);

// try to buy additional DC vs dispel
int TryToBuyDefenceDCBonus(object oPC, int iBonus, int iCost);

////////////////////////////////////////
//            DIVINE BUFFER           //
////////////////////////////////////////

// try to buy divine buffer bonus spells
int TryToBuyDivineBufferBonusSpells(object oPC, int iWantedBonus, int iRequiredBonus, int iCost);

//////////////////////////////////////////
// Empowered Hit and Critical Hit Range //
//////////////////////////////////////////

//
int TryToBuyEmpoweredHit(object oPC, int iFeatBit, int iCost);

//
int GetEmpoweredHitDamageBonus(object oPC);

//
int GetCriticalHitBonusesBitArray(object oPC);

//
int TryToBuyCriticalHitRange(object oPC, int iFeatBit, int iCost);


///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////


void RefreshTokensForPlayer(object oPC)
{
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FREEFAME, IntToString(GetFreeFame(oPC)));

/*
    int iPDKMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_PURPLE_DRAGON_KNIGHT);
    int iAAMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_ARCANE_ARCHER);
    int iASSASSINMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_ASSASSIN);
    int iBARDMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_BARD);
    int iCLERMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_CLERIC);
    int iDRUIDMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_DRUID);
    int iRANGERMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_RANGER);
    int iCHOTMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_DIVINE_CHAMPION);
    int iHARPERMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_HARPER);
    int iMONKMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_MONK);
    int iPMMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_PALE_MASTER);
    int iRDDMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_DRAGON_DISCIPLE);
    int iSHDMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_SHADOWDANCER);
    int iWMMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_WEAPON_MASTER);
    int iSorcMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_SORCERER);
    int iArchmageMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_ARCHMAGE);
    int iDDMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_DWARVEN_DEFENDER);
    int iShifterMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_SHIFTER);
    int iFighterMaxLevel = GetMaxClassLevelForPC(oPC, CLASS_TYPE_FIGHTER);

//------------PDK
    if(iPDKMaxLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_PDK_6, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_PDK_6, CONST_FAMESHOP_CLASS_CLOSED);

//------------Arcane Archer
    if(iAAMaxLevel >= 9)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCANE_ARCHER_9, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCANE_ARCHER_9, CONST_FAMESHOP_CLASS_CLOSED);

    if(iAAMaxLevel >= 19)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCANE_ARCHER_19, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCANE_ARCHER_19, CONST_FAMESHOP_CLASS_CLOSED);

    if(iAAMaxLevel >= 29)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCANE_ARCHER_29, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCANE_ARCHER_29, CONST_FAMESHOP_CLASS_CLOSED);
//------------Bard
    if(iBARDMaxLevel >= 31)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_31, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_31, CONST_FAMESHOP_CLASS_CLOSED);

    if(iBARDMaxLevel >= 32)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_32, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_32, CONST_FAMESHOP_CLASS_CLOSED);

    if(iBARDMaxLevel >= 33)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_33, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_33, CONST_FAMESHOP_CLASS_CLOSED);

    if(iBARDMaxLevel >= 34)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_34, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_34, CONST_FAMESHOP_CLASS_CLOSED);

    if(iBARDMaxLevel >= 35)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_35, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_35, CONST_FAMESHOP_CLASS_CLOSED);

    if(iBARDMaxLevel >= 36)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_36, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_36, CONST_FAMESHOP_CLASS_CLOSED);

    if(iBARDMaxLevel >= 37)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_37, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_37, CONST_FAMESHOP_CLASS_CLOSED);

    if(iBARDMaxLevel >= 38)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_38, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_38, CONST_FAMESHOP_CLASS_CLOSED);

    if(iBARDMaxLevel >= 39)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_39, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_39, CONST_FAMESHOP_CLASS_CLOSED);

    if(iBARDMaxLevel >= 40)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_40, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARD_40, CONST_FAMESHOP_CLASS_CLOSED);
//------------Cleric
    if(iCLERMaxLevel >= 31)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_31, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_31, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCLERMaxLevel >= 32)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_32, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_32, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCLERMaxLevel >= 33)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_33, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_33, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCLERMaxLevel >= 34)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_34, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_34, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCLERMaxLevel >= 35)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_35, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_35, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCLERMaxLevel >= 36)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_36, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_36, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCLERMaxLevel >= 37)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_37, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_37, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCLERMaxLevel >= 38)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_38, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_38, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCLERMaxLevel >= 39)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_39, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_39, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCLERMaxLevel >= 40)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_40, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLER_40, CONST_FAMESHOP_CLASS_CLOSED);
//------------Druid
    if(iDRUIDMaxLevel >= 31)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_31, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_31, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDRUIDMaxLevel >= 32)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_32, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_32, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDRUIDMaxLevel >= 33)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_33, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_33, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDRUIDMaxLevel >= 34)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_34, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_34, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDRUIDMaxLevel >= 35)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_35, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_35, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDRUIDMaxLevel >= 36)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_36, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_36, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDRUIDMaxLevel >= 37)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_37, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_37, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDRUIDMaxLevel >= 38)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_38, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_38, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDRUIDMaxLevel >= 39)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_39, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_39, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDRUIDMaxLevel >= 40)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_40, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DRUID_40, CONST_FAMESHOP_CLASS_CLOSED);
//------------Ranger
    if(iRANGERMaxLevel >= 31)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_31, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_31, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRANGERMaxLevel >= 32)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_32, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_32, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRANGERMaxLevel >= 33)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_33, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_33, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRANGERMaxLevel >= 34)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_34, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_34, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRANGERMaxLevel >= 35)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_35, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_35, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRANGERMaxLevel >= 36)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_36, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_36, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRANGERMaxLevel >= 37)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_37, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_37, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRANGERMaxLevel >= 38)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_38, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_38, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRANGERMaxLevel >= 39)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_39, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_39, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRANGERMaxLevel >= 40)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_40, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RANGER_40, CONST_FAMESHOP_CLASS_CLOSED);
//------------Assassin
    if(iASSASSINMaxLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_1, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_1, CONST_FAMESHOP_CLASS_CLOSED);

    if(iASSASSINMaxLevel >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_2, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_2, CONST_FAMESHOP_CLASS_CLOSED);

    if(iASSASSINMaxLevel >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_3, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_3, CONST_FAMESHOP_CLASS_CLOSED);

    if(iASSASSINMaxLevel >= 4)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_4, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_4, CONST_FAMESHOP_CLASS_CLOSED);

    if(iASSASSINMaxLevel >= 5)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_5, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_5, CONST_FAMESHOP_CLASS_CLOSED);

    if(iASSASSINMaxLevel >= 6)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_6, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_6, CONST_FAMESHOP_CLASS_CLOSED);

    if(iASSASSINMaxLevel >= 7)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_7, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_7, CONST_FAMESHOP_CLASS_CLOSED);

    if(iASSASSINMaxLevel >= 8)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_8, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_8, CONST_FAMESHOP_CLASS_CLOSED);

    if(iASSASSINMaxLevel >= 9)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_9, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_9, CONST_FAMESHOP_CLASS_CLOSED);

    if(iASSASSINMaxLevel >= 10)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_10, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_10, CONST_FAMESHOP_CLASS_CLOSED);

    if(iASSASSINMaxLevel >= 11)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_11, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ASSASSIN_11, CONST_FAMESHOP_CLASS_CLOSED);
//------------CHOT
    if(iCHOTMaxLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_CHAMPION_1, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_CHAMPION_1, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCHOTMaxLevel >= 5)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_CHAMPION_5, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_CHAMPION_5, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCHOTMaxLevel >= 10)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_CHAMPION_10, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_CHAMPION_10, CONST_FAMESHOP_CLASS_CLOSED);

    if(iCHOTMaxLevel >= 15)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_CHAMPION_15, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_CHAMPION_15, CONST_FAMESHOP_CLASS_CLOSED);
//------------Harper Scout
    if(iHARPERMaxLevel >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_HARPER_SCOUT_3, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_HARPER_SCOUT_3, CONST_FAMESHOP_CLASS_CLOSED);

    if(iHARPERMaxLevel >= 4)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_HARPER_SCOUT_4, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_HARPER_SCOUT_4, CONST_FAMESHOP_CLASS_CLOSED);

    if(iHARPERMaxLevel >= 5)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_HARPER_SCOUT_5, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_HARPER_SCOUT_5, CONST_FAMESHOP_CLASS_CLOSED);
//------------Monk
    if(iMONKMaxLevel >= 11)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_11, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_11, CONST_FAMESHOP_CLASS_CLOSED);

    if(iMONKMaxLevel >= 16)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_16, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_16, CONST_FAMESHOP_CLASS_CLOSED);

    if(iMONKMaxLevel >= 21)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_21, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_21, CONST_FAMESHOP_CLASS_CLOSED);

    if(iMONKMaxLevel >= 26)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_26, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_26, CONST_FAMESHOP_CLASS_CLOSED);

    if(iMONKMaxLevel >= 31)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_31, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_31, CONST_FAMESHOP_CLASS_CLOSED);

    if(iMONKMaxLevel >= 36)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_36, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_36, CONST_FAMESHOP_CLASS_CLOSED);
//------------Pale Master
    if(iPMMaxLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_PM_1, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_PM_1, CONST_FAMESHOP_CLASS_CLOSED);
//------------Red Dragon Disciple
    if(iRDDMaxLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_1, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_1, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRDDMaxLevel >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_2, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_2, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRDDMaxLevel >= 4)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_4, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_4, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRDDMaxLevel >= 6)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_6, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_6, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRDDMaxLevel >= 10)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_10, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_10, CONST_FAMESHOP_CLASS_CLOSED);

    if(iRDDMaxLevel >= 30)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_30, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RDD_30, CONST_FAMESHOP_CLASS_CLOSED);
//------------Shadow Dancer
    if(iSHDMaxLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_1, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_1, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSHDMaxLevel >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_2, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_2, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSHDMaxLevel >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_3, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_3, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSHDMaxLevel >= 4)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_4, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_4, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSHDMaxLevel >= 5)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_5, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_5, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSHDMaxLevel >= 6)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_6, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_6, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSHDMaxLevel >= 7)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_7, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_7, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSHDMaxLevel >= 8)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_8, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_8, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSHDMaxLevel >= 9)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_9, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_9, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSHDMaxLevel >= 10)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_10, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHADOWDANCER_10, CONST_FAMESHOP_CLASS_CLOSED);
//------------Sorcerer
    if(iSorcMaxLevel >= 30)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_30, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_30, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSorcMaxLevel >= 31)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_31, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_31, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSorcMaxLevel >= 32)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_32, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_32, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSorcMaxLevel >= 33)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_33, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_33, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSorcMaxLevel >= 34)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_34, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_34, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSorcMaxLevel >= 35)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_35, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_35, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSorcMaxLevel >= 36)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_36, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_36, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSorcMaxLevel >= 37)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_37, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_37, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSorcMaxLevel >= 38)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_38, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_38, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSorcMaxLevel >= 39)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_39, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_39, CONST_FAMESHOP_CLASS_CLOSED);

    if(iSorcMaxLevel >= 40)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_40, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SORC_40, CONST_FAMESHOP_CLASS_CLOSED);
//------------Weapon Master
    if(iWMMaxLevel >= 9)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_WEAPON_MASTER_9, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_WEAPON_MASTER_9, CONST_FAMESHOP_CLASS_CLOSED);

    if(iWMMaxLevel >= 19)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_WEAPON_MASTER_19, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_WEAPON_MASTER_19, CONST_FAMESHOP_CLASS_CLOSED);

    if(iWMMaxLevel >= 30)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_WEAPON_MASTER_30, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_WEAPON_MASTER_30, CONST_FAMESHOP_CLASS_CLOSED);

//------------Archmage
    if(iArchmageMaxLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCHMAGE_1, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCHMAGE_1, CONST_FAMESHOP_CLASS_CLOSED);

    if(iArchmageMaxLevel >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCHMAGE_2, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCHMAGE_2, CONST_FAMESHOP_CLASS_CLOSED);

    if(iArchmageMaxLevel >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCHMAGE_3, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCHMAGE_3, CONST_FAMESHOP_CLASS_CLOSED);

    if(iArchmageMaxLevel >= 4)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCHMAGE_4, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCHMAGE_4, CONST_FAMESHOP_CLASS_CLOSED);

    if(iArchmageMaxLevel >= 5)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCHMAGE_5, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_ARCHMAGE_5, CONST_FAMESHOP_CLASS_CLOSED);


//------------Dwarf Defender
    if(iDDMaxLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_1, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_1, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDDMaxLevel >= 6)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_6, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_6, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDDMaxLevel >= 11)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_11, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_11, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDDMaxLevel >= 16)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_16, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_16, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDDMaxLevel >= 21)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_21, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_21, CONST_FAMESHOP_CLASS_CLOSED);

    if(iDDMaxLevel >= 26)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_26, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DD_26, CONST_FAMESHOP_CLASS_CLOSED);

//------------ Shifter
    if(iShifterMaxLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_1, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_1, CONST_FAMESHOP_CLASS_CLOSED);
    if(iShifterMaxLevel >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_2, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_2, CONST_FAMESHOP_CLASS_CLOSED);
    if(iShifterMaxLevel >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_3, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_3, CONST_FAMESHOP_CLASS_CLOSED);
    if(iShifterMaxLevel >= 4)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_4, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_4, CONST_FAMESHOP_CLASS_CLOSED);
    if(iShifterMaxLevel >= 5)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_5, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_5, CONST_FAMESHOP_CLASS_CLOSED);
    if(iShifterMaxLevel >= 6)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_6, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_6, CONST_FAMESHOP_CLASS_CLOSED);
    if(iShifterMaxLevel >= 7)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_7, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_7, CONST_FAMESHOP_CLASS_CLOSED);
    if(iShifterMaxLevel >= 8)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_8, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_8, CONST_FAMESHOP_CLASS_CLOSED);
    if(iShifterMaxLevel >= 9)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_9, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_9, CONST_FAMESHOP_CLASS_CLOSED);
    if(iShifterMaxLevel >= 10)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_10, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SHIFTER_10, CONST_FAMESHOP_CLASS_CLOSED);

//------------ Fighter
    if(iFighterMaxLevel >= 34)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_34, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_34, CONST_FAMESHOP_CLASS_CLOSED);
    if(iFighterMaxLevel >= 36)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_36, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_36, CONST_FAMESHOP_CLASS_CLOSED);
    if(iFighterMaxLevel >= 38)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_38, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_38, CONST_FAMESHOP_CLASS_CLOSED);
    if(iFighterMaxLevel >= 40)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_40, CONST_FAMESHOP_CLASS_OPENED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_40, CONST_FAMESHOP_CLASS_CLOSED);
*/

//------------ Epic Toughness
    int iPlayerID = players_GetPCPersistentID(oPC);
    int iEpicToughnessBonus = GetEpicToughnessBonus(iPlayerID);
    if(iEpicToughnessBonus == 10)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_10, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_10, CONST_FAMESHOP_LOCKED);

    if(iEpicToughnessBonus >= 9)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_9, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_9, CONST_FAMESHOP_LOCKED);

    if(iEpicToughnessBonus >= 8)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_8, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_8, CONST_FAMESHOP_LOCKED);

    if(iEpicToughnessBonus >= 7)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_7, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_7, CONST_FAMESHOP_LOCKED);

    if(iEpicToughnessBonus >= 6)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_6, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_6, CONST_FAMESHOP_LOCKED);

    if(iEpicToughnessBonus >= 5)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_5, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_5, CONST_FAMESHOP_LOCKED);

    if(iEpicToughnessBonus >= 4)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_4, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_4, CONST_FAMESHOP_LOCKED);

    if(iEpicToughnessBonus >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_3, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_3, CONST_FAMESHOP_LOCKED);

    if(iEpicToughnessBonus >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_2, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_2, CONST_FAMESHOP_LOCKED);

    if(iEpicToughnessBonus >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_1, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_EPIC_TOUGHNESS_1, CONST_FAMESHOP_LOCKED);
//------------ Unlimited Teleports
    if (GetIsObjectValid(generic_FindResrefInInventory(oPC, "fl_tp_arabel_u"))         ||
            GetIsObjectValid(generic_FindResrefInInventory(oPC, "fl_tp_kulg_u"))       ||
               GetIsObjectValid(generic_FindResrefInInventory(oPC, "fl_tp_cult_u"))    ||
                  GetIsObjectValid(generic_FindResrefInInventory(oPC, "fl_tp_reno_u")))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CITY_TELEPORT, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CITY_TELEPORT, CONST_FAMESHOP_LOCKED);

    if (GetIsObjectValid(generic_FindResrefInInventory(oPC, "fl_tp_leader_u")))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_LEADER_TELEPORT, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_LEADER_TELEPORT, CONST_FAMESHOP_LOCKED);

//------------ Divine Buffer
    if(GetIsObjectValid(GetItemPossessedBy(oPC, DIVINE_BUFFER_ITEM_TAG)))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_BUFFER_PURCHASED, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_BUFFER_PURCHASED, CONST_FAMESHOP_LOCKED);

    int nDivineBufferBonusSpells = divbuffer_GetBonusSpellsNumber(oPC);

    if(nDivineBufferBonusSpells >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_BUFFER_BONUS_SPELL_3, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_BUFFER_BONUS_SPELL_3, CONST_FAMESHOP_LOCKED);

    if(nDivineBufferBonusSpells >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_BUFFER_BONUS_SPELL_2, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_BUFFER_BONUS_SPELL_2, CONST_FAMESHOP_LOCKED);

    if(nDivineBufferBonusSpells >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_BUFFER_BONUS_SPELL_1, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DIVINE_BUFFER_BONUS_SPELL_1, CONST_FAMESHOP_LOCKED);

    //------------ Empowered Hit
    int iBitArray = 0;
    string sSQL = "SELECT empowered_hit FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iBitArray = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }

    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_GLOVES_EMPOWERED_HIT_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_GLOVES_EMPOWERED_HIT_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_GLOVES_EMPOWERED_HIT_3, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_GLOVES_EMPOWERED_HIT_4, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_GLOVES_EMPOWERED_HIT_5, CONST_FAMESHOP_LOCKED);

    if(iBitArray & FAMESHOP_GLOVES_EMPOWERED_HIT_1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_GLOVES_EMPOWERED_HIT_1, CONST_FAMESHOP_UNLOCKED);
    if(iBitArray & FAMESHOP_GLOVES_EMPOWERED_HIT_2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_GLOVES_EMPOWERED_HIT_2, CONST_FAMESHOP_UNLOCKED);
    if(iBitArray & FAMESHOP_GLOVES_EMPOWERED_HIT_3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_GLOVES_EMPOWERED_HIT_3, CONST_FAMESHOP_UNLOCKED);
    if(iBitArray & FAMESHOP_GLOVES_EMPOWERED_HIT_4) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_GLOVES_EMPOWERED_HIT_4, CONST_FAMESHOP_UNLOCKED);
    if(iBitArray & FAMESHOP_GLOVES_EMPOWERED_HIT_5) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_GLOVES_EMPOWERED_HIT_5, CONST_FAMESHOP_UNLOCKED);

    // Critical Hit Range
    iBitArray = GetCriticalHitBonusesBitArray(oPC);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_CRIT_RANGE_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_CRIT_RANGE_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_CRIT_RANGE_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARBARIAN_CRIT_RANGE_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARBARIAN_CRIT_RANGE_2, CONST_FAMESHOP_LOCKED);

    if(iBitArray & FAMESHOP_MONK_CRIT_RANGE_1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_MONK_CRIT_RANGE_1, CONST_FAMESHOP_UNLOCKED);
    if(iBitArray & FAMESHOP_FIGHTER_CRIT_RANGE_1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_CRIT_RANGE_1, CONST_FAMESHOP_UNLOCKED);
    if(iBitArray & FAMESHOP_FIGHTER_CRIT_RANGE_2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FIGHTER_CRIT_RANGE_2, CONST_FAMESHOP_UNLOCKED);
    if(iBitArray & FAMESHOP_BARBARIAN_CRIT_RANGE_1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARBARIAN_CRIT_RANGE_1, CONST_FAMESHOP_UNLOCKED);
    if(iBitArray & FAMESHOP_BARBARIAN_CRIT_RANGE_2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BARBARIAN_CRIT_RANGE_2, CONST_FAMESHOP_UNLOCKED);
}

void RefreshTokensForPlayerDispel(object oPC)
{
    string sAccount                     = GetPCPlayerName(oPC);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FREEFAME, IntToString(GetFreeFame(oPC)));

    int iDispelLesserBonusSpells        = dispel_GetFameshopBonusChecksForDispelType(sAccount, SPELL_LESSER_DISPEL);
    int iDispelLesserBonusDC            = dispel_GetFameshopBonusToDispelAttackRoll(sAccount, SPELL_LESSER_DISPEL);

    int iDispelBonusSpells              = dispel_GetFameshopBonusChecksForDispelType(sAccount, SPELL_DISPEL_MAGIC);
    int iDispelBonusDC                  = dispel_GetFameshopBonusToDispelAttackRoll(sAccount, SPELL_DISPEL_MAGIC);

    int iDispelGreaterBonusSpells       = dispel_GetFameshopBonusChecksForDispelType(sAccount, SPELL_GREATER_DISPELLING);
    int iDispelGreaterBonusDC           = dispel_GetFameshopBonusToDispelAttackRoll(sAccount, SPELL_GREATER_DISPELLING);

    int iDispelMordenkainBonusSpells    = dispel_GetFameshopBonusChecksForDispelType(sAccount, SPELL_MORDENKAINENS_DISJUNCTION);
    int iDispelMordenkainBonusDC        = dispel_GetFameshopBonusToDispelAttackRoll(sAccount, SPELL_MORDENKAINENS_DISJUNCTION);

    int iFameBonusDefenceDC             = dispel_GetFameshopDefenceBonusVsDispel(sAccount);

    int iDispelClangBonusSpells         = dispel_GetFameshopBonusChecksForDispelType(sAccount, SPELL_DEAFENING_CLANG);
    int iDispelClangBonusDC             = dispel_GetFameshopBonusToDispelAttackRoll(sAccount, SPELL_DEAFENING_CLANG);

    // Lesser dispel tokens. Bonus dispel number
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_1_SPELLS_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_1_SPELLS_2, CONST_FAMESHOP_LOCKED);
    if(iDispelLesserBonusSpells >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_1_SPELLS_1,CONST_FAMESHOP_UNLOCKED);
    if(iDispelLesserBonusSpells >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_1_SPELLS_2,CONST_FAMESHOP_UNLOCKED);
    // Lesser dispel tokens. Bonus Attack roll
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_1_DC_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_1_DC_2, CONST_FAMESHOP_LOCKED);
    if(iDispelLesserBonusDC >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_1_DC_1, CONST_FAMESHOP_UNLOCKED);
    if(iDispelLesserBonusDC >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_1_DC_2, CONST_FAMESHOP_UNLOCKED);

    // Dispel magic tokens. Bonus dispel number
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_3_SPELLS_1,CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_3_SPELLS_2,CONST_FAMESHOP_LOCKED);
    if(iDispelBonusSpells >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_3_SPELLS_1, CONST_FAMESHOP_UNLOCKED);
    if(iDispelBonusSpells >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_3_SPELLS_2, CONST_FAMESHOP_UNLOCKED);
    // Dispel magic tokens. Bonus Attack roll
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_3_DC_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_3_DC_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_3_DC_3, CONST_FAMESHOP_LOCKED);
    if(iDispelBonusDC >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_3_DC_1, CONST_FAMESHOP_UNLOCKED);
    if(iDispelBonusDC >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_3_DC_2, CONST_FAMESHOP_UNLOCKED);
    if(iDispelBonusDC >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_3_DC_3, CONST_FAMESHOP_UNLOCKED);

    // Greater dispel tokens. Bonus dispel number
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_SPELLS_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_SPELLS_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_SPELLS_3, CONST_FAMESHOP_LOCKED);
    if(iDispelGreaterBonusSpells >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_SPELLS_1, CONST_FAMESHOP_UNLOCKED);
    if(iDispelGreaterBonusSpells >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_SPELLS_2, CONST_FAMESHOP_UNLOCKED);
    if(iDispelGreaterBonusSpells >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_SPELLS_3, CONST_FAMESHOP_UNLOCKED);
    // Greater dispel tokens. Bonus Attack roll
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_DC_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_DC_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_DC_3, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_DC_4, CONST_FAMESHOP_LOCKED);
    if(iDispelGreaterBonusDC >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_DC_1, CONST_FAMESHOP_UNLOCKED);
    if(iDispelGreaterBonusDC >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_DC_2, CONST_FAMESHOP_UNLOCKED);
    if(iDispelGreaterBonusDC >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_DC_3, CONST_FAMESHOP_UNLOCKED);
    if(iDispelGreaterBonusDC >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_6_DC_4, CONST_FAMESHOP_UNLOCKED);

    // Morda tokens. Bonus dispel number
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_SPELLS_1,CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_SPELLS_2,CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_SPELLS_3,CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_SPELLS_4,CONST_FAMESHOP_LOCKED);
    if(iDispelMordenkainBonusSpells >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_SPELLS_1,CONST_FAMESHOP_UNLOCKED);
    if(iDispelMordenkainBonusSpells >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_SPELLS_2,CONST_FAMESHOP_UNLOCKED);
    if(iDispelMordenkainBonusSpells >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_SPELLS_3,CONST_FAMESHOP_UNLOCKED);
    if(iDispelMordenkainBonusSpells >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_SPELLS_4,CONST_FAMESHOP_UNLOCKED);
    // Morda tokens. Bonus Attack roll
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_DC_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_DC_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_DC_3, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_DC_4, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_DC_5, CONST_FAMESHOP_LOCKED);
    if(iDispelMordenkainBonusDC >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_DC_1, CONST_FAMESHOP_UNLOCKED);
    if(iDispelMordenkainBonusDC >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_DC_2, CONST_FAMESHOP_UNLOCKED);
    if(iDispelMordenkainBonusDC >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_DC_3, CONST_FAMESHOP_UNLOCKED);
    if(iDispelMordenkainBonusDC >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_DC_4, CONST_FAMESHOP_UNLOCKED);
    if(iDispelMordenkainBonusDC >= 5) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DISPEL_9_DC_5, CONST_FAMESHOP_UNLOCKED);

    // Defence DC bonus tokens
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_3, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_4, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_5, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_6, CONST_FAMESHOP_LOCKED);
    if(iFameBonusDefenceDC >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_1, CONST_FAMESHOP_UNLOCKED);
    if(iFameBonusDefenceDC >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_2, CONST_FAMESHOP_UNLOCKED);
    if(iFameBonusDefenceDC >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_3, CONST_FAMESHOP_UNLOCKED);
    if(iFameBonusDefenceDC >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_4, CONST_FAMESHOP_UNLOCKED);
    if(iFameBonusDefenceDC >= 5) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_5, CONST_FAMESHOP_UNLOCKED);
    if(iFameBonusDefenceDC >= 6) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_DEFENCE_DISPEL_DC_6, CONST_FAMESHOP_UNLOCKED);

    // Deaf Clang tokens. Bonus num spells
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLANG_SPELLS_1,CONST_FAMESHOP_LOCKED);
    if(iDispelClangBonusSpells >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLANG_SPELLS_1,CONST_FAMESHOP_UNLOCKED);
    // Deaf Clang tokens. Bonus Attack roll
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLANG_DISPEL_DC_1,CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLANG_DISPEL_DC_2,CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLANG_DISPEL_DC_3,CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLANG_DISPEL_DC_4,CONST_FAMESHOP_LOCKED);
    if(iDispelClangBonusDC >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLANG_DISPEL_DC_1,CONST_FAMESHOP_UNLOCKED);
    if(iDispelClangBonusDC >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLANG_DISPEL_DC_2,CONST_FAMESHOP_UNLOCKED);
    if(iDispelClangBonusDC >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLANG_DISPEL_DC_3,CONST_FAMESHOP_UNLOCKED);
    if(iDispelClangBonusDC >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_CLANG_DISPEL_DC_4,CONST_FAMESHOP_UNLOCKED);
}

int GetTotalFame(string sAccount)
{
    string sSQL = "SELECT fame_total FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);

    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    else
    {
        return 0;
    }
}

void SetTotalFame(string sAccount, int iValue)
{
    string sSQL = "UPDATE players SET fame_total = ? WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedString(1, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
}

int GetSpentFame(string sAccount)
{
    string sSQL = "SELECT fame_spent FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        int iSpentFame = StringToInt(NWNX_SQL_ReadDataInActiveRow());
        return iSpentFame;
    }
    return 0;
}

void SetSpentFame(string sAccount, int iValue)
{
    string sSQL = "UPDATE players SET fame_spent = ? WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedString(1, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
}

int GetFreeFame(object oPC)
{
    string sAccount = GetPCPlayerName(oPC);
    return GetTotalFame(sAccount) - GetSpentFame(sAccount);
}

int GetCharacterSpentFame(int iPlayerID)
{
    string sSQL = "SELECT fame_spent FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        int iSpentFame = StringToInt(NWNX_SQL_ReadDataInActiveRow());
        return iSpentFame;
    }
    return 0;
}

void SetCharacterSpentFame(int iPlayerID, int iValue)
{
    string sSQL = "UPDATE characters SET fame_spent = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedInt(1, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
}

int SpendFame(object oPC, int iValue, int bPrintPlayerLog = TRUE, int bSaveSpentValueForCharacter = TRUE)
{
    if(GetFreeFame(oPC) >= iValue)
    {
        string sAccount = GetPCPlayerName(oPC);
        SetSpentFame(sAccount, GetSpentFame(sAccount) + iValue);
        WriteLog("Fame spend " + NWNX_Util_StripColors(GetName(oPC)) + "(" + sAccount + ") - " + IntToString(iValue));
        if (bPrintPlayerLog)
            SendMessageToPC(oPC, "You have spent " + IntToString(iValue) + " fame.");
        if (bSaveSpentValueForCharacter)
            SetCharacterSpentFame(players_GetPCPersistentID(oPC), GetCharacterSpentFame(players_GetPCPersistentID(oPC)) + iValue);
        return TRUE;
    }
    else
        return FALSE;
}

void SetMaxClassLevelForPC(object oPC, int iClass, int iLevel)
{
    string sClassName = Get2DAString("classes", "Constant", iClass);
    string sAccount = GetPCPlayerName(oPC);
    if(sClassName != "" && sAccount != "")
    {
        string sSQL = "UPDATE players SET " + sClassName + " = ? WHERE name = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, iLevel);
        NWNX_SQL_PreparedString(1, sAccount);
        NWNX_SQL_ExecutePreparedQuery();
    }
    else
    {
        WriteLog("failed, some args is null (sClassName="+sClassName+", sAccount="+sAccount+", iLevel="+IntToString(iLevel), LOG_LEVEL_ERROR);
    }
}

int GetMaxClassLevelForPC(object oPC, int iClass)
{
    // debug
    int iMaxLevelDebug = StringToInt(db_GetModuleParameter(MODULE_SETTING_DEBUG_MAX_ALLOWED_CLASS_LEVEL));
    //int iMaxLevelDebug = 0;
    if(iMaxLevelDebug > 0) return iMaxLevelDebug;
    // ----------
    string sClassName = Get2DAString("classes", "Constant", iClass);

    string sSQL = "SELECT " + sClassName + " FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, GetPCPlayerName(oPC));
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        int nMaxLevel = StringToInt(NWNX_SQL_ReadDataInActiveRow());
        return nMaxLevel;
    }
     return 0;
}

void TryToUnlockClassLevel(object oPC, int iClassType, int iWantedLevel, int iCost, int iRequiredMinLevel = 0)
{
    object oPC = GetLastSpeaker();
    int iFreeFame = GetFreeFame(oPC);
    int iMinLevel = GetMaxClassLevelForPC(oPC, iClassType);
    if(iRequiredMinLevel > 0 && iMinLevel < iRequiredMinLevel)
    {
        SendMessageToPC(oPC, "You need to unlock previous levels.");
    }
    else if(iFreeFame >= iCost)
    {
        if(GetMaxClassLevelForPC(oPC, iClassType) >= iWantedLevel)
        {
            SendMessageToPC(oPC, "You have already unlock this class level.");
        }
        else
        {
            SetMaxClassLevelForPC(oPC, iClassType, iWantedLevel);
            SpendFame(oPC, iCost, TRUE, FALSE);
            string sClassName = class_GetClassNameById(iClassType);
            SendMessageToPC(oPC, "Maximum " + sClassName + " class level" + ": " + IntToString(iWantedLevel) + ".");
            SendMessageToPC(oPC, "Available fame: " + IntToString(GetFreeFame(oPC)));
            // refresh token for successful purchase
            RefreshTokensForPlayer(oPC);
        }
    }
    else
    {
        SendMessageToPC(oPC, "Not enough fame. Available fame: " + IntToString(iFreeFame));
    }
}

//---------general feats------------

void RefreshGeneralFeatTokens(object oPC)
{
    int iPlayerID = players_GetPCPersistentID(oPC);

    int iBitArrayGeneralFeats = 0;

    string sSQL = "SELECT general_feats FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iBitArrayGeneralFeats = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }

    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FREEFAME, IntToString(GetFreeFame(oPC)));

    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_ALERTNESS, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_BLOODED, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_CALLED_SHOT, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_CRAFT_WAND, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_EPIC_REPUTATION, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_EXTRA_MUSIC, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_EXTRA_STUNNING_ATTACKS, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_EXTRA_TURNING, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_SCRIBE_SCROLL, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_STEALTHY, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_SUPERIOR_INITIATIVE, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_TOUGHNESS, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_THUG, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_IMPROVED_TAUNT, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_ARMOR_PROFICIENCY_HEAVY, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_EXTEND_SPELL, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_WOODEN_BODY, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_WEAP_PROFICIENCY_GOVNOTRYAS, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_SILENCE_SPELL, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_STILL_SPELL, CONST_FAMESHOP_LOCKED);

    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_ALERTNESS)                     NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_ALERTNESS, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_BLOODED)                       NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_BLOODED, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_CALLED_SHOT)                   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_CALLED_SHOT, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_CRAFT_WAND)                    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_CRAFT_WAND, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_EPIC_REPUTATION)               NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_EPIC_REPUTATION, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_EXTRA_MUSIC)                   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_EXTRA_MUSIC, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_EXTRA_STUNNING_ATTACKS)        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_EXTRA_STUNNING_ATTACKS, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_EXTRA_TURNING)                 NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_EXTRA_TURNING, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_SCRIBE_SCROLL)                 NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_SCRIBE_SCROLL, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_STEALTHY)                      NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_STEALTHY, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_SUPERIOR_INITIATIVE)           NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_SUPERIOR_INITIATIVE, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_TOUGHNESS)                     NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_TOUGHNESS, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_THUG)                          NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_THUG, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_IMPROVED_TAUNT)                NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_IMPROVED_TAUNT, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_ARMOR_PROFICIENCY_HEAVY)       NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_ARMOR_PROFICIENCY_HEAVY, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_EXTEND_SPELL)                  NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_EXTEND_SPELL, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_WOODEN_BODY)                   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_WOODEN_BODY, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_WEAP_PROFICIENCY_GOVNOTRYAS)   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_WEAP_PROFICIENCY_GOVNOTRYAS, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_SILENCE_SPELL)                 NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_SILENCE_SPELL, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayGeneralFeats & FAMESHOP_FEAT_STILL_SPELL)                   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FEAT_STILL_SPELL, CONST_FAMESHOP_UNLOCKED);

}

int TryToBuyGeneralFeat(object oPC, int iDatabaseFeat, int iCost)
{
    int iPlayerID = players_GetPCPersistentID(oPC);
    int iBitArray = 0;

    string sSQL = "SELECT general_feats FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iBitArray = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }

    if(iBitArray & iDatabaseFeat)
    {
        SendMessageToPC(oPC, "This feat already purchased.");
        return FALSE;
    }
    else if(GetFreeFame(oPC) >= iCost)
    {
        iBitArray |= iDatabaseFeat;

        sSQL = "UPDATE characters SET general_feats = ? WHERE id = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, iBitArray);
        NWNX_SQL_PreparedInt(1, iPlayerID);
        if (NWNX_SQL_ExecutePreparedQuery())
        {
            int iFeat = -1;
            if(iDatabaseFeat == FAMESHOP_FEAT_ALERTNESS)                    iFeat = FEAT_ALERTNESS;
            if(iDatabaseFeat == FAMESHOP_FEAT_BLOODED)                      iFeat = FEAT_BLOODED;
            if(iDatabaseFeat == FAMESHOP_FEAT_CALLED_SHOT)                  iFeat = FEAT_CALLED_SHOT;
            if(iDatabaseFeat == FAMESHOP_FEAT_CRAFT_WAND)                   iFeat = FEAT_CRAFT_WAND;
            if(iDatabaseFeat == FAMESHOP_FEAT_EPIC_REPUTATION)              iFeat = FEAT_EPIC_REPUTATION;
            if(iDatabaseFeat == FAMESHOP_FEAT_EXTRA_MUSIC)                  iFeat = FEAT_EXTRA_MUSIC;
            if(iDatabaseFeat == FAMESHOP_FEAT_EXTRA_STUNNING_ATTACKS)       iFeat = FEAT_EXTRA_STUNNING_ATTACK;
            if(iDatabaseFeat == FAMESHOP_FEAT_EXTRA_TURNING)                iFeat = FEAT_EXTRA_TURNING;
            if(iDatabaseFeat == FAMESHOP_FEAT_SCRIBE_SCROLL)                iFeat = FEAT_SCRIBE_SCROLL;
            if(iDatabaseFeat == FAMESHOP_FEAT_STEALTHY)                     iFeat = FEAT_STEALTHY;
            if(iDatabaseFeat == FAMESHOP_FEAT_SUPERIOR_INITIATIVE)          iFeat = FEAT_EPIC_SUPERIOR_INITIATIVE;
            if(iDatabaseFeat == FAMESHOP_FEAT_TOUGHNESS)                    iFeat = FEAT_TOUGHNESS;
            if(iDatabaseFeat == FAMESHOP_FEAT_THUG)                         iFeat = FEAT_THUG;
            if(iDatabaseFeat == FAMESHOP_FEAT_IMPROVED_TAUNT)               iFeat = FEAT_IMPROVED_TAUNT;
            if(iDatabaseFeat == FAMESHOP_FEAT_ARMOR_PROFICIENCY_HEAVY)      iFeat = FEAT_ARMOR_PROFICIENCY_HEAVY;
            if(iDatabaseFeat == FAMESHOP_FEAT_EXTEND_SPELL)                 iFeat = FEAT_EXTEND_SPELL;
            if(iDatabaseFeat == FAMESHOP_FEAT_WOODEN_BODY)                  iFeat = FEAT_WOODEN_BODY;
            if(iDatabaseFeat == FAMESHOP_FEAT_WEAP_PROFICIENCY_GOVNOTRYAS)  iFeat = FEAT_WEP_PROF_GOVNOTRYAS;
            if(iDatabaseFeat == FAMESHOP_FEAT_SILENCE_SPELL)                iFeat = FEAT_SILENCE_SPELL;
            if(iDatabaseFeat == FAMESHOP_FEAT_STILL_SPELL)                  iFeat = FEAT_STILL_SPELL;
            if(iFeat != -1)
            {
                SpendFame(oPC, iCost);
                if(iFeat == FEAT_WEP_PROF_GOVNOTRYAS)
                    NWNX_Creature_AddFeatByLevel(oPC, FEAT_WEP_PROF_GOVNOTRYAS, 1); // 1st exception
                else if(iFeat == FEAT_ARMOR_PROFICIENCY_HEAVY)
                    NWNX_Creature_AddFeatByLevel(oPC, FEAT_ARMOR_PROFICIENCY_HEAVY, 1); // 2nd exception
                else
                    AddFeat(iFeat, oPC); // add feat to player's skin
                string sFeatName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", iFeat)));
                SendMessageToPC(oPC, "Feat "+ sFeatName + " has been successfully purchased.");
                // refresh token for successful purchase
                RefreshGeneralFeatTokens(oPC);
                return TRUE;
            }
            else
            {
                SendMessageToPC(oPC, "Error.");
                return FALSE;
            }
        }
    }
    else
    {
        SendMessageToPC(oPC, "Not enough fame.");
        return FALSE;
    }
    return FALSE;
}

// epic toughness

void SetEpicToughnessBonus(int iPlayerID, int iToughnessLevel)
{
    if (!iPlayerID) return;
    string sSQL = "UPDATE characters SET epic_toughness = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iToughnessLevel);
    NWNX_SQL_PreparedInt(1, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
}

int GetEpicToughnessBonus(int iPlayerID)
{
    int iBonus;
    if(NWNX_SQL_ExecuteQuery("SELECT `epic_toughness` FROM characters WHERE `id`="+IntToString(iPlayerID)) &&
                             NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iBonus = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    return iBonus;
}

int ReturnEpicToughnessFeatByNumber(int iToughnessLevel)
{
    switch(iToughnessLevel)
    {
        case 1:  return FEAT_EPIC_TOUGHNESS_1;
        case 2:  return FEAT_EPIC_TOUGHNESS_2;
        case 3:  return FEAT_EPIC_TOUGHNESS_3;
        case 4:  return FEAT_EPIC_TOUGHNESS_4;
        case 5:  return FEAT_EPIC_TOUGHNESS_5;
        case 6:  return FEAT_EPIC_TOUGHNESS_6;
        case 7:  return FEAT_EPIC_TOUGHNESS_7;
        case 8:  return FEAT_EPIC_TOUGHNESS_8;
        case 9:  return FEAT_EPIC_TOUGHNESS_9;
        case 10: return FEAT_EPIC_TOUGHNESS_10;
    }
    return FALSE;
}

void ApplyEpicToughnessBonus(object oPC, int iToughnessLevel)
{
    int iBonusFeat = ReturnEpicToughnessFeatByNumber(iToughnessLevel);
    // sanity check
    if(!iBonusFeat)
        return;
    if(iToughnessLevel > 1)
        RemoveFeat(ReturnEpicToughnessFeatByNumber(iToughnessLevel - 1), oPC);
    DelayCommand(0.5, AddFeat(iBonusFeat, oPC));
    SendMessageToPC(oPC, "Applying Epic Toughness " + IntToString(iToughnessLevel));
}

int TryToUnlockEpicToughness(object oPC, int iCost, int iToughnessLevel)
{
    int iFreeFame = GetFreeFame(oPC);
    int iPlayerID = players_GetPCPersistentID(oPC);
    int iCurrentToughnessLevel = GetEpicToughnessBonus(iPlayerID);
    int iSuccess = FALSE;

    if(iCurrentToughnessLevel == 10)
    {
        SendMessageToPC(oPC, "The unlock failed. Maximum bonus reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentToughnessLevel >= iToughnessLevel)
    {
        SendMessageToPC(oPC, "The unlock failed. This or higher bonus feat has already been purchased.");
        iSuccess = FALSE;
    }
    else if((iToughnessLevel-iCurrentToughnessLevel) != 1)
    {
        SendMessageToPC(oPC, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if(iFreeFame >= iCost)
    {
        SetEpicToughnessBonus(iPlayerID, iToughnessLevel);
        SpendFame(oPC, iCost, FALSE);
        SendMessageToPC(oPC, "The unlock was successfully completed. You spent " + IntToString(iCost)+ " fame. Available: " + IntToString(GetFreeFame(oPC)));
        // refresh tokens
        RefreshTokensForPlayer(oPC);
        iSuccess = TRUE;
    }
    else
    {
        SendMessageToPC(oPC, "The unlock failed, not enough fame. Need "+IntToString(iCost-iFreeFame)+". Available: " + IntToString(iFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}

void TryToBuyFameWeapon(object oPC, string sWeaponResref, int iCost)
{
    if (sWeaponResref == "")
        return;
    int iFreeFame = GetFreeFame(oPC);
    string sNewTag = sWeaponResref + "L";
    if(iFreeFame >= iCost)
    {
        if(GetIsObjectValid(GetItemPossessedBy(oPC, sNewTag)))
        {
            SendMessageToPC(oPC, "You already bought this license.");
        }
        else
        {
            object oItemAccess = CreateItemOnObject(CONST_FAME_WEAPON_LICENCE, oPC, 1, sNewTag);

            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, TRUE, oPC);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_RECEIVED, TRUE, oPC);

            object oItem = CreateItemOnObject(sWeaponResref, oPC);
            SetName(oItemAccess, "License: " + GetName(oItem));
            SetDroppableFlag(oItem, TRUE);
            SetItemCursedFlag(oItem, FALSE);
            SetPickpocketableFlag(oItem, TRUE);
            SetPlotFlag(oItem, FALSE);
            DestroyObject(oItem);

            DelayCommand(0.5, NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, FALSE, oPC));
            DelayCommand(0.5, NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_RECEIVED, FALSE, oPC));

            SpendFame(oPC, iCost, TRUE, FALSE);
        }
    }
    else
    {
        SendMessageToPC(oPC, "Not enough fame. Available fame: " + IntToString(iFreeFame));
    }
}


// dispels

void SetDispellingSpellsBonus(string sAccount, int nDispelType, int nBonus)
{
    string sColumn;
    switch(nDispelType)
    {
        case SPELL_LESSER_DISPEL:
            sColumn =  "dispel_1_num";
            break;
        case SPELL_DISPEL_MAGIC:
            sColumn =  "dispel_3_num";
            break;
        case SPELL_GREATER_DISPELLING:
            sColumn =  "dispel_6_num";
            break;
        case SPELL_MORDENKAINENS_DISJUNCTION:
            sColumn =  "dispel_9_num";
            break;
        case SPELL_DEAFENING_CLANG:
            sColumn = "dispel_deafening_clang_num";
            break;
    }
    if(sColumn != "")
    {
        string sSQL = "UPDATE players SET " + sColumn + " = ? WHERE name = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, nBonus);
        NWNX_SQL_PreparedString(1, sAccount);
        NWNX_SQL_ExecutePreparedQuery();
    }
}

int TryToBuyDispellingSpellsBonus(object oPC, int iDispelType, int iBonus, int iCost)
{
    string sAccount = GetPCPlayerName(oPC);
    int iFreeFame = GetFreeFame(oPC);
    int iSuccess = FALSE;
    int iCurrentDispelBonus = 0;
    switch(iDispelType)
    {
        case SPELL_LESSER_DISPEL:
        case SPELL_DISPEL_MAGIC:
        case SPELL_GREATER_DISPELLING:
        case SPELL_MORDENKAINENS_DISJUNCTION:
        case SPELL_DEAFENING_CLANG:
            iCurrentDispelBonus = dispel_GetFameshopBonusChecksForDispelType(sAccount, iDispelType);
            break;
        default:
            WriteLog("wrong iDispelType - " + IntToString(iDispelType), LOG_LEVEL_ERROR);
            iSuccess = FALSE;
            return iSuccess;
    }
    if(iCurrentDispelBonus >= iBonus)
    {
        SendMessageToPC(oPC, "The unlock failed. This or higher bonus has already been purchased.");
        iSuccess = FALSE;
    }
    else if((iBonus - iCurrentDispelBonus) != 1)
    {
        SendMessageToPC(oPC, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if(iFreeFame >= iCost)
    {
        SetDispellingSpellsBonus(sAccount, iDispelType, iBonus);
        SpendFame(oPC, iCost, FALSE, FALSE);
        SendMessageToPC(oPC, "The unlock was successfully completed. You spent " + IntToString(iCost)+ " fame. Available: " + IntToString(GetFreeFame(oPC)));
        // refresh tokens
        RefreshTokensForPlayerDispel(oPC);
        iSuccess = TRUE;
    }
    else
    {
        SendMessageToPC(oPC, "Unlock failed: not enough fame. Need "+IntToString(iCost-iFreeFame)+". Available: " + IntToString(iFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}

int TryToBuyDefenceDCBonus(object oPC, int iBonus, int iCost)
{
    string sAccount = GetPCPlayerName(oPC);
    int iFreeFame = GetFreeFame(oPC);
    int iSuccess = FALSE;
    int iCurrentDefenceDCBonus = dispel_GetFameshopDefenceBonusVsDispel(sAccount);

    if(iCurrentDefenceDCBonus >= iBonus)
    {
        SendMessageToPC(oPC, "The unlock failed. This or higher bonus feat has already been purchased.");
        iSuccess = FALSE;
    }
    else if((iBonus - iCurrentDefenceDCBonus) != 1)
    {
        SendMessageToPC(oPC, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if(iFreeFame >= iCost)
    {
        dispel_SetFameshopDefenceBonusVsDispel(sAccount, iBonus);
        SpendFame(oPC, iCost, FALSE, FALSE);
        SendMessageToPC(oPC, "The unlock was successfully completed. You spent " + IntToString(iCost)+ " fame. Available: " + IntToString(GetFreeFame(oPC)));
        RefreshTokensForPlayerDispel(oPC);
        iSuccess = TRUE;
    }
    else
    {
        SendMessageToPC(oPC, "Unlock failed: not enough fame. Need " + IntToString(iCost - iFreeFame) + ". Available: " + IntToString(iFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}

void SetDispelBonusDC(string sAccount, int iDispelType, int iBonus)
{
    string sColumn;
    switch(iDispelType)
    {
        case SPELL_DEAFENING_CLANG:
            sColumn = "dispel_deafening_clang_dc";
        break;
        case SPELL_LESSER_DISPEL:
            sColumn = "dispel_1_dc";
        break;
        case SPELL_DISPEL_MAGIC:
            sColumn = "dispel_3_dc";
        break;
        case SPELL_GREATER_DISPELLING:
            sColumn = "dispel_6_dc";
        break;
        case SPELL_MORDENKAINENS_DISJUNCTION:
            sColumn = "dispel_9_dc";
        break;
    }
    if(sColumn != "")
    {
        string sSQL = "UPDATE players SET " + sColumn + " = ? WHERE name = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, iBonus);
        NWNX_SQL_PreparedString(1, sAccount);
        NWNX_SQL_ExecutePreparedQuery();
    }
}

int TryToUnlockDispelBonusDC(object oPC, int iDispelType, int iBonus, int iCost)
{
    string sAccount = GetPCPlayerName(oPC);
    int iFreeFame = GetFreeFame(oPC);
    int iSuccess = FALSE;
    int iCurrentDispelBonus = 0;
    switch(iDispelType)
    {
        case SPELL_DEAFENING_CLANG:
            iCurrentDispelBonus = dispel_GetFameshopBonusToDispelAttackRoll(sAccount, iDispelType);
            break;
        case SPELL_LESSER_DISPEL:
            iCurrentDispelBonus = dispel_GetFameshopBonusToDispelAttackRoll(sAccount, iDispelType);
            break;
        case SPELL_DISPEL_MAGIC:
            iCurrentDispelBonus = dispel_GetFameshopBonusToDispelAttackRoll(sAccount, iDispelType);
            break;
        case SPELL_GREATER_DISPELLING:
            iCurrentDispelBonus = dispel_GetFameshopBonusToDispelAttackRoll(sAccount, iDispelType);
            break;
        case SPELL_MORDENKAINENS_DISJUNCTION:
            iCurrentDispelBonus = dispel_GetFameshopBonusToDispelAttackRoll(sAccount, iDispelType);
            break;
        default:
            WriteLog("wrong iDispelType - " + IntToString(iDispelType), LOG_LEVEL_ERROR);
            iSuccess = FALSE;
            return iSuccess;
    }
    if(iCurrentDispelBonus >= iBonus)
    {
        SendMessageToPC(oPC, "The unlock failed. This or higher bonus has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iBonus - iCurrentDispelBonus != 1)
    {
        SendMessageToPC(oPC, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if(iFreeFame >= iCost)
    {
        SetDispelBonusDC(sAccount, iDispelType, iBonus);
        SpendFame(oPC, iCost, FALSE, FALSE);
        SendMessageToPC(oPC, "The unlock was successfully completed. You spent " + IntToString(iCost)+ " fame. Available: " + IntToString(GetFreeFame(oPC)));
        iSuccess = TRUE;
        // update tokens
        RefreshTokensForPlayerDispel(oPC);
    }
    else
    {
        SendMessageToPC(oPC, "Unlock failed: not enough fame. Need " + IntToString(iCost - iFreeFame) + ". Available: " + IntToString(iFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}


// Divine Buffer

int TryToBuyDivineBufferBonusSpells(object oPC, int iWantedBonus, int iRequiredBonus, int iCost)
{
    if(!GetIsObjectValid(GetItemPossessedBy(oPC, DIVINE_BUFFER_ITEM_TAG)))
    {
        SendMessageToPC(oPC, "The unlock failed. Buy Divine Buffer first.");
        return FALSE;
    }

    int iFreeFame = GetFreeFame(oPC);
    int iPlayerID = players_GetPCPersistentID(oPC);
    int iCurrentBonus = divbuffer_GetBonusSpellsNumber(oPC);
    int iDelta = iWantedBonus - iCurrentBonus;
    int iSuccess = FALSE;

    if(iRequiredBonus == 3)
    {
        SendMessageToPC(oPC, "The unlock failed. Maximum bonus reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentBonus >= iWantedBonus)
    {
        SendMessageToPC(oPC, "The unlock failed. This or higher bonus has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iDelta > 1)
    {
        SendMessageToPC(oPC, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if (iFreeFame >= iCost && iDelta == 1)
    {
        string sSQL = "UPDATE characters SET divbuffer_bonus = divbuffer_bonus + 1 WHERE id = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, iPlayerID);
        if(NWNX_SQL_ExecutePreparedQuery())
        {
            SpendFame(oPC, iCost);
            SendMessageToPC(oPC, "Purchase completed successfully.");
            RefreshTokensForPlayer(oPC);
            iSuccess = TRUE;
        }
    }
    else
    {
        SendMessageToPC(oPC, "The unlock failed. You should buy previous bonus." + IntToString(iCost - iFreeFame)+". Available: " + IntToString(iFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}

// empowered hit
int TryToBuyEmpoweredHit(object oPC, int iFeatBit, int iCost)
{
    int iPlayerID = players_GetPCPersistentID(oPC);
    int iBitArray = 0;

    string sSQL = "SELECT empowered_hit FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iBitArray = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }

    if(iBitArray & iFeatBit)
    {
        SendMessageToPC(oPC, "This upgrade already purchased.");
        return FALSE;
    }
    else if(GetFreeFame(oPC) >= iCost)
    {
        iBitArray |= iFeatBit;

        sSQL = "UPDATE characters SET empowered_hit = ? WHERE id = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, iBitArray);
        NWNX_SQL_PreparedInt(1, iPlayerID);
        if (NWNX_SQL_ExecutePreparedQuery())
        {
            SpendFame(oPC, iCost);
            SendMessageToPC(oPC, "Upgrade has been successfully purchased.");
            DeleteLocalInt(oPC, "EMPOWERED_HIT_DAMAGE_BONUS");
            RefreshTokensForPlayer(oPC);
            return TRUE;
        }
        else
        {
            SendMessageToPC(oPC, "Empowered Hit upgrade error.");
            return FALSE;
        }
    }
    else
    {
        SendMessageToPC(oPC, "Not enough fame.");
        return FALSE;
    }
    return FALSE;
}

int GetEmpoweredHitDamageBonus(object oPC)
{
    int nResult = GetLocalInt(oPC, "EMPOWERED_HIT_DAMAGE_BONUS");
    if(nResult)
        return nResult > 0 ? nResult : 0;

    int iPlayerID = players_GetPCPersistentID(oPC);
    int iBitArray = 0;
    string sSQL = "SELECT empowered_hit FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iBitArray = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    if(iBitArray & FAMESHOP_GLOVES_EMPOWERED_HIT_1)
        nResult += 1;
    if(iBitArray & FAMESHOP_GLOVES_EMPOWERED_HIT_2)
        nResult += 1;
    if(iBitArray & FAMESHOP_GLOVES_EMPOWERED_HIT_3)
        nResult += 1;
    if(iBitArray & FAMESHOP_GLOVES_EMPOWERED_HIT_4)
        nResult += 1;
    if(iBitArray & FAMESHOP_GLOVES_EMPOWERED_HIT_5)
        nResult += 1;
    if(nResult > 0)
        SetLocalInt(oPC, "EMPOWERED_HIT_DAMAGE_BONUS", nResult);
    else
        SetLocalInt(oPC, "EMPOWERED_HIT_DAMAGE_BONUS", -1);

    return nResult;
}

// monk and fighter fameshop critical range

int GetCriticalHitBonusesBitArray(object oPC)
{
    int nResult = GetLocalInt(oPC, CONST_FAMESHOP_CRITICAL_HIT_BIT_ARRAY);
    if(nResult)
        return nResult > 0 ? nResult : 0;

    int iPlayerID = players_GetPCPersistentID(oPC);
    string sSQL = "SELECT critical_hit_bonuses FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nResult = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    if(nResult > 0)
        SetLocalInt(oPC, CONST_FAMESHOP_CRITICAL_HIT_BIT_ARRAY, nResult);
    else
        SetLocalInt(oPC, CONST_FAMESHOP_CRITICAL_HIT_BIT_ARRAY, -1);

    return nResult;
}

int TryToBuyCriticalHitRange(object oPC, int iFeatBit, int iCost)
{
    if(GetLevelByClass(CLASS_TYPE_FIGHTER, oPC) <= 20 &&
       (iFeatBit & FAMESHOP_FIGHTER_CRIT_RANGE_1 || iFeatBit & FAMESHOP_FIGHTER_CRIT_RANGE_2))
    {
        SendMessageToPC(oPC, "Not enough Fighter levels for this purchase.");
        return FALSE;
    }
    if(!GetLevelByClass(CLASS_TYPE_MONK, oPC) && iFeatBit & FAMESHOP_MONK_CRIT_RANGE_1)
    {
        SendMessageToPC(oPC, "Not enough Monk levels for this purchase.");
        return FALSE;
    }
    if(GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC) <= 30 &&
       (iFeatBit & FAMESHOP_BARBARIAN_CRIT_RANGE_1 || iFeatBit & FAMESHOP_BARBARIAN_CRIT_RANGE_2))
    {
        SendMessageToPC(oPC, "Not enough Barbarian levels for this purchase.");
        return FALSE;
    }

    int iPlayerID = players_GetPCPersistentID(oPC);
    int iBitArray = 0;

    string sSQL = "SELECT critical_hit_bonuses FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iBitArray = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }

    if(iBitArray & iFeatBit)
    {
        SendMessageToPC(oPC, "This upgrade already purchased.");
        return FALSE;
    }
    else if(GetFreeFame(oPC) >= iCost)
    {
        iBitArray |= iFeatBit;

        sSQL = "UPDATE characters SET critical_hit_bonuses = ? WHERE id = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, iBitArray);
        NWNX_SQL_PreparedInt(1, iPlayerID);
        if (NWNX_SQL_ExecutePreparedQuery())
        {
            SpendFame(oPC, iCost);
            SendMessageToPC(oPC, "Upgrade has been successfully purchased.");
            DeleteLocalInt(oPC, CONST_FAMESHOP_CRITICAL_HIT_BIT_ARRAY);
            RefreshTokensForPlayer(oPC);
            return TRUE;
        }
        else
        {
            SendMessageToPC(oPC, "Critical Hit Range upgrade error.");
            return FALSE;
        }
    }
    else
    {
        SendMessageToPC(oPC, "Not enough fame.");
        return FALSE;
    }
    return FALSE;
}

#include "_inc_log"
#include "_inc_fameshop"
#include "x3_inc_skin"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

const int RUNE_EPIC_BASE_COST                               = 200;
const int RUNE_EPIC_MAX_NUMBER_PER_CHARACTER                = 5;

const int RUNE_TYPE_MASS_CAST                               = 1;
const int RUNE_TYPE_EPIC_SPELLS                             = 2;
const int RUNE_TYPE_EPIC_MISC                               = 3;
const int RUNE_TYPE_EPIC_COMBAT                             = 4;

const int RUNE_SPELL_ID_NONE                                = -1;

const string RUNES_MASS_CAST_ARRAY                          = "RUNES_MASS_CAST_ARRAY";
const string RUNES_EPIC_SPELLS_ARRAY                        = "RUNES_EPIC_SPELLS_ARRAY";
const string RUNES_EPIC_MISC_ARRAY                          = "RUNES_EPIC_MISC_ARRAY";
const string RUNES_EPIC_COMBAT_ARRAY                        = "RUNES_EPIC_COMBAT_ARRAY";

const string RUNES_MASS_CAST_TABLE                          = "runes_masscast";
const string RUNES_EPIC_SPELLS_TABLE                        = "runes_epic_spells";
const string RUNES_EPIC_MISC_TABLE                          = "runes_epic_misc";
const string RUNES_EPIC_COMBAT_TABLE                        = "runes_epic_combat";

const int RUNE_NONE                                         = 0x00000000;
const int RUNE_ALL                                          = 0xFFFFFFFF;

const int RUNE_SPELL_MASS_CAST_AID                          = 0x00000001;
const int RUNE_SPELL_MASS_CAST_MAGE_ARMOR                   = 0x00000002;
const int RUNE_SPELL_MASS_CAST_SHIELD_OF_FAITH              = 0x00000004;
const int RUNE_SPELL_MASS_CAST_BARK_SKIN                    = 0x00000008;
const int RUNE_SPELL_MASS_CAST_SEE_INVISIBLE                = 0x00000010;
const int RUNE_SPELL_MASS_CAST_MAGIC_VESTMENT               = 0x00000020;
const int RUNE_SPELL_MASS_CAST_BULLS_STRENGTH               = 0x00000040;
const int RUNE_SPELL_MASS_CAST_CATS_GRACE                   = 0x00000080;
const int RUNE_SPELL_MASS_CAST_ENDURANCE                    = 0x00000100;
const int RUNE_SPELL_MASS_CAST_EAGLE_SPLEDOR                = 0x00000200;
const int RUNE_SPELL_MASS_CAST_OWLS_WISDOM                  = 0x00000400;
const int RUNE_SPELL_MASS_CAST_KEEN_EDGE                    = 0x00000800;
const int RUNE_SPELL_MASS_CAST_GREATER_MAGIC_WEAPON         = 0x00001000;
const int RUNE_SPELL_MASS_CAST_FOXS_CUNNING                 = 0x00002000;
const int RUNE_SPELL_MASS_CAST_DEATH_WARD                   = 0x00004000;
const int RUNE_SPELL_MASS_CAST_DISPLACEMENT                 = 0x00008000;

const int RUNE_EPIC_SPELLS_DEATH_WARD_I                     = 0x00000001; // main
const int RUNE_EPIC_SPELLS_DEATH_WARD_II                    = 0x00000002;
const int RUNE_EPIC_SPELLS_DEATH_WARD_III                   = 0x00000004;
const int RUNE_EPIC_SPELLS_CLARITY_I                        = 0x00000008; // main
const int RUNE_EPIC_SPELLS_CLARITY_II                       = 0x00000010;
const int RUNE_EPIC_SPELLS_CLARITY_III                      = 0x00000020;
const int RUNE_EPIC_SPELLS_TRUE_SEEING_I                    = 0x00000040; // main
const int RUNE_EPIC_SPELLS_TRUE_SEEING_II                   = 0x00000080;
const int RUNE_EPIC_SPELLS_TRUE_SEEING_III                  = 0x00000100;
const int RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_I            = 0x00000200; // main
const int RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_II           = 0x00000400;
const int RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_III          = 0x00000800;
const int RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_I           = 0x00001000; // main
const int RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_II          = 0x00002000;
const int RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_III         = 0x00004000;
const int RUNE_EPIC_SPELLS_DIVINE_NATURE_I                  = 0x00008000; // main
const int RUNE_EPIC_SPELLS_DIVINE_NATURE_II                 = 0x00010000;
const int RUNE_EPIC_SPELLS_DIVINE_NATURE_III                = 0x00020000;
const int RUNE_EPIC_SPELLS_IMPLOSION_I                      = 0x00040000; // main
const int RUNE_EPIC_SPELLS_IMPLOSION_II                     = 0x00080000;
const int RUNE_EPIC_SPELLS_IMPLOSION_III                    = 0x00100000;
const int RUNE_EPIC_SPELLS_HEALING_I                        = 0x00200000; // main
const int RUNE_EPIC_SPELLS_HEALING_II                       = 0x00400000;
const int RUNE_EPIC_SPELLS_HEALING_III                      = 0x00800000;
const int RUNE_EPIC_SPELLS_AOE_POWER_I                      = 0x01000000; // main
const int RUNE_EPIC_SPELLS_AOE_POWER_II                     = 0x02000000;
const int RUNE_EPIC_SPELLS_AOE_POWER_III                    = 0x04000000;
const int RUNE_EPIC_SPELLS_AOE_POWER_IV                     = 0x08000000;
const int RUNE_EPIC_SPELLS_AOE_POWER_V                      = 0x10000000;

const int RUNE_EPIC_MISC_CURSE_SONG_I                       = 0x00000001; // main
const int RUNE_EPIC_MISC_CURSE_SONG_II                      = 0x00000002;
const int RUNE_EPIC_MISC_CURSE_SONG_III                     = 0x00000004;
const int RUNE_EPIC_MISC_SKILLS_I                           = 0x00000008; // main
const int RUNE_EPIC_MISC_SKILLS_II                          = 0x00000010;
const int RUNE_EPIC_MISC_SKILLS_III                         = 0x00000020; // not used yet
const int RUNE_EPIC_MISC_REGENERATION_I                     = 0x00000040; // main
const int RUNE_EPIC_MISC_REGENERATION_II                    = 0x00000080;
const int RUNE_EPIC_MISC_REGENERATION_III                   = 0x00000100;
const int RUNE_EPIC_MISC_REGENERATION_IV                    = 0x00000200;
const int RUNE_EPIC_MISC_REGENERATION_V                     = 0x00000400;

const int RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_I               = 0x00000001; // main
const int RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_II              = 0x00000002;
const int RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_III             = 0x00000004;
const int RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_IV              = 0x00000008;
const int RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_V               = 0x00000010;
const int RUNE_EPIC_COMBAT_LIFELEECH_I                      = 0x00000020; // main
const int RUNE_EPIC_COMBAT_LIFELEECH_II                     = 0x00000040;
const int RUNE_EPIC_COMBAT_LIFELEECH_III                    = 0x00000080;
const int RUNE_EPIC_COMBAT_LIFELEECH_IV                     = 0x00000100;
const int RUNE_EPIC_COMBAT_LIFELEECH_V                      = 0x00000200;
const int RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_I            = 0x00000400; // main
const int RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_II           = 0x00000800;
const int RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_III          = 0x00001000;
const int RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_IV           = 0x00002000;
const int RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_V            = 0x00004000;
const int RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_I           = 0x00008000; // main
const int RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_II          = 0x00010000;
const int RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_III         = 0x00020000;
const int RUNE_EPIC_COMBAT_SPLASH_I                         = 0x00040000; // main
const int RUNE_EPIC_COMBAT_SPLASH_II                        = 0x00080000;
const int RUNE_EPIC_COMBAT_SPLASH_III                       = 0x00100000;
const int RUNE_EPIC_COMBAT_SPLASH_IV                        = 0x00200000;
const int RUNE_EPIC_COMBAT_SPLASH_V                         = 0x00400000;

const int RUNE_EPIC_SPELLS_DEATH_WARD_II_VALUE              = 15; // 15%
//const int RUNE_EPIC_SPELLS_DEATH_WARD_III_VALUE             = 20; // unused now
const float RUNE_EPIC_SPELLS_UEF_DUR_COEFF                  = 0.25;
const float RUNE_EPIC_SPELLS_HEALING_I_VALUE                = 0.05; // 5%
const float RUNE_EPIC_SPELLS_HEALING_II_VALUE               = 0.10; // 10%

const int RUNE_EPIC_MISC_CURSE_SONG_III_DAMAGE_VALUE        = 40;
const int RUNE_EPIC_MISC_SKILLS_I_VALUE                     = 1;
const int RUNE_EPIC_MISC_SKILLS_II_VALUE                    = 2;
const int RUNE_EPIC_MISC_SKILLS_III_VALUE                   = 3;
const int RUNE_EPIC_MISC_REGEN_I_VALUE                      = 10; // regen skin prop value (10 per round)
const int RUNE_EPIC_MISC_REGEN_II_VALUE                     = 20; // regen skin prop value (20 per round)
const float RUNE_EPIC_MISC_REGEN_III_VALUE                  = 60.0; // heal interval 60sec
const float RUNE_EPIC_MISC_REGEN_IV_VALUE                   = 50.0; // heal interval 50sec
const float RUNE_EPIC_MISC_REGEN_V_VALUE                    = 40.0; // heal interval 40sec

const int RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_I_VALUE         = 4;
const int RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_II_VALUE        = 8;
const int RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_III_VALUE       = 12;
const int RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_IV_VALUE        = 16;
const int RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_V_VALUE         = 20;
const int RUNE_EPIC_COMBAT_LIFELEECH_I_VALUE                = 5;
const int RUNE_EPIC_COMBAT_LIFELEECH_II_VALUE               = 10;
const int RUNE_EPIC_COMBAT_LIFELEECH_III_VALUE              = 15;
const int RUNE_EPIC_COMBAT_LIFELEECH_IV_VALUE               = 20;
const int RUNE_EPIC_COMBAT_LIFELEECH_V_VALUE                = 25;
const int RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_I_VALUE      = 3;
const int RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_II_VALUE     = 6;
const int RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_III_VALUE    = 9;
const int RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_IV_VALUE     = 12;
const int RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_V_VALUE      = 15;
const float RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_I_VALUE   = 0.05; // 5%
const float RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_II_VALUE  = 0.10; // 10%
const float RUNE_EPIC_COMBAT_SPLASH_I_VALUE                 = 0.09; // 9%
const float RUNE_EPIC_COMBAT_SPLASH_II_VALUE                = 0.18; // 18%
const float RUNE_EPIC_COMBAT_SPLASH_III_VALUE               = 0.27; // 27%
const float RUNE_EPIC_COMBAT_SPLASH_IV_VALUE                = 0.36; // 36%
const float RUNE_EPIC_COMBAT_SPLASH_V_VALUE                 = 0.45; // 45%


//
void runes_LoadRunes(object oPC);

//
void runes_AddRune(object oPC, int iRuneType, int iRune);

//
void runes_RemoveRune(object oPC, int iRuneType, int iRune);

//
int runes_GetHasRune(object oPC, int iRuneType, int iRune);

//
int runes_GetTotalRunes(object oPC);

//
int runes_TryToActivateRune(object oPC, int iRuneType, int iRune);

//
string runes_GetAllKnownRunesList(object oPC);

//
void runes_ClearRunes(object oPC);

//
int runes_SwitchRuneLevel(object oPC, int iRuneType, int iRune);

//
int runes_GetRunicSpellIdFromStandart(int nSpellId);

//
int runes_GetStandartSpellIdFromRunic(int nSpellId);

// override spell target mode vfx for runic adjusted spells
void runes_OverrideSpellTargetModeVFX(object oPC);

//
int runes_GetHasRunicDeathWard(object oPC);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void runes_LoadRunes(object oPC)
{
    int iPlayerId = players_GetPCPersistentID(oPC);
    if(!iPlayerId)
        return;

    NWNX_SQL_ExecuteQuery("SELECT `" + RUNES_MASS_CAST_TABLE   + "`,`" +
                                       RUNES_EPIC_SPELLS_TABLE + "`,`" +
                                       RUNES_EPIC_MISC_TABLE   + "`,`" +
                                       RUNES_EPIC_COMBAT_TABLE + "` " +
                          "FROM characters WHERE `id` = " + IntToString(iPlayerId));
    if (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        SetLocalInt(oPC, RUNES_MASS_CAST_ARRAY, StringToInt(NWNX_SQL_ReadDataInActiveRow(0)));
        SetLocalInt(oPC, RUNES_EPIC_SPELLS_ARRAY, StringToInt(NWNX_SQL_ReadDataInActiveRow(1)));
        SetLocalInt(oPC, RUNES_EPIC_MISC_ARRAY, StringToInt(NWNX_SQL_ReadDataInActiveRow(2)));
        SetLocalInt(oPC, RUNES_EPIC_COMBAT_ARRAY, StringToInt(NWNX_SQL_ReadDataInActiveRow(3)));
    }
    runes_OverrideSpellTargetModeVFX(oPC);
}

void runes_AddRune(object oPC, int iRuneType, int iRune)
{
    if(!GetIsPC(oPC))
        return;
    int iPlayerId = players_GetPCPersistentID(oPC);
    if(!iPlayerId)
        return;

    string sRuneArray;
    string sTable;
    switch(iRuneType)
    {
        case RUNE_TYPE_MASS_CAST:
            sRuneArray = RUNES_MASS_CAST_ARRAY;
            sTable = RUNES_MASS_CAST_TABLE;
            break;
        case RUNE_TYPE_EPIC_SPELLS:
            sRuneArray = RUNES_EPIC_SPELLS_ARRAY;
            sTable = RUNES_EPIC_SPELLS_TABLE;
            break;
        case RUNE_TYPE_EPIC_MISC:
            sRuneArray = RUNES_EPIC_MISC_ARRAY;
            sTable = RUNES_EPIC_MISC_TABLE;
            break;
        case RUNE_TYPE_EPIC_COMBAT:
            sRuneArray = RUNES_EPIC_COMBAT_ARRAY;
            sTable = RUNES_EPIC_COMBAT_TABLE;
            break;
        default:
            return;
    }
    SetLocalInt(oPC, sRuneArray, GetLocalInt(oPC, sRuneArray) | iRune);
    int iRunesArray = GetLocalInt(oPC, sRuneArray);
    NWNX_SQL_ExecuteQuery("UPDATE characters SET `"+sTable+"` = " + IntToString(iRunesArray) + " WHERE `id` = " + IntToString(iPlayerId));
    runes_OverrideSpellTargetModeVFX(oPC);
}

void runes_RemoveRune(object oPC, int iRuneType, int iRune)
{
    if(!GetIsPC(oPC))
        return;
    int iPlayerId = players_GetPCPersistentID(oPC);
    if(!iPlayerId)
        return;

    string sRuneArray;
    string sTable;
    switch(iRuneType)
    {
        case RUNE_TYPE_MASS_CAST:
            sRuneArray = RUNES_MASS_CAST_ARRAY;
            sTable = RUNES_MASS_CAST_TABLE;
            break;
        case RUNE_TYPE_EPIC_SPELLS:
            sRuneArray = RUNES_EPIC_SPELLS_ARRAY;
            sTable = RUNES_EPIC_SPELLS_TABLE;
            break;
        case RUNE_TYPE_EPIC_MISC:
            sRuneArray = RUNES_EPIC_MISC_ARRAY;
            sTable = RUNES_EPIC_MISC_TABLE;
            break;
        case RUNE_TYPE_EPIC_COMBAT:
            sRuneArray = RUNES_EPIC_COMBAT_ARRAY;
            sTable = RUNES_EPIC_COMBAT_TABLE;
            break;
        default:
            return;
    }
    SetLocalInt(oPC, sRuneArray, GetLocalInt(oPC, sRuneArray) & ~iRune);
    int iRunesArray = GetLocalInt(oPC, sRuneArray);
    NWNX_SQL_ExecuteQuery("UPDATE characters SET `"+sTable+"` = " + IntToString(iRunesArray) + " WHERE `id` = " + IntToString(iPlayerId));
}


int runes_GetHasRune(object oPC, int iRuneType, int iRune)
{
    if(!GetIsPC(oPC))
        return FALSE;

    string sRuneArray;
    switch(iRuneType)
    {
        case RUNE_TYPE_MASS_CAST:
            sRuneArray = RUNES_MASS_CAST_ARRAY;
            break;
        case RUNE_TYPE_EPIC_SPELLS:
            sRuneArray = RUNES_EPIC_SPELLS_ARRAY;
            break;
        case RUNE_TYPE_EPIC_MISC:
            sRuneArray = RUNES_EPIC_MISC_ARRAY;
            break;
        case RUNE_TYPE_EPIC_COMBAT:
            sRuneArray = RUNES_EPIC_COMBAT_ARRAY;
            break;
        default:
            return FALSE;
    }
    int nRunesArray = GetLocalInt(oPC, sRuneArray);
    return (nRunesArray & iRune) > 0 ? TRUE : FALSE;
}

int runes_GetTotalRunes(object oPC)
{
    if(!GetIsPC(oPC)) return 0;
    int iPlayerId = players_GetPCPersistentID(oPC);
    if(!iPlayerId) return 0;

    string sSQL = "SELECT `runes_total` FROM characters WHERE `id` = "+IntToString(iPlayerId);
    if(NWNX_SQL_ExecuteQuery(sSQL) && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    return 0;
}

int runes_TryToActivateRune(object oPC, int iRuneType, int iRune)
{
    iRune = runes_SwitchRuneLevel(oPC, iRuneType, iRune);

    // dude defence
    if(iRuneType == RUNE_TYPE_EPIC_MISC && iRune == RUNE_EPIC_MISC_CURSE_SONG_I && !GetLevelByClass(CLASS_TYPE_BARD, oPC))
    {
        SendMessageToPC(oPC, "This rune available for bards only.");
        return FALSE;
    }
    if(runes_GetHasRune(oPC, iRuneType, iRune))
    {
        SendMessageToPC(oPC, "You already activated this rune.");
        return FALSE;
    }
    int iTotalRunes = runes_GetTotalRunes(oPC);
    if(iTotalRunes >= RUNE_EPIC_MAX_NUMBER_PER_CHARACTER && iRuneType != RUNE_TYPE_MASS_CAST)
    {
        SendMessageToPC(oPC, "No more epic rune slots available.");
        return FALSE;
    }

    //int iCost = RUNE_EPIC_BASE_COST * FloatToInt(pow(IntToFloat(2), IntToFloat(iTotalRunes)));
    int iCost = RUNE_EPIC_BASE_COST * (iTotalRunes + 1);

    if(iRuneType != RUNE_TYPE_MASS_CAST && !SpendFame(oPC, iCost))
    {
        SendMessageToPC(oPC, "Rune is not activated. Not enough fame. Need: " + IntToString(iCost));
        return FALSE;
    }
    if(iRuneType == RUNE_TYPE_EPIC_SPELLS || iRuneType == RUNE_TYPE_EPIC_MISC || iRuneType == RUNE_TYPE_EPIC_COMBAT)
    {
        string sSQL = "UPDATE characters SET `runes_total` = `runes_total` + 1 WHERE `id` = " + IntToString(players_GetPCPersistentID(oPC));
        NWNX_SQL_ExecuteQuery(sSQL);
        SendMessageToPC(oPC, "Rune activated. Cost: " + IntToString(iCost));
    }
    else
        SendMessageToPC(oPC, "Rune activated.");

    runes_AddRune(oPC, iRuneType, iRune);
    object oSkin = SKIN_SupportGetSkin(oPC);
    switch(iRuneType)
    {
        case RUNE_TYPE_EPIC_MISC:
            {
                switch(iRune)
                {
                    case RUNE_EPIC_MISC_SKILLS_I:
                        IPSafeAddItemProperty(oSkin, ItemPropertySkillBonus(SKILL_DISCIPLINE, RUNE_EPIC_MISC_SKILLS_I_VALUE));
                        IPSafeAddItemProperty(oSkin, ItemPropertySkillBonus(SKILL_CONCENTRATION, RUNE_EPIC_MISC_SKILLS_I_VALUE));
                        IPSafeAddItemProperty(oSkin, ItemPropertySkillBonus(SKILL_TAUNT, RUNE_EPIC_MISC_SKILLS_I_VALUE));
                        break;
                    case RUNE_EPIC_MISC_SKILLS_II:
                        IPSafeAddItemProperty(oSkin, ItemPropertySkillBonus(SKILL_DISCIPLINE, RUNE_EPIC_MISC_SKILLS_II_VALUE));
                        IPSafeAddItemProperty(oSkin, ItemPropertySkillBonus(SKILL_CONCENTRATION, RUNE_EPIC_MISC_SKILLS_II_VALUE));
                        IPSafeAddItemProperty(oSkin, ItemPropertySkillBonus(SKILL_TAUNT, RUNE_EPIC_MISC_SKILLS_II_VALUE));
                        break;
                    case RUNE_EPIC_MISC_SKILLS_III:
                        IPSafeAddItemProperty(oSkin, ItemPropertySkillBonus(SKILL_DISCIPLINE, RUNE_EPIC_MISC_SKILLS_III_VALUE));
                        IPSafeAddItemProperty(oSkin, ItemPropertySkillBonus(SKILL_CONCENTRATION, RUNE_EPIC_MISC_SKILLS_III_VALUE));
                        IPSafeAddItemProperty(oSkin, ItemPropertySkillBonus(SKILL_TAUNT, RUNE_EPIC_MISC_SKILLS_III_VALUE));
                        break;
                    case RUNE_EPIC_MISC_REGENERATION_I:
                        IPSafeAddItemProperty(oSkin, ItemPropertyRegeneration(RUNE_EPIC_MISC_REGEN_I_VALUE));
                        break;
                    case RUNE_EPIC_MISC_REGENERATION_II:
                        IPSafeAddItemProperty(oSkin, ItemPropertyRegeneration(RUNE_EPIC_MISC_REGEN_II_VALUE));
                        break;
                    //case RUNE_EPIC_MISC_REGENERATION_III:
                    //    IPSafeAddItemProperty(oSkin, ItemPropertyRegeneration(RUNE_EPIC_MISC_REGEN_III_VALUE));
                    //    break;
                }
            }
            break;
    }
    return TRUE;
}

string runes_GetAllKnownRunesList(object oPC)
{
    string sTabulation = "    ";
    // masscast
    string sList = "\nMasscast Runes:";
    int nRunesMassCastArray = GetLocalInt(oPC, RUNES_MASS_CAST_ARRAY);
    if(nRunesMassCastArray)
    {
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_AID)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Aid.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_MAGE_ARMOR)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Mage Armor.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_SHIELD_OF_FAITH)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Shield of Faith.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_BARK_SKIN)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Barkskin.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_SEE_INVISIBLE)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast See Invisible.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_MAGIC_VESTMENT)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Magic Vestment.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_BULLS_STRENGTH)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Bull's Strength.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_CATS_GRACE)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Cat's Grace.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_ENDURANCE)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Endurance.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_EAGLE_SPLEDOR)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Eagle's Splendor.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_OWLS_WISDOM)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Owl's Wisdom.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_FOXS_CUNNING)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Fox's Cunning.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_KEEN_EDGE)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Keen Edge.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_GREATER_MAGIC_WEAPON)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Greater Magic Weapon.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_DEATH_WARD)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Death Ward.", TXT_COLOR_GREEN_L);
        if(nRunesMassCastArray & RUNE_SPELL_MASS_CAST_DISPLACEMENT)
            sList += "\n" + sTabulation + ColorText("Rune of the mass cast Displacement.", TXT_COLOR_GREEN_L);
    }
    else
        sList += "\n" + sTabulation + ColorText("No mass cast runes activated.", TXT_COLOR_RED);
    // epic
    sList += "\nEpic Runes:";
    int nRunesEpicSpellsArray = GetLocalInt(oPC, RUNES_EPIC_SPELLS_ARRAY);
    int nRunesEpicMiscArray = GetLocalInt(oPC, RUNES_EPIC_MISC_ARRAY);
    int nRunesEpicCombatArray = GetLocalInt(oPC, RUNES_EPIC_COMBAT_ARRAY);
    if(nRunesEpicSpellsArray || nRunesEpicMiscArray || nRunesEpicCombatArray)
    {
        //////////////////////////////////////////////////////////////////////////////////////////////
        //////////////                           spells                                     //////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // death ward
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_DEATH_WARD_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Death Ward I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_DEATH_WARD_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Death Ward II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_DEATH_WARD_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Death Ward III.", TXT_COLOR_GREEN_L);
        // clarity
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_CLARITY_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Clarity I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_CLARITY_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Clarity II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_CLARITY_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Clarity III.", TXT_COLOR_GREEN_L);
        // true seeing
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_TRUE_SEEING_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of True Seeing I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_TRUE_SEEING_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of True Seeing II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_TRUE_SEEING_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of True Seeing III.", TXT_COLOR_GREEN_L);
        // freedom
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Freedom of Movement I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Freedom of Movement II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Freedom of Movement III.", TXT_COLOR_GREEN_L);
        // undeath's ethernal foe
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Undeath's ethernal foe I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Undeath's ethernal foe II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Undeath's ethernal foe III.", TXT_COLOR_GREEN_L);
        // divine favor
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_DIVINE_NATURE_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Divine Nature I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_DIVINE_NATURE_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Divine Nature II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_DIVINE_NATURE_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Divine Nature III.", TXT_COLOR_GREEN_L);
        // implosion
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_IMPLOSION_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Implosion I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_IMPLOSION_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Implosion II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_IMPLOSION_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Implosion III.", TXT_COLOR_GREEN_L);
        // Healing
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_HEALING_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Healing I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_HEALING_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Healing II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_HEALING_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Healing III.", TXT_COLOR_GREEN_L);
        // AoE Power
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_AOE_POWER_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of AoE Power I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_AOE_POWER_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of AoE Power II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_AOE_POWER_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of AoE Power III.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_AOE_POWER_IV)
            sList += "\n" + sTabulation + ColorText("Epic Rune of AoE Power IV.", TXT_COLOR_GREEN_L);
        if(nRunesEpicSpellsArray & RUNE_EPIC_SPELLS_AOE_POWER_V)
            sList += "\n" + sTabulation + ColorText("Epic Rune of AoE Power V.", TXT_COLOR_GREEN_L);

        //////////////////////////////////////////////////////////////////////////////////////////////
        //////////////                           misc                                       //////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // curse song
        if(nRunesEpicMiscArray & RUNE_EPIC_MISC_CURSE_SONG_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Curse Song I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicMiscArray & RUNE_EPIC_MISC_CURSE_SONG_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Curse Song II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicMiscArray & RUNE_EPIC_MISC_CURSE_SONG_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Curse Song III.", TXT_COLOR_GREEN_L);
        // discipline
        if(nRunesEpicMiscArray & RUNE_EPIC_MISC_SKILLS_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Skills I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicMiscArray & RUNE_EPIC_MISC_SKILLS_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Skills II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicMiscArray & RUNE_EPIC_MISC_SKILLS_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Skills III.", TXT_COLOR_GREEN_L);
        // regeneration
        if(nRunesEpicMiscArray & RUNE_EPIC_MISC_REGENERATION_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Regeneration I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicMiscArray & RUNE_EPIC_MISC_REGENERATION_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Regeneration II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicMiscArray & RUNE_EPIC_MISC_REGENERATION_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Regeneration III.", TXT_COLOR_GREEN_L);
        if(nRunesEpicMiscArray & RUNE_EPIC_MISC_REGENERATION_IV)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Regeneration IV.", TXT_COLOR_GREEN_L);
        if(nRunesEpicMiscArray & RUNE_EPIC_MISC_REGENERATION_V)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Regeneration V.", TXT_COLOR_GREEN_L);
        //////////////////////////////////////////////////////////////////////////////////////////////
        //////////////                           combat                                     //////////
        //////////////////////////////////////////////////////////////////////////////////////////////
        // critical damage reduction
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Critical Damage Reduction I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Critical Damage Reduction II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Critical Damage Reduction III.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_IV)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Critical Damage Reduction IV.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_V)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Critical Damage Reduction V.", TXT_COLOR_GREEN_L);
        // lifeleech
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_LIFELEECH_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Lifeleech I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_LIFELEECH_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Lifeleech II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_LIFELEECH_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Lifeleech III.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_LIFELEECH_IV)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Lifeleech IV.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_LIFELEECH_V)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Lifeleech V.", TXT_COLOR_GREEN_L);
        // extra weapon damage
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Extra Weapon Damage I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Extra Weapon Damage II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Extra Weapon Damage III.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_IV)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Extra Weapon Damage IV.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_V)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Extra Weapon Damage V.", TXT_COLOR_GREEN_L);
        // devast
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Devastating Critical I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Devastating Critical II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Devastating Critical III.", TXT_COLOR_GREEN_L);
        // splash
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_SPLASH_I)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Splash I.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_SPLASH_II)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Splash II.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_SPLASH_III)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Splash III.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_SPLASH_IV)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Splash IV.", TXT_COLOR_GREEN_L);
        if(nRunesEpicCombatArray & RUNE_EPIC_COMBAT_SPLASH_V)
            sList += "\n" + sTabulation + ColorText("Epic Rune of Splash V.", TXT_COLOR_GREEN_L);

    }
    else
        sList += "\n" + sTabulation + ColorText("No epic runes activated.", TXT_COLOR_RED);

    return sList;
}

void runes_ClearRunes(object oPC)
{
    int iPlayerId = players_GetPCPersistentID(oPC);
    DeleteLocalInt(oPC, RUNES_EPIC_SPELLS_ARRAY);
    DeleteLocalInt(oPC, RUNES_EPIC_MISC_ARRAY);
    DeleteLocalInt(oPC, RUNES_EPIC_COMBAT_ARRAY);
    NWNX_SQL_ExecuteQuery("UPDATE characters SET runes_total = 0 WHERE id = " + IntToString(iPlayerId));
    NWNX_SQL_ExecuteQuery("UPDATE characters SET " +
                               RUNES_EPIC_SPELLS_TABLE + " = 0," +
                               RUNES_EPIC_MISC_TABLE + " = 0," +
                               RUNES_EPIC_COMBAT_TABLE + " = 0 " +
                          "WHERE id = " + IntToString(iPlayerId));
    SendMessageToPC(oPC, "All activated epic runes successfully cleared.");
    object oSkin = SKIN_SupportGetSkin(oPC);
    IPRemoveMatchingItemProperties(oSkin, ITEM_PROPERTY_SKILL_BONUS, DURATION_TYPE_PERMANENT);
    IPRemoveMatchingItemProperties(oSkin, ITEM_PROPERTY_REGENERATION, DURATION_TYPE_PERMANENT);
}

int runes_SwitchRuneLevel(object oPC, int iRuneType, int iRune)
{
    int nSwitchedRune = iRune;
    switch(iRuneType)
    {
        case RUNE_TYPE_EPIC_SPELLS:
            switch(iRune)
            {
                case RUNE_EPIC_SPELLS_DEATH_WARD_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_DEATH_WARD_II))
                        nSwitchedRune = RUNE_EPIC_SPELLS_DEATH_WARD_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_DEATH_WARD_I))
                        nSwitchedRune = RUNE_EPIC_SPELLS_DEATH_WARD_II;
                    break;
                case RUNE_EPIC_SPELLS_CLARITY_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_CLARITY_II))
                        nSwitchedRune = RUNE_EPIC_SPELLS_CLARITY_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_CLARITY_I))
                        nSwitchedRune = RUNE_EPIC_SPELLS_CLARITY_II;
                    break;
                case RUNE_EPIC_SPELLS_TRUE_SEEING_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_TRUE_SEEING_II))
                        nSwitchedRune = RUNE_EPIC_SPELLS_TRUE_SEEING_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_TRUE_SEEING_I))
                        nSwitchedRune = RUNE_EPIC_SPELLS_TRUE_SEEING_II;
                    break;
                case RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_II))
                        nSwitchedRune = RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_I))
                        nSwitchedRune = RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_II;
                    break;
                case RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_II))
                        nSwitchedRune = RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_I))
                        nSwitchedRune = RUNE_EPIC_SPELLS_UNDEATHS_ETERNAL_FOE_II;
                    break;
                case RUNE_EPIC_SPELLS_DIVINE_NATURE_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_DIVINE_NATURE_II))
                        nSwitchedRune = RUNE_EPIC_SPELLS_DIVINE_NATURE_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_DIVINE_NATURE_I))
                        nSwitchedRune = RUNE_EPIC_SPELLS_DIVINE_NATURE_II;
                    break;
                case RUNE_EPIC_SPELLS_IMPLOSION_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_IMPLOSION_II))
                        nSwitchedRune = RUNE_EPIC_SPELLS_IMPLOSION_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_IMPLOSION_I))
                        nSwitchedRune = RUNE_EPIC_SPELLS_IMPLOSION_II;
                    break;
                case RUNE_EPIC_SPELLS_HEALING_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_HEALING_II))
                        nSwitchedRune = RUNE_EPIC_SPELLS_HEALING_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_HEALING_I))
                        nSwitchedRune = RUNE_EPIC_SPELLS_HEALING_II;
                    break;
                case RUNE_EPIC_SPELLS_AOE_POWER_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_AOE_POWER_IV))
                        nSwitchedRune = RUNE_EPIC_SPELLS_AOE_POWER_V;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_AOE_POWER_III))
                        nSwitchedRune = RUNE_EPIC_SPELLS_AOE_POWER_IV;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_AOE_POWER_II))
                        nSwitchedRune = RUNE_EPIC_SPELLS_AOE_POWER_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_SPELLS_AOE_POWER_I))
                        nSwitchedRune = RUNE_EPIC_SPELLS_AOE_POWER_II;
                    break;
            }
            break;
        case RUNE_TYPE_EPIC_MISC:
            switch(iRune)
            {
                case RUNE_EPIC_MISC_CURSE_SONG_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_MISC_CURSE_SONG_II))
                        nSwitchedRune = RUNE_EPIC_MISC_CURSE_SONG_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_MISC_CURSE_SONG_I))
                        nSwitchedRune = RUNE_EPIC_MISC_CURSE_SONG_II;
                    break;
                case RUNE_EPIC_MISC_SKILLS_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_MISC_SKILLS_II))
                        nSwitchedRune = RUNE_EPIC_MISC_SKILLS_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_MISC_SKILLS_I))
                        nSwitchedRune = RUNE_EPIC_MISC_SKILLS_II;
                    break;
                case RUNE_EPIC_MISC_REGENERATION_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_MISC_REGENERATION_IV))
                        nSwitchedRune = RUNE_EPIC_MISC_REGENERATION_V;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_MISC_REGENERATION_III))
                        nSwitchedRune = RUNE_EPIC_MISC_REGENERATION_IV;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_MISC_REGENERATION_II))
                        nSwitchedRune = RUNE_EPIC_MISC_REGENERATION_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_MISC_REGENERATION_I))
                        nSwitchedRune = RUNE_EPIC_MISC_REGENERATION_II;
                    break;
            }
            break;
        case RUNE_TYPE_EPIC_COMBAT:
            switch(iRune)
            {
                case RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_IV))
                        nSwitchedRune = RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_V;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_III))
                        nSwitchedRune = RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_IV;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_II))
                        nSwitchedRune = RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_I))
                        nSwitchedRune = RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_II;
                    break;
                case RUNE_EPIC_COMBAT_LIFELEECH_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_LIFELEECH_IV))
                        nSwitchedRune = RUNE_EPIC_COMBAT_LIFELEECH_V;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_LIFELEECH_III))
                        nSwitchedRune = RUNE_EPIC_COMBAT_LIFELEECH_IV;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_LIFELEECH_II))
                        nSwitchedRune = RUNE_EPIC_COMBAT_LIFELEECH_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_LIFELEECH_I))
                        nSwitchedRune = RUNE_EPIC_COMBAT_LIFELEECH_II;
                    break;
                case RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_IV))
                        nSwitchedRune = RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_V;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_III))
                        nSwitchedRune = RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_IV;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_II))
                        nSwitchedRune = RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_I))
                        nSwitchedRune = RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_II;
                    break;
                case RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_II))
                        nSwitchedRune = RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_I))
                        nSwitchedRune = RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_II;
                    break;
                case RUNE_EPIC_COMBAT_SPLASH_I:
                    if     (runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_SPLASH_IV))
                        nSwitchedRune = RUNE_EPIC_COMBAT_SPLASH_V;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_SPLASH_III))
                        nSwitchedRune = RUNE_EPIC_COMBAT_SPLASH_IV;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_SPLASH_II))
                        nSwitchedRune = RUNE_EPIC_COMBAT_SPLASH_III;
                    else if(runes_GetHasRune(oPC, iRuneType, RUNE_EPIC_COMBAT_SPLASH_I))
                        nSwitchedRune = RUNE_EPIC_COMBAT_SPLASH_II;
                    break;
            }
            break;
    }
    return nSwitchedRune;
}

int runes_GetRunicSpellIdFromStandart(int nSpellId)
{
    int nResult;
    switch(nSpellId)
    {
        case SPELL_HEAL:
            return SPELL_RUNIC_HEAL;
        case SPELL_GREATER_RESTORATION:
            return SPELL_RUNIC_GREATER_RESTORATION;
        case SPELL_MASS_HEAL:
            return SPELL_RUNIC_MASS_HEAL;
        case SPELL_DEATH_WARD:
            return SPELL_RUNIC_DEATH_WARD;
        default:
            nResult = RUNE_SPELL_ID_NONE;
        break;
    }
    return nResult;
}

int runes_GetStandartSpellIdFromRunic(int nSpellId)
{
    int nResult;
    switch(nSpellId)
    {
        case SPELL_RUNIC_HEAL:
            return SPELL_HEAL;
        case SPELL_RUNIC_GREATER_RESTORATION:
            return SPELL_GREATER_RESTORATION;
        case SPELL_RUNIC_MASS_HEAL:
            return SPELL_MASS_HEAL;
        case SPELL_RUNIC_DEATH_WARD:
            return SPELL_DEATH_WARD;
        default:
            nResult = RUNE_SPELL_ID_NONE;
        break;
    }
    return nResult;
}

void runes_OverrideSpellTargetModeVFX(object oPC)
{
    float fSizeX = 0.0;
    int nSpellId = -1;
    int nFlags = 0;
    int nImplosionLevel = runes_GetHasRune(oPC, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_IMPLOSION_III) +
                          runes_GetHasRune(oPC, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_IMPLOSION_II)  +
                          runes_GetHasRune(oPC, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_IMPLOSION_I);
    if(nImplosionLevel)
    {
        nSpellId = SPELL_IMPLOSION;
        switch(nImplosionLevel)
        {
            case 1: fSizeX = RADIUS_SIZE_MEDIUM; break;
            case 2:
            case 3: fSizeX = RADIUS_SIZE_LARGE;  break;
        }
        nFlags = StringToInt(Get2DAString("spells", "TargetFlags", nSpellId));
        //ServerShout("nImplosionLevel:" + IntToString(nImplosionLevel) + " | fSizeX: " + FloatToString(fSizeX, 2, 2) + " | nSpellId: " + IntToString(nSpellId));
    }
    if(nSpellId != -1)
        SetSpellTargetingData(oPC, nSpellId, SPELL_TARGETING_SHAPE_SPHERE, fSizeX, 0.0, nFlags);
}

int runes_GetHasRunicDeathWard(object oPC)
{
    if(GetHasSpellEffect(SPELL_RUNIC_DEATH_WARD, oPC))
        return TRUE;
    else
        return FALSE;
}

//void main(){}

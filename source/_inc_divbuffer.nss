#include "x0_i0_stringlib"
#include "_inc_dispel"
#include "nwnx_creature"
#include "nwnx_sql"
#include "_inc_spellhook"

///////////////////////////////////////////////////////////////////
//////////                Constants                      //////////
///////////////////////////////////////////////////////////////////

// base divine buffer uses
const int DIVINE_BUFFER_BASE_SPELLS_NUMBER  = 2;

// maximum bonus
const int DIVINE_BUFFER_MAX_BONUS_NUMBER    = 3;

// divine buffer item tag
const string DIVINE_BUFFER_ITEM_TAG         = "fl_divbuffer";


///////////////////////////////////////////////////////////////////
//////////                Variables                      //////////
///////////////////////////////////////////////////////////////////

// spell white list
string sSpellsWhiteListArray = IntToString(SPELL_AID)                       + "|" +
                               IntToString(SPELL_BATTLETIDE)                + "|" +
                               IntToString(SPELLABILITY_BG_BULLS_STRENGTH)  + "|" +
                               IntToString(SPELL_BLESS)                     + "|" +
                               IntToString(SPELL_DEAFENING_CLANG)           + "|" +
                               IntToString(SPELL_DIVINE_FAVOR)              + "|" +
                               IntToString(SPELL_DIVINE_MIGHT)              + "|" +
                               IntToString(SPELL_DIVINE_POWER)              + "|" +
                               IntToString(SPELL_DIVINE_SHIELD)             + "|" +
                               IntToString(SPELL_HARPER_CLAIRVOYANCE)       + "|" +
                               IntToString(SPELL_HARPER_INVISIBILITY)       + "|" +
                               IntToString(SPELL_HARPER_MIGHT)              + "|" +
                               IntToString(SPELL_HARPER_SHIELD)             + "|" +
                               IntToString(SPELL_HEROIC_POWER)              + "|" +
                               IntToString(SPELL_HOLY_SWORD)                + "|" +
                               IntToString(SPELL_BLADE_THIRST)              + "|" +
                               IntToString(SPELL_BLADE_OF_WRATH)            + "|" +
                               IntToString(622) /* Divine Wrath */          + "|" +
                               IntToString(SPELL_PRAYER);

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// save spell to divine buffer
void divbuffer_SaveSpell(object oCaster, object oDivineBuffer, int nSpellID, int nClass);

// instant cast saved spells
void divbuffer_CastSpells(object oCaster, object oDivineBuffer);

// return TRUE if nSpellID successfully decremented
int divbuffer_DecrementSpellUses(object oCaster, int nSpellID, int nMeta, int nDomain, int nClass);

// return TRUE if nSpellID is allowed for save in divine buffer
int divbuffer_GetIsWhiteListSpell(int nSpellID);

// return metamagic string for nMeta value
string divbuffer_GetMetaMagicName(int nMeta);

// return maximum available spell slots
int divbuffer_GetSpellLimit(object oPC);

// return saved spells string for examine window
string divbuffer_GetSavedSpellsString(object oDivineBuffer);

// return available spells string for examine window
string divbuffer_GetAvailableSpellsString();

// get available fameshop bonus for player character
int divbuffer_GetBonusSpellsNumber(object oPC);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void divbuffer_SaveSpell(object oCaster, object oDivineBuffer, int nSpellID, int nClass)
{
    if(divbuffer_GetIsWhiteListSpell(nSpellID))
    {
        string sStoredSpells = GetLocalString(oDivineBuffer, "DIVINE_BUFFER_STORED_SPELLS_ARRAY");
        if(GetNumberTokens(sStoredSpells, "|") >= divbuffer_GetSpellLimit(oCaster))
        {
            SendColorMessageToPC(oCaster, "You have reached your maximum spell limit.", TXT_COLOR_RED);
            return;
        }
        int nMeta = GetMetaMagicFeat();
        int nDomain = NWNX_Object_GetLastSpellCastDomainLevel(oCaster);
        sStoredSpells += IntToString(nSpellID) + "_" + // spellID
                         IntToString(nMeta)    + "_" + // metamagic
                         IntToString(nDomain)    + "_" + // domain
                         IntToString(nClass)   + "_" + // spell class
                         IntToString(NWNX_Object_GetLastSpellCastFeat(oCaster)) + // feat ID, return 65535 when not cast by a feat
                         "|";
        SetLocalString(oDivineBuffer, "DIVINE_BUFFER_STORED_SPELLS_ARRAY", sStoredSpells);
        string sMessage = GetSpellNameFromID(nSpellID) + " successfully added.";
        string sMeta = divbuffer_GetMetaMagicName(nMeta);
        if(sMeta != "")
            sMessage = sMeta + " " + sMessage;
        SendColorMessageToPC(oCaster, sMessage, TXT_COLOR_WHITE_T);
    }
}

void divbuffer_CastSpells(object oCaster, object oDivineBuffer)
{
    string sStoredSpells = GetLocalString(oDivineBuffer, "DIVINE_BUFFER_STORED_SPELLS_ARRAY");
    struct sStringTokenizer stSpellArrayTok = GetStringTokenizer(sStoredSpells, "|");
    while(HasMoreTokens(stSpellArrayTok))
    {
        stSpellArrayTok = AdvanceToNextToken(stSpellArrayTok);
        string sToken = GetNextToken(stSpellArrayTok);

        int nSpell  = StringToInt(GetTokenByPosition(sToken, "_", 0));
        int nMeta   = StringToInt(GetTokenByPosition(sToken, "_", 1));
        int nDomain = StringToInt(GetTokenByPosition(sToken, "_", 2));
        int nClass  = StringToInt(GetTokenByPosition(sToken, "_", 3));
        int nFeat   = StringToInt(GetTokenByPosition(sToken, "_", 4));
        int nCasterLevel = GetLevelByClass(nClass, oCaster);

        int bAllowCast = FALSE;
        if(nFeat == 65535 && divbuffer_DecrementSpellUses(oCaster, nSpell, nMeta, nDomain, nClass))
        {
            SetLocalInt(oCaster, IntToString(nSpell) + "_METAMAGIC_OVERRIDE", nMeta);
            SetLocalInt(oCaster, "LAST_CASTER_SPELL_CLASS", nClass);
            SetLocalInt(oCaster, "LAST_CASTER_LEVEL", nCasterLevel);
            bAllowCast = TRUE;
        }
        else if(GetHasFeat(nFeat, oCaster))
        {
            bAllowCast = TRUE;
            DecrementRemainingFeatUses(oCaster, nFeat);
        }

        if(bAllowCast)
        {
            RemoveSpellBuff(oCaster, oCaster, nSpell);
            AssignCommand(oCaster, NWNX_Creature_DoItemCastSpell(oCaster, oCaster, GetLocation(oCaster), nSpell, nCasterLevel, 0.0));
            ShowSpellCastMessage(oCaster, nSpell, EVENT_TYPE_ON_CAST_SPELL);
        }
    }
}

int divbuffer_DecrementSpellUses(object oCaster, int nSpellID, int nMeta, int nDomain, int nClass)
{
    int nSpellLevel;
    int nSpellIndex;
    for(nSpellLevel = 0; nSpellLevel <= 9; nSpellLevel++)
    {
        int nSpellSlotsPerSpellLevel = GetMemorizedSpellCountByLevel(oCaster, nClass, nSpellLevel);
        if(!nSpellSlotsPerSpellLevel)
            continue;
        for(nSpellIndex = 0; nSpellIndex < nSpellSlotsPerSpellLevel; nSpellIndex++)
        {
            int nMemorizedSpellId = GetMemorizedSpellId(oCaster, nClass, nSpellLevel, nSpellIndex);
            if(nMemorizedSpellId >= 0)  // if no memorised spell nMemorizedSpellId == -1
            {
                int nMemorizedMeta = GetMemorizedSpellMetaMagic(oCaster, nClass, nSpellLevel, nSpellIndex);
                int nMemorizedDomain = GetMemorizedSpellIsDomainSpell(oCaster, nClass, nSpellLevel, nSpellIndex);
                int nMemorizedReady = GetMemorizedSpellReady(oCaster, nClass, nSpellLevel, nSpellIndex);
                if(nMemorizedReady > 0      &&  nMemorizedSpellId == nSpellID  &&
                   nMemorizedMeta == nMeta  &&  nMemorizedDomain == nDomain)
                {
                    SetMemorizedSpell(oCaster, nClass, nSpellLevel, nSpellIndex, nMemorizedSpellId, FALSE, nMemorizedMeta, nMemorizedDomain);
                    return TRUE;
                }
            }
        }
    }
    return FALSE;
}

int divbuffer_GetIsWhiteListSpell(int nSpellID)
{
    struct sStringTokenizer stSpellWhiteListArrayTok = GetStringTokenizer(sSpellsWhiteListArray, "|");
    while(HasMoreTokens(stSpellWhiteListArrayTok))
    {
        stSpellWhiteListArrayTok = AdvanceToNextToken(stSpellWhiteListArrayTok);
        string sToken = GetNextToken(stSpellWhiteListArrayTok);
        if(StringToInt(sToken) == nSpellID)
            return TRUE;
    }
    return FALSE;
}

string divbuffer_GetMetaMagicName(int nMeta)
{
    switch(nMeta)
    {
        case METAMAGIC_EMPOWER:  return "Empower";
        case METAMAGIC_EXTEND:   return "Extend";
        case METAMAGIC_MAXIMIZE: return "Maximize";
        case METAMAGIC_QUICKEN:  return "Quicken";
        case METAMAGIC_SILENT:   return "Silent";
        case METAMAGIC_STILL:    return "Still";
        case METAMAGIC_ANY:
        case METAMAGIC_NONE:     return "";
    }
    return "";
}

int divbuffer_GetSpellLimit(object oPC)
{
    return DIVINE_BUFFER_BASE_SPELLS_NUMBER + divbuffer_GetBonusSpellsNumber(oPC);
}

string divbuffer_GetSavedSpellsString(object oDivineBuffer)
{
    string sResult = "";
    string sStoredSpells = GetLocalString(oDivineBuffer, "DIVINE_BUFFER_STORED_SPELLS_ARRAY");
    struct sStringTokenizer stSpellArrayTok = GetStringTokenizer(sStoredSpells, "|");
    while(HasMoreTokens(stSpellArrayTok))
    {
        if(sResult != "")
            sResult += ", ";
        stSpellArrayTok = AdvanceToNextToken(stSpellArrayTok);
        string sToken = GetNextToken(stSpellArrayTok);
        int nSpell = StringToInt(GetTokenByPosition(sToken, "_", 0));
        int nMeta = StringToInt(GetTokenByPosition(sToken, "_", 1));
        string sTmp = ColorText(GetSpellNameFromID(nSpell), TXT_COLOR_GREEN_L);
        string sMeta = divbuffer_GetMetaMagicName(nMeta);
        if(sMeta != "")
            sTmp = ColorText(sMeta, TXT_COLOR_GREEN_L) + " " + sTmp;
        sResult += sTmp;
    }
    if(sResult == "")
        sResult = ColorText("No saved spells", TXT_COLOR_RED);
    return sResult;
}

string divbuffer_GetAvailableSpellsString()
{
    string sResult = "";
    struct sStringTokenizer stSpellArrayTok = GetStringTokenizer(sSpellsWhiteListArray, "|");
    while(HasMoreTokens(stSpellArrayTok))
    {
        if(sResult != "")
            sResult += ", ";
        stSpellArrayTok = AdvanceToNextToken(stSpellArrayTok);
        string sToken = GetNextToken(stSpellArrayTok);
        int nSpell = StringToInt(sToken);
        sResult += ColorText(GetSpellNameFromID(nSpell), TXT_COLOR_GRAY);
    }
    return sResult;
}

int divbuffer_GetBonusSpellsNumber(object oPC)
{
    int iPlayerID = players_GetPCPersistentID(oPC);
    string sSQL = "SELECT divbuffer_bonus FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    return 0;
}

//void main(){}



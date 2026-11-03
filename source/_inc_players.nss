#include "_inc_constants"
#include "_inc_colortext"
#include "_inc_log"
#include "nwnx_object"
#include "nwnx_util"
#include "nwnx_sql"
#include "x3_inc_skin"
#include "nwnx_creature"

///////////////////////////////////////////////////////////////////
//////////                constants                      //////////
///////////////////////////////////////////////////////////////////

const int FACTION_SLOT_SORCERER             = 1;
const int FACTION_SLOT_PALEMASTER           = 2;
const int FACTION_SLOT_ARCANE_ARCHER        = 3;
const int FACTION_SLOT_PURPLE_DRAGON_KNIGHT = 4;
const int FACTION_SLOT_DWARVEN_DEFENDER     = 5;
const int FACTION_SLOT_DRUID                = 6;
const int FACTION_SLOT_CLERIC               = 7;
const int FACTION_SLOT_SUPPORT              = 8;
const int FACTION_SLOT_RDD_30               = 9;
const int FACTION_SLOT_MONK                 = 10;

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// returns TRUE if character has test flag
int players_IsTestCharacter(object oPC);

// returns TRUE if character is abyss
int players_InAbyss(object oPC);

// returns TRUE if two objects in same faction
// (local int "FACTION")
int players_GetFactionsEqual(object oPC1, object oPC2);

// returns faction id
int players_GetFaction(object oObject);

// set faction id
void players_SetFaction(object oObject, int nFaction);

// returns player's faction name (colorized or without color tag)
string players_GetFactionName(int iFaction, int bColorized = TRUE);

// returns player's faction color
string players_GetFactionColor(int iFaction);

// returns player ID
int players_GetPCPersistentID(object oPC);

// returns TRUE if name is valid
int players_GetIsCharNameValid(object oPC);

// returns slot ID for limited build
int players_GetIsLimitedBuild(object oPC);

// returns support slot ID if build matchs criterias
int players_GetIsSupport(object oPC);

// returns TRUE if there is players of different factions in oTriggerArea and oDestinationArea
int players_GetHasEnemyPlayersInRelatedAreas(object oTriggerArea, object oDestinationArea);

// returns faction creature from system area
object players_GetFactionSystemNPC(int iFaction);

// returns system NPC for cashed spell DC
object players_GetSpellIDsCashNPC();

// returns faction stargate, nId in range (1, 2, 3)
object players_GetFactionStargate(int nFaction, int nId);

// return location of faction castle entrance
object players_GetFactionEntryPoint(int nFaction);

// return FALSE if oPC has unknown faction/neutral alignment
int players_GetIsFactionAndAlignmentValid(object oPC);

// updates XP bar in NUI command menu
void players_UpdateXpBar(object oPC);

// returns TRUE if factions is enabled in module settings
// also returns TRUE for non faction areas
int players_GetIsFactionEnabled(int iFaction);

// copy all local vars from oSource to oTarget
void players_CopyVars(object oSource, object oTarget);

// get cupped +20 saving throw value. GetFortitudeSavingThrow func etc
// return value dont cupped by 20 limit
int players_GetRealSavingThrowValue(object oPC, int nSave);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int players_IsTestCharacter(object oPC)
{
    return (FindSubString(GetStringLowerCase(GetName(oPC)), "[test]") != -1);
}

int players_InAbyss(object oPC)
{
    if (GetResRef(GetArea(oPC)) == CONST_AREA_ABYSS_RESREF)
        return TRUE;
    return FALSE;
}

int players_GetFactionsEqual(object oPC1, object oPC2)
{
    return players_GetFaction(oPC1) == players_GetFaction(oPC2);
}

int players_GetFaction(object oObject)
{
    int iObjectType = GetObjectType(oObject);
    if(iObjectType == OBJECT_TYPE_CREATURE)
    {
        if(GetIsPC(oObject) && !players_IsTestCharacter(oObject))
        {
            int iFaction = GetLocalInt(oObject, "FACTION");
            if(iFaction != FACTION_UNKNOWN)
                return iFaction;
            int iPlayerID = players_GetPCPersistentID(oObject);
            if(iPlayerID > 0)
            {
                string sQuery = "SELECT faction FROM characters WHERE id = ?";
                NWNX_SQL_PrepareQuery(sQuery);
                NWNX_SQL_PreparedInt(0, iPlayerID);
                NWNX_SQL_ExecutePreparedQuery();
                if(NWNX_SQL_ReadyToReadNextRow())
                {
                    NWNX_SQL_ReadNextRow();
                    int iResult = StringToInt(NWNX_SQL_ReadDataInActiveRow());
                    SetLocalInt(oObject, "FACTION", iResult);
                    return iResult;
                }
            }
        }
        else if(GetLocalInt(oObject, "FACTION") != FACTION_UNKNOWN)
            return GetLocalInt(oObject, "FACTION");
        else
        {
            if(GetFactionEqual(oObject, players_GetFactionSystemNPC(FACTION_EMPIRE)))       return FACTION_EMPIRE;
            if(GetFactionEqual(oObject, players_GetFactionSystemNPC(FACTION_UNDERDARK)))    return FACTION_UNDERDARK;
            if(GetFactionEqual(oObject, players_GetFactionSystemNPC(FACTION_IRON_THRONE)))  return FACTION_IRON_THRONE;
            if(GetFactionEqual(oObject, players_GetFactionSystemNPC(FACTION_DRAGON_CULT)))  return FACTION_DRAGON_CULT;
        }

    }
    else
        return GetLocalInt(oObject, "FACTION");

    return FACTION_UNKNOWN;
}

void players_SetFaction(object oObject, int nFaction)
{
    SetLocalInt(oObject, "FACTION", nFaction);
}

string players_GetFactionName(int iFaction, int bColorized = TRUE)
{
    string sResult;
    string sColorStart;
    string sColorEnd;
    if(bColorized)
    {
        sColorStart = players_GetFactionColor(iFaction);
        sColorEnd = TXT_COLOR_END;
    }
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    string sFactionName = GetLocalString(oFactionCashObject, "FACTION_NAME");
    if(sFactionName == "")
    {
        string sSQL = "SELECT name FROM factions WHERE id = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, iFaction);
        NWNX_SQL_ExecutePreparedQuery();
        if(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            sFactionName = NWNX_SQL_ReadDataInActiveRow();
        }
        else
            sFactionName = "(Unknown)";
        SetLocalString(oFactionCashObject, "FACTION_NAME", sFactionName);
    }
    sResult = sColorStart + sFactionName + sColorEnd;
    return sResult;
}

string players_GetFactionColor(int iFaction)
{
    string sColor = TXT_COLOR_NONE;
    switch(iFaction)
    {
        case FACTION_EMPIRE:
            sColor = FACTION_COLOR_EMPIRE;
        break;
        case FACTION_UNDERDARK:
            sColor = FACTION_COLOR_UNDERDARK;
        break;
        case FACTION_IRON_THRONE:
            sColor = FACTION_COLOR_IRON_THRONE;
        break;
        case FACTION_DRAGON_CULT:
            sColor = FACTION_COLOR_DRAGON_CULT;
        break;
        case FACTION_UNKNOWN:
            sColor = TXT_COLOR_NONE;
        break;
    }
    return sColor;
}

int players_GetPCPersistentID(object oPC)
{
    if (!GetIsPC(oPC) || GetIsDM(oPC))
        return FALSE;
    int iResult = GetSkinInt(oPC, CONST_PLAYER_ID);
    if(!iResult)
        WriteLog("Function players_GetPCPersistentID() returns 0. " + "'" + GetName(oPC) + "'" + " is new character?" , LOG_LEVEL_ERROR);
    return iResult;
}

int players_GetIsCharNameValid(object oPC)
{
    string sCharName = NWNX_Util_StripColors(GetName(oPC));
    // check for allowed symbols
    string sRegexMainCheck = "[^a-zA-Z0-9_ '*\\[\\]]";  // not letters, digits + spaces + ' + * + [ + ] + _
    //json jMatchMainCheck = NWNX_Regex_Match(sCharName, sRegexMainCheck); deprecated
    json jMatchMainCheck = RegExpIterate(sRegexMainCheck, sCharName);

    int nLenMainCheck = JsonGetLength(jMatchMainCheck);
    string sInvalidCharacterList = "";
    int i;
    for (i = 0; i < nLenMainCheck; i++)
    {
        json jSubArray = JsonArrayGet(jMatchMainCheck, i);
        json jValue = JsonArrayGet(jSubArray, 0);
        string sValue = JsonGetString(jValue);
        sInvalidCharacterList += ColorText(sValue, TXT_COLOR_RED);
        if(i < nLenMainCheck - 1)
            sInvalidCharacterList += ", ";
    }
    if(GetStringLength(sInvalidCharacterList) > 0)
    {
        string sMessage = "Your name is incorrect. Don't use this symbol(s): " + sInvalidCharacterList + ".";
        SendMessageToPC(oPC, sMessage);
        return FALSE;
    }
    // check for spaces and underscores
    string sRegexSpacesAndUnderscores = "[\\s _]+";
    //json jMatchSpacesAndUnderscores = NWNX_Regex_Match(sCharName, sRegexSpacesAndUnderscores); deprecated
    json jMatchSpacesAndUnderscores = RegExpIterate(sRegexSpacesAndUnderscores, sCharName);
    int nLenSpacesAndUnderscores = JsonGetLength(jMatchSpacesAndUnderscores);
    for (i = 0; i < nLenSpacesAndUnderscores; i++)
    {
        json jSubArray = JsonArrayGet(jMatchSpacesAndUnderscores, i);
        json jValue = JsonArrayGet(jSubArray, 0);
        string sValue = JsonGetString(jValue);
        if(GetStringLength(sValue) > 1)
        {
            string sMessage = "Sequences of spaces and underscores longer than one are not allowed.";
            SendMessageToPC(oPC, sMessage);
            return FALSE;
        }
    }
    // check for dumb shot names
    string sRegexTwoLetters = "[a-zA-Z]+";
    //json jMatchTwoLetters = NWNX_Regex_Match(sCharName, sRegexTwoLetters); deprecated
    json jMatchTwoLetters = RegExpIterate(sRegexTwoLetters, sCharName);
    int nLenTwoLetters = JsonGetLength(jMatchTwoLetters);
    int bMoreTwoLetters = FALSE;
    for (i = 0; i < nLenTwoLetters; i++)
    {
        json jSubArray = JsonArrayGet(jMatchTwoLetters, i);
        json jValue = JsonArrayGet(jSubArray, 0);
        string sValue = JsonGetString(jValue);
        if(GetStringLength(sValue) > 1)
        {
            bMoreTwoLetters = TRUE;
            break;
        }
    }
    if(!bMoreTwoLetters)
    {
        SendMessageToPC(oPC, "Names containing sequences of letters less than two are not allowed.");
        return FALSE;
    }
    return TRUE;
}

int players_GetIsLimitedBuild(object oPC)
{
    if (GetLevelByClass(CLASS_TYPE_SORCERER, oPC))
        return FACTION_SLOT_SORCERER;
    if (GetLevelByClass(CLASS_TYPE_PALEMASTER, oPC))
        return FACTION_SLOT_PALEMASTER;
    if (GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oPC))
        return FACTION_SLOT_ARCANE_ARCHER;
    if (GetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT, oPC))
        return FACTION_SLOT_PURPLE_DRAGON_KNIGHT;
    if (GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oPC))
        return FACTION_SLOT_DWARVEN_DEFENDER;
    if (GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oPC) >= 30)
        return FACTION_SLOT_RDD_30;
    if (GetLevelByClass(CLASS_TYPE_DRUID, oPC) >= 30)
        return FACTION_SLOT_DRUID;
    if (GetLevelByClass(CLASS_TYPE_MONK, oPC) >= 35)
        return FACTION_SLOT_MONK;
    // return zero if player's build has no faction slots/limits
    return 0;
}

int players_GetIsSupport(object oPC)
{
    if (GetLevelByClass(CLASS_TYPE_CLERIC, oPC) >= 30    ||
        GetLevelByClass(CLASS_TYPE_BARD, oPC)   >  20    ||
        GetLevelByClass(CLASS_TYPE_DRUID, oPC)  >= 30    ||
        GetLevelByClass(CLASS_TYPE_SORCERER, oPC) > 1)
        return FACTION_SLOT_SUPPORT;
    return 0;
}

int players_GetHasEnemyPlayersInRelatedAreas(object oTriggerArea, object oDestinationArea)
{
    int iEmpire     = GetLocalInt(oTriggerArea,     "FACTION_" + IntToString(FACTION_EMPIRE)      + "_PLAYERS_COUNT") +
                      GetLocalInt(oDestinationArea, "FACTION_" + IntToString(FACTION_EMPIRE)      + "_PLAYERS_COUNT");
    int iUnderdark  = GetLocalInt(oTriggerArea,     "FACTION_" + IntToString(FACTION_UNDERDARK)   + "_PLAYERS_COUNT") +
                      GetLocalInt(oDestinationArea, "FACTION_" + IntToString(FACTION_UNDERDARK)   + "_PLAYERS_COUNT");
    int iIronThrone = GetLocalInt(oTriggerArea,     "FACTION_" + IntToString(FACTION_IRON_THRONE) + "_PLAYERS_COUNT") +
                      GetLocalInt(oDestinationArea, "FACTION_" + IntToString(FACTION_IRON_THRONE) + "_PLAYERS_COUNT");
    int iDragonCult = GetLocalInt(oTriggerArea,     "FACTION_" + IntToString(FACTION_DRAGON_CULT) + "_PLAYERS_COUNT") +
                      GetLocalInt(oDestinationArea, "FACTION_" + IntToString(FACTION_DRAGON_CULT) + "_PLAYERS_COUNT");

    return (iEmpire > 0) + (iUnderdark > 0) + (iIronThrone > 0) + (iDragonCult > 0) > 1;
}

object players_GetFactionSystemNPC(int iFaction)
{
    string sCashVar = "FACTION_" + IntToString(iFaction) + "_SYSTEM_NPC";
    object oResult = GetLocalObject(GetModule(), sCashVar);
    if(GetIsObjectValid(oResult))
        return oResult;
    switch(iFaction)
    {
        case FACTION_EMPIRE:      oResult = GetObjectByTag("member_empire");      break;
        case FACTION_UNDERDARK:   oResult = GetObjectByTag("member_underdark");   break;
        case FACTION_IRON_THRONE: oResult = GetObjectByTag("member_iron_throne"); break;
        case FACTION_DRAGON_CULT: oResult = GetObjectByTag("member_dragon_cult"); break;
    }
    SetLocalObject(GetModule(), sCashVar, oResult);
    return oResult;
}

object players_GetSpellIDsCashNPC()
{
    string sCashVar = "SPELL_ID_CASH_SYSTEM";
    object oResult = GetLocalObject(GetModule(), sCashVar);
    if(GetIsObjectValid(oResult))
        return oResult;
    oResult = GetObjectByTag("spell_id_cash_system");
    SetLocalObject(GetModule(), sCashVar, oResult);
    return oResult;
}

object players_GetFactionStargate(int nFaction, int nId)
{
    return GetObjectByTag("stargate" + IntToString(nId) + "_faction" + IntToString(nFaction));
}

object players_GetFactionEntryPoint(int nFaction)
{
    string sWPTag;
    switch(nFaction)
    {
        case FACTION_EMPIRE:
            sWPTag = "startNCR";
        break;
        case FACTION_UNDERDARK:
            sWPTag = "startKulg";
        break;
        case FACTION_IRON_THRONE:
            sWPTag = "startNewReno";
        break;
        case FACTION_DRAGON_CULT:
            sWPTag = "startDragon";
        break;
    }
    return GetWaypointByTag(sWPTag);
}

int players_GetIsFactionAndAlignmentValid(object oPC)
{
    int iFaction = players_GetFaction(oPC);
    if(iFaction == FACTION_UNKNOWN)
    {
        SendColorMessageToPC(oPC, "Your faction is not defined. Join discord, choose faction and get instructions from the team. " +
                                  "The server is focused on the team PvP. Trying to play solo will not give a pleasant experience. " +
                                  "Use these links: \n" +
                                  "http://cormyr.ru/ - wiki \n" +
                                  "https://discord.gg/UyGrdMb", TXT_COLOR_RED);
        return FALSE;
    }
    if (GetAlignmentGoodEvil(oPC) == ALIGNMENT_NEUTRAL)
    {
        FloatingColorTextStringOnCreature("You can't be neutral, only good or evil.",
                                          TXT_COLOR_RED, oPC, FALSE);
        return FALSE;
    }
    return TRUE;
}

void players_UpdateXpBar(object oPC)
{
    int nPlayerCmdToken = NuiFindWindow(oPC, CONST_CORMYR_NUI_CMD_MENU);
    if(nPlayerCmdToken)
    {
        int nPcLevel = GetHitDice(oPC);
        int nNextLevelXP = StringToInt(Get2DAString("exptable", "XP", nPcLevel));
        int nPreviousLevelXP = nPcLevel > 1 ? StringToInt(Get2DAString("exptable", "XP", nPcLevel - 1)) : 1;
        int nCurrentXP = GetXP(oPC);
        // bind progress bar visual
        float fXPToNextLevelPercent = nPcLevel < 40 ? IntToFloat(nCurrentXP - nPreviousLevelXP)/IntToFloat(nNextLevelXP - nPreviousLevelXP) : 1.0;
        fXPToNextLevelPercent = fXPToNextLevelPercent > 1.0 ? 1.0 : fXPToNextLevelPercent;
        NuiSetBind(oPC, nPlayerCmdToken, "cmd_progress_val", JsonFloat(fXPToNextLevelPercent));
        // bind progress bar tooltip
        string sXPToNextLevel = nPcLevel < 40 ? "XP to next level " + IntToString(nNextLevelXP - nCurrentXP > 0 ? nNextLevelXP - nCurrentXP : 0) :
                                                "You've reached the maximum level";
        NuiSetBind(oPC, nPlayerCmdToken, "cmd_progress_tt", JsonString(sXPToNextLevel));
    }
}

int players_GetIsFactionEnabled(int iFaction)
{
    if(!iFaction) return 1; // non faction areas must be enabled!
    object oFactionCashObject = players_GetFactionSystemNPC(iFaction);
    int bEnabled = GetLocalInt(oFactionCashObject, "ENABLED");
    if(bEnabled > 0)
        return bEnabled - 1;
    string sSQL = "SELECT enabled FROM factions WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iFaction);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        bEnabled = StringToInt(NWNX_SQL_ReadDataInActiveRow()) + 1;
        SetLocalInt(oFactionCashObject, "ENABLED", bEnabled);
        return bEnabled - 1;
    }
    return 0;
}

void players_CopyVars(object oSource, object oTarget)
{
    int iNumVars = NWNX_Object_GetLocalVariableCount(oSource);
    int i;
    for (i = 0; i < iNumVars; i++)
    {
        struct NWNX_Object_LocalVariable stLocalVar = NWNX_Object_GetLocalVariable(oSource, i);
        switch (stLocalVar.type)
        {
            case NWNX_OBJECT_LOCALVAR_TYPE_INT:
                SetLocalInt(oTarget, stLocalVar.key, GetLocalInt(oSource, stLocalVar.key));
                break;
            case NWNX_OBJECT_LOCALVAR_TYPE_FLOAT:
                SetLocalFloat(oTarget, stLocalVar.key, GetLocalFloat(oSource, stLocalVar.key));
                break;
            case NWNX_OBJECT_LOCALVAR_TYPE_STRING:
                SetLocalString(oTarget, stLocalVar.key, GetLocalString(oSource, stLocalVar.key));
                break;
            case NWNX_OBJECT_LOCALVAR_TYPE_OBJECT:
                SetLocalObject(oTarget, stLocalVar.key, GetLocalObject(oSource, stLocalVar.key));
                break;
            case NWNX_OBJECT_LOCALVAR_TYPE_LOCATION:
                SetLocalLocation(oTarget, stLocalVar.key, GetLocalLocation(oSource, stLocalVar.key));
                break;
            case NWNX_OBJECT_LOCALVAR_TYPE_JSON:
                SetLocalJson(oTarget, stLocalVar.key, GetLocalJson(oSource, stLocalVar.key));
                break;
        }
    }
}

int players_GetRealSavingThrowValue(object oPC, int nSave)
{
    int nOvercuppedSavingThrow;
    switch(nSave)
    {
        case SAVING_THROW_FORT:   nOvercuppedSavingThrow = GetFortitudeSavingThrow(oPC); break;
        case SAVING_THROW_REFLEX: nOvercuppedSavingThrow = GetReflexSavingThrow(oPC);    break;
        case SAVING_THROW_WILL:   nOvercuppedSavingThrow = GetWillSavingThrow(oPC);      break;
    }
    int nOvercup = NWNX_Creature_GetTotalEffectBonus(oPC, /*bonusType*/NWNX_CREATURE_BONUS_TYPE_SAVING_THROW,
                                                     /*target*/OBJECT_INVALID, /*isElemental*/0, /*isForceMax*/0,
                                                     /*savetype*/nSave, /*saveSpecificType*/-1, /*skill*/-1,
                                                     /*abilityScore*/-1, /*isOffhand*/FALSE);
    int nCorrection = nOvercup - 20;
    if(nCorrection > 0)
        return nOvercuppedSavingThrow - nCorrection;
    else
        return nOvercuppedSavingThrow;
}

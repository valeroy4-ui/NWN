#include "nwnx_creature"
#include "_inc_colortext"
#include "x0_i0_stringlib"
#include "_inc_array"
#include "nwnx_sql"

///////////////////////////////////////////////////////////////////
//////////                Constants                      //////////
///////////////////////////////////////////////////////////////////

/* table description
create table spellbooks(
    account varchar(64),
    slot TINYINT(3),
    spell_array text,
    name varchar(255),
    description varchar(255),
    primary key(account, slot)
); */

const int SPELLBOOK_MAX_SLOTS_NUMBER = 9;

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

//
void spellbook_SaveSpells(object oCaster, int nSlotNumber, string sDescription);

//
void spellbook_LoadSpells(object oCaster, int nSlotNumber);

//
void spellbook_ViewSavedSlots(object oCaster);

//
int spellbook_GetIsValidSlot(object oCaster, int nSlotNumber);

//
void spellbook_DeleteSpellSlot(object oCaster, int nSlotNumber);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void spellbook_SaveSpells(object oCaster, int nSlotNumber, string sDescription)
{
    if(!spellbook_GetIsValidSlot(oCaster, nSlotNumber))
        return;
    int nSpellLevel;
    int nSpellIndex;
    string sSpellArray = "";

    int iClassPosition;
    for(iClassPosition = 1; iClassPosition <= 3; iClassPosition++)
    {
        int nClass = GetClassByPosition(iClassPosition, oCaster);
        if(nClass == 255)
            break;
        for(nSpellLevel = 0; nSpellLevel <= 9; nSpellLevel++)
        {
            int nSpellSlotsPerSpellLevel = GetMemorizedSpellCountByLevel(oCaster, nClass, nSpellLevel);
            if(!nSpellSlotsPerSpellLevel)
                continue;
            for(nSpellIndex = 0; nSpellIndex < nSpellSlotsPerSpellLevel; nSpellIndex++)
            {
                int nSpellId = GetMemorizedSpellId(oCaster, nClass, nSpellLevel, nSpellIndex);
                if(nSpellId >= 0)  // if no memorised spell nSpellId == -1
                {
                    int nMeta = GetMemorizedSpellMetaMagic(oCaster, nClass, nSpellLevel, nSpellIndex);
                    int nDomain = GetMemorizedSpellIsDomainSpell(oCaster, nClass, nSpellLevel, nSpellIndex);
                    sSpellArray += IntToString(nSpellLevel) + "_" + IntToString(nSpellIndex) + "_" +
                                   IntToString(nSpellId) + "_" + IntToString(nMeta) + "_" +
                                   IntToString(nDomain) + "_" + IntToString(nClass) + "|";
                }
            }
        }
    }
    // insert/update into db
    string sAccount = GetPCPlayerName(oCaster);
    string sName = GetName(oCaster);
    string sSQL = "INSERT INTO spellbooks (account, slot, spell_array, `name`, description) " +
                  "VALUES (?, ?, ?, ?, ?) " +
                  "ON DUPLICATE KEY UPDATE spell_array = ?, `name` = ?, description = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_PreparedInt(1, nSlotNumber);
    NWNX_SQL_PreparedString(2, sSpellArray);
    NWNX_SQL_PreparedString(3, sName);
    NWNX_SQL_PreparedString(4, sDescription);
    NWNX_SQL_PreparedString(5, sSpellArray);
    NWNX_SQL_PreparedString(6, sName);
    NWNX_SQL_PreparedString(7, sDescription);
    if (NWNX_SQL_ExecutePreparedQuery())
    {
        SendColorMessageToPC(oCaster, "Spellbook successfully saved.", TXT_COLOR_GREEN_L);
    }
}

void spellbook_LoadSpells(object oCaster, int nSlotNumber)
{
    if(!spellbook_GetIsValidSlot(oCaster, nSlotNumber))
        return;
    string sAccount = GetPCPlayerName(oCaster);
    string sSQL = "SELECT spell_array FROM spellbooks WHERE account = ? and slot = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_PreparedInt(1, nSlotNumber);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        string sSpellArray = NWNX_SQL_ReadDataInActiveRow();
        if(sSpellArray != "")
        {
            struct sStringTokenizer stSpellDataTok = GetStringTokenizer(sSpellArray, "|");
            string sSpellArraySubData;
            while(HasMoreTokens(stSpellDataTok))
            {
                stSpellDataTok = AdvanceToNextToken(stSpellDataTok);
                sSpellArraySubData = GetNextToken(stSpellDataTok);
                int nSpellLevel = StringToInt(GetTokenByPosition(sSpellArraySubData, "_", 0));
                int nSpellIndex = StringToInt(GetTokenByPosition(sSpellArraySubData, "_", 1));
                int nSpellSpellID = StringToInt(GetTokenByPosition(sSpellArraySubData, "_", 2));
                int nSpellSpellMeta = StringToInt(GetTokenByPosition(sSpellArraySubData, "_", 3));
                int nSpellDomain = StringToInt(GetTokenByPosition(sSpellArraySubData, "_", 4));
                int nSpellClass = StringToInt(GetTokenByPosition(sSpellArraySubData, "_", 5));
                SetMemorizedSpell(oCaster, nSpellClass, nSpellLevel, nSpellIndex, nSpellSpellID, FALSE, nSpellSpellMeta, nSpellDomain);
            }
        }
        SendColorMessageToPC(oCaster, "Spellbook successfully loaded.", TXT_COLOR_GREEN_L);
    }
    else
        SendColorMessageToPC(oCaster, "The selected slot is empty.", TXT_COLOR_RED);
}

void spellbook_ViewSavedSlots(object oCaster)
{
    string sAccount = GetPCPlayerName(oCaster);
    string sSQL = "SELECT slot, `name`, description FROM spellbooks WHERE account = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    Array_Clear("ARRAY_PLAYER_SPELLBOOKS_SLOT", oCaster);
    Array_Clear("ARRAY_PLAYER_SPELLBOOKS_NAME", oCaster);
    Array_Clear("ARRAY_PLAYER_SPELLBOOKS_DESCRIPTION", oCaster);
    while (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        Array_PushBack_Int("ARRAY_PLAYER_SPELLBOOKS_SLOT", StringToInt(NWNX_SQL_ReadDataInActiveRow(0)), oCaster);
        Array_PushBack_Str("ARRAY_PLAYER_SPELLBOOKS_NAME", NWNX_SQL_ReadDataInActiveRow(1), oCaster);
        Array_PushBack_Str("ARRAY_PLAYER_SPELLBOOKS_DESCRIPTION", NWNX_SQL_ReadDataInActiveRow(2), oCaster);
    }
    string sList = "\n             Spellbook slots:\n";
    int i;
    for (i = 1 ; i <= SPELLBOOK_MAX_SLOTS_NUMBER; i++)
    {
        int iFoundIndex = Array_Find_Int("ARRAY_PLAYER_SPELLBOOKS_SLOT", i, oCaster);
        if (iFoundIndex != INVALID_INDEX)
        {
            string sSlotName = Array_At_Str("ARRAY_PLAYER_SPELLBOOKS_NAME", iFoundIndex, oCaster);
            sList += IntToString(i) + ". " + ColorText(sSlotName, TXT_COLOR_RED);
            string sSlotDescription = Array_At_Str("ARRAY_PLAYER_SPELLBOOKS_DESCRIPTION", iFoundIndex, oCaster);
            if(sSlotDescription != "")
                sList += ColorText(" [" + sSlotDescription + "]", TXT_COLOR_WHITE_T);
        }
        else
            sList += IntToString(i) + ". " + ColorText("empty", TXT_COLOR_GREEN_L);
        sList += "\n";
    }
    SendMessageToPC(oCaster, sList);
}

int spellbook_GetIsValidSlot(object oCaster, int nSlotNumber)
{
    if (nSlotNumber <= 0 || nSlotNumber > SPELLBOOK_MAX_SLOTS_NUMBER)
    {
        SendColorMessageToPC(oCaster, "You've entered incorrect slot number. Must be in the range of 1 to 9.", TXT_COLOR_RED);
        return FALSE;
    }
    return TRUE;
}

void spellbook_DeleteSpellSlot(object oCaster, int nSlotNumber)
{
    if(!spellbook_GetIsValidSlot(oCaster, nSlotNumber))
        return;
    string sAccount = GetPCPlayerName(oCaster);
    string sSQL = "DELETE from spellbooks WHERE account = ? and slot = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_PreparedInt(1, nSlotNumber);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_GetAffectedRows())
        SendColorMessageToPC(oCaster, "The selected slot has been successfully cleared.", TXT_COLOR_GREEN_L);
    else
        SendColorMessageToPC(oCaster, "The selected slot is already empty.", TXT_COLOR_RED);
}



//void main() {}

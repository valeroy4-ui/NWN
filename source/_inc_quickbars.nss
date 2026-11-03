#include "nwnx_sql"
#include "nwnx_creature"
#include "_inc_colortext"
#include "_inc_array"

///////////////////////////////////////////////////////////////////
//////////                Constants                      //////////
///////////////////////////////////////////////////////////////////

/* table description
create table quickbars(
    account varchar(64),
    slot TINYINT(3),
    quickbar text,
    name varchar(255),
    description varchar(255),
    primary key(account, slot)
); */

const int QUICKBARS_MAX_SLOTS_NUMBER = 9;


///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////


//
void quickbars_SaveQuickbar(object oPC, int nSlot, string sDescription);

//
void quickbars_LoadQuickbar(object oPC, int nSlot);

//
void quickbars_ViewQuickbars(object oPC);

//
int quickbars_GetIsValidSlot(object oPC, int nSlotNumber);

//
void quickbars_DeleteQuickbarSlot(object oCaster, int nSlotNumber);


///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void quickbars_SaveQuickbar(object oPC, int nSlot, string sDescription)
{
    if (!quickbars_GetIsValidSlot(oPC, nSlot))
        return;
    string sAccount = GetPCPlayerName(oPC);
    string sName = GetName(oPC);
    string sQuickbar = NWNX_Creature_SerializeQuickbar(oPC);
    string sSQL = "INSERT INTO quickbars (account, slot, quickbar, `name`, description) " +
                  "VALUES (?, ?, ?, ?, ?) " +
                  "ON DUPLICATE KEY UPDATE quickbar = ?, `name` = ?, description = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_PreparedInt(1, nSlot);
    NWNX_SQL_PreparedString(2, sQuickbar);
    NWNX_SQL_PreparedString(3, sName);
    NWNX_SQL_PreparedString(4, sDescription);
    NWNX_SQL_PreparedString(5, sQuickbar);
    NWNX_SQL_PreparedString(6, sName);
    NWNX_SQL_PreparedString(7, sDescription);
    if (NWNX_SQL_ExecutePreparedQuery())
    {
        SendColorMessageToPC(oPC, "Quickbar successfully saved.", TXT_COLOR_GREEN_L);
    }
}

void quickbars_LoadQuickbar(object oPC, int nSlot)
{
    if (!quickbars_GetIsValidSlot(oPC, nSlot))
        return;
    string sAccount = GetPCPlayerName(oPC);
    string sSQL = "SELECT quickbar FROM quickbars WHERE account = ? and slot = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_PreparedInt(1, nSlot);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        NWNX_Creature_DeserializeQuickbar(oPC, NWNX_SQL_ReadDataInActiveRow());
        SendColorMessageToPC(oPC, "Quickbar successfully loaded.", TXT_COLOR_GREEN_L);
    }
    else
    {
        SendColorMessageToPC(oPC, "The selected slot is empty.", TXT_COLOR_RED);
    }
}

void quickbars_ViewQuickbars(object oPC)
{
    string sAccount = GetPCPlayerName(oPC);
    string sSQL = "SELECT slot, `name`, description FROM quickbars WHERE account = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    Array_Clear("ARRAY_PLAYER_QUICKBARS_SLOT", oPC);
    Array_Clear("ARRAY_PLAYER_QUICKBARS_NAME", oPC);
    Array_Clear("ARRAY_PLAYER_QUICKBARS_DESCRIPTION", oPC);
    while (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        Array_PushBack_Int("ARRAY_PLAYER_QUICKBARS_SLOT", StringToInt(NWNX_SQL_ReadDataInActiveRow(0)), oPC);
        Array_PushBack_Str("ARRAY_PLAYER_QUICKBARS_NAME", NWNX_SQL_ReadDataInActiveRow(1), oPC);
        Array_PushBack_Str("ARRAY_PLAYER_QUICKBARS_DESCRIPTION", NWNX_SQL_ReadDataInActiveRow(2), oPC);
    }
    string sList = "\n             Quickbars slots:\n";
    int i;
    for (i = 1 ; i <= QUICKBARS_MAX_SLOTS_NUMBER; i++)
    {
        int iFoundIndex = Array_Find_Int("ARRAY_PLAYER_QUICKBARS_SLOT", i, oPC);
        if (iFoundIndex != INVALID_INDEX)
        {
            string sSlotName = Array_At_Str("ARRAY_PLAYER_QUICKBARS_NAME", iFoundIndex, oPC);
            sList += IntToString(i) + ". " + ColorText(sSlotName, TXT_COLOR_RED);
            string sSlotDescription = Array_At_Str("ARRAY_PLAYER_QUICKBARS_DESCRIPTION", iFoundIndex, oPC);
            if(sSlotDescription != "")
                sList += ColorText(" [" + sSlotDescription + "]", TXT_COLOR_WHITE_T);

        }
        else
        {
            sList += IntToString(i) + ". " + ColorText("empty", TXT_COLOR_GREEN_L);
        }
        sList += "\n";
    }
    SendMessageToPC(oPC, sList);
}

int quickbars_GetIsValidSlot(object oPC, int nSlotNumber)
{
    if (nSlotNumber <= 0 || nSlotNumber > QUICKBARS_MAX_SLOTS_NUMBER)
    {
        SendColorMessageToPC(oPC, "You've entered incorrect slot number. Must be in the range of 1 to 9.", TXT_COLOR_RED);
        return FALSE;
    }
    return TRUE;
}

void quickbars_DeleteQuickbarSlot(object oCaster, int nSlotNumber)
{
    if(!quickbars_GetIsValidSlot(oCaster, nSlotNumber))
        return;
    string sAccount = GetPCPlayerName(oCaster);
    string sSQL = "DELETE from quickbars WHERE account = ? and slot = ?";
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

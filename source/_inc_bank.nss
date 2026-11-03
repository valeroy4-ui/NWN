#include "nwnx_sql"
#include "nwnx_player"
#include "_inc_colortext"
#include "_inc_constants"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

const string BANK_DEPOSIT_CASH      = "BANK_DEPOSIT_CASH";

const int BANK_ACTION_TYPE_DEPOSIT  = 1;
const int BANK_ACTION_TYPE_CASH_OUT = 2;
const int BANK_ACTION_TYPE_PREPARE  = 3;
const int BANK_ACTION_TYPE_UPDATE   = 4;

//
void bank_DepositMoney(object oPC, int iValue);

//
void bank_CashOutMoney(object oPC, int iValue);

//
int bank_GetAccountBalance(object oPC);

//
void bank_SetAccountBalance(object oPC, int iValue);

//
void bank_IncrementAccountBalance(object oPC, int iValue, int bShowNotificationToPC = TRUE);

//
void bank_DecrementAccountBalance(object oPC, int iValue, int bShowNotificationToPC = TRUE);

//
void bank_SendNotificationToPC(object oPC, int iValue);

//
void bank_UpdateBalanceToken(object oPC);

//
string bank_FormatOutputValue(string sValue);

//
string bank_ReverseString(string sValue);


///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void bank_DepositMoney(object oPC, int iValue)
{
    if (iValue > 0)
    {
        int iPcGold = GetGold(oPC);
        if (iPcGold > 0)
        {
            if (iValue > iPcGold) iValue = iPcGold;
            TakeGoldFromCreature(iValue, oPC, TRUE);
            bank_IncrementAccountBalance(oPC, iValue);
        }
        else
        {
            SendColorMessageToPC(oPC, "You have no money.", TXT_COLOR_RED);
        }
    }
    else
    {
        SendColorMessageToPC(oPC, "You entered incorrect number or this number is too long.", TXT_COLOR_RED);
    }
}

void bank_CashOutMoney(object oPC, int iValue)
{
    if (iValue > 0)
    {
        int iDepositValue = bank_GetAccountBalance(oPC);
        if (iValue > iDepositValue) iValue = iDepositValue;
        bank_DecrementAccountBalance(oPC, iValue);
        GiveGoldToCreature(oPC, iValue);
    }
    else
        SendColorMessageToPC(oPC, "You entered incorrect number or this number is too long.", TXT_COLOR_RED);
}

int bank_GetAccountBalance(object oPC)
{
    int nResult = GetLocalInt(oPC, BANK_DEPOSIT_CASH);
    if(nResult)
        return nResult > 0 ? nResult : 0;

    string sAccount = GetPCPlayerName(oPC);
    string sSQL = "SELECT gold_deposit FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nResult = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    if(nResult > 0)
        SetLocalInt(oPC, BANK_DEPOSIT_CASH, nResult);
    else
        SetLocalInt(oPC, BANK_DEPOSIT_CASH, -1);

    return nResult;
}

void bank_SetAccountBalance(object oPC, int iValue)
{
    DeleteLocalInt(oPC, BANK_DEPOSIT_CASH);
    string sAccount = GetPCPlayerName(oPC);
    string sSQL = "UPDATE players SET gold_deposit = ? WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedString(1, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    SetLocalInt(oPC, BANK_DEPOSIT_CASH, iValue);
}

void bank_IncrementAccountBalance(object oPC, int iValue, int bShowNotificationToPC = TRUE)
{
    string sAccount = GetPCPlayerName(oPC);
    int iDepositValue = bank_GetAccountBalance(oPC);
    bank_SetAccountBalance(oPC, iDepositValue + iValue);
    if (bShowNotificationToPC)
        DelayCommand(0.25, bank_SendNotificationToPC(oPC, iValue));
}

void bank_DecrementAccountBalance(object oPC, int iValue, int bShowNotificationToPC = TRUE)
{
    string sAccount = GetPCPlayerName(oPC);
    int iDepositValue = bank_GetAccountBalance(oPC);
    if (iDepositValue - iValue >= 0)
        bank_SetAccountBalance(oPC, iDepositValue - iValue);
    if (bShowNotificationToPC)
        DelayCommand(0.25, bank_SendNotificationToPC(oPC, - iValue));
}

void bank_SendNotificationToPC(object oPC, int iValue)
{
    string sNotification;

    if      (iValue > 0)
        sNotification += ColorText("+" + bank_FormatOutputValue(IntToString(iValue)), TXT_COLOR_GREEN_L) + " to deposit. ";
    else if (iValue < 0)
        sNotification += ColorText("-" + bank_FormatOutputValue(IntToString(abs(iValue))), TXT_COLOR_RED) +
                         " from deposit. ";
    else
        sNotification += "Zero transaction. ";

    sNotification += "Your current balance: " + ColorText(bank_FormatOutputValue(IntToString(bank_GetAccountBalance(oPC))), TXT_COLOR_GREEN_L) + ".";
    SendMessageToPC(oPC, sNotification);
}

void bank_UpdateBalanceToken(object oPC)
{
    NWNX_Player_SetCustomToken(oPC, CORMYR_CUSTOM_TOKEN_BANK, ColorText(bank_FormatOutputValue(IntToString(bank_GetAccountBalance(oPC))), TXT_COLOR_GREEN_L));
}

string bank_FormatOutputValue(string sValue)
{
    string sResult = "";
    int iLength = GetStringLength(sValue);
    int i;
    int iCoint;
    for (i = 0; i <= iLength; i++)
    {
        sResult += GetSubString(sValue, iLength - i, 1);
        if (i > 0 && i < iLength && i % 3 == 0)
            sResult += ",";
    }
    sResult = bank_ReverseString(sResult);

    return sResult;
}

string bank_ReverseString(string sValue)
{
    int iLength = GetStringLength(sValue);
    if (iLength < 2) return sValue;
    int i;
    string sResult = "";
    for (i = 0; i <= iLength; i++)
    {
        sResult += GetSubString(sValue, iLength - i, 1);
    }
    return sResult;
}

//void main() {}

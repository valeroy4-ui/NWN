#include "_inc_bank"

void main()
{
    object oPC = GetPCSpeaker();
    int iActionType = StringToInt(GetScriptParam("ACTION_TYPE"));
    switch (iActionType)
    {
        case BANK_ACTION_TYPE_DEPOSIT:
            bank_DepositMoney(oPC, StringToInt(GetLocalString(oPC, "LAST_CHAT_MESSAGE")));
        break;
        case BANK_ACTION_TYPE_CASH_OUT:
            bank_CashOutMoney(oPC, StringToInt(GetLocalString(oPC, "LAST_CHAT_MESSAGE")));
        break;
        case BANK_ACTION_TYPE_PREPARE:
            DeleteLocalString(oPC, "LAST_CHAT_MESSAGE");
        break;
        case BANK_ACTION_TYPE_UPDATE:
            bank_UpdateBalanceToken(oPC);
        break;
        default: return;
    }
}

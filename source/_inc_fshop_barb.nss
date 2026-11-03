#include "_inc_fameshop"

///////////////////////////////////////////////////////////////////
//////////                  Prototypes                   //////////
///////////////////////////////////////////////////////////////////

void RefreshTokensForBarbarianRage(object oPC);

int TryToBuyRageInterval(object oPC, int iWantedBonusLevel, int iRequiredBonusLevel, int iCost);

int TryToBuyRageDC(object oPC, int iWantedBonusLevel, int iRequiredBonusLevel, int iCost);

int GetRageBonusInterval(int iPlayerID);

int GetRageBonusDC(int iPlayerID);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void RefreshTokensForBarbarianRage(object oPC)
{
   int iPlayerID = players_GetPCPersistentID(oPC);

   int iRageBonusDC = GetRageBonusDC(iPlayerID);
   int iRageBonusInterval = GetRageBonusInterval(iPlayerID);
   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FREEFAME, IntToString(GetFreeFame(oPC)));

   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_DC_1, CONST_FAMESHOP_LOCKED);
   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_DC_2, CONST_FAMESHOP_LOCKED);
   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_DC_3, CONST_FAMESHOP_LOCKED);
   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_DC_4, CONST_FAMESHOP_LOCKED);
   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_DC_5, CONST_FAMESHOP_LOCKED);

   if(iRageBonusDC >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_DC_1, CONST_FAMESHOP_UNLOCKED);
   if(iRageBonusDC >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_DC_2, CONST_FAMESHOP_UNLOCKED);
   if(iRageBonusDC >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_DC_3, CONST_FAMESHOP_UNLOCKED);
   if(iRageBonusDC >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_DC_4, CONST_FAMESHOP_UNLOCKED);
   if(iRageBonusDC >= 5) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_DC_5, CONST_FAMESHOP_UNLOCKED);

   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_INTERVAL_1, CONST_FAMESHOP_LOCKED);
   NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_INTERVAL_2, CONST_FAMESHOP_LOCKED);
   if(iRageBonusInterval >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_INTERVAL_1, CONST_FAMESHOP_UNLOCKED);
   if(iRageBonusInterval >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_RAGE_INTERVAL_2, CONST_FAMESHOP_UNLOCKED);
}

int TryToBuyRageInterval(object oPC, int iWantedBonusLevel, int iRequiredBonusLevel, int iCost)
{
    if(!GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC))
    {
        SendMessageToPC(oPC, "The unlock failed. You have no Barbarian levels in your build.");
        return FALSE;
    }
    int iFreeFame = GetFreeFame(oPC);
    int iPlayerID = players_GetPCPersistentID(oPC);
    int iCurrentBonusInterval = GetRageBonusInterval(iPlayerID);
    int iDelta = iWantedBonusLevel - iCurrentBonusInterval;
    int iSuccess = FALSE;

    if(iWantedBonusLevel == 3)
    {
        SendMessageToPC(oPC, "The unlock failed. Maximum bonus reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentBonusInterval >= iWantedBonusLevel)
    {
        SendMessageToPC(oPC, "The unlock failed. This or higher bonus feat has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iDelta > 1)
    {
        SendMessageToPC(oPC, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if (iFreeFame >= iCost && iDelta == 1)
    {
        string sSQL = "UPDATE characters SET rage_interval = rage_interval + 1 WHERE id = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, iPlayerID);
        if(NWNX_SQL_ExecutePreparedQuery())
        {
            SpendFame(oPC, iCost);
            SendMessageToPC(oPC, "Purchase completed successfully.");
            RefreshTokensForBarbarianRage(oPC);
            iSuccess = TRUE;
        }
    }
    else
    {
        SendMessageToPC(oPC, "Unlock failed: not enough fame. Need "+IntToString(iCost-iFreeFame)+". Available: " + IntToString(iFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}

int TryToBuyRageDC(object oPC, int iWantedBonusLevel, int iRequiredBonusLevel, int iCost)
{
    if(!GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC))
    {
        SendMessageToPC(oPC, "The unlock failed. You have no Barbarian levels in your build.");
        return FALSE;
    }
    int iFreeFame = GetFreeFame(oPC);
    int iPlayerID = players_GetPCPersistentID(oPC);
    int iCurrentBonusDC = GetRageBonusDC(iPlayerID);
    int iDelta = iWantedBonusLevel - iCurrentBonusDC;
    int iSuccess = FALSE;

    if(iRequiredBonusLevel == 5)
    {
        SendMessageToPC(oPC, "The unlock failed. Maximum bonus reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentBonusDC >= iWantedBonusLevel)
    {
        SendMessageToPC(oPC, "The unlock failed. This or higher bonus feat has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iDelta > 1)
    {
        SendMessageToPC(oPC, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if (iFreeFame >= iCost && iDelta == 1)
    {
        string sSQL = "UPDATE characters SET rage_dc = rage_dc + 1 WHERE id = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, iPlayerID);
        if(NWNX_SQL_ExecutePreparedQuery())
        {
            SpendFame(oPC, iCost);
            SendMessageToPC(oPC, "Purchase completed successfully.");
            RefreshTokensForBarbarianRage(oPC);
            iSuccess = TRUE;
        }
    }
    else
    {
        SendMessageToPC(oPC, "The unlock failed. You should buy previous bonus."+IntToString(iCost-iFreeFame)+". Available: " + IntToString(iFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}

int GetRageBonusInterval(int iPlayerID)
{
    string sSQL = "SELECT rage_interval FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    else
    {
        return 0;
    }
}

int GetRageBonusDC(int iPlayerID)
{
    string sSQL = "SELECT rage_dc FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    else
    {
        return 0;
    }
}
//void main(){}

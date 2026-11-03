// faction fameshop
#include "_inc_factions"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

const int DIALOG_FACTION_FAMESHOP_TYPE_REFRESH_TOKENS       = 1;
const int DIALOG_FACTION_FAMESHOP_TYPE_XP_LEVEL             = 2;
const int DIALOG_FACTION_FAMESHOP_TYPE_BUFFER_LEVELS        = 3;
const int DIALOG_FACTION_FAMESHOP_TYPE_BUFFER_BONUS_DC      = 4;
const int DIALOG_FACTION_FAMESHOP_TYPE_BUFFER_PERFORM_SKILL = 5;
const int DIALOG_FACTION_FAMESHOP_TYPE_BUFFER_SONG_UPGRADE  = 6;
const int DIALOG_FACTION_FAMESHOP_TYPE_STARGATES            = 7;
const int DIALOG_FACTION_FAMESHOP_TYPE_GUARDS_LEVEL         = 8;

//
int fact_GetFactionFreeFame(int iFaction);

//
int fact_GetFactionSpentFame(int iFaction);

//
void fact_SetFactionSpentFame(int iFaction, int iValue);

//
int fact_SpendFactionFame(int iFaction, int iValue);

//
int fact_TryToBuyFactionXPBonus(object oFactionMember, int iPurchasedLevel, int iFameCost, int iGoldCost);

//
int fact_TryToBuyFactionBufferLevel(object oFactionMember, int iPurchasedLevel, int iGoldCost);

//
int fact_TryToBuyFactionBufferBonusDC(object oFactionMember, int iPurchasedLevel, int iFameCost);

//
int fact_TryToBuyFactionBufferPerformSkill(object oFactionMember, int iPurchasedPerformSkill, int iFameCost);

//
int fact_TryToBuyFactionSongUpgradeLevel(object oFactionMember, int iPurchasedLevel, int iGoldCost);

//
int fact_TryToActivateStargates(object oFactionMember, int iPurchasedLevel, int iGoldCost);

//
int fact_TryToBuyGuardsLevel(object oFactionMember, int iPurchasedLevel, int iFameCost);

//
void fact_RefreshFactionTokens(object oPC);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int fact_GetFactionFreeFame(int iFaction)
{
    return factions_GetFactionFame(iFaction) - fact_GetFactionSpentFame(iFaction);
}

int fact_GetFactionSpentFame(int iFaction)
{
    string sSQL = "SELECT fame_spent FROM factions WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iFaction);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    return 0;
}

void fact_SetFactionSpentFame(int iFaction, int iValue)
{
    string sSQL = "UPDATE factions SET fame_spent = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iValue);
    NWNX_SQL_PreparedInt(1, iFaction);
    NWNX_SQL_ExecutePreparedQuery();
}

int fact_SpendFactionFame(int iFaction, int iValue)
{
    if(fact_GetFactionFreeFame(iFaction) >= iValue)
    {
        fact_SetFactionSpentFame(iFaction, fact_GetFactionSpentFame(iFaction) + iValue);
        WriteLog("Faction fame spend " + IntToString(iValue));
        return TRUE;
    }
    else
        return FALSE;
}

int fact_TryToBuyFactionXPBonus(object oFactionMember, int iPurchasedLevel, int iFameCost, int iGoldCost)
{
    if (GetGold(oFactionMember) < iGoldCost)
    {
        SendMessageToPC(oFactionMember, "Unlock failed: not enough gold.");
        return FALSE;
    }

    int iFaction = players_GetFaction(oFactionMember);
    int iCurrentXpLevel = factions_GetFactionXPBonus(iFaction);
    int iFactionFreeFame = fact_GetFactionFreeFame(iFaction);
    int iSuccess = FALSE;

    if(iCurrentXpLevel == 10)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. Maximum bonus reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentXpLevel >= iPurchasedLevel)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. This or higher bonus has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iPurchasedLevel - iCurrentXpLevel != 1)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if(iFactionFreeFame >= iFameCost)
    {
        factions_SetFactionXPBonus(iFaction, iPurchasedLevel);
        TakeGoldFromCreature(iGoldCost, oFactionMember, TRUE);
        fact_SpendFactionFame(iFaction, iFameCost);

        SendMessageToPC(oFactionMember, "The unlock was successfully completed. You spent " + IntToString(iFameCost) +
                                        " faction fame. Available: " + IntToString(iFactionFreeFame));
        // refresh on success
        fact_RefreshFactionTokens(oFactionMember);
        iSuccess = TRUE;
    }
    else
    {
        SendMessageToPC(oFactionMember, "The unlock failed, not enough fame. Need " +
                                        IntToString(iFameCost - iFactionFreeFame) + ". Available: " +
                                        IntToString(iFactionFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}

int fact_TryToBuyFactionBufferLevel(object oFactionMember, int iPurchasedLevel, int iGoldCost)
{
    int iFaction = players_GetFaction(oFactionMember);
    int iCurrentClericLevel = factions_GetFactionBufferLevel(iFaction);
    int iCurrentPCGold = GetGold(oFactionMember);
    int iSuccess = FALSE;

    if(iCurrentClericLevel == 40 /* max character level */)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. Maximum bonus reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentClericLevel >= iPurchasedLevel)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. This or higher bonus has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iPurchasedLevel - iCurrentClericLevel != 1)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if(iCurrentPCGold >= iGoldCost)
    {
        factions_SetFactionBufferLevel(iFaction, iPurchasedLevel);
        TakeGoldFromCreature(iGoldCost, oFactionMember, TRUE);

        SendMessageToPC(oFactionMember, "The unlock was successfully completed. You spent " + IntToString(iGoldCost) +
                                        " gold.");
        // refresh on success
        fact_RefreshFactionTokens(oFactionMember);
        iSuccess = TRUE;
    }
    else
    {
        SendMessageToPC(oFactionMember, "The unlock failed, not enough gold. Need " +
                                        IntToString(iGoldCost - iCurrentPCGold));
        iSuccess = FALSE;
    }
    return iSuccess;
}

int fact_TryToBuyFactionBufferBonusDC(object oFactionMember, int iPurchasedBonusDC, int iFameCost)
{
    int iFaction = players_GetFaction(oFactionMember);
    int iCurrentClericBonusDC = factions_GetFactionBufferBonusDC(iFaction);
    int iFactionFreeFame = fact_GetFactionFreeFame(iFaction);
    int iSuccess = FALSE;

    if(iCurrentClericBonusDC == 6 /* current max DC bonus vs dispel */)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. Maximum bonus reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentClericBonusDC >= iPurchasedBonusDC)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. This or higher bonus has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iPurchasedBonusDC - iCurrentClericBonusDC != 1)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if(iFactionFreeFame >= iFameCost)
    {
        factions_SetFactionBufferBonusDC(iFaction, iPurchasedBonusDC);
        fact_SpendFactionFame(iFaction, iFameCost);
        SendMessageToPC(oFactionMember, "The unlock was successfully completed. You spent " + IntToString(iFameCost) +
                                        " fame.");
        // refresh on success
        fact_RefreshFactionTokens(oFactionMember);
        iSuccess = TRUE;
    }
    else
    {
        SendMessageToPC(oFactionMember, "The unlock failed, not enough fame. Need " +
                                        IntToString(iFameCost - iFactionFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}

int fact_TryToBuyFactionBufferPerformSkill(object oFactionMember, int iPurchasedPerformSkill, int iFameCost)
{
    int iFaction = players_GetFaction(oFactionMember);
    int iCurrentPerformSkill = factions_GetFactionBufferPerformSkill(iFaction);
    int iFactionFreeFame = fact_GetFactionFreeFame(iFaction);
    int iSuccess = FALSE;

    if(iCurrentPerformSkill == 80 /* current max perform skill for song bonuses */)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. Maximum bonus reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentPerformSkill >= iPurchasedPerformSkill)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. This or higher bonus has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iPurchasedPerformSkill - iCurrentPerformSkill != 10)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if(iFactionFreeFame >= iFameCost)
    {
        factions_SetFactionBufferPerformSkill(iFaction, iPurchasedPerformSkill);
        fact_SpendFactionFame(iFaction, iFameCost);
        SendMessageToPC(oFactionMember, "The unlock was successfully completed. You spent " + IntToString(iFameCost) +
                                        " fame.");
        // refresh on success
        fact_RefreshFactionTokens(oFactionMember);
        iSuccess = TRUE;
    }
    else
    {
        SendMessageToPC(oFactionMember, "The unlock failed, not enough fame. Need " +
                                        IntToString(iFameCost - iFactionFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}

int fact_TryToBuyFactionSongUpgradeLevel(object oFactionMember, int iPurchasedLevel, int iGoldCost)
{
    int iFaction = players_GetFaction(oFactionMember);
    int iCurrentSongUpgradeLevel = factions_GetFactionBufferSongUpgradeLevel(iFaction);
    int iCurrentPCGold = GetGold(oFactionMember);
    int iSuccess = FALSE;

    if(iCurrentSongUpgradeLevel == 5 /* max faction song upgrade level */)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. Maximum bonus reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentSongUpgradeLevel >= iPurchasedLevel)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. This or higher bonus has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iPurchasedLevel - iCurrentSongUpgradeLevel != 1)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if(iCurrentPCGold >= iGoldCost)
    {
        factions_SetFactionBufferSongUpgradeLevel(iFaction, iPurchasedLevel);
        TakeGoldFromCreature(iGoldCost, oFactionMember, TRUE);

        SendMessageToPC(oFactionMember, "The unlock was successfully completed. You spent " + IntToString(iGoldCost) +
                                        " gold.");
        // refresh on success
        fact_RefreshFactionTokens(oFactionMember);
        iSuccess = TRUE;
    }
    else
    {
        SendMessageToPC(oFactionMember, "The unlock failed, not enough gold. Need " +
                                        IntToString(iGoldCost - iCurrentPCGold));
        iSuccess = FALSE;
    }
    return iSuccess;
}

int fact_TryToActivateStargates(object oFactionMember, int iPurchasedLevel, int iGoldCost)
{
    int iFaction = players_GetFaction(oFactionMember);
    int iCurrentActiveStargates = factions_GetFactionActiveStargates(iFaction);
    int iCurrentPCGold = GetGold(oFactionMember);
    int iSuccess = FALSE;

    if(iCurrentActiveStargates == 3 /* max stargates */)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. Maximum bonus reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentActiveStargates >= iPurchasedLevel)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. This or higher bonus has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iPurchasedLevel - iCurrentActiveStargates != 1)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if(iCurrentPCGold >= iGoldCost)
    {
        factions_SetFactionActiveStargates(iFaction, iPurchasedLevel);
        TakeGoldFromCreature(iGoldCost, oFactionMember, TRUE);

        SendMessageToPC(oFactionMember, "The unlock was successfully completed. You spent " + IntToString(iGoldCost) +
                                        " gold.");
        // refresh on success
        fact_RefreshFactionTokens(oFactionMember);
        iSuccess = TRUE;
    }
    else
    {
        SendMessageToPC(oFactionMember, "The unlock failed, not enough gold. Need " +
                                        IntToString(iGoldCost - iCurrentPCGold));
        iSuccess = FALSE;
    }
    return iSuccess;
}

int fact_TryToBuyGuardsLevel(object oFactionMember, int iPurchasedLevel, int iFameCost)
{
    int iFaction = players_GetFaction(oFactionMember);
    int iCurrentLevel = factions_GetFactionGuardsLevel(iFaction);
    int iFactionFreeFame = fact_GetFactionFreeFame(iFaction);
    int iSuccess = FALSE;

    if(iCurrentLevel == 4 /* current max level */)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. Maximum level reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentLevel >= iPurchasedLevel)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. This or higher level has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iPurchasedLevel - iCurrentLevel != 1)
    {
        SendMessageToPC(oFactionMember, "The unlock failed. You should buy previous level.");
        iSuccess = FALSE;
    }
    else if(iFactionFreeFame >= iFameCost)
    {
        factions_SetFactionGuardsLevel(iFaction, iPurchasedLevel);
        fact_SpendFactionFame(iFaction, iFameCost);
        SendMessageToPC(oFactionMember, "The unlock was successfully completed. You spent " + IntToString(iFameCost) +
                                        " fame.");
        // refresh on success
        fact_RefreshFactionTokens(oFactionMember);
        iSuccess = TRUE;
    }
    else
    {
        SendMessageToPC(oFactionMember, "The unlock failed, not enough fame. Need " +
                                        IntToString(iFameCost - iFactionFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}

void fact_RefreshFactionTokens(object oPC)
{
    int iFaction = players_GetFaction(oPC);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_FAME_VALUE, IntToString(fact_GetFactionFreeFame(iFaction)));

    // experience bonuses
    int iExpLevel = factions_GetFactionXPBonus(iFaction);
    if(iExpLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_1, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_1, CONST_FAMESHOP_LOCKED);
    if(iExpLevel >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_2, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_2, CONST_FAMESHOP_LOCKED);
    if(iExpLevel >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_3, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_3, CONST_FAMESHOP_LOCKED);
    if(iExpLevel >= 4)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_4, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_4, CONST_FAMESHOP_LOCKED);
    if(iExpLevel >= 5)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_5, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_5, CONST_FAMESHOP_LOCKED);
    if(iExpLevel >= 6)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_6, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_6, CONST_FAMESHOP_LOCKED);
    if(iExpLevel >= 7)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_7, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_7, CONST_FAMESHOP_LOCKED);
    if(iExpLevel >= 8)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_8, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_8, CONST_FAMESHOP_LOCKED);
    if(iExpLevel >= 9)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_9, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_9, CONST_FAMESHOP_LOCKED);
    if(iExpLevel >= 10)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_10, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_XP_BONUS_10, CONST_FAMESHOP_LOCKED);

    // cleric upgrades
    int iClericLevel = factions_GetFactionBufferLevel(iFaction);

    if(iClericLevel >= 21)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_21, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_21, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 22)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_22, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_22, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 23)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_23, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_23, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 24)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_24, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_24, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 25)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_25, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_25, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 26)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_26, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_26, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 27)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_27, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_27, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 28)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_28, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_28, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 29)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_29, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_29, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 30)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_30, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_30, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 31)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_31, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_31, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 32)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_32, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_32, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 33)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_33, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_33, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 34)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_34, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_34, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 35)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_35, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_35, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 36)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_36, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_36, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 37)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_37, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_37, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 38)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_38, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_38, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 39)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_39, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_39, CONST_FAMESHOP_LOCKED);
    if(iClericLevel >= 40)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_40, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_LEVEL_40, CONST_FAMESHOP_LOCKED);

    // additional DC bonus VS dispel
    int iFactionClericBonusDC = factions_GetFactionBufferBonusDC(iFaction);

    if(iFactionClericBonusDC >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_1, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_1, CONST_FAMESHOP_LOCKED);
    if(iFactionClericBonusDC >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_2, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_2, CONST_FAMESHOP_LOCKED);
    if(iFactionClericBonusDC >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_3, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_3, CONST_FAMESHOP_LOCKED);
    if(iFactionClericBonusDC >= 4)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_4, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_4, CONST_FAMESHOP_LOCKED);
    if(iFactionClericBonusDC >= 5)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_5, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_5, CONST_FAMESHOP_LOCKED);
    if(iFactionClericBonusDC >= 6)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_6, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_DISPEL_DEFENCE_6, CONST_FAMESHOP_LOCKED);

    // buffer's perform skill
    int iFactionBufferPerformSkill = factions_GetFactionBufferPerformSkill(iFaction);

    if(iFactionBufferPerformSkill >= 10)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_10, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_10, CONST_FAMESHOP_LOCKED);
    if(iFactionBufferPerformSkill >= 20)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_20, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_20, CONST_FAMESHOP_LOCKED);
    if(iFactionBufferPerformSkill >= 30)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_30, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_30, CONST_FAMESHOP_LOCKED);
    if(iFactionBufferPerformSkill >= 40)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_40, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_40, CONST_FAMESHOP_LOCKED);
    if(iFactionBufferPerformSkill >= 50)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_50, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_50, CONST_FAMESHOP_LOCKED);
    if(iFactionBufferPerformSkill >= 60)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_60, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_60, CONST_FAMESHOP_LOCKED);
    if(iFactionBufferPerformSkill >= 70)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_70, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_70, CONST_FAMESHOP_LOCKED);
    if(iFactionBufferPerformSkill >= 80)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_80, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_PERFORM_SKILL_80, CONST_FAMESHOP_LOCKED);

    // buffer's song upgrade level
    int iFactionBufferSongUpgradeLevel = factions_GetFactionBufferSongUpgradeLevel(iFaction);

    if(iFactionBufferSongUpgradeLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_SONG_TEMP_HITPOINTS, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_SONG_TEMP_HITPOINTS, CONST_FAMESHOP_LOCKED);
    if(iFactionBufferSongUpgradeLevel >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_SONG_NEGATIVE_IMMUNITY, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_SONG_NEGATIVE_IMMUNITY, CONST_FAMESHOP_LOCKED);
    if(iFactionBufferSongUpgradeLevel >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_SONG_REGENERATION, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_SONG_REGENERATION, CONST_FAMESHOP_LOCKED);
    if(iFactionBufferSongUpgradeLevel >= 4)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_SONG_CONCEALMENT, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_SONG_CONCEALMENT, CONST_FAMESHOP_LOCKED);
    if(iFactionBufferSongUpgradeLevel >= 5)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_SONG_MAGIC_DAMAGE, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_BUFFER_SONG_MAGIC_DAMAGE, CONST_FAMESHOP_LOCKED);

    // stargates
    int nActiveStargates = factions_GetFactionActiveStargates(iFaction);
    if(nActiveStargates >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_STARGATE_1, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_STARGATE_1, CONST_FAMESHOP_LOCKED);
    if(nActiveStargates >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_STARGATE_2, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_STARGATE_2, CONST_FAMESHOP_LOCKED);
    if(nActiveStargates >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_STARGATE_3, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_STARGATE_3, CONST_FAMESHOP_LOCKED);

    // additional DC bonus VS dispel
    int iFactionGuardsLevel = factions_GetFactionGuardsLevel(iFaction);

    if(iFactionGuardsLevel >= 1)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_GUARDS_LEVEL_1, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_GUARDS_LEVEL_1, CONST_FAMESHOP_LOCKED);
    if(iFactionGuardsLevel >= 2)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_GUARDS_LEVEL_2, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_GUARDS_LEVEL_2, CONST_FAMESHOP_LOCKED);
    if(iFactionGuardsLevel >= 3)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_GUARDS_LEVEL_3, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_GUARDS_LEVEL_3, CONST_FAMESHOP_LOCKED);
    if(iFactionGuardsLevel >= 4)
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_GUARDS_LEVEL_4, CONST_FAMESHOP_UNLOCKED);
    else
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FACTION_GUARDS_LEVEL_4, CONST_FAMESHOP_LOCKED);
}

//void main() {}

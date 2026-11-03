#include "_inc_fameshop"

///////////////////////////////////////////////////////////////////
//////////                  Prototypes                   //////////
///////////////////////////////////////////////////////////////////

const string BG_UPGRADES_CASH = "BG_UPGRADES_CASH";

//
void fshop_bg_RefreshTokens(object oPC);

//
int fshop_bg_GetIsBitActivated(object oPC, int nUpgradeBit);

//
void fshop_bg_ActivateBit(object oPC, int nUpgradeBit);

//
int fshop_bg_TryToActivateBit(object oPC, int nUpgradeBit, int nCost);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void fshop_bg_RefreshTokens(object oPC)
{
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_SEAL_OF_SILENCE_DUR_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_SEAL_OF_SILENCE_DUR_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_TAUNT_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_SF_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_AB_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_CD_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_CD_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_RADIUS_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_MARK_OF_DOOM_CD_1_3ROUNDS, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_MARK_OF_DOOM_CD_2_3ROUNDS, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_MARK_OF_DOOM_CD_3_2ROUNDS, CONST_FAMESHOP_LOCKED);

    if(fshop_bg_GetIsBitActivated(oPC, FAMESHOP_BG_SEAL_OF_SILENCE_DUR_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_SEAL_OF_SILENCE_DUR_1, CONST_FAMESHOP_UNLOCKED);

    if(fshop_bg_GetIsBitActivated(oPC, FAMESHOP_BG_SEAL_OF_SILENCE_DUR_2))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_SEAL_OF_SILENCE_DUR_2, CONST_FAMESHOP_UNLOCKED);

    if(fshop_bg_GetIsBitActivated(oPC, FAMESHOP_BG_EVIL_BLIGHT_BONUS_TAUNT_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_TAUNT_1, CONST_FAMESHOP_UNLOCKED);

    if(fshop_bg_GetIsBitActivated(oPC, FAMESHOP_BG_EVIL_BLIGHT_BONUS_SF_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_SF_1, CONST_FAMESHOP_UNLOCKED);

    if(fshop_bg_GetIsBitActivated(oPC, FAMESHOP_BG_EVIL_BLIGHT_BONUS_AB_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_AB_1, CONST_FAMESHOP_UNLOCKED);

    if(fshop_bg_GetIsBitActivated(oPC, FAMESHOP_BG_EVIL_BLIGHT_BONUS_CD_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_CD_1, CONST_FAMESHOP_UNLOCKED);

    if(fshop_bg_GetIsBitActivated(oPC, FAMESHOP_BG_EVIL_BLIGHT_BONUS_CD_2))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_CD_2, CONST_FAMESHOP_UNLOCKED);

    if(fshop_bg_GetIsBitActivated(oPC, FAMESHOP_BG_EVIL_BLIGHT_BONUS_RADIUS_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_EVIL_BLIGHT_BONUS_RADIUS_1, CONST_FAMESHOP_UNLOCKED);

    if(fshop_bg_GetIsBitActivated(oPC, FAMESHOP_BG_MARK_OF_DOOM_CD_1_3ROUNDS))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_MARK_OF_DOOM_CD_1_3ROUNDS, CONST_FAMESHOP_UNLOCKED);

    if(fshop_bg_GetIsBitActivated(oPC, FAMESHOP_BG_MARK_OF_DOOM_CD_2_3ROUNDS))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_MARK_OF_DOOM_CD_2_3ROUNDS, CONST_FAMESHOP_UNLOCKED);

    if(fshop_bg_GetIsBitActivated(oPC, FAMESHOP_BG_MARK_OF_DOOM_CD_3_2ROUNDS))
        NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_BG_MARK_OF_DOOM_CD_3_2ROUNDS, CONST_FAMESHOP_UNLOCKED);
}

int fshop_bg_GetIsBitActivated(object oPC, int nUpgradeBit)
{
    int iPlayerId = players_GetPCPersistentID(oPC);
    if(!iPlayerId)
        return 0;

    int nBitArray = GetLocalInt(oPC, BG_UPGRADES_CASH);
    if(nBitArray > 0)
        return nBitArray & nUpgradeBit;
    else if(nBitArray == -1)
        return 0;

    NWNX_SQL_ExecuteQuery("SELECT bg_upgrades FROM characters WHERE id = " + IntToString(iPlayerId));
    if (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nBitArray = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
        nBitArray = nBitArray > 0 ? nBitArray : -1;
        SetLocalInt(oPC, BG_UPGRADES_CASH, nBitArray);
        if(nBitArray > 0)
            return nBitArray & nUpgradeBit;
        else
            return 0;
    }
    return 0;
}

void fshop_bg_ActivateBit(object oPC, int nUpgradeBit)
{
    int iPlayerId = players_GetPCPersistentID(oPC);
    if(!iPlayerId)
        return;

    if(fshop_bg_GetIsBitActivated(oPC, nUpgradeBit))
        return;

    int nBitArray = GetLocalInt(oPC, BG_UPGRADES_CASH);
    if(nBitArray < 0)
        nBitArray = 0;

    nBitArray = nBitArray | nUpgradeBit;
    SetLocalInt(oPC, BG_UPGRADES_CASH, nBitArray);
    NWNX_SQL_ExecuteQuery("UPDATE characters SET bg_upgrades = " + IntToString(nBitArray) + " WHERE id = " + IntToString(iPlayerId));
}

int fshop_bg_TryToActivateBit(object oPC, int nUpgradeBit, int nCost)
{
    if(!GetLevelByClass(CLASS_TYPE_BLACKGUARD, oPC))
    {
        SendMessageToPC(oPC, "This upgrade available for BG only.");
        return FALSE;
    }
    if(fshop_bg_GetIsBitActivated(oPC, nUpgradeBit))
    {
        SendMessageToPC(oPC, "You already activated this upgrade.");
        return FALSE;
    }
    if(!SpendFame(oPC, nCost))
    {
        SendMessageToPC(oPC, "Upgrade is not activated. Not enough fame. Need: " + IntToString(nCost));
        return FALSE;
    }
    SendMessageToPC(oPC, "Upgrade activated.");
    fshop_bg_ActivateBit(oPC, nUpgradeBit);
    fshop_bg_RefreshTokens(oPC);
    return TRUE;
}

//void main(){}

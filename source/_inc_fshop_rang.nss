#include "_inc_fameshop"

///////////////////////////////////////////////////////////////////
//////////                  Prototypes                   //////////
///////////////////////////////////////////////////////////////////

void RefreshTokensForPlayerFavoredEnemy(object oPC);

int TryToBuyFavoredEnemyFeat(object oPC, int iDatabaseFeat, int iCost);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void RefreshTokensForPlayerFavoredEnemy(object oPC)
{
    int iPlayerID = players_GetPCPersistentID(oPC);

    int iBitArrayEnemies = 0;

    string sSQL = "SELECT favored_enemies FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iBitArrayEnemies = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }

    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FREEFAME, IntToString(GetFreeFame(oPC)));

    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_HALFLING, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_HALFELF, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_GNOME, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_HUMAN, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_HALFORC, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_ELF, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_DWARF, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_AASIMAR, CONST_FAMESHOP_LOCKED);   // new
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_MOONELF, CONST_FAMESHOP_LOCKED);   // new
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_DUERGAR, CONST_FAMESHOP_LOCKED);   // new

    if(iBitArrayEnemies & FAMESHOP_RANGER_FAVORED_ENEMY_GNOME)    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_GNOME, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayEnemies & FAMESHOP_RANGER_FAVORED_ENEMY_HALFELF)  NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_HALFELF, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayEnemies & FAMESHOP_RANGER_FAVORED_ENEMY_HALFLING) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_HALFLING, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayEnemies & FAMESHOP_RANGER_FAVORED_ENEMY_HUMAN)    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_HUMAN, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayEnemies & FAMESHOP_RANGER_FAVORED_ENEMY_HALFORC)  NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_HALFORC, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayEnemies & FAMESHOP_RANGER_FAVORED_ENEMY_ELF)      NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_ELF, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayEnemies & FAMESHOP_RANGER_FAVORED_ENEMY_DWARF)    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_DWARF, CONST_FAMESHOP_UNLOCKED);
    if(iBitArrayEnemies & FAMESHOP_RANGER_FAVORED_ENEMY_AASIMAR)  NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_AASIMAR, CONST_FAMESHOP_UNLOCKED); // new
    if(iBitArrayEnemies & FAMESHOP_RANGER_FAVORED_ENEMY_MOONELF)  NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_MOONELF, CONST_FAMESHOP_UNLOCKED); // new
    if(iBitArrayEnemies & FAMESHOP_RANGER_FAVORED_ENEMY_DUERGAR)  NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FAVORED_ENEMY_DUERGAR, CONST_FAMESHOP_UNLOCKED); // new
}

int TryToBuyFavoredEnemyFeat(object oPC, int iDatabaseFeat, int iCost)
{
    if(!GetLevelByClass(CLASS_TYPE_RANGER, oPC))
    {
        SendMessageToPC(oPC, "The unlock failed. You have no Ranger levels in your build.");
        return FALSE;
    }

    int iPlayerID = players_GetPCPersistentID(oPC);
    int iBitArrayEnemies = 0;

    string sSQL = "SELECT favored_enemies FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        iBitArrayEnemies = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }

    if(iBitArrayEnemies & iDatabaseFeat)
    {
        SendMessageToPC(oPC, "This feat already purchased.");
        return FALSE;
    }
    else if(GetFreeFame(oPC) >= iCost)
    {
        iBitArrayEnemies |= iDatabaseFeat;

        sSQL = "UPDATE characters SET favored_enemies = ? WHERE id = ?";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedInt(0, iBitArrayEnemies);
        NWNX_SQL_PreparedInt(1, iPlayerID);
        if (NWNX_SQL_ExecutePreparedQuery())
        {
            SpendFame(oPC, iCost);
            int iFeat = -1;
            string sFeatName = "";
            if(iDatabaseFeat == FAMESHOP_RANGER_FAVORED_ENEMY_HALFLING)  iFeat = FEAT_FAVORED_ENEMY_HALFLING;
            if(iDatabaseFeat == FAMESHOP_RANGER_FAVORED_ENEMY_HALFELF)   iFeat = FEAT_FAVORED_ENEMY_HALFELF;
            if(iDatabaseFeat == FAMESHOP_RANGER_FAVORED_ENEMY_GNOME)     iFeat = FEAT_FAVORED_ENEMY_GNOME;
            if(iDatabaseFeat == FAMESHOP_RANGER_FAVORED_ENEMY_HUMAN)     iFeat = FEAT_FAVORED_ENEMY_HUMAN;
            if(iDatabaseFeat == FAMESHOP_RANGER_FAVORED_ENEMY_HALFORC)   iFeat = FEAT_FAVORED_ENEMY_HALFORC;
            if(iDatabaseFeat == FAMESHOP_RANGER_FAVORED_ENEMY_ELF)       iFeat = FEAT_FAVORED_ENEMY_ELF;
            if(iDatabaseFeat == FAMESHOP_RANGER_FAVORED_ENEMY_DWARF)     iFeat = FEAT_FAVORED_ENEMY_DWARF;
            if(iDatabaseFeat == FAMESHOP_RANGER_FAVORED_ENEMY_AASIMAR)   iFeat = FEAT_FAVORED_ENEMY_AASIMAR;  // new
            if(iDatabaseFeat == FAMESHOP_RANGER_FAVORED_ENEMY_MOONELF)   iFeat = FEAT_FAVORED_ENEMY_MOONELF;  // new
            if(iDatabaseFeat == FAMESHOP_RANGER_FAVORED_ENEMY_DUERGAR)   iFeat = FEAT_FAVORED_ENEMY_DUERGAR;  // new

            if(iFeat != -1)
            {
                // can not be added as skin feat cos bane of enemies doesnt work in this case
                // this implementation uses ELC crutch
                NWNX_Creature_AddFeatByLevel(oPC, iFeat, 1);

                sFeatName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", iFeat)));
                SendMessageToPC(oPC, "Feat "+ sFeatName + " has been successfully purchased.");
                WriteTimestampedLogEntry("Feat "+ sFeatName + " has been successfully purchased.");

                RefreshTokensForPlayerFavoredEnemy(oPC);

                return TRUE;
            }
            else
            {
                SendMessageToPC(oPC, "Error.");
                return FALSE;
            }
        }
    }
    else
    {
        SendMessageToPC(oPC, "Not enough fame.");
        return FALSE;
    }
    return FALSE;
}

//void main(){}

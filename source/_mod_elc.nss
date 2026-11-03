#include "nwnx_elc"
#include "_inc_players"
#include "_inc_fshop_const"
#include "_inc_pres_class"
#include "nwnx_creature"


void main()
{
    object oPC   = OBJECT_SELF;
    int nType    = NWNX_ELC_GetValidationFailureType();
    int nSubType = NWNX_ELC_GetValidationFailureSubType();
    int nStrRef  = NWNX_ELC_GetValidationFailureMessageStrRef();

    WriteTimestampedLogEntry("ELC: FAIL: "  + GetName(oPC) +
                             " -> Type = "  + IntToString(nType) +
                             ", SubType = " + IntToString(nSubType) +
                             ", StrRef = "  + GetStringByStrRef(nStrRef));

    // debug
    NWNX_ELC_SkipValidationFailure();
    return;
    // end debug

    switch(nType)
    {
        case NWNX_ELC_VALIDATION_FAILURE_TYPE_CHARACTER:
        {
            if(nSubType == NWNX_ELC_SUBTYPE_PRESTIGE_CLASS_REQUIREMENTS)
            {
                int bValidated = FALSE;
                if     (GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oPC) && pres_RDD(oPC))
                    bValidated = TRUE;
                if(bValidated)
                    NWNX_ELC_SkipValidationFailure();
            }
            if(nSubType == NWNX_ELC_SUBTYPE_MISC_SAVING_THROW)
            {
                NWNX_ELC_SkipValidationFailure();
            }
            break;
        }
        case NWNX_ELC_VALIDATION_FAILURE_TYPE_ITEM:
        {
            object oItem = NWNX_ELC_GetValidationFailureItem();
            SendMessageToPC(oPC, GetName(oItem));
            // Unequip the item instead of having the player unable to login
            if(GetIsObjectValid(oItem))
                ActionUnequipItem(oItem);
            NWNX_ELC_SkipValidationFailure();
            break;
        }
        case NWNX_ELC_VALIDATION_FAILURE_TYPE_SKILL:
        {
            // We don't handle skill validation failures
            break;
        }
        case NWNX_ELC_VALIDATION_FAILURE_TYPE_FEAT:
        {
            if (nSubType == NWNX_ELC_SUBTYPE_TOO_MANY_FEATS_THIS_LEVEL ||
                nSubType == NWNX_ELC_SUBTYPE_FEAT_IS_NORMAL_FEAT_ONLY  ||
                nSubType == NWNX_ELC_SUBTYPE_FEAT_IS_BONUS_FEAT_ONLY   ||
                nSubType == NWNX_ELC_SUBTYPE_FEAT_LIST_COMPARISON      ||
                nSubType == NWNX_ELC_SUBTYPE_FEAT_NOT_AVAILABLE_TO_CLASS)
            {
                int nFeatID = NWNX_ELC_GetValidationFailureFeatID();
                if (GetLevelByClass(CLASS_TYPE_RANGER, oPC))
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

                    // int iHexFavoriteEnemy = elc_ConvertFavoriteEnemyToFameShopHex(nFeatID);
                    // пропускаем всех с купленными фитами, т. к.
                    // на текущий момент NWNX_ELC_GetValidationFailureFeatID() может выбросить
                    // даже корректный, взятый на левелапе фит, как ошибочный,
                    // а не только из добавленных хирургически функцией NWNX_Creature_AddFeatByLevel
                    // upd 16.12.21
                    // если у чара на каком-то уровне присутствует лишний фит, то ошибка пробрасывается
                    // на фит с более высоким значением strref
                    // на текущий момент "правильный" механизм валидации похоже невозможен

                    if (iBitArrayEnemies /* & iHexFavoriteEnemy */)
                    {
                        NWNX_ELC_SkipValidationFailure();
                    }
                    else
                    {
                        WriteTimestampedLogEntry("FEAT_ID: " + IntToString(nFeatID));
                        WriteTimestampedLogEntry("iBitArrayEnemies: " + IntToHexString(iBitArrayEnemies));
                        //WriteTimestampedLogEntry("iHexFavoriteEnemy: " + IntToHexString(iHexFavoriteEnemy));
                    }
                }
                if(GetHasFeat(FEAT_WEP_PROF_GOVNOTRYAS, oPC) || GetHasFeat(FEAT_ARMOR_PROFICIENCY_HEAVY, oPC))
                {
                    NWNX_ELC_SkipValidationFailure();
                }
            }
            break;
        }

        case NWNX_ELC_VALIDATION_FAILURE_TYPE_SPELL:
        {
            if(nSubType == NWNX_ELC_SUBTYPE_SPELL_MINIMUM_ABILITY)
                NWNX_ELC_SkipValidationFailure();
            break;
        }

        case NWNX_ELC_VALIDATION_FAILURE_TYPE_CUSTOM:
        {
            int nLimitedClassSlotID = players_GetIsLimitedBuild(oPC);
            int nSupportSlot = players_GetIsSupport(oPC);
            if ((nLimitedClassSlotID || nSupportSlot) && !players_IsTestCharacter(oPC))
            {
                if (nLimitedClassSlotID &&
                    GetLocalInt(GetModule(), "LIMITED_BUILD_FACTION_" + IntToString(players_GetFaction(oPC)) + "_SLOT_ID_" + IntToString(nLimitedClassSlotID)) >= 1)
                {
                    NWNX_ELC_SetValidationFailureMessageStrRef(16777600);
                }
                else if // handle support slots
                   (nSupportSlot &&
                    GetLocalInt(GetModule(), "LIMITED_BUILD_FACTION_" + IntToString(players_GetFaction(oPC)) + "_SLOT_ID_" + IntToString(nSupportSlot)) >= 4)
                {
                    // boot with message about support limit
                    NWNX_ELC_SetValidationFailureMessageStrRef(16777601);
                }
                else
                    NWNX_ELC_SkipValidationFailure();
            }
            else
                NWNX_ELC_SkipValidationFailure();

            break;
        }
    }
}

/*
int elc_ConvertFavoriteEnemyToFameShopHex(int nFeat);

int elc_ConvertFavoriteEnemyToFameShopHex(int nFeat)
{
    switch(nFeat)
    {
        case FEAT_FAVORED_ENEMY_DWARF: return FAMESHOP_RANGER_FAVORED_ENEMY_DWARF;
        case FEAT_FAVORED_ENEMY_ELF: return FAMESHOP_RANGER_FAVORED_ENEMY_ELF;
        case FEAT_FAVORED_ENEMY_GNOME: return FAMESHOP_RANGER_FAVORED_ENEMY_GNOME;
        case FEAT_FAVORED_ENEMY_HALFELF: return FAMESHOP_RANGER_FAVORED_ENEMY_HALFELF;
        case FEAT_FAVORED_ENEMY_HALFLING: return FAMESHOP_RANGER_FAVORED_ENEMY_HALFLING;
        case FEAT_FAVORED_ENEMY_HALFORC: return FAMESHOP_RANGER_FAVORED_ENEMY_HALFORC;
        case FEAT_FAVORED_ENEMY_HUMAN: return FAMESHOP_RANGER_FAVORED_ENEMY_HUMAN;
    }
    return 0;
}       */

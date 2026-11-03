#include "_inc_obelisk"
#include "_inc_factions"

///////////////////////////////////////////////////////////////////
//////////                constants                      //////////
///////////////////////////////////////////////////////////////////

const int BUFF_TYPE_LONG                = 1;
const int BUFF_TYPE_SHORT               = 2;
const int BUFF_TYPE_LEVELING            = 3;
const int BUFF_TYPE_BARD_SONG           = 4;
const int BUFF_TYPE_SWITCH_TO_CASH      = 5;
const int BUFF_TYPE_SWITCH_TO_CASHLESS  = 6;
const int BUFF_TYPE_SWITCH_TO_XP        = 7;
const int BUFF_TYPE_UPDATE_TOKEN        = 8;

const int SPELL_TARGET_HOSTILE          = 4; // crutch constant

const int BUFF_TYPE_LONG_BASE_COST      = 150;
const int BUFF_TYPE_SHORT_BASE_COST     = 100;
const int BUFF_TYPE_LEVELING_BASE_COST  = 100;
const int BUFF_TYPE_SONG_BASE_COST      = 10000;

const int BUFF_MIN_LEVEL                = 6;
const int BUFF_COST_INCREASE_PER_FAME   = 10000;

const int BUFF_PAYMENT_TYPE_CASH        = 1;
const int BUFF_PAYMENT_TYPE_CASHLESS    = 2;
const int BUFF_PAYMENT_TYPE_XP          = 3;

const string BUFF_COST_LONG             = "BUFF_COST_LONG";
const string BUFF_COST_SHORT            = "BUFF_COST_SHORT";
const string BUFF_COST_LEVELING         = "BUFF_COST_LEVELING";
const string BUFF_COST_SONG             = "BUFF_COST_SONG";

const string BUFF_FACTION_TAX_LONG      = "BUFF_FACTION_TAX_LONG";
const string BUFF_FACTION_TAX_SHORT     = "BUFF_FACTION_TAX_SHORT";
const string BUFF_FACTION_TAX_LEVELING  = "BUFF_FACTION_TAX_LEVELING";
const string BUFF_FACTION_TAX_SONG      = "BUFF_FACTION_TAX_SONG";

///////////////////////////////////////////////////////////////////
//////////                prototypes                     //////////
///////////////////////////////////////////////////////////////////

//
void npc_Caster_ActionCastSpell(object oCaster, object oTarget, int nSpell, int nMetamMagic = METAMAGIC_EXTEND, int nCasterLevel = 40, int nDispelDC = 58, int bInstantSpell = FALSE);

//
void npc_Caster_CastLongSpells(object oCaster, object oTarget, int iCasterLevel, int iDispelDC, int iCost, int nTaxes, int nPaymentType);

//
void npc_Caster_CastShortSpells(object oCaster, object oTarget, int iCasterLevel, int iDispelDC, int iCost, int nTaxes, int nPaymentType);

//
void npc_Caster_CastLevelingSpells(object oCaster, object oTarget, int iCasterLevel, int iDispelDC, int iCost, int nTaxes, int nPaymentType);

//
void npc_Caster_CastBardSong(object oCaster, object oTarget, int iCasterLevel, int iPerformSkill, int iCost, int nTaxes, int nPaymentType);

//
void npc_Caster_TakeMoney(object oPC, int iValue, int nPaymentType, int nTaxes, int bForce = FALSE);

//
int npc_Caster_GetPaymentType(object oPC);

//
void npc_Caster_SetPaymentType(object oPC, int nValue);

//
void npc_Caster_UpdatePaymentTypeToken(object oPC);

//
void npc_Caster_UpdateBuffCost(object oPC, int nPlayerLevel, int nPlayerFaction);

//
void npc_Caster_UpdateFactionGold(int nFaction, int nTaxes);

//
int npc_Caster_GetFactionGold(int nFaction);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void npc_Caster_ActionCastSpell(object oCaster, object oTarget, int nSpell, int nMetamMagic = METAMAGIC_EXTEND, int nCasterLevel = 40, int nDispelDC = 58, int bInstantSpell = FALSE)
{
    string sSpell = IntToString(nSpell);
    SetLocalInt(oCaster, sSpell + "_TARGET_TYPE_OVERRIDE", SPELL_TARGET_HOSTILE);
    SetLocalInt(oCaster, sSpell + "_CASTER_LEVEL_OVERRIDE", nCasterLevel);
    SetLocalInt(oCaster, sSpell + "_METAMAGIC_OVERRIDE", nMetamMagic);
    SetLocalInt(oCaster, "OVERRIDE_DC_VS_DISPEL_" + sSpell, nDispelDC);
    AssignCommand(oCaster, ActionCastSpellAtObject(nSpell, oTarget, nMetamMagic, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantSpell));
}

void npc_Caster_CastLongSpells(object oCaster, object oTarget, int iCasterLevel, int iDispelDC, int iCost, int nTaxes, int nPaymentType)
{
    AssignCommand(oCaster, ClearAllActions(TRUE));
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_SEE_INVISIBILITY, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_BLESS, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_AID, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_MAGE_ARMOR, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_IMPROVED_INVISIBILITY, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_FREEDOM_OF_MOVEMENT, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    DelayCommand(0.25, npc_Caster_TakeMoney(oTarget, iCost, nTaxes, nPaymentType));
}

void npc_Caster_CastShortSpells(object oCaster, object oTarget, int iCasterLevel, int iDispelDC, int iCost, int nTaxes, int nPaymentType)
{
    AssignCommand(oCaster, ClearAllActions(TRUE));
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_MONSTROUS_REGENERATION, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_REGENERATE, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_PRAYER, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_CLARITY, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_UNDEATHS_ETERNAL_FOE, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_TRUE_SEEING, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    DelayCommand(0.25, npc_Caster_TakeMoney(oTarget, iCost, nTaxes, nPaymentType));
}

void npc_Caster_CastLevelingSpells(object oCaster, object oTarget, int iCasterLevel, int iDispelDC, int iCost, int nTaxes, int nPaymentType)
{
    AssignCommand(oCaster, ClearAllActions(TRUE));
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_BULLS_STRENGTH, METAMAGIC_EMPOWER | METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_CATS_GRACE, METAMAGIC_EMPOWER | METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_ENDURANCE, METAMAGIC_EMPOWER | METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_OWLS_WISDOM, METAMAGIC_EMPOWER | METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_EAGLE_SPLEDOR, METAMAGIC_EMPOWER | METAMAGIC_EXTEND, iCasterLevel, iDispelDC);

    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_GREATER_MAGIC_WEAPON, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_KEEN_EDGE, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_BLESS_WEAPON, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_MAGIC_VESTMENT, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_BARKSKIN, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    npc_Caster_ActionCastSpell(oCaster, oTarget, SPELL_SHIELD_OF_FAITH, METAMAGIC_EXTEND, iCasterLevel, iDispelDC);
    DelayCommand(0.25, npc_Caster_TakeMoney(oTarget, iCost, nTaxes, nPaymentType));
}

void npc_Caster_CastBardSong(object oCaster, object oTarget, int iCasterLevel, int iPerformSkill, int iCost, int nTaxes, int nPaymentType)
{
    SQLocals_SetInt(oTarget, "BARD_SONG_CASTER_LEVEL", iCasterLevel);
    SQLocals_SetInt(oTarget, "BARD_SONG_PERFORM_SKILL", iPerformSkill);
    NWNX_Creature_DoItemCastSpell(oTarget, oTarget, GetLocation(oTarget), SPELL_BARD_SONG, iCasterLevel, 0.5);
    DelayCommand(0.25, npc_Caster_TakeMoney(oTarget, iCost, nTaxes, nPaymentType, TRUE));
}

void npc_Caster_TakeMoney(object oPC, int iValue, int nTaxes, int nPaymentType, int bForce = FALSE)
{
    if (GetCurrentAction(OBJECT_SELF) == ACTION_CASTSPELL || bForce)
    {
        switch(nPaymentType)
        {
            case BUFF_PAYMENT_TYPE_CASH:
                TakeGoldFromCreature(iValue, oPC, TRUE);
            break;
            case BUFF_PAYMENT_TYPE_CASHLESS:
                bank_DecrementAccountBalance(oPC, iValue);
            break;
            case BUFF_PAYMENT_TYPE_XP:
            {
                generic_TakeXPFromCreature(oPC, GetXP(oPC)/100);
            }
            break;
        }
        npc_Caster_UpdateFactionGold(players_GetFaction(oPC), nTaxes);
    }
}

int npc_Caster_GetPaymentType(object oPC)
{
    string sAccount = GetPCPlayerName(oPC);
    string sSQL = "SELECT t.take_xp_for_buff FROM players t WHERE t.name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    else
        return 0;
}

void npc_Caster_SetPaymentType(object oPC, int nValue)
{
    string sAccount = GetPCPlayerName(oPC);
    string sSQL = "UPDATE players t SET t.take_xp_for_buff = ? WHERE t.name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, nValue);
    NWNX_SQL_PreparedString(1, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    npc_Caster_UpdatePaymentTypeToken(oPC);
}

void npc_Caster_UpdatePaymentTypeToken(object oPC)
{
    string sTokenText = "Cash";
    int nPaymentType = npc_Caster_GetPaymentType(oPC);
    switch(nPaymentType)
    {
        case BUFF_PAYMENT_TYPE_CASHLESS: sTokenText = "Cashless"; break;
        case BUFF_PAYMENT_TYPE_XP: sTokenText = "XP"; break;
    }
    NWNX_Player_SetCustomToken(oPC, CORMYR_CUSTOM_TOKEN_BUFF_PAYMENT_TYPE, ColorText(sTokenText, TXT_COLOR_GREEN_L));
}

void npc_Caster_UpdateBuffCost(object oPC, int nPlayerLevel, int nPlayerFaction)
{
    float fFamePriceIncreaseCoeff = IntToFloat(100 + factions_GetTotalFactionsFame()/BUFF_COST_INCREASE_PER_FAME)/100.0;
    string nFactionColor = players_GetFactionColor(nPlayerFaction);
    int nObelisksOwnedByFaction = obelisk_CountOwnedByFaction(nPlayerFaction);

    int nFullBuffCostLong = FloatToInt(IntToFloat(nPlayerLevel * BUFF_TYPE_LONG_BASE_COST) * fFamePriceIncreaseCoeff);
    int nFameTaxesLong = nFullBuffCostLong - nPlayerLevel * BUFF_TYPE_LONG_BASE_COST;
    int nObeliskDiscountLong = FloatToInt(IntToFloat(nPlayerLevel * BUFF_TYPE_LONG_BASE_COST) * OBELISK_BUFF_COST_DECREASE_PERCENT/100.0) * nObelisksOwnedByFaction;
    int nFactionTaxesLong = nFameTaxesLong + nObeliskDiscountLong;
    int nFinalCostLong = nFullBuffCostLong - nObeliskDiscountLong;
    // set locals
    SetLocalInt(oPC, BUFF_COST_LONG, nFinalCostLong);
    SetLocalInt(oPC, BUFF_FACTION_TAX_LONG, nFactionTaxesLong);
    // update token
    string sFactionStringLong = nObeliskDiscountLong > 0 ? ColorText("-" + IntToString(nObeliskDiscountLong), nFactionColor) : "";
    string sTotalFameStringLong = nFameTaxesLong > 0 ? ColorText("+" + IntToString(nFameTaxesLong), TXT_COLOR_WHITE_T) : "";
    NWNX_Player_SetCustomToken(oPC, CORMYR_CUSTOM_TOKEN_BUFF_TYPE_LONG, IntToString(BUFF_TYPE_LONG_BASE_COST) + "*" + IntToString(nPlayerLevel) + sFactionStringLong +
                                                                         sTotalFameStringLong + "=" + IntToString(nFinalCostLong));

    int nFullBuffCostShort = FloatToInt(IntToFloat(nPlayerLevel * BUFF_TYPE_SHORT_BASE_COST) * fFamePriceIncreaseCoeff);
    int nFameTaxesShort = nFullBuffCostShort - nPlayerLevel * BUFF_TYPE_SHORT_BASE_COST;
    int nObeliskDiscountShort = FloatToInt(IntToFloat(nPlayerLevel * BUFF_TYPE_SHORT_BASE_COST) * OBELISK_BUFF_COST_DECREASE_PERCENT/100.0) * nObelisksOwnedByFaction;
    int nFactionTaxesShort = nFameTaxesShort + nObeliskDiscountShort;
    int nFinalCostShort = nFullBuffCostShort - nObeliskDiscountShort;
    // set locals
    SetLocalInt(oPC, BUFF_COST_SHORT, nFinalCostShort);
    SetLocalInt(oPC, BUFF_FACTION_TAX_SHORT, nFactionTaxesShort);
    // update token
    string sFactionStringShort = nObeliskDiscountShort > 0 ? ColorText("-" + IntToString(nObeliskDiscountShort), nFactionColor) : "";
    string sTotalFameStringShort = nFameTaxesShort > 0 ? ColorText("+" + IntToString(nFameTaxesShort), TXT_COLOR_WHITE_T) : "";
    NWNX_Player_SetCustomToken(oPC, CORMYR_CUSTOM_TOKEN_BUFF_TYPE_SHORT, IntToString(BUFF_TYPE_SHORT_BASE_COST) + "*" + IntToString(nPlayerLevel) + sFactionStringShort +
                                                                         sTotalFameStringShort + "=" + IntToString(nFinalCostShort));

    int nFullBuffCostLeveling = FloatToInt(IntToFloat(nPlayerLevel * BUFF_TYPE_LEVELING_BASE_COST) * fFamePriceIncreaseCoeff);
    int nFameTaxesLeveling = nFullBuffCostLeveling - nPlayerLevel * BUFF_TYPE_LEVELING_BASE_COST;
    int nObeliskDiscountLeveling = FloatToInt(IntToFloat(nPlayerLevel * BUFF_TYPE_LEVELING_BASE_COST) * OBELISK_BUFF_COST_DECREASE_PERCENT/100.0) * nObelisksOwnedByFaction;
    int nFactionTaxesLeveling = nFameTaxesLeveling + nObeliskDiscountLeveling;
    int nFinalCostLeveling = nFullBuffCostLeveling - nObeliskDiscountLeveling;
    // set locals
    SetLocalInt(oPC, BUFF_COST_LEVELING, nFinalCostLeveling);
    SetLocalInt(oPC, BUFF_FACTION_TAX_LEVELING, nFactionTaxesLeveling);
    // update token
    string sFactionStringLeveling = nObeliskDiscountLeveling > 0 ? ColorText("-" + IntToString(nObeliskDiscountLeveling), nFactionColor) : "";
    string sTotalFameStringLeveling = nFameTaxesLeveling > 0 ? ColorText("+" + IntToString(nFameTaxesLeveling), TXT_COLOR_WHITE_T) : "";
    NWNX_Player_SetCustomToken(oPC, CORMYR_CUSTOM_TOKEN_BUFF_TYPE_LEVELING, IntToString(BUFF_TYPE_LEVELING_BASE_COST) + "*" + IntToString(nPlayerLevel) + sFactionStringLeveling +
                                                                            sTotalFameStringLeveling + "=" + IntToString(nFinalCostLeveling));

    int nFullBuffCostSong = FloatToInt(IntToFloat(BUFF_TYPE_SONG_BASE_COST) * fFamePriceIncreaseCoeff);
    int nFameTaxesSong = nFullBuffCostSong - BUFF_TYPE_SONG_BASE_COST;
    int nObeliskDiscountSong = FloatToInt(IntToFloat(BUFF_TYPE_SONG_BASE_COST) * OBELISK_BUFF_COST_DECREASE_PERCENT/100.0) * nObelisksOwnedByFaction;
    int nFactionTaxesSong = nFameTaxesSong + nObeliskDiscountSong;
    int nFinalCostSong = nFullBuffCostSong - nObeliskDiscountSong;
    // set locals
    SetLocalInt(oPC, BUFF_COST_SONG, nFinalCostSong);
    SetLocalInt(oPC, BUFF_FACTION_TAX_SONG, nFactionTaxesSong);
    // update token
    string sFactionStringSong = nObeliskDiscountSong > 0 ? ColorText("-" + IntToString(nObeliskDiscountSong), nFactionColor) : "";
    string sTotalFameStringSong = nFameTaxesSong > 0 ? ColorText("+" + IntToString(nFameTaxesSong), TXT_COLOR_WHITE_T) : "";
    NWNX_Player_SetCustomToken(oPC, CORMYR_CUSTOM_TOKEN_BUFF_TYPE_SONG, IntToString(BUFF_TYPE_SONG_BASE_COST) + sFactionStringSong + sTotalFameStringSong + "=" + IntToString(nFinalCostSong));


}

void npc_Caster_UpdateFactionGold(int nFaction, int nTaxes)
{
    string sSQL = "UPDATE factions F SET F.faction_gold = faction_gold + ? WHERE F.id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, nTaxes);
    NWNX_SQL_PreparedInt(1, nFaction);
    NWNX_SQL_ExecutePreparedQuery();
}

int npc_Caster_GetFactionGold(int nFaction)
{
    string sSQL = "select F.faction_gold from factions F WHERE F.id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, nFaction);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    else
        return 0;
}

//void main(){}

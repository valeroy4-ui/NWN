#include "_inc_fameshop"

///////////////////////////////////////////////////////////////////
//////////                  Prototypes                   //////////
///////////////////////////////////////////////////////////////////

//
void RefreshTokensForSpellUpgrades(object oPC);

//
int GetSpellUpgradeLevel(object oPC, int iSpellID);

//
void SetSpellUpgradeLevel(object oPC, int iSpellID, int nLevel);

//
int TryToUnlockSpellUpgradeLevel(object oPC, int iSpellID, int nLevel, int nCost);

//
string GetSpellUpgradeColumnFromSpellID(int iSpellID);

//
int GetPCSongBitArray(object oPC);

// get json key for specific onhit nSpellID
string GetJsonKeyFromOnhitSpell(int nSpellID);

// load from database or init onhits cash json
json LoadOrInitCustomOnhits(string sAccount);

// set custom bonus for specific custom onhit spell
int SetCustomOnhitFameBonus(object oPC, int nSpellID, int nValue);

// get custom bonus for specific custom onhit spell
int GetCustomOnhitFameBonus(object oPC, int nSpellID);

// get max bonus for specific onhit
int GetMaxBonusForSpecificOnhitSpell(int nSpellID);

// try to by onhit bonus
int TryToUnlockCustomOnhitBonus(object oPC, int nSpellID, int iBonus, int iCost);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void RefreshTokensForSpellUpgrades(object oPC)
{
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_FREEFAME, IntToString(GetFreeFame(oPC)));

    // Inferno tokens
    int nInfernoUpgradeLevel = GetSpellUpgradeLevel(oPC, SPELL_INFERNO);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_INFERNO_LEVEL_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_INFERNO_LEVEL_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_INFERNO_LEVEL_3, CONST_FAMESHOP_LOCKED);
    if(nInfernoUpgradeLevel >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_INFERNO_LEVEL_1, CONST_FAMESHOP_UNLOCKED);
    if(nInfernoUpgradeLevel >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_INFERNO_LEVEL_2, CONST_FAMESHOP_UNLOCKED);
    if(nInfernoUpgradeLevel >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_INFERNO_LEVEL_3, CONST_FAMESHOP_UNLOCKED);
    // EQ tokens
    int nEarthquakeUpgradeLevel = GetSpellUpgradeLevel(oPC, SPELL_EARTHQUAKE);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_EARTHQUAKE_LEVEL_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_EARTHQUAKE_LEVEL_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_EARTHQUAKE_LEVEL_3, CONST_FAMESHOP_LOCKED);
    if(nEarthquakeUpgradeLevel >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_EARTHQUAKE_LEVEL_1, CONST_FAMESHOP_UNLOCKED);
    if(nEarthquakeUpgradeLevel >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_EARTHQUAKE_LEVEL_2, CONST_FAMESHOP_UNLOCKED);
    if(nEarthquakeUpgradeLevel >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_EARTHQUAKE_LEVEL_3, CONST_FAMESHOP_UNLOCKED);
    // Bard Song token
    int nBardSongUpgradeLevel = GetSpellUpgradeLevel(oPC, SPELL_BARD_SONG);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_TEMP_HITPOINTS, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_REMOVE_FEAR, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_NEGATIVE_IMMUNITY, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_REGENERATION, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_CONCEALMENT, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_MAGIC_DAMAGE, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_BALAGARN_IRON_HORN_DC, CONST_FAMESHOP_LOCKED);
    if(nBardSongUpgradeLevel >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_TEMP_HITPOINTS, CONST_FAMESHOP_UNLOCKED);
    if(nBardSongUpgradeLevel >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_REMOVE_FEAR, CONST_FAMESHOP_UNLOCKED);
    if(nBardSongUpgradeLevel >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_NEGATIVE_IMMUNITY, CONST_FAMESHOP_UNLOCKED);
    if(nBardSongUpgradeLevel >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_REGENERATION, CONST_FAMESHOP_UNLOCKED);
    if(nBardSongUpgradeLevel >= 5) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_CONCEALMENT, CONST_FAMESHOP_UNLOCKED);
    if(nBardSongUpgradeLevel >= 6) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_SONG_MAGIC_DAMAGE, CONST_FAMESHOP_UNLOCKED);
    if(nBardSongUpgradeLevel >= 7) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_BARD_BALAGARN_IRON_HORN_DC, CONST_FAMESHOP_UNLOCKED);
    // spell Poison token
    int nPoisonUpgradeLevel = GetSpellUpgradeLevel(oPC, SPELL_POISON);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_POISON_LEVEL_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_POISON_LEVEL_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_POISON_LEVEL_3, CONST_FAMESHOP_LOCKED);
    if(nPoisonUpgradeLevel >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_POISON_LEVEL_1, CONST_FAMESHOP_UNLOCKED);
    if(nPoisonUpgradeLevel >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_POISON_LEVEL_2, CONST_FAMESHOP_UNLOCKED);
    if(nPoisonUpgradeLevel >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_FAMESHOP_SPELL_POISON_LEVEL_3, CONST_FAMESHOP_UNLOCKED);
    // spell Assassination Mark
    int nAssassinMark = GetCustomOnhitFameBonus(oPC, SPELL_ASSASSINATION_MARK);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_ASSASSINATION_MARK_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_ASSASSINATION_MARK_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_ASSASSINATION_MARK_3, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_ASSASSINATION_MARK_4, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_ASSASSINATION_MARK_5, CONST_FAMESHOP_LOCKED);
    if(nAssassinMark >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_ASSASSINATION_MARK_1, CONST_FAMESHOP_UNLOCKED);
    if(nAssassinMark >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_ASSASSINATION_MARK_2, CONST_FAMESHOP_UNLOCKED);
    if(nAssassinMark >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_ASSASSINATION_MARK_3, CONST_FAMESHOP_UNLOCKED);
    if(nAssassinMark >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_ASSASSINATION_MARK_4, CONST_FAMESHOP_UNLOCKED);
    if(nAssassinMark >= 5) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_ASSASSINATION_MARK_5, CONST_FAMESHOP_UNLOCKED);
    // spell Dark Hit token
    int nDarkHit = GetCustomOnhitFameBonus(oPC, SPELL_DARK_HIT);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_HIT_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_HIT_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_HIT_3, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_HIT_4, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_HIT_5, CONST_FAMESHOP_LOCKED);
    if(nDarkHit >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_HIT_1, CONST_FAMESHOP_UNLOCKED);
    if(nDarkHit >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_HIT_2, CONST_FAMESHOP_UNLOCKED);
    if(nDarkHit >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_HIT_3, CONST_FAMESHOP_UNLOCKED);
    if(nDarkHit >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_HIT_4, CONST_FAMESHOP_UNLOCKED);
    if(nDarkHit >= 5) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_HIT_5, CONST_FAMESHOP_UNLOCKED);
    // spell Open Wounds token
    int nOpenWounds = GetCustomOnhitFameBonus(oPC, SPELL_OPEN_WOUNDS);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_OPEN_WOUNDS_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_OPEN_WOUNDS_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_OPEN_WOUNDS_3, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_OPEN_WOUNDS_4, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_OPEN_WOUNDS_5, CONST_FAMESHOP_LOCKED);
    if(nOpenWounds >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_OPEN_WOUNDS_1, CONST_FAMESHOP_UNLOCKED);
    if(nOpenWounds >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_OPEN_WOUNDS_2, CONST_FAMESHOP_UNLOCKED);
    if(nOpenWounds >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_OPEN_WOUNDS_3, CONST_FAMESHOP_UNLOCKED);
    if(nOpenWounds >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_OPEN_WOUNDS_4, CONST_FAMESHOP_UNLOCKED);
    if(nOpenWounds >= 5) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_OPEN_WOUNDS_5, CONST_FAMESHOP_UNLOCKED);
    // spell Painful Hit
    int nPainfulHit = GetCustomOnhitFameBonus(oPC, SPELL_PAINFUL_HIT);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_PAINFUL_HIT_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_PAINFUL_HIT_2, CONST_FAMESHOP_LOCKED);
    if(nPainfulHit >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_PAINFUL_HIT_1, CONST_FAMESHOP_UNLOCKED);
    if(nPainfulHit >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_PAINFUL_HIT_2, CONST_FAMESHOP_UNLOCKED);
    // spell Dark Strike
    int nDarkStrike = GetCustomOnhitFameBonus(oPC, SPELL_DARK_STRIKE);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_STRIKE_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_STRIKE_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_STRIKE_3, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_STRIKE_4, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_STRIKE_5, CONST_FAMESHOP_LOCKED);
    if(nDarkStrike >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_STRIKE_1, CONST_FAMESHOP_UNLOCKED);
    if(nDarkStrike >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_STRIKE_2, CONST_FAMESHOP_UNLOCKED);
    if(nDarkStrike >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_STRIKE_3, CONST_FAMESHOP_UNLOCKED);
    if(nDarkStrike >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_STRIKE_4, CONST_FAMESHOP_UNLOCKED);
    if(nDarkStrike >= 5) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DARK_STRIKE_5, CONST_FAMESHOP_UNLOCKED);
    // spell Scare
    int nScare = GetCustomOnhitFameBonus(oPC, SPELL_SCARE);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_SCARE_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_SCARE_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_SCARE_3, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_SCARE_4, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_SCARE_5, CONST_FAMESHOP_LOCKED);
    if(nScare >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_SCARE_1, CONST_FAMESHOP_UNLOCKED);
    if(nScare >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_SCARE_2, CONST_FAMESHOP_UNLOCKED);
    if(nScare >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_SCARE_3, CONST_FAMESHOP_UNLOCKED);
    if(nScare >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_SCARE_4, CONST_FAMESHOP_UNLOCKED);
    if(nScare >= 5) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_SCARE_5, CONST_FAMESHOP_UNLOCKED);
    // spell Cormyr Sayanara
    int nCormyrSayanara = GetCustomOnhitFameBonus(oPC, SPELL_CORMYR_SAYANARA);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_CORMYR_SAYANARA_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_CORMYR_SAYANARA_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_CORMYR_SAYANARA_3, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_CORMYR_SAYANARA_4, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_CORMYR_SAYANARA_5, CONST_FAMESHOP_LOCKED);
    if(nCormyrSayanara >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_CORMYR_SAYANARA_1, CONST_FAMESHOP_UNLOCKED);
    if(nCormyrSayanara >= 2) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_CORMYR_SAYANARA_2, CONST_FAMESHOP_UNLOCKED);
    if(nCormyrSayanara >= 3) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_CORMYR_SAYANARA_3, CONST_FAMESHOP_UNLOCKED);
    if(nCormyrSayanara >= 4) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_CORMYR_SAYANARA_4, CONST_FAMESHOP_UNLOCKED);
    if(nCormyrSayanara >= 5) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_CORMYR_SAYANARA_5, CONST_FAMESHOP_UNLOCKED);
    // spell Cormyr Devast
    int nCormyrDevast = GetCustomOnhitFameBonus(oPC, SPELL_DEVASTATING_CRITICAL_1);
    NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DEVASTATING_CRITICAL_1, CONST_FAMESHOP_LOCKED);
    if(nCormyrDevast >= 1) NWNX_Player_SetCustomToken(oPC, TOKEN_SPELL_DEVASTATING_CRITICAL_1, CONST_FAMESHOP_UNLOCKED);
}

int GetSpellUpgradeLevel(object oPC, int iSpellID)
{
    string sColumn = GetSpellUpgradeColumnFromSpellID(iSpellID);
    if (sColumn == "")
    {
        WriteTimestampedLogEntry("Function GetSpellUpgradeLevel(..) Error. GetSpellUpgradeColumnFromSpellID(iSpellID) returned empty column. Input parameter iSpellID = " + IntToString(iSpellID));
        return 0;
    }
    string sCashVar = GetStringUpperCase(sColumn);
    int nResult = GetLocalInt(oPC, sCashVar);
    if(nResult)
        return nResult > 0 ? nResult : 0;

    string sAccount = GetPCPlayerName(oPC);
    string sSQL = "SELECT " + sColumn + " FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nResult = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    if(nResult > 0)
        SetLocalInt(oPC, sCashVar, nResult);
    else
        SetLocalInt(oPC, sCashVar, -1);

    return nResult;
}

void SetSpellUpgradeLevel(object oPC, int iSpellID, int nLevel)
{
    string sColumn = GetSpellUpgradeColumnFromSpellID(iSpellID);
    if (sColumn == "")
    {
        WriteTimestampedLogEntry("Function SetSpellUpgradeLevel(..) Error. GetSpellUpgradeColumnFromSpellID(iSpellID) returned empty column. Input parameter iSpellID = " + IntToString(iSpellID));
        return;
    }
    string sAccount = GetPCPlayerName(oPC);
    string sSQL = "UPDATE players SET " + sColumn + " = ? WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, nLevel);
    NWNX_SQL_PreparedString(1, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    string sCashVar = GetStringUpperCase(sColumn);
    DeleteLocalInt(oPC, sCashVar);
}

int TryToUnlockSpellUpgradeLevel(object oPC, int iSpellID, int nLevel, int nCost)
{

    int nFreeFame = GetFreeFame(oPC);
    int bSuccess = FALSE;
    int nCurrentSpellUpgradeLevel = GetSpellUpgradeLevel(oPC, iSpellID);

    if(nCurrentSpellUpgradeLevel >= nLevel)
    {
        SendMessageToPC(oPC, "The unlock failed. This or higher upgrade has already been purchased.");
        bSuccess = FALSE;
    }
    else if(nLevel - nCurrentSpellUpgradeLevel != 1)
    {
        SendMessageToPC(oPC, "The unlock failed. You should buy previous upgrades.");
        bSuccess = FALSE;
    }
    else if(nFreeFame >= nCost)
    {
        SetSpellUpgradeLevel(oPC, iSpellID, nLevel);
        SpendFame(oPC, nCost, FALSE, FALSE);
        SendMessageToPC(oPC, "The unlock was successfully completed. You spent " + IntToString(nCost)+ " fame. Available: " + IntToString(GetFreeFame(oPC)));
        bSuccess = TRUE;
        // refresh tokens
        RefreshTokensForSpellUpgrades(oPC);
    }
    else
    {
        SendMessageToPC(oPC, "Unlock failed: not enough fame. Need " + IntToString(nCost - nFreeFame) + ". Available: " + IntToString(nFreeFame));
        bSuccess = FALSE;
    }
    return bSuccess;
}

string GetSpellUpgradeColumnFromSpellID(int iSpellID)
{
    switch(iSpellID)
    {
        case SPELL_INFERNO:    return "inferno_lvl";
        case SPELL_EARTHQUAKE: return "earthquake_lvl";
        case SPELL_BARD_SONG:  return "bardsong_lvl";
        case SPELL_POISON:     return "poison_lvl";
    }
    return "";
}

int GetPCSongBitArray(object oPC)
{
    int nBitArray = 0;
    int nPcSongUpgradeLevel = GetSpellUpgradeLevel(oPC, SPELL_BARD_SONG);
    if(nPcSongUpgradeLevel >= 1)
        nBitArray |= FAMESHOP_BARD_SONG_TEMP_HITPOINTS;
    if(nPcSongUpgradeLevel >= 2)
        nBitArray |= FAMESHOP_BARD_SONG_REMOVE_FEAR;
    if(nPcSongUpgradeLevel >= 3)
        nBitArray |= FAMESHOP_BARD_SONG_NEGATIVE_IMMUNITY;
    if(nPcSongUpgradeLevel >= 4)
        nBitArray |= FAMESHOP_BARD_SONG_REGENERATION;
    if(nPcSongUpgradeLevel >= 5)
        nBitArray |= FAMESHOP_BARD_SONG_CONCEALMENT;
    if(nPcSongUpgradeLevel >= 6)
        nBitArray |= FAMESHOP_BARD_SONG_MAGIC_DAMAGE;
    if(nPcSongUpgradeLevel >= 7)
        nBitArray |= FAMESHOP_BARD_BALAGARN_IRON_HORN_DC;
    return nBitArray;
}

string GetJsonKeyFromOnhitSpell(int nSpellID)
{
    switch(nSpellID)
    {
        case SPELL_ASSASSINATION_MARK:      return "assassn_mark";
        case SPELL_DARK_HIT:                return "dark_hit";
        //case SPELL_CANT_SEE_ME:           return "cant_see_me";
        case SPELL_OPEN_WOUNDS:             return "open_wounds";
        case SPELL_PAINFUL_HIT:             return "painful_hit";
        case SPELL_DARK_STRIKE:             return "dark_strike";
        case SPELL_SCARE:                   return "assassn_spec_hit"; // assassin's paralize
        case SPELL_CORMYR_SAYANARA:         return "slayer_sayanara";  // fake spell for custom vorpal
        case SPELL_DEVASTATING_CRITICAL_1:  return "devast";           // fake spell for custom devast
    }
    return "";
}

json LoadOrInitCustomOnhits(string sAccount)
{
    json jCustomOnhits;
    string sSQL = "SELECT onhit_cast FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    if (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        jCustomOnhits = JsonParse(NWNX_SQL_ReadDataInActiveRow());
    }
    // if database value is empty when create new json
    if (JsonGetType(jCustomOnhits) == JSON_TYPE_NULL)
    {
        jCustomOnhits = JSON_OBJECT;
        JsonObjectSetInplace(jCustomOnhits, "assassn_mark",     JsonInt(0));
        JsonObjectSetInplace(jCustomOnhits, "dark_hit",         JsonInt(0));
        // JsonObjectSetInplace(jCustomOnhits, "cant_see_me",      JsonInt(0));
        JsonObjectSetInplace(jCustomOnhits, "open_wounds",      JsonInt(0));
        JsonObjectSetInplace(jCustomOnhits, "painful_hit",      JsonInt(0));
        JsonObjectSetInplace(jCustomOnhits, "dark_strike",      JsonInt(0));
        JsonObjectSetInplace(jCustomOnhits, "assassn_spec_hit", JsonInt(0));
        JsonObjectSetInplace(jCustomOnhits, "slayer_sayanara",  JsonInt(0));
        JsonObjectSetInplace(jCustomOnhits, "devast",           JsonInt(0));
    }
    return jCustomOnhits;
}

int SetCustomOnhitFameBonus(object oPC, int nSpellID, int nValue)
{
    json jCustomOnhits = GetLocalJson(oPC, "CUSTOM_ONHITS");
    string sAccount = GetPCPlayerName(oPC);
    // if null when load from database or init new json
    if(JsonGetType(jCustomOnhits) == JSON_TYPE_NULL)
        jCustomOnhits = LoadOrInitCustomOnhits(sAccount);
    // get key string from spell id
    string sKey = GetJsonKeyFromOnhitSpell(nSpellID);
    // set new value into json key
    JsonObjectSetInplace(jCustomOnhits, sKey, JsonInt(nValue));
    // prepare string for DB
    string sDump = JsonDump(jCustomOnhits);
    string sSQL = "UPDATE players SET onhit_cast = ? WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sDump);
    NWNX_SQL_PreparedString(1, sAccount);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        SetLocalJson(oPC, "CUSTOM_ONHITS", jCustomOnhits); // cash json at oPC
        //ServerShout(JsonDump(jCustomOnhits, 1));
        return TRUE;
    }
    else
        return FALSE;
}

int GetCustomOnhitFameBonus(object oPC, int nSpellID)
{
    // try to get json from local cash
    json jCustomOnhits = GetLocalJson(oPC, "CUSTOM_ONHITS");
    string sAccount = GetPCPlayerName(oPC);
    // if null when load from database or init new json
    if(JsonGetType(jCustomOnhits) == JSON_TYPE_NULL)
        jCustomOnhits = LoadOrInitCustomOnhits(sAccount);
    // cash json as local var at oPC
    SetLocalJson(oPC, "CUSTOM_ONHITS", jCustomOnhits);
    // get key string from spell id
    string sKey = GetJsonKeyFromOnhitSpell(nSpellID);
    // get value
    json jValue = JsonObjectGet(jCustomOnhits, sKey);
    if(JsonGetType(jValue) == JSON_TYPE_NULL)
        return 0; // if key is not exists
    return JsonGetInt(jValue);
}

int GetMaxBonusForSpecificOnhitSpell(int nSpellID)
{
    switch(nSpellID)
    {
        case SPELL_ASSASSINATION_MARK:      return 5;
        case SPELL_DARK_HIT:                return 5;
        //case SPELL_CANT_SEE_ME:            // no
        case SPELL_OPEN_WOUNDS:             return 5;
        case SPELL_PAINFUL_HIT:             return 2;
        case SPELL_DARK_STRIKE:             return 5;
        case SPELL_SCARE:                   return 5;
        case SPELL_CORMYR_SAYANARA:         return 5;
        case SPELL_DEVASTATING_CRITICAL_1:  return 1;
    }
    return 0;
}

int TryToUnlockCustomOnhitBonus(object oPC, int nSpellID, int iBonus, int iCost)
{
    string sAccount = GetPCPlayerName(oPC);
    int iFreeFame = GetFreeFame(oPC);
    int iSuccess = FALSE;
    int iCurrentCustomOnhitBonus = 0;
    // determine current bonus
    switch(nSpellID)
    {
        case SPELL_ASSASSINATION_MARK:     // max +5  rog and ass
        case SPELL_DARK_HIT:               // max +5  ass
        //case SPELL_CANT_SEE_ME:            // no fameshop
        case SPELL_OPEN_WOUNDS:            // max +5  slayer
        case SPELL_PAINFUL_HIT:            // max +2  slayer and monk
        case SPELL_DARK_STRIKE:            // max +5  rog
        case SPELL_SCARE:                  // max +5  ass paralize
        case SPELL_CORMYR_SAYANARA:        // max +5  slayer
        case SPELL_DEVASTATING_CRITICAL_1: // max +1  fighter
            iCurrentCustomOnhitBonus = GetCustomOnhitFameBonus(oPC, nSpellID);
        break;
        default:
            WriteLog("Wrong custom onhit nSpellID: " + IntToString(nSpellID), LOG_LEVEL_ERROR);
            return FALSE;
    }
    // get max possible bonus
    int nMaxBonusLevel = GetMaxBonusForSpecificOnhitSpell(nSpellID);
    if(iCurrentCustomOnhitBonus == nMaxBonusLevel)
    {
        SendMessageToPC(oPC, "The unlock failed. Maximum bonus reached.");
        iSuccess = FALSE;
    }
    else if(iCurrentCustomOnhitBonus >= iBonus)
    {
        SendMessageToPC(oPC, "The unlock failed. This or higher bonus has already been purchased.");
        iSuccess = FALSE;
    }
    else if(iBonus - iCurrentCustomOnhitBonus != 1)
    {
        SendMessageToPC(oPC, "The unlock failed. You should buy previous bonus.");
        iSuccess = FALSE;
    }
    else if(iFreeFame >= iCost && SetCustomOnhitFameBonus(oPC, nSpellID, iBonus))
    {
        SpendFame(oPC, iCost, FALSE, FALSE);
        SendMessageToPC(oPC, "The unlock was successfully completed. You spent " + IntToString(iCost)+ " fame. Available: " + IntToString(GetFreeFame(oPC)));
        iSuccess = TRUE;
        // update tokens
        RefreshTokensForSpellUpgrades(oPC);
    }
    else
    {
        SendMessageToPC(oPC, "Unlock failed: not enough fame. Need " + IntToString(iCost - iFreeFame) + ". Available: " + IntToString(iFreeFame));
        iSuccess = FALSE;
    }
    return iSuccess;
}



//void main() {}

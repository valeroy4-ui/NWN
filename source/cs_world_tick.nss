#include "nwnx_admin"
#include "_inc_generic"
#include "_inc_champ_boss"
#include "nwnx_item"

const string GOLD_MERCHANT_HOUR                 = "GOLD_MERCHANT_HOUR";  // local var name
const string GOLD_MERCHANT_MINUTE               = "GOLD_MERCHANT_MINUTE";  // local var name
const int GOLD_MINUTE_MIN_WAIT_TIME             = 120;  // min value for random
const int GOLD_MINUTE_MAX_WAIT_TIME             = 120;  // max value for random
const int GOLD_RANDOM_MIN                       = 1000000;  // min value for random
const int GOLD_RANDOM_MAX                       = 1500000;  // max value for random
const float GOLD_DELAY_TIME                     = 300.0;  // delay before gold generate

const string GRAND_CHAMPION_HOUR                = "GRAND_CHAMPION_HOUR";  // local var name
const string GRAND_CHAMPION_MINUTE              = "GRAND_CHAMPION_MINUTE";  // local var name
const int GRAND_CHAMPION_MINUTE_MIN_WAIT_TIME   = 15;  // min value for random
const int GRAND_CHAMPION_MINUTE_MAX_WAIT_TIME   = 30;  // max value for random

const string TEMPLE_REFRESH_HOUR                = "TEMPLE_REFRESH_HOUR";  // local var name
const string TEMPLE_REFRESH_MINUTE              = "TEMPLE_REFRESH_MINUTE";  // local var name
const int TEMPLE_REFRESH_MINUTE_MIN_WAIT_TIME   = 40;  // min value for random
const int TEMPLE_REFRESH_MINUTE_MAX_WAIT_TIME   = 120;  // max value for random

// generates random hour and minute (current_time + random(range(iMinuteMin, iMinuteMax))
// and stores it as SQLocals with sHourLocalName and sMinuteLocalName variable names
// also return interval between current time and generated in minutes
int GenerateTimeAndGetIntervalLength(object oHolder, string sHourLocalName, string sMinuteLocalName, int iCurrentHour, int iCurrentMinute, int iMinuteMin, int iMinuteMax);

// return random temple merchant
object GetRandomTempleMerchant();

// generates goods at temple
void CreateTempleStoreGoods(object oHolder, object oTempleMerchant, int nIntervalLength);


void main()
{
    int iCurrentHour;
    int iCurrentMinute;

    sqlquery SqlTime = SqlPrepareQueryObject(GetModule(), "SELECT strftime('%H','now', 'localtime'), strftime('%M','now', 'localtime')");
    if (SqlStep(SqlTime))
    {
        iCurrentHour = SqlGetInt(SqlTime, 0);
        iCurrentMinute = SqlGetInt(SqlTime, 1);
    }

    object oHolder  = GetModule();

    SetLocalInt(oHolder, SERVER_HOUR, iCurrentHour);
    SetLocalInt(oHolder, SERVER_MINUTE, iCurrentMinute);

    // World events restored; restart/password policy remains with the operator.
    ExportAllCharacters();
    DelayCommand(60.0, ExecuteScript("cs_world_tick", GetModule()));

    // if merchant don't has min gold generate event
    object oMerchant = GetObjectByTag("desert_jert_store");
    if(GetStoreGold(oMerchant) < GOLD_RANDOM_MIN)
    {
        int iGoldHour   = SQLocals_GetInt(oHolder, GOLD_MERCHANT_HOUR);
        int iGoldMinute = SQLocals_GetInt(oHolder, GOLD_MERCHANT_MINUTE);

        if (iGoldHour == iCurrentHour && iGoldMinute == iCurrentMinute &&
            SQLocals_IsSet(oHolder, GOLD_MERCHANT_HOUR, SQLOCALS_TYPE_INT) &&
            SQLocals_IsSet(oHolder, GOLD_MERCHANT_MINUTE, SQLOCALS_TYPE_INT))
        {
            int iRandomGold = GOLD_RANDOM_MIN + Random(GOLD_RANDOM_MAX - GOLD_RANDOM_MIN) + 1;
            GenerateTimeAndGetIntervalLength(oHolder, GOLD_MERCHANT_HOUR, GOLD_MERCHANT_MINUTE, iCurrentHour, iCurrentMinute,
                                               GOLD_MINUTE_MIN_WAIT_TIME, GOLD_MINUTE_MAX_WAIT_TIME);
            ServerShout(ColorText("Someone spotted gnomes with bags of money near Suzail. Soon there will be money in the store! Five minutes left.", TXT_COLOR_ORANGE));

            DelayCommand(GOLD_DELAY_TIME, SetStoreGold(oMerchant, /* GetStoreGold(oMerchant) +  */ iRandomGold));
            DelayCommand(GOLD_DELAY_TIME, ServerShout(ColorText("The money was brought to the main Cormyrean store. It's good time to sell your loot!", TXT_COLOR_ORANGE)));
        }
        else if (!SQLocals_IsSet(oHolder, GOLD_MERCHANT_HOUR, SQLOCALS_TYPE_INT) &&
                 !SQLocals_IsSet(oHolder, GOLD_MERCHANT_MINUTE, SQLOCALS_TYPE_INT))
            GenerateTimeAndGetIntervalLength(oHolder, GOLD_MERCHANT_HOUR, GOLD_MERCHANT_MINUTE, iCurrentHour, iCurrentMinute,
                                               GOLD_MINUTE_MIN_WAIT_TIME, GOLD_MINUTE_MAX_WAIT_TIME);
    }
    // grand champions time
    int iGrandChampionSpawnHour   = SQLocals_GetInt(oHolder, GRAND_CHAMPION_HOUR);
    int iGrandChampionSpawnMinute = SQLocals_GetInt(oHolder, GRAND_CHAMPION_MINUTE);
    int nGrandChampionMinTime     = GRAND_CHAMPION_MINUTE_MIN_WAIT_TIME;
    int nGrandChampionMaxTime     = GRAND_CHAMPION_MINUTE_MAX_WAIT_TIME;
    if(!db_GetIsPrimeTime())
    {
        nGrandChampionMinTime = nGrandChampionMinTime * 4;
        nGrandChampionMaxTime = nGrandChampionMaxTime * 4;
    }
    if (iGrandChampionSpawnHour == iCurrentHour && iGrandChampionSpawnMinute == iCurrentMinute &&
        SQLocals_IsSet(oHolder, GRAND_CHAMPION_HOUR, SQLOCALS_TYPE_INT) &&
        SQLocals_IsSet(oHolder, GRAND_CHAMPION_MINUTE, SQLOCALS_TYPE_INT))
    {
        champion_EliteRandomSpawn();
        GenerateTimeAndGetIntervalLength(oHolder, GRAND_CHAMPION_HOUR, GRAND_CHAMPION_MINUTE, iCurrentHour, iCurrentMinute,
                                         nGrandChampionMinTime, nGrandChampionMaxTime);
    }
    else if (!SQLocals_IsSet(oHolder, GRAND_CHAMPION_HOUR, SQLOCALS_TYPE_INT) &&
             !SQLocals_IsSet(oHolder, GRAND_CHAMPION_MINUTE, SQLOCALS_TYPE_INT))
        GenerateTimeAndGetIntervalLength(oHolder, GRAND_CHAMPION_HOUR, GRAND_CHAMPION_MINUTE, iCurrentHour, iCurrentMinute,
                                         nGrandChampionMinTime, nGrandChampionMaxTime);

    // temple heals and potions staff
    int nTempleRefreshHour = SQLocals_GetInt(oHolder, TEMPLE_REFRESH_HOUR);
    int nTempleRefreshMinute = SQLocals_GetInt(oHolder, TEMPLE_REFRESH_MINUTE);
    if (nTempleRefreshHour == iCurrentHour && nTempleRefreshMinute == iCurrentMinute &&
        SQLocals_IsSet(oHolder, TEMPLE_REFRESH_HOUR, SQLOCALS_TYPE_INT) &&
        SQLocals_IsSet(oHolder, TEMPLE_REFRESH_MINUTE, SQLOCALS_TYPE_INT))
    {
        object oTempleMerchant = GetRandomTempleMerchant();
        if(GetIsObjectValid(oTempleMerchant))
        {
            ServerShout(ColorText("Hurry up for the ", TXT_COLOR_ORANGE) + ColorText(GetName(GetArea(oTempleMerchant)), TXT_COLOR_WHITE_T) + ColorText(" sale!", TXT_COLOR_ORANGE));
            int nIntervalLength = SQLocals_GetInt(oHolder, "TEMPLE_REFRESH_INTERVAL");
            int nRandomDelay = 30 + Random(61);
            DelayCommand(IntToFloat(nRandomDelay), CreateTempleStoreGoods(oHolder, oTempleMerchant, nIntervalLength));
        }
        SQLocals_SetInt(oHolder, "TEMPLE_REFRESH_INTERVAL", GenerateTimeAndGetIntervalLength(oHolder, TEMPLE_REFRESH_HOUR, TEMPLE_REFRESH_MINUTE, iCurrentHour, iCurrentMinute,
                                                                                             TEMPLE_REFRESH_MINUTE_MIN_WAIT_TIME, TEMPLE_REFRESH_MINUTE_MAX_WAIT_TIME));
    }
    else if (!SQLocals_IsSet(oHolder, TEMPLE_REFRESH_HOUR, SQLOCALS_TYPE_INT) &&
             !SQLocals_IsSet(oHolder, TEMPLE_REFRESH_MINUTE, SQLOCALS_TYPE_INT))
        SQLocals_SetInt(oHolder, "TEMPLE_REFRESH_INTERVAL", GenerateTimeAndGetIntervalLength(oHolder, TEMPLE_REFRESH_HOUR, TEMPLE_REFRESH_MINUTE, iCurrentHour, iCurrentMinute,
                                                                                             TEMPLE_REFRESH_MINUTE_MIN_WAIT_TIME, TEMPLE_REFRESH_MINUTE_MAX_WAIT_TIME));
}

int GenerateTimeAndGetIntervalLength(object oHolder, string sHourLocalName, string sMinuteLocalName, int iCurrentHour, int iCurrentMinute, int iMinuteMin, int iMinuteMax)
{
    int nIntervalLength = iMinuteMin + Random(iMinuteMax - iMinuteMin + 1);
    //ServerShout("[DEBUG] Next Refresh: " + IntToString(nIntervalLength) + " min. Local Var: " + sHourLocalName);
    int iRandomMinute = iCurrentMinute + nIntervalLength;
    int iRandomHour = iCurrentHour + iRandomMinute/60;
    iRandomHour = iRandomHour >= 24 ? (iRandomHour % 24) : iRandomHour;
    iRandomMinute = iRandomMinute >= 60 ? (iRandomMinute % 60) : iRandomMinute;
    SQLocals_SetInt(oHolder, sHourLocalName, iRandomHour);
    SQLocals_SetInt(oHolder, sMinuteLocalName, iRandomMinute);
    return nIntervalLength;
}

object GetRandomTempleMerchant()
{
    object oMerchant = OBJECT_INVALID;
    int nDice = d6();
    switch(nDice)
    {
        case 1: oMerchant = GetObjectByTag("cyric_temple_merchant");     break;
        case 2: oMerchant = GetObjectByTag("helm_temple_merchant");      break;
        case 3: oMerchant = GetObjectByTag("lathander_temple_merchant"); break;
        case 4: oMerchant = GetObjectByTag("lliira_temple_merchant");    break;
        case 5: oMerchant = GetObjectByTag("mask_temple_merchant");      break;
        case 6: oMerchant = GetObjectByTag("silvanus_temple_merchant");  break;
    }
    return oMerchant;
}

void CreateTempleStoreGoods(object oHolder, object oTempleMerchant, int nIntervalLength)
{
    // create heal potion and set gold value
    object oHeal = CreateItemOnObject("nw_it_mpotion012", oTempleMerchant, 1 + nIntervalLength / 20);
    NWNX_Item_SetAddGoldPieceValue(oHeal, 20000);
    // create restoration potion and set gold value
    object oRestore = CreateItemOnObject("fl_mrestor", oTempleMerchant, 1 + nIntervalLength / 10);
    NWNX_Item_SetAddGoldPieceValue(oHeal, 2500);
    // create blank scroll and set gold value
    object oScroll = CreateItemOnObject("x2_it_cfm_bscrl", oTempleMerchant, 1 + nIntervalLength / 40);
    NWNX_Item_SetAddGoldPieceValue(oScroll, 40000);
}

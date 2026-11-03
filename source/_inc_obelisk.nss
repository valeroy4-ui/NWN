#include "nwnx_sql"
#include "_inc_sqlite_time"
#include "_inc_generic"
#include "_inc_discord_rpt"

///////////////////////////////////////////////////////////////////
//////////                 Constants                     //////////
///////////////////////////////////////////////////////////////////

const int OBELISK_MAX_COUNT = 8;
const int OBELISK_MAX_HITPOINTS = 15000;
const int OBELISK_CAPTURE_COOLDOWN_SEC = 10800; // 3 hours
const int OBELISK_ALARM_INTERVAL_SEC = 18; // 3 rounds
const int OBELISK_REGEN_PER_ALARM_INTERVAL = 300; // hitpoints per 3 rounds
const int OBELISK_DAMAGE_IMMUNITY_PERCENT = 50;

const float OBELISK_BUFF_COST_DECREASE_PERCENT = 10.0;

const string OBELISK_ON_DAMAGE_ALARM_TIMESTAMP = "OBELISK_ON_DAMAGE_ALARM_TIMESTAMP";
const string OBELISK_CURRENT_HITPOINTS = "OBELISK_CURRENT_HITPOINTS";
const string OBELISK_CAPTURED_TIMESTAMP = "OBELISK_CAPTURED_TIMESTAMP";
const string OBELISK_PLACEBLE_PREFIX = "ObeliskOfPower";
const string OBELISK_UNIQUE_ID = "OBELISK_UNIQUE_ID";

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

//
int obelisk_GetIsReadyToReceiveDamage(object oObelisk, int nTotalIncomeDamage, int nFaction);

//
int obelisk_TryToChangeHitpoints(object oObelisk, int nHitpoints, int nFaction, int nCurrentTimeStamp);

//
void obelisk_SetCaptured(object oObelisk, int nFaction, float fDuration, int bGenerateReports = TRUE);

//
void obelisk_Alarm(object oObelisk, int nHitpoints);

//
effect eObeliskImmunes();

//
void obelisk_Init();

//
int obelisk_UpdateCapturedData(int nID, int nFaction, int nCapturedTimeStamp);

//
void obelisk_Report(object oPC);

//
int obelisk_CountOwnedByFaction(int nFaction);

//
string obelisk_Examine(object oObelisk);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int obelisk_GetIsReadyToReceiveDamage(object oObelisk, int nTotalIncomeDamage, int nFaction)
{
    if(nFaction == FACTION_UNKNOWN)
        return FALSE;

    int nCapturedTimeStamp = GetLocalInt(oObelisk, OBELISK_CAPTURED_TIMESTAMP);
    int nCurrentTimeStamp = SQLite_GetTimeStamp();

    if(nCurrentTimeStamp - nCapturedTimeStamp <= OBELISK_CAPTURE_COOLDOWN_SEC)
        return FALSE;

    int nResult = FALSE;
    int nAlarmTimeStamp = GetLocalInt(oObelisk, OBELISK_ON_DAMAGE_ALARM_TIMESTAMP);
    //ServerShout(IntToString(nCurrentTimeStamp - nAlarmTimeStamp));
    if(nCurrentTimeStamp - nAlarmTimeStamp > OBELISK_ALARM_INTERVAL_SEC)
    {
        //string sFactionColor = GetFactionColor(nFaction);
        ServerShout(ColorText("Obelisk of Power", TXT_COLOR_WHITE_T) + ColorText(" in area ", TXT_COLOR_ORANGE) +
                    ColorText(GetName(GetArea(oObelisk)), TXT_COLOR_WHITE_T) + ColorText(" has been attacked.", TXT_COLOR_ORANGE));
        SetLocalInt(oObelisk, OBELISK_ON_DAMAGE_ALARM_TIMESTAMP, nCurrentTimeStamp);
        // regen 50 hp per 2 rounds
        obelisk_TryToChangeHitpoints(oObelisk, OBELISK_REGEN_PER_ALARM_INTERVAL * (nCurrentTimeStamp - nAlarmTimeStamp)/OBELISK_ALARM_INTERVAL_SEC, FACTION_UNKNOWN, nCurrentTimeStamp);
        // alarm about HP
        //int nCurrentHitpoint = GetLocalInt(oObelisk, OBELISK_CURRENT_HITPOINTS);
        //if(nCurrentHitpoint)
        //    obelisk_Alarm(oObelisk, nCurrentHitpoint);
    }
    nResult = obelisk_TryToChangeHitpoints(oObelisk, -nTotalIncomeDamage, nFaction, nCurrentTimeStamp);
    return nResult;
}

int obelisk_TryToChangeHitpoints(object oObelisk, int nHitpoints, int nFaction, int nCurrentTimeStamp)
{
    int nResult = TRUE;
    int nCurrentHitpoints = GetLocalInt(oObelisk, OBELISK_CURRENT_HITPOINTS);
    int nNewHipoints = nCurrentHitpoints + nHitpoints;
    if(nNewHipoints > OBELISK_MAX_HITPOINTS)
        SetLocalInt(oObelisk, OBELISK_CURRENT_HITPOINTS, OBELISK_MAX_HITPOINTS);
    else if(nNewHipoints <= 0)
    {
        if(!obelisk_UpdateCapturedData(GetLocalInt(oObelisk, OBELISK_UNIQUE_ID), nFaction, nCurrentTimeStamp))
            WriteLog("Function obelisk_UpdateCapturedData() returned FALSE. Unsuccessful obelisk data update in database.", LOG_LEVEL_ERROR);
        obelisk_SetCaptured(oObelisk, nFaction, IntToFloat(OBELISK_CAPTURE_COOLDOWN_SEC));
        nResult = FALSE;
    }
    else
        SetLocalInt(oObelisk, OBELISK_CURRENT_HITPOINTS, nNewHipoints);
    // evade destroy placeable
    SetCurrentHitPoints(oObelisk, 10000);

    return nResult;
}

void obelisk_SetCaptured(object oObelisk, int nFaction, float fDuration, int bGenerateReports = TRUE)
{
    if(fDuration <= 0.0) // sanity check
        return;
    // send messages to shout and discord
    if(bGenerateReports)
    {
        ServerShout(ColorText("Obelisk of Power", TXT_COLOR_WHITE_T) + ColorText(" in area ", TXT_COLOR_ORANGE) +
                    ColorText(GetName(GetArea(oObelisk)), TXT_COLOR_WHITE_T) + ColorText(" has been captured by ", TXT_COLOR_ORANGE) +
                    players_GetFactionName(nFaction) + ColorText(" faction.", TXT_COLOR_ORANGE));
        SendMessageToEventChannelOfDiscord("**Obelisk of Power** in area **" + GetName(GetArea(oObelisk)) + "** has been captured by **" + players_GetFactionName(nFaction, FALSE) + "** faction.");
        SendMessageToEventChannelOfTelegram("<b>Obelisk of Power</b> in area <b>" + GetName(GetArea(oObelisk)) + "</b> has been captured by <b>" + players_GetFactionName(nFaction, FALSE) + "</b> faction.");
    }
    // set locals
    players_SetFaction(oObelisk, nFaction);
    SetLocalInt(oObelisk, OBELISK_CAPTURED_TIMESTAMP, SQLite_GetTimeStamp());
    SetLocalInt(oObelisk, OBELISK_CURRENT_HITPOINTS, OBELISK_MAX_HITPOINTS);
    // select and apply vfx
    int nHealVfx;
    int nMantleVfx;
    switch(nFaction)
    {
        case FACTION_EMPIRE:
            nHealVfx = CEPVFX_IMP_HEALING_X_BLUE;
            nMantleVfx = HGVFX_DUR_SHEATH_BLUE; // BLUE;
        break;
        case FACTION_UNDERDARK:
            nHealVfx = CEPVFX_IMP_HEALING_X_ORANGE;
            nMantleVfx = HGVFX_DUR_SHEATH_BLACK; // ORANGE;
        break;
        case FACTION_IRON_THRONE:
            nHealVfx = CEPVFX_IMP_HEALING_X_PURPLE;
            nMantleVfx = HGVFX_DUR_SHEATH_PURPLE; // PURPLE;
        break;
        case FACTION_DRAGON_CULT:
            nHealVfx = CEPVFX_IMP_HEALING_X_GREEN;
            nMantleVfx = HGVFX_DUR_SHEATH_GREEN; // GREEN;
        break;
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(nHealVfx), oObelisk);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(nMantleVfx, FALSE, 1.5), oObelisk, fDuration);
}

void obelisk_Alarm(object oObelisk, int nHitpoints)
{
    object oPC = GetFirstObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_COLOSSAL, GetLocation(oObelisk), FALSE);
    while(GetIsObjectValid(oPC))
    {
        if(GetIsPC(oPC))
            FloatingColorTextStringOnCreature(IntToString(nHitpoints) + " hitpoints left.", TXT_COLOR_BLUE_L, oPC, FALSE);
        oPC = GetNextObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_COLOSSAL, GetLocation(oObelisk), FALSE);
    }
}

effect eObeliskImmunes()
{
    effect eEff = EffectDamageImmunityIncrease(DAMAGE_TYPE_ACID, OBELISK_DAMAGE_IMMUNITY_PERCENT);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_BLUDGEONING, OBELISK_DAMAGE_IMMUNITY_PERCENT), eEff);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, OBELISK_DAMAGE_IMMUNITY_PERCENT), eEff);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_DIVINE, OBELISK_DAMAGE_IMMUNITY_PERCENT), eEff);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_ELECTRICAL, OBELISK_DAMAGE_IMMUNITY_PERCENT), eEff);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, OBELISK_DAMAGE_IMMUNITY_PERCENT), eEff);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_MAGICAL, OBELISK_DAMAGE_IMMUNITY_PERCENT), eEff);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, OBELISK_DAMAGE_IMMUNITY_PERCENT), eEff);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_PIERCING, OBELISK_DAMAGE_IMMUNITY_PERCENT), eEff);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_POSITIVE, OBELISK_DAMAGE_IMMUNITY_PERCENT), eEff);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_SLASHING, OBELISK_DAMAGE_IMMUNITY_PERCENT), eEff);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_SONIC, OBELISK_DAMAGE_IMMUNITY_PERCENT), eEff);
    eEff = EffectLinkEffects(EffectSpellLevelAbsorption(9), eEff);
    eEff = SupernaturalEffect(eEff);
    return eEff;
}

void obelisk_Init()
{
    effect eEff = eObeliskImmunes();
    int nCurrentTimeStamp = SQLite_GetTimeStamp();
    string sSQL = "select t.id, t.owners_faction, t.capture_timestamp from obelisk t";
    NWNX_SQL_PrepareQuery(sSQL);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            int nID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
            int nFaction = StringToInt(NWNX_SQL_ReadDataInActiveRow(1));
            int nCapturedTimeStamp = StringToInt(NWNX_SQL_ReadDataInActiveRow(2));

            object oObelisk = GetObjectByTag(OBELISK_PLACEBLE_PREFIX + IntToString(nID));
            if(GetIsObjectValid(oObelisk))
            {
                float fTimeLeft = IntToFloat(OBELISK_CAPTURE_COOLDOWN_SEC - (nCurrentTimeStamp - nCapturedTimeStamp));
                if(nFaction && fTimeLeft > 0.0)
                    obelisk_SetCaptured(oObelisk, nFaction, fTimeLeft, FALSE);
                // apply effect with damage immunes etc
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEff, oObelisk);
                // set local variables
                players_SetFaction(oObelisk, nFaction);
                SetLocalInt(oObelisk, OBELISK_CAPTURED_TIMESTAMP, nCapturedTimeStamp);
                SetLocalInt(oObelisk, OBELISK_CURRENT_HITPOINTS, OBELISK_MAX_HITPOINTS);
                SetLocalInt(oObelisk, OBELISK_ON_DAMAGE_ALARM_TIMESTAMP, nCurrentTimeStamp); // prevent possible integer overflow in fuction obelisk_TryToChangeHitpoints
                SetLocalInt(oObelisk, OBELISK_UNIQUE_ID, nID);
            }
        }
    }
}

int obelisk_UpdateCapturedData(int nID, int nFaction, int nCapturedTimeStamp)
{
    string sSQL = "update obelisk t set t.owners_faction = ?, t.capture_timestamp = ? where t.id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, nFaction);
    NWNX_SQL_PreparedInt(1, nCapturedTimeStamp);
    NWNX_SQL_PreparedInt(2, nID);
    if(NWNX_SQL_ExecutePreparedQuery())
        return TRUE;
    else
        return FALSE;
}

void obelisk_Report(object oPC)
{
    string sMessage = "";
    int nObeliskCount;
    for(nObeliskCount = 1; nObeliskCount <= OBELISK_MAX_COUNT; nObeliskCount++)
    {
        object oObelisk = GetObjectByTag(OBELISK_PLACEBLE_PREFIX + IntToString(nObeliskCount));
        int nFaction = players_GetFaction(oObelisk);
        int nCapturedTimeStamp = GetLocalInt(oObelisk, OBELISK_CAPTURED_TIMESTAMP);
        int nTimeLeft = SQLite_GetTimeStamp() - nCapturedTimeStamp;
        string sFactionColor = players_GetFactionColor(nFaction);
        if(sFactionColor == TXT_COLOR_NONE)
            sFactionColor = TXT_COLOR_WHITE_T;
        sMessage += ColorText("  " + IntToString(nObeliskCount) + ") ", TXT_COLOR_YELLOW_T) + ColorText("Obelisk of Power", sFactionColor) +
                    ColorText(" in area ", TXT_COLOR_YELLOW_T) + ColorText(GetName(GetArea(oObelisk)), TXT_COLOR_WHITE_T) + ColorText(" status:", TXT_COLOR_YELLOW_T);
        if(nTimeLeft >= OBELISK_CAPTURE_COOLDOWN_SEC)
            sMessage += ColorText(" ready!\n", TXT_COLOR_GREEN_L);
        else
            sMessage += ColorText(" is not ready! " + IntToString((OBELISK_CAPTURE_COOLDOWN_SEC - nTimeLeft)/60) + " minute(s) left.\n", TXT_COLOR_RED);
    }
    SendMessageToPC(oPC, sMessage);
}

//
int obelisk_CountOwnedByFaction(int nFaction)
{
    int nResult = 0;
    int nObeliskCount;
    for(nObeliskCount = 1; nObeliskCount <= OBELISK_MAX_COUNT; nObeliskCount++)
    {
        object oObelisk = GetObjectByTag(OBELISK_PLACEBLE_PREFIX + IntToString(nObeliskCount));
        if(players_GetFaction(oObelisk) == nFaction)
            nResult++;
    }
    return nResult;
}

string obelisk_Examine(object oObelisk)
{
    string sResult = "Hitpoints: ";
    int nCapturedTimeStamp = GetLocalInt(oObelisk, OBELISK_CAPTURED_TIMESTAMP);
    int nCurrentTimeStamp = SQLite_GetTimeStamp();

    string sHitpoints = ColorText(IntToString(GetLocalInt(oObelisk, OBELISK_CURRENT_HITPOINTS)), TXT_COLOR_BLUE_L);
    if(nCurrentTimeStamp - nCapturedTimeStamp <= OBELISK_CAPTURE_COOLDOWN_SEC)
        sHitpoints = ColorText("invulnerable", TXT_COLOR_RED);
    sResult += sHitpoints + "\n";
    int nFaction = players_GetFaction(oObelisk);
    string sFactionName = players_GetFactionName(nFaction);
    sResult += "Owner: " + sFactionName + "\n";
    return sResult;
}

//void main() {}

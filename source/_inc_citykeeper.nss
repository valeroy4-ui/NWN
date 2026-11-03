#include "_inc_log"
#include "_inc_players"
#include "x0_i0_stringlib"

const int KEEPER_MAX_HEALTH = 15000;
const float KEEPER_RESPAWN_TIME = 7200.0; // 2 hours

effect GetKeeperImmunes();
void CreateKeeperOnWaypoint(object oWPS);
void CreateKeeperInArea(object oArea);
void InitKeepers();
int GetKeeperMaxHealth();
int GetIsKeeperDestroyed(int iFaction);
int GetIsAreaProtectedByKeeper(object oArea);
int GetIsPCAllowedToEnterArea(object oPC, object oArea);

effect GetKeeperImmunes()
{
    effect eCrit = EffectImmunity(IMMUNITY_TYPE_CRITICAL_HIT);
    effect eSneak = EffectImmunity(IMMUNITY_TYPE_SNEAK_ATTACK);
    effect eAcid = EffectDamageImmunityIncrease(DAMAGE_TYPE_ACID, 100);
    effect eCold = EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, 100);
    effect eElec = EffectDamageImmunityIncrease(DAMAGE_TYPE_ELECTRICAL, 100);
    effect eFire = EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, 100);
    effect eSony = EffectDamageImmunityIncrease(DAMAGE_TYPE_SONIC, 100);
    effect eBlud = EffectDamageImmunityIncrease(DAMAGE_TYPE_BLUDGEONING, 100);
    effect eSlas = EffectDamageImmunityIncrease(DAMAGE_TYPE_SLASHING, 100);
    effect ePier = EffectDamageImmunityIncrease(DAMAGE_TYPE_PIERCING, 100);
    effect eLink = EffectLinkEffects(eCrit, eSneak);
    eLink = EffectLinkEffects(eLink, eAcid);
    eLink = EffectLinkEffects(eLink, eCold);
    eLink = EffectLinkEffects(eLink, eElec);
    eLink = EffectLinkEffects(eLink, eFire);
    eLink = EffectLinkEffects(eLink, eSony);
    eLink = EffectLinkEffects(eLink, eBlud);
    eLink = EffectLinkEffects(eLink, eSlas);
    eLink = EffectLinkEffects(eLink, ePier);
    eLink = SupernaturalEffect(eLink);
    return eLink;
}

void CreateKeeperOnWaypoint(object oWPS)
{
    string sTag = GetStringRight(GetTag(oWPS), GetStringLength(GetTag(oWPS)) - 5);
    object oKeeper = CreateObject(OBJECT_TYPE_PLACEABLE, sTag, GetLocation(oWPS), FALSE);
    int iFaction = players_GetFaction(oKeeper);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,GetKeeperImmunes(), oKeeper, DURATION_SERVER_SESSION);
    SetLocalInt(GetModule(), "FACTION_"+IntToString(iFaction)+"_IS_DESTROYED", FALSE);

    if(GetIsObjectValid(oKeeper))
        WriteLog("successfully spawn keeper in Area: " + GetName(GetArea(oWPS)) + " with tag " + GetTag(GetArea(oWPS)) + ". Keeper tag: " + GetTag(oKeeper), LOG_LEVEL_INFO);
    else
        WriteLog("failed to spawn keeper in Area: "+GetName(GetArea(oWPS)) + " with tag " + GetTag(GetArea(oWPS)) + ". WaypointSpawn tag: " + GetTag(oWPS)+". ResRef for CreateObject: "+ sTag, LOG_LEVEL_ERROR);

}

void CreateKeeperInArea(object oArea)
{
    if(oArea == OBJECT_INVALID)
        return;
    object oWaypointSpawn = GetFirstObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
    while(GetIsObjectValid(oWaypointSpawn))
    {
        WriteLog("GetTag(oWaypointSpawn)=" + GetTag(oWaypointSpawn), LOG_LEVEL_DEBUG);
        if(GetStringLeft(GetTag(oWaypointSpawn), 5) == "WPSK_")
        {
            WriteLog("Invoke CreateKeeperOnWaypoint", LOG_LEVEL_DEBUG);
            // GetFirstObjectInArea/GetNextObjectInArea loop + CreateObject works incorrect‚
            // call CreateObject by DelayCommand or ActionDoCommand
            DelayCommand(0.0, CreateKeeperOnWaypoint(oWaypointSpawn));
        }
        oWaypointSpawn = GetNextObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
    }
}

void InitKeepers()
{
    SetLocalInt(GetModule(),"KEEPER_MAX_HEALTH", KEEPER_MAX_HEALTH);
    string sAreasTags = "_loc_kulg_appr|_loc_arab_appr|_loc_reno_appr|area_dcult_appr";
    struct sStringTokenizer stAreasTok = GetStringTokenizer(sAreasTags, "|");
    string sAreaTag;
    object oArea;
    while(HasMoreTokens(stAreasTok))
    {
        stAreasTok = AdvanceToNextToken(stAreasTok);
        sAreaTag = GetNextToken(stAreasTok);
        oArea = GetObjectByTag(sAreaTag);
        // skip creation if disabled
        if(!players_GetIsFactionEnabled(players_GetFaction(oArea)))
            continue;
        if(GetIsObjectValid(oArea))
        {
            WriteLog("Invoke CreateKeeperInArea. sAreaTag=" + sAreaTag, LOG_LEVEL_DEBUG);
            CreateKeeperInArea(oArea);
        }
        else
            WriteLog("Invalid Area with tag '" + sAreaTag + "'", LOG_LEVEL_ERROR);
    }
}

int GetKeeperMaxHealth()
{
    return GetLocalInt(GetModule(), "KEEPER_MAX_HEALTH");
}

int GetIsKeeperDestroyed(int iFaction)
{
    return GetLocalInt(GetModule(), "FACTION_"+IntToString(iFaction) + "_IS_DESTROYED");
}

int GetIsAreaProtectedByKeeper(object oArea)
{
    return GetLocalInt(oArea, "bProtectedByKeeper");
}

int GetIsPCAllowedToEnterArea(object oPC, object oArea)
{
    int iAreaFaction = players_GetFaction(oArea);
    if(players_GetFaction(oPC) != iAreaFaction && GetIsAreaProtectedByKeeper(oArea) && !GetIsKeeperDestroyed(iAreaFaction))
        return FALSE;
    return TRUE;
}

//void main(){}


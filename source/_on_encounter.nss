#include "_inc_sqlite_time"
#include "nwnx_encounter"
#include "_inc_generic"
#include "nwnx_sql"

//
int encounter_GetRespawnTime(object oEncounter, string sCreatureResRef);

//
int encounter_GetRespawnsPvPBlocked(object oArea, int nCR);

void main()
{
    object oPC = GetEnteringObject();
    object oEncounter = OBJECT_SELF;
    int bBossInstance = GetLocalInt(GetArea(oEncounter), AREA_FLAG_INSTANCE_BOSS);

    if(!GetIsPC(oPC) || GetIsDM(oPC) || bBossInstance)
        return;

    switch(GetCurrentlyRunningEvent(FALSE))
    {
        case EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER:
        {
            if(NWNX_Encounter_GetCurrentNumSpawned(oEncounter))
                return;
            // declare vars
            int bAllowSpawn = FALSE;
            int nRespawnTime = GetLocalInt(oEncounter, "ENCOUNTER_MOBS_RESPAWN_TIME");
            int nCurrentTimeStamp = SQLite_GetTimeStamp();
            struct NWNX_Encounter_CreatureListEntry stEncounter = NWNX_Encounter_GetEncounterCreatureByIndex(oEncounter, 0);

            if(nRespawnTime > 0) // check respawn time
                bAllowSpawn = nCurrentTimeStamp - GetLocalInt(oEncounter, "ENCOUNTER_MOBS_DEATH_TIMESTAMP") > nRespawnTime;
            else // first spawn
                bAllowSpawn = TRUE;

            if(bAllowSpawn && !encounter_GetRespawnsPvPBlocked(GetArea(oPC), FloatToInt(stEncounter.challengeRating)))
            {
                SetEncounterActive(TRUE);
                SetEncounterActive(FALSE);
            }
        }
        break;
    }
}

int encounter_GetRespawnsPvPBlocked(object oArea, int nCR)
{
    int iEmpire     = GetLocalInt(oArea, "FACTION_" + IntToString(FACTION_EMPIRE)      + "_PLAYERS_COUNT");
    int iUnderdark  = GetLocalInt(oArea, "FACTION_" + IntToString(FACTION_UNDERDARK)   + "_PLAYERS_COUNT");
    int iIronThrone = GetLocalInt(oArea, "FACTION_" + IntToString(FACTION_IRON_THRONE) + "_PLAYERS_COUNT");
    int iDragonCult = GetLocalInt(oArea, "FACTION_" + IntToString(FACTION_DRAGON_CULT) + "_PLAYERS_COUNT");
    int bEnemiesHere = (iEmpire > 0) + (iUnderdark > 0) + (iIronThrone > 0) + (iDragonCult > 0) > 1;
    if(!bEnemiesHere)
        return FALSE;
    int nSumLevel = 0;
    int nCount = 1; // prevent div by zero
    object oLoop = GetFirstObjectInArea(oArea, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(oLoop))
    {
        if(GetIsPC(oLoop))
        {
            nSumLevel += GetHitDice(oLoop);
            nCount++;
        }
        oLoop = GetNextObjectInArea(oArea, OBJECT_TYPE_CREATURE);
    }
    int nAverageLvl = nSumLevel / (nCount - 1);
    if(nAverageLvl - nCR > 5)
        return TRUE;
    return FALSE;
}


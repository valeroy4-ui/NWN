#include "_inc_generic"

void main()
{
    if (!generic_DestroyCreature(OBJECT_SELF))
        DelayCommand(60.0, ExecuteScript("_mod_despawn", OBJECT_SELF));
    else
    {
        object oEncounter = NWNX_Creature_GetEncounter(OBJECT_SELF);
        if(GetIsObjectValid(oEncounter) && !(NWNX_Encounter_GetCurrentNumSpawned(oEncounter) - 1))
        {
            int nCurrentTimeStamp = SQLite_GetTimeStamp();
            SetLocalInt(oEncounter, "ENCOUNTER_MOBS_DEATH_TIMESTAMP", nCurrentTimeStamp);
            if(GetLocalInt(oEncounter, "ENCOUNTER_MOBS_RESPAWN_TIME"))
                return;

            struct NWNX_Encounter_CreatureListEntry stEncounter = NWNX_Encounter_GetEncounterCreatureByIndex(oEncounter, 0);
            object oEncounterHolder = GetObjectByTag(CONST_ENCOUNTER_HOLDER);
            int nRespawnTime = generic_GetRespawnTime(oEncounterHolder, stEncounter.resref);
            if(nRespawnTime <= 0)
                nRespawnTime = NWNX_Encounter_GetResetTime(oEncounter);
            SetLocalInt(oEncounter, "ENCOUNTER_MOBS_RESPAWN_TIME", nRespawnTime);
        }
    }
}


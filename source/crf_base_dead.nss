/*/////////////////////// [On Death] ///////////////////////////////////////////
    Filename: J_AI_OnDeath or nw_c2_default7
///////////////////////// [On Death] ///////////////////////////////////////////
    Speeded up no end, when compiling, with seperate Include.
    Cleans up all un-droppable items, all ints and all local things when destroyed.

    Check down near the bottom for a good place to add XP or corpse lines ;-)
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added in Turn of corpses toggle
        - Added in appropriate space for XP awards, marked with ideas (effect death)
    1.4 - Removed the redudnant notes on the "You have gained 0 experience" message
///////////////////////// [Workings] ///////////////////////////////////////////
    You can edit this for experience, there is a seperate section for it.

    It will use DeathCheck to execute a cleanup-and-destroy script, that removes
    any coprse, named "j_ai_destroyself".
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetLastKiller.
///////////////////////// [On Death] /////////////////////////////////////////*/

// We only require the constants/debug file. We have 1 function, not worth another include.

#include "j_inc_constants"
#include "_inc_experience"
#include "_inc_corpses"
#include "_inc_loot_static"
#include "_inc_discord_rpt"
#include "_inc_guard_spawn"
#include "_inc_onhit"

// We need a wrapper. If the amount of deaths, got in this, is not equal to iDeaths,
// we don't execute the script, else we do. :-P
void DeathCheck(int nDeaths);

// sends sText to all online iFactionToSend members
void SendFloatingMessageToFaction(int iFactionToSend, string sText);

// generates alert to nNPCFaction members and reward to killer's faction if time is fame time
void GenerateNPCKillAlertOrCaptainReward(object oNPC, int nNPCFaction, object oKiller);


void main()
{
    // If we are set to, don't fire this script at all
    if(GetAIInteger(I_AM_TOTALLY_DEAD)) return;

    // Pre-death-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_DEATH_PRE_EVENT, EVENT_DEATH_PRE_EVENT)) return;

    // Note: No AI on/off check here.

    // Who killed us? (alignment changing, debug, XP).
    object oKiller = GetLastKiller();

    // Stops if we just applied EffectDeath to ourselves.
    if(GetLocalTimer(AI_TIMER_DEATH_EFFECT_DEATH)) return;

    // If guard, send alarm message to all pc
    // or generate captain reward
    int iGuardFaction = players_GetFaction(OBJECT_SELF);
    if(iGuardFaction)
        GenerateNPCKillAlertOrCaptainReward(OBJECT_SELF, iGuardFaction, oKiller);

    int nCurrentTimeStamp = SQLite_GetTimeStamp();
    // ==> handle encounters, EVENT_SCRIPT_ENCOUNTER_ON_ENCOUNTER_EXHAUSTED sometimes dont triggering
    object oEncounter = NWNX_Creature_GetEncounter(OBJECT_SELF);
    if(GetIsObjectValid(oEncounter) && !(NWNX_Encounter_GetCurrentNumSpawned(oEncounter) - 1))
    {
        SetLocalInt(oEncounter, "ENCOUNTER_MOBS_DEATH_TIMESTAMP", nCurrentTimeStamp);
        if(GetLocalInt(oEncounter, "ENCOUNTER_MOBS_RESPAWN_TIME"))
            SendColorMessageToPC(oKiller, "Time until the next respawn: " + IntToString(GetLocalInt(oEncounter, "ENCOUNTER_MOBS_RESPAWN_TIME") / 60) + " min", TXT_COLOR_DM_BLUE);
        else
        {
            struct NWNX_Encounter_CreatureListEntry stEncounter = NWNX_Encounter_GetEncounterCreatureByIndex(oEncounter, 0);
            object oEncounterHolder = GetObjectByTag(CONST_ENCOUNTER_HOLDER);
            int nRespawnTime = generic_GetRespawnTime(oEncounterHolder, stEncounter.resref);
            if(nRespawnTime <= 0)
                nRespawnTime = NWNX_Encounter_GetResetTime(oEncounter);
            SendColorMessageToPC(oKiller, "Time until the next respawn: " + IntToString(nRespawnTime / 60) + " min", TXT_COLOR_DM_BLUE);
            SetLocalInt(oEncounter, "ENCOUNTER_MOBS_RESPAWN_TIME", nRespawnTime);
        }
    }
    // <== handle encounters, EVENT_SCRIPT_ENCOUNTER_ON_ENCOUNTER_EXHAUSTED sometimes dont triggering

    // Special: To stop giving out multiple amounts of XP, we use EffectDeath
    // to change the killer, so the XP systems will NOT award MORE XP.
    // - Even the default one suffers from this!
    if(GetAIInteger(WE_HAVE_DIED_ONCE))
    {
        if(!GetLocalTimer(AI_TIMER_DEATH_EFFECT_DEATH))
        {
            // Don't apply effect death to self more then once per 2 seconds.
            SetLocalTimer(AI_TIMER_DEATH_EFFECT_DEATH, 2.0);
            // This should make the last killer us.
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), OBJECT_SELF);
            DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetMaxHitPoints()), OBJECT_SELF));
        }
    }
    else if(oKiller != OBJECT_SELF)
    {
        // Set have died once, stops giving out mulitple amounts of XP.
        SetAIInteger(WE_HAVE_DIED_ONCE, TRUE);
        if(!GetLocalInt(OBJECT_SELF, "IMGUARD"))
        {
            if (champion_GetIsBoss())
            {
                object oMaster = GetMaster(oKiller);
                if (GetIsObjectValid(oMaster))
                    oKiller = oMaster;

                object oSaver  = GetLocalObject(OBJECT_SELF, "BOSS_LOOT_SAVER");
                // no double spawns for instance bosses
                int bBossInstance = GetLocalInt(GetArea(OBJECT_SELF), AREA_FLAG_INSTANCE_BOSS);
                if(bBossInstance)
                    SetLocalInt(GetArea(oSaver), AREA_FLAG_INSTANCE_BOSS_KILLED, TRUE);
                // is boss mutant??
                int bMutant = GetLocalInt(OBJECT_SELF, "MUTATED");

                string sKillerName = NWNX_Util_StripColors(GetName(oKiller));
                if(sKillerName == "")
                    sKillerName = "[Unknown]";
                int iFaction = players_GetFaction(oKiller);
                string sKillerFactionName = players_GetFactionName(iFaction, FALSE);

                string sBossName = NWNX_Util_StripColors(GetName(OBJECT_SELF));
                // colorise boss name for shout message
                string sColorBossName;
                if(bMutant)
                    sColorBossName = ColorText(sBossName, TXT_COLOR_RED);
                else
                    sColorBossName = ColorText(sBossName, TXT_COLOR_WHITE_T);
                // get portrait
                string sBossPortrait = GetPortraitResRef();
                int nBossType = champion_GetBossType(OBJECT_SELF);
                string sBossCategory = champion_GetDiscordCategory(nBossType);
                // report about boss kill
                ServerShout("Boss " + sColorBossName + " was killed by " + ColorText(sKillerName, players_GetFactionColor(iFaction)));
                WriteLog("Boss " + sBossName + " has been killed by " + sKillerName, LOG_LEVEL_INFO);
                //ServerShout(GetStringLowerCase(sBossPortrait) + "m.png");
                // save boss kill timestamp if not instance boss
                if(!bBossInstance)
                {
                    string sBossResref  = GetResRef(OBJECT_SELF);
                    SetLocalInt(GetModule(), sBossResref, nCurrentTimeStamp);
                    NWNX_SQL_ExecuteQuery("UPDATE boss_cooldowns SET last_death_timestamp = '" +
                                          IntToString(nCurrentTimeStamp) + "', boss_random_shift = '" +
                                          IntToString(-BOSS_RANDOM_SPAWN_WINDOW_SIZE/2 + Random(BOSS_RANDOM_SPAWN_WINDOW_SIZE)) +
                                          "' WHERE boss_resref = '" + sBossResref + "'");
                }
                // give PvE fame to player's party
                if(GetIsPC(oKiller) && GetLocalInt(OBJECT_SELF, "FAME_REWARD") > 0)
                    factions_GivePVEReward(oKiller, GetLocalInt(OBJECT_SELF, "FAME_REWARD") + bMutant * GetLocalInt(OBJECT_SELF, "FAME_REWARD") /2 , 1.0, 1.0);

                // generating loot
                if (GetIsObjectValid(oSaver))
                {
                    AssignCommand(oSaver, GenerateBossTreasure());
                    AssignCommand(oSaver, DestroyObject(OBJECT_SELF, 1.5));
                }
                else
                {
                    SendMessageToAllDMs("Loot saver not found! Loot from boss " + sBossName + " not generated.");
                    WriteLog("Loot saver not found! Loot from boss " + sBossName + " not generated.", LOG_LEVEL_ERROR);
                }
                // chance to drop epic rune from advanced+ bosses
                if(GetLocalInt(OBJECT_SELF, "MUTATED"))
                {
                    int nChance = 20 * nBossType; // 20% per boss tier
                    if(nChance > 20 && nChance >= Random(100) + 1) // drop from advanced+ only
                    {
                        CreateLootOnObject(OBJECT_SELF, LOOT_MOBS_LEVEL_09 /* epic runes */, 1);
                        generic_PlayAudioStreamForPlayerArea(OBJECT_SELF, "mus_holyshit");
                    }
                }
                if(iFaction == FACTION_UNDERDARK)
                    generic_PlayAudioStreamForPlayerArea(OBJECT_SELF, "mus_funigga", AUDIOSTREAM_IDENTIFIER_1);

                // validation
                SetTimeStampValidation(OBJECT_SELF, nCurrentTimeStamp);

            }
            else if(champion_GetIsEliteChampion())
                champion_GenerateEliteReward(GetLastKiller(), OBJECT_SELF);
            else
            {
                int nMobCR = FloatToInt(GetChallengeRating(OBJECT_SELF));
                if(champion_GetIsChampion() && d100() > 75)
                {
                    int nFameReward = nMobCR/10;
                    if(nFameReward > 6)
                        nFameReward = 6;
                    if(nFameReward > 0)
                    {
                        GenerateFameOnTarget(OBJECT_SELF, nFameReward);
                        generic_PlayAudioStreamForPlayerArea(OBJECT_SELF, "mus_holyshit");
                    }
                }
                // elite mobs epic runes drop
                if(nMobCR >= 60)
                {
                    object oMaster = GetMaster(oKiller);
                    if (GetIsObjectValid(oMaster))
                        oKiller = oMaster;
                    string sFaction = players_GetFactionName(players_GetFaction(oKiller), FALSE);
                    string sLogMsg = "ELITE 60CR MOB HAS BEEN KILLED WITH ";
                    int nChance = 1; // base chance 0.1%
                    if(champion_GetIsChampion())
                    {
                        nChance = 10; // 1.0%
                        sLogMsg += "CHAMPION FLAG ";
                    }
                    else if(db_GetIsPrimeTime())
                    {
                        nChance = 5; // 0.5%
                        sLogMsg += "PRIME TIME FLAG ";
                    }
                    else
                        sLogMsg += "STANDART FLAG ";

                    if(nChance >= Random(1000) + 1)
                    {
                        CreateLootOnObject(OBJECT_SELF, LOOT_MOBS_LEVEL_09 /* epic runes */, 1);
                        generic_PlayAudioStreamForPlayerArea(OBJECT_SELF, "mus_holyshit");
                    }
                    sLogMsg += " BY " + GetStringUpperCase(sFaction) + " FACTION.";
                    WriteLog(sLogMsg);
                }
                GenerateStaticMobLoot();
            }
            GiveExperience(oKiller);
            onhit_LastHitHealing(oKiller, OBJECT_SELF, SPELL_LAST_HIT);
        }

/*/////////////////////// [Experience] /////////////////////////////////////////
    THIS is the place for it, below this comment.

    It is useful to use GetFirstFactionMember (and Next), GiveXPToCreature,
    GetXP, SetXP, GetChallengeRating (of self) all are really useful.

    Bug note: GetFirstFactionMember/Next with the PC parameter means either ONLY PC,
    and so NPC henchmen, unless FALSE is used, will not be even recognised.
///////////////////////// [Experience] ///////////////////////////////////////*/
    // Do XP things (Use object "oKiller" for who killed us).



/*/////////////////////// [Experience] ///////////////////////////////////////*/
    }

    // Note: Here we do a simple way of checking how many times we have died.
    // Nothing special. Debugging most useful aspect.
    int nDeathCounterNew = GetAIInteger(AMOUNT_OF_DEATHS);
    nDeathCounterNew++;
    SetAIInteger(AMOUNT_OF_DEATHS, nDeathCounterNew);

    // Here is the last time (in game seconds) we died. It is used in the executed script
    // to make sure we don't prematurly remove areselves.

    // We may want some sort of visual effect - like implosion or something, to fire.
    int nDeathEffect = GetAIConstant(AI_DEATH_VISUAL_EFFECT);

    // Valid constants from 0 and up. Apply to our location (not to us, who will go!)
    if(nDeathEffect >= 0)
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(nDeathEffect), GetLocation(OBJECT_SELF));
    }

    // Always shout when we are killed. Reactions - Morale penalty, and
    // attack the killer.
    AISpeakString(AI_SHOUT_I_WAS_KILLED);

    // Speaks the set death speak, like "AGGGGGGGGGGGGGGGGGGG!! NOOOO!" for instance :-)
    // Note for 1.4: No need for "CanSpeak()" for this, of course.
    SpeakArrayString(AI_TALK_ON_DEATH);

    DelayCommand(0.5, LeaveCorpse());

    // First check - do we use "destroyable corpses" or not? (default, yes)
    if(!GetSpawnInCondition(AI_FLAG_OTHER_TURN_OFF_CORPSES, AI_OTHER_MASTER))
    {
        // We will actually dissapear after 12.0 seconds if not raised.
        int nTime = GetAIInteger(AI_CORPSE_DESTROY_TIME);
        if(nTime == 0) // Error checking
        {
            nTime = 12;
        }
        // 64: "[Death] Checking corpse status in " + IntToString(nTime) + " [Killer] " + GetName(oKiller) + " [Times Died Now] " + IntToString(nDeathCounterNew)
        DebugActionSpeakByInt(64, oKiller, nTime, IntToString(nDeathCounterNew));
        // Delay check
        DelayCommand(IntToFloat(nTime), DeathCheck(nDeathCounterNew));
    }
    else
    {
/************************ [Alternative Corpses] ********************************
    This is where you can add some alternative corpse code - EG looting
    and so on, without disrupting the rest of the AI (as the corpses
    are turned off).
************************* [Alternative Corpses] *******************************/
    // Add alternative corpse code here


/************************ [Alternative Corpses] *******************************/
    }
    // Signal the death event.
    FireUserEvent(AI_FLAG_UDE_DEATH_EVENT, EVENT_DEATH_EVENT);
}

// We need a wrapper. If the amount of deaths, got in this, is not equal to iDeaths,
// we don't execute the script, else we do. :-P
void DeathCheck(int nDeaths)
{
    // Do the deaths imputted equal the amount we have suffered?
    if(GetAIInteger(AMOUNT_OF_DEATHS) == nDeaths)
    {
        // - This now includes a check for Bioware's lootable functions and using them.
        ExecuteScript(FILE_DEATH_CLEANUP, OBJECT_SELF);
    }
}

void SendFloatingMessageToFaction(int iFactionToSend, string sText)
{
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
       if(!GetIsDM(oPC))
           if(players_GetFaction(oPC) == iFactionToSend)
               FloatingTextStringOnCreature(sText, oPC);
       oPC = GetNextPC();
    }
}

void GenerateNPCKillAlertOrCaptainReward(object oNPC, int nNPCFaction, object oKiller)
{
    string sAreaName = GetName(GetArea(oNPC));
    int bDenied = nNPCFaction == players_GetFaction(oKiller);
    int bCaptain = guard_GetIsCaptain(oNPC);
    string sMessage;

    if(bCaptain)
    {
        if(bDenied)
            sMessage = ColorText("Captain of your faction was denied in area " + sAreaName +".", TXT_COLOR_GREEN_L);
        else
            sMessage = ColorText("Captain of your faction was killed in area " + sAreaName +".", TXT_COLOR_RED);
    }
    else if(bDenied)
        sMessage = ColorText("NPC of your faction was denied in area " + sAreaName +".", TXT_COLOR_GREEN_L);
    else
        sMessage = ColorText("NPC of your faction was killed in area " + sAreaName +".", TXT_COLOR_RED);

    SendFloatingMessageToFaction(nNPCFaction, sMessage);

    // give reward if possible
    if(GetIsPC(oKiller) && GetLocalInt(oNPC, "FAME_REWARD") > 0 && db_GetIsPrimeTime())
    {
        if(!bDenied)
            factions_GivePVEReward(oKiller, GetLocalInt(oNPC, "FAME_REWARD"));
        DeleteLocalInt(oNPC, "FAME_REWARD");
        if(bCaptain)
        {
            if(!bDenied)
                champion_GenerateEliteReward(oKiller, oNPC, TRUE);
            int nKilledCapsCount = GetLocalInt(GetModule(), "KILLED_CAPTAINS_COUNT_FACTION_" + IntToString(nNPCFaction)) + 1;
            SetLocalInt(GetModule(), "KILLED_CAPTAINS_COUNT_FACTION_" + IntToString(nNPCFaction), nKilledCapsCount);
            if(nKilledCapsCount >= CAPTAINS_COUNT_FOR_TREASURE_UNLOCK)
            {
                guard_SetLockedFactionTreasureDoor(nNPCFaction, FALSE);
                guard_GenerateGoldInTreasureChest(nNPCFaction);
            }
        }
    }
}

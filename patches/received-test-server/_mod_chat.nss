#include "nwnx_encounter"
#include "_inc_stashes"
#include "_inc_chat"
#include "_inc_runes"
#include "_inc_quickbars"
#include "_inc_spellbook"
#include "_inc_divbuffer"
#include "_inc_obelisk"


void main()
{
    // TEST SERVER ONLY: movement presets; return before ordinary chat/DB logic.
    string sSpeedCommand = GetStringLowerCase(GetPCChatMessage());
    if (sSpeedCommand == "!dmspeed" || sSpeedCommand == ".dmspeed"
        || sSpeedCommand == "!pcspeed" || sSpeedCommand == ".pcspeed")
    {
        SetPCChatMessage("");
        object oSpeedPC = GetPCChatSpeaker();
        if (!GetIsPC(oSpeedPC)) return;
        int nSpeedRate = NWNX_CREATURE_MOVEMENT_RATE_PC;
        if (sSpeedCommand == "!dmspeed" || sSpeedCommand == ".dmspeed")
            nSpeedRate = NWNX_CREATURE_MOVEMENT_RATE_DM_FAST;
        NWNX_Creature_SetMovementRate(oSpeedPC, nSpeedRate);
        int nActualRate = GetMovementRate(oSpeedPC);
        string sSpeedReport = "[TEST SPEED] requested=" + IntToString(nSpeedRate)
            + " actual=" + IntToString(nActualRate);
        if (nActualRate != nSpeedRate)
            sSpeedReport += " FAILED";
        else if (nSpeedRate == NWNX_CREATURE_MOVEMENT_RATE_DM_FAST)
            sSpeedReport += " DM fast; use !pcspeed to restore normal speed.";
        else
            sSpeedReport += " Normal PC speed restored.";
        SendMessageToPC(oSpeedPC, sSpeedReport);
        PrintString(sSpeedReport);
        return;
    }
    // TEST SERVER ONLY: explicit laboratory entry; no database/chat side effects.
    string sLabCommand = GetStringLowerCase(GetPCChatMessage());
    if (sLabCommand == "!lab" || sLabCommand == ".lab")
    {
        SetPCChatMessage("");
        object oLabPC = GetPCChatSpeaker();
        if (!GetIsPC(oLabPC) || GetIsDead(oLabPC)) return;
        object oLabWaypoint = GetWaypointByTag("CT_SPELL_LAB");
        if (!GetIsObjectValid(oLabWaypoint)
            || GetResRef(GetArea(oLabWaypoint)) != "ct_spell_lab")
        {
            SendMessageToPC(oLabPC, "Spell laboratory waypoint not found; no transfer.");
            return;
        }
        AssignCommand(oLabPC, ClearAllActions());
        AssignCommand(oLabPC, JumpToLocation(GetLocation(oLabWaypoint)));
        DelayCommand(2.0, ExecuteScript("ct_d_ensure", GetModule()));
        SendMessageToPC(oLabPC, "Entering the spell laboratory.");
        return;
    }
    object oChater = GetPCChatSpeaker();
    string sMsg = GetStringLowerCase(GetPCChatMessage());
    int bSystemMessage = FALSE;

    if (GetSubString(sMsg, 0, 1) == ".")
        sMsg = "!" + GetSubString(sMsg, 1, GetStringLength(sMsg) - 1);
    if (GetSubString(sMsg, 0, 1) == "!")
        bSystemMessage = TRUE;

    if (sMsg=="!help")
    {
        SendMessageToPC(oChater, ColorText("\n             Chat commands list:      ", TXT_COLOR_GREEN_L));
        SendMessageToPC(oChater, "Server's PVP statistics -" + TXT_COLOR_GREEN_L + " !stat");
        SendMessageToPC(oChater, "Top-10 players -" + TXT_COLOR_GREEN_L + " !top");
        SendMessageToPC(oChater, "Top players in different timeframes -" + TXT_COLOR_GREEN_L + " !topd");
        SendMessageToPC(oChater, "Kills/Deaths statistics -" + TXT_COLOR_GREEN_L + " !fstat");
        SendMessageToPC(oChater, "Loot statistics -" + TXT_COLOR_GREEN_L + " !lstat");
        SendMessageToPC(oChater, "Current server's time -" + TXT_COLOR_GREEN_L + " !time");
        SendMessageToPC(oChater, "Check boss cooldown status -" + TXT_COLOR_GREEN_L + " !boss");
        SendMessageToPC(oChater, "Check obelisks statuses -" + TXT_COLOR_GREEN_L + " !obelisk");
        SendMessageToPC(oChater, "Check account's free fame -" + TXT_COLOR_GREEN_L + " !fame");
        SendMessageToPC(oChater, "Transfer fame to teammate -" + TXT_COLOR_GREEN_L + " !fame <amount>");
        SendMessageToPC(oChater, "Check a bank account -" + TXT_COLOR_GREEN_L + " !money");
        SendMessageToPC(oChater, "Cashless money transfer -" + TXT_COLOR_GREEN_L + " !money <amount>");
        SendMessageToPC(oChater, "Check account's available Soul Stones -" + TXT_COLOR_GREEN_L + " !soul");
        SendMessageToPC(oChater, "Transfer Soul Stones to another player -" + TXT_COLOR_GREEN_L + " !soul <amount>");
        SendMessageToPC(oChater, "Show all known runes -" + TXT_COLOR_GREEN_L + " !runes");
        SendMessageToPC(oChater, "Show information about stash usage -" + TXT_COLOR_GREEN_L + " !stash");
        SendMessageToPC(oChater, "Show information about quickbar saver usage -" + TXT_COLOR_GREEN_L + " !qbh");
        SendMessageToPC(oChater, "Show information about spellbook saver usage -" + TXT_COLOR_GREEN_L + " !sbh");
        SendMessageToPC(oChater, "Total effects bonuses report -" + TXT_COLOR_GREEN_L + " !treport");
        SendMessageToPC(oChater, "Show extended combat information -" + TXT_COLOR_GREEN_L + " !combatlog");
        SendMessageToPC(oChater, "Show what feats were taken at each level -" + TXT_COLOR_GREEN_L + " !checklevels");
        SendMessageToPC(oChater, "Get an auto-invitation to a party from your faction -" + TXT_COLOR_GREEN_L + " !party");
        SendMessageToPC(oChater, "Take party leader -" + TXT_COLOR_GREEN_L + " !leader");
        SendMessageToPC(oChater, "Calculate DPS -" + TXT_COLOR_GREEN_L + " !dps");
        SendMessageToPC(oChater, "Show base player statistics -" + TXT_COLOR_GREEN_L + " !pstat");
        SendMessageToPC(oChater, "Show information about resists/reducts in log -" + TXT_COLOR_GREEN_L + " !resist");
        SendMessageToPC(oChater, "Delete character -" + TXT_COLOR_GREEN_L + " !delete");
    }
    else if (sMsg == "!stat")
        chat_PrintPVPStats(oChater);
    else if (sMsg=="!top")
        chat_PrintTop10(oChater);
    else if (sMsg=="!topd")
        chat_PrintDynamicTop(oChater);
    else if (sMsg=="!fstat")
        chat_PrintFactionPVPStats(oChater);
    else if (sMsg=="!lstat")
        chat_PrintLootStats(oChater);
    else if (sMsg == "!time")
        SendMessageToPC(oChater, "\nServer time: " + db_GetCurrentServerTime());
    else if (sMsg == "!boss")
        chat_PrintBossStatuses(oChater);
    else if (sMsg == "!obelisk")
        obelisk_Report(oChater);
    else if (FindSubString(sMsg, "!fame") == 0)
        chat_SendFame(oChater, sMsg);
    else if (FindSubString(sMsg, "!money") == 0)
        chat_SendMoney(oChater, sMsg);
    else if (FindSubString(sMsg, "!soul") == 0)
        chat_SendSoulStones(oChater, sMsg);
    else if (FindSubString(sMsg, "!runes") == 0)
        SendMessageToPC(oChater, runes_GetAllKnownRunesList(oChater));
    else if (sMsg == "!delete")
        chat_DeleteCharacter(oChater);
    else if (sMsg == "!bard")
        chat_UseBardAsYourSlave(oChater);
    else if (sMsg == "!pstat")
    {
        if(!GetLocalInt(oChater, "PSTAT_ENABLED"))
            SetLocalInt(oChater, "PSTAT_ENABLED", TRUE);
        else
            DeleteLocalInt(oChater, "PSTAT_ENABLED");
        ExecuteScript("_mod_instant_eff", oChater);
    }
    else if (sMsg == "!treport")
        SendMessageToPC(oChater, chat_CreatureReportBonuses(oChater));
    else if(FindSubString(sMsg, "!stash") == 0 && !players_IsTestCharacter(oChater))
        stashes_ChatHandler(oChater, GetSubString(sMsg, 6, 500));
    else if(GetStringLeft(sMsg, 4) == "!qbh")
    {
        SendMessageToPC(
            oChater,
            ColorText("\n             Quickbar commands list:\n", TXT_COLOR_GREEN_L) +
            ColorText("!qbv", TXT_COLOR_GREEN_L) + " - view saved quickbars.\n" +
            ColorText("!qbs <slot> [description]", TXT_COLOR_GREEN_L) + " - save quickbar, <slot> must be in the range of 1 to 9.\n" +
            ColorText("!qbl <slot>", TXT_COLOR_GREEN_L) + " - load quickbar, <slot> must be in the range of 1 to 9.\n");
    }
    else if(GetStringLeft(sMsg, 4) == "!qbs")
    {
        int nSlot = StringToInt(GetTokenByPosition(sMsg, " ", 1));
        string sDescription = GetTokenByPosition(sMsg, " ", 2);
        quickbars_SaveQuickbar(oChater, nSlot, sDescription);
    }
    else if(GetStringLeft(sMsg, 4) == "!qbl")
    {
        int nSlot = StringToInt(GetTokenByPosition(sMsg, " ", 1));
        quickbars_LoadQuickbar(oChater, nSlot);
    }
    else if(GetStringLeft(sMsg, 4) == "!qbd")
    {
        int nSlot = StringToInt(GetTokenByPosition(sMsg, " ", 1));
        quickbars_DeleteQuickbarSlot(oChater, nSlot);
    }
    else if(GetStringLeft(sMsg, 4) == "!qbv")
    {
        quickbars_ViewQuickbars(oChater);
    }
    else if(GetStringLeft(sMsg, 4) == "!sbh")
    {
        SendMessageToPC(
            oChater,
            ColorText("\n             Spellbook commands list:\n", TXT_COLOR_GREEN_L) +
            ColorText("!sbv", TXT_COLOR_GREEN_L) + " - view saved spellbooks.\n" +
            ColorText("!sbs <slot> [description]", TXT_COLOR_GREEN_L) + " - save spellbooks, <slot> must be in the range of 1 to 9.\n" +
            ColorText("!sbl <slot>", TXT_COLOR_GREEN_L) + " - load spellbooks, <slot> must be in the range of 1 to 9.\n");
    }
    else if(GetStringLeft(sMsg, 4) == "!sbs")
    {
        int nSlot = StringToInt(GetTokenByPosition(sMsg, " ", 1));
        string sDescription = GetTokenByPosition(sMsg, " ", 2);
        spellbook_SaveSpells(oChater, nSlot, sDescription);
    }
    else if(GetStringLeft(sMsg, 4) == "!sbl")
    {
        int nSlot = StringToInt(GetTokenByPosition(sMsg, " ", 1));
        spellbook_LoadSpells(oChater, nSlot);
    }
    else if(GetStringLeft(sMsg, 4) == "!sbd")
    {
        int nSlot = StringToInt(GetTokenByPosition(sMsg, " ", 1));
        spellbook_DeleteSpellSlot(oChater, nSlot);
    }
    else if(GetStringLeft(sMsg, 4) == "!sbv")
    {
        spellbook_ViewSavedSlots(oChater);
    }
    else if (sMsg == "!combatlog")
    {
        if (!GetLocalInt(oChater, "COMBAT_LOG_EXTEND"))
        {
            SetLocalInt(oChater, "COMBAT_LOG_EXTEND", TRUE);
            SendMessageToPC(oChater, "Extended combat log enabled.");
        }
        else
        {
            DeleteLocalInt(oChater, "COMBAT_LOG_EXTEND");
            SendMessageToPC(oChater, "Extended combat log disabled.");
        }
    }
    else if (GetStringLeft(sMsg, 12) == "!checklevels" || GetStringLeft(sMsg, 6) == "!build" || GetStringLeft(sMsg, 4) == "!bld")
    {
        int nRace = GetRacialType(oChater);
        string sRacialType2da = Get2DAString("racialtypes", "featstable", nRace);
        int i;
        SendMessageToPC(oChater, "--------checklevels output--------");
        json jRacialCash = JsonObject();
        for(i = 0; i<= Get2DARowCount(sRacialType2da); i++)
        {
            string sFeatIndex = Get2DAString(sRacialType2da, "featindex", i);
            JsonObjectSetInplace(jRacialCash, sFeatIndex, JsonInt(1));
        }
        int iChaterLevel;
        int nPrevLevel;
        for (iChaterLevel = 1; iChaterLevel <= GetHitDice(oChater); iChaterLevel++)
        {
            int iClassId = NWNX_Creature_GetClassByLevel(oChater, iChaterLevel);
            string sClass = class_GetClassNameById(iClassId);
            SendColorMessageToPC(oChater, "Level " + IntToString(iChaterLevel) + " - " + sClass, TXT_COLOR_DM_BLUE);
            int iFeatCount = NWNX_Creature_GetFeatCountByLevel(oChater, iChaterLevel);

            int iFeatIndex;
            for (iFeatIndex = 0; iFeatIndex < iFeatCount; iFeatIndex++)
            {
                int iLoopFeat = NWNX_Creature_GetFeatByLevel(oChater, iChaterLevel, iFeatIndex);
                string sClass2daTable = Get2DAString("classes", "featstable", iClassId);
                int i;
                int nList = 0;
                for(i = 0; i<= Get2DARowCount(sClass2daTable); i++)
                {
                    string sFeatIndex = Get2DAString(sClass2daTable, "featindex", i);
                    if(StringToInt(sFeatIndex) == iLoopFeat)
                    {
                        nList = StringToInt(Get2DAString(sClass2daTable, "list", i));
                        break;
                    }
                }
                string sFeatName;
                int nRaceCashValue = JsonGetInt(JsonObjectGet(jRacialCash, IntToString(iLoopFeat)));
                string sParam = GetTokenByPosition(sMsg, " ", 1);
                if(nList != 3 && !nRaceCashValue && sParam != "f" || sParam == "a" || (sParam == "f" && nList == 3 || sParam == "f"  && nRaceCashValue))
                {
                    string sFeatName = GetFeatNameFrom2DA(iLoopFeat);
                    SendColorMessageToPC(oChater, "  " + sFeatName + " (ID: " + IntToString(iLoopFeat) + ")", TXT_COLOR_GREEN_L);
                }
            }
        }
    }
    else if(sMsg == "!party")
        chat_InvitePlayerIntoFactionParty(oChater);
    else if(sMsg == "!leader")
        chat_ChangePartyLeader(oChater);
    else if(GetStringLeft(sMsg, 4) == "!dps")
    {
        int nRounds = StringToInt(GetTokenByPosition(sMsg, " ", 1));
        if(nRounds)
            chat_RunDPSCalculator(oChater, nRounds);
        else
            chat_RunDPSCalculator(oChater);
    }
    else if(sMsg == "!resist")
    {
        if (!GetLocalInt(oChater, "RESISTS_DISABLED"))
        {
            SetLocalInt(oChater, "RESISTS_DISABLED", TRUE);
            SendMessageToPC(oChater, "Combat log damage resistance info enabled.");
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_IMMUNITY, FALSE);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_RESISTANCE, FALSE);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_RESISTANCE_REMAINING, FALSE);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_REDUCTION, FALSE);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_REDUCTION_REMAINING, FALSE);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_WEAPON_NOT_EFFECTIVE, FALSE);
        }
        else
        {
            DeleteLocalInt(oChater, "RESISTS_DISABLED");
            SendMessageToPC(oChater, "Combat log damage resistance info disabled.");
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_IMMUNITY, TRUE);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_RESISTANCE, TRUE);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_RESISTANCE_REMAINING, TRUE);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_REDUCTION, TRUE);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_REDUCTION_REMAINING, TRUE);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_WEAPON_NOT_EFFECTIVE, TRUE);
        }
    }


//////////////////////////  competition commands //////////////////////////////

/*
    if (FindSubString(sMsg, "!save") == 0)
    {
        if (GetNumberTokens(sMsg, " ") == 1)
        {
            SendMessageToPC(oChater, "Please enter filename after !save command.");
            return;
        }
        string sFileName = GetTokenByPosition(sMsg, " ", 1);
        if (GetStringLength(sFileName) > 11)
        {
            SendMessageToPC(oChater, "Filename is too long");
            return;
        }
        int iInventorySlot;
        for (iInventorySlot = 0; iInventorySlot <= 13; iInventorySlot++)
        {
            object oItemInSlot = GetItemInSlot(iInventorySlot, oChater);
            if (GetIsObjectValid(oItemInSlot))
                NWNX_Object_Export(oItemInSlot, sFileName + "_" + chat_GetItemTypeString(iInventorySlot));
        }
        SendMessageToPC(oChater, "Successfully saved.");
    }
    else if (FindSubString(sMsg, "!male") == 0)
        NWNX_Creature_SetGender(oChater, GENDER_MALE);
    else if (FindSubString(sMsg, "!female") == 0)
        NWNX_Creature_SetGender(oChater, GENDER_FEMALE);

*/


///////////////////////////////////////////////////////////////////////////////



/////////////////////// special commands ///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

    if (sMsg == "!restart")
        chat_Restart(oChater);
    else if(sMsg == "!cls")
        chat_DeleteModuleParameters(oChater);
    else if (GetSubString(sMsg, 0, 4) == "!vfx")
    {
        int iStringLenght = GetStringLength(sMsg);
        if (StringToInt(GetSubString(sMsg, 5, iStringLenght - 5)))
            db_SetVFX(GetPCPlayerName(oChater), StringToInt(GetSubString(sMsg, 5, iStringLenght - 5)));
    }
    else if (sMsg == "!checkareas")
    {
        object oArea = GetFirstArea();
        while (oArea != OBJECT_INVALID)
        {
            //WriteTimestampedLogEntry(GetName(oArea));
            if (GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_ENTER) != "_mod_area_enter")
            {
                SendMessageToPC(oChater, "Area " + TXT_COLOR_RED + GetName(oArea) + TXT_COLOR_END + " has invalid OnEnter script.");
            }
            if (GetEventScript(oArea, EVENT_SCRIPT_AREA_ON_EXIT) != "_mod_area_exit")
            {
                SendMessageToPC(oChater, "Area " + TXT_COLOR_RED + GetName(oArea) + TXT_COLOR_END + " has invalid OnExit script.");
            }
            if (GetIsAreaInterior(oArea) || !GetIsAreaAboveGround(oArea) || !GetIsAreaNatural(oArea))
            {
                WriteTimestampedLogEntry(GetName(oArea));
                SendMessageToPC(oChater, "Area " + TXT_COLOR_RED + GetName(oArea) + TXT_COLOR_END + " is not natural.");
            }
            oArea = GetNextArea();
        }
    }
    else if (sMsg == "!checkenc")
    {
        object oArea = GetFirstArea();
        while (oArea != OBJECT_INVALID)
        {
            object oEncounter = GetFirstObjectInArea(oArea, OBJECT_TYPE_ENCOUNTER);
            while(GetIsObjectValid(oEncounter))
            {
                if (NWNX_Encounter_GetNumberOfCreaturesInEncounterList(oEncounter) == 0)
                    SendMessageToPC(oChater, "Alarm! Area " + TXT_COLOR_RED + GetName(oArea) + TXT_COLOR_END + " has empty encounter");
                oEncounter = GetNextObjectInArea(oArea, OBJECT_TYPE_ENCOUNTER);
            }
            oArea = GetNextArea();
        }
    }
    else if (sMsg == "!checkmapnotes")
        chat_MapNotesChecker();
    else if(GetStringLeft(sMsg, 7) == "!appear")
    {
        int nAppearNumber = StringToInt(GetTokenByPosition(sMsg, " ", 1));
        SetCreatureAppearanceType(oChater, nAppearNumber);
    }
    else if (sMsg == "!!")
    {
        int nToken = NuiCreateFromResRef(oChater, "test", "test");
    }

///////////////////// Cheat commands ///////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////


/*
    if (sMsg=="!exp") GiveXPToCreature(oChater, 1000000);

    if (sMsg == "!gold") {
        GiveGoldToCreature(oChater, 100000);
    }

    if (sMsg == "!godmode") {
        if (GetImmortal(oChater)==FALSE && GetLocalInt(oChater, "GODMODE_ON") == FALSE)
        {
            SetImmortal(oChater, TRUE);
            SetLocalInt(oChater, "GODMODE_ON", TRUE);
            SendMessageToPC(oChater, "Godmode ON");
        }
        else
        {
            SetImmortal(oChater, FALSE);
            DeleteLocalInt(oChater, "GODMODE_ON");
            SendMessageToPC(oChater, "Godmode OFF");
        }
    }

    if (sMsg == "!dmspeed") {
        NWNX_Creature_SetMovementRate(oChater, NWNX_CREATURE_MOVEMENT_RATE_DM_FAST);
    }

    if (sMsg == "!pcspeed") {
        NWNX_Creature_SetMovementRate(oChater, NWNX_CREATURE_MOVEMENT_RATE_PC);
    }

    else if (sMsg == "!test")
    {
        SetTextureOverride("fnt_es_icon32", "", oChater);
        SetTextureOverride("fnt_es_icon32", "", OBJECT_INVALID);
        int i;
        PostString(oChater, "a", 12, 4, SCREEN_ANCHOR_TOP_RIGHT, 5.0, 0xFFFFFFFF, 0xFFFFFFFF, 1, "fnt_es_icon32");
        PostString(oChater, "a", 16, 4, SCREEN_ANCHOR_TOP_RIGHT, 5.0, 0xFFFFFFFF, 0xFFFFFFFF, 2, "fnt_es_icon32");
        PostString(oChater, "a", 20, 4, SCREEN_ANCHOR_TOP_RIGHT, 5.0, 0xFFFFFFFF, 0xFFFFFFFF, 3, "fnt_es_icon32");
        DelayCommand(0.1, SetTextureOverride("fnt_es_icon32", "is_heal", oChater));
    }

*/

    SetLocalString(oChater, "LAST_CHAT_MESSAGE", sMsg);

    if(GetIsPC(oChater) && GetPCChatVolume() == TALKVOLUME_SHOUT && !bSystemMessage)
    {
        chat_SaveShoutMessageIntoDB(players_GetPCPersistentID(oChater), NWNX_Util_StripColors(GetName(oChater)), sMsg);
        int nFaction = players_GetFaction(oChater);
        ReportPlayerShoutToDiscord(oChater, nFaction, sMsg);
        SendMessageToTGShoutTopic(oChater, nFaction, sMsg);
    }

    if (bSystemMessage)
        SetPCChatMessage();
    else if(GetPCChatVolume() == TALKVOLUME_SHOUT && Random(100) > 100)
    {
        SetPCChatMessage();
        int nRandom = Random(50) + 1;
        switch(nRandom)
        {
            case 1:
                AssignCommand(oChater, SpeakString("Я люблю члены!", TALKVOLUME_SHOUT));
            break;
            case 2:
                AssignCommand(oChater, SpeakString("Я уже намазался ;)", TALKVOLUME_SHOUT));
            break;
            case 3:
                AssignCommand(oChater, SpeakString("Почему-то сегодня задница болит :(", TALKVOLUME_SHOUT));
            break;
            case 4:
                AssignCommand(oChater, SpeakString("Без членов никуда..", TALKVOLUME_SHOUT));
            break;
            case 5:
                AssignCommand(oChater, SpeakString("А я сегодня ходил на работу в костюме петуха!", TALKVOLUME_SHOUT));
            break;
            case 6:
                AssignCommand(oChater, SpeakString("Эх, глину бы помесить", TALKVOLUME_SHOUT));
            break;
            case 7:
                AssignCommand(oChater, SpeakString("Мой анус - это портал в нирвану!", TALKVOLUME_SHOUT));
            break;
            case 8:
                AssignCommand(oChater, SpeakString("Хочу, чтоб меня разорвали пополам, как арбуз!", TALKVOLUME_SHOUT));
            break;
            case 9:
                AssignCommand(oChater, SpeakString("Парни в трикотаже - моя слабость!", TALKVOLUME_SHOUT));
            break;
            case 10:
                AssignCommand(oChater, SpeakString("Я вчера проглотил слона... ну, почти!", TALKVOLUME_SHOUT));
            break;
            case 11:
                AssignCommand(oChater, SpeakString("Моя попка поёт оперу от каждого толчка!", TALKVOLUME_SHOUT));
            break;
            case 12:
                AssignCommand(oChater, SpeakString("Радуга в штанах - мой фетиш!", TALKVOLUME_SHOUT));
            break;
            case 13:
                AssignCommand(oChater, SpeakString("Банан? Нет, дай огурчик покрупнее!", TALKVOLUME_SHOUT));
            break;
            case 14:
                AssignCommand(oChater, SpeakString("Я - королева ДискоДырочки!", TALKVOLUME_SHOUT));
            break;
            case 15:
                AssignCommand(oChater, SpeakString("Член - это не овощ, это оружие массового поражения!", TALKVOLUME_SHOUT));
            break;
            case 16:
                AssignCommand(oChater, SpeakString("Отсосу так, что молоко из коровы польётся!", TALKVOLUME_SHOUT));
            break;
            case 17:
                AssignCommand(oChater, SpeakString("Моя дырка - магнит для альфа-самцов!", TALKVOLUME_SHOUT));
            break;
            case 18:
                AssignCommand(oChater, SpeakString("Глубокий глоток — мой олимпийский вид спорта!", TALKVOLUME_SHOUT));
            break;
            case 19:
                AssignCommand(oChater, SpeakString("Петухи на старте! Кто первый клюнет?", TALKVOLUME_SHOUT));
            break;
            case 20:
                AssignCommand(oChater, SpeakString("Без подушки под попу - ни дня!", TALKVOLUME_SHOUT));
            break;
            case 21:
                AssignCommand(oChater, SpeakString("Хочу, чтоб меня оттрахали все 12 апостолов разом!", TALKVOLUME_SHOUT));
            break;
            case 22:
                AssignCommand(oChater, SpeakString("Моя жопа - Олимпийский чемпион по прыжкам в длину!", TALKVOLUME_SHOUT));
            break;
            case 23:
                AssignCommand(oChater, SpeakString("Соси, пока не посинеешь, мой сладкий!", TALKVOLUME_SHOUT));
            break;
            case 24:
                AssignCommand(oChater, SpeakString("Я - вакуумная помпа для свежей спермы!", TALKVOLUME_SHOUT));
            break;
            case 25:
                AssignCommand(oChater, SpeakString("Петушок готов к утреннему петтингу и не только!", TALKVOLUME_SHOUT));
            break;
            case 26:
                AssignCommand(oChater, SpeakString("Без анала жизнь - сплошная тоска и скука!", TALKVOLUME_SHOUT));
            break;
            case 27:
                AssignCommand(oChater, SpeakString("Мой рот — чёрная дыра мужского блаженства!", TALKVOLUME_SHOUT));
            break;
            case 28:
                AssignCommand(oChater, SpeakString("Давай по кругу, братва, не стесняемся!", TALKVOLUME_SHOUT));
            break;
            case 29:
                AssignCommand(oChater, SpeakString("Люблю, когда меня дерут как последнюю шлюху на районе!", TALKVOLUME_SHOUT));
            break;
            case 30:
                AssignCommand(oChater, SpeakString("Сперма — мой фирменный молочный коктейль!", TALKVOLUME_SHOUT));
            break;
            case 31:
                AssignCommand(oChater, SpeakString("Задница ноет от сладких воспоминаний о вчерашней оргии!", TALKVOLUME_SHOUT));
            break;
            case 32:
                AssignCommand(oChater, SpeakString("Хочу огромный, твёрдый и пылающий как вулкан!", TALKVOLUME_SHOUT));
            break;
            case 33:
                AssignCommand(oChater, SpeakString("Я - профессиональный анальный акробат цирка!", TALKVOLUME_SHOUT));
            break;
            case 34:
                AssignCommand(oChater, SpeakString("Член в рот - и я в раю на земле!", TALKVOLUME_SHOUT));
            break;
            case 35:
                AssignCommand(oChater, SpeakString("Парни, кто на жаркую групповуху сегодня?", TALKVOLUME_SHOUT));
            break;
            case 36:
                AssignCommand(oChater, SpeakString("Моя дырка уже звонит вам на свидание!", TALKVOLUME_SHOUT));
            break;
            case 37:
                AssignCommand(oChater, SpeakString("Оттрахай меня в усмерть, без пощады!", TALKVOLUME_SHOUT));
            break;
            case 38:
                AssignCommand(oChater, SpeakString("Я смазан, разогрет и готов к космическому запуску!", TALKVOLUME_SHOUT));
            break;
            case 39:
                AssignCommand(oChater, SpeakString("Люблю, когда кончают внутрь - океан удовольствия!", TALKVOLUME_SHOUT));
            break;
            case 40:
                AssignCommand(oChater, SpeakString("Мой зад - общественный транспорт для хуёв!", TALKVOLUME_SHOUT));
            break;
            case 41:
                AssignCommand(oChater, SpeakString("Соси мои яйца, как сочные персики!", TALKVOLUME_SHOUT));
            break;
            case 42:
                AssignCommand(oChater, SpeakString("Я - гей-наркоман, зависим от мужского секса!", TALKVOLUME_SHOUT));
            break;
            case 43:
                AssignCommand(oChater, SpeakString("Хочу классическое двойное проникновение!", TALKVOLUME_SHOUT));
            break;
            case 44:
                AssignCommand(oChater, SpeakString("Моя попка - вулкан неутолимой страсти!", TALKVOLUME_SHOUT));
            break;
            case 45:
                AssignCommand(oChater, SpeakString("Без хуя я как рыба без воды - задыхаюсь!", TALKVOLUME_SHOUT));
            break;
            case 46:
                AssignCommand(oChater, SpeakString("Давайте поимеем друг друга до потери пульса!", TALKVOLUME_SHOUT));
            break;
            case 47:
                AssignCommand(oChater, SpeakString("Обожаю запах мужского пота после тренировки!", TALKVOLUME_SHOUT));
            break;
            case 48:
                AssignCommand(oChater, SpeakString("Однажды в студеную зимнюю пору я из лесу вышел с членом во рту!", TALKVOLUME_SHOUT));
            break;
            case 49:
                AssignCommand(oChater, SpeakString("Мой анус расширяется от чистого восторга!", TALKVOLUME_SHOUT));
            break;
            case 50:
                AssignCommand(oChater, SpeakString("Группа крови на рукаве, а член в жопе навсегда!", TALKVOLUME_SHOUT));
            break;
        }
    }
}






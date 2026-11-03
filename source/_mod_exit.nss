#include "_inc_death"
#include "nwnx_admin"
#include "_inc_generic"

void main()
{
    object oPC = GetExitingObject();
    object oArea = GetArea(oPC);

    if(!GetIsDM(oPC))
    {
        int nLimitedClassSlotID = players_GetIsLimitedBuild(oPC);
        if (nLimitedClassSlotID)
            SetLocalInt(GetModule(), "LIMITED_BUILD_FACTION_" + IntToString(players_GetFaction(oPC)) +
                                     "_SLOT_ID_" + IntToString(nLimitedClassSlotID),
                                     GetLocalInt(GetModule(),
                                     "LIMITED_BUILD_FACTION_" + IntToString(players_GetFaction(oPC))
                                     + "_SLOT_ID_" + IntToString(nLimitedClassSlotID)) - 1);

        int nSupportSlot = players_GetIsSupport(oPC);
        if(nSupportSlot)
            SetLocalInt(GetModule(), "LIMITED_BUILD_FACTION_" + IntToString(players_GetFaction(oPC)) +
                                     "_SLOT_ID_" + IntToString(nSupportSlot),
                                     GetLocalInt(GetModule(),
                                     "LIMITED_BUILD_FACTION_" + IntToString(players_GetFaction(oPC))
                                     + "_SLOT_ID_" + IntToString(nSupportSlot)) - 1);

        ExecuteScript("pdk_srv_exit", oPC);
        int iPersistentID = players_GetPCPersistentID(oPC);
        // update logout time
        NWNX_SQL_ExecuteQuery("UPDATE " +
                              "  characters " +
                              "SET " +
                              "  `last_logout` = CURRENT_TIMESTAMP, `level` = " + IntToString(GetHitDice(oPC)) + " " +
                              "WHERE " +
                              "  `id` = " + IntToString(iPersistentID));
        // calculate online time
        NWNX_SQL_ExecuteQuery("UPDATE " +
                              "  characters " +
                              "SET " +
                              "  online_seconds = online_seconds + " +
                              "                  (SELECT TIMESTAMPDIFF(SECOND, " +
                              "                  (select last_login from characters WHERE id = " + IntToString(iPersistentID) + "), " +
                              "                  (select last_logout from characters WHERE id = " + IntToString(iPersistentID) + "))) " +
                              "WHERE " +
                              "  id = " + IntToString(iPersistentID));

        // save HP data
        SetLocalInt(oPC, "CURRENT_PC_HITPOINTS", GetCurrentHitPoints(oPC));

        // save info about player entered to the server
        SetLocalInt(oPC, "PLAYER_LOGGED_AFTER_RESTART", TRUE);

        // for boss antialt system
        if (GetLocalInt(oArea, "BOSS_AREA"))
        {
            if(death_GetDeadFlag(iPersistentID) <= 0)
                SetLocalInt(oArea, "ALTEROK_DETECTED", TRUE);
            SendMessageToAllDMs("Player " + GetName(oPC) + " has been alted in the boss area " + GetName(oArea));
            DelayCommand(12.0, DeleteLocalInt(oArea, "ALTEROK_DETECTED"));
        }

        if (!players_IsTestCharacter(oPC)) ExportSingleCharacter(oPC);

        // Save players count of every faction Area onExit doesnt work if player leave server
        string sFaction = IntToString(players_GetFaction(oPC));
        string sVar = "FACTION_" + sFaction + "_PLAYERS_COUNT";
        int iCurrentPlayersCount = GetLocalInt(oArea, sVar);
        SetLocalInt(oArea, sVar, --iCurrentPlayersCount > 0 ? iCurrentPlayersCount : 0);

        if(players_IsTestCharacter(oPC) && iPersistentID > 0 || GetLocalInt(oPC, "YOUR_NAME_IS_INVALID"))
        {
            //NWNX_Administration_DeletePlayerCharacter(oPC, FALSE);
            //NWNX_SQL_ExecuteQuery("DELETE FROM characters WHERE `id` = " + IntToString(iPersistentID));
        }
        DeleteLocalInt(oPC, "FACTION");
    }

}


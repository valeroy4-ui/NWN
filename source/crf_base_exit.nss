#include "_inc_death"
#include "_inc_feat2skin"
#include "nw_i0_spells"
#include "_inc_generic"
#include "_inc_areas"

void main()
{
    object oPC = GetExitingObject();
    object oArea = OBJECT_SELF;
    int iPlayerPCPersistentID = players_GetPCPersistentID(oPC);

    if(GetIsPC(oPC) && !GetIsDM(oPC) && iPlayerPCPersistentID > 0)
    {
        // run following code if character leaved fugue
        if (GetResRef(oArea) == CONST_AREA_ABYSS_RESREF)
        {
            string sCorpseName      = GetName(oPC);
            object oCorpse          = GetLocalObject(death_GetCorpseHolder(), "CORPSE_OF_" + IntToString(iPlayerPCPersistentID));
            object oVictim          = GetLocalObject(death_GetCorpseHolder(), "DEAD_PLAYER_" + IntToString(iPlayerPCPersistentID));
            object oGravestone      = GetLocalObject(death_GetCorpseHolder(), "GRAVESTONE_OF_" + IntToString(iPlayerPCPersistentID));

            DestroyObject(oCorpse, 0.1);
            if (GetIsObjectValid(oVictim))
                SendMessageToPC(oVictim, "You're alive, corpse has been destroyed.");

            // delete expired local objects
            DeleteLocalObject(death_GetCorpseHolder(), "DEAD_PLAYER_" + IntToString(iPlayerPCPersistentID));
            DeleteLocalObject(death_GetCorpseHolder(), "CORPSE_OF_" + IntToString(iPlayerPCPersistentID));

            // calculate XP penalty
            int iPcLevel    = GetHitDice(oPC);
            int iNoPenalty  = FALSE;
            int nDeathType  = death_GetDeadFlag(iPlayerPCPersistentID);

            // no penalty if character 40 lvl and died not in boss area
            if (nDeathType != DEATH_TYPE_BOSS && iPcLevel >= 40) iNoPenalty = TRUE;

            // 1st level = no XP penalty too
            if (!iNoPenalty && iPcLevel > 1)
            {
                iPcLevel = iPcLevel > 39 ? 39: iPcLevel;
                int iExpForNextLevel = StringToInt(Get2DAString("exptable", "XP", iPcLevel)) -
                    StringToInt(Get2DAString("exptable", "XP", iPcLevel - 1));

                int iPenalty = (iExpForNextLevel * 2) / 5;

                if (GetLocalInt(oPC, "RAISEDEAD_PLAYER"))
                    iPenalty = iExpForNextLevel / 5;
                else if (GetLocalInt(oPC, "RESURRECTED_PLAYER"))
                    iPenalty = iExpForNextLevel / 10;
                else if (nDeathType == DEATH_TYPE_VASELINED)
                    iPenalty = iExpForNextLevel / 20;
                else if (nDeathType == DEATH_TYPE_ENEMY_PLAYER)
                    iPenalty = iExpForNextLevel / 15;
                else if (nDeathType == DEATH_TYPE_BOSS)
                    iPenalty = iExpForNextLevel / 15;
                else if (nDeathType == DEATH_TYPE_FRIENDLY_PLAYER)
                    iPenalty = iExpForNextLevel / 5;

                generic_TakeXPFromCreature(oPC, iPenalty);
                // leave the possibility of returning part of the experience using the tombstone
                if (GetIsObjectValid(oGravestone)) SetLocalInt(oGravestone, "GRAVESTONE_XP_PRAY_BONUS", iPenalty / 3);
            }
            // clear dead flag
            death_SetDeadFlag(iPlayerPCPersistentID, DEATH_TYPE_ALIVE);
            // clear local vars
            DeleteLocalInt(oPC, "RESURRECTED_PLAYER");
            DeleteLocalInt(oPC, "RAISEDEAD_PLAYER");
            // update NUI XP progress bar
            players_UpdateXpBar(oPC);
        }
        else if(GetResRef(oArea) == CONST_AREA_EPIC_LOOT_RESREF)
            AssignCommand(oPC, DelayCommand(0.0, RemoveEffectsFromSpell(oPC, SPELL_EPIC_LOOT_AREA_TRUESEEING)));

        // Save players count of every faction
        string sFaction = IntToString(players_GetFaction(oPC));
        string sVar = "FACTION_" + sFaction + "_PLAYERS_COUNT";
        int iCurrentPlayersCount = GetLocalInt(oArea, sVar);
        SetLocalInt(oArea, sVar, --iCurrentPlayersCount > 0 ? iCurrentPlayersCount : 0);

        // Original restriction, with one explicit test-server !lab transfer.
        if(GetResRef(oArea) == "_loc_testarea")
        {
            object oLabDest = GetLocalObject(oPC, "CT_LAB_TRANSFER_DEST");
            int bLabTransfer = GetIsObjectValid(oLabDest)
                && oLabDest == GetWaypointByTag("CT_SPELL_LAB")
                && GetResRef(GetArea(oLabDest)) == "ct_spell_lab";
            DeleteLocalObject(oPC, "CT_LAB_TRANSFER_DEST");
            if(!bLabTransfer)
                BootPC(oPC);
            else
                PrintString("[TEST LAB] TestRoom exit allowed for !lab: " + GetName(oPC, TRUE));
        }

        // set last exited area as local object
        SetLocalObject(oPC, "LAST_AREA", oArea);
    }
    // clear var cash
    DeleteLocalInt(oArea, AREA_FLAG_PLAYERS_COUNT_WITH_DMS);
    DeleteLocalInt(oArea, AREA_FLAG_PLAYERS_COUNT_WITHOUT_DMS);
}

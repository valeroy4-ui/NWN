#include "x0_i0_stringlib"
#include "nwnx_object"
#include "nwnx_sql"
#include "nwnx_player"
#include "_inc_db_funcs"
#include "nwnx_area"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

const int MAX_STASHES_PER_ACCOUNT = 10;
const string STASH_ID_VAR = "StashID";
const string STASH_STORE_RESREF = "cormyr_stash";
const string STASH_ARGUMENTS_DELIMITER = "/";

const string STASH_DISTURB_OBJECT_UUID = "STASH_DISTURB_OBJECT_UUID";
const string STASH_DISTURB_SCRIPT = "stash_disturb";

// Create stash and return stash ID or 0 on error.
int stashes_CreateStash(string sOwner, string sStashName = "", string sPassword = "");

// BEWARE: Permanently delete stash with all items inside.
int stashes_DeleteStash(int iStashID);

// Save stash to database. Return FALSE on error.
int stashes_SaveStash(int iStashID, object oStash);

// Open stash for oPC. Return FALSE on error.
int stashes_OpenStash(int iStashID, object oPC);

// return string with created stash Id's of sOwner
string stashes_GetStashesList(string sOwner);

// return count of sOwner's stashes
int stashes_GetStashesCount(string sOwner);

// return TRUE if sPasswordInput matchs stash password or sAccount
// is the owner of this stash
int stashes_HasAccessToStash(int iStashID, string sAccount, string sPasswordInput);

// set sNewName for iStashID
int stashes_ChangeStashName(int iStashID, string sNewName);

// set sNewPassword for iStashID
int stashes_ChangeStashPassword(int iStashID, string sNewPassword);

// OnChat event
int stashes_ChatHandler(object oPC, string sArguments);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int stashes_CreateStash(string sOwner, string sStashName = "", string sPassword = "")
{
    object oStash = CreateObject(OBJECT_TYPE_STORE, STASH_STORE_RESREF, GetStartingLocation());
    string sUUID = GetObjectUUID(oStash);

    if(GetIsObjectValid(oStash) && GetStringLength(sUUID) > 0)
    {
        string sSQL = "INSERT INTO stashes (owner, uuid, chest, name, password) VALUES (?, ?, ?, ?, ?)";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedString(0, sOwner);
        NWNX_SQL_PreparedString(1, sUUID);
        NWNX_SQL_PreparedObjectFull(2, oStash, FALSE);
        NWNX_SQL_PreparedString(3, sStashName);
        NWNX_SQL_PreparedString(4, sPassword);
        if(NWNX_SQL_ExecutePreparedQuery())
        {
            int iStashID = db_GetDatabaseLastInsertID();
            DestroyObject(oStash);
            return iStashID;
        }
    }
    DestroyObject(oStash);
    return 0;
}

int stashes_DeleteStash(int iStashID)
{
    string sSQL = "DELETE FROM stashes WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iStashID);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_GetAffectedRows() != -1)
    {
        return TRUE;
    }
    return FALSE;
}

int stashes_SaveStash(int iStashID, object oStash)
{
    string sSQL = "UPDATE stashes SET chest = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedObjectFull(0, oStash, FALSE);
    NWNX_SQL_PreparedInt(1, iStashID);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_GetAffectedRows() != -1)
    {
        return TRUE;
    }
    return FALSE;
}

int stashes_OpenStash(int iStashID, object oPC)
{
    if(players_GetFaction(GetArea(oPC)) != players_GetFaction(oPC) && NWNX_Area_GetPVPSetting(GetArea(oPC)))
    {
        SendColorMessageToPC(oPC, "You can use stashes only on the territory of your faction and some others.", TXT_COLOR_RED);
        return FALSE;
    }
    string sSQL = "SELECT chest, uuid FROM stashes WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iStashID);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        string sUUID = NWNX_SQL_ReadDataInActiveRow(1);
        object oChest = GetObjectByUUID(sUUID);
        if(!GetIsObjectValid(oChest))
        {
            SendMessageToPC(oPC, "Stash object doesn't found on the server. Create one!");
            oChest = NWNX_SQL_ReadFullObjectInActiveRow(0, GetObjectByTag("_loc_loot"), 0.0, 0.0, 0.0, FALSE);
            if(!GetIsObjectValid(oChest))
            {
                SendMessageToPC(oPC, "Fail to create stash object");
                return FALSE;
            }
        }

        SetStoreMaxBuyPrice(oChest, 0);
        SetLocalInt(oChest, STASH_ID_VAR, iStashID);
        SetEventScript(oChest, EVENT_SCRIPT_STORE_ON_CLOSE, "stash_close");

        OpenStore(oChest, oPC);

        return TRUE;
    }
    return FALSE;
}

string stashes_GetStashesList(string sOwner)
{
    string sResult;
    string sSQL = "SELECT id, name, password FROM stashes WHERE owner = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sOwner);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        string sId;
        string sStashName;
        string sPassword;
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            sId = NWNX_SQL_ReadDataInActiveRow(0);
            sStashName = NWNX_SQL_ReadDataInActiveRow(1);
            if(sStashName == "")
            {
                sStashName = "Unnamed";
            }
            sPassword = (NWNX_SQL_ReadDataInActiveRow(2) != "") ? "password protected" : "private";
            sResult += "Label: " + sStashName + ", ID: " + sId + " [" + sPassword + "]\n";
        }
        return sResult;
    }
    return "";
}

int stashes_GetStashesCount(string sOwner)
{
    string sResult;
    string sSQL = "SELECT COUNT(*) FROM stashes WHERE owner = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sOwner);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    return 0;
}

int stashes_HasAccessToStash(int iStashID, string sAccount, string sPasswordInput)
{
    string sSQL = "SELECT owner, password FROM stashes WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iStashID);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
       if(NWNX_SQL_ReadyToReadNextRow())
       {
           NWNX_SQL_ReadNextRow();
           string sOwner = NWNX_SQL_ReadDataInActiveRow(0);
           string sPassword = NWNX_SQL_ReadDataInActiveRow(1);
           if(sOwner == sAccount) return TRUE;
           else if(sPassword == sPasswordInput && sPassword != "") return TRUE;
       }
    }
    return FALSE;
}

int stashes_ChangeStashName(int iStashID, string sNewName)
{
    string sSQL = "UPDATE stashes SET name = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sNewName);
    NWNX_SQL_PreparedInt(1, iStashID);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_GetAffectedRows() != -1)
    {
        return TRUE;
    }
    return FALSE;
}

int stashes_ChangeStashPassword(int iStashID, string sNewPassword)
{
    string sSQL = "UPDATE stashes SET password = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sNewPassword);
    NWNX_SQL_PreparedInt(1, iStashID);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_GetAffectedRows() != -1)
    {
        return TRUE;
    }
    return FALSE;
}

int stashes_ChatHandler(object oPC, string sArguments)
{
    string sCommand, Arg1, Arg2, Arg3, Arg4, Arg5;
    struct sStringTokenizer stArguments = GetStringTokenizer(sArguments, STASH_ARGUMENTS_DELIMITER);
    string sAreaTag;
    int i = -1;
    while(HasMoreTokens(stArguments)){
        stArguments = AdvanceToNextToken(stArguments);
        switch(i)
        {
            case 0: sCommand = GetNextToken(stArguments); break;
            case 1: Arg1 = GetNextToken(stArguments); break;
            case 2: Arg2 = GetNextToken(stArguments); break;
            case 3: Arg3 = GetNextToken(stArguments); break;
            case 4: Arg4 = GetNextToken(stArguments); break;
            case 5: Arg5 = GetNextToken(stArguments); break;
        }
        i++;
    }
    int ArgsNum = i - 1;
    string sAccount = GetPCPlayerName(oPC);
    if(sCommand == "list")
    {
        string sMessage = stashes_GetStashesList(sAccount);
        SendMessageToPC(oPC, sMessage);
        return TRUE;
    }
    else if(sCommand == "new")
    {
        string sStashName = Arg1;
        string sPassword = Arg2;

        if(GetStringLength(sAccount) > 0)
        {
            if(stashes_GetStashesCount(sAccount) >= MAX_STASHES_PER_ACCOUNT)
            {
                SendMessageToPC(oPC, "You have maximum stashes per account.");
                return FALSE;
            }
            int iNewStashID = stashes_CreateStash(sAccount, sStashName, sPassword);
            if(iNewStashID > 0)
            {
                SendMessageToPC(oPC, "Stash succesfully created. ID: " + IntToString(iNewStashID));
                return TRUE;
            }
            return FALSE;
        }
    }
    else if(sCommand == "edit")
    {
        int iStashID = StringToInt(Arg1);
        string sStashNameInput = Arg2;
        string sPasswordInput = Arg3;
        if(iStashID > 0)
        {
            string sSQL = "SELECT owner, uuid FROM stashes WHERE id = ?";
            NWNX_SQL_PrepareQuery(sSQL);
            NWNX_SQL_PreparedInt(0, iStashID);
            if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
            {
                NWNX_SQL_ReadNextRow();
                string sOwner = NWNX_SQL_ReadDataInActiveRow(0);
                if(sOwner == sAccount)
                {
                    stashes_ChangeStashName(iStashID, sStashNameInput);

                    if(stashes_ChangeStashPassword(iStashID, sPasswordInput))
                    {
                        // password changed. close other sessions by destroying stash object
                        string sStashUUID = NWNX_SQL_ReadDataInActiveRow(1);
                        object oStash = GetObjectByUUID(sStashUUID);
                        if(GetIsObjectValid(oStash))
                        {
                            object oItem = GetFirstItemInInventory(oStash);
                            while(GetIsObjectValid(oItem))
                            {
                                DestroyObject(oItem);
                                oItem = GetNextItemInInventory(oStash);
                            }
                            DestroyObject(oStash);
                        }
                    }
                    return TRUE;
                }
            }
        }
        return FALSE;
    }
    else if(sCommand == "open")
    {
        int nStashID = StringToInt(Arg1);
        string sPasswordInput = Arg2;

        if(GetStringLength(sAccount) > 0)
        {
            if(stashes_HasAccessToStash(nStashID, sAccount, sPasswordInput) && stashes_OpenStash(nStashID, oPC))
            {
                SendMessageToPC(oPC, "Stash succesfully opened.");
                return TRUE;
            }
            SendMessageToPC(oPC, "Stash doesn't exists or you doesn't have access rights.");
            return FALSE;
        }
    }
    else if(sCommand == "delete")
    {
        SendMessageToPC(oPC, "NOTIMPLEMENTED: Stash delete");
        return FALSE;
    }
    else if(sCommand == "log")
    {
        SendMessageToPC(oPC, "NOTIMPLEMENTED: Stash log");
        return FALSE;
    }
    SendMessageToPC(oPC, ColorText("\n             Stash commands list:\n", TXT_COLOR_GREEN_L) +
                         ColorText("!stash/list", TXT_COLOR_GREEN_L) + " - list of your stashes.\n" +
                         ColorText("!stash/new/NAME/PASSWORD", TXT_COLOR_GREEN_L) + " - create new stash with NAME and PASSWORD. Only the owner has access without a password.\n" +
                         ColorText("!stash/edit/ID/NAME/PASSWORD", TXT_COLOR_GREEN_L) + " - edit NAME and PASSWORD. Available only to the owner.\n" +
                         ColorText("!stash/open/ID/PASSWORD", TXT_COLOR_GREEN_L) + " - open stash. PASSWORD is required to access someone else's stash.");
    return FALSE;
}



//void main(){}

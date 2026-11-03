#include "_inc_players"
#include "nw_inc_nui"
#include "_inc_stashes"
#include "_inc_generic"


///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

//
void nui_CreatePlayerMenu(object oPC);

//
string nui_GetStargateExitName(object oStargate);

//
void nui_FillPlayerMenuStashCombo(object oPC, int nToken);

//
int nui_GetLastOpenedStashID(object oPC);

//
int nui_OpenStash(object oPC, int nToken);

//
void nui_DeleteStash(object oPC, int nToken);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////


void nui_CreatePlayerMenu(object oPC)
{
    int nToken = NuiCreateFromResRef(oPC, CONST_CORMYR_NUI_PLAYER_MENU, CONST_CORMYR_NUI_PLAYER_MENU);

    int nFaction = players_GetFaction(oPC);
    string sExitAreaName1 = nui_GetStargateExitName(players_GetFactionStargate(nFaction, 1));
    string sExitAreaName2 = nui_GetStargateExitName(players_GetFactionStargate(nFaction, 2));
    string sExitAreaName3 = nui_GetStargateExitName(players_GetFactionStargate(nFaction, 3));
    json jColor1 = sExitAreaName1 == "Undefined Area" ? NuiColor(254, 1, 1) : NuiColor(32, 254, 32);
    json jColor2 = sExitAreaName2 == "Undefined Area" ? NuiColor(254, 1, 1) : NuiColor(32, 254, 32);
    json jColor3 = sExitAreaName3 == "Undefined Area" ? NuiColor(254, 1, 1) : NuiColor(32, 254, 32);
    // bind values
    NuiSetBind(oPC, nToken, "btn_stgate1_ttip", JsonString(sExitAreaName1));
    NuiSetBind(oPC, nToken, "btn_stgate2_ttip", JsonString(sExitAreaName2));
    NuiSetBind(oPC, nToken, "btn_stgate3_ttip", JsonString(sExitAreaName3));
    NuiSetBind(oPC, nToken, "btn_stgate1_clr", jColor1);
    NuiSetBind(oPC, nToken, "btn_stgate2_clr", jColor2);
    NuiSetBind(oPC, nToken, "btn_stgate3_clr", jColor3);
    // fill stash combo
    nui_FillPlayerMenuStashCombo(oPC, nToken);
}

string nui_GetStargateExitName(object oStargate)
{
    string VAR_ANCHOR = "ANCHOR_UUID_" + GetLocalString(oStargate, "STARGATE_UUID");
    location lDest = GetLocalLocation(oStargate, VAR_ANCHOR);
    string sAreaName = GetName(GetAreaFromLocation(lDest));
    if(sAreaName != "")
        return sAreaName;
    else
        return "Undefined Area";
}

void nui_FillPlayerMenuStashCombo(object oPC, int nToken)
{
    json jStashCombo = JsonArray();
    string sSQL = "SELECT G.stash_id, G.stash_label FROM stashes_gui G WHERE G.account = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, GetPCPlayerName(oPC));
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        while(NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            int sStashID = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
            string sStashLabel = NWNX_SQL_ReadDataInActiveRow(1);
            if(sStashLabel == "")
                sStashLabel = IntToString(sStashID);
            jStashCombo = JsonArrayInsert(jStashCombo, NuiComboEntry(sStashLabel, sStashID));
        }
    }
    NuiSetBind(oPC, nToken, "cmb_stash_entry", jStashCombo);
    int nLastOpenedStashID = nui_GetLastOpenedStashID(oPC);
    if(nLastOpenedStashID > 0)
        // if no delay NuiGetBind often return incorrect value (???) strange behavoir, -2h of life for debugging
        DelayCommand(0.01, NuiSetBind(oPC, nToken, "cmb_stash_select", JsonInt(nLastOpenedStashID)));
}

int nui_GetLastOpenedStashID(object oPC)
{
    int nLastOpenedStashID = GetLocalInt(oPC, "LAST_OPENED_STASH_ID");
    if(nLastOpenedStashID)
        return nLastOpenedStashID;
    string sSQL = "SELECT last_gui_stash_id FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, GetPCPlayerName(oPC));
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nLastOpenedStashID = StringToInt(NWNX_SQL_ReadDataInActiveRow());
        if(!nLastOpenedStashID)
            nLastOpenedStashID = -1;
    }
    SetLocalInt(oPC, "LAST_OPENED_STASH_ID", nLastOpenedStashID);
    return nLastOpenedStashID;
}

int nui_OpenStash(object oPC, int nToken)
{
    int nStashID = JsonGetInt(NuiGetBind(oPC, nToken, "cmb_stash_select"));
    //ServerShout("nui_OpenStash, cmb_stash_select: " + IntToString(nStashID));
    if(!nStashID)
    {
        SendColorMessageToPC(oPC, "No stash selected.", TXT_COLOR_RED);
        return FALSE;
    }
    string sAccount = GetPCPlayerName(oPC);
    string sPassword = "";
    string sSQL = "SELECT stash_pass FROM stashes_gui WHERE account = ? and stash_id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_PreparedInt(1, nStashID);
    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sPassword = NWNX_SQL_ReadDataInActiveRow();
    }
    if(stashes_HasAccessToStash(nStashID, sAccount, sPassword))
    {
        if(stashes_OpenStash(nStashID, oPC))
        {
            SetLocalInt(oPC, "LAST_OPENED_STASH_ID", nStashID);
            return TRUE;
        }
        else
            return FALSE;
    }
    else
    {
        SendColorMessageToPC(oPC, "Invalid password.", TXT_COLOR_RED);
        return FALSE;
    }
}

void nui_AddStash(object oPC, int nToken)
{
    string sStashID = JsonGetString(NuiGetBind(oPC, nToken, "txt_stash_id"));
    string sStashPass = JsonGetString(NuiGetBind(oPC, nToken, "txt_stash_pass"));
    int nStashID = StringToInt(sStashID);
    if(!nStashID)
    {
        SendColorMessageToPC(oPC, "Enter stash ID.", TXT_COLOR_RED);
        return;
    }
    if(sStashPass == "")
    {
        SendColorMessageToPC(oPC, "Enter stash password.", TXT_COLOR_RED);
        return;
    }
    string sAccount = GetPCPlayerName(oPC);
    if(!stashes_HasAccessToStash(nStashID, sAccount, sStashPass))
    {
        SendColorMessageToPC(oPC, "Incorrect ID or password was entered.", TXT_COLOR_RED);
        return;
    }
    string sStashName = "";
    if(NWNX_SQL_ExecuteQuery("SELECT name FROM stashes WHERE id = " + IntToString(nStashID)) && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sStashName = NWNX_SQL_ReadDataInActiveRow();
    }
    if(sStashName == "")
        sStashName = "Unknown";

    string sSQL = "INSERT INTO stashes_gui (account, stash_id, stash_label, stash_pass) " +
                  "VALUES (?, ?, ?, ?) " +
                  "ON DUPLICATE KEY UPDATE stash_label = ?, stash_pass = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_PreparedInt(1, nStashID);
    NWNX_SQL_PreparedString(2, sStashName);
    NWNX_SQL_PreparedString(3, sStashPass);
    NWNX_SQL_PreparedString(4, sStashName);
    NWNX_SQL_PreparedString(5, sStashPass);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        int nEffectedRows = NWNX_SQL_GetAffectedRows();
        if(nEffectedRows == 1)
        {
            SendColorMessageToPC(oPC, "Stash successfully added.", TXT_COLOR_GREEN_L);
        }
        else if(nEffectedRows > 1)
            SendColorMessageToPC(oPC, "Stash successfully updated.", TXT_COLOR_GREEN_L);
        else
            SendColorMessageToPC(oPC, "Stash is already added.", TXT_COLOR_RED);
        if(nEffectedRows)
            nui_FillPlayerMenuStashCombo(oPC, nToken);
    }
    else
        SendColorMessageToPC(oPC, "Failed to add stash.", TXT_COLOR_RED);
}

void nui_DeleteStash(object oPC, int nToken)
{
    string sStashID = JsonGetString(NuiGetBind(oPC, nToken, "txt_stash_id"));
    int nStashID = StringToInt(sStashID);
    if(!nStashID)
    {
        SendColorMessageToPC(oPC, "Enter stash ID.", TXT_COLOR_RED);
        return;
    }
    string sAccount = GetPCPlayerName(oPC);
    string sSQL = "DELETE from stashes_gui WHERE account = ? and stash_id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_PreparedInt(1, nStashID);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        int nEffectedRows = NWNX_SQL_GetAffectedRows();
        if(nEffectedRows)
        {
            SendColorMessageToPC(oPC, "Stash successfully deleted.", TXT_COLOR_GREEN_L);
            nui_FillPlayerMenuStashCombo(oPC, nToken);
        }
        else
            SendColorMessageToPC(oPC, "No stash with the specified ID was found.", TXT_COLOR_RED);
    }
}

//void main() {}

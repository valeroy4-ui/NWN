#include "_inc_nui"
#include "_inc_chat"
#include "_inc_obelisk"


void main()
{
    object oPC     = NuiGetEventPlayer();
    int    nToken  = NuiGetEventWindow();
    string sEvent  = NuiGetEventType();
    string sElem   = NuiGetEventElement();
    int    nIdx    = NuiGetEventArrayIndex();
    string sWndId  = NuiGetWindowId(oPC, nToken);

    if(sWndId == CONST_CORMYR_NUI_PLAYER_MENU)
    {
        if(sEvent == "click" && (sElem == "btn_stgate1" || sElem == "btn_stgate2" || sElem == "btn_stgate3"))
        {
            string sLastBtnIdChar = GetSubString(sElem, GetStringLength(sElem) - 1, 1);
            object oStargate = players_GetFactionStargate(players_GetFaction(oPC), StringToInt(sLastBtnIdChar));
            if(!GetIsObjectValid(oStargate))
            {
                SendColorMessageToPC(oPC, "Stargate not found.", TXT_COLOR_WHITE);
                return;
            }
            if(NWNX_Object_GetCurrentAnimation(oStargate) == NWNX_ANIMATION_PLACEABLE_ACTIVATED)
            {
                SendColorMessageToPC(oPC, "Stargate is already activated.", TXT_COLOR_WHITE);
                return;
            }
            NWNX_Creature_DoItemCastSpell(oPC, oPC, LOCATION_INVALID, SPELL_GATE, 40, 0.0, PROJECTILE_PATH_TYPE_DEFAULT,
                                          -1, oStargate);
        }
        else if(sEvent == "click" && sElem == "btn_fshop_open")
        {
            AssignCommand(oPC, ClearAllActions());
            AssignCommand(oPC, ActionStartConversation(oPC, "dlg_playerwand", TRUE, FALSE));
            NuiDestroy(oPC, nToken);
        }
        else if(sEvent == "click" && sElem == "btn_stash_open")
        {
            if(nui_OpenStash(oPC, nToken))
                NuiDestroy(oPC, nToken);
        }
        else if(sEvent == "click" && sElem == "btn_stash_add")
        {
            nui_AddStash(oPC, nToken);
        }
        else if(sEvent == "click" && sElem == "btn_stash_del")
        {
            nui_DeleteStash(oPC, nToken);
        }
        else if(sEvent == "click" && sElem == "btn_cmds_open")
        {
            NuiDestroy(oPC, nToken);
            int nCmdToken = NuiCreateFromResRef(oPC, CONST_CORMYR_NUI_CMD_MENU, CONST_CORMYR_NUI_CMD_MENU);
            float fX = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH))/10.0;
            NuiSetBind(oPC, nCmdToken, "cmd_w_geometry", NuiRect(fX, 1.0, 500.0, 300.0));
            players_UpdateXpBar(oPC);
        }
    }
    else if(sWndId == CONST_CORMYR_NUI_CMD_MENU)
    {
        if     (sEvent == "click" && sElem == "cmd_btn_stat")
            chat_PrintPVPStats(oPC);
        else if(sEvent == "click" && sElem == "cmd_btn_top")
            chat_PrintTop10(oPC);
        else if(sEvent == "click" && sElem == "cmd_btn_topd")
            chat_PrintDynamicTop(oPC);
        else if(sEvent == "click" && sElem == "cmd_btn_fstat")
            chat_PrintFactionPVPStats(oPC);
        else if(sEvent == "click" && sElem == "cmd_btn_lstat")
            chat_PrintLootStats(oPC);
        else if(sEvent == "click" && sElem == "cmd_btn_boss")
            chat_PrintBossStatuses(oPC);
        else if(sEvent == "click" && sElem == "cmd_btn_obelisk")
            obelisk_Report(oPC);
        else if(sEvent == "click" && sElem == "cmd_btn_party")
            chat_InvitePlayerIntoFactionParty(oPC);
        else if(sEvent == "click" && sElem == "cmd_btn_money")
            chat_SendMoney(oPC, "!money " + JsonGetString(NuiGetBind(oPC, nToken, "cmd_txt_money")));
        else if(sEvent == "click" && sElem == "cmd_btn_fame")
            chat_SendFame(oPC, "!fame " + JsonGetString(NuiGetBind(oPC, nToken, "cmd_txt_fame")));
        else if(sEvent == "click" && sElem == "cmd_btn_soul")
            chat_SendSoulStones(oPC, "!soul " + JsonGetString(NuiGetBind(oPC, nToken, "cmd_txt_soul")));
    }
}

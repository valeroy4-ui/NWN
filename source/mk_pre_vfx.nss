#include "mk_inc_generic"
#include "mk_inc_body"
#include "mk_inc_vfx"
#include "mk_inc_states"
#include "mk_inc_2da_disp"
#include "mk_inc_delimiter"
#include "mk_inc_cep"

int GetIsCraftingDisabled(object oPC, int i)
{
    string sVarName = "MK_DISABLE_CRAFT_" + MK_IntToString(i, 2, "0");
    return (GetLocalInt(oPC, sVarName)==1);
}


int StartingConditional()
{
    object oPC = GetPCSpeaker();

    int nState = MK_GenericDialog_GetState();
//    MK_DEBUG_TRACE("mk_pre_vfx2: nState="+IntToString(nState));

    int nCurrentPage=-1;

    int nAction = MK_GenericDialog_GetAction();

    int nVFXMode = -1;

    switch (nState)
    {
    case MK_STATE_VFX_SELECT_FILTER:
        switch (nAction)
        {
        case 250:
        case 251:
        case 252:
        case 253:
            nCurrentPage = MK_2DA_DISPLAY_UpdatePage(nAction);
            break;
        case -1:
            break;
        default:
            if ((nAction>=0) && (nAction<MK_2DA_DISPLAY_GetPageLength()))
            {
                nVFXMode = MK_2DA_DISPLAY_GetSelectedRow(nAction);
                MK_VFX_SetVFXMode(nVFXMode, oPC);
 //               MK_DEBUG_TRACE("mk_pre_vfx2: nVFXMode="+IntToString(nVFXMode));
                string s2DA = MK_VFX_Get_VFXModeFile();
                MK_GenericDialog_SetState(nState = MK_STATE_VFX_SELECT_EFFECT);
                string sScrCheck = Get2DAString(s2DA, "SCR_CHECK", nVFXMode);
                int nMaxHoleSize = MK_Get2DAInt(s2DA, "MAX_HOLE_SIZE", nVFXMode, 10);

                MK_2DA_DISPLAY_Initialize(
                    MK_VFX_Get2DAFile(nVFXMode),
                    "Label",
                    "Label",
                    "",
                    "Type_FD",
                    nMaxHoleSize,
                    sScrCheck
                    );

                MK_2DA_DISPLAY_SetPageLength(MK_VFX_GetNumberOfVFXPerPage(oPC));
                nCurrentPage = MK_2DA_DISPLAY_GetCurrentPage();
                nAction = -1;
                MK_CraftBody_SetDefaultCameraFacing(oPC);
            }
        }
        break;
    case MK_STATE_VFX_SELECT_EFFECT:
        switch (nAction)
        {
        case 250:
        case 251:
        case 252:
        case 253:
            nCurrentPage = MK_2DA_DISPLAY_UpdatePage(nAction);
            break;
        case 255:
            MK_GenericDialog_SetState(nState = MK_STATE_VFX_INIT_FILTER);
            break;
        case 127:
            // Remove all effects
            MK_VFX_RemoveAllEffects(oPC);
            break;
        case -1:
            break;
        default:
            if ((nAction>=0) && (nAction<MK_2DA_DISPLAY_GetPageLength()))
            {
                int nRow = MK_2DA_DISPLAY_GetSelectedRow(nAction);
                nVFXMode = MK_VFX_GetVFXMode(oPC);
                int nVFX = MK_VFX_GetVFX(nVFXMode, nRow, oPC);
//                MK_DEBUG_TRACE("mk_pre_vfx2: nAction="+IntToString(nAction)
//                    +", nRow="+IntToString(nRow)
//                    +", nVFXMode="+IntToString(nVFXMode)
//                    +", nVFX="+IntToString(nVFX));
                if (nVFX!=-1)
                {
                    if (MK_VFX_GetHasVFX(oPC, nVFX))
                    {
//                    MK_DEBUG_TRACE("mk_pre_vfx2: remove vfx("+IntToString(nVFX)+")");
                        if (!MK_VFX_RemoveVFX(oPC, nVFX))
                        {
                            SendMessageToPC(oPC, "Failed to remove the selected vfx!");
                        }
                    }
                    else
                    {
//                        MK_DEBUG_TRACE("mk_pre_vfx2: apply vfx("+IntToString(nVFX)+")");
                        if (!MK_VFX_ApplyVFX(oPC, nVFX, nVFXMode, nRow))
                        {
                            SendMessageToPC(oPC, "Failed to apply the selected vfx!");
                        }
                    }
                }
            }
        }
        break;
    default:
        MK_GenericDialog_SetState(nState = MK_STATE_VFX_INIT_FILTER);
        break;
    }

    switch (nState)
    {
    case MK_STATE_VFX_INIT_FILTER:
        MK_2DA_DISPLAY_Initialize(MK_VFX_Get_VFXModeFile(), "", "LABEL", "STRREF", "NAME", 10, "mk_cb_vfx_filter");
        MK_2DA_DISPLAY_SetPageLength(10);
        MK_GenericDialog_SetState(nState = MK_STATE_VFX_SELECT_FILTER);
        break;
    }

    nCurrentPage = MK_2DA_DISPLAY_GetCurrentPage();

    switch (nState)
    {
    case MK_STATE_VFX_SELECT_FILTER:
        MK_2DA_DISPLAY_DisplayPage(nCurrentPage, -1, "", FALSE);
        MK_DELIMITER_Initialize();
        break;
    case MK_STATE_VFX_SELECT_EFFECT:
    {
        MK_2DA_DISPLAY_DisplayPage(nCurrentPage, -1, "mk_cb_vfx_label", FALSE);

        nVFXMode = MK_VFX_GetVFXMode(oPC);
        string sWarning="";
        int nStrRef = (MK_Get2DAInt(MK_VFX_Get_VFXModeFile(), "MESSAGE", nVFXMode, 0));
        if (nStrRef!=0)
        {
            sWarning = " "+MK_TLK_GetStringByStrRef(nStrRef);
        }
        SetCustomToken(14430, sWarning);

        MK_GenericDialog_SetCondition(127, TRUE);
        MK_DELIMITER_Initialize();
        break;
    }
    }

    return TRUE;
/*
    case MK_STATE_VFX_EYES:
    case MK_STATE_VFX_LIGHT:
    case MK_STATE_VFX_CEP:
    case MK_STATE_VFX_USER:
    case MK_STATE_VFX_ALL:
        nVFXmode = nState-24;
        nCurrentPage = MK_2DA_DISPLAY_GetCurrentPage();
//        MK_DEBUG_TRACE("mk_pre_vfx2: nAction="+IntToString(nAction));

        switch (nAction)
        {
        case -1:
            break;
        case 250:
        case 251:
        case 252:
        case 253:
            nCurrentPage = MK_2DA_DISPLAY_UpdatePage(nAction);
            break;
        case 127:
            // Remove all effects
            MK_VFX_RemoveAllEffects(oPC);
            break;
        case 255:
            MK_GenericDialog_SetState(nState = MK_STATE_BODY_SELECT);
            break;
        default:
            if ((nAction>=0) && (nAction<MK_2DA_DISPLAY_GetPageLength()))
            {
                int nVFX = MK_2DA_DISPLAY_GetValueAsInt(nAction);
                if (nVFX!=-1)
                {
                    if (MK_VFX_GetHasVFX(oPC, nVFX))
                    {
//                    MK_DEBUG_TRACE("mk_pre_vfx2: remove vfx("+IntToString(nVFX)+")");
                        if (!MK_VFX_RemoveVFX(oPC, nVFX))
                        {
                            SendMessageToPC(oPC, "Failed to remove the selected vfx!");
                        }
                    }
                    else
                    {
//                        MK_DEBUG_TRACE("mk_pre_vfx2: apply vfx("+IntToString(nVFX)+")");
                        if (!MK_VFX_ApplyVFX(oPC, nVFX, nVFXmode, MK_2DA_DISPLAY_GetSelectedRow(nAction)))
                        {
                            SendMessageToPC(oPC, "Failed to apply the selected vfx!");
                        }
                    }
                }
            }
            break;
        }
    default:
//        MK_DEBUG_TRACE("mk_pre_vfx2: nAction="+IntToString(nAction));
        switch (nAction)
        {
        case 24:
        case 25:
        case 26:
        case 27:
        case 28:
        {
            nState = nAction;
            nVFXmode = nState-24;
            MK_GenericDialog_SetState(nState);
            MK_DEBUG_TRACE("mk_pre_vfx: nVFXmode="+IntToString(nVFXmode));
            MK_2DA_DISPLAY_Initialize(
                MK_VFX_Get2DAFile(nVFXmode),
                MK_VFX_GetValueColumn(nVFXmode),
                "Label",
                "",
                "Type_FD",
                1500,
                ((nVFXmode!=MK_VFX_MODE_ALL) ? "mk_cb_vfx_check" : "")
                );

            MK_2DA_DISPLAY_SetPageLength(MK_VFX_GetNumberOfVFXPerPage(oPC));
            nCurrentPage = MK_2DA_DISPLAY_GetCurrentPage();
            nAction = -1;
            MK_CraftBody_SetDefaultCameraFacing(oPC);
            break;
        }
        }
        break;
    }
*/

/*
    switch (nState)
    {
    case MK_STATE_VFX_EYES:
    case MK_STATE_VFX_LIGHT:
    case MK_STATE_VFX_CEP:
    case MK_STATE_VFX_USER:
    case MK_STATE_VFX_ALL:
    {
        MK_2DA_DISPLAY_DisplayPage(nCurrentPage, -1, "mk_cb_vfx_label");

        string sWarning = "";
        switch (nState)
        {
        case MK_STATE_VFX_ALL:
            sWarning = "\nSome effects seem to stay on your character even when they shouldn't. However save and reload usually should fix that.";
            break;
        }

        SetCustomToken(14430, sWarning);

        MK_GenericDialog_SetCondition(127, TRUE);

        MK_DELIMITER_Initialize();
        break;
    }
    default:
    {
//        MK_DEBUG_TRACE("mk_pre_vfx2: !!!!");
        int iCondition;
        int bOk;
        for (iCondition=24; iCondition<=28; iCondition++)
        {
            bOk = (!GetIsCraftingDisabled(oPC, iCondition))
                && (MK_VFX_Get2DAFile(iCondition-24)!="");
            switch (iCondition)
            {
            case 24:
                bOk = (bOk && MK_VERSION_GetIsVersionGreaterEqual_1_69(oPC));
                break;
            case 26:
                bOk = (bOk && MK_CEP_GetIsCEPInstalled());
                break;
            }
            MK_GenericDialog_SetCondition(iCondition, bOk);
        }
        break;
    }
    }
*/
    return TRUE;
}

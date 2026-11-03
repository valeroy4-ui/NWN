#include "mk_inc_generic"
#include "mk_inc_states"
#include "mk_inc_delimiter"
#include "mk_inc_2da_disp"
#include "mk_inc_ccoh_db"


const string MK_FOOTSTEP_TYPE_SAVE = "MK_WINGS_TYPE_SAVE";

void RestoreOriginalFootstepType(object oPC)
{
    string sIAStr = GetLocalString(oPC, MK_FOOTSTEP_TYPE_SAVE);
    MK_DEBUG_TRACE("Restoring original footstep type: '"+sIAStr+"'");
    if (sIAStr!="")
    {
        MK_CCOH_DB_IAStrToBodyAppearance(oPC, sIAStr, MK_CCOH_DB_BODY_APPR_FOOTSTEP);
        DeleteLocalString(oPC, MK_FOOTSTEP_TYPE_SAVE);
    }
}

void SaveOriginalFootstepType(object oPC)
{
    string sIAStr = GetLocalString(oPC, MK_FOOTSTEP_TYPE_SAVE);
    if (sIAStr=="")
    {
        sIAStr = MK_CCOH_DB_BodyAppearanceToIAStr(oPC, MK_CCOH_DB_BODY_APPR_FOOTSTEP);
        SetLocalString(oPC, MK_FOOTSTEP_TYPE_SAVE, sIAStr);
    }
}

int GetHasOriginalFootstepType(object oPC)
{
    string sIAStr1 = GetLocalString(oPC, MK_FOOTSTEP_TYPE_SAVE);
    string sIAStr2 = MK_CCOH_DB_BodyAppearanceToIAStr(oPC, MK_CCOH_DB_BODY_APPR_FOOTSTEP);
    return (sIAStr1=="") || (sIAStr1==sIAStr2);
}

string GetFootstepSoundResRef(object oPC, int nFootstepSound)
{
    location loc = GetLocation(oPC);
    int nSurfaceMaterial = GetSurfaceMaterial(loc);
    int nNumber = GetLocalInt(oPC, "MK_FOOTSTEP_SOUND_NR");
    nNumber = (nNumber + 1) % 3;
    SetLocalInt(oPC, "MK_FOOTSTEP_SOUND_NR", nNumber);
    string sMaterial = Get2DAString("surfacemat", "Name", nSurfaceMaterial);
    if (sMaterial=="") sMaterial = "Stone";
    string sColumn = sMaterial + IntToString(nNumber);
    string sResRef = Get2DAString("footstepsounds", sColumn , nFootstepSound);
//    MK_DEBUG_TRACE("GetFootstepSoundResRef(): nSurfaceMaterial="+IntToString(nSurfaceMaterial)
//        +"', sColumn='"+sColumn
//        +"', sResRef='"+sResRef+"'");
    return sResRef;
}

void PlayCurrentFootstepSound(object oPC)
{
    int nFootstepSound = GetFootstepType(oPC);
    string sSoundResRef = GetFootstepSoundResRef(oPC, nFootstepSound);
    SendMessageToPC(oPC, "Playing '"+sSoundResRef+"' ...");
    PlaySound(sSoundResRef);
}


int StartingConditional()
{
    object oPC = GetPCSpeaker();

    MK_CCOH_DB_Init(oPC);

    int nState = MK_GenericDialog_GetState();
    int nAction = MK_GenericDialog_GetAction();

    int nCurrentPage;

    switch (nState)
    {
    case MK_STATE_FOOTSTEP:
        nCurrentPage = MK_2DA_DISPLAY_GetCurrentPage();
        switch (nAction)
        {
        case 250:
        case 251:
        case 252:
        case 253:
            nCurrentPage = MK_2DA_DISPLAY_UpdatePage(nAction);
            break;
        case 127:
            // Restore original appearance
            RestoreOriginalFootstepType(oPC);
            break;
        default:
            if ((nAction>=0) && (nAction<MK_2DA_DISPLAY_GetPageLength()))
            {
                int nNewFootstepType = MK_2DA_DISPLAY_GetValueAsInt(nAction);
                if (nNewFootstepType!=-1)
                {
                    SaveOriginalFootstepType(oPC);
                    SetFootstepType(nNewFootstepType, oPC);
                    PlayCurrentFootstepSound(oPC);
                }
            }
            break;
        }
        break;
    default:
        nState = MK_STATE_FOOTSTEP;
        MK_2DA_DISPLAY_Initialize("footstepsounds", "", "Label", "", "", 300);
        nCurrentPage = MK_2DA_DISPLAY_GetCurrentPage();
        MK_GenericDialog_SetState(nState);
        CISetCurrentModMode(oPC, MK_CI_MODMODE_BODY);
        break;
    }

    switch (nState)
    {
    case MK_STATE_FOOTSTEP:
        MK_2DA_DISPLAY_DisplayPage(nCurrentPage, GetFootstepType(oPC));

        MK_GenericDialog_SetCondition(127, !GetHasOriginalFootstepType(oPC));
        MK_GenericDialog_SetCondition(254, MK_CCOH_DB_GetIsBodyChanged(oPC));

        MK_DELIMITER_Initialize();
        break;
    }

    return TRUE;
}

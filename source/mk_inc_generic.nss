#include "mk_inc_debug"

const int MK_GENERIC_DIALOG_DEBUG = FALSE;

const int MK_GENERIC_DIALOG_NUMBER_OF_VARIABLES = 256;

const int MK_GENERIC_DIALOG_INVALID_ACTION = -1;

const int MK_GENERIC_DIALOG_STATE_DISPLAY_TOKEN = 14400;

const string MK_DISABLED_OPTIONS_COLOR = "MK_DISABLED_OPTIONS_COLOR";

const string MK_GENERIC_ACTION_SCRIPT = "MK_GENERIC_ACTION_SCRIPT";

void MK_GenericDialog_CleanUp();

int MK_GenericDialog_SetState(int nState);

int MK_GenericDialog_GetState(int bClearState=FALSE);

int MK_GenericDialog_StateToCustomToken(int nToken);

int MK_GenericDialog_IsInState(int nState, int bClearState=FALSE);

void MK_GenericDialog_SetCondition(int nCondition, int bIsTrue);

void MK_GenericDialog_SetConditionRange(int nConditionFrom, int nConditionTo, int bTrue);

int MK_GenericDialog_GetCondition(int nCondition);

void MK_GenericDialog_SetObject(int nObject, object oObject);

object MK_GenericDialog_GetObject(int nObject);

void MK_GenericDialog_SetAction(int nAction);

int MK_GenericDialog_GetAction(int bClearAction=TRUE);

void MK_GenericDialog_SetCurrentPage(int nState, int nPage);

int MK_GenericDialog_GetCurrentPage(int nState);

void MK_GenericDialog_DEBUG_TRACE(string sMessage)
{
    if (MK_GENERIC_DIALOG_DEBUG)
    {
        MK_DEBUG_TRACE(sMessage);
    }
}

void MK_GenericDialog_CleanUp()
{
    SetCustomToken(MK_GENERIC_DIALOG_STATE_DISPLAY_TOKEN,"");
    int iVar;
    for (iVar=0; iVar<MK_GENERIC_DIALOG_NUMBER_OF_VARIABLES; iVar++)
    {
        DeleteLocalInt(OBJECT_SELF, "MK_CONDITION_"+IntToString(iVar));
        DeleteLocalObject(OBJECT_SELF, "MK_OBJECT_"+IntToString(iVar));
    }
    DeleteLocalInt(OBJECT_SELF, "MK_ACTION");
    DeleteLocalInt(OBJECT_SELF, "MK_STATE");

    DeleteLocalString(OBJECT_SELF, MK_GENERIC_ACTION_SCRIPT);
}

string MK_GenericDialog_GetActionScript(int bClearScript=TRUE)
{
    string sActionScript = GetLocalString(OBJECT_SELF, MK_GENERIC_ACTION_SCRIPT);
    if (bClearScript)
    {
        DeleteLocalString(OBJECT_SELF, MK_GENERIC_ACTION_SCRIPT);
    }
    return sActionScript;
}

void  MK_GenericDialog_SetActionScript(string sActionScript)
{
    SetLocalString(OBJECT_SELF, MK_GENERIC_ACTION_SCRIPT, sActionScript);
}

int MK_GenericDialog_SetState(int nState)
{
    int nOldState = GetLocalInt(OBJECT_SELF, "MK_STATE");
    MK_GenericDialog_DEBUG_TRACE("MK_GenericDialog_SetState("+IntToString(nState)+"), oldState = "+IntToString(nOldState));

    SetLocalInt(OBJECT_SELF, "MK_STATE", nState);
//    SetCustomToken(MK_GENERIC_DIALOG_STATE_DISPLAY_TOKEN, "MK_GenericDialog: current state = <cюҐ >"+IntToString(nState)+"</c>\n");
    return nOldState;
}

int MK_GenericDialog_GetState(int bClearState=FALSE)
{
    int nState = GetLocalInt(OBJECT_SELF, "MK_STATE");
    if (bClearState)
    {
        MK_GenericDialog_SetState(-1);
    }
    return nState;
}

int MK_GenericDialog_IsInState(int nState, int bClearState=FALSE)
{
    return MK_GenericDialog_GetState()==nState;
}

void MK_GenericDialog_SetCondition(int nCondition, int bIsTrue)
{
    MK_GenericDialog_DEBUG_TRACE("MK_GenericDialog_SetCondition("+IntToString(nCondition)+", "+IntToString(bIsTrue)+")");
    SetLocalInt(OBJECT_SELF, "MK_CONDITION_"+IntToString(nCondition), bIsTrue);
}

void MK_GenericDialog_SetConditionRange(int nConditionFrom, int nConditionTo, int bIsTrue)
{
    int iCondition;
    for (iCondition=nConditionFrom; iCondition<=nConditionTo; iCondition++)
    {
        MK_GenericDialog_SetCondition(iCondition, bIsTrue);
    }
}

int MK_GenericDialog_GetCondition(int nCondition)
{
    return GetLocalInt(OBJECT_SELF, "MK_CONDITION_"+IntToString(nCondition));
}

void MK_GenericDialog_SetObject(int nObject, object oObject)
{
    SetLocalObject(OBJECT_SELF, "MK_OBJECT_"+IntToString(nObject), oObject);
}

object MK_GenericDialog_GetObject(int nObject)
{
    return GetLocalObject(OBJECT_SELF, "MK_OBJECT_"+IntToString(nObject));
}

void MK_GenericDialog_SetAction(int nAction)
{
    SetLocalInt(OBJECT_SELF, "MK_ACTION", nAction);
    string sActionScript = MK_GenericDialog_GetActionScript();
    MK_GenericDialog_DEBUG_TRACE("MK_GenericDialog_SetAction("+IntToString(nAction)+"[,'"+sActionScript+"'])");
    if (sActionScript!="")
    {
        ExecuteScript(sActionScript, OBJECT_SELF);
    }
}

int MK_GenericDialog_GetAction(int bClearAction=TRUE)
{
    int nAction = GetLocalInt(OBJECT_SELF, "MK_ACTION");
    if (bClearAction)
    {
        SetLocalInt(OBJECT_SELF, "MK_ACTION", MK_GENERIC_DIALOG_INVALID_ACTION);
    }
    return nAction;
}

void MK_GenericDialog_SetCurrentPage(int nState, int nPage)
{
    SetLocalInt(OBJECT_SELF, "MK_GENERIC_CURRENTPAGE_"+IntToString(nState), nPage);
}

int MK_GenericDialog_GetCurrentPage(int nState)
{
    return GetLocalInt(OBJECT_SELF, "MK_GENERIC_CURRENTPAGE_"+IntToString(nState));
}


/*
void main()
{

}
*/

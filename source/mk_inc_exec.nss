// mk_inc_exec

#include "mk_inc_debug"

const string MK_EXEC_INT_VALUE = "MK_EXEC_INT_VALUE";
const string MK_EXEC_STR_VALUE = "MK_EXEC_STR_VALUE";
const string MK_EXEC_OBJ_VALUE = "MK_EXEC_OBJ_VALUE";
const string MK_EXEC_FLT_VALUE = "MK_EXEC_FLT_VALUE";

// Make oTarget run sScript and then return execution to the calling script.
// The return value should be set inside sScript by making a call to
// void MK_EXEC_INT_SetReturnValue(int nReturnValue)
// If sScript does not specify a compiled script, nothing happens.
// If sScript does not set the return value nDefault will be returned instead.
// sVarName is the name of a local int to be used to store the return value.
int MK_EXEC_INT_ExecuteScript(string sScript, object oTarget = OBJECT_SELF, int nDefault=0, string sVarName=MK_EXEC_INT_VALUE);

// Make oTarget run sScript and then return execution to the calling script.
// The return value should be set inside sScript by making a call to
// void MK_EXEC_INT_SetReturnValue(int nReturnValue)
// If sScript does not specify a compiled script, nothing happens.
// If sScript does not set the return value sDefault will be returned instead.
// sVarName is the name of a local int to be used to store the return value.
string MK_EXEC_STR_ExecuteScript(string sScript, object oTarget = OBJECT_SELF, string sDefault="", string sVarName=MK_EXEC_STR_VALUE);

// Make oTarget run sScript and then return execution to the calling script.
// The return value should be set inside sScript by making a call to
// void MK_EXEC_INT_SetReturnValue(int nReturnValue)
// If sScript does not specify a compiled script, nothing happens.
// If sScript does not set the return value sDefault will be returned instead.
// sVarName is the name of a local int to be used to store the return value.
object MK_EXEC_OBJ_ExecuteScript(string sScript, object oTarget = OBJECT_SELF, object oDefault=OBJECT_INVALID, string sVarName=MK_EXEC_STR_VALUE);


// To be used inside a script called by MK_EXEC_INT_ExecuteScript(...)
// to set the value returned by MK_EXEC_INT_ExecuteScript(...).
void MK_EXEC_INT_SetReturnValue(int nReturnValue, object oTarget = OBJECT_SELF, string sVarName=MK_EXEC_INT_VALUE);

// To be used inside a script called by MK_EXEC_STR_ExecuteScript(...)
// to set the value returned by MK_EXEC_STR_ExecuteScript(...).
void MK_EXEC_STR_SetReturnValue(string sReturnValue, object oTarget = OBJECT_SELF, string sVarName=MK_EXEC_INT_VALUE);

// To be used inside a script called by MK_EXEC_OBJ_ExecuteScript(...)
// to set the value returned by MK_EXEC_OBJ_ExecuteScript(...).
void MK_EXEC_OBJ_SetReturnValue(object oReturnValue, object oTarget = OBJECT_SELF, string sVarName=MK_EXEC_INT_VALUE);


void MK_EXEC_INT_SetReturnValue(int nReturnValue, object oTarget, string sVarName)
{
    SetLocalInt(oTarget, sVarName, nReturnValue);
    MK_DEBUG_TRACE("MK_EXEC_INT_SetReturnValue("+IntToString(nReturnValue)+", "+GetName(oTarget)+", "+sVarName+")");
}

void MK_EXEC_STR_SetReturnValue(string sReturnValue, object oTarget, string sVarName)
{
    SetLocalString(oTarget, sVarName, sReturnValue);
}

void MK_EXEC_OBJ_SetReturnValue(object oReturnValue, object oTarget, string sVarName)
{
    SetLocalObject(oTarget, sVarName, oReturnValue);
}

int MK_EXEC_INT_GetReturnValue(object oTarget, string sVarName=MK_EXEC_INT_VALUE)
{
    return GetLocalInt(oTarget, sVarName);
}

string MK_EXEC_STR_GetReturnValue(object oTarget, string sVarName=MK_EXEC_INT_VALUE)
{
    return GetLocalString(oTarget, sVarName);
}

object MK_EXEC_OBJ_GetReturnValue(object oTarget, string sVarName=MK_EXEC_INT_VALUE)
{
    return GetLocalObject(oTarget, sVarName);
}

void MK_EXEC_INT_DeleteReturnValue(object oTarget, string sVarName=MK_EXEC_INT_VALUE)
{
    DeleteLocalInt(oTarget, sVarName);
}

void MK_EXEC_STR_DeleteReturnValue(object oTarget, string sVarName=MK_EXEC_INT_VALUE)
{
    DeleteLocalString(oTarget, sVarName);
}

void MK_EXEC_OBJ_DeleteReturnValue(object oTarget, string sVarName=MK_EXEC_INT_VALUE)
{
    DeleteLocalObject(oTarget, sVarName);
}

void MK_EXEC_ExecuteScript(string sScript, object oTarget)
{
//    if (sScript=="") return;
//    string sOverideScript = GetLocalString(GetModule(), sScript);
//    if (sOverrideScript!="")
//    {
//        sScript = sOverrideScript;
//    }
    ExecuteScript(sScript, oTarget);
}


int MK_EXEC_INT_ExecuteScript(string sScript, object oTarget, int nDefault, string sVarName=MK_EXEC_INT_VALUE)
{
    MK_EXEC_INT_SetReturnValue(nDefault, oTarget, sVarName);

    MK_EXEC_ExecuteScript(sScript, oTarget);

    int nReturn = MK_EXEC_INT_GetReturnValue(oTarget, sVarName);
    MK_DEBUG_TRACE("MK_EXEC_INT_ExecuteScript("+sScript+", "+GetName(oTarget)+", "+IntToString(nDefault)+", "+sVarName+")="+IntToString(nReturn));
    MK_EXEC_INT_DeleteReturnValue(oTarget, sVarName);
    return nReturn;
}

string MK_EXEC_STR_ExecuteScript(string sScript, object oTarget, string sDefault, string sVarName = MK_EXEC_STR_VALUE)
{
    MK_EXEC_STR_SetReturnValue(sDefault, oTarget, sVarName);

    MK_EXEC_ExecuteScript(sScript, oTarget);

    string sReturn = MK_EXEC_STR_GetReturnValue(oTarget, sVarName);
    MK_EXEC_STR_DeleteReturnValue(oTarget, sVarName);
    return sReturn;
}

object MK_EXEC_OBJ_ExecuteScript(string sScript, object oTarget, object oDefault, string sVarName=MK_EXEC_STR_VALUE)
{
    MK_EXEC_OBJ_SetReturnValue(oDefault, oTarget, sVarName);

    MK_EXEC_ExecuteScript(sScript, oTarget);

    object oReturn = MK_EXEC_OBJ_GetReturnValue(oTarget, sVarName);
    MK_EXEC_OBJ_DeleteReturnValue(oTarget, sVarName);
    return oReturn;
}

/*
void main()
{

}
/**/

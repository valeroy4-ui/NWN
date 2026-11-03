// dm_dumplocals.nss

#include "nwnx_events"
#include "nwnx_object"

void main()
{
    object oDM = OBJECT_SELF;
    object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET"));
    int nType = StringToInt(NWNX_Events_GetEventData("TYPE"));

    NWNX_Events_SkipEvent();

    object oParam = StringToObject(GetScriptParam("DUMP_LOCALS_TARGET"));
    if(GetIsObjectValid(oParam))
        oTarget = oParam;

    string sMessage;

    switch (nType)
    {
        case 0: // dm_dumplocals
        {
            sMessage = "*** Variable Dump *** [Object] Tag: " + GetTag(oTarget);
            break;
        }
        case 1: // dm_dumparealocals
        {
            oTarget = GetArea(oTarget);
            sMessage = "*** Variable Dump *** [Area] Tag: " + GetTag(oTarget);
            break;
        }
        case 2: // dm_dumpmodulelocals
        {
            oTarget = GetModule();
            sMessage = "*** Variable Dump *** [Module]";
            break;
        }
    }

    if (!GetIsObjectValid(oTarget)) return;

    int nCount = NWNX_Object_GetLocalVariableCount(oTarget);

    if (!nCount)
    {
        sMessage += "\nNone defined.";
    }
    else
    {
        int i;
        for(i = 0; i < nCount; i++)
        {
            struct NWNX_Object_LocalVariable var = NWNX_Object_GetLocalVariable(oTarget, i);

            switch (var.type)
            {
                case NWNX_OBJECT_LOCALVAR_TYPE_INT:
                    sMessage += "\n[INT] " + var.key + " = " + IntToString(GetLocalInt(oTarget, var.key));
                    break;

                case NWNX_OBJECT_LOCALVAR_TYPE_FLOAT:
                    sMessage += "\n[FLT] " + var.key + " = " + FloatToString(GetLocalFloat(oTarget, var.key), 0);
                    break;

                case NWNX_OBJECT_LOCALVAR_TYPE_STRING:
                    sMessage += "\n[STR] " + var.key + " = \"" + GetLocalString(oTarget, var.key) + "\"";
                    break;

                case NWNX_OBJECT_LOCALVAR_TYPE_OBJECT:
                    sMessage += "\n[OID] " + var.key + " = " + ObjectToString(GetLocalObject(oTarget, var.key));
                    break;

                case NWNX_OBJECT_LOCALVAR_TYPE_LOCATION:
                {
                    location loc = GetLocalLocation(oTarget, var.key);
                    vector vPos = GetPositionFromLocation(loc);

                    sMessage += "\n[LOC] " + var.key + " = (" + FloatToString(vPos.x, 0, 3) + ", " + FloatToString(vPos.y, 0, 3) + ", " + FloatToString(vPos.z, 0, 3) + ")";
                    break;
                }
                case NWNX_OBJECT_LOCALVAR_TYPE_JSON:
                {
                    json jVar = GetLocalJson(oTarget, var.key);
                    sMessage += "\n[JSON] " + var.key + " = " + JsonDump(jVar);
                    break;
                }
            }
        }
    }

    SendMessageToPC(oDM, sMessage);
}

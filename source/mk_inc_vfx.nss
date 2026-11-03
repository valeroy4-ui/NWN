//////////////////////////////////////////////////////////////////////////////
// mk_inc_vfx.nss
//////////////////////////////////////////////////////////////////////////////

#include "mk_inc_version"
#include "mk_inc_tools"
#include "mk_inc_body"

const string MK_VFX_BIOWARE_2DA = "visualeffects";

const string MK_VFX_MODE = "mk_vfx_mode";

const string MK_VFX_PER_PAGE = "MK_VFX_PER_PAGE";

const string MK_VFX = "mk_def_vfx";

/*
const int MK_VFX_MODE_GLEYES = 0;
const int MK_VFX_MODE_LIGHTS = 1;
const int MK_VFX_MODE_CEP = 2;
const int MK_VFX_MODE_USER = 3;
const int MK_VFX_MODE_ALL = 4;
const int MK_VFX_MODE_ERROR = -1;
*/

//////////////////////////////////////////////////////////////////////////////
string MK_VFX_Get_VFXModeFile();

//////////////////////////////////////////////////////////////////////////////
string MK_VFX_Get2DAFile(int nVFXmode);

//////////////////////////////////////////////////////////////////////////////
int MK_VFX_GetVFX(int nVFXmode, int nRow, object oPC = OBJECT_SELF);

//////////////////////////////////////////////////////////////////////////////
int MK_VFX_GetVFXIsValid(int nVFXmode, int nRow, object oPC = OBJECT_SELF);

//////////////////////////////////////////////////////////////////////////////
//string MK_VFX_GetValueColumn(int nVFXmode, object oPC = OBJECT_SELF);

//////////////////////////////////////////////////////////////////////////////
string MK_VFX_GetTag(int nVFX);

//////////////////////////////////////////////////////////////////////////////
int MK_VFX_GetHasVFX(object oPC, int nVFX);

//////////////////////////////////////////////////////////////////////////////
int MK_VFX_RemoveVFX(object oPC, int nVFX);

//////////////////////////////////////////////////////////////////////////////
int MK_VFX_ApplyVFX(object oPC, int nVFX, int nVFXmode=-1, int nRow=-1);

//////////////////////////////////////////////////////////////////////////////
int MK_VFX_GetNumberOfVFXPerPage(object oPC);

//////////////////////////////////////////////////////////////////////////////
void MK_VFX_RemoveAllEffects(object oPC, int nEffectType=EFFECT_TYPE_VISUALEFFECT, int nEffectSubType=0);

//////////////////////////////////////////////////////////////////////////////


string MK_VFX_Get_VFXModeFile()
{
    return MK_VFX;
}

int MK_VFX_GetVFXMode(object oPC = OBJECT_SELF)
{
    return GetLocalInt(oPC, MK_VFX_MODE);
}

void MK_VFX_SetVFXMode(int nVFXMode, object oPC = OBJECT_SELF)
{
    SetLocalInt(oPC, MK_VFX_MODE, nVFXMode);
}

int MK_VFX_GetVFXIsValid(int nVFXmode, int nRow, object oPC)
{
    int bReturn = FALSE;
    int nVFX = MK_VFX_GetVFX(nVFXmode, nRow, oPC);
    if (nVFX!=-1)
    {
        bReturn = (Get2DAString(MK_VFX_BIOWARE_2DA, "Type_FD", nVFX)!="");
    }
    return bReturn;
}

int MK_VFX_GetNumberOfVFXPerPage(object oPC)
{
    return GetLocalInt(oPC, MK_VFX_PER_PAGE);
}

string MK_VFX_Get2DAFile(int nVFXmode)
{
    string s2DA = Get2DAString(MK_VFX_Get_VFXModeFile(), "2DAFILE", nVFXmode);
    if (s2DA=="")
    {
        s2DA = MK_VFX_BIOWARE_2DA;
    }
    return s2DA;
}

string MK_VFX_GetRaceGenderColumn(object oPC=OBJECT_SELF)
{
    int nRacialType = GetRacialType(oPC);
    string sAppearance =Get2DAString("racialtypes", "Appearance", nRacialType);
    if (sAppearance!="")
    {
        nRacialType = MK_Search2DAFile("racialtypes", "Appearance", sAppearance, 50);
    }
    return Get2DAString("racialtypes", "Label", nRacialType)+"_"+MK_GetGenderAsString(oPC);
}

int MK_VFX_GetVFX(int nVFXMode, int nRow, object oPC)
{
    int nVFX=-1;
    string s2DA = Get2DAString(MK_VFX_Get_VFXModeFile(), "2DAFILE", nVFXMode);
//   MK_DEBUG_TRACE("MK_VFX_GetVFX("+IntToString(nVFXMode)+","+IntToString(nRow)+"): s2DA="+s2DA);
    if (s2DA=="")
    {
        nVFX = nRow;
    }
    else
    {
        string sColumn = MK_VFX_GetRaceGenderColumn(oPC);
        nVFX = MK_Get2DAInt(s2DA, sColumn, nRow, -1);
//        MK_DEBUG_TRACE(" > sColumn="+sColumn+", nVFX="+IntToString(nVFX));
        if (nVFX == -1)
        {
            nVFX = MK_Get2DAInt(s2DA, "Default", nRow, -1);
//            MK_DEBUG_TRACE(" > nVFX="+IntToString(nVFX));
        }
    }
    return nVFX;
}

string MK_VFX_GetTag(int nVFX)
{
    return "MK_VFX_"+MK_IntToString(nVFX, 5, "0");
}

int MK_VFX_GetHasVFX(object oPC, int nVFX)
{
    if (MK_VERSION_GetIsVersionLower_1_74(oPC))
    {
        return FALSE;
    }

    string sTag = MK_VFX_GetTag(nVFX);

    effect eEff = GetFirstEffect(oPC);
    while (GetIsEffectValid(eEff))
    {
        if (GetEffectTag(eEff) == sTag)
        {
            return TRUE;
        }
        eEff = GetNextEffect(oPC);
    }
    return FALSE;
}

int MK_VFX_RemoveVFX(object oPC, int nVFX)
{
    if (MK_VERSION_GetIsVersionLower_1_74(oPC))
    {
        SendMessageToPC(oPC, "EE features are disabled. Can't remove specific effects!");
        return FALSE;
    }

    string sTag = MK_VFX_GetTag(nVFX);

    effect eEff = GetFirstEffect(oPC);
    while (GetIsEffectValid(eEff))
    {
        if (GetEffectTag(eEff) == sTag)
        {
            RemoveEffect(oPC, eEff);
            return TRUE;
        }
        eEff = GetNextEffect(oPC);
    }
//    SendMessageToPC(oPC, "Specified effect not found!");
    return FALSE;
}

int MK_VFX_ApplyVFX(object oPC, int nVFX, int nVFXmode, int nRow)
{
    effect eEffect = EffectVisualEffect(nVFX);
    int nDurationType = DURATION_TYPE_INSTANT;
    string s2DAFile = MK_VFX_Get2DAFile(nVFXmode);
    if (s2DAFile!="")
    {
        if (nRow==-1) nRow = nVFX;
        string sTypeFD = Get2DAString(s2DAFile, "Type_FD", nRow);
        if ((sTypeFD == "D") || (sTypeFD == "B"))
        {
            if (Get2DAString(s2DAFile, "Supernatural", nRow) == "1")
            {
                eEffect = SupernaturalEffect(eEffect);
            }
            nDurationType = DURATION_TYPE_PERMANENT;
        }
    }
    if (MK_VERSION_GetIsVersionGreaterEqual_1_74(oPC))
    {
        eEffect = TagEffect(eEffect, MK_VFX_GetTag(nVFX));
    }

    SendMessageToPC(oPC, "Applying specified vfx (name="+Get2DAString(s2DAFile, "Label", nRow)+","+IntToString(nVFX)+")!");

    ApplyEffectToObject(nDurationType, eEffect, oPC);

    return TRUE;
}

void MK_VFX_RemoveAllEffects(object oPC, int nEffectType, int nEffectSubType)
{
    effect eEffect = GetFirstEffect(oPC);
    while (GetIsEffectValid(eEffect))
    {
        if ( (                         GetEffectType   (eEffect) == nEffectType    ) &&
             ( (nEffectSubType==0) || (GetEffectSubType(eEffect) == nEffectSubType))    )
        {
            RemoveEffect(oPC, eEffect);
        }
        eEffect = GetNextEffect(oPC);
    }
}

/*
struct MK_VFX_DESCRIPTION
{
    string sDescription;
    string sPrefix1;
    string sPrefix2;
};

struct MK_VFX_DESCRIPTION MK_VFX_SetDescription(string sName)
{
    struct MK_VFX_DESCRIPTION desc;

    int nPos0 = FindSubString(sName, "_");
    int nPos1 = ( (nPos0 == -1) ? -1 : MK_VERSION_FindSubString(sName, "_", nPos0+1) );
    int nLen = GetStringLength(sName);

    if (nPos1!=-1)
    {
        desc.sPrefix1 = GetStringLeft(sName, nPos0);
        if (desc.sPrefix1 == "SCENE")
        {
            desc.sPrefix2 = "";
            desc.sDescription = GetStringRight(sName, nLen - nPos0 - 1);
        }
        else
        {
            desc.sPrefix2 = GetSubString(sName, nPos0+1, nPos1 - nPos0 -1);
            desc.sDescription = GetStringRight(sName, nLen - nPos1 - 1);
        }
    }
    else if (nPos0!=-1)
    {
        desc.sDescription = GetStringRight(sName, nLen - nPos0 - 1);
        desc.sPrefix1 = GetStringLeft(sName, nPos0);
        desc.sPrefix2 = "";
    }
    else
    {
        desc.sDescription = sName;
        desc.sPrefix1 = "";
        desc.sPrefix2 = "";
    }
    return desc;
}
*/

string MK_VFX_GetDescription(int nVFXmode, int nVFX, string sName)
{
    string sDescription;
    switch (nVFXmode)
    {
    case 0:
    {
        int nLen = GetStringLength(sName);
        int nNewLen = -1;
        if ((nLen>25) && (nVFX>=100))
        {
            nNewLen = 24;
        }
        else if ((nLen>26) && (nVFX>=10))
        {
            nNewLen = 25;
        }
        else if (nLen>27)
        {
            nNewLen = 26;
        }
        if (nNewLen!=-1)
        {
            sName = GetStringLeft(sName, nNewLen)+"..";
        }
        sDescription = sName + " ("+IntToString(nVFX)+")";
        break;
    }
    default:
        sDescription = sName + " ("+IntToString(nVFX)+")";
        break;
    }
/*
    case 1:
    case 2:
    case 3:
        sDescription = sName + " ("+IntToString(nVFX)+")";
        break;
    default:
    {
        struct MK_VFX_DESCRIPTION desc = MK_VFX_SetDescription(sName);
        sDescription = desc.sDescription + " ("+IntToString(nVFX);
        if ((desc.sPrefix1 != "VFX") && (desc.sPrefix1 != ""))
        {
            sDescription += (", " + desc.sPrefix1);
        }
        if (desc.sPrefix2 != "")
        {
            sDescription += (", " + desc.sPrefix2);
        }
        sDescription += ")";
        break;
    }
    }
*/
    return sDescription;
}



/*
void main()
{
}
/**/

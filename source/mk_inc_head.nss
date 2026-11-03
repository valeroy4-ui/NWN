/////////////////////////////////////////////////////////////////////////////
//
// mk_inc_head.nss
//
/////////////////////////////////////////////////////////////////////////////

#include "mk_inc_debug"
#include "mk_inc_tools"
#include "mk_inc_array"
#include "mk_inc_body"

// name of head filter definition 2da file
const string MK_DEF_HEAD = "mk_def_head";

const string MK_HEAD_MAX_HEAD_ID = "MK_HEAD_MAX_ID";

const string MK_HEAD_SELECTED_FILTER = "MK_HEAD_SELECTED_FILTER";

const string MK_HEAD_VALID_HEADS = "MK_HEAD_VALID_HEADS";

const int MK_HEAD_NEXT = 1;
const int MK_HEAD_PREV = 2;
const int MK_HEAD_MODEL = 3;

/////////////////////////////////////////////////////////////////////////////

// returns the max head ID. If no max head ID is set then 255 is returned
int MK_HEAD_GetMaxHeadID();

// returns Get2DAString("mk_def_head", "2DAFILE", nFilterID)
string MK_HEAD_GetFilter2DAFile(int nFilterID);

// returns RacialType_Gender
string MK_HEAD_GetBaseColumn(object oPC);

// returns the column name for the specified object (racialtype, gender) and
// the specified filter ID (row in "mk_def_head")
string MK_HEAD_GetColumn(object oPC, int nFilterID);

// returns TRUE if the specified filter provides no heads for oPC
int MK_HEAD_GetIsFilterEmpty(object oPC, int nFilterID);

// sets the head model to be used on the creature specified
// - oPC: the creature to change the head for
// - nMode: MK_HEAD_NEXT: next valid head model number
//          MK_HEAD_PREV: previous valid head model number
//          MK_HEAD_MODEL: set head model number to nModelNumber
// - nModelNumber: model number used for mode MK_HEAD_MODEL
int MK_HEAD_SetCreatureHead(object oPC, int nMode, int nModelNumber=-1);

int MK_HEAD_GetMaxHeadID()
{
    int nMaxID = GetLocalInt(OBJECT_SELF, MK_HEAD_MAX_HEAD_ID);
    if (nMaxID==0)
    {
        nMaxID = 255;
    }
    return nMaxID;
}

int MK_HEAD_GetIsCCOHFilter(int nFilterID)
{
    return MK_Get2DAInt(MK_DEF_HEAD, "CCOH", nFilterID);
}

string MK_HEAD_GetFilter2DAFile(int nFilterID)
{
    return Get2DAString(MK_DEF_HEAD, "2DAFILE", nFilterID);
}

string MK_HEAD_GetBaseColumn(object oPC)
{
    int nRacialType = GetRacialType(oPC);
    int nGender = GetGender(oPC);
    string sColumn = Get2DAString("racialtypes", "Label", nRacialType)
                        +"_"
                        +MK_GetGenderAsString(oPC);
    return sColumn;
}

string MK_HEAD_GetColumn(object oPC, int nFilterID)
{
    string sBaseColumn = MK_HEAD_GetBaseColumn(oPC);
    string sColumn = Get2DAString(MK_DEF_HEAD, sBaseColumn, nFilterID);
    if (sColumn=="")
    {
        sColumn = sBaseColumn;
    }
    return sColumn;
}

string MK_HEAD_GetFilterLabel(int nFilterID, object oPC = OBJECT_SELF)
{
    string sLabel="";
    int nStrRef = MK_Get2DAInt(MK_DEF_HEAD, "STRREF", nFilterID);
    if (nStrRef!=0)
    {
        sLabel = MK_TLK_GetStringByStrRef(nStrRef, GetGender(oPC));
    }
    else
    {
        sLabel = Get2DAString(MK_DEF_HEAD, "LABEL", nFilterID);
    }
    return sLabel;
}

int MK_HEAD_GetIsFilterEmpty(object oPC, int nFilterID)
{
    string s2DAFile = MK_HEAD_GetFilter2DAFile(nFilterID);
    string sColumn = MK_HEAD_GetColumn(oPC, nFilterID);

    if (MK_HEAD_GetIsCCOHFilter(nFilterID))
    {
        if (Get2DAString(s2DAFile, sColumn, 256)=="")
        {
            return TRUE;
        }
    }

//    MK_DEBUG_TRACE("MK_HEAD_GetIsFilterEmpty: s2DAFile='"+s2DAFile+"', sColumn='"+sColumn+"'");
    int iRow;
    for (iRow=1; iRow<=MK_HEAD_GetMaxHeadID(); iRow++)
    {
        if (Get2DAString(s2DAFile, sColumn, iRow)!="")
        {
//            MK_DEBUG_TRACE(" > iRow="+IntToString(iRow)+", sValue='"+Get2DAString(s2DAFile, sColumn, iRow)+"'");
            return FALSE;
        }
    }
    return TRUE;
}

string MK_HEAD_GetSelectedFilterString(object oPC)
{
    return GetLocalString(oPC, MK_HEAD_SELECTED_FILTER);
}

int MK_HEAD_GetFilterCount(object oPC)
{
    return MK_ARRAY_GetLocalArrayBoolLength(oPC, MK_HEAD_SELECTED_FILTER);
}

void MK_HEAD_SetSelectedFilterString(object oPC, string sSelectedFilter)
{
    SetLocalString(oPC, MK_HEAD_SELECTED_FILTER, sSelectedFilter);
}

void MK_HEAD_SelectFilter(object oPC, int nFilterID, int bSelect)
{
    MK_ARRAY_SetLocalArrayBool(oPC, MK_HEAD_SELECTED_FILTER, nFilterID, bSelect);
}

int MK_HEAD_GetIsFilterSelected(object oPC, int nFilterID)
{
    return MK_ARRAY_GetLocalArrayBool(oPC, MK_HEAD_SELECTED_FILTER, nFilterID);
}

string MK_HEAD_GetSelectedFilterAsText(object oPC)
{
    string sSelectedFilter = MK_HEAD_GetSelectedFilterString(oPC);
    string s="";
    int nLen = MK_HEAD_GetFilterCount(oPC);
    int iFilter;
//    MK_DEBUG_TRACE("MK_HEAD_GetSelectedFilterAsText: sSelectedFilter='"+sSelectedFilter+"', nLen="+IntToString(nLen));
    for (iFilter=0; iFilter<nLen; iFilter++)
    {
        if (MK_HEAD_GetIsFilterSelected(oPC, iFilter))
        {
            s += MK_HEAD_GetFilterLabel(iFilter, oPC);
            s += ", ";
        }
    }
    if (s=="")
    {
        s = "none";
    }
    else
    {
        s = GetStringLeft(s, GetStringLength(s)-2);
    }
//    MK_DEBUG_TRACE(" > sToken='"+s+"'");
    return s;
}

int MK_HEAD_ToggleFilter(object oPC, int nFilterID)
{
    int bSelect = !MK_HEAD_GetIsFilterSelected(oPC, nFilterID);
    MK_HEAD_SelectFilter(oPC, nFilterID, bSelect);
    return bSelect;
}

string MK_HEAD_GetHeadsString(object oPC, int nFilterID, string sHeadsString="")
{
    string s2DAFile =  MK_HEAD_GetFilter2DAFile(nFilterID);
    string sColumn = MK_HEAD_GetColumn(oPC, nFilterID);
    string s="";
    int nLength = GetStringLength(sHeadsString);
    int iRow;
    for (iRow=0; iRow<MK_HEAD_GetMaxHeadID(); iRow++)
    {
        string sValue = Get2DAString(s2DAFile, sColumn, iRow);
        if ((sValue!="") ||
            ((iRow<nLength) && (GetSubString(sHeadsString, iRow, 1)=="1") ) )
        {
            s+="1";
        }
        else
        {
            s+="0";
        }
    }
    return s;
}

void MK_HEAD_SetValidHeadsString(object oPC, string sValidHeads)
{
    MK_ARRAY_SetLocalArrayBuffer(oPC, MK_HEAD_VALID_HEADS, sValidHeads);
//    SetLocalString(oPC, MK_HEAD_VALID_HEADS, sValidHeads);
}

string MK_HEAD_GetValidHeadsString(object oPC)
{
    return MK_ARRAY_GetLocalArrayBuffer(oPC, MK_HEAD_VALID_HEADS);
//    return GetLocalString(oPC, MK_HEAD_VALID_HEADS);
}

string MK_HEAD_CreateValidHeadsString(object oPC)
{
    string sSelectedFilter = MK_HEAD_GetSelectedFilterString(oPC);
    int nFilterCount = GetStringLength(sSelectedFilter);
//    MK_DEBUG_TRACE("MK_HEAD_CreateValidHeadsString: sSelectedFilter='"+sSelectedFilter+"', nCount="+IntToString(nFilterCount));
    int iFilter;
    string sHeadsString="";
    int nCount=0;
    for (iFilter=0; iFilter<nFilterCount; iFilter++)
    {
        if (MK_HEAD_GetIsFilterSelected(oPC, iFilter))
        {
            sHeadsString = MK_HEAD_GetHeadsString(oPC, iFilter, sHeadsString);
//            MK_DEBUG_TRACE(" > sHeadsString='"+sHeadsString+"'");
            nCount++;
        }
    }
    int iHeads;
    string sValidHeads = "";
    if (nCount>0)
    {
        int nHeadCount = GetStringLength(sHeadsString);
        for (iHeads=0; iHeads<nHeadCount; iHeads++)
        {
            if (GetSubString(sHeadsString, iHeads, 1)=="1")
            {
                sValidHeads+=MK_ARRAY_LocalArraySortedInt_IntToString(iHeads);
            }
        }
    }
    else
    {
        int nHeadCount = MK_HEAD_GetMaxHeadID()+1;
        for (iHeads=1; iHeads<nHeadCount; iHeads++)
        {
            sValidHeads+=MK_ARRAY_LocalArraySortedInt_IntToString(iHeads);
        }
    }
    MK_HEAD_SetValidHeadsString(oPC, sValidHeads);
    return sValidHeads;
}

int MK_HEAD_SearchModelNumber(object oPC, int nModelNumber)
{
    return MK_ARRAY_SearchLocalArraySortedInt(oPC, MK_HEAD_VALID_HEADS, nModelNumber);
}

int MK_HEAD_SetCreatureHead(object oPC, int nMode, int nModelNumber)
{
    int nReturn = -1;
//    MK_DEBUG_TRACE("MK_HEAD_SetCreatureHead:");
    switch (nMode)
    {
    case MK_HEAD_MODEL:
        SetCreatureBodyPart(CREATURE_PART_HEAD, nModelNumber, oPC);
        nReturn = nModelNumber;
        break;
    case MK_HEAD_NEXT:
    case MK_HEAD_PREV:
    {
        int nCurrent = GetCreatureBodyPart(CREATURE_PART_HEAD, oPC);
        int nPosCurrent = MK_HEAD_SearchModelNumber(oPC, nCurrent);
        int nPosNew, nNew;
        int nHeadCount = MK_ARRAY_GetLocalArraySortedIntLength(oPC, MK_HEAD_VALID_HEADS);

        if (nPosCurrent==-1)
        {
            nPosNew = 0;
        }
        else
        {
            switch (nMode)
            {
            case MK_HEAD_PREV:
                nPosNew = (nPosCurrent + nHeadCount - 1) % nHeadCount;
                break;
            case MK_HEAD_NEXT:
                nPosNew = (nPosCurrent + 1) % nHeadCount;
                break;
            }
        }

        if (nPosNew>=0)
        {
            nNew = MK_ARRAY_GetLocalArraySortedInt(oPC, MK_HEAD_VALID_HEADS, nPosNew);
        }

        if (nNew!=-1)
        {
            SetCreatureBodyPart(CREATURE_PART_HEAD, nNew, oPC);
            nReturn = nNew;
        }
//        MK_DEBUG_TRACE(" > nCurrent="+IntToString(nCurrent)+
//            ", ValidHeads='"+sValidHeads+"', nPos="+IntToString(nPos)+
//            ", nNew="+IntToString(nNew));

        break;
    }
    }
    return nReturn;
}


/*
void main()
{
}
/**/


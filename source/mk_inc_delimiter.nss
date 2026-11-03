//#include "x3_inc_string"
#include "mk_inc_generic"

const int MK_DELIMITER_TOKEN = 14401;
const int MK_DELIMITER_CONDITION = 256;
const string MK_USE_DELIMITER = "MK_USE_DELIMITER";
const string MK_DELIMITER_COLOR = "MK_DELIMITER_COLOR";

int MK_DELIMITER_GetUseDelimiter()
{
    return GetLocalInt(OBJECT_SELF, MK_USE_DELIMITER);
}

void MK_DELIMITER_Initialize(int bEnable=TRUE, int nCondition=MK_DELIMITER_CONDITION)
{
    bEnable = bEnable && MK_DELIMITER_GetUseDelimiter();
    string sToken="";
    if (bEnable)
    {
//        string sRGB = GetLocalString(OBJECT_SELF, MK_DELIMITER_COLOR);
        string sColorTag = GetLocalString(OBJECT_SELF, MK_DELIMITER_COLOR);
        string sColorEnd = "</c>";
        sToken = sColorTag + "--------------------------------------------------" + sColorEnd;
//        sToken = StringToRGBString("--------------------------------------------------",sRGB);
    }

    MK_GenericDialog_SetCondition(nCondition, bEnable);
    SetCustomToken(MK_DELIMITER_TOKEN, sToken);
}

/*
void main()
{

}
/**/

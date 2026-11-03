//////////////////////////////////////////////////////////////////////////////
// mk_inc_tlk.nss
//////////////////////////////////////////////////////////////////////////////

#include "mk_inc_language"

const string MK_TLK_2DA_FILE = "mk_tlk";


string MK_TLK_GetStringByStrRef(int nStrRef, int nGender=GENDER_MALE);

string MK_TLK_Get2DAString(string sColumn, int nRow)
{
    return Get2DAString(MK_TLK_2DA_FILE, sColumn, nRow);
}

string MK_TLK_GetTLKColumn(int nGender)
{
    string sColumn = MK_LANG_GetLanguageID();

    if (MK_LANG_GetLanguageHasDialogF()==1)
    {
        sColumn += ("_"+IntToString(nGender));
    }
    return sColumn;
}

string MK_TLK_GetStringByStrRef(int nStrRef, int nGender)
{
    if (nStrRef>=0) return GetStringByStrRef(nStrRef, nGender);

    string sColumn, sString;
    int iGender;
    for (iGender=nGender; iGender>=GENDER_MALE; iGender--)
    {
        sColumn = MK_TLK_GetTLKColumn(iGender);
        sString = MK_TLK_Get2DAString(sColumn, -nStrRef);
        if (sString=="-1") return "";
        if (sString!="") return sString;
    }
    return MK_TLK_Get2DAString("en", -nStrRef);
}


/*
void main()
{

}
/**/

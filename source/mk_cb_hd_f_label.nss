// mk_cb_hd_f_label

#include "mk_inc_tools"
#include "mk_inc_2da_disp"
#include "mk_inc_tlk"
#include "mk_inc_head"

void main()
{
    object oPC = OBJECT_SELF;
    int nRow = GetLocalInt(oPC, MK_2DA_DISP_CALLBACK_ROW);
    int nStrRef = MK_Get2DAInt(MK_DEF_HEAD, "STRREF", nRow, 0);
    string sLabel = (nStrRef!=0 ? MK_TLK_GetStringByStrRef(nStrRef) : Get2DAString(MK_DEF_HEAD, "LABEL", nRow));

    sLabel = MK_TLK_GetStringByStrRef( MK_HEAD_GetIsFilterSelected(oPC, nRow) ? -39 : -40, GetGender(oPC) ) + sLabel;

    SetLocalString(oPC, MK_2DA_DISP_CALLBACK_LABEL, sLabel);
}

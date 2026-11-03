// Keep the installed AI code; give rift feats before its AI setup runs.
#include "crift_inc"
void main()
{
    int rift = GetLocalInt(GetArea(OBJECT_SELF), "CRIFT_AREA");
    int mark = GetLocalInt(OBJECT_SELF, "IAMCHAMPION");
    if (rift)
    {
        CRF_Enhance(OBJECT_SELF);
        DeleteLocalInt(OBJECT_SELF, "IAMCHAMPION");
    }
    ExecuteScript("crf_base_spwn", OBJECT_SELF);
    if (rift && mark) SetLocalInt(OBJECT_SELF, "IAMCHAMPION", mark);
}

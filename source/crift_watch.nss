#include "crift_inc"
void main()
{
    object area = OBJECT_SELF;
    if (!GetIsObjectValid(area) || !GetLocalInt(area, "CRIFT_AREA") ||
        GetLocalInt(area, "CRIFT_CLOSED")) return;
    object mob = GetFirstObjectInArea(area, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(mob))
    {
        // Stock/custom spawn scripts are covered even if they don't call nw_c2_default9.
        CRF_Enhance(mob);
        mob = GetNextObjectInArea(area, OBJECT_TYPE_CREATURE);
    }
    CRF_Grand(area);
    AssignCommand(GetModule(), DelayCommand(0.5, ExecuteScript("crift_watch", area)));
}

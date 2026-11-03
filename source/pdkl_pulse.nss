#include "pdkl_core"

void main()
{
    object oModule = GetModule();
    int nSubtick=GetLocalInt(oModule,"PDKL_SUBTICK")+1;
    if(nSubtick>=10) { SetLocalInt(oModule,"PDKL_TICK",PDKL_Now()+1);nSubtick=0; }
    SetLocalInt(oModule,"PDKL_SUBTICK",nSubtick);
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        PDKL_Refresh(oPC);
        oPC = GetNextPC();
    }
    DelayCommand(0.1, ExecuteScript("pdkl_pulse", oModule));
}

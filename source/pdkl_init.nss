#include "pdkl_core"

void main()
{
    object oModule = GetModule();
    if(GetLocalInt(oModule, "PDKL_RUNNING")) return;
    SetLocalInt(oModule, "PDKL_RUNNING", TRUE);
    SetLocalInt(oModule, "PDKL_TICK", 100);
    SetLocalInt(oModule, "PDKL_SUBTICK", 0);
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        PDKL_ClearOwner(oPC);
        oPC = GetNextPC();
    }
    DelayCommand(1.0, ExecuteScript("pdkl_pulse", oModule));
}

#include "_inc_generic"

void main()
{
    object oArea = OBJECT_SELF;
    if(DestroyArea(oArea) > 0)
    {
        WriteLog("Instance area: " + GetName(oArea) + " has been successfully destroyed.");
        return;
    }
    else
        DelayCommand(30.0, ExecuteScript("_on_inst_destroy", oArea));
}



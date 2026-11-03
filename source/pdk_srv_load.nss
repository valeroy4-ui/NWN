// Call from the existing module-load chain. Does not replace NWNX callbacks.
#include "pdkl_native"
void main()
{
    if(!PDKL_NativeReady())
    {
        WriteTimestampedLogEntry("PDK integration: NWNX_PDK not ready; pulse not started.");
        return;
    }
    ExecuteScript("pdkl_init", GetModule());
}

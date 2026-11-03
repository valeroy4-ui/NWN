#include "pdkl_core"
void main()
{
    PDKL_ClearOwner(OBJECT_SELF, TRUE);
    SendMessageToPC(OBJECT_SELF, "All your links released.");
}

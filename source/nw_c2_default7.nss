#include "dq_store"
void main()
{
    // Capture the actual killer before the original AI can resurrect/clean up.
    DQC_Death(OBJECT_SELF,GetLastKiller());
    ExecuteScript("dq_base_dead",OBJECT_SELF);
}

#include "crift_hook"
void main()
{
    // Count before a custom callback can immediately destroy the corpse.
    CRF_OnDeath(OBJECT_SELF);
    string original = GetLocalString(OBJECT_SELF, "CRIFT_ORIG_DEATH");
    if (original != "" && original != "crift_death") ExecuteScript(original, OBJECT_SELF);
}

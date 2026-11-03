// Installed original NCS/NSS are preserved verbatim as crf_base_dead.
#include "crift_hook"
void main()
{
    int handled = GetLocalInt(OBJECT_SELF, "CRIFT_DEATH_HANDLED");
    SetLocalInt(OBJECT_SELF, "CRIFT_DEATH_HANDLED", TRUE);
    ExecuteScript("crf_base_dead", OBJECT_SELF);
    if (handled || !GetIsDead(OBJECT_SELF)) return;
    CRF_OnDeath(OBJECT_SELF);
    if (!GetLocalInt(OBJECT_SELF, "BOSS_TYPE") &&
        !GetLocalInt(OBJECT_SELF, "ELITECHAMPIONSPAWNED") &&
        !GetLocalInt(OBJECT_SELF, "IMGUARD"))
        CRF_TryPortal(OBJECT_SELF, GetLastKiller());
}

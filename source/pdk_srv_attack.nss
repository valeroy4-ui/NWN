// Call ONCE inside NWNX DAMAGE attack callback, OBJECT_SELF = attacker.
// Existing callback must flush its struct first and re-read it after this call.
#include "pdk_battle"
void main()
{
    ExecuteScript("pdkl_attack",OBJECT_SELF);
    struct NWNX_Damage_AttackEventData d=NWNX_Damage_GetAttackEventData();
    PKV_SmiteImpact(OBJECT_SELF,d.oTarget,d.iAttackType,d.iAttackResult,d.bRangedAttack);
    // Native hook already applied physical Smite/Wrath before mitigation.
}

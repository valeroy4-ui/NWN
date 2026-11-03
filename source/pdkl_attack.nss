#include "pdkl_procs"
#include "pdk_lnk_dmg"

void main()
{
    struct NWNX_Damage_AttackEventData d = NWNX_Damage_GetAttackEventData();
    object oPDK = GetFirstPC();
    int i;
    while(GetIsObjectValid(oPDK))
    {
        for(i = 1; i <= PDKL_MAX; i++)
        {
            if(GetLocalObject(oPDK, PDKL_Key("TARGET", i)) == OBJECT_SELF
                && PDKL_BenefitActive(oPDK, i))
                d = PDKL_ApplyDamage(d, GetLocalInt(oPDK, PDKL_Key("KIND", i)),
                    PDKL_Level(oPDK), GetAbilityModifier(ABILITY_STRENGTH, oPDK),
                    GetAbilityModifier(ABILITY_DEXTERITY, oPDK));
        }
        PDKL_QueueProcsForOwner(oPDK,OBJECT_SELF,d);
        oPDK = GetNextPC();
    }
    NWNX_Damage_SetAttackEventData(d);
}

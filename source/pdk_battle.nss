#include "pdk_auras"
#include "nwnx_damage"
// Smite damage kind is generated from the user's confirmed choice.
#include "pkb_config"
void PKB_Grant(object p)
{
    PKS_Grant(p);int level=PDKL_Level(p);
    if(level>=1)
    {
        if(!GetHasFeat(1080,p,TRUE)) NWNX_Creature_AddFeat(p,1080);
        if(!GetHasFeat(1422,p,TRUE)) NWNX_Creature_AddFeat(p,1422);
        if(!GetHasFeat(1423,p,TRUE)) NWNX_Creature_AddFeat(p,1423);
    }
    if(level>=5 && !GetHasFeat(1083,p,TRUE)) NWNX_Creature_AddFeat(p,1083);
    if(level>=6 && !GetHasFeat(1081,p,TRUE)) NWNX_Creature_AddFeat(p,1081);
}
int PKB_Charges(object p,int kind)
{
    string ref="PKB_SMREF"+IntToString(kind),used="PKB_SMUSED"+IntToString(kind);
    int deadline=GetLocalInt(p,ref);
    if(deadline>0 && PKS_Now()>=deadline)
    { DeleteLocalInt(p,ref);DeleteLocalInt(p,used); }
    int remaining=3-GetLocalInt(p,used);if(remaining<0) return 0;return remaining;
}
int PKB_Smite(object p,object target,int kind)
{
    if(kind<1 || kind>2 || !PDKL_Alive(p) || PDKL_Level(p)<1) return 0;
    if(!PKS_Enemy(p,target)) { PKS_Feedback(p,"Smite: choose a living enemy.");return 0; }
    if(GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,p)))
    { PKS_Feedback(p,"Smite requires a melee weapon or unarmed attack. No charge spent.");return 0; }
    PKB_Restore(p);
    if(PKB_Charges(p,kind)<=0) { PKS_Feedback(p,"Smite: no charges; wait for the full refill.");return 0; }
    int feat=kind==1?1422:1423;
    NWNXPushInt(feat);NWNXPushObject(target);NWNXPushObject(p);NWNXCall("NWNX_PDK","QueueSmite");
    if(!NWNXPopInt()) return 0;
    string ref="PKB_SMREF"+IntToString(kind),used="PKB_SMUSED"+IntToString(kind);
    if(GetLocalInt(p,ref)<=0) SetLocalInt(p,ref,PKS_Now()+120);
    SetLocalInt(p,used,GetLocalInt(p,used)+1);PKB_Save(p);PKV_SmiteCast(p,kind);
    PKS_Feedback(p,(kind==1?"Smite Good":"Smite Evil")+": attack queued; "+IntToString(PKB_Charges(p,kind))+"/3 charges left.");
    return 1;
}
// Physical Smite is added in native GetDamageRoll, after critical multiplication
// and before damage immunity/resistance/reduction. Late attack-event additions
// would bypass those defenses.
int PKB_ProbeSmite(object p,object target,int feat,int result,int ranged=FALSE)
{
 NWNXPushInt(ranged);NWNXPushInt(result);NWNXPushInt(feat);NWNXPushObject(target);NWNXPushObject(p);
 NWNXCall("NWNX_PDK","ProbeSmiteRoll");return NWNXPopInt();
}

// Selected non-destructive original login operations. Existing CT login remains authoritative.
#include "_inc_death"
#include "_inc_itemprop"
#include "nwnx_rename"
void CS_RestoreLogin(object pc)
{
    if(GetLocalInt(GetModule(), CORMYREAN_WIPE_PHASE)>=CORMYREAN_WIPE_PHASE_4 || players_IsTestCharacter(pc))
        NWNX_Creature_SetMulticlassLimit(pc,0,TRUE);
    else NWNX_Creature_SetMulticlassLimit(pc,3,TRUE);
    if(!GetLocalInt(pc,"PLAYER_LOGGED_AFTER_RESTART"))
    {
        NWNX_Object_SetCurrentHitPoints(pc,GetMaxHitPoints(pc));
        ip_ClearAllTempItemPropAtPC(pc);
        NWNX_Creature_RestoreFeats(pc);
        NWNX_Creature_RestoreSpecialAbilities(pc);
        int i; for(i=0;i<=9;i++) ReadySpellLevel(pc,i);
        NWNX_Creature_RestoreItems(pc);
    }
    else
    {
        int hp=GetLocalInt(pc,"CURRENT_PC_HITPOINTS");
        if(hp>GetMaxHitPoints(pc)) hp=GetMaxHitPoints(pc);
        // Do not turn a missing legacy HP local into a new death.
        if(hp>0) NWNX_Object_SetCurrentHitPoints(pc,hp);
    }
    int faction=players_GetFaction(pc);
    int limited=players_GetIsLimitedBuild(pc), support=players_GetIsSupport(pc);
    string prefix="LIMITED_BUILD_FACTION_"+IntToString(faction)+"_SLOT_ID_";
    if(limited) SetLocalInt(GetModule(),prefix+IntToString(limited),GetLocalInt(GetModule(),prefix+IntToString(limited))+1);
    if(support) SetLocalInt(GetModule(),prefix+IntToString(support),GetLocalInt(GetModule(),prefix+IntToString(support))+1);
    DelayCommand(1.0,CheckAndDestroyNonActualCorpses(pc));
    if(!players_IsTestCharacter(pc))
        NWNX_Rename_SetPCNameOverride(pc,players_GetFactionColor(faction)+GetName(pc)+TXT_COLOR_END,"","",NWNX_RENAME_PLAYERNAME_DEFAULT);
}

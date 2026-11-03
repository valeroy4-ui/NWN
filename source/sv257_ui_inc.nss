// Private automatic targeting replacement for prepared Storm of Vengeance.
#include "nwnx_player"
const int SVUI_BASE=173;
const int SVUI_RANGE=2043;
int SVUI_Property(object o)
{
    if(GetLocalInt(o,"STORM_MEDIUM_VARIANT")>0) return TRUE;
    int i;
    for(i=0;i<18;i++)
    {
        object item=GetItemInSlot(i,o);
        if(GetIsObjectValid(item) && GetLocalInt(item,"STORM_MEDIUM_VARIANT")>0) return TRUE;
    }
    return FALSE;
}
void SVUI_Sync(object o,int forceBase=FALSE)
{
    if(!GetIsPC(o) || GetIsDM(o)) return;
    int active=!forceBase && !GetLocalInt(GetModule(),"SV257_UI_STOPPED") && SVUI_Property(o);
    int cls,level,i,changed=0;
    for(cls=CLASS_TYPE_CLERIC;cls<=CLASS_TYPE_DRUID;cls++)
    {
        if(GetLevelByClass(cls,o)<1) continue;
        for(level=0;level<=9;level++)
        {
            int count=GetMemorizedSpellCountByLevel(o,cls,level);
            for(i=0;i<count;i++)
            {
                if(GetMemorizedSpellId(o,cls,level,i)!=SVUI_RANGE) continue;
                int ready=GetMemorizedSpellReady(o,cls,level,i);
                int meta=GetMemorizedSpellMetaMagic(o,cls,level,i);
                int domain=GetMemorizedSpellIsDomainSpell(o,cls,level,i);
                if(ready<0 || meta<0 || domain<0) continue;
                SetMemorizedSpell(o,cls,level,i,SVUI_BASE,ready,meta,domain);
                if(GetMemorizedSpellId(o,cls,level,i)!=SVUI_BASE)
                {
                    if(!GetLocalInt(o,"SV257_UI_ERROR"))
                        PrintString("[SV UI ERROR] Legacy slot repair failed for "+GetName(o));
                    SetLocalInt(o,"SV257_UI_ERROR",TRUE);
                    return;
                }
                changed++;
            }
        }
    }
    for(i=0;i<36;i++)
    {
        struct NWNX_Player_QuickBarSlot slot=NWNX_Player_GetQuickBarSlot(o,i);
        if(slot.nObjectType==2 && slot.nINTParam1==SVUI_RANGE)
        {
            slot.nINTParam1=SVUI_BASE;
            NWNX_Player_SetQuickBarSlot(o,i,slot);
            changed++;
        }
    }
    if(GetLocalInt(o,"SV257_UI_MODE")!=active+1)
    {
        SetSpellTargetingData(o,SVUI_RANGE,SPELL_TARGETING_SHAPE_SPHERE,5.0,0.0,SPELL_TARGETING_FLAGS_HARMS_ENEMIES);
        SetSpellTargetingData(o,SVUI_BASE,SPELL_TARGETING_SHAPE_SPHERE,10.0,0.0,SPELL_TARGETING_FLAGS_HARMS_ENEMIES|SPELL_TARGETING_FLAGS_ORIGIN_ON_SELF);
        SetLocalInt(o,"SV257_UI_MODE",active+1);
        PrintString("[SV UI] "+GetName(o)+" medium="+IntToString(active)+" radius="+(active?"5":"10")+"; native slots/button retained; targeting checked on cast.");
    }
}
void SVUI_RestoreTestBelt(object o)
{
    object belt=GetLocalObject(o,"SV257_TEST_BELT");
    object old=GetLocalObject(o,"SV257_OLD_BELT");
    if(GetIsObjectValid(belt) && GetItemPossessor(belt)==o && GetLocalInt(belt,"SV257_TEST_ITEM"))
    {
        int worn=GetItemInSlot(INVENTORY_SLOT_BELT,o)==belt;
        if(worn) AssignCommand(o,ActionUnequipItem(belt));
        DestroyObject(belt,0.1);
        if(worn && GetIsObjectValid(old) && GetItemPossessor(old)==o)
            AssignCommand(o,ActionEquipItem(old,INVENTORY_SLOT_BELT));
    }
    DeleteLocalObject(o,"SV257_TEST_BELT");DeleteLocalObject(o,"SV257_OLD_BELT");
    DeleteLocalInt(o,"SV257_BELT_TEST");
    DelayCommand(0.5,SVUI_Sync(o));
}
void SVUI_BeltTimeout(object o,int token)
{
    if(GetIsObjectValid(o) && GetLocalInt(o,"SV257_BELT_TOKEN")==token) SVUI_RestoreTestBelt(o);
}
void SVUI_RestoreRange(object o)
{
    if(GetLocalInt(o,"SV257_RANGE_TEST"))
    {
        SetLocalInt(o,"STORM_MEDIUM_VARIANT",GetLocalInt(o,"SV257_RANGE_OLD"));
        DeleteLocalInt(o,"SV257_RANGE_TEST");
    }
    if(GetLocalInt(o,"SV257_BELT_TEST")) SVUI_RestoreTestBelt(o);
    SVUI_Sync(o);
}
void SVUI_RangeTimeout(object o,int token)
{
    if(GetIsObjectValid(o) && GetLocalInt(o,"SV257_RANGE_TOKEN")==token) SVUI_RestoreRange(o);
}

void SVUI_ClearSelection(object o,int cancelCursor=FALSE)
{
    if(!GetLocalInt(o,"SV257_SELECTING")) return;
    DeleteLocalInt(o,"SV257_SELECTING");
    if(cancelCursor && !GetLocalInt(o,"TARGET_MODE")) EnterTargetingMode(o,0);
}
void SVUI_SelectionTimeout(object o,int token)
{
    if(GetIsObjectValid(o) && GetLocalInt(o,"SV257_SELECT_TOKEN")==token)
        SVUI_ClearSelection(o);
}

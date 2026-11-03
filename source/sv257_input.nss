#include "sv257_ui_inc"
#include "nwnx_events"
void main()
{
    object o=OBJECT_SELF;
    if(!GetIsPC(o) || GetIsDM(o) || GetIsDead(o) || GetLocalInt(GetModule(),"SV257_UI_STOPPED")) return;
    int spell=StringToInt(NWNX_Events_GetEventData("SPELL_ID"));
    if(spell!=173) {SVUI_ClearSelection(o);return;}
    SVUI_Sync(o);
    if(!SVUI_Property(o)) {SVUI_ClearSelection(o,TRUE);return;}
    if(NWNX_Events_GetEventData("FAKE")=="1") return;
    string feat=NWNX_Events_GetEventData("FEAT");
    if(feat!="" && StringToInt(feat)!=-1) return;
    int position=StringToInt(NWNX_Events_GetEventData("MULTICLASS"));
    int cls=GetClassByPosition(position+1,o);
    if(cls!=CLASS_TYPE_CLERIC && cls!=CLASS_TYPE_DRUID) return;
    NWNX_Events_SkipEvent();
    if(GetLocalInt(o,"TARGET_MODE"))
    {SendMessageToPC(o,"Finish or cancel your current target selection first.");return;}
    if(GetLocalInt(o,"SV257_SELECTING")) return;
    int meta=StringToInt(NWNX_Events_GetEventData("META_TYPE"));
    int domain=StringToInt(NWNX_Events_GetEventData("DOMAIN_LEVEL"));
    if(meta<0) meta=METAMAGIC_NONE;
    if(domain<0) domain=0;
    int token=GetLocalInt(o,"SV257_SELECT_TOKEN")+1;
    SetLocalInt(o,"SV257_SELECT_TOKEN",token);
    SetLocalInt(o,"SV257_SELECT_CLASS",cls);
    SetLocalInt(o,"SV257_SELECT_META",meta);
    SetLocalInt(o,"SV257_SELECT_DOMAIN",domain);
    SetLocalObject(o,"SV257_SELECT_AREA",GetArea(o));
    SetLocalInt(o,"SV257_SELECTING",TRUE);
    SetEnterTargetingModeData(o,SPELL_TARGETING_SHAPE_SPHERE,5.0,0.0,SPELL_TARGETING_FLAGS_HARMS_ENEMIES,20.0,2043);
    DelayCommand(0.0,EnterTargetingMode(o,OBJECT_TYPE_TILE));
    DelayCommand(600.0,SVUI_SelectionTimeout(o,token));
}

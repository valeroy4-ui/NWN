#include "sv257_ui_inc"
void main()
{
    object o=OBJECT_SELF;
    if(!GetIsPC(o) || !GetLocalInt(o,"SV257_SELECTING")) return;
    object selected=GetLocalObject(o,"SV257_PICKED_OBJECT");
    if(!GetIsObjectValid(selected)) {SVUI_ClearSelection(o);return;}
    if(GetLocalInt(GetModule(),"SV257_UI_STOPPED") || !SVUI_Property(o))
    {SVUI_ClearSelection(o);return;}
    location target=GetLocalLocation(o,"SV257_PICKED_LOCATION");
    if(GetArea(o)!=GetLocalObject(o,"SV257_SELECT_AREA") || selected!=GetArea(o)
        || GetDistanceBetweenLocations(GetLocation(o),target)>20.0
        || !LineOfSightVector(GetPosition(o),GetPositionFromLocation(target)))
    {
        SendMessageToPC(o,"Select a visible ground point within 20m in the same area.");
        SetEnterTargetingModeData(o,SPELL_TARGETING_SHAPE_SPHERE,5.0,0.0,SPELL_TARGETING_FLAGS_HARMS_ENEMIES,20.0,2043);
        DelayCommand(0.0,EnterTargetingMode(o,OBJECT_TYPE_TILE));return;
    }
    int cls=GetLocalInt(o,"SV257_SELECT_CLASS");
    if(cls!=CLASS_TYPE_CLERIC && cls!=CLASS_TYPE_DRUID) {SVUI_ClearSelection(o);return;}
    int meta=GetLocalInt(o,"SV257_SELECT_META");
    int domain=GetLocalInt(o,"SV257_SELECT_DOMAIN");
    SVUI_ClearSelection(o);
    // Native Master173 consumes a normal prepared slot. Never a cheat/free cast.
    AssignCommand(o,ActionCastSpellAtLocation(2043,target,meta,FALSE,PROJECTILE_PATH_TYPE_DEFAULT,FALSE,cls,FALSE,domain));
}

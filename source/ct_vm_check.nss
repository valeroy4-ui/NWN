#include "nwnx_object"
void main()
{
    PrintString("[VM286 CHECK] READ ONLY; spell529 school="+Get2DAString("spells","School",529)+" range="+Get2DAString("spells","Range",529)+" radius="+Get2DAString("vfx_persistent","radius",201));
    object pc=GetFirstPC();
    while(GetIsObjectValid(pc))
    {
        if(!GetIsDM(pc))
        {
            PrintString("[VM286 CHECK] name="+GetName(pc)+" Druid="+IntToString(GetLevelByClass(CLASS_TYPE_DRUID,pc))+" HP="+IntToString(GetCurrentHitPoints(pc))+"/"+IntToString(GetMaxHitPoints(pc)));
            object field=GetFirstObjectInArea(GetArea(pc));
            while(GetIsObjectValid(field))
            {
                if(GetObjectType(field)==OBJECT_TYPE_AREA_OF_EFFECT && GetAreaOfEffectCreator(field)==pc && GetLocalInt(field,"VM286_READY"))
                    PrintString("[VM286 CHECK] owner="+GetName(pc)+" CL="+IntToString(GetLocalInt(field,"AOE_LEVEL"))+" focus="+IntToString(GetLocalInt(field,"VM286_FOCUS"))+" heal="+IntToString(GetLocalInt(field,"VM286_HEAL"))+" duration="+FloatToString(GetLocalFloat(field,"VM286_DURATION"),0,2)+" remaining="+FloatToString(NWNX_Object_GetAoEObjectDurationRemaining(field),0,2)+" radius="+FloatToString(NWNX_Object_GetAoEObjectRadius(field),0,2));
                field=GetNextObjectInArea(GetArea(pc));
            }
        }
        pc=GetNextPC();
    }
}

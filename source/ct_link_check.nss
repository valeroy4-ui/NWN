// Read-only Link diagnostics for the server console and startup log.
#include "nwnx_object"

string CT_LinkNativeState(object target)
{
    NWNXPushObject(target);NWNXCall("NWNX_PDK","BeamSyncReport");return NWNXPopString();
}
int CT_LinkBeamEffects(object target)
{
    int count=0;effect e=GetFirstEffect(target);
    while(GetIsEffectValid(e))
    {
        if(GetStringLeft(GetEffectTag(e),10)=="PDKL_BEAM_") count++;
        e=GetNextEffect(target);
    }
    return count;
}
void main()
{
    NWNXCall("NWNX_PDK","BeamSyncVersion");
    PrintString("[LINK CHECK] nativeSync="+IntToString(NWNXPopInt()));
    object p=GetFirstPC();int count=0;
    while(GetIsObjectValid(p))
    {
        PrintString("[LINK CHECK] target="+GetName(p,TRUE)+" object="+ObjectToString(p)
            +" beamEffects="+IntToString(CT_LinkBeamEffects(p))+" "+CT_LinkNativeState(p));
        int slot;
        for(slot=1;slot<=3;slot++)
        {
            string s=IntToString(slot);int kind=GetLocalInt(p,"PDKL_KIND_"+s);
            object target=GetLocalObject(p,"PDKL_TARGET_"+s);
            if(kind>0 || GetIsObjectValid(target))
                PrintString("[LINK CHECK] owner="+GetName(p,TRUE)+" slot="+s+" kind="+IntToString(kind)
                    +" target="+GetName(target,TRUE)+" distance="+FloatToString(GetDistanceBetween(p,target),5,2)
                    +" "+CT_LinkNativeState(target));
        }
        count++;p=GetNextPC();
    }
    PrintString("[LINK CHECK] online="+IntToString(count)+" READ ONLY");
}

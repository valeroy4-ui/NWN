int PDKL_NativeReady()
{ NWNXCall("NWNX_PDK","Ready");return NWNXPopInt(); }

void PDKL_NativeLink(object owner,object target,int slot)
{
    NWNXPushInt(slot);NWNXPushObject(target);NWNXPushObject(owner);
    NWNXCall("NWNX_PDK","SetLink");
}

int PDKL_ShieldBase(object target)
{ NWNXPushObject(target);NWNXCall("NWNX_PDK","ShieldBase");return NWNXPopInt(); }

object PDKL_CreateHum(object area,vector position)
{ NWNXPushVector(position);NWNXPushObject(area);NWNXCall("NWNX_PDK","CreateHum");return NWNXPopObject(); }

int PDKL_SoundState(object sound,int field)
{ NWNXPushInt(field);NWNXPushObject(sound);NWNXCall("NWNX_PDK","SoundState");return NWNXPopInt(); }

void PDKL_NativeTrace(object target,int enabled)
{ NWNXPushInt(enabled);NWNXPushObject(target);NWNXCall("NWNX_PDK","Trace"); }

int PDKL_NativeProbe(object attacker,object target,int index,int layout=0,int special=0)
{
    NWNXPushInt(special);NWNXPushInt(layout);NWNXPushInt(index);
    NWNXPushObject(target);NWNXPushObject(attacker);NWNXCall("NWNX_PDK","Probe");return NWNXPopInt();
}

void PDKL_SyncHum(object sound)
{ NWNXPushObject(sound);NWNXCall("NWNX_PDK","SyncHum"); }
void PDKL_ForgetHum(object sound)
{ NWNXPushObject(sound);NWNXCall("NWNX_PDK","ForgetHum"); }
string PDKL_SheetRow(object target)
{ NWNXPushObject(target);NWNXCall("NWNX_PDK","SheetRow");return NWNXPopString(); }
int PDKL_SheetField(object target,int field)
{ NWNXPushInt(field);NWNXPushObject(target);NWNXCall("NWNX_PDK","SheetField");return NWNXPopInt(); }

void PDKL_ResetClient(object player)
{
    DeleteLocalInt(player,"PDKL_BREAK_BUSY");
    DeleteLocalInt(player,"PDKL_RELINK_BUSY");
    NWNXPushObject(player);NWNXCall("NWNX_PDK","ResetClient");
}

int PDKL_BreakCue(object listener)
{ NWNXPushObject(listener);NWNXCall("NWNX_PDK","BreakCue");return NWNXPopInt(); }

int PDKL_RelinkCue(object listener)
{ NWNXPushObject(listener);NWNXCall("NWNX_PDK","RelinkCue");return NWNXPopInt(); }

// Separate one-shot connect/replacement and break cues; never create a looping source.
void PDKL_BreakGateReset(object listener)
{ if(GetIsObjectValid(listener)) DeleteLocalInt(listener,"PDKL_BREAK_BUSY"); }
int PDKL_BreakGate(object listener)
{
    if(!GetIsObjectValid(listener) || GetLocalInt(listener,"PDKL_BREAK_BUSY")) return FALSE;
    SetLocalInt(listener,"PDKL_BREAK_BUSY",TRUE);
    AssignCommand(GetModule(),DelayCommand(0.75,PDKL_BreakGateReset(listener)));
    return TRUE;
}
void PDKL_NotifyBreak(object owner,object target)
{
    // Coalesce simultaneous loss of several links for each participant.
    if(PDKL_BreakGate(owner)) PDKL_BreakCue(owner);
    if(target!=owner && PDKL_BreakGate(target)) PDKL_BreakCue(target);
}
void PDKL_RemoveSound(object owner,int slot)
{
    // Also clean legacy loop state if a saved character still carries it.
    object sound=GetLocalObject(owner,PDKL_Key("SOUND",slot));
    DeleteLocalObject(owner,PDKL_Key("SOUND",slot));
    DeleteLocalInt(owner,PDKL_Key("SOUND_VOL",slot));
    if(GetIsObjectValid(sound) && PDKL_SoundState(sound,0)>=0)
    { SoundObjectStop(sound);PDKL_ForgetHum(sound);DestroyObject(sound); }
}
void PDKL_UpdateSounds(object owner)
{
    int slot;
    for(slot=1;slot<=PDKL_MAX;slot++) PDKL_RemoveSound(owner,slot);
}

void PDKL_RelinkGateReset(object listener)
{ if(GetIsObjectValid(listener)) DeleteLocalInt(listener,"PDKL_RELINK_BUSY"); }
int PDKL_RelinkGate(object listener)
{
    if(!GetIsObjectValid(listener) || GetLocalInt(listener,"PDKL_RELINK_BUSY")) return FALSE;
    SetLocalInt(listener,"PDKL_RELINK_BUSY",TRUE);
    AssignCommand(GetModule(),DelayCommand(1.5,PDKL_RelinkGateReset(listener)));
    return TRUE;
}
void PDKL_NotifyRelink(object owner,object oldTarget,object newTarget)
{
    // The source and new recipient hear a connection/replacement ping. A different old recipient
    // has actually lost the connection and hears the usual break notification.
    if(PDKL_RelinkGate(owner)) PDKL_RelinkCue(owner);
    if(newTarget!=owner && PDKL_RelinkGate(newTarget)) PDKL_RelinkCue(newTarget);
    if(oldTarget!=newTarget && oldTarget!=owner && PDKL_BreakGate(oldTarget))
        PDKL_BreakCue(oldTarget);
}

// guard_heartbeat

void main()
{
    if(!GetIsDead(OBJECT_SELF))
    {
        if(GetTimeHour() == 12 && GetTimeMinute() == 0 && !GetIsInCombat(OBJECT_SELF))
            ForceRest(OBJECT_SELF);
    }
    ExecuteScript("nw_c2_default1", OBJECT_SELF);
}


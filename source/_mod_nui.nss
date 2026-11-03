void main()
{
    object pc = NuiGetEventPlayer();
    string window = NuiGetWindowId(pc,NuiGetEventWindow());
    if (window == "dq_journal" || window == "dq_confirm") { ExecuteScript("dq_event",OBJECT_SELF); return; }
    ExecuteScript("dq_base_nui",OBJECT_SELF);
}

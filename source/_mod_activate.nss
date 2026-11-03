void main()
{
    object item = GetItemActivated();
    if (GetResRef(item) == "dq_journal" && GetTag(item) == "DQ_JOURNAL")
    {
        object pc = GetItemActivator();
        if (GetIsPC(pc)) ExecuteScript("dq_open", pc);
        return;
    }
    ExecuteScript("dq_base_act", OBJECT_SELF);
}

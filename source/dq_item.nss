void main()
{
    object pc = OBJECT_SELF;
    if (!GetIsPC(pc)) return;
    object item = GetItemPossessedBy(pc,"DQ_JOURNAL");
    if (GetIsObjectValid(item) && GetResRef(item) == "dq_journal")
    {
        SendMessageToPC(pc,"You already have the Daily Quest Journal. Place its unique power on your quickbar.");
        return;
    }
    item = CreateItemOnObject("dq_journal",pc);
    if (!GetIsObjectValid(item)) { SendMessageToPC(pc,"Journal could not be created."); return; }
    itemproperty ip = GetFirstItemProperty(item);
    while (GetIsItemPropertyValid(ip))
    {
        RemoveItemProperty(item,ip);
        ip = GetFirstItemProperty(item);
    }
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyCastSpell(IP_CONST_CASTSPELL_UNIQUE_POWER_SELF_ONLY,
        IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE),item);
    SetPlotFlag(item,TRUE);
    SetDroppableFlag(item,FALSE);
    SendMessageToPC(pc,"Daily Quest Journal added. Put its unique power on a quickbar slot, then bind that slot to your preferred key in Controls.");
}

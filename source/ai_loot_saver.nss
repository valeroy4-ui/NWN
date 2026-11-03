void main()
{
    if (!GetIsObjectValid(GetArea(OBJECT_SELF)))
    {
        DelayCommand(1.0, ExecuteScript("ai_loot_saver", OBJECT_SELF));
    }
    else
    {
        object oSaver = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_invisobj",
                                     GetLocation(OBJECT_SELF), FALSE);

        SetPlotFlag(oSaver, TRUE);
        SetLocalObject(OBJECT_SELF, "BOSS_LOOT_SAVER", oSaver);
    }
}

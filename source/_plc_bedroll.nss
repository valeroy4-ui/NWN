void main()
{
    object oUser = GetLastUsedBy();
    CreateItemOnObject("fl_bedroll", oUser);
    DestroyObject(OBJECT_SELF);
}

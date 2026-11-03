void main()
{
    object oTrash = GetFirstItemInInventory();
    while (GetIsObjectValid(oTrash))
    {
        DestroyObject(oTrash);
        oTrash = GetNextItemInInventory();
    }
}

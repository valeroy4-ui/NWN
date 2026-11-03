#include "_inc_generic"


void main()
{
    object oPC = GetLastClosedBy();
    object oPlaceable = OBJECT_SELF;
    int bNoItems = FALSE;

    if (!GetIsObjectValid(GetFirstItemInInventory(oPlaceable)))
    {
        bNoItems = TRUE;
        DestroyObject(oPlaceable);
    }

    if (GetLocalInt(oPlaceable, "PLACEABLE_PERSONAL_MAGIC_FORGE"))
    {
        AssignCommand(oPC, ClearAllActions());
        object oMagicForge = GetLocalObject(oPlaceable, "PLACEABLE_MAGIC_FORGE");
        if (!bNoItems)
            AssignCommand(oMagicForge, ActionStartConversation(oPC, "dlg_magic_forge", TRUE));
    }
}


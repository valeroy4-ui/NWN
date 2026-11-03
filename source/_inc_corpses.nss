#include "_inc_guard_spawn"

const string sPlaceMobLoot = "plc_mob_loot";

void CheckIsDeadAndDestroy();
void LeaveCorpse();
void DestroyLoot(object oLoot = OBJECT_SELF);
void DestroyCorpse();

void CheckIsDeadAndDestroy()
{
    if(GetIsDead(OBJECT_SELF))
    {
        SetIsDestroyable(TRUE, FALSE, FALSE);
        DestroyObject(OBJECT_SELF);
    }
}

void LeaveCorpse()
{
    object oCreature = OBJECT_SELF;
    location lLoc = GetLocation(oCreature);

    if(GetLocalInt(oCreature, "iBodyLoot"))
    {
        SetIsDestroyable(FALSE,TRUE,TRUE);
        return;
    }
    if(GetLocalInt(oCreature, "IMGUARD") && !guard_GetIsCaptain(oCreature))
    {
        SetIsDestroyable(FALSE, TRUE, FALSE);
        DestroyLoot(oCreature);
        DelayCommand(60.0, CheckIsDeadAndDestroy());
        return;
    }

    object oLoot = CreateObject(OBJECT_TYPE_PLACEABLE, sPlaceMobLoot, lLoc);

    if(GetTag(oCreature) == "cr_mahladtukuum")
        if (d100() > 75) CreateItemOnObject("nw_it_mboots005", oLoot);  // boots of haste

    object oItem = GetFirstItemInInventory(oCreature);
    while(GetIsObjectValid(oItem))
    {
        int nBaseType = GetBaseItemType(oItem);
        if(GetDroppableFlag(oItem) && (nBaseType < 69 || nBaseType > 73))
            CopyItem(oItem, oLoot, TRUE);
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oCreature);
    }

    int nGold = GetGold();
    TakeGoldFromCreature(nGold, OBJECT_SELF, TRUE);
    //Crypton Gold Generate -->
    if(GetLocalInt(oCreature, "GOLD") > 0)
       nGold = GetLocalInt(oCreature, "GOLD");

    // Crypton <--
    if(nGold) CreateItemOnObject("NW_IT_GOLD001", oLoot, nGold);

    oItem = GetFirstItemInInventory(oLoot);
    if(!GetIsObjectValid(oItem))
        DestroyObject(oLoot);
    else
        AssignCommand(oLoot, DelayCommand(IntToFloat(Random(200)+300), DestroyLoot()));

    SetIsDestroyable(FALSE, FALSE, FALSE);
    AssignCommand(oCreature, DelayCommand(5.0, DestroyCorpse()));
}

void DestroyLoot(object oLoot = OBJECT_SELF)
{
    object oItem = GetFirstItemInInventory(oLoot);
    while(GetIsObjectValid(oItem))
    {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oLoot);
    }
    DestroyObject(oLoot);
}

void DestroyCorpse()
{
    AssignCommand(OBJECT_SELF, SetIsDestroyable(TRUE, FALSE, FALSE));
    DestroyObject(OBJECT_SELF);
}

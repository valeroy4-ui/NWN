#include "_inc_players"
#include "nwnx_damage"
#include "_inc_champ_boss"
#include "_inc_itemprop"
#include "_inc_db_funcs"
#include "nwnx_item"
#include "_inc_loot"

void main()
{
    object oPC = GetSpellTargetObject();
    location lLoc = GetSpellTargetLocation();

//    if(GetObjectType(oPC) == OBJECT_TYPE_ITEM)
//        ServerShout(IntToString(GetBaseItemType(oPC)));

    object oTarget = oPC;
    {
        //Search through the valid effects on the target.
        effect eAOE = GetFirstEffect(oTarget);
        while(GetIsEffectValid(eAOE))
        {
            ServerShout("GetEffectSpellId: " + IntToString(GetEffectSpellId(eAOE)));
            //Get next effect on the target
            eAOE = GetNextEffect(oTarget);
        }
    }


    //NWNX_Util_SetInstructionLimit(8388608);

    //object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    //ip_StoreItemIntoDatabase(oItem);
    //    ServerShout("[TEST] Target name:" + GetName(oPC));
    //    ServerShout("[TEST] Item name:" + GetName(GetFirstItemInInventory(oPC)));

    /*
    object oItem = GetFirstItemInInventory(oPC);
    while(GetIsObjectValid(oItem))
    {
        //object oCreated = CreateItemOnObject(ip_GetBlankBaseItemResRef(GetBaseItemType(oItem)), oPC);
        ip_StoreItemIntoDatabase(oItem);
        ServerShout("TEST");
        oItem = GetNextItemInInventory(oPC);
    }
    */
    loot_GenerateBossTreasuresInArea(GetArea(oPC), "BLUE", 20);
    //loot_CreateStoredItem(312, oPC);

    //object oEliteChampion = CreateObject(OBJECT_TYPE_CREATURE, "cr_fiendish", lLoc, TRUE);
    // no elite champions + champions bonuses
    //DeleteLocalInt(oEliteChampion, "IAMCHAMPION");
    //champion_ApplyAllBonuses(oEliteChampion, TRUE);

    /*
    itemproperty ip_Itemproperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip_Itemproperty))
    {
        struct NWNX_IPUnpacked unpacked = NWNX_ItemProperty_UnpackIP(ip_Itemproperty);
        printip(unpacked);
        ip_Itemproperty = GetNextItemProperty(oItem);
    }

    itemproperty ip;
    struct NWNX_IPUnpacked IpUnpacked = NWNX_ItemProperty_UnpackIP(ip);
    IpUnpacked.nProperty = 15;
    IpUnpacked.nSubType = 118;
    IpUnpacked.nCostTable = 3;
    IpUnpacked.nCostTableValue = 10;
    IpUnpacked.nParam1 = 255;
    IpUnpacked.nParam1Value = 0;
    IpUnpacked.nUsesPerDay = 3;
    IpUnpacked.nChanceToAppear = 100;
    IpUnpacked.bUsable = 1;
    IpUnpacked.nSpellId = -1;
    IpUnpacked.sTag = "";
    ip = NWNX_ItemProperty_PackIP(IpUnpacked);
    AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
     */
/*
sID = '118400'
nProperty = 15
nSubType = 118
nCostTable = 3
nCostTableValue = 10
nParam1 = 255
nParam1Value = 0
nUsesPerDay = 3
nChanceToAppear = 100
bUsable = 1
nSpellId = -1
sTag = ''
*/
    //SetCreatureAppearanceType(oPC, 1000);
    //PostString(OBJECT_SELF, "TEST");
}

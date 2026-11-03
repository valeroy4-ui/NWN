#include "nwnx_admin"
#include "nwnx_item"

string tmp_GetItemTypeString(int iInventorySlot)
{
    switch(iInventorySlot)
    {
        case INVENTORY_SLOT_ARMS: return "arms";
        case INVENTORY_SLOT_ARROWS: return "arrs";
        case INVENTORY_SLOT_BELT: return "belt";
        case INVENTORY_SLOT_BOLTS: return "blts";
        case INVENTORY_SLOT_BOOTS: return "boot";
        case INVENTORY_SLOT_BULLETS: return "bull";
        case INVENTORY_SLOT_CARMOUR: return "carm";
        case INVENTORY_SLOT_CHEST: return "armr";
        case INVENTORY_SLOT_CLOAK: return "cape";
        case INVENTORY_SLOT_CWEAPON_B: return "cweb";
        case INVENTORY_SLOT_CWEAPON_L: return "cwel";
        case INVENTORY_SLOT_CWEAPON_R: return "cwer";
        case INVENTORY_SLOT_HEAD: return "head";
        case INVENTORY_SLOT_LEFTHAND: return "rng1";
        case INVENTORY_SLOT_LEFTRING: return "rng2";
        case INVENTORY_SLOT_NECK: return "neck";
        case INVENTORY_SLOT_RIGHTHAND: return "hnd1";
        case INVENTORY_SLOT_RIGHTRING: return "hnd2";
    }
    return "";
}

void main()
{
    object oPC = GetSpellTargetObject();
    string sCompetitionResref = "jrec11111";
    string sAppearanceData = "";

    object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
    object oTmpArmor = CreateItemOnObject(sCompetitionResref + "_" + tmp_GetItemTypeString(INVENTORY_SLOT_CHEST), oPC);
    NWNX_Item_RestoreItemAppearance(oArmor, NWNX_Item_GetEntireItemAppearance(oTmpArmor));
    DestroyObject(oTmpArmor);
    CopyItem(oArmor, oPC, TRUE);
    DestroyObject(oArmor);

    object oHead = GetItemInSlot(INVENTORY_SLOT_HEAD, oPC);
    object oTmpHead = CreateItemOnObject(sCompetitionResref + "_" + tmp_GetItemTypeString(INVENTORY_SLOT_HEAD), oPC);
    NWNX_Item_RestoreItemAppearance(oHead, NWNX_Item_GetEntireItemAppearance(oTmpHead));
    DestroyObject(oTmpHead);
    CopyItem(oHead, oPC, TRUE);
    DestroyObject(oHead);

    object oCloak = GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC);
    object oTmpCloak = CreateItemOnObject(sCompetitionResref + "_" + tmp_GetItemTypeString(INVENTORY_SLOT_CLOAK), oPC);
    NWNX_Item_RestoreItemAppearance(oCloak, NWNX_Item_GetEntireItemAppearance(oTmpCloak));
    DestroyObject(oTmpCloak);
    CopyItem(oCloak, oPC, TRUE);
    DestroyObject(oCloak);

    object oHand1 = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    object oTmpHand1 = CreateItemOnObject(sCompetitionResref + "_" + tmp_GetItemTypeString(INVENTORY_SLOT_RIGHTHAND), oPC);
    NWNX_Item_RestoreItemAppearance(oHand1, NWNX_Item_GetEntireItemAppearance(oTmpHand1));
    DestroyObject(oTmpHand1);
    CopyItem(oHand1, oPC, TRUE);
    DestroyObject(oHand1);

    object oHand2 = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    object oTmpHand2 = CreateItemOnObject(sCompetitionResref + "_" + tmp_GetItemTypeString(INVENTORY_SLOT_LEFTHAND), oPC);
    NWNX_Item_RestoreItemAppearance(oHand2, NWNX_Item_GetEntireItemAppearance(oTmpHand2));
    DestroyObject(oTmpHand2);
    CopyItem(oHand2, oPC, TRUE);
    DestroyObject(oHand2);




    //SetCreatureAppearanceType(oPC, APPEARANCE_TYPE_CHICKEN);
    //SetCreatureAppearanceType(oPC, GetRacialType(oPC));
    /*
    //SetCreatureAppearanceType(oPC, GetRacialType(oPC));
    //SetCreatureAppearanceType(oPC, 3006);


    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(oPC), FALSE);
    //object oTarget = GetFirstPC();
    while(GetIsObjectValid(oTarget))
    {
        //SetCreatureAppearanceType(oTarget, Random(3000)+1);
        if (GetIsPC(oTarget)) SetCreatureAppearanceType(oTarget, GetRacialType(oTarget));
    //    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(5000), oTarget);
    //    if (GetIsPC(oTarget)) SetCreatureAppearanceType(oTarget, APPEARANCE_TYPE_CHICKEN);
    //    oTarget = GetNextPC();
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, 30.0, GetLocation(oPC), FALSE);
    }
    */
}

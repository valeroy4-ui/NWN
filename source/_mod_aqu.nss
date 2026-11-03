#include "_inc_factions"
#include "_inc_generic"
#include "nwnx_util"
#include "nwnx_sql"
#include "_inc_array"
#include "_inc_areas"
#include "_inc_itemprop"

//
void CleanChest(object oChest);

//
void DetectDupedLoot(object oPC, object oItem);

//
void AutoSyncLoot(object oPC, object oItem);


void main()
{
    object oPC = GetModuleItemAcquiredBy();
    object oItem = GetModuleItemAcquired();
    object oOwner = GetModuleItemAcquiredFrom();
    string sOwnerTag = GetTag(oOwner);

    //SendMessageToPC(oPC, GetName(oItem));

    // 1.71: craft dupe fix &
    if(GetLocalInt(oItem, "DUPLICATED_ITEM"))
    {
        DestroyObject(oItem);
        return;
    }

    if(!GetIsPC(oPC)) return; // following staff for PCs only
    if(!GetLocalInt(oPC,"CT_LOGIN_READY")) return;

    // 1.72: support for OC henchman inventory across levelling
    if(GetAssociateType(oPC) == ASSOCIATE_TYPE_HENCHMAN && !GetLocalInt(oItem, "70_MY_ORIGINAL_POSSESSION") && oOwner == GetMaster(oPC))
    {
        SetLocalInt(oItem, "70_ACQUIRED_FROM_MASTER", TRUE);
    }

    // begin loot
    string  sLootCategory       = GetLocalString(oItem, "LOOT_CATEGORY");
    if(sLootCategory != "") // clear loot cash json
        DeleteLocalJson(GetModule(), "LOOT_STAT");

    string  sOrigName           = GetName(oItem, TRUE);
    int     iFactionPC          = players_GetFaction(oPC);
    string  sFactionColor       = players_GetFactionColor(iFactionPC);
    int     iPlayerID           = players_GetPCPersistentID(oPC);
    string  sCharName           = NWNX_Util_StripColors(GetName(oPC));

    if(GetIsPC(oPC) && !GetLocalInt(oItem, "ID") && (GetTag(oItem) == "fl_inst_key" ||
       FindSubString(sOwnerTag, "boss_chest_") != -1 || FindSubString(sOwnerTag, "chest_soul_") != -1))
    {
        int bFloatingText = (FindSubString(sOwnerTag, "boss_chest_") != -1);
        string sTableName = GetLootTableByLootCategory(sLootCategory);
        string sLootColor = GetLootColorByLootCategory(sLootCategory);
        if(GetStringLength(sTableName) > 0 && GetStringLength(sLootColor) > 0)
        {
            string sSQL = "INSERT INTO " + sTableName + " (name, looter_id, looter_char_name, last_acquired_by) VALUES (?, ?, ?, ?)";
            NWNX_SQL_PrepareQuery(sSQL);
            NWNX_SQL_PreparedString(0, sOrigName);
            NWNX_SQL_PreparedInt(1, iPlayerID);
            NWNX_SQL_PreparedString(2, sCharName);
            NWNX_SQL_PreparedInt(3, iPlayerID);
            if(NWNX_SQL_ExecutePreparedQuery())
            {
                int iItemID = db_GetDatabaseLastInsertID();
                if(iItemID > 0)
                {
                    SetLocalInt(oItem, "ID", iItemID);
                    // personalize name of item
                    string sName = sOrigName + " " + sLootColor + "#" + IntToString(iItemID) + TXT_COLOR_END + " of " +
                            sFactionColor + sCharName + TXT_COLOR_END;
                    SetName(oItem, sName);

                    if(bFloatingText)
                        FloatingTextStringOnCreature(sFactionColor + sCharName + TXT_COLOR_END + " has looted " + sOrigName, oPC, TRUE);
                }
                else
                    WriteLog("Function db_GetDatabaseLastInsertID() returns zero value.", LOG_LEVEL_ERROR);
            }
        }
    }
    if(GetIsPC(oPC) && !GetIsDM(oPC))
    {
        string sItemResref = GetResRef(oItem);
        if     (sItemResref == CONST_ITEM_GOLD)
        {
            if(iFactionPC == players_GetFaction(oItem)) // Convert gold item
            {
                AssignCommand(GetModule(), DelayCommand(0.0, generic_MoveItem(oItem, oOwner, TRUE, FALSE)));
                SendColorMessageToPC(oPC, "You can not steal gold of your faction.", TXT_COLOR_RED);
            }
            else
            {
                int iGoldAmount = GetLocalInt(oItem, "GENERATED_GOLD_PIECE");
                string sGoldItemName = GetName(oItem);
                DestroyItemSilently(oPC, oItem);
                GiveGoldToCreatureSilently(oPC, iGoldAmount);
                FloatingTextStringOnCreature(ColorText(sCharName, sFactionColor) + " has looted " + sGoldItemName, oPC, TRUE);
            }
        }
        else if(sItemResref == CONST_ITEM_FAME) // Convert fame item
        {
            int iFame = GetLocalInt(oItem, "GENERATED_FAME_POINTS");
            DestroyItemSilently(oPC, oItem);
            factions_AddFame(oPC, iFame);
            factions_StoreFameEventToDatabase(oPC, OBJECT_INVALID, GetHitDice(oPC), 0, SQLite_GetTimeStamp(),
                                              GetTag(GetArea(oPC)), iFame, FAME_GAIN_TYPE_PVE);
            factions_AddFameToFaction(players_GetFaction(oPC), iFame);
            FloatingTextStringOnCreature(ColorText(sCharName, sFactionColor) + " has looted " + IntToString(iFame) + " Fame", oPC, TRUE);
        }
        else if(sItemResref == CONST_ITEM_SOULSTONE) // Convert soulstone item
        {
            DestroyItemSilently(oPC, oItem);
            generic_ChangeSoulStonesAmount(oPC, 1);
            FloatingTextStringOnCreature(sFactionColor + sCharName + TXT_COLOR_END + " has looted Soul Stone", oPC, TRUE);
        }
        else if (GetLocalInt(oItem, "RUNE_TYPE") > 1 && !GetLocalInt(oItem, "RUNE_HAS_BEEN_LOOTED") && GetResRef(oOwner) == "plc_mob_loot") // epic rune alarm
        {
            FloatingTextStringOnCreature(ColorText(sCharName, sFactionColor) + " has looted " + sOrigName, oPC, TRUE);
            ServerShout(ColorText(sCharName, sFactionColor) + ColorText(" has looted ", TXT_COLOR_ORANGE) +
                        ColorText(sOrigName, TXT_COLOR_WHITE_T) + ColorText(" in area ", TXT_COLOR_ORANGE) + ColorText(GetName(GetArea(oPC)), TXT_COLOR_WHITE_T));
            SetLocalInt(oItem, "RUNE_HAS_BEEN_LOOTED", 1);
        }
    }
    if (FindSubString(sOwnerTag, "boss_chest_") != -1 || FindSubString(sOwnerTag, "chest_soul_") != -1)
    {
        CleanChest(oOwner);
        if(FindSubString(sOwnerTag, "chest_soul_") != -1)
        {
            AssignCommand(oPC, ClearAllActions());
            SetLocked(oOwner, TRUE);
        }
    }
    // end loot
    if(players_GetPCPersistentID(oPC))
    {
        AutoSyncLoot(oPC, oItem);
        int nLevelOverride = GetLocalInt(oItem, "LEVEL");
        if(nLevelOverride)
            NWNX_Item_SetMinEquipLevelOverride(oItem, nLevelOverride);
        DetectDupedLoot(oPC, oItem); // duped items check
        UpdateAcquiredInfo(oPC, oItem); // save PC ID who last aquired item
        ip_FixIllegalIPs(oItem); // remove all immunities
    }
}

void CleanChest(object oChest)
{
    object oItem = GetFirstItemInInventory(oChest);
    while(GetIsObjectValid(oItem))
    {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oChest);
    }
}

void DetectDupedLoot(object oPC, object oItem)
{
    string sLootCategory = GetLocalString(oItem, "LOOT_CATEGORY");
    // check only PCs and boss loot category
    if (GetResRef(GetArea(oPC)) == AREA_TESTROOM_RESREF || sLootCategory == "" ||
        !GetIsPC(oPC) || GetIsDM(oPC)) return;

    object oModule          = GetModule();
    int    iLootID          = GetLocalInt(oItem, "ID");
    string sLootUUID        = GetObjectUUID(oItem);
    string sCashedItemUUID  = "";

    // check if item inserted in array
    int iLootIdIndex = Array_Find_Int(sLootCategory + "_INDEX_ARRAY", iLootID, oModule);

    if (iLootIdIndex != INVALID_INDEX)
        sCashedItemUUID = Array_At_Str(sLootCategory + "_UUID_ARRAY", iLootIdIndex, oModule);

    object oCashedItem = GetObjectByUUID(sCashedItemUUID);

    if (!GetIsObjectValid(oCashedItem))
    {
        if (iLootIdIndex != INVALID_INDEX)
        {
            Array_Set_Int(sLootCategory + "_INDEX_ARRAY", iLootIdIndex, 0, oModule);
            Array_Set_Str(sLootCategory + "_UUID_ARRAY", iLootIdIndex, " ", oModule);
        }
        Array_PushBack_Int(sLootCategory + "_INDEX_ARRAY", iLootID, oModule);
        Array_PushBack_Str(sLootCategory + "_UUID_ARRAY", sLootUUID);
    }
    // if inserted do dupe check based item ID and UUID
    else if (sCashedItemUUID != sLootUUID)
    {
        string sQuery = "INSERT INTO dupe_warnings" +
                      " (item_name_cashed, item_name_checked, item_uuid_cashed, item_uuid_checked, pc_id_cashed, pc_id_checked, pc_name_cashed, pc_name_checked) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        NWNX_SQL_PrepareQuery(sQuery);
        NWNX_SQL_PreparedString(0, NWNX_Util_StripColors(GetName(oCashedItem)));
        NWNX_SQL_PreparedString(1, NWNX_Util_StripColors(GetName(oItem)));
        NWNX_SQL_PreparedString(2, sCashedItemUUID);
        NWNX_SQL_PreparedString(3, sLootUUID);

        object oCashedItemPC = GetItemPossessor(oCashedItem);

        NWNX_SQL_PreparedInt(4, players_GetPCPersistentID(oCashedItemPC));
        NWNX_SQL_PreparedInt(5, players_GetPCPersistentID(oPC));
        NWNX_SQL_PreparedString(6, NWNX_Util_StripColors(GetName(oCashedItemPC)));
        NWNX_SQL_PreparedString(7, NWNX_Util_StripColors(GetName(oPC)));
        if(NWNX_SQL_ExecutePreparedQuery()) WriteLog("Duplicated items have been detected!", LOG_LEVEL_CHEAT);
    }
}

void AutoSyncLoot(object oPC, object oItem)
{
    // dont sync instance keys and no palette items
    if(GetLocalString(oItem, "LOOT_CATEGORY") == "" || GetTag(oItem) == "fl_inst_key")
        return;

    // feedback msgs off
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_EQUIP_NATURAL_AC_NO_STACK, TRUE, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_EQUIP_ARMOUR_AC_NO_STACK, TRUE, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_EQUIP_SHIELD_AC_NO_STACK, TRUE, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_EQUIP_DEFLECTION_AC_NO_STACK, TRUE, oPC);

    string sModuleResref = NWNX_Util_GetFirstResRef(NWNX_UTIL_RESREF_TYPE_ITEM, "^" + GetResRef(oItem) +"$");
    // remove all permanent item properties
    IPRemoveAllItemProperties(oItem, DURATION_TYPE_PERMANENT);
    // convert template to json and get properties array
    json jItem = TemplateToJson(sModuleResref, RESTYPE_UTI);
    int i = 0;
    // iterate through json localvars
    json jVarsArray = GffGetList(jItem, "VarTable");
    json jVar = JsonArrayGet(jVarsArray, i);
    while(jVar != JSON_NULL)
    {
        string sVarName = JsonGetString(GffGetString(jVar, "Name"));
        int nType = JsonGetInt(GffGetDword(jVar, "Type"));
        //ServerShout(IntToString(nType));
        switch(nType)
        {
            case NWNX_OBJECT_LOCALVAR_TYPE_INT:
            {
                int nValue = JsonGetInt(GffGetInt(jVar, "Value"));
                SetLocalInt(oItem, sVarName, nValue);
                //ServerShout(IntToString(nValue));
            }
            break;
            case NWNX_OBJECT_LOCALVAR_TYPE_STRING:
            {
                string sValue = JsonGetString(GffGetString(jVar, "Value"));
                SetLocalString(oItem, sVarName, sValue);
                //ServerShout(sValue);
            }
            break;
        }
        jVar = JsonArrayGet(jVarsArray, ++i);
    }
    i = 0;
    json jPropArray = GffGetList(jItem, "PropertiesList");
    json jProp = JsonArrayGet(jPropArray, i);
    // iterate through json props, construct new and apply
    while(jProp != JSON_NULL)
    {
        itemproperty ip_Loop;
        struct NWNX_IPUnpacked stIpUnpacked = NWNX_ItemProperty_UnpackIP(ip_Loop);
        stIpUnpacked.nProperty = JsonGetInt(GffGetWord(jProp, "PropertyName"));
        stIpUnpacked.nSubType = JsonGetInt(GffGetWord(jProp, "Subtype"));
        stIpUnpacked.nCostTable = JsonGetInt(GffGetByte(jProp, "CostTable"));
        stIpUnpacked.nCostTableValue = JsonGetInt(GffGetWord(jProp, "CostValue"));
        stIpUnpacked.nParam1 = JsonGetInt(GffGetByte(jProp, "Param1"));
        stIpUnpacked.nParam1Value = JsonGetInt(GffGetByte(jProp, "Param1Value"));
        stIpUnpacked.nUsesPerDay = 255;
        stIpUnpacked.nChanceToAppear = 100;
        stIpUnpacked.bUsable = 1;
        stIpUnpacked.nSpellId = -1;
        stIpUnpacked.sTag = "";
        ip_Loop = NWNX_ItemProperty_PackIP(stIpUnpacked);
        AddItemProperty(DURATION_TYPE_PERMANENT, ip_Loop, oItem);
        jProp = JsonArrayGet(jPropArray, ++i);
    }
    // feedback msgs on
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_EQUIP_NATURAL_AC_NO_STACK, FALSE, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_EQUIP_ARMOUR_AC_NO_STACK, FALSE, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_EQUIP_SHIELD_AC_NO_STACK, FALSE, oPC);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_EQUIP_DEFLECTION_AC_NO_STACK, FALSE, oPC);
}

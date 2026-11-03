#include "_inc_log"
#include "nwnx_sql"
#include "nwnx_item"
#include "nwnx_itemprop"
#include "nw_inc_gff"
#include "_inc_generic"
#include "_inc_array"

///////////////////////////////////////////////////////////////////
//////////                  Constants                    //////////
///////////////////////////////////////////////////////////////////

/* weapons
int BASE_ITEM_SHORTSWORD            = 0;
int BASE_ITEM_LONGSWORD             = 1;
int BASE_ITEM_BATTLEAXE             = 2;
int BASE_ITEM_BASTARDSWORD          = 3;
int BASE_ITEM_LIGHTFLAIL            = 4;
int BASE_ITEM_WARHAMMER             = 5;
int BASE_ITEM_HEAVYCROSSBOW         = 6;
int BASE_ITEM_LIGHTCROSSBOW         = 7;
int BASE_ITEM_LONGBOW               = 8;
int BASE_ITEM_LIGHTMACE             = 9;
int BASE_ITEM_HALBERD               = 10;
int BASE_ITEM_SHORTBOW              = 11;
int BASE_ITEM_TWOBLADEDSWORD        = 12;
int BASE_ITEM_GREATSWORD            = 13;
int BASE_ITEM_GREATAXE              = 18;
int BASE_ITEM_DAGGER                = 22;
int BASE_ITEM_CLUB                  = 28;
int BASE_ITEM_DART                  = 31;
int BASE_ITEM_DIREMACE              = 32;
int BASE_ITEM_DOUBLEAXE             = 33;
int BASE_ITEM_HEAVYFLAIL            = 35;
int BASE_ITEM_GLOVES                = 36;
int BASE_ITEM_LIGHTHAMMER           = 37;
int BASE_ITEM_HANDAXE               = 38;
int BASE_ITEM_KAMA                  = 40;
int BASE_ITEM_KATANA                = 41;
int BASE_ITEM_KUKRI                 = 42;
int BASE_ITEM_MORNINGSTAR           = 47;
int BASE_ITEM_QUARTERSTAFF          = 50;
int BASE_ITEM_RAPIER                = 51;
int BASE_ITEM_SCIMITAR              = 53;
int BASE_ITEM_SCYTHE                = 55;
int BASE_ITEM_SHORTSPEAR            = 58;
int BASE_ITEM_SHURIKEN              = 59;
int BASE_ITEM_SICKLE                = 60;
int BASE_ITEM_SLING                 = 61;
int BASE_ITEM_THROWINGAXE           = 63;
int BASE_ITEM_TRIDENT               = 95;
int BASE_ITEM_DWARVENWARAXE         = 108;
int BASE_ITEM_WHIP                  = 111;

// ammo
int BASE_ITEM_ARROW                 = 20;
int BASE_ITEM_BOLT                  = 25;
int BASE_ITEM_BULLET                = 27;

// gear
int BASE_ITEM_SMALLSHIELD           = 14;
int BASE_ITEM_LARGESHIELD           = 56;
int BASE_ITEM_TOWERSHIELD           = 57;
int BASE_ITEM_TORCH                 = 15;
int BASE_ITEM_ARMOR                 = 16;
int BASE_ITEM_HELMET                = 17;
int BASE_ITEM_AMULET                = 19;
int BASE_ITEM_BELT                  = 21;
int BASE_ITEM_BOOTS                 = 26;
int BASE_ITEM_MAGICSTAFF            = 45;
int BASE_ITEM_RING                  = 52;
int BASE_ITEM_BRACER                = 78;
int BASE_ITEM_CLOAK                 = 80;

// misc
int BASE_ITEM_MISCSMALL             = 24;
int BASE_ITEM_MISCMEDIUM            = 29;
int BASE_ITEM_MISCLARGE             = 34;
int BASE_ITEM_HEALERSKIT            = 39;
int BASE_ITEM_MISCTALL              = 43;
int BASE_ITEM_MAGICROD              = 44;
int BASE_ITEM_MAGICWAND             = 46;
int BASE_ITEM_POTIONS               = 49;
int BASE_ITEM_SCROLL                = 54;
int BASE_ITEM_THIEVESTOOLS          = 62;
int BASE_ITEM_TRAPKIT               = 64;
int BASE_ITEM_KEY                   = 65;
int BASE_ITEM_LARGEBOX              = 66;
int BASE_ITEM_MISCWIDE              = 68;
int BASE_ITEM_BOOK                  = 74;
int BASE_ITEM_SPELLSCROLL           = 75;
int BASE_ITEM_GOLD                  = 76;
int BASE_ITEM_GEM                   = 77;
int BASE_ITEM_MISCTHIN              = 79;
int BASE_ITEM_GRENADE               = 81;
int BASE_ITEM_BLANK_POTION          = 101;
int BASE_ITEM_BLANK_SCROLL          = 102;
int BASE_ITEM_BLANK_WAND            = 103;
int BASE_ITEM_ENCHANTED_POTION      = 104;
int BASE_ITEM_ENCHANTED_SCROLL      = 105;
int BASE_ITEM_ENCHANTED_WAND        = 106;
int BASE_ITEM_CRAFTMATERIALMED      = 109;
int BASE_ITEM_CRAFTMATERIALSML      = 110; */

const int LOOT_SUBTYPE_ALL          = 0; // for extensions like LOOT_SUBTYPE_AMULET etc


///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

//
void loot_ItemDelayCreator(int nPaletteID, string sLootCategory, object oOwner);

// object oArea - area where script will try to find chests for treasure generating. (treasure chest has localint "CORMYR_TREASURE_CHEST" = 1)
// string sLootCategory - possible values: "BLUE", "GREEN", "PURPLE", "RED", "ARTIFACT"
// int nItemsInChest - how many items in chest
// int nLootSubtype - TODO (sort loot by BaseItemType, rings only, weapons only etc)
//                    LOOT_SUBTYPE_DEFAULT - without any kind of sorting
void loot_GenerateBossTreasuresInArea(object oArea, string sLootCategory, int nItemsInChest, int nLootSubtype=LOOT_SUBTYPE_ALL);

// build SQL query for generating items list
string loot_TryToCreateSqlQuery(string sLootCategory, int nLootSubtype, int nItemsInChest);

// store oItem into DB
void loot_StoreItemIntoDatabase(object oItem);

// returns store for cashing gff constructed item templates
object loot_GetGffTemplateStoreByLootCategory(string sCategory);

// create stored item by database id
object loot_CreateStoredItem(int nPaletteID, string sLootCategory, object oOwner = OBJECT_INVALID);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void loot_ItemDelayCreator(int nPaletteID, string sLootCategory, object oOwner)
{
    loot_CreateStoredItem(nPaletteID, sLootCategory, oOwner);
}

void loot_GenerateBossTreasuresInArea(object oArea, string sLootCategory, int nItemsInChest, int nLootSubtype=LOOT_SUBTYPE_ALL)
{
    if(!GetIsObjectValid(oArea))
        return;
    object oChest = GetFirstObjectInArea(oArea, OBJECT_TYPE_PLACEABLE);
    while(GetIsObjectValid(oChest))
    {
        if(/*GetLocalInt(oChest, "CORMYR_TREASURE_CHEST") && */ GetHasInventory(oChest))
        {
            string sSQL = loot_TryToCreateSqlQuery(sLootCategory, nLootSubtype, nItemsInChest);
            if(sSQL != "")
            {
                NWNX_SQL_PrepareQuery(sSQL);
                NWNX_SQL_PreparedString(0, sLootCategory);
                NWNX_SQL_PreparedInt(1, nItemsInChest);
                if(NWNX_SQL_ExecutePreparedQuery())
                {
                    int i;
                    while(NWNX_SQL_ReadyToReadNextRow())
                    {
                        NWNX_SQL_ReadNextRow();
                        int nPaletteID = StringToInt(NWNX_SQL_ReadDataInActiveRow());
                        AssignCommand(GetModule(), DelayCommand(0.01 * ++i,
                            loot_ItemDelayCreator(nPaletteID, sLootCategory, oChest)));
                    }
                }
            }
            else
                WriteLog("sSQL is empty in function loot_GenerateBossTreasuresInArea, loot generation is not possible.", LOG_LEVEL_ERROR);
        }
        // get next object in Area
        oChest = GetNextObjectInArea(oArea, OBJECT_TYPE_PLACEABLE);
    }
}

string loot_TryToCreateSqlQuery(string sLootCategory, int nLootSubtype, int nItemsInChest)
{
    string sResult = "";
    switch(nLootSubtype)
    {
        case LOOT_SUBTYPE_ALL:
            sResult = "select P.palette_id from palette P WHERE P.category = ? ORDER BY RAND() LIMIT ?";
        break;
    }
    return sResult;
}

void loot_StoreItemIntoDatabase(object oItem)
{
    string sInsertIntoPalette = "INSERT INTO palette (name, description, category, baseitem, resref, appearance) VALUES (?, ?, ?, ?, ?, ?)";
    int nBaseItemType = GetBaseItemType(oItem);
    NWNX_SQL_PrepareQuery(sInsertIntoPalette);
    NWNX_SQL_PreparedString(0, GetName(oItem, TRUE));
    NWNX_SQL_PreparedString(1, GetDescription(oItem, TRUE));
    NWNX_SQL_PreparedString(2, GetLocalString(oItem, "LOOT_CATEGORY"));
    NWNX_SQL_PreparedInt(3, nBaseItemType);
    NWNX_SQL_PreparedString(4, GetResRef(oItem));
    NWNX_SQL_PreparedString(5, NWNX_Item_GetEntireItemAppearance(oItem));

    if(NWNX_SQL_ExecutePreparedQuery())
    {
        int nItemId = db_GetDatabaseLastInsertID();
        itemproperty ip_Loop = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(ip_Loop))
        {
            if(GetItemPropertyDurationType(ip_Loop) == DURATION_TYPE_PERMANENT)
            {
                struct NWNX_IPUnpacked stIpUnpacked = NWNX_ItemProperty_UnpackIP(ip_Loop);
                string sInsertIntoPaletteIp = "INSERT INTO palette_ip (palette_id, name, property, subtype, cost_table, cost_table_value, param1, param1_value, uses_per_day, chance_to_appear, usable, spell_id, tag) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                NWNX_SQL_PrepareQuery(sInsertIntoPaletteIp);
                NWNX_SQL_PreparedInt(0, nItemId);
                NWNX_SQL_PreparedString(1, GetStringByStrRef(StringToInt(Get2DAString("itemprops", "stringref", stIpUnpacked.nProperty))));
                NWNX_SQL_PreparedInt(2, stIpUnpacked.nProperty);
                NWNX_SQL_PreparedInt(3, stIpUnpacked.nSubType);
                NWNX_SQL_PreparedInt(4, stIpUnpacked.nCostTable);
                NWNX_SQL_PreparedInt(5, stIpUnpacked.nCostTableValue);
                NWNX_SQL_PreparedInt(6, stIpUnpacked.nParam1);
                NWNX_SQL_PreparedInt(7, stIpUnpacked.nParam1Value);
                NWNX_SQL_PreparedInt(8, stIpUnpacked.nUsesPerDay);
                NWNX_SQL_PreparedInt(9, stIpUnpacked.nChanceToAppear);
                NWNX_SQL_PreparedInt(10, stIpUnpacked.bUsable);
                NWNX_SQL_PreparedInt(11, stIpUnpacked.nSpellId);
                NWNX_SQL_PreparedString(12, stIpUnpacked.sTag);
                NWNX_SQL_ExecutePreparedQuery();
            }
            ip_Loop = GetNextItemProperty(oItem);
        }
    }
}

object loot_GetGffTemplateStoreByLootCategory(string sCategory)
{
    if     (sCategory == "BLUE")
        return GetObjectByTag("GFF_TEMPLATE_STORE_BLUE");
    else if(sCategory == "GREEN")
        return GetObjectByTag("GFF_TEMPLATE_STORE_GREEN");
    else if(sCategory == "PURPLE")
        return GetObjectByTag("GFF_TEMPLATE_STORE_PURPLE");
    else if(sCategory == "RED")
        return GetObjectByTag("GFF_TEMPLATE_STORE_RED");
    else if(sCategory == "ARTIFACT")
        return GetObjectByTag("GFF_TEMPLATE_STORE_ARTIFACT");
    else
        return OBJECT_INVALID;
}

object loot_CreateStoredItem(int nPaletteID, string sLootCategory, object oOwner = OBJECT_INVALID)
{
    object oResult = OBJECT_INVALID;
    object oGffStore = loot_GetGffTemplateStoreByLootCategory(sLootCategory);
    if(GetIsObjectValid(GetLocalObject(oGffStore, IntToString(nPaletteID))))
        oResult = GetLocalObject(oGffStore, IntToString(nPaletteID));
    else
    {
        object oItem = OBJECT_INVALID;
        string sPalette = "SELECT name, description, category, baseitem, resref, appearance FROM palette WHERE palette_id = ?";
        NWNX_SQL_PrepareQuery(sPalette);
        NWNX_SQL_PreparedInt(0, nPaletteID);
        if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
        {
            // create necessary base item with local vars
            NWNX_SQL_ReadNextRow();
            string sName = NWNX_SQL_ReadDataInActiveRow();
            string sDescription = NWNX_SQL_ReadDataInActiveRow(1);
            string sCategory = NWNX_SQL_ReadDataInActiveRow(2);
            int nBaseItem = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
            string sResref = NWNX_SQL_ReadDataInActiveRow(4);
            string sAppearance = NWNX_SQL_ReadDataInActiveRow(5);
            json jObject = GffCreateObject(OBJECT_TYPE_ITEM); // object created
            jObject = GffAddLocString(jObject, "LocalizedName", sName);
            jObject = GffAddLocString(jObject, "DescIdentified", sDescription);
            jObject = GffAddInt(jObject, "BaseItem", nBaseItem);
            jObject = GffAddString(jObject, "Tag", sResref);
            jObject = GffAddResRef(jObject, "TemplateResRef", sResref);
            oItem = JsonToObject(jObject, GetStartingLocation(), oGffStore);
            NWNX_Item_RestoreItemAppearance(oItem, sAppearance);
            SetLocalString(oItem, "LOOT_CATEGORY", sCategory);
            SetLocalInt(oItem, "PALETTE_ID", nPaletteID);
            SetLocalObject(oGffStore, IntToString(nPaletteID), oItem);
            // add itemproperties
            string sPaletteIp = "SELECT property, subtype, cost_table, cost_table_value, param1, param1_value, uses_per_day, chance_to_appear, usable, spell_id, tag FROM palette_ip WHERE palette_id = ?";
            NWNX_SQL_PrepareQuery(sPaletteIp);
            NWNX_SQL_PreparedInt(0, nPaletteID);
            NWNX_SQL_ExecutePreparedQuery();
            while(NWNX_SQL_ReadyToReadNextRow())
            {
                NWNX_SQL_ReadNextRow();
                itemproperty ip_Loop;
                struct NWNX_IPUnpacked stIpUnpacked = NWNX_ItemProperty_UnpackIP(ip_Loop);
                stIpUnpacked.nProperty = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
                stIpUnpacked.nSubType = StringToInt(NWNX_SQL_ReadDataInActiveRow(1));
                stIpUnpacked.nCostTable = StringToInt(NWNX_SQL_ReadDataInActiveRow(2));
                stIpUnpacked.nCostTableValue = StringToInt(NWNX_SQL_ReadDataInActiveRow(3));
                stIpUnpacked.nParam1 = StringToInt(NWNX_SQL_ReadDataInActiveRow(4));
                stIpUnpacked.nParam1Value = StringToInt(NWNX_SQL_ReadDataInActiveRow(5));
                stIpUnpacked.nUsesPerDay = StringToInt(NWNX_SQL_ReadDataInActiveRow(6));
                stIpUnpacked.nChanceToAppear = StringToInt(NWNX_SQL_ReadDataInActiveRow(7));
                stIpUnpacked.bUsable = StringToInt(NWNX_SQL_ReadDataInActiveRow(8));
                stIpUnpacked.nSpellId = StringToInt(NWNX_SQL_ReadDataInActiveRow(9));
                stIpUnpacked.sTag = NWNX_SQL_ReadDataInActiveRow(10);
                ip_Loop = NWNX_ItemProperty_PackIP(stIpUnpacked);
                AddItemProperty(DURATION_TYPE_PERMANENT, ip_Loop, oItem);

            }
        }
        oResult = oItem;
    }
    // add item to oOwner inventory or to starting location of oOwner is invalid
    CopyObject(oResult, GetStartingLocation(), oOwner, "", TRUE);
    return oResult;
}

//void main() {}

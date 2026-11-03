#include "_inc_generic"
#include "_inc_array"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// local vars names
const string sLootTier                  = "LOOT_TIER";
const string sItemAmountInChest         = "ITEMS_AMOUNT_IN_CHEST";
const string sGoldChanceInChest         = "GOLD_CHANÑE_IN_CHEST";
const string sFameChanceInChest         = "FAME_CHANÑE_IN_CHEST";
const string sMaxFameInChest            = "MAX_FAME_IN_CHEST";

// local vars values
const int LOOT_MOBS_LEVEL_01            = 1;
const int LOOT_MOBS_LEVEL_02            = 2;
const int LOOT_MOBS_LEVEL_03            = 3;
const int LOOT_MOBS_LEVEL_04            = 4;
const int LOOT_MOBS_LEVEL_05            = 5;
const int LOOT_MOBS_LEVEL_06            = 6;
const int LOOT_MOBS_LEVEL_07            = 7;
const int LOOT_MOBS_LEVEL_08            = 8;
const int LOOT_MOBS_LEVEL_09            = 9;
const int LOOT_MOBS_LEVEL_10            = 10;

const int LOOT_BOSS_LEVEL_01            = 11;  // blue
const int LOOT_BOSS_LEVEL_02            = 12;  // green weapons
const int LOOT_BOSS_LEVEL_03            = 13;  // green equipment
const int LOOT_BOSS_LEVEL_04            = 14;  // green weapons + green equipment
const int LOOT_BOSS_LEVEL_05            = 15;  // purple weapons
const int LOOT_BOSS_LEVEL_06            = 16;  // purple equipment
const int LOOT_BOSS_LEVEL_07            = 17;  // purple weapons + purple equipment
const int LOOT_BOSS_LEVEL_08            = 18;  // red weapons
const int LOOT_BOSS_LEVEL_09            = 19;  // red equipment
const int LOOT_BOSS_LEVEL_10            = 20;  // red weapons + red equipment
const int LOOT_BOSS_LEVEL_11            = 21;  // artifacts

// merchants objects tags
// used for cash loot palette
const string sSorceLootMobsLevel_01     = "MERCHANT_FOR_LOOT_MOBS_LEVEL_01";
const string sSorceLootMobsLevel_02     = "MERCHANT_FOR_LOOT_MOBS_LEVEL_02";
const string sSorceLootMobsLevel_03     = "MERCHANT_FOR_LOOT_MOBS_LEVEL_03";
const string sSorceLootMobsLevel_04     = "MERCHANT_FOR_LOOT_MOBS_LEVEL_04";
const string sSorceLootMobsLevel_05     = "MERCHANT_FOR_LOOT_MOBS_LEVEL_05";
const string sSorceLootMobsLevel_06     = "MERCHANT_FOR_LOOT_MOBS_LEVEL_06";
const string sSorceLootMobsLevel_07     = "MERCHANT_FOR_LOOT_MOBS_LEVEL_07";
const string sSorceLootMobsLevel_08     = "MERCHANT_FOR_LOOT_MOBS_LEVEL_08"; // mass cast runes
const string sSorceLootMobsLevel_09     = "MERCHANT_FOR_LOOT_MOBS_LEVEL_09"; // epic runes
const string sSorceLootMobsLevel_10     = "MERCHANT_FOR_LOOT_MOBS_LEVEL_10"; // artifact runes

const string sSorceLootBossLevel_01     = "MERCHANT_FOR_LOOT_BOSS_LEVEL_01"; // blue
const string sSorceLootBossLevel_02     = "MERCHANT_FOR_LOOT_BOSS_LEVEL_02";
const string sSorceLootBossLevel_03     = "MERCHANT_FOR_LOOT_BOSS_LEVEL_03";
const string sSorceLootBossLevel_04     = "MERCHANT_FOR_LOOT_BOSS_LEVEL_04";
const string sSorceLootBossLevel_05     = "MERCHANT_FOR_LOOT_BOSS_LEVEL_05";
const string sSorceLootBossLevel_06     = "MERCHANT_FOR_LOOT_BOSS_LEVEL_06";
const string sSorceLootBossLevel_07     = "MERCHANT_FOR_LOOT_BOSS_LEVEL_07";
const string sSorceLootBossLevel_08     = "MERCHANT_FOR_LOOT_BOSS_LEVEL_08";
const string sSorceLootBossLevel_09     = "MERCHANT_FOR_LOOT_BOSS_LEVEL_09";
const string sSorceLootBossLevel_10     = "MERCHANT_FOR_LOOT_BOSS_LEVEL_10";
const string sSorceLootBossLevel_11     = "MERCHANT_FOR_LOOT_BOSS_LEVEL_11"; // artifacts

// util local vars
string sMerchantInitilazed              = "MERCHANT_INITIALIZED";
string sLocalItemObjectConstName        = "LOCAL_ITEM_OBJECT_CONST_NAME_";
string sTotalItemsOnMerchant            = "TOTAL_ITEMS_ON_MERCHANT";

// returns TRUE if merchant object initialised
int GetIsMerchantInitialized(object oBaseCont);

// set merchant object init state
void SetIsMerchantInitialized(object oBaseCont, int iInit=TRUE);

// cash all necessary values at merchant
void InitMerchant(object oMerchant);

// calculates sum of all items in merchant's inventory
int GetTotalItemsOnMerchant(object oMerchant);

// returns item object using values from merchant initialization
// iRandomItem must be in (0 .. GetTotalItemsOnMerchant - 1)
object GetInitializedLocalItemFromMerchant(object oMerchant, int iRandomItem);

// get merchant object by loot tier
object GetLootTierMerchant(int iLootTier);

// returns max possible item's stack
int GetItemStack(object oItem);

// create loot in chest using parameters
void CreateLootOnObject(object oLootTarget, int iLootTier = 1, int iNumItems = 1, int iGoldChance = 0, int iFameChance = 0, int iFameMax = 0);

// generates full tier palette based on chest's local vars, used in Test Area
void GenerateFullTierPalette(object oLootTarget);

// get loot level from mob CR
int loot_GetMobLootLevel(float fCR);

// generates CR based mob loot
void GenerateStaticMobLoot(object oCreature = OBJECT_SELF);

// generates loot from cormyrean loot pallette
void GenerateBossTreasure();

// clear all chest content
void PrepareChest(object oContainer);

// create gem in gnome chests
void CreateGnomeTreasureGem(object oChest);

// create gold item on target
void GenerateCustomGoldOnTarget(object oLootTarget, int nGoldValue, int nFaction = FACTION_UNKNOWN);

// create fame item on target
void GenerateFameOnTarget(object oLootTarget, int nFameValue);

// sort boss loot by categories
void LootSeparator();

// set timestapms for keys and chests for validation
void SetTimeStampValidation(object oBoss, int nUnixTime);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int GetIsMerchantInitialized(object oMerchant)
{
    return GetLocalInt(oMerchant, sMerchantInitilazed);
}

void SetIsMerchantInitialized(object oMerchant, int iInit = TRUE)
{
    SetLocalInt(oMerchant, sMerchantInitilazed, iInit);
}

void InitMerchant(object oMerchant)
{
    if (GetIsMerchantInitialized(oMerchant))
        return;

    int iTotalItems = GetTotalItemsOnMerchant(oMerchant);
    int i;
    string sMerchantTag = GetTag(oMerchant);

    object oTmp = GetFirstItemInInventory(oMerchant);
    for (i = 0; i <= iTotalItems - 1 ; i++)
    {
        string sIndex = IntToString(i);
        Array_PushBack_Int(sMerchantTag, i, oMerchant);
        string sLocalItemObjectVarName = sLocalItemObjectConstName + sIndex;
        SetLocalObject(oMerchant, sLocalItemObjectVarName, oTmp);
        oTmp = GetNextItemInInventory(oMerchant);
    }
    SetIsMerchantInitialized(oMerchant);
}

int GetTotalItemsOnMerchant(object oMerchant)
{
    int iTotalItems = GetLocalInt(oMerchant, sTotalItemsOnMerchant);
    if (iTotalItems)
        return iTotalItems;

    object oTmp = GetFirstItemInInventory(oMerchant);
    while (GetIsObjectValid(oTmp))
    {
        iTotalItems++;
        oTmp = GetNextItemInInventory(oMerchant);
    }
    SetLocalInt(oMerchant, sTotalItemsOnMerchant, iTotalItems);
    return iTotalItems;
}

object GetInitializedLocalItemFromMerchant(object oMerchant, int iRandomItem)
{
    if (!GetIsObjectValid(oMerchant))
    {
        return OBJECT_INVALID;
    }
    InitMerchant(oMerchant);
    // Refs to the items are stored on the container itself
    string sLocalItemObjectVarName = sLocalItemObjectConstName + IntToString(iRandomItem);
    object oLocalItem = GetLocalObject(oMerchant, sLocalItemObjectVarName);
    return oLocalItem;

}

object GetLootTierMerchant(int iLootTier)
{
    object oMerchant = OBJECT_INVALID;
    string sContTag = "";

    switch (iLootTier)
    {
        // mob palette + runes containers
        case LOOT_MOBS_LEVEL_01: sContTag = sSorceLootMobsLevel_01; break;
        case LOOT_MOBS_LEVEL_02: sContTag = sSorceLootMobsLevel_02; break;
        case LOOT_MOBS_LEVEL_03: sContTag = sSorceLootMobsLevel_03; break;
        case LOOT_MOBS_LEVEL_04: sContTag = sSorceLootMobsLevel_04; break;
        case LOOT_MOBS_LEVEL_05: sContTag = sSorceLootMobsLevel_05; break;
        case LOOT_MOBS_LEVEL_06: sContTag = sSorceLootMobsLevel_06; break;
        case LOOT_MOBS_LEVEL_07: sContTag = sSorceLootMobsLevel_07; break;
        case LOOT_MOBS_LEVEL_08: sContTag = sSorceLootMobsLevel_08; break;
        case LOOT_MOBS_LEVEL_09: sContTag = sSorceLootMobsLevel_09; break;
        case LOOT_MOBS_LEVEL_10: sContTag = sSorceLootMobsLevel_10; break;
        // boss palette
        case LOOT_BOSS_LEVEL_01: sContTag = sSorceLootBossLevel_01; break;
        case LOOT_BOSS_LEVEL_02: sContTag = sSorceLootBossLevel_02; break;
        case LOOT_BOSS_LEVEL_03: sContTag = sSorceLootBossLevel_03; break;
        case LOOT_BOSS_LEVEL_04: sContTag = sSorceLootBossLevel_04; break;
        case LOOT_BOSS_LEVEL_05: sContTag = sSorceLootBossLevel_05; break;
        case LOOT_BOSS_LEVEL_06: sContTag = sSorceLootBossLevel_06; break;
        case LOOT_BOSS_LEVEL_07: sContTag = sSorceLootBossLevel_07; break;
        case LOOT_BOSS_LEVEL_08: sContTag = sSorceLootBossLevel_08; break;
        case LOOT_BOSS_LEVEL_09: sContTag = sSorceLootBossLevel_09; break;
        case LOOT_BOSS_LEVEL_10: sContTag = sSorceLootBossLevel_10; break;
        case LOOT_BOSS_LEVEL_11: sContTag = sSorceLootBossLevel_11; break;
    }
    oMerchant = GetObjectByTag(sContTag);
    if (!GetIsObjectValid(oMerchant))
    {
        WriteTimestampedLogEntry("Critical Failure: Treasure source " + IntToString(iLootTier) +
                                 " not found, nothing will be generated!");
    }
    return oMerchant;
}

int GetItemStack(object oItem)
{
    return StringToInt(Get2DAString("baseitems", "Stacking", GetBaseItemType(oItem)));
}

void CreateLootOnObject(object oLootTarget, int iLootTier = 1, int iNumItems = 1, int iGoldChance = 0,
                        int iFameChance = 0, int iFameMax = 0)
{
    if (GetLocalInt(oLootTarget, sLootTier) != 0) iLootTier = GetLocalInt(oLootTarget, sLootTier);
    object oMerchant = GetLootTierMerchant(iLootTier);
    InitMerchant(oMerchant);
    int iTotalItemsOnMerchant = GetTotalItemsOnMerchant(oMerchant);
    string sMerchantTag = GetTag(oMerchant);
    int i;
    int bGoldHasBeenGenerated = FALSE;

    Array_Shuffle(sMerchantTag, oMerchant);
    for (i = 0; i <= iNumItems - 1; i++)
    {
        int iRandomItem     = Array_At_Int(sMerchantTag, i, oMerchant);
        object oItem        = GetInitializedLocalItemFromMerchant(oMerchant, iRandomItem);
        int iStack          = GetItemStack(oItem);

        if (iLootTier <= LOOT_MOBS_LEVEL_10)
            if (iStack > 1) iStack = Random(iStack/(21 - 2 * iLootTier)) + 1;

        int iGenerateGold = (!bGoldHasBeenGenerated && iGoldChance >= d100()) ? TRUE : FALSE;  // TODO - place before <for> loop & updates chances in chests
        if(!iGenerateGold)                                                                     // actually gold chance = iGoldChance * iNumItems
        {
            object oNewItem = CopyItem(oItem, oLootTarget, TRUE);
            if (GetIsObjectValid(oNewItem))
            {
                SetDroppableFlag(oNewItem, TRUE);
                SetItemStackSize(oNewItem, iStack);
                SetIdentified(oNewItem, TRUE);
            }
            else
                WriteTimestampedLogEntry("Error, Item was not created!");
        }
        else if(iGenerateGold) //
        {
            int nGoldBase = 350 + Random(700);
            int nMultiplier = 1;
            switch(iLootTier)
            {
                case 11: nMultiplier = 2; break; // mini
                case 12: case 13: case 14: nMultiplier = 3; break; // advanced
                case 15: case 16: case 17: nMultiplier = 4; break; // lesser
                case 18: case 19: case 20: nMultiplier = 5; break; // greater
                case 21: nMultiplier = 6; break; // artifact
            }
            int iGoldValue = iLootTier * iLootTier * nGoldBase * nMultiplier;

            GenerateCustomGoldOnTarget(oLootTarget, iGoldValue);
            bGoldHasBeenGenerated = TRUE;
        }
    }
    // fame generation
    if (iFameChance >= d100())
    {
        iFameMax = Random(iFameMax) + 1;
        GenerateFameOnTarget(oLootTarget, iFameMax);
    }
}

void GenerateFullTierPalette(object oLootTarget)
{
    int iLootTier               = GetLocalInt(oLootTarget, sLootTier);
    object oMerchant            = GetLootTierMerchant(iLootTier);
    int iTotalItemsOnMerchant   = GetTotalItemsOnMerchant(oMerchant);
    WriteTimestampedLogEntry("int iLootTier: "              + IntToString(iLootTier));
    WriteTimestampedLogEntry("object oMerchant: "           + GetTag(oMerchant));
    WriteTimestampedLogEntry("int iTotalItemsOnMerchant: "  + IntToString(iTotalItemsOnMerchant));
    int i;
    for (i = 0; i < iTotalItemsOnMerchant; i++)
    {
        object oItem = GetInitializedLocalItemFromMerchant(oMerchant, i);
        int iStack = GetItemStack(oItem);
        object oNewItem = CopyItem(oItem, oLootTarget, TRUE);
        if (GetIsObjectValid(oNewItem))
        {
            SetIdentified(oNewItem, FALSE);
            SetDroppableFlag(oNewItem, TRUE);
            SetItemStackSize(oNewItem, iStack);
            SetIdentified(oNewItem, TRUE);
            string sLootCategory = GetLocalString(oNewItem, "LOOT_CATEGORY");
            if (FindSubString(GetTag(oLootTarget), "BossLoot") != -1)
            {
                if(sLootCategory != "BLUE"   && sLootCategory != "GREEN" &&
                   sLootCategory != "PURPLE" && sLootCategory != "RED"   &&
                   sLootCategory != "ARTIFACT")
                {
                    WriteTimestampedLogEntry("Invalid Boss Item's local variables. Item's name: " + GetName(oNewItem));
                }
            }
        }
        else
            WriteTimestampedLogEntry("Error, Item was not created!");
    }
}

int loot_GetMobLootLevel(float fCR)
{
    int nTierCoeff = FloatToInt(fCR)/10 + 1;
    if(d20() == 20)
        nTierCoeff += 1;

    if      (nTierCoeff >= 5)
        return LOOT_MOBS_LEVEL_05;
    else if (nTierCoeff == 4)
        return LOOT_MOBS_LEVEL_04;
    else if (nTierCoeff == 3)
        return LOOT_MOBS_LEVEL_03;
    else if (nTierCoeff == 2)
        return LOOT_MOBS_LEVEL_02;
    else
        return LOOT_MOBS_LEVEL_01;
}

void GenerateStaticMobLoot(object oCreature = OBJECT_SELF)
{
    float fCR = GetChallengeRating(oCreature);
    int nLootTier = loot_GetMobLootLevel(fCR);
    int nItemsNumber = (d100() > 90) ? 2 : 1;

    if (d100() > 75)
        CreateLootOnObject(oCreature, nLootTier, nItemsNumber, d10());

    // runes/inst keys/champ gold
    int bChampion = GetLocalInt(oCreature, "CHAMPIONSPAWNED");
    int nWipePhase = GetLocalInt(GetModule(), CORMYREAN_WIPE_PHASE);
    int nCR = FloatToInt(fCR);
    int nInstanceChance = nCR > 5 ? (nCR * (1 + 4 * bChampion)) / (nWipePhase + 1) : 0;
    int nMassCastRuneChance = nCR * (1 + 4 * bChampion);
    int nChampGoldChance = 100; // 100%

    if(nInstanceChance >= Random(10000) + 1) // (0.05 .. 3.0) / nWipePhase) %
    {
        object oInstanceKey = CreateItemOnObject("fl_inst_key", oCreature);
        int nInstanceRoll = Random(100) + 1;
        string sInstanceKeyName = "Instance Key";
        string sLootCategory = "BLUE";
        switch(nWipePhase)
        {
            case CORMYREAN_WIPE_PHASE_1:
            {
                if(nInstanceRoll <= 50)
                {
                    sInstanceKeyName = ColorText("Newbie " + sInstanceKeyName, LOOT_COLOR_BLUE);
                    SetLocalString(oInstanceKey, "LOOT_CATEGORY", "BLUE");
                }
                else
                {
                    sInstanceKeyName = ColorText("Advanced " + sInstanceKeyName, LOOT_COLOR_GREEN);
                    SetLocalString(oInstanceKey, "LOOT_CATEGORY", "GREEN");
                }
                break;
            }
            case CORMYREAN_WIPE_PHASE_2:
            {
                if(nInstanceRoll <= 50)
                {
                    sInstanceKeyName = ColorText("Advanced " + sInstanceKeyName, LOOT_COLOR_GREEN);
                    SetLocalString(oInstanceKey, "LOOT_CATEGORY", "GREEN");
                }
                else
                {
                    sInstanceKeyName = ColorText("Lesser " + sInstanceKeyName, LOOT_COLOR_PURPLE);
                    SetLocalString(oInstanceKey, "LOOT_CATEGORY", "PURPLE");
                }
                break;
            }
            case CORMYREAN_WIPE_PHASE_3:
            {
                if(nInstanceRoll > 90) // 10% artifact
                {
                    sInstanceKeyName = ColorText("Artifact " + sInstanceKeyName, LOOT_COLOR_ARTIFACT);
                    SetLocalString(oInstanceKey, "LOOT_CATEGORY", "ARTIFACT");
                    //SetDescription(oInstanceKey, ColorText("Warning! Bosses with prime time flag will be despawned if you open this key at the wrong time.", TXT_COLOR_RED));
                }
                else if(nInstanceRoll > 45)
                {
                    sInstanceKeyName = ColorText("Greater " + sInstanceKeyName, LOOT_COLOR_RED);
                    SetLocalString(oInstanceKey, "LOOT_CATEGORY", "RED");
                }
                else
                {
                    sInstanceKeyName = ColorText("Lesser " + sInstanceKeyName, LOOT_COLOR_PURPLE);
                    SetLocalString(oInstanceKey, "LOOT_CATEGORY", "PURPLE");
                }
                break;
            }
            case CORMYREAN_WIPE_PHASE_4:
            {
                if(nInstanceRoll > 65) // 10% artifact
                {
                    sInstanceKeyName = ColorText("Artifact " + sInstanceKeyName, LOOT_COLOR_ARTIFACT);
                    SetLocalString(oInstanceKey, "LOOT_CATEGORY", "ARTIFACT");
                    //SetDescription(oInstanceKey, ColorText("Warning! Bosses with prime time flag will be despawned if you open this key at the wrong time.", TXT_COLOR_RED));
                }
                else
                {
                    sInstanceKeyName = ColorText("Greater " + sInstanceKeyName, LOOT_COLOR_RED);
                    SetLocalString(oInstanceKey, "LOOT_CATEGORY", "RED");
                }
                break;
            }
        }
        SetName(oInstanceKey, sInstanceKeyName);
        generic_PlayAudioStreamForPlayerArea(oCreature, "mus_holyshit");
    }
    else if(nMassCastRuneChance >= Random(10000) + 1)  // 0.05% - 3,0%
    {
        CreateLootOnObject(oCreature, LOOT_MOBS_LEVEL_08, 1, 0);
        generic_PlayAudioStreamForPlayerArea(oCreature, "mus_holyshit");
    }
    else if(bChampion)
        CreateLootOnObject(oCreature, nLootTier, 1, nChampGoldChance);

}

void GenerateBossTreasure()
{
    int i = 1;
    object oChest = GetNearestObjectByTag("boss_chest_" + IntToString(i));
    if (!GetIsObjectValid(oChest))
    {
        SendMessageToAllDMs("Error! First boss chest not found. Area: " + GetName(GetArea(OBJECT_SELF)));
        WriteTimestampedLogEntry("Error! First boss chest not found. Area: " + GetName(GetArea(OBJECT_SELF)));
        return;
    }
    WriteTimestampedLogEntry("Boss loot succesfully generated.");
    while (GetIsObjectValid(oChest))
    {
        i++;
        AssignCommand(oChest, PrepareChest(OBJECT_SELF));
        // gnome treasure
        if (GetLocalInt(oChest, "I_AM_GNOME_VAULT"))
            AssignCommand(oChest, DelayCommand(0.5, CreateGnomeTreasureGem(OBJECT_SELF)));
        // other boss treasures
        else
            AssignCommand(oChest,
                          DelayCommand(0.5, CreateLootOnObject(OBJECT_SELF, GetLocalInt(oChest, sLootTier), GetLocalInt(oChest, sItemAmountInChest),
                          GetLocalInt(oChest, sGoldChanceInChest), GetLocalInt(oChest, sFameChanceInChest),
                          GetLocalInt(oChest, sMaxFameInChest))));

        oChest = GetNearestObjectByTag("boss_chest_" + IntToString(i));
    }
}

void PrepareChest(object oChest)
{
    object oItem = GetFirstItemInInventory(oChest);
    while (GetIsObjectValid(oItem))
    {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oChest);
    }
    SetLocked(oChest, TRUE);
    //SetEventScript(oChest, EVENT_SCRIPT_PLACEABLE_ON_UNLOCK, "_on_place_unlock");
}

void CreateGnomeTreasureGem(object oChest)
{
    SetIdentified(CreateItemOnObject(CONST_ITEM_GNOME_GEM, oChest), TRUE);
}

void GenerateCustomGoldOnTarget(object oLootTarget, int nGoldValue, int nFaction = FACTION_UNKNOWN)
{
    object oGoldPiece = CreateItemOnObject(CONST_ITEM_GOLD, oLootTarget);
    if (GetIsObjectValid(oGoldPiece))
    {
        SetName(oGoldPiece, IntToString(nGoldValue) + "GP");
        SetIdentified(oGoldPiece, TRUE);
        SetDroppableFlag(oGoldPiece, TRUE);
        SetLocalInt(oGoldPiece, "GENERATED_GOLD_PIECE", nGoldValue);
        players_SetFaction(oGoldPiece, nFaction);
    }
}

void GenerateFameOnTarget(object oLootTarget, int nFameValue)
{
    object oFame = CreateItemOnObject(CONST_ITEM_FAME, oLootTarget);
    SetName(oFame, TXT_COLOR_RED + IntToString(nFameValue) + "FP" + TXT_COLOR_END);
    SetIdentified(oFame, TRUE);
    SetLocalInt(oFame, "GENERATED_FAME_POINTS", nFameValue);
}

void LootSeparator()
{
    int i = 0;
    object oSortedBlue          = GetObjectByTag(sSorceLootBossLevel_01); // blue
    object oSortedGreenWeapons  = GetObjectByTag(sSorceLootBossLevel_02); // green
    object oSortedGreenArmor    = GetObjectByTag(sSorceLootBossLevel_03);
    object oSortedGreenAll      = GetObjectByTag(sSorceLootBossLevel_04);
    object oSortedPurpleWeapons = GetObjectByTag(sSorceLootBossLevel_05); // purple
    object oSortedPurpleArmor   = GetObjectByTag(sSorceLootBossLevel_06);
    object oSortedPurpleAll     = GetObjectByTag(sSorceLootBossLevel_07);
    object oSortedRedWeapons    = GetObjectByTag(sSorceLootBossLevel_08); // red
    object oSortedRedArmor      = GetObjectByTag(sSorceLootBossLevel_09);
    object oSortedRedAll        = GetObjectByTag(sSorceLootBossLevel_10);
    object oSortedArtifacts     = GetObjectByTag(sSorceLootBossLevel_11); // artifacts

    object oSeparatorChest = GetObjectByTag("SEPARATOR_CHEST");
    string sResref = NWNX_Util_GetFirstResRef(NWNX_UTIL_RESREF_TYPE_ITEM, "^fl_.*_loot.*$");
    while(sResref != "")
    {
        //object oLoot = CreateObject(OBJECT_TYPE_ITEM, sResref, GetStartingLocation());
        object oLoot = CreateItemOnObject(sResref, oSeparatorChest);

        int nType = GetBaseItemType(oLoot);
        int bWeapon = StringToInt(Get2DAString("baseitems", "CritHitMult", nType));

        if(FindSubString(sResref, "fl_blue_") >= 0)
            DelayCommand(0.0, generic_MoveItem(oLoot, oSortedBlue, FALSE, FALSE));
        else if(FindSubString(sResref, "fl_grn_") >= 0)
        {
            if(bWeapon && nType != BASE_ITEM_MAGICSTAFF)
                CopyItem(oLoot, oSortedGreenWeapons, TRUE);
            else
                CopyItem(oLoot, oSortedGreenArmor, TRUE);
            DelayCommand(0.0, generic_MoveItem(oLoot, oSortedGreenAll, FALSE, FALSE));
        }
        else if(FindSubString(sResref, "fl_prpl_") >= 0 || FindSubString(sResref, "fl_red_") >= 0 && GetLocalInt(oLoot, "SORCERER_LOOT"))
        {
            if(bWeapon && nType != BASE_ITEM_MAGICSTAFF)
                CopyItem(oLoot, oSortedPurpleWeapons, TRUE);
            else
                CopyItem(oLoot, oSortedPurpleArmor, TRUE);
            DelayCommand(0.0, generic_MoveItem(oLoot, oSortedPurpleAll, FALSE, FALSE));
        }
        else if(FindSubString(sResref, "fl_red_") >= 0)
        {
            if(bWeapon && nType != BASE_ITEM_MAGICSTAFF)
                CopyItem(oLoot, oSortedRedWeapons, TRUE);
            else
                CopyItem(oLoot, oSortedRedArmor, TRUE);
            DelayCommand(0.0, generic_MoveItem(oLoot, oSortedRedAll, FALSE, FALSE));
        }
        else if(FindSubString(sResref, "fl_art_") >= 0)
        {
            DelayCommand(0.0, generic_MoveItem(oLoot, oSortedArtifacts, FALSE, FALSE));
        }
        sResref = NWNX_Util_GetNextResRef();
    }
}

void SetTimeStampValidation(object oBoss, int nUnixTime)
{
    // Keep the original fixed-key contracts of the three Herald bosses.
    string sHeraldResref = GetResRef(oBoss);
    if(sHeraldResref == "cr_hrldanger" || sHeraldResref == "cr_hrlddeath" || sHeraldResref == "cr_hrlddoom") return;
    // set timestamp for chests
    int i = 1;
    string sNewKeyTag = GetResRef(oBoss) + IntToString(nUnixTime);
    object oChest = GetNearestObjectByTag("boss_chest_" + IntToString(i));
    while(GetIsObjectValid(oChest))
    {
        //SetLocalInt(oChest, "LAST_BOSS_KILL_TIMESTAMP", nUnixTime);
        SetLockKeyTag(oChest, sNewKeyTag);
        oChest = GetNearestObjectByTag("boss_chest_" + IntToString(++i));
    }
    // deadcult base custom chest handler
    object oDeadCultChest = GetNearestObjectByTag("chest_dead_cult_base");
    if(GetIsObjectValid(oDeadCultChest))
        SetLockKeyTag(oDeadCultChest, sNewKeyTag);
    // set timestamp for keys
    object oItem = GetFirstItemInInventory(oBoss);
    while(GetIsObjectValid(oItem))
    {
        int nBaseItemType = GetBaseItemType(oItem);
        if(nBaseItemType == BASE_ITEM_KEY || FindSubString(GetResRef(oItem), "_key") >=0)
            SetTag(oItem, sNewKeyTag);
        oItem = GetNextItemInInventory(oBoss);
    }
}





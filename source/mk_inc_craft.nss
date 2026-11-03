// requires
#include "mk_inc_init"
#include "mk_inc_version"
#include "mk_inc_generic"
#include "x2_inc_craft"
#include "mk_inc_tools_s"
#include "mk_inc_editor"
#include "mk_inc_iaam"
#include "mk_inc_iaac"
#include "mk_inc_tlk"
#include "mk_inc_debug"

const int MK_IP_ITEMTYPE_NEXT = 0;
const int MK_IP_ITEMTYPE_PREV = 1;
const int MK_IP_ITEMTYPE_OPPOSITE = 2;
const int MK_IP_ITEMCOLOR_NEXT = 3;
const int MK_IP_ITEMCOLOR_PREV = 4;
const int MK_IP_ITEMTYPE_CLEAR = 5;

const int MK_IP_WEAPONCOLOR_NEXT = 3;
const int MK_IP_WEAPONCOLOR_PREV = 4;
const int MK_IP_WEAPONCOLOR_RESET = 5;

/*
// Defined in x2_inc_craft
//const int X2_CI_MODMODE_INVALID = 0;
//const int X2_CI_MODMODE_ARMOR = 1;
//const int X2_CI_MODMODE_WEAPON = 2;

const int MK_CI_MODMODE_CLOAK = 3;
const int MK_CI_MODMODE_HELMET = 4;
const int MK_CI_MODMODE_SHIELD = 5;
//const int MK_CI_MODMODE_CHARACTER = 255; // character description
const int MK_CI_MODMODE_CHARACTER = 8; // character description
const int MK_CI_MODMODE_BODY = 9;
//const int MK_CI_MODMODE_BODY = 127;      // modify body (used only for proper
                                         // abort dialog)
*/
#include "mk_inc_modmodes"

const int MK_TOKEN_PARTSTRING = 14422;
const int MK_TOKEN_PARTNUMBER = 14423;
const int MK_TOKEN_OPP_PART   = 14430;

const int MK_TOKEN_COLOR1 = 14424;
const int MK_TOKEN_COLOR2 = 14425;
const int MK_TOKEN_COLOR3 = 14426;
const int MK_TOKEN_COLOR4 = 14427;
const int MK_TOKEN_COLOR5 = 14428;
const int MK_TOKEN_COLOR6 = 14429;

const int MK_TOKEN_COPYFROM = 14410;
const int MK_TOKEN_DYEFROM = 14432;
const int MK_TOKEN_SOURCEITEM = 14433;
const int MK_TOKEN_MATERIAL = 14434;

const int MK_TOKEN_COLOR_CLOSE = 14435;
const int MK_TOKEN_COLOR_COLOR1 = 14436;
const int MK_TOKEN_COLOR_COLOR2 = 14437;
const int MK_TOKEN_COLOR_COLOR3 = 14438;
const int MK_TOKEN_COLOR_COLOR4 = 14439;
const int MK_TOKEN_COLOR_COLOR5 = 14480;

/*
const int MK_STATE_INVALID = 0;
const int MK_STATE_COPY = 1;
const int MK_STATE_MATERIAL = 2;
const int MK_STATE_CGROUP = 3;
const int MK_STATE_COLOR = 4;
const int MK_STATE_SELECTPART = 5;
const int MK_STATE_MODIFY = 6;
const int MK_STATE_SELECTMODE = 7;
const int MK_STATE_INIT = 8;
const int MK_STATE_DATABASE_1 = 9;
const int MK_STATE_DATABASE_2 = 10;
const int MK_STATE_DATABASE_3 = 11;
const int MK_STATE_DATABASE_4 = 12;
*/

/*
const int MK_ITEM_APPR_MODEL_LRSHOULDER = 19;
const int MK_ITEM_APPR_MODEL_LRBICEP = 20;
const int MK_ITEM_APPR_MODEL_LRFOREARM = 21;
const int MK_ITEM_APPR_MODEL_LRHAND = 22;
const int MK_ITEM_APPR_MODEL_LRTHIGH = 23;
const int MK_ITEM_APPR_MODEL_LRSHIN = 24;
const int MK_ITEM_APPR_MODEL_LRFOOT = 25;

const int MK_ITEM_APPR_ARMOR_NUM_MODELS = 26;
*/

// const int MK_TOKEN_MATERIAL = 14422;

const int MK_TOKEN_ITEMLIST = 14440;

// Token 14440-14461 for up to 22 color groups (176/8 = 22)
const int MK_TOKEN_COLORGROUP = 14440;

// Token 14462-14477 for up to 16 color names
const int MK_TOKEN_COLORNAME = 14462;

const int MK_TOKEN_NEWNAME = 14478;
const int MK_TOKEN_ORIGINALNAME = 14479;

// int MK_NUMBER_OF_COLOR_GROUPS = 22;

const string MK_VAR_CHARACTER_DESCRIPTION = "MK_CHARACTER_DESCRIPTION";

const string MK_TAG_TEMP_EFFECT = "MK_TAG_TEMP_EFFECT";

const string MK_LIGHTEFFECT_DURATION = "MK_LIGHTEFFECT_DURATION";

const string MK_PERPARTCOLORING = "MK_PERPARTCOLORING";

const string MK_O_CRAFT_MODIFY_MIRROR = "MK_O_CRAFT_MODIFY_MIRROR";

const string MK_MODIFYITEM_USECONTAINER = "MK_MODIFYITEM_USECONTAINER";

const string MK_MODIFYITEM_CURRENTITEMMODIFIED = "MK_MODIFYITEM_CURRENTITEMMODIFIED";

const string MK_MODIFYITEM_DEACTIVATE_MIRRORUPDATE = "MK_MODIFYITEM_DEACTIVATE_MIRRORUPDATE";

const string MK_COLOR_HIGHLIGHT = "<cюҐ >";
const string MK_COLOR_CLOSE = "</c>";

// Colors per group
// int MK_NUMBER_OF_COLORS_PER_GROUP = (176 / MK_NUMBER_OF_COLOR_GROUPS);

/*
// ----------------------------------------------------------------------------
// On client/server with servervault characters forcing the client to quit
// when modifying an item will create a dupe item. This function removes that
// dupe. It should be called from the OnClientEnter script:
//
//      MK_craft_remove_dupe(GetEnteringObject());
//
// it cycles through the item slots of oPlayer and removes the items with
//    GetLocalInt(oItem, MK_CRRAFTING_DUPE) == 1
// also it cycles through the inventory and equips the item with
//    GetLocalInt(oItem, MK_CRAFTING_BACKUP) > 0
//
// In single player or on a server with local characters allowed this is not
// required because the character and the dupe are lost on a crash.
// ----------------------------------------------------------------------------
int MK_craft_remove_dupe(object oPlayer);
*/

// ----------------------------------------------------------------------------
// Reads the current mod part and returns its name (as it is set in the custom
// token XP_IP_ITEMMODCONVERSATION_CTOKENBASE)
// ----------------------------------------------------------------------------
string MK_CurrentModPart2PartName(object oPC);

// ----------------------------------------------------------------------------
// Reads a string from a 2DA file, if it does not exist it reads from DefaultColumn
// ----------------------------------------------------------------------------
string MK_Get2DAStringEx(string s2DA, string sColumn, int nRow, string sDefaultColumn="");

// ----------------------------------------------------------------------------
// Returns the color name for cloth/leather color iColor
// - iColor (0..63)
// Taken from Mandragon's Dye Kit
// ----------------------------------------------------------------------------
string MK_ClothColor(int iColor);

// ----------------------------------------------------------------------------
// Returns the color name (if iColor between 0 and 63) for cloth/leather color
// iColor plus the color number in brackets
// Example 'Light Blue (24)'
// - iColor (0..176)
// ----------------------------------------------------------------------------
string MK_ClothColorEx(int iColor, int bDisplayNumber = TRUE);

string MK_ColorEx(int iMaterial, int iColor, int bDisplayNumber = TRUE);

// ----------------------------------------------------------------------------
// Returns the color name for metal color iColor
// - iColor (0..63)
// Taken from Mandragon's Dye Kit
// ----------------------------------------------------------------------------
string MK_MetalColor(int iColor);

// ----------------------------------------------------------------------------
// Returns the color name (if iColor between 0 and 63) for metal color
// iColor plus the color number in brackets
// Example 'Lightest Gold (8)'
// - iColor (0..176)
// ----------------------------------------------------------------------------
string MK_MetalColorEx(int iColor, int bDisplayNumber = TRUE);

// ----------------------------------------------------------------------------
// Uses 'CIGetCurrentModItem' to get the current item to be dyed.
// Then the script changes the color of layer iMaterialToDye to iColor.
// Finally the item is equipped again (if bEquipItem=TRUE).
// ----------------------------------------------------------------------------
void MK_DyeItem(object oPC, int nMaterialToDye, int nColor);

// ----------------------------------------------------------------------------
// Prints the colors of oItem.
// ----------------------------------------------------------------------------
void MK_DisplayColors(object oPC, object oItem);

// ----------------------------------------------------------------------------
// Gets the new armor appearance type of oArmor
// - nPart
//      ITEM_APPR_ARMOR_MODEL_*
//   nMode
//      X2_IP_ARMORTYPE_PREV
//      X2_IP_ARMORTYPE_NEXT
// ----------------------------------------------------------------------------
int MK_GetArmorAppearanceType2(object oArmor, int nPart, int nMode);

// ----------------------------------------------------------------------------
// Returns the new armor with nPart modified
// - nPart
//      ITEM_APPR_ARMOR_MODEL_*
//   nMode
//      X2_IP_ARMORTYPE_PREV
//      X2_IP_ARMORTYPE_NEXT
// ----------------------------------------------------------------------------
object MK_GetModifiedArmor(object oArmor, int nPart, int nMode, int bDestroyOldOnSuccess);


// ----------------------------------------------------------------------------
// Returns the new weapon with nPart modified
// - nPart
//      ITEM_APPR_WEAPON_MODEL_*
//      ITEM_APPR_WEAPON_COLOR_*
//   nMode
//      MK_IP_ITEMTYPE_NEXT
//      MK_IP_ITEMTYPE_PREV
//      MK_IP_ITEMCOLOR_NEXT
//      MK_IP_ITEMCOLOR_PREV
// ----------------------------------------------------------------------------
object MK_GetModifiedWeapon(object oWeapon, int nPart, int nMode, int bDestroyOldOnSuccess);

// ----------------------------------------------------------------------------
// Returns the inventory slot of the current item
// ----------------------------------------------------------------------------
int MK_GetCurrentInventorySlot(object oPC);

// ----------------------------------------------------------------------------
// Gets the new cloak appearance type of oCloak
// - nMode
//      MK_IP_CLOAKTYPE_PREV
//      MK_IP_CLOAKTYPE_NEXT
// ----------------------------------------------------------------------------
int MK_GetCloakAppearanceType(object oCloak, int nPart, int nMode);

// ----------------------------------------------------------------------------
// Returns a new cloak based of oCloak with the model modified
// nMode -
//          MK_IP_CLOAKTYPE_NEXT    - next valid appearance
//          MK_IP_CLOAKTYPE_PREV    - previous valid apperance;
// bDestroyOldOnSuccess - Destroy oArmor in process?
// ----------------------------------------------------------------------------
object MK_GetModifiedCloak(object oCloak, int nPart, int nMode, int bDestroyOldOnSuccess);

// ----------------------------------------------------------------------------
// Returns a new helm based of oHelmet with the model modified
// nMode -
//          MK_IP_HELMTYPE_NEXT    - next valid appearance
//          MK_IP_HELMTYPE_PREV    - previous valid apperance;
// bDestroyOldOnSuccess - Destroy oArmor in process?
// ----------------------------------------------------------------------------
object MK_GetModifiedHelmet(object oHelmet, int nMode, int bDestroyOldOnSuccess);

// ----------------------------------------------------------------------------
// Copies the appearance of item oSource to item oDest
//
// iType                            iIndex
// ITEM_APPR_TYPE_SIMPLE_MODEL      [Ignored]
// ITEM_APPR_TYPE_WEAPON_COLOR      ITEM_APPR_WEAPON_COLOR_*
// ITEM_APPR_TYPE_WEAPON_MODEL      ITEM_APPR_WEAPON_MODEL_*
// ITEM_APPR_TYPE_ARMOR_MODEL       ITEM_APPR_ARMOR_MODEL_*
// ITEM_APPR_TYPE_ARMOR_COLOR       ITEM_APPR_ARMOR_COLOR_*
//
// Script (idea) taken from a script posted by John Bye
// ----------------------------------------------------------------------------
object MK_MatchItem(object oDest, object oSource, int nType, int nIndex);


// ----------------------------------------------------------------------------
// Script (idea) taken from a script posted by John Bye
// ----------------------------------------------------------------------------
object MK_ModifyCloakModel(object oPC, object oItem, int nNewValue);

// ----------------------------------------------------------------------------
// returns TRUE if the item is modified
// ----------------------------------------------------------------------------
int MK_GetIsModified(object oItem, object oBackup);

// ----------------------------------------------------------------------------
// returns TRUE if the item is a weapon and if it can be modified
// Slings and whips are 1 part items and can't be modified.
// ----------------------------------------------------------------------------
int MK_GetIsModifiableWeapon(object oItem);

// ----------------------------------------------------------------------------
// returns TRUE if the item is a shield
// ----------------------------------------------------------------------------
int MK_GetIsShield(object oItem);

// ----------------------------------------------------------------------------
// returns TRUE if it is allowed to modify the item
// ----------------------------------------------------------------------------
int MK_GetIsAllowedToModifyItem(object oPC, object oItem);

// ----------------------------------------------------------------------------
// initializes the RenameItem dialog
// ----------------------------------------------------------------------------
void MK_InitializeRenameItem(object oPC, object oItem);

// ----------------------------------------------------------------------------
// initializes the EditDescription dialog
// ----------------------------------------------------------------------------
void MK_InitializeEditDescription(object oPC, object oObject);

// ----------------------------------------------------------------------------
// prepares the editor
// ----------------------------------------------------------------------------
void MK_PrepareEditor(object oPC, int nEditorID, string sHeadLine="",
    int nMaxLength=-1, int bSingleLine=FALSE, int bDisableColors=FALSE,
    int bUseChatEvent=FALSE);


// ----------------------------------------------------------------------------
// sets custom token 14410, 14411, ... to the current item type name
// (armor, weapon, cloak, helmet or shield)
// used in the crafting dialog
// ----------------------------------------------------------------------------
void MK_SetCustomTokenByItemTypeName(object oPC);


// ----------------------------------------------------------------------------
// special version of CopyItem that also copies a modified description
// ----------------------------------------------------------------------------
object MK_CopyItem(object oItem, object oTargetInventory=OBJECT_INVALID, int bCopyVars=TRUE);

// ----------------------------------------------------------------------------
// special version of CopyItemAndModify that also copies a modified description
// ----------------------------------------------------------------------------
object MK_CopyItemAndModify(object oItem, int nType, int nIndex, int nNewValue, int bCopyVars=TRUE, int nStoreValueOnItem=FALSE);


// ----------------------------------------------------------------------------
// return the number of colors used for that mod mode
// ----------------------------------------------------------------------------
int MK_GetNumColorsFromModMode(int nModMode);

// ----------------------------------------------------------------------------
// return the item appearance, work-around for per-part coloring
// ----------------------------------------------------------------------------
int MK_GetItemAppearance2(object oItem, int nType, int nIndex, int nIndex2=-1);


// ----------------------------------------------------------------------------
// return the item's color, calculates index in case of per-part coloring
// ----------------------------------------------------------------------------
int MK_GetItemColor(object oPC, object oItem, int nType, int nIndex);

// ----------------------------------------------------------------------------
// calculates color index for per-part coloring
// ----------------------------------------------------------------------------
int MK_CalculateColorIndex(int nIndex, int nPart);


object MK_CopyColor(object oDest, object oSource, int bCopyOverrideColors=FALSE);

void MK_StartModifyItem(object oPC, object oItem, int bUseContainer=FALSE, int bCreateMirror=TRUE);

void MK_EquipModifiedItem(object oPC);

void MK_CancelModifyItem(object oPC);

void MK_FinishModifyItem(object oPC);

void MK_SetAppearanceValue(object oItem, int nType, int nIndex, int nValue);

int MK_GetAppearanceValue(object oItem, int nType, int nIndex);

int MK_GetIsPerPartColored(object oItem, int nType, int nIndex, int nPart);

int MK_ModPart2StrRef(int nModPart);

//void MK_SetCurrentModParts(object oPC, int nPart1, int nPart2);

void MK_SetCurrentModPart(object oPC, int nPart, int bSetCamera=TRUE);

int MK_GetCurrentModPart(object oPC);

int MK_GetItemAppearance(object oItem, int nType, int nIndex);

//int MK_GetCurrentModPart1(object oPC);

//int MK_GetCurrentModPart2(object oPC);

//void MK_SetCurrentModPart1(object oPC, int nPart);

//void MK_SetCurrentModPart2(object oPC, int nPart);

void MK_SetCurrentModMirror(object oPC, object oItem);

object MK_GetCurrentModMirror(object oPC);

void MK_SetModifyItemUseContainer(object oPC, int bUseContainer);

int MK_GetModifyItemUseContainer(object oPC);

void MK_SetCurrentItemIsModified(object oPC, int bModified=TRUE);

void MK_SetItemIsModified(object oItem, int bModified=TRUE);

int MK_GetCurrentItemIsModified(object oPC, int bReset=TRUE);

int MK_DeactivateMirrorUpdate(object oPC, int bDeactivate, int bUpdateMirror=TRUE);

int MK_GetUpdateMirror(object oPC);

void MK_VerifyCurrentModItem(object oPC, string s);

void MK_SetMaterialToken(int nMaterial);

int MK_GetHiddenWhenEquipped(object oItem)
{
    return GetHiddenWhenEquipped(oItem);
}

void MK_SetHiddenWhenEquipped(object oItem, int nValue)
{
    if (MK_VERSION_GetIsVersionGreaterEqual_1_74())
    {
        SetHiddenWhenEquipped(oItem, nValue);
    }
}


int MK_GetIsPerPartColoring(object oPC)
{
    return GetLocalInt(oPC, MK_PERPARTCOLORING);
}

void MK_SetMaterialToken(int nMaterial)
{
/*
    string sToken="";
    switch (nMaterial)
    {
    case ITEM_APPR_ARMOR_COLOR_LEATHER1:
        sToken = "Leather 1";
        break;
    case ITEM_APPR_ARMOR_COLOR_LEATHER2:
        sToken = "Leather 2";
        break;
    case ITEM_APPR_ARMOR_COLOR_CLOTH1:
        sToken = "Cloth 1";
        break;
    case ITEM_APPR_ARMOR_COLOR_CLOTH2:
        sToken = "Cloth 2";
        break;
    case ITEM_APPR_ARMOR_COLOR_METAL1:
        sToken = "Metal 1";
        break;
    case ITEM_APPR_ARMOR_COLOR_METAL2:
        sToken = "Metal 2";
        break;
    }
*/
    string sToken = MK_IAAC_GetName(nMaterial);
    SetCustomToken(MK_TOKEN_MATERIAL, sToken);
}

int MK_DeactivateMirrorUpdate(object oPC, int bDeactivate, int bUpdateMirror)
{
//    MK_DEBUG_TRACE("MK_DeactivateMirrorUpdate(bDeactivate="+IntToString(bDeactivate)
//                                                 +",bUpdateMirror="+IntToString(bUpdateMirror));

    if (!MK_GetModifyItemUseContainer(oPC)) return FALSE;
    if (bDeactivate)
    {
        SetLocalInt(oPC, MK_MODIFYITEM_DEACTIVATE_MIRRORUPDATE, bDeactivate);
    }
    else
    {
        DeleteLocalInt(oPC, MK_MODIFYITEM_DEACTIVATE_MIRRORUPDATE);
        if (bUpdateMirror)
        {
            MK_EquipModifiedItem(oPC);
        }
    }
    return TRUE;
}

int MK_GetUpdateMirror(object oPC)
{
    if (!MK_GetModifyItemUseContainer(oPC))
    {
        return FALSE;
    }
    return !GetLocalInt(oPC, MK_MODIFYITEM_DEACTIVATE_MIRRORUPDATE);
}

void MK_SetItemIsModified(object oItem, int bModified)
{
    if (GetIsObjectValid(oItem))
    {
        if (bModified)
        {
            SetLocalInt(oItem, MK_MODIFYITEM_CURRENTITEMMODIFIED, TRUE);
        }
        else
        {
            DeleteLocalInt(oItem, MK_MODIFYITEM_CURRENTITEMMODIFIED);
        }
    }
}

void MK_SetCurrentItemIsModified(object oPC, int bModified)
{
    MK_SetItemIsModified(CIGetCurrentModItem(oPC));
}

int MK_GetCurrentItemIsModified(object oPC, int bReset)
{
    int bModified=FALSE;
    object oItem = CIGetCurrentModItem(oPC);
    if (GetIsObjectValid(oItem))
    {
        bModified = GetLocalInt(oItem, MK_MODIFYITEM_CURRENTITEMMODIFIED);
        if (bReset)
        {
            DeleteLocalInt(oItem, MK_MODIFYITEM_CURRENTITEMMODIFIED);
        }
    }
    return bModified;
}

void MK_SetModifyItemUseContainer(object oPC, int bUseContainer)
{
    SetLocalInt(oPC, MK_MODIFYITEM_USECONTAINER, bUseContainer);
}

int MK_GetModifyItemUseContainer(object oPC)
{
    return GetLocalInt(oPC, MK_MODIFYITEM_USECONTAINER);
}

void MK_SetCurrentModMirror(object oPC, object oItem)
{
    if (GetIsObjectValid(oItem))
    {
        SetItemCursedFlag(oItem, TRUE);
        SetLocalObject(oPC, MK_O_CRAFT_MODIFY_MIRROR, oItem);
    }
    else
    {
        DeleteLocalObject(oPC, MK_O_CRAFT_MODIFY_MIRROR);
    }
}

object MK_GetCurrentModMirror(object oPC)
{
    return GetLocalObject(oPC, MK_O_CRAFT_MODIFY_MIRROR);
}


void MK_CopyItemFlags(object oSource, object oDestination)
{
    string sDescription = GetDescription(oSource);
    if (GetDescription(oDestination)!=sDescription)
    {
        MK_DEBUG_TRACE("CopyItem: description copied manually!");
        SetDescription(oDestination, sDescription);
    }
    int nItemCursedFlag = GetItemCursedFlag(oSource);
    if (GetItemCursedFlag(oDestination)!=nItemCursedFlag)
    {
        MK_DEBUG_TRACE("CopyItem: cursed flag copied manually!");
        SetItemCursedFlag(oDestination, nItemCursedFlag);
    }
    int nPlotFlag = GetPlotFlag(oSource);
    if (GetPlotFlag(oDestination)!=nPlotFlag)
    {
        MK_DEBUG_TRACE("CopyItem: plot flag copied manually!");
        SetPlotFlag(oDestination, nPlotFlag);
    }
    int nHiddenWhenEquipped = MK_GetHiddenWhenEquipped(oSource);
    if (MK_GetHiddenWhenEquipped(oDestination)!=nHiddenWhenEquipped)
    {
        MK_DEBUG_TRACE("CopyItem: hidden when equipped flag copied manually!");
        MK_SetHiddenWhenEquipped(oDestination, nHiddenWhenEquipped);
    }
}

object MK_CopyItem(object oItem, object oTargetInventory, int bCopyVars)
{
    if (!GetIsObjectValid(oItem))
    {
        return OBJECT_INVALID;
    }
    object oCopy = CopyItem(oItem, oTargetInventory, bCopyVars);
    if (!GetIsObjectValid(oCopy))
    {
        return OBJECT_INVALID;
    }
    MK_CopyItemFlags(oItem, oCopy);

    return oCopy;
}

object MK_CopyItemAndModify(object oItem, int nType, int nIndex, int nNewValue, int bCopyVars, int nStoreValueOnItem)
{
//    MK_DEBUG_TRACE("MK_CopyItemAndModify(name="+GetName(oItem)
//        +", nType="+IntToString(nType)+", nIndex="+IntToString(nIndex)+", nNewValue="+IntToString(nNewValue)
//        +", bCopyVars="+IntToString(bCopyVars)+", nStoreValueOnItem="+IntToString(nStoreValueOnItem)+")");
    if (!GetIsObjectValid(oItem))
    {
        return OBJECT_INVALID;
    }
//    MK_DEBUG_TRACE("> original item is possessed by '"+GetName(GetItemPossessor(oItem))+"'.");
//    if (GetLocalInt(oItem, "MK_MIRRORITEM"))
//    {
//        MK_DEBUG_TRACE("> ORIGINAL ITEM IS MIRROR ITEM!");
//    }

    object oCopy = CopyItemAndModify(oItem, nType, nIndex, nNewValue, bCopyVars);
    if (!GetIsObjectValid(oCopy))
    {
        return OBJECT_INVALID;
    }
    MK_SetItemIsModified(oCopy, TRUE);
//    MK_DEBUG_TRACE("> new item is possessed by '"+GetName(GetItemPossessor(oCopy))+"'.");

    MK_CopyItemFlags(oItem, oCopy);
    if ((nType == ITEM_APPR_TYPE_ARMOR_COLOR) && nStoreValueOnItem && (nIndex>=ITEM_APPR_ARMOR_NUM_COLORS))
    {
        MK_SetAppearanceValue(oCopy, nType, nIndex, nNewValue);
    }
    return oCopy;
}

/*
const int MK_CUSTOMTOKEN_PREFIX_NONE = 0;
const int MK_CUSTOMTOKEN_PREFIX_YOUR = 1;
const int MK_CUSTOMTOKEN_PREFIX_THE = 2;
*/

void MK_SetCustomTokenByItemTypeName(object oPC)
{
    int nModMode = CIGetCurrentModMode(oPC);
    string sToken="";

    string s2DAFile = "mk_modmode";
    int nCol;
    string sColumn;
    int nStrRef;
    int nGender = GetGender(oPC);
    int bOk = TRUE;
    for (nCol=0; bOk; nCol++)
    {
        sColumn = "StrRef"+IntToString(nCol);
        nStrRef = MK_Get2DAInt(s2DAFile, sColumn, nModMode);
        sToken = MK_TLK_GetStringByStrRef(nStrRef, nGender);
        SetCustomToken(MK_TOKEN_COPYFROM+nCol, sToken);
        bOk = (nCol<20) && (nStrRef!=0);
    }
/*
    switch (nModMode)
    {
    case MK_CI_MODMODE_CHARACTER:
        nStrRef = (nPrefix ? -46 : -6);
//        sToken = "character";
        break;
    case X2_CI_MODMODE_ARMOR:
        nStrRef = (nPrefix ? -41 : -1);
//        sToken = "armor";
        break;
    case X2_CI_MODMODE_WEAPON:
        nStrRef = (nPrefix ? -42 : -2);
//        sToken = "weapon";
        break;
    case MK_CI_MODMODE_CLOAK:
        nStrRef = (nPrefix ? -43 : -3);
//        sToken = "cloak";
        break;
    case MK_CI_MODMODE_HELMET:
        nStrRef = (nPrefix ? -44 : -4);
//        sToken = "helmet";
        break;
    case MK_CI_MODMODE_SHIELD:
        nStrRef = (nPrefix ? -45 : -5);
//        sToken = "shield";
        break;
    }
    sToken = MK_TLK_GetStringByStrRef(nStrRef, GetGender(oPC));
    SetCustomToken(MK_TOKEN_COPYFROM, sToken);
*/
}

int MK_GetIsAllowedToModifyItem(object oPC, object oItem)
{
    if (!GetIsObjectValid(oPC))
    {
        return FALSE;
    }
    if (!GetIsObjectValid(oItem))
    {
        return FALSE;
    }
    if (GetLocalInt(GetModule(),"X2_L_DO_NOT_ALLOW_MODIFY_ARMOR"))
    {
        return FALSE;
    }
    if (GetPlotFlag(oItem) && (GetLocalInt(oPC,"MK_ENABLE_MODIFY_PLOT_ITEMS")==0))
    {
        return FALSE;
    }
    return TRUE;
}

int MK_GetIsSameArmorAppearance(object oItem, object oBackup)
{
    int bIsSameApp=TRUE;
    int iPart;
    for (iPart=0; (bIsSameApp)&&(iPart<ITEM_APPR_ARMOR_NUM_MODELS); iPart++)
    {
        bIsSameApp =
            (GetItemAppearance(oItem,ITEM_APPR_TYPE_ARMOR_MODEL,iPart) ==
                GetItemAppearance(oBackup,ITEM_APPR_TYPE_ARMOR_MODEL,iPart));
    }
    return bIsSameApp;
}

int MK_GetIsSameWeaponAppearance(object oItem, object oBackup)
{
    int bIsSameApp=TRUE;
    int iPart;
    for (iPart=ITEM_APPR_WEAPON_MODEL_BOTTOM; (bIsSameApp) && (iPart<=ITEM_APPR_WEAPON_MODEL_TOP); iPart++)
    {
        bIsSameApp =
            (GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, iPart) ==
                GetItemAppearance(oBackup, ITEM_APPR_TYPE_WEAPON_MODEL, iPart));
    }
    for (iPart=ITEM_APPR_WEAPON_COLOR_BOTTOM; (bIsSameApp) && (iPart<=ITEM_APPR_WEAPON_COLOR_TOP); iPart++)
    {
        bIsSameApp =
            (GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, iPart) ==
                GetItemAppearance(oBackup, ITEM_APPR_TYPE_WEAPON_COLOR, iPart));
    }
    return bIsSameApp;
}

int MK_GetIsSameSimpleAppearance(object oItem, object oBackup)
{
    int bIsSameAppearance =
        (GetItemAppearance(oItem,ITEM_APPR_TYPE_SIMPLE_MODEL,0) ==
            GetItemAppearance(oBackup,ITEM_APPR_TYPE_SIMPLE_MODEL,0));
    return bIsSameAppearance;
}

int MK_GetIsSameColor(object oItem, object oBackup)
{
    int bIsSameColor=TRUE;
    int iMaterial;
    int iPart;
//    int nEEFeaturesDisabled = MK_INIT_GetAreEEFeaturesDisabled();
    int nVersion_GE_1_74 = MK_VERSION_GetIsVersionGreaterEqual_1_74();

    for (iMaterial=0; (bIsSameColor)&&(iMaterial<ITEM_APPR_ARMOR_NUM_COLORS); iMaterial++)
    {
        bIsSameColor =
            (GetItemAppearance(oItem,ITEM_APPR_TYPE_ARMOR_COLOR,iMaterial) ==
                GetItemAppearance(oBackup,ITEM_APPR_TYPE_ARMOR_COLOR,iMaterial));

        if (nVersion_GE_1_74)
        {
            for (iPart=0; (bIsSameColor)&&(iPart < ITEM_APPR_ARMOR_NUM_MODELS); iPart++)
            {
                bIsSameColor =
                    (MK_GetItemAppearance2(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterial, iPart) ==
                     MK_GetItemAppearance2(oBackup, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterial, iPart));
            }
        }
    }
    return bIsSameColor;
}

int MK_GetIsModified(object oItem, object oBackup)
{
    int bIsModified = FALSE;

    int nBaseType = GetBaseItemType(oItem);
    int i;
    switch (nBaseType)
    {
    case BASE_ITEM_ARMOR:
        bIsModified =
            !(MK_GetIsSameColor(oItem, oBackup) &&
                MK_GetIsSameArmorAppearance(oItem, oBackup));
        break;
    case BASE_ITEM_CLOAK:
    case BASE_ITEM_HELMET:
        bIsModified =
            !(MK_GetIsSameColor(oItem, oBackup) &&
                MK_GetIsSameSimpleAppearance(oItem, oBackup));
        break;
    case BASE_ITEM_SMALLSHIELD:
    case BASE_ITEM_LARGESHIELD:
    case BASE_ITEM_TOWERSHIELD:
        bIsModified = (!MK_GetIsSameSimpleAppearance(oItem, oBackup));
        break;
    default:
        bIsModified = (!MK_GetIsSameWeaponAppearance(oItem, oBackup));
        break;
    }
    if (!bIsModified)
    {
        bIsModified = (MK_GetHiddenWhenEquipped(oItem)!=MK_GetHiddenWhenEquipped(oBackup));
    }

    if (!bIsModified)
    {
        bIsModified = (GetName(oItem)!=GetName(oBackup));
    }
    if (!bIsModified)
    {
        bIsModified = (GetDescription(oItem)!=GetDescription(oBackup));
    }
    return bIsModified;
}

/*
void MK_InitColorTokens()
{
    SetCustomToken(14435, "</c>"); // CLOSE tag
    SetCustomToken(14436, "<cюҐ >"); // orange (highlight)
    SetCustomToken(14437, "<cю ю>"); // magenta (back)
    SetCustomToken(14438, "<c їю>"); // deepskyblue (model name/number)
    SetCustomToken(14439, "<cюю >"); // yellow (make changes)
}
*/

int MK_GetCurrentInventorySlot(object oPC)
{
    int nModMode = CIGetCurrentModMode(oPC);
    return (nModMode!=-1 ? MK_Get2DAInt("mk_modmode", "INVENTORY_SLOT", nModMode) : -1);
/*    int nInventorySlot=0;

    switch (CIGetCurrentModMode(oPC))
    {
    case X2_CI_MODMODE_ARMOR:
        nInventorySlot = INVENTORY_SLOT_CHEST;
        break;
    case X2_CI_MODMODE_WEAPON:
        nInventorySlot = INVENTORY_SLOT_RIGHTHAND;
        break;
    case MK_CI_MODMODE_CLOAK:
        nInventorySlot = INVENTORY_SLOT_CLOAK;
        break;
    case MK_CI_MODMODE_HELMET:
        nInventorySlot = INVENTORY_SLOT_HEAD;
        break;
    case MK_CI_MODMODE_SHIELD:
        nInventorySlot = INVENTORY_SLOT_LEFTHAND;
        break;
    default:
        nInventorySlot = -1;
    }
    return nInventorySlot;*/
}

// copied from 'string ZEP_ListReverse(string s)'
string MK_ListReverse(string s) {
    string sCache;
    int n;
    int l = GetStringLength(s);
    s = GetSubString(s, 1, l);
    while (s!="") {
        // take string upto next seperator and put this in front of cache
        n = FindSubString(s, ":")+1;
        sCache = GetStringLeft(s, n) + sCache;
        s = GetSubString(s, n, l);
    }
    return ":"+sCache;
}

int MK_GetOppositePart(int nPart)
{
    return MK_IAAM_GetOpposite(nPart);
}
/*
int MK_GetOppositePart(int nPart)
{
    int nOppositePart=0;
    switch (nPart)
    {
    case ITEM_APPR_ARMOR_MODEL_LSHOULDER:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RSHOULDER;
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHOULDER:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LSHOULDER;
        break;
    case ITEM_APPR_ARMOR_MODEL_LBICEP:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RBICEP;
        break;
    case ITEM_APPR_ARMOR_MODEL_RBICEP:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LBICEP;
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOREARM:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RFOREARM;
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOREARM:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LFOREARM;
        break;
    case ITEM_APPR_ARMOR_MODEL_LHAND:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RHAND;
        break;
    case ITEM_APPR_ARMOR_MODEL_RHAND:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LHAND;
        break;
    case ITEM_APPR_ARMOR_MODEL_LTHIGH:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RTHIGH;
        break;
    case ITEM_APPR_ARMOR_MODEL_RTHIGH:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LTHIGH;
        break;
    case ITEM_APPR_ARMOR_MODEL_LSHIN:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RSHIN;
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHIN:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LSHIN;
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOOT:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_RFOOT;
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOOT:
        nOppositePart = ITEM_APPR_ARMOR_MODEL_LFOOT;
        break;
    }
    return nOppositePart;

}
*/

int MK_HasOppositePart(int nPart)
{
    int nReturn = FALSE;
    int nOpposite = MK_IAAM_GetOpposite(nPart);
    if (nOpposite!=-1)
    {
        string s;
        int nStrRef = MK_IAAM_GetStrRef(nOpposite);
        if (nStrRef!=-1)
        {
            s = GetStringByStrRef(nStrRef);
        }
        SetCustomToken(MK_TOKEN_OPP_PART, s);
        nReturn = TRUE;
    }
    return nReturn;
}

/*
int MK_HasOppositePart(int nPart)
{
    int nStrRef=0;
    switch (nPart)
    {
    case ITEM_APPR_ARMOR_MODEL_LSHOULDER:
        nStrRef=7146;
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHOULDER:
        nStrRef=7150;
        break;
    case ITEM_APPR_ARMOR_MODEL_LBICEP:
        nStrRef=7147;
        break;
    case ITEM_APPR_ARMOR_MODEL_RBICEP:
        nStrRef=7151;
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOREARM:
        nStrRef=7148;
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOREARM:
        nStrRef=7152;
        break;
    case ITEM_APPR_ARMOR_MODEL_LHAND:
        nStrRef=7149;
        break;
    case ITEM_APPR_ARMOR_MODEL_RHAND:
        nStrRef=7153;
        break;
    case ITEM_APPR_ARMOR_MODEL_LTHIGH:
        nStrRef=83351;
        break;
    case ITEM_APPR_ARMOR_MODEL_RTHIGH:
        nStrRef=83350;
        break;
    case ITEM_APPR_ARMOR_MODEL_LSHIN:
        nStrRef=83349;
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHIN:
        nStrRef=83348;
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOOT:
        nStrRef=83346;
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOOT:
        nStrRef=83345;
        break;
    }

    int nResult = FALSE;
    string s = "";

    if (nStrRef>0)
    {
        s = GetStringByStrRef(nStrRef);
        nResult = TRUE;
    }
    SetCustomToken(MK_TOKEN_OPP_PART, s);

    return nResult;
}
*/

/*
//copied from 'string ZEP_PreReadArmorACList(string sAC)'
string MK_PreReadArmorACList(string sAC)
{
    // pick the right 2da to read the parts from
    string s2DA = "parts_chest";
    string sCache= ":";
    string sLine;

    int nMax = 255;
    int n=1;
    sAC = GetStringLeft(sAC, 1);
    while (n<=nMax) {
        // Verify validity of the ID and add to the list
        sLine = Get2DAString(s2DA, "ACBONUS", n);
        if (GetStringLeft(sLine, 1)==sAC)
        {
            sCache+= IntToString(n)+":";
        }
        n++;
    }
    // Store the list in a modulestring, once normal, once reversed, both with ID 0 added as first index for cycling
    SetLocalString(GetModule(), "MK_IDPreReadAC_"+GetStringLeft(sAC,1), sCache);
    SetLocalString(GetModule(), "MK_IDPreReadACR_"+GetStringLeft(sAC,1), MK_ListReverse(sCache));

    return GetLocalString(GetModule(), "MK_IDPreReadAC_"+GetStringLeft(sAC,1));
}
*/


string MK_GetParts2DAfile(int nPart)
{
    return MK_IAAM_GetParts2DAfile(nPart);
}

int MK_GetPartsMaxID(int nPart)
{
    return MK_IAAM_GetPartsMaxID(nPart);
}

/*
// - private -
// Prereads the 2da-file for nPart and puts all used ID's in a : seperated stringlist
string MK_PreReadArmorPartList(int nPart) {
    // pick the right 2da to read the parts from
    string s2DA = MK_GetParts2DAfile(nPart);

    string sCache= ":";
    string sLine;
    int nMax = 255;
    int n=1;
    while (n<=nMax) {
        // Verify validity of the ID and add to the list
        sLine = Get2DAString(s2DA, "ACBONUS", n);
        if (sLine!="")
        {
            sCache+= IntToString(n)+":";
//            MK_DEBUG_TRACE("MK_PreReadArmorPartList: n="+IntToString(n)+", sLine='"+sLine+"', sCache='"+sCache+"'");
        }
        n++;
    }
    // Store the list in a modulestring, once normal, once reversed, both with ID 0 added as first index for cycling
    SetLocalString(GetModule(), "MK_IDPreRead_"+IntToString(nPart), ":0"+sCache);
    SetLocalString(GetModule(), "MK_IDPreReadR_"+IntToString(nPart), ":0"+MK_ListReverse(sCache));

//    MK_DEBUG_TRACE("MK_PreReadArmorPartList: MK_IDPreRead_"+IntToString(nPart)+"='"+GetLocalString(GetModule(),"MK_IDPreRead_"+IntToString(nPart)));
//    MK_DEBUG_TRACE("MK_PreReadArmorPartList: MK_IDPreReadR_"+IntToString(nPart)+"='"+GetLocalString(GetModule(),"MK_IDPreReadR_"+IntToString(nPart)));
    return GetLocalString(GetModule(),"MK_IDPreRead_"+IntToString(nPart));
}
*/


// - private -
// Prereads the 2da-file for nPart and puts all used ID's in a : seperated stringlist
string MK_PreReadArmorPartList2(int nPart, string sAC="")
{
    // pick the right 2da to read the parts from
    string s2DA = MK_GetParts2DAfile(nPart);
    string sCache = "";
    string sLine;
    int nMax = MK_GetPartsMaxID(nPart);
    int n = 0;
    int nCount=0;
//    MK_DEBUG_TRACE("MK_PreReadArmorPartList2("+IntToString(nPart)+", '"+sAC+"'), s2DA='"+s2DA+"', nMax="+IntToString(nMax));
    for (n=0; n<=nMax; n++)
    {
        // Verify validity of the ID and add to the list
        sLine = Get2DAString(s2DA, "ACBONUS", n);
        if ((sLine!="") && ((sAC=="") || (GetStringLeft(sLine,1)==sAC)))
        {
            sCache+=("!"+MK_IntToString(n,3," "));
            nCount++;
        }
    }
    if (nCount>0)
    {
        string sStart = GetStringLeft(sCache, 4);
        string sEnd = GetStringRight(sCache, 4);
        sCache = sEnd + sCache + sStart;
    }
    SetLocalString(GetModule(), "MK_IAAM_PreReadIDs"+MK_IntToString(nPart,2,"0")+sAC, sCache);
    return sCache;
}

string MK_GetPreReadArmorPartCache(int nPart, int nCurrApp)
{
    string sAC = "";
    if (nPart ==ITEM_APPR_ARMOR_MODEL_TORSO)
    {
        sAC = GetStringLeft(Get2DAString("parts_chest", "ACBONUS", nCurrApp),1);
    }

    string sCache = GetLocalString(GetModule(),"MK_IAAM_PreReadIDs"+MK_IntToString(nPart,2,"0")+sAC);
    if (sCache=="")
    {
        sCache = MK_PreReadArmorPartList2(nPart, sAC);
    }
    return sCache;
}

int MK_GetIsArmorPartEmptyAppearance(object oArmor, int nPart)
{
    int nPartQ = MK_IAAM_GetPart(nPart, 0);
    int nCurrApp = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_MODEL, nPartQ);
    string sCache = MK_GetPreReadArmorPartCache(nPartQ, nCurrApp);
    int nNullApp = StringToInt(GetSubString(sCache, 4+1, 3));
    return (nCurrApp == nNullApp);
}

int MK_GetArmorAppearanceType2(object oArmor, int nPart, int nMode)
{
    int nCurrApp  = GetItemAppearance(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL,nPart);
    int nNewApp;
    if (nMode == MK_IP_ITEMTYPE_OPPOSITE)
    {
        int nOppositePart = MK_GetOppositePart(nPart);
        if (nOppositePart!=0)
        {
            nNewApp = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_MODEL, nOppositePart);
        }
    }
    else
    {
        string sAC = "";
        if (nPart ==ITEM_APPR_ARMOR_MODEL_TORSO)
        {
            sAC = GetStringLeft(Get2DAString("parts_chest", "ACBONUS", nCurrApp),1);
        }

        string sCache = MK_GetPreReadArmorPartCache(nPart, nCurrApp);
/*
        string sCache = GetLocalString(GetModule(),"MK_IAAM_PreReadIDs"+MK_IntToString(nPart,2,"0")+sAC);
        if (sCache=="")
        {
            sCache = MK_PreReadArmorPartList2(nPart, sAC);
        }
//        MK_DEBUG_TRACE("MK_GetArmorAppearanceType2: cache='"+sCache+"!");
*/
        if (sCache=="")
        {
            nNewApp = nCurrApp;
        }
        else if (nMode == MK_IP_ITEMTYPE_CLEAR)
        {
            nNewApp = StringToInt(GetSubString(sCache, 4+1, 3));
        }
        else
        {
            string sCurrApp = "!"+MK_IntToString(nCurrApp,3," ");
            int nPos = MK_VERSION_FindSubString(sCache, sCurrApp, 4);

            if (nPos!=-1)
            {
                nNewApp = StringToInt(GetSubString(sCache, (nMode == X2_IP_ARMORTYPE_PREV ? nPos-4 : nPos+4) + 1, 3));
            }
            else
            {
                nNewApp = StringToInt(GetSubString(sCache, 4+1, 3));
            }
//            MK_DEBUG_TRACE(" > nCurrApp="+IntToString(nCurrApp)+", sCurrApp="+sCurrApp+", nPos="+IntToString(nPos)+", nNewApp="+IntToString(nNewApp));
        }
    }
    return nNewApp;
}

/*
// copied from 'void ZEP_RemakeItem(object oPC, int nMode)' and modified
int MK_GetArmorAppearanceType(object oArmor, int nPart, int nMode)
{
    int nCurrApp  = GetItemAppearance(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL,nPart);

    if (nMode == MK_IP_ITEMTYPE_OPPOSITE)
    {
        int nOppositePart = MK_GetOppositePart(nPart);
        if (nOppositePart!=0)
        {
            nCurrApp = GetItemAppearance(oArmor, ITEM_APPR_TYPE_ARMOR_MODEL, nOppositePart);
        }
    }
    else
    {
        string sPreRead;

        if (nPart == ITEM_APPR_ARMOR_MODEL_TORSO)
        {
            string sAC = Get2DAString("parts_chest", "ACBONUS", nCurrApp);
            // Fetch the stringlist that holds the ID's for this part
            sPreRead = GetLocalString(GetModule(), "MK_IDPreReadAC_"+GetStringLeft(sAC,1));
            if (sPreRead=="") // list didn't exist yet, so generate it
                sPreRead = MK_PreReadArmorACList(sAC);
            if (nMode==X2_IP_ARMORTYPE_PREV)
                sPreRead = GetLocalString(GetModule(), "MK_IDPreReadACR_"+GetStringLeft(sAC,1));
        }
        else
        {
            // Fetch the stringlist that holds the ID's for this part
            sPreRead = GetLocalString(GetModule(), "MK_IDPreRead_"+IntToString(nPart));
            if (sPreRead=="") // list didn't exist yet, so generate it
                sPreRead = MK_PreReadArmorPartList(nPart);
            if (nMode==X2_IP_ARMORTYPE_PREV)
                sPreRead = GetLocalString(GetModule(), "MK_IDPreReadR_"+IntToString(nPart));
        }
        MK_DEBUG_TRACE("MK_GetArmorAppearanceType(,"+IntToString(nPart)+","+IntToString(nMode)
            +"), nCurrApp="+IntToString(nCurrApp)+", sPreRead="+sPreRead);

        // Find the current ID in the stringlist and pick the one coming after that
        string sID;
        string sCurrApp = IntToString(nCurrApp);
        int n = FindSubString(sPreRead, ":"+sCurrApp+":");
        sID = GetSubString(sPreRead, n+GetStringLength(sCurrApp)+2, 5);
        MK_DEBUG_TRACE(" > sCurrApp="+sCurrApp+", FindSubString(nCurrApp)="+IntToString(n)+", GetSubStr(n)="+sID);
        n = FindSubString(sID, ":");
        sID = GetStringLeft(sID, n);
        MK_DEBUG_TRACE(" > FindSubString(sID,':')="+IntToString(n)+", GetStrLeft(sID,n)="+sID);
        if (sID=="" && nPart == ITEM_APPR_ARMOR_MODEL_TORSO)
        {
           sID = GetSubString(sPreRead, 1, 5);
           n = FindSubString(sID, ":");
           sID = GetStringLeft(sID, n);
        }
        nCurrApp = StringToInt(sID);
    }

    return nCurrApp;
}
*/

// ----------------------------------------------------------------------------
// Returns a new armor based of oArmor with nPartModified
// nPart - ITEM_APPR_ARMOR_MODEL_* constant of the part to be changed
// nMode -
//          X2_IP_ARMORTYPE_NEXT    - next valid appearance
//          X2_IP_ARMORTYPE_PREV    - previous valid apperance;
//          X2_IP_ARMORTYPE_RANDOM  - random valid appearance (torso is never changed);
// bDestroyOldOnSuccess - Destroy oArmor in process?
// Uses Get2DAstring, so do not use in loops
// ----------------------------------------------------------------------------
object MK_GetModifiedArmor(object oArmor, int nPart, int nMode, int bDestroyOldOnSuccess)
{
    if (!MK_IAAM_GetIsValid(nPart)) return oArmor;
    int nPartCount = MK_IAAM_GetPartCount(nPart);
    int nNewApp=-1;
    object oNew = OBJECT_INVALID;
    int nPartOpp=-1;
    if (nPartCount>0)
    {
        switch (nMode)
        {
        case MK_IP_ITEMTYPE_OPPOSITE:
        {
            nPartOpp = MK_IAAM_GetOpposite(nPart);
            int nPartOppCount = MK_IAAM_GetPartCount(nPartOpp);
            if (nPartOppCount!=nPartCount)
            {
                return oArmor;
            }
            break;
        }
        case X2_IP_ARMORTYPE_NEXT:
        case X2_IP_ARMORTYPE_PREV:
        case MK_IP_ITEMTYPE_CLEAR:
            nNewApp = MK_GetArmorAppearanceType2(oArmor, MK_IAAM_GetPart(nPart,0),  nMode );
            break;
        }

        int iModel;
        oNew = oArmor;
        for (iModel=0; (GetIsObjectValid(oNew) && (iModel<nPartCount)); iModel++)
        {
            int iPart = MK_IAAM_GetPart(nPart, iModel);
            switch (nMode)
            {
            case MK_IP_ITEMTYPE_OPPOSITE:
            {
                int iPartOpp = MK_IAAM_GetPart(nPartOpp, iModel);
                nNewApp = GetItemAppearance(oNew, ITEM_APPR_TYPE_ARMOR_MODEL, iPartOpp);
                break;
            }
            case X2_IP_ARMORTYPE_NEXT:
            case X2_IP_ARMORTYPE_PREV:
            case MK_IP_ITEMTYPE_CLEAR:
                break;
            default:
                nNewApp = MK_GetArmorAppearanceType2(oArmor, iPart, nMode);
                break;
            }
//            MK_DEBUG_TRACE("MK_GetModifiedArmor: nNewApp="+IntToString(nNewApp));
            oNew = MK_CopyItemAndModify(oNew,ITEM_APPR_TYPE_ARMOR_MODEL, iPart, nNewApp, TRUE);
        }
    }

    if (GetIsObjectValid(oNew))
    {
        MK_SetItemIsModified(oNew, TRUE);
        SetCustomToken(MK_TOKEN_PARTNUMBER, IntToString(nNewApp));
        if( bDestroyOldOnSuccess )
        {
            DestroyObject(oArmor);
        }
        return oNew;
    }
    // Safety fallback, return old armor on failures
    return oArmor;
}


/*
object MK_GetModifiedArmor(object oArmor, int nPart, int nMode, int bDestroyOldOnSuccess)
{
    int nNewApp = MK_GetArmorAppearanceType(oArmor, nPart,  nMode );
//    SpeakString("old: " + IntToString(GetItemAppearance(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL,nPart)));
//    SpeakString("new: " + IntToString(nNewApp));

    object oNew = MK_CopyItemAndModify(oArmor,ITEM_APPR_TYPE_ARMOR_MODEL, nPart, nNewApp, TRUE);

    if (oNew != OBJECT_INVALID)
    {
        MK_SetItemIsModified(oNew, TRUE);
        SetCustomToken(MK_TOKEN_PARTNUMBER, IntToString(nNewApp));
        if( bDestroyOldOnSuccess )
        {
            DestroyObject(oArmor);
        }
        return oNew;
    }

    // Safety fallback, return old armor on failures
    return oArmor;
}
*/

// - private -
// Prereads the 2da-file for nPart and puts all used ID's in a : seperated stringlist
string MK_PreReadCloakModelList()
{
    // pick the right 2da to read the parts from
    string s2DA = "CloakModel";

    string sCache= ":";
    string sLine;
    int nMax = 255;
    int n=1;
    while (n<=nMax) {
        // Verify validity of the ID and add to the list
        sLine = Get2DAString(s2DA, "LABEL", n);
        if (sLine!="")
        {
            sCache+= IntToString(n)+":";
        }
        n++;
    }
    // Store the list in a modulestring, once normal, once reversed, both with ID 0 added as first index for cycling
    SetLocalString(GetModule(), "MK_IDPreRead_Cloak", ":0"+sCache);
    SetLocalString(GetModule(), "MK_IDPreReadR_Cloak", ":0"+MK_ListReverse(sCache));

//    SpeakString(GetLocalString(GetModule(),"MK_IDPreRead_Cloak"));
//    SpeakString(GetLocalString(GetModule(),"MK_IDPreReadR_Cloak"));

    return sCache;
}


int MK_GetCloakAppearanceType(object oCloak, int nPart, int nMode)
{
    int nCurrApp  = GetItemAppearance(oCloak, 0, nPart);

    string sPreRead;

    // Fetch the stringlist that holds the ID's for this part
    sPreRead = GetLocalString(GetModule(), "MK_IDPreRead_Cloak");
    if (sPreRead=="") // list didn't exist yet, so generate it
        sPreRead = MK_PreReadCloakModelList();
    if (nMode==MK_IP_ITEMTYPE_PREV)
        sPreRead = GetLocalString(GetModule(), "MK_IDPreReadR_Cloak");

    // Find the current ID in the stringlist and pick the one coming after that
    string sID;
    string sCurrApp = IntToString(nCurrApp);
    int n = FindSubString(sPreRead, ":"+sCurrApp+":");
    sID = GetSubString(sPreRead, n+GetStringLength(sCurrApp)+2, 5);
    n = FindSubString(sID, ":");
    sID = GetStringLeft(sID, n);
    nCurrApp = StringToInt(sID);

    return nCurrApp;
}

// ----------------------------------------------------------------------------
// Returns a new armor based of oArmor with nPartModified
// nPart - ITEM_APPR_ARMOR_MODEL_* constant of the part to be changed
// nMode -
//          MK_IP_CLOAKTYPE_NEXT    - next valid appearance
//          MK_IP_CLOAKTYPE_PREV    - previous valid apperance;
// bDestroyOldOnSuccess - Destroy oArmor in process?
// Uses Get2DAstring, so do not use in loops
// ----------------------------------------------------------------------------
object MK_GetModifiedCloak(object oCloak, int nPart, int nMode, int bDestroyOldOnSuccess)
{
    int nNewApp = MK_GetCloakAppearanceType(oCloak, nPart,  nMode );

    object oNew = MK_CopyItemAndModify(oCloak, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nNewApp, TRUE);
//    object oNew = MK_ModifyCloakModel(GetPCSpeaker(), oCloak, nNewApp);

    if (oNew != OBJECT_INVALID)
    {
        MK_SetItemIsModified(oNew, TRUE);
        SetCustomToken(MK_TOKEN_PARTNUMBER, IntToString(nNewApp));
        if( bDestroyOldOnSuccess )
        {
            DestroyObject(oCloak);
        }
        return oNew;
    }
//        SpeakString("failed");

    // Safety fallback, return old armor on failures
    return oCloak;
}

object MK_GetModifiedHelmet(object oHelmet, int nMode, int bDestroyOldOnSuccess)
{
    int nMin = MK_Get2DAInt("baseitems", "MinRange", BASE_ITEM_HELMET);
    int nMax = MK_Get2DAInt("baseitems", "MaxRange", BASE_ITEM_HELMET);
    int nCurrApp = GetItemAppearance(oHelmet, ITEM_APPR_TYPE_ARMOR_MODEL, 0);

    object oNew;

    do
    {
        switch (nMode)
        {
        case MK_IP_ITEMTYPE_NEXT:
            if (++nCurrApp>nMax) nCurrApp = nMin;
            break;

        case MK_IP_ITEMTYPE_PREV:
            if (--nCurrApp<nMin) nCurrApp = nMax;
            break;
        }
        oNew = MK_CopyItemAndModify(oHelmet, ITEM_APPR_TYPE_ARMOR_MODEL, 0, nCurrApp, TRUE);
    }
    while (!GetIsObjectValid(oNew));

    MK_SetItemIsModified(oNew, TRUE);

    SetCustomToken(MK_TOKEN_PARTNUMBER, IntToString(nCurrApp));

    if( bDestroyOldOnSuccess )
    {
        DestroyObject(oHelmet);
    }
    return oNew;
}


/*
int MK_GetShieldAppearanceType(object oShield, int nMode)
{
    int nCurrApp  = GetItemAppearance(oShield, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);

    int nBaseItemType = GetBaseItemType(oShield);

    int nMinApp = StringToInt(Get2DAString("baseitems", "MinRange", nBaseItemType));
    int nMaxApp = StringToInt(Get2DAString("baseitems", "MaxRange", nBaseItemType));

    switch (nMode)
    {
    case MK_IP_ITEMTYPE_NEXT:
        if (++nCurrApp > nMaxApp) nCurrApp = nMinApp;
        break;
    case MK_IP_ITEMTYPE_PREV:
        if (--nCurrApp < nMinApp) nCurrApp = nMaxApp;
        break;
    }
    return nCurrApp;
}
*/

int MK_GetIsWeaponValid(object oWeapon, int nType, int nPart)
{
    int bReturn = FALSE;
    if (GetIsObjectValid(oWeapon))
    {
        switch (nType)
        {
        case ITEM_APPR_TYPE_WEAPON_COLOR:
        {
            int nAppearance = GetItemAppearance(oWeapon, ITEM_APPR_TYPE_WEAPON_MODEL, nPart);
            object oTemp = MK_CopyItemAndModify(oWeapon, ITEM_APPR_TYPE_WEAPON_MODEL, nPart, nAppearance, FALSE);
            if (GetIsObjectValid(oTemp))
            {
                DestroyObject(oTemp);
                bReturn = TRUE;
            }
            break;
        }
        case ITEM_APPR_TYPE_WEAPON_MODEL:
            bReturn = TRUE;
            break;
        }
        if (!bReturn)
        {
            DestroyObject(oWeapon);
        }
    }
    return bReturn;
}

object MK_GetModifiedWeapon(object oWeapon, int nPart, int nMode, int bDestroyOldOnSuccess)
{
//    int bDisableExtendedEditionFeatures = MK_INIT_GetAreEEFeaturesDisabled();
//    MK_DEBUG_TRACE("MK_GetModifiedWeapon(..,nPart="+IntToString(nPart)+", nMode="+IntToString(nMode)+")");
    int nBaseItemType = GetBaseItemType(oWeapon);
    int nMin, nMax, nCurrApp;
    int nType;
    switch (nMode)
    {
    case X2_IP_WEAPONTYPE_NEXT:
    case X2_IP_WEAPONTYPE_PREV:
        nMin = MK_Get2DAInt("baseitems", "MinRange", nBaseItemType)/10;
        nMax = MK_Get2DAInt("baseitems", "MaxRange", nBaseItemType)/10;
        nType = ITEM_APPR_TYPE_WEAPON_MODEL;
        break;
    case MK_IP_WEAPONCOLOR_NEXT:
    case MK_IP_WEAPONCOLOR_PREV:
    case MK_IP_WEAPONCOLOR_RESET:
        nMin = 1;
 //       if (bDisableExtendedEditionFeatures)
 //           nMax = 4;
 //       else
        nMax = (MK_VERSION_GetIsVersionGreaterEqual_1_74() ? 9 : 4);
        nType = ITEM_APPR_TYPE_WEAPON_COLOR;
        break;
    }
    nCurrApp = GetItemAppearance(oWeapon, nType, nPart);
//    MK_DEBUG_TRACE("> nType="+IntToString(nType)+", nMin="+IntToString(nMin)
//        +", nMax="+IntToString(nMax)+", nCurrApp="+IntToString(nCurrApp));

    object oNew;

    int nOldApp = nCurrApp;

    do
    {
        switch (nMode)
        {
        case X2_IP_WEAPONTYPE_NEXT:
        case MK_IP_WEAPONCOLOR_NEXT:
            if (++nCurrApp>nMax) nCurrApp = nMin;
            break;

        case MK_IP_WEAPONCOLOR_PREV:
        case X2_IP_WEAPONTYPE_PREV:
            if (--nCurrApp<nMin) nCurrApp = nMax;
            break;
        case MK_IP_WEAPONCOLOR_RESET:
            nCurrApp = nMin;
            break;
        }
//        MK_DEBUG_TRACE("> MK_CopyItemAndModify(nType="+IntToString(nType)+", nPart="+IntToString(nPart)+", nCurrApp="+IntToString(nCurrApp)+")");
        oNew = MK_CopyItemAndModify(oWeapon, nType, nPart, nCurrApp, TRUE);
    }
    while (!MK_GetIsWeaponValid(oNew, nType, nPart) && (nOldApp!=nCurrApp));

    if (GetIsObjectValid(oNew) && (nMax!=nMin) && (nOldApp==nCurrApp))
    {
        oWeapon = oNew;
        oNew = OBJECT_INVALID;
    }

    if (GetIsObjectValid(oNew))
    {
//        MK_DEBUG_TRACE("MK_GetModifiedWeapon: nType="+IntToString(nType)+", nPart="+IntToString(nPart)+", nCurrApp="+IntToString(nCurrApp)+": valid");
        MK_SetItemIsModified(oNew, TRUE);

        SetCustomToken(MK_TOKEN_PARTNUMBER,
            IntToString(GetItemAppearance(oWeapon, ITEM_APPR_TYPE_WEAPON_MODEL, nPart)*10+
                        GetItemAppearance(oWeapon, ITEM_APPR_TYPE_WEAPON_COLOR, nPart)));

        if( bDestroyOldOnSuccess )
        {
            DestroyObject(oWeapon);
        }
        return oNew;
    }
    else
    {
//        MK_DEBUG_TRACE("MK_GetModifiedWeapon: nType="+IntToString(nType)+", nPart="+IntToString(nPart)+", nCurrApp="+IntToString(nCurrApp)+": INVALID");
        switch (nMode)
        {
        case X2_IP_WEAPONTYPE_NEXT:
        case X2_IP_WEAPONTYPE_PREV:
            if (GetItemAppearance(oWeapon, ITEM_APPR_TYPE_WEAPON_COLOR, nPart) != 1)
            {
                oNew = MK_GetModifiedWeapon(oWeapon, nPart, MK_IP_WEAPONCOLOR_RESET, FALSE);
                if (GetIsObjectValid(oNew))
                {
//                    MK_DEBUG_TRACE("MK_GetModifiedWeapon: nType="+IntToString(nType)+", nPart="+IntToString(nPart)+", nCurrApp=1: valid");
                    oNew = MK_GetModifiedWeapon(oNew, nPart, X2_IP_WEAPONTYPE_NEXT, TRUE);
                    if (GetIsObjectValid(oNew))
                    {
                        if (GetItemAppearance(oNew, nType, nPart) != nOldApp)
                        {
                            DestroyObject(oWeapon);
                            return oNew;
                        }
                        else
                        {
                            DestroyObject(oNew);
                        }
                    }
                }
 //               else
 //               {
 //                   MK_DEBUG_TRACE("MK_GetModifiedWeapon: nPart="+IntToString(nPart)+", nCurrApp=1: INVALID");
 //               }
            }
            break;
        }
    }

    return oWeapon;
}

object MK_GetModifiedShield(object oShield, int nMode, int bDestroyOldOnSuccess)
{
    int nBaseItemType = GetBaseItemType(oShield);
    int nMinApp = MK_Get2DAInt("baseitems", "MinRange", nBaseItemType);
    int nMaxApp = MK_Get2DAInt("baseitems", "MaxRange", nBaseItemType);

    int nCurrApp  = GetItemAppearance(oShield, ITEM_APPR_TYPE_SIMPLE_MODEL, 0);

    object oNew;

    do
    {
        switch (nMode)
        {
        case MK_IP_ITEMTYPE_NEXT:
            if (++nCurrApp > nMaxApp) nCurrApp = nMinApp;
            break;
        case MK_IP_ITEMTYPE_PREV:
            if (--nCurrApp < nMinApp) nCurrApp = nMaxApp;
            break;
        }
        oNew = MK_CopyItemAndModify(oShield, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nCurrApp, TRUE);
    }
    while (!MK_GetIsWeaponValid(oNew, ITEM_APPR_TYPE_WEAPON_COLOR, 0));
//    while (!GetIsObjectValid(oNew));

    MK_SetItemIsModified(oNew, TRUE);

    SetCustomToken(MK_TOKEN_PARTNUMBER, IntToString(nCurrApp));
    if( bDestroyOldOnSuccess )
    {
        DestroyObject(oShield);
    }
    return oNew;
}

object MK_GetDyedItem(object oArmor, int iPart, int iMaterialToDye, int iColor, int bDestroyOldOnSuccess, int nStoreValueOnItem)
{
    object oNew = OBJECT_INVALID;

    if (iPart==-1)
    {
        oNew = MK_CopyItemAndModify(oArmor, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterialToDye, iColor, TRUE, FALSE);
    }
    else
    {
        int iIndex = MK_CalculateColorIndex(iMaterialToDye, iPart);
        oNew = MK_CopyItemAndModify(oArmor, ITEM_APPR_TYPE_ARMOR_COLOR, iIndex, iColor, TRUE, nStoreValueOnItem);
    }
//    MK_DEBUG_TRACE("MK_GetDyedItem(iPart="+IntToString(iPart)+", iMaterial="+IntToString(iMaterialToDye)+
//        ", iColor="+IntToString(iColor)+"): success="+IntToString(oNew != OBJECT_INVALID));
    if (oNew != OBJECT_INVALID)
    {
        if( bDestroyOldOnSuccess )
        {
            DestroyObject(oArmor);
        }
        return oNew;
    }

    // Safety fallback, return old armor on failures
    return oArmor;
}


object MK_MatchItem(object oDest, object oSource, int nType, int nIndex)
{
    int nValue = MK_GetItemAppearance(oSource, nType, nIndex);
    if ((nValue==-1) && (nType==ITEM_APPR_TYPE_ARMOR_COLOR) && (nIndex>ITEM_APPR_ARMOR_NUM_COLORS))
    {
        nValue = 255;
    }

    if ((nValue!=-1) || ((nType==ITEM_APPR_TYPE_ARMOR_COLOR) && (nIndex>ITEM_APPR_ARMOR_NUM_COLORS)))
    {
        object oNew = MK_CopyItemAndModify(oDest, nType, nIndex, nValue, TRUE, TRUE);
        if (GetIsObjectValid(oNew))
        {
            DestroyObject(oDest);
            return oNew;
        }
    }
    return oDest;
}

string MK_GetCloakModelResRef(int nModel)
{
    string sNr = "mk_clk_";
    if (nModel<100) sNr+="0";
    if (nModel<10) sNr+="0";
    sNr+=IntToString(nModel);
    return sNr;
}

object MK_CopyAppearance(object oDest, object oSource)
{
    if ((GetBaseItemType(oDest)!=BASE_ITEM_ARMOR) ||
        (GetBaseItemType(oSource)!=BASE_ITEM_ARMOR))
    {
        return oDest;
    }

    int bCopyTorso=FALSE;

    int nDestTorso = GetItemAppearance(oDest,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_TORSO);
    int nSourceTorso = GetItemAppearance(oSource,ITEM_APPR_TYPE_ARMOR_MODEL,ITEM_APPR_ARMOR_MODEL_TORSO);
    if (nDestTorso!=nSourceTorso)
    {
        int nDestACBonus = MK_Get2DAInt("parts_chest","ACBONUS",nDestTorso);
        int nSourceACBonus = MK_Get2DAInt("parts_chest","ACBONUS",nSourceTorso);
        bCopyTorso = (nDestACBonus==nSourceACBonus);
    }

    object oNewItem = oDest;
    int iModelType;
    for (iModelType=0; iModelType<ITEM_APPR_ARMOR_NUM_MODELS; iModelType++)
    {
        if ((iModelType!=ITEM_APPR_ARMOR_MODEL_TORSO) || bCopyTorso)
        {
            oNewItem = MK_MatchItem(oNewItem, oSource, ITEM_APPR_TYPE_ARMOR_MODEL,iModelType);
        }
    }
    return oNewItem;
}

object MK_CopyColor(object oDest, object oSource, int bCopyOverrideColors)
{
    object oNewItem = oDest;
    int iMaterial;
    for (iMaterial=0; iMaterial<ITEM_APPR_ARMOR_NUM_COLORS; iMaterial++)
    {
        oNewItem = MK_MatchItem(oNewItem, oSource, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterial);
        if (bCopyOverrideColors)
        {
            int iPart;
            for (iPart=0; iPart<ITEM_APPR_ARMOR_NUM_MODELS; iPart++)
            {
                int nIndex = MK_CalculateColorIndex(iMaterial, iPart);
                int nColorSource = MK_GetItemAppearance(oSource, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex);
                int nColorDest = MK_GetItemAppearance(oNewItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex);
                int nAppearance = GetItemAppearance(oSource, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex);

                oNewItem = MK_MatchItem(oNewItem, oSource, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex);

                int nNewColorDest = MK_GetItemAppearance(oNewItem, ITEM_APPR_TYPE_ARMOR_COLOR, nIndex);

//                if (nColorSource!=-1)
//                {
//                    MK_DEBUG_TRACE("MK_CopyColor: iMaterial="+IntToString(iMaterial)+", iPart="+IntToString(iPart)
//                         +", nColorSource="+IntToString(nColorSource)
//                         +", nColorDest="+IntToString(nColorDest)
//                         +", nAppearance="+IntToString(nAppearance)
//                         +", nNewColorDest="+IntToString(nNewColorDest)
//                         );
//                }
            }
        }
    }
    return oNewItem;
}

/*
object MK_ModifyCloakModel(object oPC, object oItem, int nNewValue)
{
    // Bodge for CopyItemAndModify not working on cloak appearance in NWN v1.68
    // Create a new cloak with the correct model
    object oContainer = IPGetIPWorkContainer(oPC);

    object oNewItem = CreateItemOnObject(MK_GetCloakModelResRef(nNewValue), oContainer, 1, GetTag(oItem));

    // Copy across all the colors for it
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1);
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2);
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1);
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2);
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1);
    oNewItem = MK_MatchItem(oNewItem, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2);

    // Copy the item properties
    itemproperty iProp = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(iProp))
    {
        if (GetItemPropertyDurationType(iProp) == DURATION_TYPE_PERMANENT)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT,iProp,oNewItem);
        }
        iProp = GetNextItemProperty(oItem);
    }

    // Copy the name
    SetName(oNewItem,GetName(oItem));

    // Copy the stolen flag
    SetStolenFlag(oNewItem, GetStolenFlag(oItem));

    // Copy the plot flag
    SetPlotFlag(oNewItem, GetPlotFlag(oItem));

    // Copy the curse flag
    SetItemCursedFlag(oNewItem, GetItemCursedFlag(oItem));

    object oNew = CopyItem(oNewItem, oPC, FALSE);
    DestroyObject(oNewItem);

    return oNew;
}
*/

int MK_IsBodyPartVisible(int nRobe, int nPart)
{
    if (!MK_IAAM_GetIsValid(nPart)) return FALSE;
    string s2DAfile = MK_IAAM_GetParts2DAfile(ITEM_APPR_ARMOR_MODEL_ROBE);
//    MK_DEBUG_TRACE("MK_IsBodyPartVisible("+IntToString(nRobe)+", "+IntToString(nPart)+"), s2DAfile="+s2DAfile);

    int nPartCount = MK_IAAM_GetPartCount(nPart);
    int iModel;
    int nVisible=TRUE;

    for (iModel=0; (nVisible && (iModel<nPartCount)); iModel++)
    {
        int iPart = MK_IAAM_GetPart(nPart, iModel);
        string sColumn=MK_IAAM_GetRobeHideColumn(iPart);
        if (sColumn!="")
        {
            nVisible = !MK_Get2DAInt(s2DAfile, sColumn, nRobe);
        }
//        MK_DEBUG_TRACE("> nPartCount="+IntToString(nPartCount)+", iModel="+IntToString(iModel)+", iPart="+IntToString(iPart)+", sColumn="+sColumn+", nVisible="+IntToString(nVisible));
    }
    return nVisible;
/*
    string sColumn="";
    switch (nPart)
    {
    case ITEM_APPR_ARMOR_MODEL_LBICEP:
        sColumn = "HIDEBICEPR";
        break;
    case ITEM_APPR_ARMOR_MODEL_RBICEP:
        sColumn = "HIDEBICEPL";
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOREARM:
        sColumn = "HIDEFOREL";
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOREARM:
        sColumn = "HIDEFORER";
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOOT:
        sColumn = "HIDEFOOTL";
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOOT:
        sColumn = "HIDEFOOTR";
        break;
    case ITEM_APPR_ARMOR_MODEL_LHAND:
        sColumn = "HIDEHANDL";
        break;
    case ITEM_APPR_ARMOR_MODEL_RHAND:
        sColumn = "HIDEHANDR";
        break;
    case ITEM_APPR_ARMOR_MODEL_LSHIN:
        sColumn = "HIDESHINR";
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHIN:
        sColumn = "HIDESHINL";
        break;
    case ITEM_APPR_ARMOR_MODEL_LSHOULDER:
        sColumn = "HIDESHOL";
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHOULDER:
        sColumn = "HIDESHOR";
        break;
    case ITEM_APPR_ARMOR_MODEL_LTHIGH:
        sColumn = "HIDELEGL";
        break;
    case ITEM_APPR_ARMOR_MODEL_RTHIGH:
        sColumn = "HIDELEGR";
        break;
    case ITEM_APPR_ARMOR_MODEL_NECK:
        sColumn = "HIDENECK";
        break;
    case ITEM_APPR_ARMOR_MODEL_BELT:
        sColumn = "HIDEBELT";
        break;
    case ITEM_APPR_ARMOR_MODEL_PELVIS:
        sColumn = "HIDEPELVIS";
        break;
    case ITEM_APPR_ARMOR_MODEL_TORSO:
        sColumn = "HIDECHEST";
        break;
    }
    int nReturn=TRUE;

    if (sColumn!="")
    {
        nReturn = (0==StringToInt(Get2DAString("parts_robe", sColumn, nRobe)));
    }
    return nReturn;
    */
}

void MK_DyeItem(object oPC, int nMaterialToDye, int nColor)
{
    if (!GetIsObjectValid(oPC))
    {
        return;
    }
    object oItem = CIGetCurrentModItem(oPC);
    if (!GetIsObjectValid(oItem))
    {
        return;
    }
    object oNew = oItem;

    int bPerPartColoring = GetLocalInt(oPC, MK_PERPARTCOLORING) && (CIGetCurrentModMode(oPC)==X2_CI_MODMODE_ARMOR);
    int iColor;
    int nColorCount = MK_IAAC_GetColorCount(nMaterialToDye);
//    MK_DEBUG_TRACE("MK_DyeItem: iMaterialToDye="+IntToString(nMaterialToDye)+", nColorCount="+IntToString(nColorCount));
    for (iColor=0; iColor<nColorCount; iColor++)
    {
        int iMaterial = MK_IAAC_GetColor(nMaterialToDye, iColor);
//        MK_DEBUG_TRACE(" >: iColor="+IntToString(iColor)+", iMaterial="+IntToString(iMaterial));

        if ( bPerPartColoring )
        {
            int nCurrentModPart = MK_GetCurrentModPart(oPC);
            if (MK_IAAM_GetIsValid(nCurrentModPart))
            {
                int nPartCount = MK_IAAM_GetPartCount(nCurrentModPart);
                int iModel;
//                oNew = oItem;
                for (iModel=0; iModel<nPartCount; iModel++)
                {
                    int iPart = MK_IAAM_GetPart(nCurrentModPart, iModel);
//                    MK_DEBUG_TRACE("  >: iModel="+IntToString(iModel)+", iPart="+IntToString(iPart));
                    oNew = MK_GetDyedItem(oNew, iPart, iMaterial, nColor, TRUE, TRUE);
                }
            }
        }
        else
        {
            oNew = MK_GetDyedItem(oNew, -1, iMaterial, nColor, TRUE, FALSE);
        }
    }

    if (GetIsObjectValid(oNew))
    {
        CISetCurrentModItem(oPC,oNew);

        MK_EquipModifiedItem(oPC);
    }
}

void MK_SetColorToken(object oItem, int nMaterialToDye)
{
    if (GetIsObjectValid(oItem))
    {
        string sColor1 = GetLocalString(OBJECT_SELF, "MK_TOKEN_COLOR1");
        string sColor2 = GetLocalString(OBJECT_SELF, "MK_TOKEN_COLOR2");
        string sColor="";
        int nColor, iMaterial;
        for (iMaterial = 0; iMaterial<ITEM_APPR_ARMOR_NUM_COLORS; iMaterial++)
        {
            if (MK_IAAC_GetContainsColor(nMaterialToDye, iMaterial))
//            if (iMaterial==nMaterialToDye)
            {
                sColor = sColor1;
            }
            else
            {
                sColor = sColor2;
            }
            nColor = MK_GetItemColor(OBJECT_SELF, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterial);
//            nColor = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterial);


            sColor += MK_ColorEx(iMaterial, nColor);
/*
            switch (iMaterial)
            {
            case ITEM_APPR_ARMOR_COLOR_LEATHER1:
            case ITEM_APPR_ARMOR_COLOR_LEATHER2:
            case ITEM_APPR_ARMOR_COLOR_CLOTH1:
            case ITEM_APPR_ARMOR_COLOR_CLOTH2:
                sColor+=MK_ClothColorEx(nColor);
                break;
            case ITEM_APPR_ARMOR_COLOR_METAL1:
            case ITEM_APPR_ARMOR_COLOR_METAL2:
                sColor+=MK_MetalColorEx(nColor);
                break;
            }
*/
            sColor+="</c>";


            if (MK_GetIsPerPartColoring(OBJECT_SELF))
            {
                if (MK_GetIsPerPartColored(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterial, MK_GetCurrentModPart(OBJECT_SELF)))
                {
                    sColor+=" *";
                }
            }
            else
            {
                int nNumParts = MK_GetIsPerPartColored(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterial, -1);
                if (nNumParts>0)
                {
                    sColor+=" *"+IntToString(nNumParts);
                }
            }

            SetCustomToken(MK_TOKEN_COLOR1+iMaterial, sColor);
        }
    }
}

void MK_DisplayColors(object oPC, object oItem)
{
    if (GetIsObjectValid(oItem))
    {
//        int iLeather1 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1);
//        int iLeather2 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2);
//        int iCloth1 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1);
//        int iCloth2 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2);
//        int iMetal1 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1);
//        int iMetal2 = GetItemAppearance(oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2);
        int i;
        string sOutput="";
        for (i=0; i<ITEM_APPR_ARMOR_NUM_COLORS; i++)
        {
            sOutput += ("\n" + MK_IAAC_GetName(i) + ": "
                + MK_ColorEx(i, MK_GetItemColor(oPC, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, i)));
        }

/*
        int iLeather1 = MK_GetItemColor(oPC, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER1);
        int iLeather2 = MK_GetItemColor(oPC, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_LEATHER2);
        int iCloth1 = MK_GetItemColor(oPC, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH1);
        int iCloth2 = MK_GetItemColor(oPC, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_CLOTH2);
        int iMetal1 = MK_GetItemColor(oPC, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL1);
        int iMetal2 = MK_GetItemColor(oPC, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, ITEM_APPR_ARMOR_COLOR_METAL2);

        string sOutput = "\n" + "Leather 1: " + MK_ClothColorEx(iLeather1);
        sOutput += "\n" + "Leather 2: " + MK_ClothColorEx(iLeather2);
        sOutput += "\n" + "Cloth 1: " + MK_ClothColorEx(iCloth1);
        sOutput += "\n" + "Cloth 2: " + MK_ClothColorEx(iCloth2);
        sOutput += "\n" + "Metal 1: " + MK_MetalColorEx(iMetal1);
        sOutput += "\n" + "Metal 2: " + MK_MetalColorEx(iMetal2);
*/
        SendMessageToPC(oPC, sOutput);
    }
}

string MK_ColorEx(int iMaterial, int iColor, int bDisplayNumber)
{
    string sColor = MK_IAAC_GetColorValueName(iMaterial, iColor);
    if (bDisplayNumber)
    {
        sColor = sColor + (sColor=="" ? " " : "") + "(" + IntToString(iColor) + ")";
    }
    return sColor;
}

string MK_ClothColorEx(int iColor, int bDisplayNumber)
{
    string sColor = MK_ClothColor(iColor);
    if (bDisplayNumber)
    {
        sColor = sColor + (sColor=="" ? " " : "") + "(" + IntToString(iColor) + ")";
    }
    return sColor;
}

string MK_MetalColorEx(int iColor, int bDisplayNumber)
{
    string sColor = MK_MetalColor(iColor);
    if (bDisplayNumber)
    {
        sColor = sColor + (sColor=="" ? " " : "") + "(" + IntToString(iColor) + ")";
    }
    return sColor;
}

string MK_Get2DAStringEx(string s2DA, string sColumn, int nRow, string sDefaultColumn)
{
    string sString = Get2DAString(s2DA, sColumn, nRow);
    if ((sString=="") && (sDefaultColumn!="") && (sDefaultColumn!=sColumn))
    {
        sString = Get2DAString(s2DA, sDefaultColumn, nRow);
    }
    return sString;
}

string MK_ClothColor(int iColor)
{
    return Get2DAString("MK_colornames", "Cloth", iColor);
}

string MK_MetalColor(int iColor)
{
    return MK_Get2DAStringEx("MK_colornames", "Metal", iColor, "Cloth");
}

string MK_Get2DAColumnFromMaterial(int iMaterial)
{
    string sColumn="";
    switch (iMaterial)
    {
    case ITEM_APPR_ARMOR_COLOR_LEATHER1:
    case ITEM_APPR_ARMOR_COLOR_LEATHER2:
    case ITEM_APPR_ARMOR_COLOR_CLOTH1:
    case ITEM_APPR_ARMOR_COLOR_CLOTH2:
        sColumn = "Cloth";
        break;
    case ITEM_APPR_ARMOR_COLOR_METAL1:
    case ITEM_APPR_ARMOR_COLOR_METAL2:
        sColumn = "Metal";
        break;
    }
    return sColumn;
}

void MK_SetTokenColorName(int iMaterialToDye, int iColorGroup)
{
//    string sColumn = MK_Get2DAColumnFromMaterial(iMaterialToDye);
    int iColor,i;
    string sColorName;
    int nNumberOfColorsPerGroup = GetLocalInt(OBJECT_SELF, "MK_NUMBER_OF_COLORS_PER_GROUP");
    for (i = 0; i<nNumberOfColorsPerGroup; i++)
    {
        iColor = (iColorGroup*nNumberOfColorsPerGroup) + i;
//        sColorName = MK_Get2DAStringEx("mk_colornames", sColumn, iColor, "Cloth");
        sColorName = MK_IAAC_GetColorValueName(iMaterialToDye, iColor);
        MK_GenericDialog_SetCondition(i,1);
        SetCustomToken(MK_TOKEN_COLORNAME + i, sColorName);
    }
    for (i = nNumberOfColorsPerGroup; i<16; i++)
    {
        MK_GenericDialog_SetCondition(i,0);
    }
}

/*
void MK_SetTokenColorGroup(int iMaterialToDye)
{
//    string sColumn = MK_Get2DAColumnFromMaterial(iMaterialToDye);

    int iGroup;
    string sGroupName;
    int nNumberOfColorGroups = GetLocalInt(OBJECT_SELF, "MK_NUMBER_OF_COLOR_GROUPS");
    for (iGroup=0; iGroup<nNumberOfColorGroups; iGroup++)
    {
        sGroupName = MK_IAAC_GetColorGroupName(iMaterialToDye, iGroup);

        MK_GenericDialog_SetCondition(iGroup, sGroupName!="");
        SetCustomToken(MK_TOKEN_COLORGROUP + iGroup, sGroupName);
    }
    for (iGroup=nNumberOfColorGroups; iGroup<22; iGroup++)
    {
        MK_GenericDialog_SetCondition(iGroup, FALSE);
    }
}
*/

//int MK_GetCurrentModPart1(object oPC)
//{
//    return GetLocalInt(oPC,"X2_TAILOR_CURRENT_PART");
//}

//int MK_GetCurrentModPart2(object oPC)
//{
//    return GetLocalInt(oPC,"MK_TAILOR_CURRENT_PART2");
//}

//void MK_SetCurrentModPart1(object oPC, int nPart)
//{
//    SetLocalInt(oPC,"X2_TAILOR_CURRENT_PART", nPart);
//}

//void MK_SetCurrentModPart2(object oPC, int nPart)
//{
//    SetLocalInt(oPC,"MK_TAILOR_CURRENT_PART2", nPart);
//}

int MK_GetCurrentModPart(object oPC)
{
    return GetLocalInt(oPC, "MK_TAILER_CURRENT_PART");
}

void MK_SetCurrentModPart(object oPC, int nPart, int bSetCamera)
{
    SetLocalInt(oPC, "MK_TAILER_CURRENT_PART", nPart);

    string sName;
    switch (CIGetCurrentModMode(oPC))
    {
    case X2_CI_MODMODE_ARMOR:
    {
        int nPart1 = MK_IAAM_GetPart(nPart, 0);

//      MK_DEBUG_TRACE("MK_SetCurrentModPart(nPart="+IntToString(nPart)+", nPartCount="+IntToString(nPartCount)+
//          ", nPart1="+IntToString(nPart1)+", nPart2="+IntToString(nPart2)+")");

        if ((nPart1>-1) && (bSetCamera))
        {
            // * Make the camera float near the PC
            float fFacing  = GetFacing(oPC) + 180.0;
            if (fFacing > 359.0)
            {
                fFacing -=359.0;
            }

            float fPitch = 75.0;
            float  fDistance = 3.5f;

            if (nPart1 == ITEM_APPR_ARMOR_MODEL_RFOOT || nPart1 == ITEM_APPR_ARMOR_MODEL_LFOOT  )
            {
                fDistance = 3.5f;
                fPitch = 47.0f;
            }
            else if (nPart1 == ITEM_APPR_ARMOR_MODEL_LTHIGH || nPart1 == ITEM_APPR_ARMOR_MODEL_RTHIGH )
            {
                fDistance = 2.5f;
                fPitch = 65.0f;
            }
            else if (nPart1 == ITEM_APPR_ARMOR_MODEL_RSHIN || nPart1 == ITEM_APPR_ARMOR_MODEL_LSHIN    )
            {
                fDistance = 3.5f;
                fPitch = 95.0f;
            }

            if (GetRacialType(oPC)  == RACIAL_TYPE_HALFORC)
            {
                fDistance += 1.0f;
            }

            SetCameraFacing(fFacing, fDistance, fPitch,CAMERA_TRANSITION_TYPE_VERY_FAST) ;
        }
        sName = MK_IAAM_GetName(nPart);
        break;
    }
    case X2_CI_MODMODE_WEAPON:
    {
        int nStrRef = -1;
        switch (nPart)
        {
        case ITEM_APPR_WEAPON_MODEL_TOP:
            nStrRef = 84540;
            break;
        case ITEM_APPR_WEAPON_MODEL_MIDDLE:
            nStrRef = 84541;
            break;
        case ITEM_APPR_WEAPON_MODEL_BOTTOM:
            nStrRef = 84542;
            break;
        }
        if (nStrRef!=-1)
        {
            sName = GetStringByStrRef(nStrRef);
        }
        break;
    }
    }

//    SetCustomToken(X2_CI_MODIFYARMOR_GP_CTOKENBASE,"0");
//    SetCustomToken(X2_CI_MODIFYARMOR_GP_CTOKENBASE+1,"0");

    SetCustomToken(XP_IP_ITEMMODCONVERSATION_CTOKENBASE, sName);
}

int MK_GetIsModifiableWeapon(object oItem)
{
    int nBaseType = GetBaseItemType(oItem);

    // Modifiable Weapons are ModelType 2 (?)
    int nModelType = MK_Get2DAInt("baseitems","ModelType",nBaseType);
    if (nModelType!=2)
    {
        return FALSE;
    }
    // Weapons should have a Weapon Size (?)
    int nWeaponSize = MK_Get2DAInt("baseitems","WeaponSize",nBaseType);
    if (nWeaponSize==0)
    {
        return FALSE;
    }
    return TRUE;
}

int MK_GetIsShield(object oItem)
{
    int bShield;

    switch (GetBaseItemType(oItem))
    {
    case BASE_ITEM_LARGESHIELD:
    case BASE_ITEM_SMALLSHIELD:
    case BASE_ITEM_TOWERSHIELD:
        bShield=TRUE;
        break;
    default:
        bShield=FALSE;
        break;
    }
    return bShield;
}

void MK_InitializeEditDescription(object oPC, object oObject)
{
    string sDescription = GetDescription(oObject, FALSE);
    string sOriginalDescription = GetDescription(oObject, TRUE);

    MK_GenericDialog_SetCondition(22, sDescription!=sOriginalDescription);

    SetLocalString(oPC, g_varEditorText, sDescription);

    if (MK_GetStringLength(sDescription, TRUE)>200)
    {
        sDescription = MK_CloseColorTags(MK_GetStringLeft(sDescription,200, TRUE)+"...");
    }
    SetCustomToken(MK_TOKEN_PARTSTRING, sDescription);
}

void MK_InitializeRenameItem(object oPC, object oItem)
{
    string sName = GetName(oItem, FALSE);
    string sNewName = GetLocalString(oPC, "MK_NEWNAME");
    string sOriginalName = GetName(oItem, TRUE);

    SetCustomToken(MK_TOKEN_PARTSTRING, sName);

    int i;
    int bOk;

    for (i=21; i<=22; i++)
    {
        bOk = FALSE;

        switch (i)
        {
        case 21:
            if ((sNewName!="") && (sNewName!=sName))
            {
                SetCustomToken(MK_TOKEN_NEWNAME , "'"+sNewName+"'");
                bOk = TRUE;
            }
            break;
        case 22:
            if (sName!=sOriginalName)
            {
                SetCustomToken(MK_TOKEN_ORIGINALNAME , "'"+sOriginalName+"'");
                bOk = TRUE;
            }
            break;
        }
        MK_GenericDialog_SetCondition(i, bOk);
    }

    //
    SetLocalString(oPC, g_varEditorText, (sNewName=="" ? sName : sNewName));
}

void MK_PrepareEditor(object oPC, int nEditorID, string sHeadLine,
    int nMaxLength, int bSingleLine, int bDisableColors,
    int bUseChatEvent)
{
    SetLocalInt(oPC, g_varEditorID, nEditorID);
    SetLocalInt(oPC, g_varEditorInit, 1);
    // to make sure the editor gets initialized.
    // Without this the editor doesn't get initialized and everything
    // will most likely look very strange.
    // So this is REQUIRED !!!

    SetLocalString(oPC, g_varEditorHeadLine, sHeadLine);
    // text displayed as 'headline'. Set it something different than ""
    // Otherwise the default headline 'IGTE vsersion - Text:' will be
    // displayed.

    // Allready done in MK_InitializeRenameItem() so we don't have to it here:
    //
    // SetLocalString(oPC, g_varEditorText, sText);
    // the text that gets edited. Without this the text editor will start
    // empty (or containing something strange in case there are some remains
    // from a previous call.

    // We don't need it:
    //
    SetLocalString(oPC, g_varEditorOnInit, "");
    // the OnInit script gets called after the editor is initialized.
    // if you don't need it set it to "".

    // We don't need it:
    //
    SetLocalString(oPC, g_varEditorOnExit, "");
    // the OnExit script, gets called when the user exits the editor
    // using the 'Exit' (= OK) option.
    // that's the place where you should process the edited text.
    // replace 'mk_editor_onexit' with your script name.
    // Not required but without it the whole thing doesn't make much
    // sense because everything the user has done is lost.

    // We don't need it:
    //
    SetLocalString(oPC, g_varEditorOnCancel, "");
    // the name of the 'OnCancel' script, gets called when the user
    // exits the editor by choosing the 'Cancel' option.
    // Warning: the script does not get called if the user uses 'escape'
    // to exit the dialog.
    // replace 'mk_editor_oncncl' with your script name or set it to an
    // empty string if you don't have/need an 'OnCancel' script.

    SetLocalInt(oPC, g_varEditorMaxLength, nMaxLength);
    // You can limit the length of the text by setting the variable
    // g_varEditorMaxLength to value greater 0

    SetLocalInt(oPC, g_varEditorSingleLine, bSingleLine);
    // Setting 'g_varEditorSingleLine' to TRUE will disable the
    // 'Return (insert new line)' dialog option.

    SetLocalInt(oPC, g_varEditorDisableColors, bDisableColors);
    // Setting 'g_varEditorDisableColors' to TRUE will disable the
    // 'Colors (insert color codes)' dialog option.
    // Warning: the user still can use the chat line to insert color tags.

    SetLocalInt(oPC, g_varEditorDisableBlock, FALSE);
    // Setting 'g_varEditorDisableBlock' to TRUE will disable the following
    // dialog options: 'Shift Pos 1', 'Shift Left', 'Shift Right', 'Shift
    // End', 'Shift Delete', 'Shift Insert' and 'Ctrl Insert'. This will
    // perhaps make the editor less confusing but also you lose a lot of
    // functionality (you can't use the block operations anymore).

    SetLocalInt(oPC, g_varEditorDisableLoadSave, FALSE);
    // If g_varEditorDisableLoadSave is set to TRUE the player cannot load
    // or save text. Of course still the text gets saved to
    // g_varEditorText (if the player exits the editor using the OK button)

    SetLocalInt(oPC, g_varEditorUseOnPlayerChatEvent, bUseChatEvent);
    // if you use the editor in a single player game you don't have to use
    // the OnPlayerChatEvent because there are no other players and their
    // chat messages can't interfere with the users chat messages.
    // In a multiplayer game however you should use the OnPlayerChat event
    // to store the chat message as a variable on the player. The editor then
    // will use that variable instead of using the GetPCChatMessage command to
    // get the text entered by the user.
    // The OnPlayerChat event script should look like:
    //
    // #include "mk_inc_editor"
    // void main()
    // {
    //    object oPC = GetPCChatSpeaker();
    //    string sChatMessage = GetPCChatMessage();
    //
    //    int bEditorRunning = GetLocalInt(oPC, g_varEditorRunning);
    //    if (bEditorRunning) // the editor is running
    //    {
    //        int bUseOnPlayerChatEvent =
    //        GetLocalInt(oPC, g_varEditorUseOnPlayerChatEvent);
    //        if (bUseOnPlayerChatEvent)
    //        {
    //            SetLocalString(oPC, g_varEditorChatMessageString, sChatMessage);
    //
    //            // the following line is not required but will make everything
    //            // look much better.
    //            SetPCChatMessage(""); // delete the message so it does not
    //                                  // appear above the player's head
    //        }
    //        return;
    //    }
    //
    //    /*
    //    ...
    //    */
    // }
}

string MK_GetDescription(object oObject)
{
    string sDescription = GetDescription(oObject);
    if (GetDescription(oObject, TRUE)==sDescription)
    {
        sDescription = "";
    }
    return sDescription;
}

void MK_SaveCharacterDescription(object oPC)
{
    SetLocalString(oPC, MK_VAR_CHARACTER_DESCRIPTION,
        MK_GetDescription(oPC));
}

void MK_RestoreCharacterDescription(object oPC)
{
    SetDescription(oPC, GetLocalString(oPC, MK_VAR_CHARACTER_DESCRIPTION));
    DeleteLocalString(oPC, MK_VAR_CHARACTER_DESCRIPTION);
}

int MK_GetIsDescriptionModified(object oPC)
{
    return MK_GetDescription(oPC)!=GetLocalString(oPC, MK_VAR_CHARACTER_DESCRIPTION);
}

int MK_RemoveTemporaryEffects(object oPC, string sTagName)
{
    int nResult = 0;

    if (GetIsObjectValid(oPC))
    {
//        int bDisableExtendedEditionFeatures = MK_INIT_GetAreEEFeaturesDisabled();
        int nNWNversion_GE_1_74 =  MK_VERSION_GetIsVersionGreaterEqual_1_74();

        effect eEff = GetFirstEffect(oPC);
        while (GetIsEffectValid(eEff))
        {
            int bRemoveEffect=FALSE;
            if (nNWNversion_GE_1_74)
            {
                bRemoveEffect = (GetEffectTag(eEff) == sTagName);
            }
            else
            {
                bRemoveEffect = (GetEffectType(eEff) == EFFECT_TYPE_CUTSCENEIMMOBILIZE
                     && GetEffectCreator(eEff) == oPC
                     && GetEffectSubType(eEff) == SUBTYPE_EXTRAORDINARY );
            }
            if (bRemoveEffect)
            {
                nResult++;
                RemoveEffect(oPC, eEff);
            }
            eEff = GetNextEffect(oPC);
        }

        if (nResult>0)
        {
            string s1="";
            string s2="s were";
            switch (nResult)
            {
            case 1:
                s1="One";
                s2=" was";
                break;
            case 2:
                s1="Two";
                break;
            case 3:
                s1="Three";
                break;
            default:
                s1=IntToString(nResult);
                break;
            }
            SendMessageToPC(oPC, s1 + " temporary effect" + s2 + " removed.");
        }
    }
    return nResult;
}

int MK_AddTemporaryEffects(object oPC, string sTagName, int bFreezePlayer)
{
    int nResult = 0;

    if (GetIsObjectValid(oPC))
    {
        int nNWNversion_GE_1_74 =  MK_VERSION_GetIsVersionGreaterEqual_1_74();
//        int bDisableExtendedEditionFeatures = MK_INIT_GetAreEEFeaturesDisabled();

        //* TODO: Light model to make changes easier to see
        effect eLight = EffectVisualEffect( VFX_DUR_LIGHT_WHITE_20);
        if (nNWNversion_GE_1_74)
        {
            SendMessageToPC(oPC, "Applying temporary light effect - will be removed when crafting dialog terminates.");
            eLight = TagEffect(eLight, MK_TAG_TEMP_EFFECT);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,eLight,oPC);
            nResult++;
        }
        else
        {
            float fDuration = GetLocalFloat(oPC, MK_LIGHTEFFECT_DURATION);
            if (fDuration<1.0)
            {
                fDuration = 120.0;
            }
            SendMessageToPC(oPC, "Applying temporary light effect - will disappear after "+IntToString(FloatToInt(fDuration))+" seconds.");
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eLight,oPC,fDuration);
            nResult++;
        }

        if (bFreezePlayer)
        {
            //* Immobilize player while crafting
            effect eImmob = EffectCutsceneImmobilize();
            eImmob = ExtraordinaryEffect(eImmob);
            if (nNWNversion_GE_1_74)
            {
                eImmob = TagEffect(eImmob, MK_TAG_TEMP_EFFECT);
            }
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,eImmob,oPC);
            SendMessageToPC(oPC, "Applying temporary freeze effect - will be removed when crafting dialog terminates.");
            nResult++;
        }
    }

    return nResult;
}

int MK_ModPart2StrRef(int nModPart)
{
   int nStrRef=-1;
   switch (nModPart)
    {
    case ITEM_APPR_ARMOR_MODEL_NECK:
        nStrRef = 7143;
        break;
    case ITEM_APPR_ARMOR_MODEL_LSHOULDER:
        nStrRef = 7150;
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHOULDER:
        nStrRef = 7146;
        break;
    case ITEM_APPR_ARMOR_MODEL_LBICEP:
        nStrRef = 7151;
        break;
    case ITEM_APPR_ARMOR_MODEL_RBICEP:
        nStrRef = 7147;
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOREARM:
        nStrRef = 7152;
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOREARM:
        nStrRef = 7148;
        break;
    case ITEM_APPR_ARMOR_MODEL_LHAND:
        nStrRef = 7153;
        break;
    case ITEM_APPR_ARMOR_MODEL_RHAND:
        nStrRef = 7149;
        break;
    case ITEM_APPR_ARMOR_MODEL_TORSO:
        nStrRef = 7144;
        break;
    case ITEM_APPR_ARMOR_MODEL_BELT:
        nStrRef = 6745;
        break;
    case ITEM_APPR_ARMOR_MODEL_PELVIS:
        nStrRef = 7145;
        break;
    case ITEM_APPR_ARMOR_MODEL_LTHIGH:
        nStrRef = 83350;
        break;
    case ITEM_APPR_ARMOR_MODEL_RTHIGH:
        nStrRef = 83351;
        break;
    case ITEM_APPR_ARMOR_MODEL_LSHIN:
        nStrRef = 83348;
        break;
    case ITEM_APPR_ARMOR_MODEL_RSHIN:
        nStrRef = 83349;
        break;
    case ITEM_APPR_ARMOR_MODEL_LFOOT:
        nStrRef = 83345;
        break;
    case ITEM_APPR_ARMOR_MODEL_RFOOT:
        nStrRef = 83346;
        break;
    case ITEM_APPR_ARMOR_MODEL_ROBE:
        nStrRef = 83691;
        break;
    }
    return nStrRef;
}



string MK_ModPart2String(int nModPart)
{
    string sReturn="";
    int nStrRef=MK_ModPart2StrRef(nModPart);
    if (nStrRef!=-1)
    {
        sReturn = GetStringByStrRef(nStrRef);
    }
    return sReturn;
}

string MK_CurrentModPart2String(object oPC)
{
    string sReturn;

    int nCurrentModPart1 = GetLocalInt(oPC,"X2_TAILOR_CURRENT_PART");
//    int nCurrentModPart2 = MK_GetCurrentModPart2(oPC);

    sReturn = MK_ModPart2String(nCurrentModPart1);
/*    if (nCurrentModPart2>=0)
    {
        sReturn = sReturn
           + "\\"
           + MK_ModPart2String(nCurrentModPart2);
    }*/
    return sReturn;
}

int MK_GetNumColorsFromModMode(int nModMode)
{
    switch (nModMode)
    {
    case X2_CI_MODMODE_ARMOR:
        return 6;
    }
    return 1;
}

int MK_CalculateColorIndex(int nIndex, int nPart)
{
    return (ITEM_APPR_ARMOR_NUM_COLORS + nPart*ITEM_APPR_ARMOR_NUM_COLORS) + nIndex;
}

void MK_SetAppearanceValue(object oItem, int nType, int nIndex, int nValue)
{
    string sVarName = "MK_APP_"+MK_IntToString(nType, 3, "0")+MK_IntToString(nIndex, 4, "0");
    if (nValue==255)
    {
        DeleteLocalInt(oItem, sVarName);
    }
    else
    {
        SetLocalInt(oItem, sVarName, nValue+1);
    }
}

int MK_GetAppearanceValue(object oItem, int nType, int nIndex)
{
    string sVarName = "MK_APP_"+MK_IntToString(nType, 3, "0")+MK_IntToString(nIndex, 4, "0");
    int nValue = GetLocalInt(oItem, sVarName);
    return nValue-1;
}

int MK_GetItemAppearance(object oItem, int nType, int nIndex)
{
    int nResult = GetItemAppearance(oItem, nType, nIndex);
    if ((nType==ITEM_APPR_TYPE_ARMOR_COLOR) && (nIndex>=ITEM_APPR_ARMOR_NUM_COLORS))
    {
        if (nResult==-1)
        {
            nResult = MK_GetAppearanceValue(oItem, nType, nIndex);
        }
        else
        {
            MK_DEBUG_TRACE("GetItemAppearance('"+GetName(oItem)+"', "+IntToString(nType)
                +", "+IntToString(nIndex)+") = "+IntToString(nResult)+" !!!");
//        int nResultQ = MK_GetAppearanceValue(oItem, nType, nIndex);
//        MK_DEBUG_TRACE("MK_GetItemAppearance('"+GetName(oItem)+"', "+IntToString(nType)
//            +", "+IntToString(nIndex)+"): GetItemAppearance="+IntToString(nResult)
//            +", AppearanceValue="+IntToString(nResultQ));
//        nResult = nResultQ;
        }
    }
    return nResult;
}

int MK_GetItemAppearance2(object oItem, int nType, int nIndex, int nIndex2)
{
    int nAppearance=-1;
    switch (nType)
    {
    case ITEM_APPR_TYPE_ARMOR_COLOR:
        nAppearance = GetItemAppearance(oItem, nType, nIndex);
        if (nIndex2!=-1)
        {
            if (MK_IAAM_GetIsBase(nIndex2))
            {
                nIndex = MK_CalculateColorIndex(nIndex, nIndex2);
            }
            else if (MK_IAAM_GetIsValid(nIndex2))
            {
                nIndex = MK_CalculateColorIndex(nIndex, MK_IAAM_GetPart(nIndex2, 0));
            }
            else
            {
                nIndex = -1;
            }
            if (nIndex!=-1)
            {
                int nValue = MK_GetAppearanceValue(oItem, nType, nIndex);
                if (nValue>=0)
                {
                    nAppearance = nValue;
                }
            }
        }
        break;
    case ITEM_APPR_TYPE_ARMOR_MODEL:
        if (MK_IAAM_GetIsValid(nIndex))
        {
            nIndex = MK_IAAM_GetPart(nIndex, 0);
            nAppearance = GetItemAppearance(oItem, nType, nIndex);
        }
        break;
    default:
        nAppearance = GetItemAppearance(oItem, nType, nIndex);
        break;
    }
    return nAppearance;
}

int MK_GetItemColor(object oPC, object oItem, int nType, int nIndex)
{
    int nAppearance;
    int nMaterial = MK_IAAC_GetColor(nIndex, 0);
    if (GetLocalInt(oPC, MK_PERPARTCOLORING))
    {
        int nPart = MK_GetCurrentModPart(oPC);
        nAppearance = MK_GetItemAppearance2(oItem, nType, nMaterial, nPart);
//        MK_DEBUG_TRACE("MK_GetItemColor('"+GetName(oItem)+"', nType="+IntToString(nType)+", nIndex="+IntToString(nIndex)
//            +", nMaterial="+IntToString(nMaterial)+", nPart="+IntToString(nPart)+")="+IntToString(nAppearance));
    }
    else
    {
        nAppearance = GetItemAppearance(oItem, nType, nMaterial);
//        MK_DEBUG_TRACE("MK_GetItemColor('"+GetName(oItem)+"', nType="+IntToString(nType)+", nIndex="+IntToString(nIndex)
//            +", nMaterial="+IntToString(nMaterial)+")="+IntToString(nAppearance));
    }
    return nAppearance;
}

int MK_GetIsPerPartColored(object oItem, int nType, int nIndex, int nPart)
{
    int nReturn=0;
//    MK_DEBUG_TRACE("MK_GetIsPerPartColored(nIndex="+IntToString(nIndex)
//        +", nPart="+IntToString(nPart)+")...");
    switch (nType)
    {
    case ITEM_APPR_TYPE_ARMOR_COLOR:
        if ((nIndex!=-1) && (nPart!=-1))
        {
            if (MK_IAAC_GetIsBase(nIndex) && MK_IAAM_GetIsBase(nPart))
            {
                if (MK_GetAppearanceValue(oItem, nType, MK_CalculateColorIndex(nIndex, nPart))>=0)
                {
                    nReturn = 1;
                }
            }
            else if (!MK_IAAM_GetIsBase(nPart))
            {
                int nPartCount = MK_IAAM_GetPartCount(nPart);
                int iModel;
                for (iModel=0; iModel<nPartCount; iModel++)
                {
                    int iPart = MK_IAAM_GetPart(nPart, iModel);
                    nReturn+=MK_GetIsPerPartColored(oItem, nType, nIndex, iPart);
                }
            }
            else
            {
                int nColorCount = MK_IAAC_GetColorCount(nIndex);
                int i;
                for (i=0; i<nColorCount; i++)
                {
                    int iIndex = MK_IAAC_GetColor(nIndex, i);
                    nReturn+=MK_GetIsPerPartColored(oItem, nType, iIndex, nPart);
                }
            }
        }
        else if ((nIndex!=-1) && (nPart==-1))
        {
            int iPart;
            for (iPart = 0; iPart<ITEM_APPR_ARMOR_NUM_MODELS; iPart++)
            {
                nReturn+=MK_GetIsPerPartColored(oItem, nType, nIndex, iPart);
            }
        }
        else if (nIndex==-1)
        {
            int iIndex;
            for (iIndex = 0; iIndex<ITEM_APPR_ARMOR_NUM_COLORS; iIndex++)
            {
                nReturn+=MK_GetIsPerPartColored(oItem, nType, iIndex, nPart);
            }
        }
        break;
    }
//    MK_DEBUG_TRACE("MK_GetIsPerPartColored(nIndex="+IntToString(nIndex)
//        +", nPart="+IntToString(nPart)+")="+IntToString(nReturn));
    return nReturn;
}

int MK_ClearOverrideColor(int nType, int nIndex, int nPart, int bCheck)
{
    object oPC = OBJECT_SELF;

    int nReturn = 0;

    int bMirrorUpdateDeactivated=FALSE;
    if ((nPart==-1) || (nIndex==-1))
    {
        if (MK_GetUpdateMirror(oPC))
        {
            bMirrorUpdateDeactivated=TRUE;
            MK_DeactivateMirrorUpdate(oPC, TRUE);
//            MK_DEBUG_TRACE("MK_ClearOverrideColor: mirror update deactivated!");
        }
    }

    switch (nType)
    {
    case ITEM_APPR_TYPE_ARMOR_COLOR:
        if ((nPart!=-1) && (nIndex!=-1))
        {
            object oNew = CIGetCurrentModItem(oPC);
            if (MK_IAAM_GetIsValid(nPart))
            {
                int iColor;
                int nColorCount = MK_IAAC_GetColorCount(nIndex);
                //    MK_DEBUG_TRACE("MK_DyeItem: iMaterialToDye="+IntToString(nMaterialToDye)+", nColorCount="+IntToString(nColorCount));
                for (iColor=0; iColor<nColorCount; iColor++)
                {
                    int iMaterial = MK_IAAC_GetColor(nIndex, iColor);

                    int nPartCount=MK_IAAM_GetPartCount(nPart);
                    int iModel;
                    for (iModel=0; iModel<nPartCount; iModel++)
                    {
                        int iPart = MK_IAAM_GetPart(nPart, iModel);

                        if ((!bCheck) || MK_GetIsPerPartColored(oNew, nType, iMaterial, iPart))
                        {
                            oNew = MK_GetDyedItem(oNew, iPart, iMaterial, 255, TRUE, TRUE);
                        }
                    }
                }
            }

//                int nNewIndex = MK_CalculateColorIndex(nIndex, nPart);
//                object oNew = MK_GetDyedItem(oItem, -1, nNewIndex, 255, TRUE, TRUE);
//            MK_DEBUG_TRACE("MK_CLearOverrideColor: override color cleared for nIndex="+IntToString(nIndex)+", nPart="+IntToString(nPart)+"!");

            CISetCurrentModItem(oPC, oNew);

            MK_EquipModifiedItem(oPC);

            nReturn = 1;
        }
        else if ((nPart!=-1) && (nIndex==-1))
        {
            int iIndex;
            for (iIndex=0; iIndex<ITEM_APPR_ARMOR_NUM_COLORS; iIndex++)
            {
                nReturn += MK_ClearOverrideColor(nType, iIndex, nPart, bCheck);
            }
        }
        else if (nPart==-1)
        {
            int iPart;
            for (iPart=0; iPart<ITEM_APPR_ARMOR_NUM_MODELS; iPart++)
            {
                nReturn += MK_ClearOverrideColor(nType, nIndex, iPart, bCheck);
            }
        }
        break;
    }

    if (bMirrorUpdateDeactivated)
    {
        // activate mirror update, update mirror and equip item
        MK_DeactivateMirrorUpdate(oPC, FALSE, TRUE);
//        MK_DEBUG_TRACE("MK_ClearOverrideColor: mirror update activated!");
    }
    return nReturn;
}

void MK_StartModifyItem(object oPC, object oItem, int bUseContainer, int bCreateMirror)
{
//    MK_VerifyCurrentModItem(oPC, "MK_StartModifyItem(start)");

    MK_DEBUG_TRACE("MK_StartModifyItem("+GetName(oPC)+", "+GetName(oItem)+", "+IntToString(bUseContainer)+")");
    MK_DEBUG_TRACE("> item is possessed by '"+GetName(GetItemPossessor(oItem))+"'.");

//    int nSlot = MK_GetCurrentInventorySlot(oPC);
    object oContainer = IPGetIPWorkContainer();
    if (GetIsObjectValid(oContainer))
    {
        MK_DEBUG_TRACE("> "+GetName(oContainer)+" is valid!");
    }

//    object oItem = GetItemInSlot(nSlot, oPC);

    object oBackup = MK_CopyItem(oItem, oContainer, TRUE);

    // Mark the backup item. In case of a multiplayer crash this can be used
    // to re-equip the backup item.
    // SetLocalInt(oBackup, "MK_CRAFTING_BACKUP", nSlot+1);
    CISetCurrentModBackup(oPC, oBackup);
    MK_DEBUG_TRACE("> backup item created on "+GetName(oContainer)+" and stored.");
    MK_DEBUG_TRACE("> backup item is possessed by '"+GetName(GetItemPossessor(oBackup))+"'.");

    if (bCreateMirror)
    {
        MK_SetModifyItemUseContainer(oPC, bUseContainer);
        if (bUseContainer)
        {
            MK_DEBUG_TRACE("> modifying item will use container "+GetName(oContainer)+" (hopefully)!");
            object oMirror = oItem;
            oItem = MK_CopyItem(oMirror, oContainer, TRUE);
            MK_SetCurrentModMirror(oPC, oMirror);
            SetLocalInt(oMirror, "MK_MIRRORITEM", 1);
            MK_DEBUG_TRACE("> mirror item created to reflect item changes.");
            MK_DEBUG_TRACE("> mirror item is possessed by '"+GetName(GetItemPossessor(oMirror))+"'.");
            MK_DEBUG_TRACE("> current item is possessed by '"+GetName(GetItemPossessor(oItem))+"'.");
        }
        else
        {
            MK_DEBUG_TRACE("> modifying item will use players inventory!");
            MK_SetCurrentModMirror(oPC, OBJECT_INVALID);
            MK_DEBUG_TRACE("> current item is possessed by '"+GetName(GetItemPossessor(oItem))+"'.");
        }
    }

    CISetCurrentModItem(oPC, oItem);
    MK_DEBUG_TRACE("> current mod item set.");
    MK_DEBUG_TRACE("> current mod item is '"+GetName(CIGetCurrentModItem(oPC))+"'.");
}

void MK_DupeItemFix(object oItem)
{
    itemproperty ip = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip))
    {
        RemoveItemProperty(oItem,ip);
        ip = GetNextItemProperty(oItem);
    }
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyLimitUseByClass(20),oItem);
    SetDescription(oItem,"This item was duped!");
    SetStolenFlag(oItem,TRUE);
    SetLocalInt(oItem,"DUPLICATED_ITEM",TRUE);
}

void MK_DestroyItem(object oItem)
{
    if (GetIsObjectValid(oItem))
    {
        SetLocalInt(oItem, "MK_ITEM_DESTROYED", TRUE);
        DestroyObject(oItem);
    }
}

int MK_SearchItem(object oPC, object oItem)
{
    if (GetIsObjectValid(oItem) && GetIsObjectValid(oPC))
    {
        int iSlot=0;
        for (iSlot=0; iSlot<=NUM_INVENTORY_SLOTS; iSlot++)
        {
            if (GetItemInSlot(iSlot, oPC) == oItem)
            {
                return iSlot;
            }
        }
    }
    return -1;
}

void MK_CancelModifyItem(object oPC)
{
    object oBackup = CIGetCurrentModBackup(oPC);
    object oItem = CIGetCurrentModItem(oPC);
    object oMirror = MK_GetCurrentModMirror(oPC);

    int nInventorySlot = MK_GetCurrentInventorySlot(oPC);

    int bUseContainer = GetIsObjectValid(oMirror);

    if (nInventorySlot == 256)
    {
        nInventorySlot = MK_SearchItem(oPC, (bUseContainer ? oMirror : oItem));
    }

    if (bUseContainer)
    {
        MK_DupeItemFix(oMirror);
        MK_DestroyItem(oMirror);
    }
    else
    {
        MK_DupeItemFix(oItem);
    }

    object oNew = MK_CopyItem(oBackup, oPC, TRUE);

    MK_DestroyItem(oItem);
    DestroyObject(oBackup);

    AssignCommand(oPC,ClearAllActions(TRUE));

    if (nInventorySlot != -1)
    {
        AssignCommand(oPC, ActionEquipItem(oNew,nInventorySlot));
    }
}

void MK_FinishModifyItem(object oPC)
{
    object oBackup = CIGetCurrentModBackup(oPC);
    object oMirror = MK_GetCurrentModMirror(oPC);
    object oItem;
    object oNew;

    if (GetIsObjectValid(oMirror))
    {
        DestroyObject(oMirror);
        object oItem = CIGetCurrentModItem(oPC);
        oNew = MK_CopyItem(oItem, oPC, TRUE);
        DestroyObject(oItem);
    }
    else
    {
        oNew = CIGetCurrentModItem(oPC);
    }

    AssignCommand(oPC,ClearAllActions(TRUE));
    int nInventorySlot = MK_GetCurrentInventorySlot(oPC);
    if (nInventorySlot != -1)
    {
        AssignCommand(oPC, ActionEquipItem(oNew,nInventorySlot));
    }

    switch (CIGetCurrentModMode(oPC))
    {
    case MK_CI_MODMODE_ITEM:
        break;
    default:
        //-------------------------------------------------------------------
        // This is to work around a problem with temporary item properties
        // sometimes staying around when they are on a cloned item.
        //-------------------------------------------------------------------
        if (!GetLocalInt(OBJECT_SELF, "MK_KEEP_TEMP_ITEM_PROPS"))
        {
            IPRemoveAllItemProperties(oNew,DURATION_TYPE_TEMPORARY);
        }
        break;
    }

    // remove backup
    DestroyObject(oBackup);
}

void MK_EquipModifiedItem(object oPC)
{
    MK_DEBUG_TRACE("MK_EquipModifiedItem("+GetName(oPC)+")");

//    MK_DEBUG_TRACE("> GetModifyItemUseContainer: "+IntToString(MK_GetModifyItemUseContainer(oPC))+".");

    if (MK_GetModifyItemUseContainer(oPC))
    {
//        MK_DEBUG_TRACE("> GetCurrentItemIsModified: "+IntToString(MK_GetCurrentItemIsModified(oPC, FALSE))+".");
        if (MK_GetUpdateMirror(oPC))
        {
//            MK_DEBUG_TRACE("> GetUpdateMirror: "+IntToString(MK_GetUpdateMirror(oPC))+".");
            if (MK_GetCurrentItemIsModified(oPC))
            {
                object oItem = CIGetCurrentModItem(oPC);
                AssignCommand(oPC,ClearAllActions(TRUE));
                int nInventorySlot = MK_GetCurrentInventorySlot(oPC);

                object oMirror = MK_GetCurrentModMirror(oPC);
                if (GetIsObjectValid(oMirror))
                {
                    DestroyObject(oMirror);
                }
                object oNew = MK_CopyItem(oItem, oPC, TRUE);
                MK_DEBUG_TRACE("> modified item copied to PC!");
                MK_SetCurrentModMirror(oPC, oNew);
                MK_DEBUG_TRACE("> copy set as mirror item");
                SetLocalInt(oNew, "MK_MIRRORITEM", 1);
                AssignCommand(oPC, ActionEquipItem(oNew, nInventorySlot));
                MK_DEBUG_TRACE("> mirror item equipped!");
            }
        }
    }
    else
    {
        object oItem = CIGetCurrentModItem(oPC);
        AssignCommand(oPC,ClearAllActions(TRUE));
        int nInventorySlot = MK_GetCurrentInventorySlot(oPC);
        AssignCommand(oPC, ActionEquipItem(oItem, nInventorySlot));
        MK_DEBUG_TRACE("> modified item equipped!");
    }
}

void MK_VerifyCurrentModItem(object oPC, string s)
{
    object oItem = CIGetCurrentModItem(oPC);
    if (GetIsObjectValid(oItem))
    {
        int bMirror = GetLocalInt(oItem, "MK_MIRRORITEM");
        if (bMirror)
            MK_DEBUG_TRACE(s+" :MIRROR : current mod item: '"+GetName(oItem)+"', possessed by '"+GetName(GetItemPossessor(oItem))+"'.");
        else
            MK_DEBUG_TRACE(s+" :OK     : current mod item: '"+GetName(oItem)+"', possessed by '"+GetName(GetItemPossessor(oItem))+"'.");
    }
    else
    {
            MK_DEBUG_TRACE(s+" :INVALID: current mod item is invalid.");
    }
}

int MK_GetModifyShieldMode(object oPC)
{
    int nReturn = GetLocalInt(oPC, "MK_MODIFYSHIELD_MODE");
    switch (nReturn)
    {
    case 1:
    case 2:
        break;
    default:
        nReturn = (MK_VERSION_GetIsVersionGreaterEqual_1_74(oPC) ? 2 : 1);
        break;
    }
    return nReturn;
}

void MK_IM_NextPart(object oPC, object oItem, int nPart)
{
    if(GetIsObjectValid(oItem))
    {
        object oNew = OBJECT_INVALID;

        switch (CIGetCurrentModMode(oPC))
        {
        case X2_CI_MODMODE_ARMOR:
            oNew = MK_GetModifiedArmor(oItem, nPart, X2_IP_ARMORTYPE_NEXT, TRUE);
            break;
        case X2_CI_MODMODE_WEAPON:
            oNew = MK_GetModifiedWeapon(oItem, nPart, X2_IP_WEAPONTYPE_NEXT, TRUE);
            MK_DEBUG_TRACE("MK_IM_NextPart: nAppearance="+IntToString(GetItemAppearance(oNew, ITEM_APPR_TYPE_SIMPLE_MODEL, nPart)));
//            CISetCurrentModItem(oPC,oNew);
            break;
        case MK_CI_MODMODE_CLOAK:
            oNew = MK_GetModifiedCloak(oItem, nPart, MK_IP_ITEMTYPE_NEXT, TRUE);
//            CISetCurrentModItem(oPC,oNew);
            break;
        case MK_CI_MODMODE_HELMET:
            oNew = MK_GetModifiedHelmet(oItem, MK_IP_ITEMTYPE_NEXT, TRUE);
//            CISetCurrentModItem(oPC,oNew);
            break;
        case MK_CI_MODMODE_SHIELD:
            switch (MK_GetModifyShieldMode(oPC))
            {
            case 1:
                oNew = MK_GetModifiedShield(oItem, MK_IP_ITEMTYPE_NEXT, TRUE);
                break;
            case 2:
                oNew = MK_GetModifiedWeapon(oItem, 0, X2_IP_WEAPONTYPE_NEXT, TRUE);
                break;
            }
//            CISetCurrentModItem(oPC,oNew);
            break;
        }
        if (GetIsObjectValid(oNew))
        {
            CISetCurrentModItem(oPC,oNew);
            MK_EquipModifiedItem(oPC);
        }
    }
}

void MK_IM_PrevPart(object oPC, object oItem, int nPart)
{
    if(GetIsObjectValid(oItem))
    {
        object oNew = OBJECT_INVALID;

        switch (CIGetCurrentModMode(oPC))
        {
        case X2_CI_MODMODE_ARMOR:
            oNew = MK_GetModifiedArmor(oItem, nPart, X2_IP_ARMORTYPE_PREV, TRUE);
            break;
        case X2_CI_MODMODE_WEAPON:
            oNew = MK_GetModifiedWeapon(oItem, nPart, X2_IP_WEAPONTYPE_PREV, TRUE);
            break;
        case MK_CI_MODMODE_CLOAK:
            oNew = MK_GetModifiedCloak(oItem, nPart, MK_IP_ITEMTYPE_PREV, TRUE);
           break;
        case MK_CI_MODMODE_HELMET:
            oNew = MK_GetModifiedHelmet(oItem, MK_IP_ITEMTYPE_PREV, TRUE);
            break;
        case MK_CI_MODMODE_SHIELD:
            switch (MK_GetModifyShieldMode(oPC))
            {
            case 1:
                oNew = MK_GetModifiedShield(oItem, MK_IP_ITEMTYPE_PREV, TRUE);
                break;
            case 2:
                oNew = MK_GetModifiedWeapon(oItem, 0, X2_IP_WEAPONTYPE_PREV, TRUE);
                break;
            }
            break;
        }
        if (GetIsObjectValid(oNew))
        {
            CISetCurrentModItem(oPC,oNew);
            MK_EquipModifiedItem(oPC);
        }
    }
}

void MK_IM_ClearPart(object oPC, object oItem, int nPart)
{
    if(GetIsObjectValid(oItem))
    {
        object oNew = OBJECT_INVALID;

        switch (CIGetCurrentModMode(oPC))
        {
        case X2_CI_MODMODE_ARMOR:
            oNew = MK_GetModifiedArmor(oItem, nPart, MK_IP_ITEMTYPE_CLEAR, TRUE);
            break;
        case MK_CI_MODMODE_CLOAK:
            oNew = MK_GetModifiedCloak(oItem, nPart, MK_IP_ITEMTYPE_CLEAR, TRUE);
            break;
        }
        if (GetIsObjectValid(oNew))
        {
            CISetCurrentModItem(oPC,oNew);
            MK_EquipModifiedItem(oPC);
        }
    }
}

void MK_IM_OppositePart(object oPC, object oItem, int nPart)
{
    if(GetIsObjectValid(oItem))
    {
        object oNew = OBJECT_INVALID;

        switch (CIGetCurrentModMode(oPC))
        {
        case X2_CI_MODMODE_ARMOR:
            if (MK_IAAM_GetHasOpposite(nPart))
            {
                oNew = MK_GetModifiedArmor(oItem, nPart, MK_IP_ITEMTYPE_OPPOSITE, TRUE);
            }
            break;
        }
        if (GetIsObjectValid(oNew))
        {
            CISetCurrentModItem(oPC,oNew);
            MK_EquipModifiedItem(oPC);
        }
    }
}

void MK_IM_ToggleVisibility(object oPC, object oItem)
{
    if (GetIsObjectValid(oItem))
    {
        MK_SetHiddenWhenEquipped(oItem, !MK_GetHiddenWhenEquipped(oItem));
        MK_SetItemIsModified(oItem, TRUE);
        MK_EquipModifiedItem(oPC);
    }
}

int MK_IM_GetColorCount(object oPC)
{
    int nColorCount = GetLocalInt(oPC, "MK_IM_COLOR_COUNT");
    if (nColorCount==0)
    {
        nColorCount = MK_Get2DALength("mk_color", "Cloth");
        SetLocalInt(oPC, "MK_IM_COLOR_COUNT", nColorCount);
    }
    return nColorCount;
}

void MK_IM_NextColor(object oPC, object oItem, int nPart)
{
    if(GetIsObjectValid(oItem))
    {
        object oNew = OBJECT_INVALID;

        switch (CIGetCurrentModMode(oPC))
        {
        case X2_CI_MODMODE_ARMOR:
        case MK_CI_MODMODE_CLOAK:
        case MK_CI_MODMODE_HELMET:
        {
            int iMaterialToDye = GetLocalInt(oPC, "MK_MaterialToDye");
            int iColor = MK_GetItemColor(oPC, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterialToDye);
            int nColors = MK_IM_GetColorCount(oPC);
//            int nColors = GetLocalInt(OBJECT_SELF, "MK_NUMBER_OF_COLORS_PER_GROUP") *
//                            GetLocalInt(OBJECT_SELF, "MK_NUMBER_OF_COLOR_GROUPS");

//            MK_DEBUG_TRACE("MK_IM_NextColor: iMaterialToDye="+IntToString(iMaterialToDye)
//                +", oldColor="+IntToString(iColor)+", newColor="+IntToString((iColor+1) % 176));

            iColor = (iColor+1) % nColors;

            MK_DyeItem(oPC,iMaterialToDye,iColor);

            break;
        }
        case X2_CI_MODMODE_WEAPON:
        {
            oNew = MK_GetModifiedWeapon(oItem, nPart, MK_IP_WEAPONCOLOR_NEXT, TRUE);
            break;
        }
        case MK_CI_MODMODE_SHIELD:
            oNew = MK_GetModifiedWeapon(oItem, 0, MK_IP_WEAPONCOLOR_NEXT, TRUE);
            break;
        }

        if (GetIsObjectValid(oNew))
        {
            CISetCurrentModItem(oPC,oNew);
            MK_EquipModifiedItem(oPC);
        }
    }
}

void MK_IM_PrevColor(object oPC, object oItem, int nPart)
{
    if(GetIsObjectValid(oItem))
    {
        object oNew = OBJECT_INVALID;

        switch (CIGetCurrentModMode(oPC))
        {
        case X2_CI_MODMODE_ARMOR:
        case MK_CI_MODMODE_CLOAK:
        case MK_CI_MODMODE_HELMET:
        {
            int iMaterialToDye = GetLocalInt(oPC, "MK_MaterialToDye");
            int iColor = MK_GetItemColor(oPC, oItem, ITEM_APPR_TYPE_ARMOR_COLOR, iMaterialToDye);
            int nColors = MK_IM_GetColorCount(oPC);
//            int nColors = GetLocalInt(OBJECT_SELF, "MK_NUMBER_OF_COLORS_PER_GROUP") *
//                            GetLocalInt(OBJECT_SELF, "MK_NUMBER_OF_COLOR_GROUPS");
            iColor = (iColor+nColors-1) % nColors;

            MK_DyeItem(oPC,iMaterialToDye,iColor);
            break;
        }
        case X2_CI_MODMODE_WEAPON:
        {
            oNew = MK_GetModifiedWeapon(oItem, nPart, MK_IP_WEAPONCOLOR_PREV, TRUE);
            break;
        }
        case MK_CI_MODMODE_SHIELD:
            oNew = MK_GetModifiedWeapon(oItem, 0, MK_IP_WEAPONCOLOR_PREV, TRUE);
            break;
        }

        if (GetIsObjectValid(oNew))
        {
            CISetCurrentModItem(oPC,oNew);
            MK_EquipModifiedItem(oPC);
        }
    }
}

/*
void main()
{
}
/**/

#include "_inc_fshop_barb"
#include "_inc_fshop_rang"
#include "_inc_fshop_spell"
#include "_inc_factions"
#include "_inc_fshop_bg"
#include "_inc_war_class"

const int DIALOG_FAMESHOP_TYPE_BUY_CLASS                    = 1;
const int DIALOG_FAMESHOP_TYPE_BUY_LICENSE                  = 2;
const int DIALOG_FAMESHOP_TYPE_REFRESH                      = 3;
const int DIALOG_FAMESHOP_TYPE_BUY_GENERAL_FEATS            = 4;
const int DIALOG_FAMESHOP_TYPE_BUY_EPIC_TOUGHNESS           = 5;
const int DIALOG_FAMESHOP_TYPE_BUY_CITY_TELEPORT            = 6;
const int DIALOG_FAMESHOP_TYPE_BUY_LEADER_TELEPORT          = 7;
const int DIALOG_FAMESHOP_TYPE_BUY_DISPEL_DEFENCE           = 8;
const int DIALOG_FAMESHOP_TYPE_BUY_DISPEL_NUMBER_BONUS      = 9;
const int DIALOG_FAMESHOP_TYPE_BUY_DISPEL_ATTACK_BONUS      = 10;
const int DIALOG_FAMESHOP_TYPE_BUY_SPELL_UPGRADES           = 11;
const int DIALOG_FAMESHOP_TYPE_BUY_FAVORED_ENEMY            = 12;
const int DIALOG_FAMESHOP_TYPE_BUY_BARBARIAN_RAGE_DC        = 13;
const int DIALOG_FAMESHOP_TYPE_BUY_BARBARIAN_RAGE_INTERVAL  = 14;
const int DIALOG_FAMESHOP_TYPE_BUY_DIVINE_BUFFER            = 15;
const int DIALOG_FAMESHOP_TYPE_BUY_DIVINE_BUFFER_BONUSES    = 16;
const int DIALOG_FAMESHOP_TYPE_BUY_EMPOWERED_HIT_BONUSES    = 17;
const int DIALOG_FAMESHOP_TYPE_BUY_CRITICAL_HIT_BONUSES     = 18;
const int DIALOG_FAMESHOP_TYPE_BUY_BG_UPGRADES              = 19;
const int DIALOG_FAMESHOP_TYPE_BUY_ONHIT_UPGRADES           = 20;
const int DIALOG_FAMESHOP_TYPE_BUY_WARLORD_UPGRADES         = 21;

// get weapon resref from dialog parameter
string GetFameWeaponResref(string sDialogParameter);

//
void fameshop_BuyCityPort(object oPC, int iCost);

//
int fameshop_CreateTeleport(object oPC, string sResref);

//
void fameshop_BuyLeaderPort(object oPC, int iCost);

//
int fameshop_ConvertScriptParamToSpellID(string sScriptParam);

//
void fameshop_BuyDivineBuffer(object oPC, int iCost);

void main()
{
    int iDialogFameShopType = StringToInt(GetScriptParam("DIALOG_FAMESHOP_TYPE"));
    switch (iDialogFameShopType)
    {
        case DIALOG_FAMESHOP_TYPE_BUY_CLASS:
            /*TryToUnlockClassLevel(GetLastSpeaker(),
                                        StringToInt(GetScriptParam("CLASS_TYPE")),
                                        StringToInt(GetScriptParam("CLASS_UNLOCK_LEVEL")),
                                        StringToInt(GetScriptParam("CLASS_COST")),
                                        StringToInt(GetScriptParam("CLASS_MIN_REQ_LEVEL")));*/
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_LICENSE:
            TryToBuyFameWeapon(GetLastSpeaker(), GetFameWeaponResref(GetScriptParam("FAME_WEAPON_TYPE")), StringToInt(GetScriptParam("LICENSE_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_REFRESH:
        {
            object oLastSpeaker = GetLastSpeaker();
            RefreshTokensForPlayer(oLastSpeaker);
            RefreshGeneralFeatTokens(oLastSpeaker);
            RefreshTokensForPlayerDispel(oLastSpeaker);
            RefreshTokensForBarbarianRage(oLastSpeaker);
            RefreshTokensForPlayerFavoredEnemy(oLastSpeaker);
            RefreshTokensForSpellUpgrades(oLastSpeaker);
            fshop_bg_RefreshTokens(oLastSpeaker);
            WarlordFameshopRefreshTokens(oLastSpeaker);
        }
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_GENERAL_FEATS:
            TryToBuyGeneralFeat(GetLastSpeaker(),
                                        StringToInt(GetScriptParam("GENERAL_FEAT_BIT_VALUE")),
                                        StringToInt(GetScriptParam("GENERAL_FEAT_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_EPIC_TOUGHNESS:
            if (TryToUnlockEpicToughness(GetLastSpeaker(), StringToInt(GetScriptParam("EPIC_TOUGHNESS_COST")), StringToInt(GetScriptParam("EPIC_TOUGHNESS_LEVEL"))))
                ApplyEpicToughnessBonus(GetLastSpeaker(), StringToInt(GetScriptParam("EPIC_TOUGHNESS_LEVEL")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_CITY_TELEPORT:
            fameshop_BuyCityPort(GetLastSpeaker(), StringToInt(GetScriptParam("CITY_TELEPORT_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_LEADER_TELEPORT:
            fameshop_BuyLeaderPort(GetLastSpeaker(), StringToInt(GetScriptParam("LEADER_TELEPORT_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_DISPEL_DEFENCE:
            TryToBuyDefenceDCBonus(GetLastSpeaker(),
                                        StringToInt(GetScriptParam("DISPEL_DEFENCE_BONUS")),
                                        StringToInt(GetScriptParam("DISPEL_DEFENCE_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_DISPEL_NUMBER_BONUS:
            TryToBuyDispellingSpellsBonus(GetLastSpeaker(),
                                        fameshop_ConvertScriptParamToSpellID(GetScriptParam("DISPEL_TYPE")),
                                        StringToInt(GetScriptParam("DISPEL_NUMBER_BONUS")),
                                        StringToInt(GetScriptParam("DISPEL_NUMBER_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_DISPEL_ATTACK_BONUS:
            TryToUnlockDispelBonusDC(GetLastSpeaker(),
                                        fameshop_ConvertScriptParamToSpellID(GetScriptParam("DISPEL_TYPE")),
                                        StringToInt(GetScriptParam("DISPEL_ATTACK_BONUS")),
                                        StringToInt(GetScriptParam("DISPEL_ATTACK_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_SPELL_UPGRADES:
            TryToUnlockSpellUpgradeLevel(GetLastSpeaker(),
                                        fameshop_ConvertScriptParamToSpellID(GetScriptParam("SPELL_FOR_UPGRADE")),
                                        StringToInt(GetScriptParam("SPELL_UPGRADE_LEVEL")),
                                        StringToInt(GetScriptParam("SPELL_UPGRADE_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_FAVORED_ENEMY:
            TryToBuyFavoredEnemyFeat(GetLastSpeaker(),
                                        StringToInt(GetScriptParam("FAVORED_ENEMY_TYPE")),
                                        StringToInt(GetScriptParam("FAVORED_ENEMY_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_BARBARIAN_RAGE_DC:
            TryToBuyRageDC(GetPCSpeaker(),
                                        StringToInt(GetScriptParam("RAGE_DC_WANTED_BONUS_LEVEL")),
                                        StringToInt(GetScriptParam("RAGE_DC_REQUIRED_BONUS_LEVEL")),
                                        StringToInt(GetScriptParam("RAGE_DC_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_BARBARIAN_RAGE_INTERVAL:
            TryToBuyRageInterval(GetPCSpeaker(),
                                        StringToInt(GetScriptParam("RAGE_INTERVAL_WANTED_BONUS_LEVEL")),
                                        StringToInt(GetScriptParam("RAGE_INTERVAL_REQUIRED_BONUS_LEVEL")),
                                        StringToInt(GetScriptParam("RAGE_INTERVAL_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_DIVINE_BUFFER:
            fameshop_BuyDivineBuffer(GetLastSpeaker(), StringToInt(GetScriptParam("DIVINE_BUFFER_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_DIVINE_BUFFER_BONUSES:
            TryToBuyDivineBufferBonusSpells(GetLastSpeaker(),
                                        StringToInt(GetScriptParam("DIVINE_BUFFER_WANTED_BONUS_LEVEL")),
                                        StringToInt(GetScriptParam("DIVINE_BUFFER_REQUIRED_BONUS_LEVEL")),
                                        StringToInt(GetScriptParam("DIVINE_BUFFER_BONUS_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_EMPOWERED_HIT_BONUSES:
            TryToBuyEmpoweredHit(GetLastSpeaker(),
                                        StringToInt(GetScriptParam("EMPOWERED_HIT_BIT_VALUE")),
                                        StringToInt(GetScriptParam("EMPOWERED_HIT_BONUS_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_CRITICAL_HIT_BONUSES:
            TryToBuyCriticalHitRange(GetLastSpeaker(),
                                        StringToInt(GetScriptParam("CRITICAL_HIT_BIT_VALUE")),
                                        StringToInt(GetScriptParam("CRITICAL_HIT_BONUS_COST")));
            AssignCommand(GetLastSpeaker(), DelayCommand(0.0, ExecuteScript("_mod_instant_eff", GetLastSpeaker())));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_BG_UPGRADES:
            fshop_bg_TryToActivateBit(GetLastSpeaker(),
                                        StringToInt(GetScriptParam("BG_UPGRADE_BIT_VALUE")),
                                        StringToInt(GetScriptParam("BG_UPGRADE_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_ONHIT_UPGRADES:
            TryToUnlockCustomOnhitBonus(GetLastSpeaker(),
                                        fameshop_ConvertScriptParamToSpellID(GetScriptParam("SPELL_FOR_UPGRADE")),
                                        StringToInt(GetScriptParam("SPELL_UPGRADE_LEVEL")),
                                        StringToInt(GetScriptParam("SPELL_UPGRADE_COST")));
        break;
        case DIALOG_FAMESHOP_TYPE_BUY_WARLORD_UPGRADES:
            WarlordFameshopTryToActivateBit(GetLastSpeaker(),
                                        StringToInt(GetScriptParam("WARLORD_UPGRADE_BIT_VALUE")),
                                        StringToInt(GetScriptParam("WARLORD_UPGRADE_COST")));
        break;
        default:
            WriteTimestampedLogEntry("DLG_FAMESHOP.NSS received unknown script parameter 'DIALOG_FAMESHOP_TYPE'. Value = " +
                                      GetScriptParam("DIALOG_FAMESHOP_TYPE") + ". Expected value above zero.");
    }
}

string GetFameWeaponResref(string sDialogParameter)
{
    if      (sDialogParameter == "CONST_FAME_GREATSWORD")
        return CONST_FAME_GREATSWORD;
    else if (sDialogParameter == "CONST_FAME_LONGSWORD")
        return CONST_FAME_LONGSWORD;
    else if (sDialogParameter == "CONST_FAME_WHIP")
        return CONST_FAME_WHIP;
    else if (sDialogParameter == "CONST_FAME_BATTLEAXE")
        return CONST_FAME_BATTLEAXE;
    else if (sDialogParameter == "CONST_FAME_MORNINGSTAR")
        return CONST_FAME_MORNINGSTAR;
    else if (sDialogParameter == "CONST_FAME_GAUNTLET_1")
        return CONST_FAME_GAUNTLET_1;
    else if (sDialogParameter == "CONST_FAME_SCIMITAR")
        return CONST_FAME_SCIMITAR;
    else if (sDialogParameter == "CONST_FAME_GREATAXE")
        return CONST_FAME_GREATAXE;
    else if (sDialogParameter == "CONST_FAME_DAGGER")
        return CONST_FAME_DAGGER;
    else if (sDialogParameter == "CONST_FAME_GAUNTLET_2")
        return CONST_FAME_GAUNTLET_2;
    else if (sDialogParameter == "CONST_FAME_KUKRI")
        return CONST_FAME_KUKRI;
    else if (sDialogParameter == "CONST_FAME_KATANA")
        return CONST_FAME_KATANA;
    else if (sDialogParameter == "CONST_FAME_RAPIER")
        return CONST_FAME_RAPIER;
    else if (sDialogParameter == "CONST_FAME_TWO_BLADED_SWORD")
        return CONST_FAME_TWO_BLADED_SWORD;
    else if (sDialogParameter == "CONST_FAME_SHORT_SWORD")
        return CONST_FAME_SHORT_SWORD;
    else if (sDialogParameter == "CONST_FAME_HANDAXE")
        return CONST_FAME_HANDAXE;
    else if (sDialogParameter == "CONST_FAME_SCYTHE")
        return CONST_FAME_SCYTHE;
    else if (sDialogParameter == "CONST_FAME_WARHAMMER")
        return CONST_FAME_WARHAMMER;
    else if (sDialogParameter == "CONST_FAME_BASTARD_SWORD")
        return CONST_FAME_BASTARD_SWORD;
    else if (sDialogParameter == "CONST_FAME_DOUBLE_AXE")
        return CONST_FAME_DOUBLE_AXE;
    else if (sDialogParameter == "CONST_FAME_DWARVEN_WARAXE")
        return CONST_FAME_DWARVEN_WARAXE;
    else if (sDialogParameter == "CONST_FAME_HALBERD")
        return CONST_FAME_HALBERD;
    else if (sDialogParameter == "CONST_FAME_DIRE_MACE")
        return CONST_FAME_DIRE_MACE;
    else if (sDialogParameter == "CONST_FAME_HEAVY_FLAIL")
        return CONST_FAME_HEAVY_FLAIL;
    else if (sDialogParameter == "CONST_FAME_TRIDENT")
        return CONST_FAME_TRIDENT;
    else if (sDialogParameter == "CONST_FAME_KAMA")
        return CONST_FAME_KAMA;
    else if (sDialogParameter == "CONST_FAME_MACE")
        return CONST_FAME_MACE;
    else if (sDialogParameter == "CONST_FAME_LIGHT_FLAIL")
        return CONST_FAME_LIGHT_FLAIL;
    else if (sDialogParameter == "CONST_FAME_LIGHT_HAMMER")
        return CONST_FAME_LIGHT_HAMMER;
    else if (sDialogParameter == "CONST_FAME_SHORTBOW")
        return CONST_FAME_SHORTBOW;
    else if (sDialogParameter == "CONST_FAME_LONGBOW")
        return CONST_FAME_LONGBOW;

    else
        return "";
}

void fameshop_BuyCityPort(object oPC, int iCost)
{
    if(MIN_TOTAL_FAME_FOR_LESSER_LOOT_ACCESS > factions_GetTotalFactionsFame())
    {
        SendMessageToPC(oPC, "Not yet available for purchase.");
        return;
    }
    int iFreeFame = GetFreeFame(oPC);
    if(iFreeFame >= iCost)
    {
        int iResult = FALSE;
        if      (players_GetFaction(oPC) == FACTION_EMPIRE)
            iResult = fameshop_CreateTeleport(oPC, "fl_tp_arabel_u");
        else if (players_GetFaction(oPC) == FACTION_UNDERDARK)
            iResult = fameshop_CreateTeleport(oPC, "fl_tp_kulg_u");
        else if (players_GetFaction(oPC) == FACTION_IRON_THRONE)
            iResult = fameshop_CreateTeleport(oPC, "fl_tp_reno_u");
        else if (players_GetFaction(oPC) == FACTION_DRAGON_CULT)
            iResult = fameshop_CreateTeleport(oPC, "fl_tp_cult_u");

        if (iResult)
        {
            SpendFame(oPC, iCost);
            RefreshTokensForPlayer(oPC);
        }
        else
            SendMessageToPC(oPC, "Your character does not belong to any of the factions");
    }
    else
        SendMessageToPC(oPC, "Unlock failed: not enough fame. Need: " + IntToString(iCost - iFreeFame));
}

int fameshop_CreateTeleport(object oPC, string sResref)
{
    if(!GetIsObjectValid(generic_FindResrefInInventory(oPC, sResref)))
    {
        CreateItemOnObject(sResref, oPC);
        return TRUE;
    }
    else
    {
        SendMessageToPC(oPC, "This upgrade already been purchased.");
        return FALSE;
    }
}

void fameshop_BuyLeaderPort(object oPC, int iCost)
{
    if(MIN_TOTAL_FAME_FOR_GREATER_LOOT_ACCESS > factions_GetTotalFactionsFame())
    {
        SendMessageToPC(oPC, "Not yet available for purchase.");
        return;
    }

    int iFreeFame = GetFreeFame(oPC);

    if(iFreeFame >= iCost)
    {
        if (!GetIsObjectValid(generic_FindResrefInInventory(oPC, "fl_tp_leader_u")))
        {
            CreateItemOnObject("fl_tp_leader_u", oPC);
            SpendFame(oPC, iCost);
            RefreshTokensForPlayer(oPC);
        }
        else
        {
            SendMessageToPC(oPC, "This upgrade already been purchased.");
            return;
        }
    }
    else
    {
        SendMessageToPC(oPC, "Unlock failed: not enough fame. Need: " + IntToString(iFreeFame));
    }
}

int fameshop_ConvertScriptParamToSpellID(string sScriptParam)
{
    if      (sScriptParam == "SPELL_LESSER_DISPEL")                 return SPELL_LESSER_DISPEL;
    else if (sScriptParam == "SPELL_DISPEL_MAGIC")                  return SPELL_DISPEL_MAGIC;
    else if (sScriptParam == "SPELL_GREATER_DISPELLING")            return SPELL_GREATER_DISPELLING;
    else if (sScriptParam == "SPELL_MORDENKAINENS_DISJUNCTION")     return SPELL_MORDENKAINENS_DISJUNCTION;
    else if (sScriptParam == "SPELL_DEAFENING_CLANG")               return SPELL_DEAFENING_CLANG;
    else if (sScriptParam == "SPELL_INFERNO")                       return SPELL_INFERNO;
    else if (sScriptParam == "SPELL_EARTHQUAKE")                    return SPELL_EARTHQUAKE;
    else if (sScriptParam == "SPELL_BARD_SONG")                     return SPELL_BARD_SONG;
    // wipe 26
    else if (sScriptParam == "SPELL_ASSASSINATION_MARK")            return SPELL_ASSASSINATION_MARK;
    else if (sScriptParam == "SPELL_DARK_HIT")                      return SPELL_DARK_HIT;
    else if (sScriptParam == "SPELL_OPEN_WOUNDS")                   return SPELL_OPEN_WOUNDS;
    else if (sScriptParam == "SPELL_PAINFUL_HIT")                   return SPELL_PAINFUL_HIT;
    else if (sScriptParam == "SPELL_DARK_STRIKE")                   return SPELL_DARK_STRIKE;
    else if (sScriptParam == "SPELL_SCARE")                         return SPELL_SCARE;
    else if (sScriptParam == "SPELL_CORMYR_SAYANARA")               return SPELL_CORMYR_SAYANARA;
    else if (sScriptParam == "SPELL_DEVASTATING_CRITICAL_1")        return SPELL_DEVASTATING_CRITICAL_1;
    else
        return FALSE;
}

void fameshop_BuyDivineBuffer(object oPC, int iCost)
{
    int iFreeFame = GetFreeFame(oPC);

    if(iFreeFame >= iCost)
    {
        if (!GetIsObjectValid(GetItemPossessedBy(oPC, DIVINE_BUFFER_ITEM_TAG)))
        {
            CreateItemOnObject(DIVINE_BUFFER_ITEM_TAG, oPC);
            SpendFame(oPC, iCost);
            RefreshTokensForPlayer(oPC);
        }
        else
        {
            SendMessageToPC(oPC, "This upgrade already been purchased.");
            return;
        }
    }
    else
        SendMessageToPC(oPC, "Unlock failed: not enough fame. Need: " + IntToString(iFreeFame));
}

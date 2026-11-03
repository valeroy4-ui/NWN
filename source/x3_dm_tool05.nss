#include "nwnx_effect"
#include "_inc_db_funcs"
#include "nwnx_feedback"
#include "nwnx_creature"
#include "nwnx_damage"
#include "_inc_generic"
#include "nwnx_events"
#include "nwnx_admin"
#include "_inc_appearance"
#include "_inc_spellbook"
#include "x3_inc_skin"
#include "nwnx_encounter"
#include "nw_inc_nui"
#include "nw_inc_nui_insp"
#include "_inc_obelisk"
#include "nwnx_feat"
#include "_inc_guard_spawn"
#include "_inc_loot"
#include "_inc_runes"
#include "_inc_champ_boss"
#include "_inc_chat"


    const int PALETTE_CATEGORY_BLUE     = 198;
    const int PALETTE_CATEGORY_GREEN    = 199;
    const int PALETTE_CATEGORY_PURPLE   = 200;
    const int PALETTE_CATEGORY_RED      = 201;
    const int PALETTE_CATEGORY_ARTIFACT = 197;


void GenerateEncTable();

void _test_CreateWrapper(int nObjectType, string sResref, location lLoc)
{
    object oTemplate = CreateObject(OBJECT_TYPE_CREATURE, sResref, lLoc);
    SetCreatureAppearanceType(oTemplate, APPEARANCE_TYPE_CHICKEN);
    /*
    int nSize =  StringToInt(Get2DAString("appearance", "sizecategory", nAppearanceType));
    string sAppearanceName = Get2DAString("appearance", "label", nAppearanceType);

    DelayCommand(0.5, SetLocalInt(oTemplate, "APPEARANCE_TYPE", nAppearanceType));
    DelayCommand(0.5, SetName(oTemplate, sAppearanceName));
    DelayCommand(0.5, NWNX_Creature_SetFaction(oTemplate, STANDARD_FACTION_MERCHANT));
    DelayCommand(0.5, NWNX_Creature_SetSize(oTemplate, nSize));
    DelayCommand(0.5, SetPlotFlag(oTemplate, TRUE));
    DelayCommand(0.5, NWNX_Creature_SetMovementRate(oTemplate, NWNX_CREATURE_MOVEMENT_RATE_IMMOBILE));
    DelayCommand(0.5, SetCreatureAppearanceType(oTemplate, nAppearanceType));
    DelayCommand(0.5, appearance_SetAppearanceEventHandlers(oTemplate));   */
}

string LowerCase(string sInputString)
{
    string sResult = "";
    string sAsciiTable = NWNX_Util_GetAsciiTableString();
    int i;
    for(i = 0; i < GetStringLength(sInputString); i++)
    {
        int nSymbolPositionInAsciiTable = FindSubString(sAsciiTable, GetSubString(sInputString, i, 1));
        if(nSymbolPositionInAsciiTable >= 65  && nSymbolPositionInAsciiTable <= 90   || // eng shift
           nSymbolPositionInAsciiTable >= 192 && nSymbolPositionInAsciiTable <= 223)    // rus shift
            sResult += GetSubString(sAsciiTable, nSymbolPositionInAsciiTable + 32, 1);
        else
            sResult += GetSubString(sInputString, i, 1);
    }
    return sResult;
}

string UpperCase(string sInputString)
{
    string sResult = "";
    string sAsciiTable = NWNX_Util_GetAsciiTableString();
    int i;
    for(i = 0; i < GetStringLength(sInputString); i++)
    {
        int nSymbolPositionInAsciiTable = FindSubString(sAsciiTable, GetSubString(sInputString, i, 1));
        if(nSymbolPositionInAsciiTable >= 97  && nSymbolPositionInAsciiTable <= 122   || // eng shift
           nSymbolPositionInAsciiTable >= 224 && nSymbolPositionInAsciiTable <= 255)     // rus shift
            sResult += GetSubString(sAsciiTable, nSymbolPositionInAsciiTable - 32, 1);
        else
            sResult += GetSubString(sInputString, i, 1);
    }
    return sResult;
}

void UpdateSaves(object oPC)
{
    object oSkin = SKIN_SupportGetSkin(oPC);
    // get base saves values
    int nSavesDiff = GetLocalInt(oSkin, "SAVES_DIFF");
    int nSavesBaseFort = NWNX_Creature_GetBaseSavingThrow(oPC, SAVING_THROW_FORT) - nSavesDiff;
    int nSavesBaseRefl = NWNX_Creature_GetBaseSavingThrow(oPC, SAVING_THROW_REFLEX) - nSavesDiff;
    int nSavesBaseWill = NWNX_Creature_GetBaseSavingThrow(oPC, SAVING_THROW_WILL) - nSavesDiff;
    // set new saves values
    int nNewSavesDiff = GetAbilityModifier(ABILITY_CHARISMA, oPC);
    if(nNewSavesDiff < 0)
        nNewSavesDiff = 0;
    SetLocalInt(oSkin, "SAVES_DIFF", nNewSavesDiff);
    NWNX_Creature_SetBaseSavingThrow(oPC, SAVING_THROW_FORT, nSavesBaseFort + nNewSavesDiff);
    NWNX_Creature_SetBaseSavingThrow(oPC, SAVING_THROW_REFLEX, nSavesBaseRefl + nNewSavesDiff);
    NWNX_Creature_SetBaseSavingThrow(oPC, SAVING_THROW_WILL, nSavesBaseWill + nNewSavesDiff);
}

void LootProcessor()
{
    string sResref = NWNX_Util_GetFirstResRef(NWNX_UTIL_RESREF_TYPE_ITEM, "^fl_.*_loot.*$");
    while(sResref != "")
    {
        //object oLoot = CreateObject(OBJECT_TYPE_ITEM, sResref, GetStartingLocation());
        json jItem = TemplateToJson(sResref, RESTYPE_UTI);
        // remove props
        json jPropArray = GffGetList(jItem, "PropertiesList");
        int i = 0;
        json jPropArrayNew = JsonArray();
        json jProp = JsonArrayGet(jPropArray, i);
        while(jProp != JSON_NULL)
        {
            int nPropName = JsonGetInt(GffGetWord(jProp, "PropertyName"));
            if(nPropName != 83 /* Weapon vis effect */ && nPropName != 155 /* value decr */ && nPropName != 156 /* value inc */)
                jPropArrayNew = JsonArrayInsert(jPropArrayNew, jProp);
            jProp = JsonArrayGet(jPropArray, ++i);
        }
        jItem = GffRemoveList(jItem, "PropertiesList");
        jItem = GffAddList(jItem, "PropertiesList", jPropArrayNew);
        // get values
        int nType = JsonGetInt(GffGetInt(jItem, "BaseItem"));
        int bWeapon = StringToInt(Get2DAString("baseitems", "CritHitMult", nType));
        int bSorc = FindSubString(JsonGetString(JsonObjectGet(GffGetLocString(jItem, "LocalizedName"), "0")), "Sorcerer") > 0;

        // find values
        int nPaletteId = 0;
        int nVisualId = 0;
        int nItemLevel = 0;
        if(FindSubString(sResref, "fl_blue_") >= 0)
        {
            if(bWeapon && nType != BASE_ITEM_MAGICSTAFF && nType != BASE_ITEM_GLOVES)
            {
                nItemLevel = 18;
                nVisualId = ITEM_VISUAL_GLOW_BLUE;
            }
            else
                nItemLevel = 15;
            nPaletteId = PALETTE_CATEGORY_BLUE;
        }
        else if(FindSubString(sResref, "fl_grn_") >= 0)
        {
            if(bWeapon && nType != BASE_ITEM_MAGICSTAFF && nType != BASE_ITEM_GLOVES)
            {
                nItemLevel = 28;
                nVisualId = ITEM_VISUAL_GLOW_GREEN;
            }
            else
                nItemLevel = 25;
            nPaletteId = PALETTE_CATEGORY_GREEN;
        }
        else if(FindSubString(sResref, "fl_prpl_") >= 0 || FindSubString(sResref, "fl_red_") >= 0 && bSorc)
        {
            if(bWeapon && nType != BASE_ITEM_MAGICSTAFF && nType != BASE_ITEM_GLOVES)
            {
                nItemLevel = 33;
                nVisualId = ITEM_VISUAL_GLOW_PURPLE;
            }
            else
                nItemLevel = 30;
            nPaletteId = PALETTE_CATEGORY_PURPLE;
        }
        else if(FindSubString(sResref, "fl_red_") >= 0)
        {
            if(bWeapon && nType != BASE_ITEM_MAGICSTAFF && nType != BASE_ITEM_GLOVES)
            {
                nItemLevel = 38;
                nVisualId = ITEM_VISUAL_GLOW_RED;
            }
            else
                nItemLevel = 35;
            nPaletteId = PALETTE_CATEGORY_RED;
        }
        else if(FindSubString(sResref, "fl_art_") >= 0)
        {
            if(bWeapon && nType != BASE_ITEM_MAGICSTAFF && nType != BASE_ITEM_GLOVES)
            {
                nItemLevel = 40;
                nVisualId = ITEM_VISUAL_GLOW_ORANGE;
            }
            else
                nItemLevel = 1;
            nPaletteId = PALETTE_CATEGORY_ARTIFACT;
        }
        // create Item and add local vars and visual for weapons
        object oLoot = JsonToObject(jItem, GetStartingLocation());
        if(nItemLevel)
            SetLocalInt(oLoot, "LEVEL", nItemLevel);
        if(nVisualId) // ItemPropertyVisualEffect(int nEffect) works incorrect, lets build vis effect!
        {
            itemproperty ip_WepVis;
            struct NWNX_IPUnpacked stIpUnpacked = NWNX_ItemProperty_UnpackIP(ip_WepVis);
            stIpUnpacked.nProperty = 83; //
            stIpUnpacked.nSubType = nVisualId;
            stIpUnpacked.nCostTable = 0;
            stIpUnpacked.nCostTableValue = 0;
            stIpUnpacked.nParam1 = 255;
            stIpUnpacked.nParam1Value = 0;
            stIpUnpacked.nUsesPerDay = 255;
            stIpUnpacked.nChanceToAppear = 100;
            stIpUnpacked.bUsable = 1;
            stIpUnpacked.nSpellId = -1;
            stIpUnpacked.sTag = "";
            ip_WepVis = NWNX_ItemProperty_PackIP(stIpUnpacked);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip_WepVis, oLoot);
        }
        jItem = ObjectToJson(oLoot, TRUE);
        if(nPaletteId) // this field dont apply :( seems lost after creation or export
            jItem = GffAddByte(jItem, "PaletteID", nPaletteId);

        JsonToTemplate(jItem, sResref, RESTYPE_UTI);
        DestroyObject(oLoot);

        sResref = NWNX_Util_GetNextResRef();
    }
}

const string GRAND_CHAMPION_HOUR                = "GRAND_CHAMPION_HOUR";  // local var name
const string GRAND_CHAMPION_MINUTE              = "GRAND_CHAMPION_MINUTE";  // local var name


void main()
{

    object oCreature = GetSpellTargetObject();
    location lLoc = GetSpellTargetLocation();

    object oInstanceKey = CreateItemOnObject("fl_inst_key", oCreature);
        string sInstanceKeyName = "Instance Key";
        string sLootCategory = "BLUE";
                    sInstanceKeyName = ColorText("Artifact " + sInstanceKeyName, LOOT_COLOR_ARTIFACT);
                    SetLocalString(oInstanceKey, "LOOT_CATEGORY", "ARTIFACT");

//MusicBackgroundChangeDay(GetArea(oCreature), 563);
//MusicBackgroundChangeNight(GetArea(oCreature), 563);
//MusicBattleChange(GetArea(oCreature), 563);
    //NWNX_Creature_SetSkillPointsRemaining(oCreature, 20);
    //NWNX_Creature_SetSkillRankByLevel(oCreature, SKILL_CONCENTRATION, 42, 40);
    //NWNX_Creature_SetSkillRankByLevel(oCreature, SKILL_DISCIPLINE, 43, 40);
    //NWNX_Creature_SetSkillRankByLevel(oCreature, SKILL_SPOT, 43, 40);
    //NWNX_Creature_SetSkillRankByLevel(oCreature, SKILL_TUMBLE, 20, 40);

    //NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEP_PROF_GOVNOTRYAS, 1);
    //NWNX_Creature_SetMovementRate(oCreature, NWNX_CREATURE_MOVEMENT_RATE_FAST);
    //NWNX_Player_UpdateFogAmount(oCreature, 0,0);
    //NWNX_Area_SetFogClipDistance(GetArea(oCreature), 200.0);
    //ServerShout("Fort: " + IntToString(GetFortitudeSavingThrow(oCreature)));
    //ServerShout("FortBase: " + IntToString(NWNX_Creature_GetBaseSavingThrow(oCreature, SAVING_THROW_FORT)));
    //ServerShout("PreferredAttackDistance: " + FloatToString(NWNX_Creature_GetPreferredAttackDistance(oCreature)));

    //NWNX_Creature_SetPreferredAttackDistance(oCreature, 2.1);
    //NWNX_Creature_SetHitDistance(oCreature, 0.3);
    //object oTarget = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature, 1, CREATURE_TYPE_IS_ALIVE, TRUE);
    //AssignCommand(oCreature, ActionCastSpellAtObject(SPELL_DESTRUCTION, oTarget));


//chat_DeleteModuleParameters(oCreature);


    // NWNX_Administration_DeleteTURD(GetPCPlayerName(oCreature), GetName(oCreature));
    /*
    effect eLoop = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eLoop))
    {
        object oCreator = GetEffectCreator(eLoop);

            struct NWNX_EffectUnpacked eEffUnpacked = NWNX_Effect_UnpackEffect(eLoop);
            printeff(eEffUnpacked);
        eLoop = GetNextEffect(oCreature);
    }


    int i;
    float fDelay = GetRandomDelay();

    for (i=1; i<=10; i++)
    {
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_ar_clr", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_ku_clr", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_re_clr", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_dr_clr", lLoc));
    }*/

    /* http telegram tests //

    json jMessage = JsonObject();
    jMessage = JsonObjectSet(jMessage, "chat_id", JsonString("-1002316642750"));
    jMessage = JsonObjectSet(jMessage, "caption", JsonString("òåñò íàõóé"));
    jMessage = JsonObjectSet(jMessage, "message_thread_id", JsonString(TELEGRAM_TOPIC_BOSSES));
    jMessage = JsonObjectSet(jMessage, "photo", JsonString("https://portraits.cormyr.ru/po_2snake_s.png"));
    jMessage = JsonObjectSet(jMessage, "parse_mode", JsonString("HTML"));


    struct NWNX_HTTPClient_Request stTelegramPost;
    stTelegramPost.nRequestMethod = NWNX_HTTPCLIENT_REQUEST_METHOD_POST;
    stTelegramPost.sHost = "api.telegram.org";
    stTelegramPost.sPath = "/bot8329075530:AAEx8JcTorGfHjBt1rpxn-Ea499OBALb_54/sendPhoto";

    stTelegramPost.sData = JsonDump(jMessage);

    stTelegramPost.nAuthType = NWNX_HTTPCLIENT_AUTH_TYPE_NONE;
    stTelegramPost.nContentType = NWNX_HTTPCLIENT_CONTENT_TYPE_JSON;

    NWNX_HTTPClient_SendRequest(stTelegramPost);

*/



//        object oInstanceKey = CreateItemOnObject("fl_inst_key", oCreature);
 //       string sInstanceKeyName = "Instance Key";
   //     sInstanceKeyName = ColorText("Artifact " + sInstanceKeyName, LOOT_COLOR_ARTIFACT);
     //   SetLocalString(oInstanceKey, "LOOT_CATEGORY", "ARTIFACT");
      //  SetDescription(oInstanceKey, ColorText("Warning! Bosses with prime time flag will be despawned if you open this key at the wrong time.", TXT_COLOR_RED));
       // SetName(oInstanceKey, sInstanceKeyName);
        // generic_PayAudioStreamForPlayerArea(oCreature, "mus_holyshit");

     //NWNX_Feat_SetFeatModifier(FEAT_EPIC_PROWESS, NWNX_FEAT_MODIFIER_ABILITY, ABILITY_STRENGTH, 10);
     //NWNX_Feat_SetFeatModifier(FEAT_EPIC_PROWESS, NWNX_FEAT_MODIFIER_ABILITY, ABILITY_STRENGTH, 10);
     //NWNX_Feat_SetFeatModifier(FEAT_SKILL_FOCUS_DISCIPLINE, NWNX_FEAT_MODIFIER_SAVE, SAVING_THROW_FORT, 20);

    //spells_GetHasKnockdownEffect(oCreature);
    //effect eRegen = EffectRegenerate(60, 6.0);
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRegen, oCreature, 36000.0);
    //AddFeat(FEAT_IMPROVED_EXPERTISE, oCreature);
    //AddFeat(FEAT_DIVINE_MIGHT, oCreature);
    //SetItemCharges(oCreature, 50);
    //SetItemStackSize(oCreature, 99);
    //CopyItem(oCreature, GetItemPossessor(oCreature));
    //RemoveFeat(FEAT_BULLHEADED, oCreature);
    //RemoveFeat(FEAT_SKILL_FOCUS_CONCENTRATION, oCreature);
    //SetCreatureAppearanceType(oCreature, 6);
    //runes_LoadRunes(oCreature);
    //NWNX_Administration_ReloadRules();
    //NWNX_Creature_SetSize(oCreature, CREATURE_SIZE_LARGE);

    //NWNX_Creature_SetMulticlassLimit(oCreature, 0, TRUE);

    //AddFeat(FEAT_IMPROVED_KNOCKDOWN, oCreature);
    //AddFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC,oCreature);
    //AddFeat(FEAT_SKILL_FOCUS_CONCENTRATION,oCreature);
    //RemoveFeat(FEAT_EPIC_SKILL_FOCUS_CONCENTRATION,oCreature);
    //RemoveFeat(FEAT_SKILL_FOCUS_CONCENTRATION,oCreature);
    //SetCreatureAppearanceType(oCreature, 150);
    //CreateItemOnObject("fl_12345", oCreature);

    //generic_DestroyCreature(oCreature);
    //NWNX_Creature_SetMovementRate(oCreature, NWNX_CREATURE_MOVEMENT_RATE_FAST);
    //LootSeparator();
//    dispel_AddSpellDataOnTarget(oCreature, oCreature, SPELL_CLARITY);
//    DeleteLocalInt(oCreature, "SPELL_EFFECT_APPLYING" + IntToString(SPELL_CLARITY));
    //LootProcessor();
//  DeleteLocalJson(GetModule(), "TOP_STAT");
  // StartAudioStream(oCreature, 1,"mus_ownage");
//    champion_ApplyAllBonuses(oCreature, FALSE, TRUE);
//    SetLocalInt(oCreature, "MUTATED", TRUE);
 //   object oHolder  = GetModule();
 //   int iGrandChampionSpawnHour   = SQLocals_GetInt(oHolder, GRAND_CHAMPION_HOUR);
 //   int iGrandChampionSpawnMinute = SQLocals_GetInt(oHolder, GRAND_CHAMPION_MINUTE);

//    SendMessageToPC(oCreature, IntToString(iGrandChampionSpawnHour) + ":" + IntToString(iGrandChampionSpawnMinute));
       //AssignCommand(oCreature, SpeakString("È âîîáùå, ÿ ñìåòàíà.", TALKVOLUME_SHOUT)) ;
             //
//GenerateEncTable();

/// For example: **nwnx_.\*** gets you all scripts prefixed with nwnx_
/// when using the NSS resref type.
/// @param bModuleResourcesOnly If TRUE only custom resources will be returned.
/// @return The first resref found or "" if none is found.


    //effect eDam = EffectDamage(GetCurrentHitPoints(oCreature) + 5);
    //ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oCreature );

    //effect eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_SEAL_OF_SILENCE), EffectIcon(EFFECT_ICON_EVIL_BLIGHT_TARGET));
    //eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_MARK_OF_DOOM), eLink);
    //eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_EVIL_BLIGHT_SELF), eLink);
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectIcon(EFFECT_ICON_SEAL_OF_SILENCE), oCreature, 60.0);
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectIcon(EFFECT_ICON_EVIL_BLIGHT_TARGET), oCreature, 60.0);
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectIcon(EFFECT_ICON_MARK_OF_DOOM), oCreature, 60.0);
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectIcon(EFFECT_ICON_EVIL_BLIGHT_SELF), oCreature, 60.0);
    //StartAudioStream(oCreature, AUDIOSTREAM_IDENTIFIER_0, "mus_shangtsung");

    //ServerShout(IntToString(NWNX_Creature_GetAttackBonus(oCreature, -1)));



    //loot_GenerateBossTreasuresInArea(GetAreaFromLocation(lLoc), "BLUE", 50);
    /*

            object oInstanceKey = CreateItemOnObject("fl_inst_key", oCreature);
            string sInstanceKeyName = "Instance Key";
            sInstanceKeyName = ColorText("Lesser " + sInstanceKeyName, LOOT_COLOR_PURPLE);
            SetLocalString(oInstanceKey, "LOOT_CATEGORY", "PURPLE");
            SetName(oInstanceKey, sInstanceKeyName);


    return;
    */

    //NWNX_Creature_DoItemCastSpell(oCreature, oCreature, LOCATION_INVALID, SPELL_ICE_STORM, 40, 0.0);
    /*
    int i;
    float fDelay = GetRandomDelay();

    for (i=1; i<=10; i++)
    {
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_ar_clr", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_ku_clr", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_re_clr", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_dr_clr", lLoc));
    }
    */
    //NWNX_Events_AddIDToWhitelist("NWNX_ON_HAS_FEAT", FEAT_EPIC_DEVASTATING_CRITICAL_LIGHTFLAIL);
    //NWNX_Events_AddIDToWhitelist("NWNX_ON_HAS_FEAT", FEAT_EPIC_RANGER);

    //effect eEnemy = EffectBonusFeat(FEAT_WOODEN_BODY);
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEnemy, oCreature, 3600.0);

    //effect eVis = EffectVisualEffect(HGVFX_DUR_MAGICAL_SIGHT_GREEN);
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oCreature, 30.0);
    // SendMessageToPC(oCreature, IntToString(NWNX_Creature_GetBaseSavingThrow(oCreature, SAVING_THROW_FORT)));
    // UpdateSaves(oCreature);

    //AddFeat(FEAT_EPIC_SKILL_FOCUS_CONCENTRATION,oCreature);
    //AddFeat(FEAT_SKILL_FOCUS_CONCENTRATION,oCreature);
    //RemoveFeat(FEAT_EPIC_SKILL_FOCUS_CONCENTRATION,oCreature);
    //RemoveFeat(FEAT_SKILL_FOCUS_CONCENTRATION,oCreature);
    //SetCreatureAppearanceType(oCreature, 150);

    //struct NWNX_Damage_DamageData stTestDamage;
    //stTestDamage.iSlash = Random(1350)+150;
    //stTestDamage.iAcid = Random(1350)+150;
    //stTestDamage.iCold = Random(1350)+150;
    //AssignCommand(oCreature, NWNX_Damage_DealDamage(stTestDamage, oCreature, oCreature));

    //ServerShout(UpperCase("ÒÅÑÒòåñòÒÅÑÒÊîðìèðÊîðìèðCormyrCormyr"));
    //ServerShout(NWNX_Util_GetAsciiTableString());
    //NWNX_Events_SubscribeEvent("NWNX_ON_ITEM_ACQUIRE_BEFORE", "_ev_on_acquire");
    //NWNX_Events_SubscribeEvent("NWNX_ON_ITEM_ACQUIRE_AFTER", "_ev_on_acquire");
    //obelisk_SetCaptured(oCreature, 3, 60.0);
    //obelisk_Init();

    //guard_ReturnGoldInTreasure(1);
    //int nFaction = NWNX_Creature_GetFaction(oCreature);
    //ServerShout(IntToString(nFaction));

    //NWNX_Creature_SetFaction(oCreature, 15);

    //NWNX_Feat_SetFeatModifier(FEAT_EPIC_PROWESS, NWNX_FEAT_MODIFIER_AB, 1);

   //ServerShout(IntToString(0x80000000));

   // Init NUI
   // NWNX_Util_SetInstructionLimit(8388608);
   //NUI_Initialize();

/*
  json col;
  json row;
  col = JsonArray();

  row = JsonArray();
    row = JsonArrayInsert(row, NuiSpacer());
    json img = NuiImage(NuiBind("ief_abildecr"),
                        JsonInt(NUI_ASPECT_EXACT),
                        JsonInt(NUI_HALIGN_CENTER),
                        JsonInt(NUI_VALIGN_TOP));
    img = NuiGroup(img);
    img = NuiWidth(img, 256.0);
    img = NuiHeight(img, 256.0);
    row = JsonArrayInsert(row, img);
    row = JsonArrayInsert(row, NuiSpacer());
  col = JsonArrayInsert(col, NuiRow(row));



SendMessageToPC(oCreature, JsonDump(col));
json root = NuiCol(col);
        json nui = NuiWindow(
        root,
        NuiBind("po_resref"),
        NuiBind("geometry"),
        NuiBind("resizable"),
        NuiBind("collapsed"),
        NuiBind("closable"),
        NuiBind("transparent"),
        NuiBind("border"));

    int token = NuiCreate(oCreature, nui, "poviewer");

NuiSetBind(oCreature, token, "geometry", NuiRect(420.0, 10.0, 400.0, 600.0));

NuiSetBind(oCreature, token, "ief_abildecr", JsonString("ief_abildecr"));

*/

    //NUI_DisplayForm(oCreature, "appearance_editor");
     //   NUI_DisplayForm(oCreature, "my_new_form3");
    //    NUI_DisplayForm(OBJECT_SELF, "appearance_editor");
    //AddFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);

    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectModifyAttacks(5), oCreature, 30.0);

    //CreateObject(OBJECT_TYPE_CREATURE, "cr_chauntea", lLoc);
    //spellbook_SaveSpells(oCreature, 1);
   //spellbook_LoadSpells(oCreature, 1);
   // spellbook_ViewSavedSlots(oCreature);
    //appearance_Init();

    //SendMessageToPC(OBJECT_SELF, IntToString(GetCreatureSize(oCreature)));
    //NWNX_Creature_SetSize(oCreature, 4);
    //NWNX_Creature_SetSize
    //AssignCommand(oCreature, NWNX_Creature_SetLastKiller(oCreature, oCreature));
    //AssignCommand(oCreature, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(1), oCreature));
    //AssignCommand(oCreature, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oCreature));
    //AssignCommand(oCreature, NWNX_Creature_SetLastKiller(oCreature, oCreature));
    //ServerShout();

    //ExecuteScript("_mod_load", GetModule());

    /*
    object oPC = GetNearestCreatureToLocation(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, lLoc);

    struct NWNX_Damage_DamageData stTestDamage;
    stTestDamage.iSlash = Random(350)+150;
    stTestDamage.iAcid = Random(350)+150;
    stTestDamage.iCold = Random(350)+150;
    AssignCommand(oCreature, NWNX_Damage_DealDamage(stTestDamage, oCreature, oCreature));


    RemoveFeat(FEAT_FAVORED_ENEMY_HALFELF, oCreature);
    RemoveFeat(FEAT_FAVORED_ENEMY_HALFORC, oCreature);
    RemoveFeat(FEAT_FAVORED_ENEMY_DWARF, oCreature);
    NWNX_Creature_RemoveFeat(oCreature, FEAT_FAVORED_ENEMY_HALFELF);
    NWNX_Creature_RemoveFeat(oCreature, FEAT_FAVORED_ENEMY_HALFORC);
    NWNX_Creature_RemoveFeat(oCreature, FEAT_FAVORED_ENEMY_DWARF);

    NWNX_Creature_AddFeatByLevel(oCreature, FEAT_FAVORED_ENEMY_HALFELF, 1);
        NWNX_Creature_AddFeatByLevel(oCreature, FEAT_FAVORED_ENEMY_HALFORC, 1);
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_FAVORED_ENEMY_DWARF, 1);


    object oTarget = GetFirstPC();
    while(GetIsObjectValid(oTarget))
    {
        if (GetIsPC(oTarget))
        {
            object oItem = GetFirstItemInInventory(oTarget);
            while(GetIsObjectValid(oItem))
            {
                SetHiddenWhenEquipped(oItem, FALSE);
                oItem = GetNextItemInInventory(oTarget);
            }

            int iInventorySlot;
            for (iInventorySlot = 0; iInventorySlot <= 13; iInventorySlot++)
            {
                object oItemInSlot = GetItemInSlot(iInventorySlot, oTarget);
                if (GetIsObjectValid(oItemInSlot))
                    SetHiddenWhenEquipped(oItem, FALSE);
            }
        }
        oTarget = GetNextPC();
    }

    NWNX_Creature_RemoveFeat(oCreature, FEAT_FAVORED_ENEMY_HALFELF);
    NWNX_Creature_AddFeat(oCreature, FEAT_FAVORED_ENEMY_HALFELF);
//    NWNX_Creature_AddFeatByLevel(oCreature, FEAT_FAVORED_ENEMY_HALFELF, 1);
//    RemoveFeat(FEAT_FAVORED_ENEMY_HALFELF, oCreature);
//    RemoveFeat(FEAT_FAVORED_ENEMY_HALFORC, oCreature);






    int i;
    float fDelay = GetRandomDelay();

    for (i=1; i<=15; i++)
    {
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_sew_zombie", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_sew_zombie", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_sew_zombie", lLoc));
    }
*/


    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBlindness(), oPC, 1.1);

    //effect eSlow = SupernaturalEffect(EffectMovementSpeedIncrease(-50));
    //DelayCommand(0.1, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, oPC, 6.0));

    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectHaste(), oPC, 1.0);
    //NWNX_Creature_SetMovementRate(oPC, NWNX_CREATURE_MOVEMENT_RATE_PC);
    //ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectMovementSpeedDecrease(50), oPC, 3.0);
    //NWNX_Creature_ModifyRawAbilityScore(oPC, ABILITY_STRENGTH, -10);

    //NWNX_Feat_SetFeatModifier(1308, NWNX_FEAT_MODIFIER_ABILITY, ABILITY_STRENGTH, 30);

    //ServerShout(IntToString(SQLite_GetTimeStamp()));


    /*
    int i;
    float fDelay = GetRandomDelay();

    for (i=1; i<=10; i++)
    {
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_re_clr", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_ar_clr", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_ku_clr", lLoc));
    }
    for (i=1; i<=15; i++)
    {
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_re_war", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_ar_war", lLoc));
        DelayCommand(fDelay, _test_CreateWrapper(OBJECT_TYPE_CREATURE, "cr_gu_ku_war", lLoc));
    }

     */

    /*
    string sAssistArray = "HOSTILE_ACTORS_LIST";
    int ArraySize = NWNX_Data_Array_Size(NWNX_DATA_TYPE_STRING, oPC, sAssistArray);
    ServerShout("Array size: " + IntToString(ArraySize));
    int i;
    for (i = 0; i <= ArraySize - 1; i++)
    {
        ServerShout(GetName(GetObjectByUUID(NWNX_Data_Array_At_Str(oPC, sAssistArray, i))));
    }         */

    /*
    string sMerchantTag = "MERCHANT_FOR_LOOT_BOSS_LEVEL_1";
    object oMerchant = GetObjectByTag(sMerchantTag);
    int ArraySize = NWNX_Data_Array_Size(NWNX_DATA_TYPE_INTEGER, oMerchant, sMerchantTag);
    int i;
    NWNX_Data_Array_SortAscending(NWNX_DATA_TYPE_INTEGER, oMerchant, sMerchantTag);
    for (i = 0; i <= ArraySize - 1; i++)
    {
        WriteTimestampedLogEntry("ID: " + IntToString(i) +
                                 " | Value: " + IntToString(NWNX_Data_Array_At_Int(oMerchant, sMerchantTag, i)));
    }
     */

    /*
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        if (GetTag(oArea) != GetResRef(oArea)) SendMessageToPC(OBJECT_SELF, GetName(oArea));
        oArea = GetNextArea();
    }
     */

    /*
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        string sTabulation = "    ";
        WriteTimestampedLogEntry(GetName(oArea));
        int iMusicBattle = MusicBackgroundGetBattleTrack(oArea);
        int iMusicDay    = MusicBackgroundGetDayTrack(oArea);
        int iMusicNight  = MusicBackgroundGetNightTrack(oArea);
        WriteTimestampedLogEntry(sTabulation + "Battle " + IntToString(iMusicBattle) + " " + GetStringByStrRef(StringToInt(Get2DAString("ambientmusic", "Description", iMusicBattle))) + " " + Get2DAString("ambientmusic", "DisplayName", iMusicBattle));
        WriteTimestampedLogEntry(sTabulation + "Day " + IntToString(iMusicDay) + " " + GetStringByStrRef(StringToInt(Get2DAString("ambientmusic", "Description", iMusicDay))) + " " + Get2DAString("ambientmusic", "DisplayName", iMusicDay));
        WriteTimestampedLogEntry(sTabulation + "Night " + IntToString(iMusicNight) + " " + GetStringByStrRef(StringToInt(Get2DAString("ambientmusic", "Description", iMusicNight))) + " " + Get2DAString("ambientmusic", "DisplayName", iMusicNight));
        oArea = GetNextArea();
    }
    */

    //object oArea = GetObjectByTag("renocastle");
    //SendMessageToPC(OBJECT_SELF, GetName(oArea));
    //NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBATLOG_CAST_SPELL, TRUE);
    //NWNX_Feedback_SetCombatLogMessageHidden(NWNX_FEEDBACK_COMBATLOG_CAST_SPELL, FALSE);
    //NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBATLOG_CAST_SPELL, FALSE);
    //AssignCommand(oPC, SetFacing(GetFacing(oPC) + 180.0));

    /*
    location lLoc       = GetLocation(oPC);
    object oArea        = GetAreaFromLocation(lLoc);
    vector vPosition    = GetPositionFromLocation(lLoc);
    float fOrientation  = GetFacingFromLocation(lLoc);

    vPosition.x += 5.0;

    location lNewLoc    = Location(oArea, vPosition, fOrientation + 180.0);
    AssignCommand(oPC, JumpToLocation(lNewLoc));    */
}

void GenerateEncTable()
{
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        if (FindSubString(GetName(oArea), "(") != -1 && FindSubString(GetName(oArea), ")") != -1)
        {
            object oEncounter = GetFirstObjectInArea(oArea, OBJECT_TYPE_ENCOUNTER);
            while (GetIsObjectValid(oEncounter))
            {
                int i;
                for(i = 0; i < NWNX_Encounter_GetNumberOfCreaturesInEncounterList(oEncounter); i++)
                {
                    struct NWNX_Encounter_CreatureListEntry stEncounter = NWNX_Encounter_GetEncounterCreatureByIndex(oEncounter, i);


                    int nRespTime;
                    if(stEncounter.challengeRating >= 60.0)
                        nRespTime = 5400;
                    else if(stEncounter.challengeRating >= 43.0)
                        nRespTime = 4500;
                    else if(stEncounter.challengeRating >= 36.0)
                        nRespTime = 3600;
                    else if(stEncounter.challengeRating >= 31.0)
                        nRespTime = 2700;
                    else if(stEncounter.challengeRating >= 26.0)
                        nRespTime = 2400;
                    else if(stEncounter.challengeRating >= 21.0)
                        nRespTime = 2100;
                    else if(stEncounter.challengeRating >= 16.0)
                        nRespTime = 1800;
                    else if(stEncounter.challengeRating >= 6.0)
                        nRespTime = 1200;
                    else
                        nRespTime = 300;
                    json jCreature = TemplateToJson(stEncounter.resref, RESTYPE_UTC);
                    object oCreature = JsonToObject(jCreature, GetStartingLocation());
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
                    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "");
                    string sName = GetName(oCreature);
                       /*
                    if(stEncounter.resref != "nw_orcboss")
                        continue;
                    else
                    {
                        ServerShout(GetName(GetArea(oEncounter)));
                        break;
                    }      */
                    if(GetIsObjectValid(oCreature))
                    {
                        string sSQL = "INSERT INTO encounters2 (mob_name, mob_resref, mob_respawn_time, mob_cr) VALUES (?, ?, ?, ?)";
                        NWNX_SQL_PrepareQuery(sSQL);
                        NWNX_SQL_PreparedString(0, sName);
                        NWNX_SQL_PreparedString(1, stEncounter.resref);
                        NWNX_SQL_PreparedInt(2, nRespTime);
                        NWNX_SQL_PreparedInt(3, FloatToInt(stEncounter.challengeRating));
                        NWNX_SQL_ExecutePreparedQuery();
                    }
                    DestroyObject(oCreature);
                }
                oEncounter = GetNextObjectInArea(oArea, OBJECT_TYPE_ENCOUNTER);
            }
        }
        oArea = GetNextArea();
    }
}

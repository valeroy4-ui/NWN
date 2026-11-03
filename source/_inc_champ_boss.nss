#include "x2_inc_itemprop"
#include "nwnx_creature"
#include "nwnx_encounter"
#include "_inc_feat4base"
#include "_inc_npc_cast"
#include "_inc_constants"
#include "_inc_loot_static"
#include "_inc_discord_rpt"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// returns TRUE if champion mark is set, you must mark oMob as champion in toolset
int champion_GetHasChampionFlag(object oMob = OBJECT_SELF);

// returns TRUE if oMob is champion
int champion_GetIsChampion(object oMob = OBJECT_SELF);

// returns TRUE if oMob is grand champion
int champion_GetIsEliteChampion(object oMob = OBJECT_SELF);

// TRUE if oMob is boss or mini boss
int champion_GetIsBoss(object oMob = OBJECT_SELF);

// applies random bonuses, entry function
void champion_ApplyAllBonuses(object oMob = OBJECT_SELF, int bElite = FALSE, int bBoss = FALSE);

// applies bonuses for High Level champions, subfunction of champion_ApplyAllBonuses
void champion_ApplyHighLevelBonuses(object oMob, int iMobCR, int bElite);

// applies standart random bonuses, subfunction of champion_ApplyAllBonuses
void champion_ApplyStandartBonuses(object oMob, int iMobCR, int bElite);

// count encounters in area
int champion_CountEncounter(object oArea, location lLoc);

// generate Scout at random encounter
void champion_CreateScout();

// create array with random 35+ CR encounters
void champion_EliteInit();

// spawn random elite champion
void champion_EliteRandomSpawn();

// generate reward
void champion_GenerateEliteReward(object oKiller, object oVictim, int bCaptain = FALSE);

// returns boss Type (0 - no boss, 1 - mini, etc)
int champion_GetBossType(object oBoss);

// return boss type string for discord (mini, advanced etc)
string champion_GetDiscordCategory(int nBossType);

//
string champion_BossChooseRandomPhrase();

//
void champion_OnBossRageEnter(object oBoss);

//
void champion_OnBossRageTicks(object oBoss);

//
void champion_OnBossRageExit(object oBoss);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////


int champion_GetHasChampionFlag(object oMob = OBJECT_SELF)
{
    if (GetLocalInt(oMob, "IAMCHAMPION"))
        return TRUE;
    return FALSE;
}

int champion_GetIsChampion(object oMob = OBJECT_SELF)
{
    if (GetLocalInt(oMob, "CHAMPIONSPAWNED"))
        return TRUE;
    return FALSE;
}

int champion_GetIsEliteChampion(object oMob = OBJECT_SELF)
{
    if (GetLocalInt(oMob, "ELITECHAMPIONSPAWNED"))
        return TRUE;
    return FALSE;
}

int champion_GetIsBoss(object oMob = OBJECT_SELF)
{
    if (GetLocalInt(oMob, "BOSS_TYPE") > 0)
        return TRUE;
    return FALSE;
}

void champion_ApplyAllBonuses(object oMob = OBJECT_SELF, int bElite = FALSE, int bBoss = FALSE)
{
    string sNameSuffix = "";

    if(bBoss)
        sNameSuffix = "Mutated ";
    if(bElite && !bBoss)
        sNameSuffix += " Grand";
    if(!bBoss)
        sNameSuffix += " Champion";

    if(bBoss)
        SetName(oMob, ColorText(sNameSuffix + GetName(oMob), TXT_COLOR_RED));
    else
        SetName(oMob, GetName(oMob) + sNameSuffix);

    if (bElite)
        SetLocalInt(oMob, "ELITECHAMPIONSPAWNED", TRUE);
    else
        SetLocalInt(oMob, "CHAMPIONSPAWNED", TRUE);

    if(bBoss)
        SetDescription(oMob, "*Mutanted bosses has more power and abilities to kill you.*");
    else
        SetDescription(oMob, "*Champions are the best warriors among creatures of their clan*");

    SetObjectVisualTransform(oMob, OBJECT_VISUAL_TRANSFORM_SCALE, 1.00 + IntToFloat(d100())/200.0);

    int iMobCR  = FloatToInt(GetChallengeRating(oMob));
    if(bBoss)
        iMobCR = GetHitDice(oMob);

    //  Default bonuses
    effect eDam = EffectDamageReduction(iMobCR, DAMAGE_POWER_PLUS_TWENTY, iMobCR * 10);
    effect eConceal = EffectConcealment(iMobCR > 50 ? 50: iMobCR);

    effect eLink = EffectLinkEffects(eDam, eConceal);
    eLink = EffectLinkEffects(EffectHaste(), eLink);
    eLink = EffectLinkEffects(EffectCutsceneGhost(), eLink);

    eLink = SupernaturalEffect(eLink);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oMob);

    // visual part
    if(bBoss)
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, UnyieldingEffect(EffectVisualEffect(VFX_DUR_GLOW_RED)), oMob);
    else
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, UnyieldingEffect(EffectVisualEffect(VFX_DUR_GLOW_PURPLE)), oMob);

    // 35% chance to get imbo speed
    if (d100() > 65)
        NWNX_Creature_SetMovementRate(oMob, NWNX_CREATURE_MOVEMENT_RATE_FAST);

    // Highlevel bonuses
    if (iMobCR > 34 && !bBoss)
        champion_ApplyHighLevelBonuses(oMob, iMobCR, bElite);

    champion_ApplyStandartBonuses(oMob, iMobCR, bElite);
}

void champion_ApplyHighLevelBonuses(object oMob, int iMobCR, int bElite)
{
    object oItem    = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oMob);
    int iDexMob     = GetAbilityScore(oMob,ABILITY_DEXTERITY);
    int iSTRMob     = GetAbilityScore(oMob,ABILITY_STRENGTH);
    int iMageLvl    = GetLevelByClass(CLASS_TYPE_BARD, oMob)  + GetLevelByClass(CLASS_TYPE_CLERIC, oMob)   +
                      GetLevelByClass(CLASS_TYPE_DRUID, oMob) + GetLevelByClass(CLASS_TYPE_SORCERER, oMob) +
                      GetLevelByClass(CLASS_TYPE_WIZARD, oMob);

    // if melee weapon
    if (GetIsObjectValid(oItem) && IPGetIsMeleeWeapon(oItem))
    {
        int nItemBaseType = GetBaseItemType(oItem);
        if  (d100() > 50 && iMageLvl < 18 || bElite)    // 50% to get improve crit range
        {
            NWNX_Creature_SetCriticalRangeModifier(oMob, -3);
        }
        // +Devast - strength 25+, cleave, great cleave, improved critical, overwhelming critical, power attack, weapon focus
        if (iSTRMob > 24 && d100() > 50 || bElite)  //50% for devast
        {
            NWNX_Creature_AddFeat(oMob, FEAT_CLEAVE);
            NWNX_Creature_AddFeat(oMob, FEAT_GREAT_CLEAVE);
            NWNX_Creature_AddFeat(oMob, FEAT_POWER_ATTACK);
            NWNX_Creature_AddFeat(oMob, GetWeaponFocusFeatForItemBaseType(nItemBaseType));
            NWNX_Creature_AddFeat(oMob, GetWeaponImprovedCriticalFeatForItemBaseType(nItemBaseType));
            NWNX_Creature_AddFeat(oMob, GetEpicWeaponOverwhelmingCriticalFeatForItemBaseType(nItemBaseType));
            NWNX_Creature_AddFeat(oMob, GetEpicWeaponDevastatingCriticalFeatForItemBaseType(nItemBaseType));
        }
    }
    // unarmed or ranged bonuses
    else if(d100() > 50 || bElite)
    {
        NWNX_Creature_SetCriticalRangeModifier(oMob, -5);
        NWNX_Creature_SetCriticalMultiplierModifier(oMob, 1);
        effect eUnarmedBonus = EffectDamageIncrease(GetDamageBonusConstantFromNumber(d6() + iMobCR/5), DAMAGE_TYPE_MAGICAL);
        eUnarmedBonus = EffectLinkEffects(EffectAttackIncrease(d6()), eUnarmedBonus);
        eUnarmedBonus = EffectLinkEffects(EffectDamageResistance(DAMAGE_TYPE_BLUDGEONING, 5 + iMobCR/5, 0), eUnarmedBonus);
        eUnarmedBonus = EffectLinkEffects(EffectDamageResistance(DAMAGE_TYPE_SLASHING, 5 + iMobCR/5, 0), eUnarmedBonus);
        eUnarmedBonus = EffectLinkEffects(EffectDamageResistance(DAMAGE_TYPE_PIERCING, 5 + iMobCR/5, 0), eUnarmedBonus);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eUnarmedBonus), oMob);
    }
    // 50% chance for attack & knock bonuses
    if  (d100() > 50 && iMageLvl < 18 || bElite)
    {
        effect eEffect = EffectAttackIncrease(d6());
        NWNX_Creature_AddFeat(oMob, FEAT_KNOCKDOWN);
        NWNX_Creature_AddFeat(oMob, FEAT_IMPROVED_KNOCKDOWN);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eEffect), oMob);
    }
    // 67% chance to get hips + extra disc for dex oMob
    if (iDexMob > 30 && d100() > 33)
    {
        NWNX_Creature_AddFeat(oMob, FEAT_HIDE_IN_PLAIN_SIGHT);
        NWNX_Creature_SetSkillRank(oMob, SKILL_DISCIPLINE, GetSkillRank(SKILL_DISCIPLINE, oMob, TRUE) + iMobCR/5);
    }
    // 67% chance to get crit immun + disc for mages
    if (iMageLvl > 25 && d100() > 33 || iMageLvl > 25 && bElite)
    {
        effect eImmunCrit = EffectLinkEffects(EffectImmunity(IMMUNITY_TYPE_CRITICAL_HIT),
                                              EffectSkillIncrease(SKILL_DISCIPLINE, iMobCR/5));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eImmunCrit), oMob);
    }
    // 25% for true seeing
    if (d100() > 75 || bElite)
    {
        effect eTrueSeeing = EffectTrueSeeing();
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eTrueSeeing), oMob);
    }
    // 5% for elem+exotic immun
    if (d100() > 95 || bElite)
    {
        effect eDamageImmunity = EffectDamageImmunityIncrease(DAMAGE_TYPE_ACID, iMobCR * 2);
        eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_ACID, iMobCR * 2), eDamageImmunity);
        eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, iMobCR * 2), eDamageImmunity);
        eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_DIVINE, iMobCR * 2), eDamageImmunity);
        eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_ELECTRICAL, iMobCR * 2), eDamageImmunity);
        eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, iMobCR * 2), eDamageImmunity);
        eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_MAGICAL, iMobCR * 2), eDamageImmunity);
        eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, iMobCR * 2), eDamageImmunity);
        eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_POSITIVE, iMobCR * 2), eDamageImmunity);
        eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_SONIC, iMobCR * 2), eDamageImmunity);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eDamageImmunity), oMob);
    }
}

void champion_ApplyStandartBonuses(object oMob, int iMobCR, int bElite)
{
    int nAvailableBonusesNumber = 16;
    // Random bonuses number depends on creature CR with base 3
    int nRandomBonusesNumber = iMobCR/10 + d6();
    if (bElite)
        nRandomBonusesNumber = nAvailableBonusesNumber;
    int i;
    // Random bonuses variants
    for (i = 1; i <= nAvailableBonusesNumber; i++)
    {
        Array_PushBack_Int("CHAMPION_RANDOM_BONUSES_ARRAY", i, oMob);
    }
    // shuffle bonuses
    Array_Shuffle("CHAMPION_RANDOM_BONUSES_ARRAY", oMob);
    for (i = 0; i < nRandomBonusesNumber; i++)
    {
        // get unrepeatable bonus number
        int nUniqueBonus = Array_At_Int("CHAMPION_RANDOM_BONUSES_ARRAY", i, oMob);
        effect eInc;
        switch(nUniqueBonus)
        {
            case 1: eInc = EffectAbilityIncrease(ABILITY_CONSTITUTION, d6() + iMobCR/5); break;
            case 2: eInc = EffectAbilityIncrease(ABILITY_DEXTERITY, d6() + iMobCR/5); break;
            case 3: eInc = EffectAbilityIncrease(ABILITY_STRENGTH, d6() + iMobCR/5); break;
            case 4: eInc = EffectAttackIncrease(iMobCR/5); break;
            case 5: eInc = EffectDamageIncrease(GetDamageBonusConstantFromNumber(d6() + iMobCR/5), DAMAGE_TYPE_MAGICAL); break;
            case 6: eInc = EffectDamageIncrease(GetDamageBonusConstantFromNumber(d6() + iMobCR/5), DAMAGE_TYPE_DIVINE); break;
            case 7: eInc = EffectACIncrease(d6(), AC_DODGE_BONUS); break;
            case 8: eInc = EffectACIncrease(d6(), AC_NATURAL_BONUS); break;
            case 9: eInc = EffectTemporaryHitpoints(bElite ? iMobCR * 100 : iMobCR * 10); break;
            case 10: eInc = EffectSpellResistanceIncrease(iMobCR); break;
            case 11: eInc = EffectSavingThrowIncrease(SAVING_THROW_ALL, d6() + iMobCR/5, SAVING_THROW_TYPE_ALL); break;
            case 12: eInc = EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, d6() + iMobCR/5); break;
            case 13: eInc = EffectRegenerate(iMobCR, 6.0); break;
            case 14: eInc = EffectDamageShield(iMobCR/5, DAMAGE_BONUS_1d6, DAMAGE_TYPE_ELECTRICAL); break;
            case 15: eInc = EffectImmunity(IMMUNITY_TYPE_KNOCKDOWN); break;
            case 16: eInc = EffectModifyAttacks(d2()); break;
            default: eInc = EffectACIncrease(1, AC_DODGE_BONUS); break; // apply extra dodge AC
        }
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eInc), oMob);
    }
}

int champion_CountEncounter(object oArea, location lLoc)
{
    int nCnt = GetLocalInt(oArea, "ENCOUNTER_COUNT");
    if (nCnt)
        return nCnt;
    nCnt = 1;
    object oEncounter = GetNearestObjectToLocation(OBJECT_TYPE_ENCOUNTER, lLoc, nCnt);
    while (GetIsObjectValid(oEncounter))
    {
        nCnt++;
        oEncounter = GetNearestObjectToLocation(OBJECT_TYPE_ENCOUNTER, lLoc, nCnt);
    }
    SetLocalInt(oArea, "ENCOUNTER_COUNT", nCnt - 1);
    return nCnt - 1;
}

void champion_CreateScout()
{
    string sResRef = GetResRef(OBJECT_SELF);
    object oArea = GetArea(OBJECT_SELF);
    location lLoc = GetLocation(OBJECT_SELF);

    if (GetIsObjectValid(GetLocalObject(oArea, "SCOUT"))) return; // check if one spawn active at a time
    int nEncounter = champion_CountEncounter(oArea, lLoc);
    if (!nEncounter) return;

    object oEncounter = GetNearestObjectToLocation(OBJECT_TYPE_ENCOUNTER, lLoc, Random(nEncounter) + 1);
    lLoc = GetLocation(oEncounter);

    object oPC = GetNearestCreatureToLocation(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, lLoc);

    float fCR = GetChallengeRating(OBJECT_SELF);
    int iScoutLevel = (fCR < 60.0) ? FloatToInt(fCR) : 60;

    // create scout if abs(Mob_CR - Player_LVL) <= 5 && Player_LVL < 35 and dont create low level scouts for Player_LVL > 35
    if (!GetIsObjectValid(oPC) || !(abs(iScoutLevel - GetHitDice(oPC)) <= 5 && GetHitDice(oPC) < 35) || GetHitDice(oPC) - iScoutLevel > 5 && GetHitDice(oPC) >= 35 )
        return;

    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc);
    SetLocalObject(oArea, "SCOUT", oCreature); // to check if one spawn active at a time
    SetLocalInt(oCreature, "IAMCHAMPION", FALSE); // Scout can not be champion
    SetLocalInt(oCreature, "IAMSCOUT", TRUE);

    if (!GetHasFeat(FEAT_KNOCKDOWN)) NWNX_Creature_AddFeat(oCreature, FEAT_KNOCKDOWN);
    if (!GetHasFeat(FEAT_IMPROVED_KNOCKDOWN)) NWNX_Creature_AddFeat(oCreature, FEAT_IMPROVED_KNOCKDOWN);

    if (iScoutLevel > 5)
    {
        DelayCommand(1.0, AssignCommand(oCreature, npc_Caster_ActionCastSpell(oCreature, oCreature, SPELL_SEE_INVISIBILITY,
                          METAMAGIC_EXTEND, iScoutLevel, iScoutLevel, TRUE)));
        DelayCommand(1.0, AssignCommand(oCreature, npc_Caster_ActionCastSpell(oCreature, oCreature, SPELL_INVISIBILITY,
                          METAMAGIC_EXTEND, iScoutLevel, iScoutLevel, TRUE)));
    }
    if (iScoutLevel > 15)
    {
        DelayCommand(1.0, AssignCommand(oCreature, npc_Caster_ActionCastSpell(oCreature, oCreature, SPELL_DISPLACEMENT,
                          METAMAGIC_EXTEND, iScoutLevel, iScoutLevel, TRUE)));
    }
    if (iScoutLevel > 25)
    {
        DelayCommand(1.0, AssignCommand(oCreature, npc_Caster_ActionCastSpell(oCreature, oCreature, SPELL_TRUE_SEEING,
                          METAMAGIC_EXTEND, iScoutLevel, iScoutLevel, TRUE)));
    }
    if (iScoutLevel > 35)
    {
        DelayCommand(1.0, AssignCommand(oCreature, npc_Caster_ActionCastSpell(oCreature, oCreature, SPELL_ETHEREALNESS,
                          METAMAGIC_EXTEND, iScoutLevel, iScoutLevel, TRUE)));
    }

    string sName = GetName(oCreature);
    SetName(oCreature, sName + " Scout");
    SetObjectVisualTransform(oCreature, OBJECT_VISUAL_TRANSFORM_SCALE, 0.5 + (IntToFloat(Random(25) + 1))/100);
    NWNX_Creature_SetMovementRate(oCreature, NWNX_CREATURE_MOVEMENT_RATE_VERY_FAST);

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, UnyieldingEffect(EffectVisualEffect(VFX_DUR_GLOW_BLUE)), oCreature);

    DelayCommand(3.0, AssignCommand(oCreature, ActionForceMoveToObject(oPC, TRUE, 3.0)));
}

void champion_EliteInit()
{
    object oStorage = GetWaypointByTag("elite_champions_storage");
    object oArea = GetFirstArea();
    Array_Clear("ENCOUNTERS_ARRAY", oStorage);
    while (GetIsObjectValid(oArea))
    {
        string sAreaName = GetName(oArea);
        if (FindSubString(sAreaName, "(") != -1 && FindSubString(sAreaName, ")") != -1)
        {
            int nNumberOfEncountersInArea = 0;
            object oEncounter = GetFirstObjectInArea(oArea, OBJECT_TYPE_ENCOUNTER);
            while (GetIsObjectValid(oEncounter))
            {
                int i;
                int bValid = FALSE;
                for(i = 0; i < NWNX_Encounter_GetNumberOfCreaturesInEncounterList(oEncounter); i++)
                {
                    struct NWNX_Encounter_CreatureListEntry stEncounter = NWNX_Encounter_GetEncounterCreatureByIndex(oEncounter, i);
                    if (stEncounter.challengeRating >= 35.0)
                        bValid = TRUE;
                }
                if (bValid)
                {
                    int nEncounterNumber = nNumberOfEncountersInArea++;
                    SetLocalObject(oStorage, "AREA_ENCOUNTER_TMP_" + IntToString(nEncounterNumber), oEncounter);
                    DelayCommand(10.0, DeleteLocalObject(oStorage, "AREA_ENCOUNTER_TMP_" + IntToString(nEncounterNumber)));
                }
                oEncounter = GetNextObjectInArea(oArea, OBJECT_TYPE_ENCOUNTER);
            }
            if (nNumberOfEncountersInArea > 0)
                Array_PushBack_Obj("ENCOUNTERS_ARRAY", GetLocalObject(oStorage, "AREA_ENCOUNTER_TMP_" + IntToString(Random(nNumberOfEncountersInArea))), oStorage);
        }
        oArea = GetNextArea();
    }
}


void champion_EliteRandomSpawn()
{
    object oStorage = GetWaypointByTag("elite_champions_storage");
    Array_Shuffle("ENCOUNTERS_ARRAY", oStorage);
    object oEncounter = Array_At_Obj("ENCOUNTERS_ARRAY", 0, oStorage);
    Array_Erase("ENCOUNTERS_ARRAY", 0, oStorage);
    object oArea = GetArea(oEncounter);
    location lLoc = GetLocation(oEncounter);
    string sResref = "";
    int i;
    for(i = 0; i < NWNX_Encounter_GetNumberOfCreaturesInEncounterList(oEncounter); i++)
    {
        struct NWNX_Encounter_CreatureListEntry stEncounter = NWNX_Encounter_GetEncounterCreatureByIndex(oEncounter, i);
        if (stEncounter.challengeRating >= 35.0)
        {
            sResref = stEncounter.resref;
            break;
        }
    }
    object oEliteChampion = CreateObject(OBJECT_TYPE_CREATURE, sResref, lLoc, TRUE);
    // no elite champions + champions bonuses
    DeleteLocalInt(oEliteChampion, "IAMCHAMPION");
    champion_ApplyAllBonuses(oEliteChampion, TRUE);
    string sEliteChampionName = GetName(oEliteChampion);
    ServerShout(ColorText(sEliteChampionName, TXT_COLOR_WHITE_T) +
                ColorText(" has been spawned in Area: ", TXT_COLOR_ORANGE) +
                ColorText(GetName(oArea), TXT_COLOR_WHITE_T));

    WriteLog("Grand Champion => " + sEliteChampionName + " has been spawned in Area " + GetName(oArea), LOG_LEVEL_DEBUG);
}

void champion_GenerateEliteReward(object oKiller, object oVictim, int bCaptain = FALSE)
{
    ServerShout(ColorText(GetName(oVictim), TXT_COLOR_WHITE_T) +
                ColorText(" has been killed by ", TXT_COLOR_ORANGE) +
                ColorText(GetName(oKiller) != "" ? GetName(oKiller) : "[unknown]", players_GetFactionColor(players_GetFaction(oKiller))) +
                ColorText(". Area: ", TXT_COLOR_ORANGE) +
                ColorText(GetName(GetArea(oVictim)), TXT_COLOR_WHITE_T));

    int nRoll;
    if(bCaptain)
        nRoll = d2();
    else
        nRoll = d4();

    switch(nRoll)
    {
        case 1:
            CreateLootOnObject(oVictim, LOOT_MOBS_LEVEL_09, 1);
        break;

        case 2:
        {
            int nSoulsDice = d3() + 2;
            int i;
            for(i = 0; i < nSoulsDice; i++)
            {
                object oSoulStone = CreateItemOnObject(CONST_ITEM_SOULSTONE, oVictim);
                SetIdentified(oSoulStone, TRUE);
                SetDroppableFlag(oSoulStone, TRUE);
            }
        }
        break;
        case 3:
            GenerateFameOnTarget(oVictim, FloatToInt(GetChallengeRating(oVictim)) * 2);
        break;
        case 4:
            GenerateCustomGoldOnTarget(oVictim, 20000 * FloatToInt(GetChallengeRating(oVictim)));
        break;
    }
}

int champion_GetBossType(object oBoss)
{
    string sCategory = "";
    string sSql = "SELECT category FROM boss_cooldowns WHERE boss_resref = ?";
    NWNX_SQL_PrepareQuery(sSql);
    NWNX_SQL_PreparedString(0, GetResRef(oBoss));
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sCategory = NWNX_SQL_ReadDataInActiveRow();
    }
    if     (sCategory == "blue")        return 1;
    else if(sCategory == "green")       return 2;
    else if(sCategory == "purple")      return 3;
    else if(sCategory == "red")         return 4;
    else if(sCategory == "artifact")    return 5;
    else                                return 0;
}

string champion_GetDiscordCategory(int nBossType)
{
    switch(nBossType)
    {
        case 1: return "Mini";
        case 2: return "Advanced";
        case 3: return "Lesser";
        case 4: return "Greater";
        case 5: return "Artifact";
    }
    return "";
}

string champion_BossChooseRandomPhrase()
{
    switch(Random(7))
    {
        case 0: return "Fucking bastards!";
        case 1: return "Freeze, you motherfucking cocksucking scumbags! I destroy you one by one!";
        case 2: return "Prepare your anuses!";
        case 3: return "I'll fuck you up!";
        case 4: return "I'm going to piss on your sad fucks!";
        case 5: return "Freeze shitweights! Take your dicks out of your mouths and I'll kick your asses one by one!";
    }
    return "I'll fuck your wives and children you fucking bastards!";
}

void champion_OnBossRageEnter(object oBoss)
{
    int nPlayersCountInArea = GetLocalInt(oBoss, "BOSS_AREA_PLAYERS_COUNT");
    float fDuration = GetLocalFloat(oBoss, "BOSS_RAGE_DURATION");
    int bShout = FALSE;

    effect eShield = EffectDamageShield(d20(8), DAMAGE_BONUS_2d12, DAMAGE_TYPE_SONIC);
    effect eLink = EffectLinkEffects(eShield, EffectDamageIncrease(DAMAGE_BONUS_2d12, DAMAGE_TYPE_DIVINE));

    if(nPlayersCountInArea > 2)
        eLink = EffectLinkEffects(eLink, EffectDamageIncrease(DAMAGE_BONUS_2d12, DAMAGE_TYPE_MAGICAL));
    if(nPlayersCountInArea > 3)
        eLink = EffectLinkEffects(eLink, EffectDamageIncrease(DAMAGE_BONUS_2d12, DAMAGE_TYPE_POSITIVE));
    if(nPlayersCountInArea > 4)
        eLink = EffectLinkEffects(eLink, EffectDamageIncrease(DAMAGE_BONUS_2d12, DAMAGE_TYPE_NEGATIVE));
    if(nPlayersCountInArea > 5)
    {
        bShout = TRUE;
        eLink = EffectLinkEffects(eLink, EffectDamageIncrease(DAMAGE_BONUS_2d12, DAMAGE_TYPE_SONIC));
    }
    if(nPlayersCountInArea > 6)
    {
        eLink = EffectLinkEffects(eLink, EffectDamageIncrease(DAMAGE_BONUS_2d12, DAMAGE_TYPE_COLD));
        NWNX_Creature_SetCriticalRangeModifier(oBoss, -d4());
    }

    int nChannel = TALKVOLUME_TALK;
    if(bShout)
        nChannel = TALKVOLUME_SHOUT;

    AssignCommand(oBoss, SpeakString(champion_BossChooseRandomPhrase(), nChannel));
    eLink = EffectLinkEffects(eLink, EffectAttackIncrease(20));
    eLink = EffectLinkEffects(eLink, EffectModifyAttacks(5));
    eLink = SupernaturalEffect(eLink);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HASTE, FALSE, 1.5), oBoss);
    AssignCommand(oBoss, DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oBoss, fDuration)));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_KNOCK), oBoss);
    AssignCommand(oBoss, DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GOOD_HELP), oBoss)));
}

void champion_OnBossRageTicks(object oBoss)
{
    effect eTick = EffectLinkEffects(EffectVisualEffect(VFX_COM_CHUNK_RED_LARGE), EffectVisualEffect(VFX_IMP_HEAD_ODD));
    AssignCommand(oBoss, DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eTick, oBoss)));
    // apply damage
    location lLoc = GetLocation(oBoss);
    object oLoop = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lLoc);
    while(GetIsObjectValid(oLoop))
    {
        if(GetIsEnemy(oLoop) && GetIsPC(oLoop) && !GetIsDM(oLoop))
        {
            effect eDamage = EffectDamage(d6(20) * (GetLocalInt(oBoss, "MAX_BOSS_HEALS") - GetLocalInt(oBoss, "BOSS_HEALS")),
                                          DAMAGE_TYPE_MAGICAL);
            AssignCommand(oLoop, DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oLoop)));
        }
        oLoop = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lLoc);
    }
}

void champion_OnBossRageExit(object oBoss)
{
    DeleteLocalInt(oBoss, "HEAL_AND_RAGE_ACTIVATED");
    SetPlotFlag(oBoss, FALSE);
    NWNX_Creature_SetCriticalRangeModifier(oBoss, 0);
    if(GetHasFeat(FEAT_STUNNING_FIST, oBoss, TRUE))
        NWNX_Creature_SetFeatRemainingUses(oBoss, FEAT_STUNNING_FIST, NWNX_Creature_GetFeatTotalUses(oBoss, FEAT_STUNNING_FIST));
}


void champion_Pyromaniac(int nMaxHitpoints, location lLoc)
{
    int nDamage = nMaxHitpoints / 4; // 25% from nMaxHitpoints

    // VFX_FNF_GAS_EXPLOSION_FIRE   'эффект на чара
    // PRCVFX_FNF_HELLFIRE_2    - взрыв
    // HGVFX_AOE_DELAYED_BLAST_PURPLE -- эффект который подсвечивает эпицентр до взрыва

    object oLoop = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lLoc);
    while(GetIsObjectValid(oLoop))
    {
        if(GetIsPC(oLoop) && !GetIsDM(oLoop))
        {
            effect eDamage = EffectDamage(nDamage, DAMAGE_TYPE_MAGICAL);
            AssignCommand(oLoop, DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oLoop)));
        }
        oLoop = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lLoc);
    }
}

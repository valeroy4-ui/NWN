/************************ [On Spawn] *******************************************
    Filename: j_ai_onspawn or nw_c2_default9
************************* [On Spawn] *******************************************/

#include "j_inc_spawnin"
#include "_inc_champ_boss"

int GetHealsCount(object oMob = OBJECT_SELF, int bDestroy = FALSE)
{
    int iHeals = 0;

    object oItem = GetFirstItemInInventory(oMob);
    while(GetIsObjectValid(oItem))
    {
        if(GetBaseItemType(oItem) == BASE_ITEM_POTIONS)
        {
            int iNext = 0;
            itemproperty ip = GetFirstItemProperty(oItem);
            while(GetIsItemPropertyValid(ip) && !iNext)
            {
                if(GetItemPropertySubType(ip) == IP_CONST_CASTSPELL_HEAL_11)
                {
                    iHeals += GetItemStackSize(oItem);
                    iNext = 1;
                    if(bDestroy) DestroyObject(oItem, 0.1);
                }
                ip = GetNextItemProperty(oItem);
            }
        }
        oItem = GetNextItemInInventory(oMob);
    }
    return iHeals;
}

void AI_Setup()
{
    if(GetRacialType(OBJECT_SELF) == RACIAL_TYPE_DRAGON)
    {
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectCutsceneGhost()), OBJECT_SELF);
        SetSpawnInCondition(AI_FLAG_COMBAT_FLYING, AI_COMBAT_MASTER);
        if(GetTag(OBJECT_SELF) == "cr_boss_hemin")
            SetAIInteger(AI_DRAGON_FREQUENCY_OF_BUFFET, 2);
        else
            SetAIInteger(AI_DRAGON_FREQUENCY_OF_BUFFET, 5);
        if(GetTag(OBJECT_SELF) == "cr_boss_shor")
            SetAIInteger(AI_DRAGON_FREQUENCY_OF_BREATH, 1);

    }

    SetAIInteger(AI_INTELLIGENCE, 10);
    SetAIInteger(AI_MORALE, 10);

    SetSpawnInCondition(AI_FLAG_TARGETING_LIKE_PCS, AI_TARGETING_FLEE_MASTER);
    SetSpawnInCondition(AI_FLAG_TARGETING_LIKE_LOWER_AC, AI_TARGETING_FLEE_MASTER);
    SetSpawnInCondition(AI_FLAG_TARGETING_LIKE_LOWER_HD, AI_TARGETING_FLEE_MASTER);
    SetAIConstant(AI_FAVOURED_ENEMY_CLASS, CLASS_TYPE_BARD);
    SetAIConstant(AI_FAVOURED_ENEMY_CLASS, CLASS_TYPE_CLERIC);
    SetAIInteger(AI_MAX_TURNS_TO_ATTACK_ONE_TARGET, 1);
    SetAIInteger(AI_MELEE_LAST_TO_NEW_TARGET_CHANCE, 25);
    SetAIInteger(AI_RANGED_LAST_TO_NEW_TARGET_CHANCE, 25);
    SetAIInteger(AI_SPELL_LAST_TO_NEW_TARGET_CHANCE, 25);

    SetSpawnInCondition(AI_FLAG_FLEEING_FEARLESS, AI_TARGETING_FLEE_MASTER);
    SetSpawnInCondition(AI_FLAG_COMBAT_FLAG_FAST_BUFF_ENEMY, AI_COMBAT_MASTER);
    SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PICKPOCKETING, AI_OTHER_COMBAT_MASTER);
    SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_OPENING_LOCKED_DOORS, AI_OTHER_COMBAT_MASTER);
    SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_USING_HEALING_KITS, AI_OTHER_COMBAT_MASTER);
    SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PARRYING, AI_OTHER_COMBAT_MASTER);
    SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_SEARCH, AI_OTHER_COMBAT_MASTER);
    SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_CONCENTRATION, AI_OTHER_COMBAT_MASTER);
    SetSpawnInCondition(AI_FLAG_OTHER_NO_POLYMORPHING, AI_OTHER_MASTER);
    SetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_ITEMS, AI_OTHER_MASTER);
    SetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_CURING_ALLIES, AI_OTHER_MASTER);

    //SetSpawnInCondition(AI_FLAG_OTHER_REST_AFTER_COMBAT, AI_OTHER_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_LISTENING, AI_OTHER_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_EMPATHY, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_LAG_EQUIP_MOST_DAMAGING, AI_OTHER_MASTER);
    //SetAIInteger(SECONDS_BETWEEN_STATUS_CHECKS, 30);
    //SetAIInteger(AI_CORPSE_DESTROY_TIME, 5);
}



void main()
{
    int nBossType = champion_GetBossType(OBJECT_SELF);
    // calculate mutation chance
    int nWipePhase = GetLocalInt(GetModule(), CORMYREAN_WIPE_PHASE);
    int nChance = 5;
    switch(nWipePhase)
    {
        case CORMYREAN_WIPE_PHASE_2:
            nChance = 7;
        break;
        case CORMYREAN_WIPE_PHASE_3:
            nChance = 10;
        break;
        case CORMYREAN_WIPE_PHASE_4:
            nChance = 12;
        break;
    }
    int bMutated = d100() <= nChance;
    //int bMutated = 1;

    if(nBossType > 1) // advanced +
    {
        SetLocalInt(OBJECT_SELF, "BOSS_HEALS", GetHealsCount(OBJECT_SELF, TRUE));
        SetLocalInt(OBJECT_SELF, "MAX_BOSS_HEALS", GetLocalInt(OBJECT_SELF, "BOSS_HEALS"));
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectSpellImmunity(SPELL_WORD_OF_FAITH), OBJECT_SELF);
        SetImmortal(OBJECT_SELF, TRUE);
    }
    if(nBossType > 1) // advanced +
    {
        object oBossArea = GetArea(OBJECT_SELF);
        SetLocalInt(oBossArea, "NO_CORPSE", TRUE);
        SetLocalInt(oBossArea, "NO_GRAVESTONE", TRUE);
        SetLocalInt(oBossArea, "BOSS_AREA", TRUE);
    }
    if(bMutated)
    {
        champion_ApplyAllBonuses(OBJECT_SELF, FALSE, TRUE);
        SetLocalInt(OBJECT_SELF, "MUTATED", TRUE);
    }

    SetLocalInt(OBJECT_SELF, "BOSS_TYPE", nBossType);

    if (GetLocalFloat(OBJECT_SELF, "VISUAL_TRANSFORM_COEFFICIENT") != 0.0)
    {
        SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_SCALE, GetLocalFloat(OBJECT_SELF, "VISUAL_TRANSFORM_COEFFICIENT"));
    }

    ExecuteScript("ai_loot_saver", OBJECT_SELF);



/************************ [Bioware: Animations/Waypoints/Treasure] ************/
    AI_Setup();
    // AI Behaviour. DO NOT CHANGE! DO NOT CHANGE!!!
    AI_SetUpEndOfSpawn();
        // This MUST be called. It fires these events:
        // SetUpSpells, SetUpSkillToUse, SetListeningPatterns, SetWeapons, AdvancedAuras.
        // These MUST be called! the AI might fail to work correctly if they don't fire!

/************************ [User] ***********************************************
    This is the ONLY place you should add user things, on spawn, such as
    visual effects or anything, as it is after SetUpEndOfSpawn. By default, this
    does have encounter animations on. This is here, so is easily changed :-D

    Be careful otherwise.

    Notes:
    - SetListening is already set to TRUE, unless AI_FLAG_OTHER_LAG_NO_LISTENING is on.
    - SetListenPattern's are set from 0 to 7.
    - You can use the wrappers AI_SpawnInInstantVisual and AI_SpawnInPermamentVisual
      for visual effects (Instant/Permament as appropriate).
************************* [User] **********************************************/
    // Example (and default) of user addition:
    // - If we are from an encounter, set mobile (move around) animations.
    if(GetIsEncounterCreature())
    {
        SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS, NW_GENERIC_MASTER);
    }
    // Leave this in if you use the variable for creature attacks, as for golems. Bioware's code.
//    int nNumber = GetLocalInt(OBJECT_SELF, "CREATURE_VAR_NUMBER_OF_ATTACKS");
//    if(nNumber > 0)
//    {
//        SetBaseAttackBonus(nNumber);
//    }


/************************ [User] **********************************************/

}



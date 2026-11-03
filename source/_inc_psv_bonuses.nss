#include "nwnx_creature"
#include "_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_itemprop"
#include "x0_i0_match"
#include "nwnx_item"
#include "_inc_fameshop"
#include "_inc_runes"
//#include "x3_inc_skin"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////


// applies DD passive abilities
void ApplyDDPassiveAbilities(object oPC);

// set archmage monk AC analog
void SetArchmageAncientAC(object oPC);

// add AC for characters with dual weapons
void AddACAmbidex(object oPC);

// add cold damage for dex characters
void DexDamage(object oPC);

// return true if weapon work with finess feat
int GetDexWeapon(object oItem);

// returns monk magic damage for gloves depending on Level and Wis_mod
int GetMonkBonusDamageAmountMagical(int iLevel, int iWisdomMod);

// returns monk piercing damage for gloves depending on Level and Wis_mod
int GetMonkBonusDamageAmountPiercing(int iLevel, int iWisdomMod);

// applies magic and piercing damage to monk's gloves
void AddMonkBonuses(object oPC);

// add assassin's onhits to weapon and gloves
void AddAssassinWeaponOnHit(object oPC);

// unequip shield for shifter or characters with epic dodge
void CheckShieldOnShifter(object oPC);

// get level depending magic damage for BG
int BGLevelToDamage(int iLevel, object oPC);

// add BG magic damage for melee weapon
void AddBgDamageBonus(object oPC);

// crossclass tumble compensation, need to evade AoO's
void psv_TumbleCompensation(object oPC);

// fameshop critical hit range bonuses for fighter or monk
void psv_ApplyBonusCriticalRange(object oPC);

// in development ..
void psv_CustomDivineGrace(object oPC);

// applies concentration and taunt bonus for specific classes
void psv_TauntAndConcentrationBonus(object oPC);

// applies runic heal from Epic Rune of Regeneration
void psv_ApplyRuneOfRegenHeal(object oPC);

// add rogue's onhits to weapon and gloves
void AddRogueWeaponOnHit(object oPC);

// add Slayer's onhits to weapon and gloves
void AddSlayerWeaponOnHit(object oPC);

// generates bonus saves for Wild Fortitude and Divine Saves feats
void psv_AdjustCustomSaves(object oPC);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void ApplyWarlordPassiveAbilities(object oPC)
{
    int nDDLevel = GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oPC);
    // sanity check
    if(!nDDLevel) return;

    int iAC = 10 + nDDLevel / 6;
    int iRegeneration = nDDLevel - 10 > 0 ? nDDLevel - 10 : 0;

    effect eLink = EffectACIncrease(iAC, AC_DEFLECTION_BONUS);
    if (iRegeneration > 0)
        eLink = EffectLinkEffects(EffectRegenerate(iRegeneration, 6.0), eLink);

    eLink = SetEffectSpellId(eLink, SPELL_BONUS_DWARVEN_PASSIVE_ABILITIES);
    eLink = HideEffectIcon(eLink);
    eLink = ExtraordinaryEffect(eLink);

    RemoveEffectsFromSpell(oPC, SPELL_BONUS_DWARVEN_PASSIVE_ABILITIES);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oPC, DURATION_SERVER_SESSION);
}

void SetArchmageAncientAC(object oPC)
{
    if (!GetIsPC(oPC))
        return;
    int iArchmageAcBonus = 0;
    if(GetHasFeat(EPIC_FEAT_ANCIENT_MAGE_ARMOR, oPC))
    {
        iArchmageAcBonus += GetAbilityModifier(ABILITY_WISDOM, oPC);
        if (GetLevelByClass(CLASS_TYPE_BARD, oPC) == 38)
            iArchmageAcBonus += GetAbilityModifier(ABILITY_CHARISMA, oPC);
        object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
        if(GetIsObjectValid(oArmor))
            iArchmageAcBonus = (NWNX_Item_GetBaseArmorClass(oArmor) > 0) ? 0 : iArchmageAcBonus;
        if(MatchShield(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC)))
            iArchmageAcBonus = 0;
        if(iArchmageAcBonus < 0)
            iArchmageAcBonus = 0;
    }
    NWNX_Creature_SetBaseAC(oPC, iArchmageAcBonus);
}

void AddACAmbidex(object oPC)
{
    RemoveEffectsFromSpell(oPC, SPELL_DUAL_WIELDING_AC);
    if (GetLevelByClass(CLASS_TYPE_MONK, oPC) > 2 || GetLevelByClass(CLASS_TYPE_ARCHMAGE, oPC) > 1)
        return;

    object oLeftHandWeapon  = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);

    if(!GetIsObjectValid(oLeftHandWeapon) || !IPGetIsMeleeWeapon(oLeftHandWeapon)) return;


    if(GetHasFeat(FEAT_IMPROVED_TWO_WEAPON_FIGHTING, oPC))
    {
        int iAcShieldBonus = GetHitDice(oPC) / 10;
        effect eAC = EffectACIncrease(iAcShieldBonus, AC_SHIELD_ENCHANTMENT_BONUS);
        eAC = SetEffectSpellId(eAC, SPELL_DUAL_WIELDING_AC);
        SendMessageToPC(oPC, "+" + IntToString(iAcShieldBonus) + " Shield AC for Dual-Wielding has been applied.");
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eAC), oPC);
    }
}

void DexDamage(object oPC)
{
    object oRightHandWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);

    if (GetIsObjectValid(oRightHandWeapon) == FALSE) return;
    if (GetWeaponRanged(oRightHandWeapon) == TRUE) return;

    int iDex = GetAbilityScore(oPC, ABILITY_DEXTERITY, TRUE);

    if (GetAbilityScore(oPC, ABILITY_STRENGTH, TRUE) <= 24 && GetDexWeapon(oRightHandWeapon) == TRUE)
    {
        int iDamageConstant;
        if(iDex >= 25 && iDex <= 26)
        {
            iDamageConstant = IP_CONST_DAMAGEBONUS_1d4;
        }
        if(iDex >= 27 && iDex <= 28)
        {
            iDamageConstant = IP_CONST_DAMAGEBONUS_1d6;
        }
        if(iDex >= 29 && iDex <= 30)
        {
            iDamageConstant = IP_CONST_DAMAGEBONUS_1d8;
        }
        if(iDex >= 31 && iDex <= 32)
        {
            iDamageConstant = IP_CONST_DAMAGEBONUS_1d10;
        }
        if(iDex >= 33 && iDex <= 34)
        {
            iDamageConstant = IP_CONST_DAMAGEBONUS_1d12;
        }
        if(iDex >= 35 && iDex <= 36)
        {
            iDamageConstant = IP_CONST_DAMAGEBONUS_2d6;
        }
        if(iDex >= 37)
        {
            iDamageConstant = IP_CONST_DAMAGEBONUS_2d8;
        }
        IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, iDamageConstant),
                                                             DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

        object oLeftHandWeapon  = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
        if (GetIsObjectValid(oLeftHandWeapon) == TRUE && GetDexWeapon(oLeftHandWeapon) == TRUE)
        IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_COLD, iDamageConstant),
                                                             DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    }
}

int GetDexWeapon(object oItem)
{
      if(GetBaseItemType(oItem)==BASE_ITEM_DAGGER
      || GetBaseItemType(oItem)==BASE_ITEM_HANDAXE
      || GetBaseItemType(oItem)==BASE_ITEM_KAMA
      || GetBaseItemType(oItem)==BASE_ITEM_KUKRI
      || GetBaseItemType(oItem)==BASE_ITEM_LIGHTHAMMER
      || GetBaseItemType(oItem)==BASE_ITEM_LIGHTMACE
      || GetBaseItemType(oItem)==BASE_ITEM_RAPIER
      || GetBaseItemType(oItem)==BASE_ITEM_SHORTSWORD
      || GetBaseItemType(oItem)==BASE_ITEM_SICKLE
      || GetBaseItemType(oItem)==BASE_ITEM_WHIP
      || GetBaseItemType(oItem)==BASE_ITEM_GLOVES)
      {
        return TRUE;
      }
      return FALSE;
}


int GetMonkBonusDamageAmountMagical(int iLevel, int iWisdomMod)
{
    int iDamageBonus;
    if (iWisdomMod >= 8)
    {
        if     (iLevel >= 2  && iLevel <4)  iDamageBonus = IP_CONST_DAMAGEBONUS_5;
        else if(iLevel >= 4  && iLevel <6)  iDamageBonus = IP_CONST_DAMAGEBONUS_6;
        else if(iLevel >= 6  && iLevel <8)  iDamageBonus = IP_CONST_DAMAGEBONUS_7;
        else if(iLevel >= 8  && iLevel <10) iDamageBonus = IP_CONST_DAMAGEBONUS_8;
        else if(iLevel >= 10 && iLevel <12) iDamageBonus = IP_CONST_DAMAGEBONUS_9;
        else if(iLevel >= 12 && iLevel <14) iDamageBonus = IP_CONST_DAMAGEBONUS_10;
        else if(iLevel >= 14 && iLevel <16) iDamageBonus = IP_CONST_DAMAGEBONUS_11;
        else if(iLevel >= 16 && iLevel <18) iDamageBonus = IP_CONST_DAMAGEBONUS_12;
        else if(iLevel >= 18 && iLevel <20) iDamageBonus = IP_CONST_DAMAGEBONUS_13;
        else if(iLevel >= 20 && iLevel <22) iDamageBonus = IP_CONST_DAMAGEBONUS_14;
        else if(iLevel >= 22 && iLevel <24) iDamageBonus = IP_CONST_DAMAGEBONUS_15;
        else if(iLevel >= 24 && iLevel <26) iDamageBonus = IP_CONST_DAMAGEBONUS_16;
        else if(iLevel >= 26 && iLevel <28) iDamageBonus = IP_CONST_DAMAGEBONUS_17;
        else if(iLevel >= 28 && iLevel <30) iDamageBonus = IP_CONST_DAMAGEBONUS_18;
        else if(iLevel >= 30 && iLevel <32) iDamageBonus = IP_CONST_DAMAGEBONUS_19;
        else if(iLevel >= 32)               iDamageBonus = IP_CONST_DAMAGEBONUS_20;
    }
    return iDamageBonus;
}

int GetMonkBonusDamageAmountPiercing(int iLevel, int iWisdomMod)
{
    int iDamageBonus;
    if (iWisdomMod >= 4)
    {
        if     (iLevel >= 1  && iLevel <3)  iDamageBonus = IP_CONST_DAMAGEBONUS_1;
        else if(iLevel >= 3  && iLevel <5)  iDamageBonus = IP_CONST_DAMAGEBONUS_2;
        else if(iLevel >= 5  && iLevel <7)  iDamageBonus = IP_CONST_DAMAGEBONUS_3;
        else if(iLevel >= 7  && iLevel <9)  iDamageBonus = IP_CONST_DAMAGEBONUS_4;
        else if(iLevel >= 9  && iLevel <11) iDamageBonus = IP_CONST_DAMAGEBONUS_5;
        else if(iLevel >= 11 && iLevel <13) iDamageBonus = IP_CONST_DAMAGEBONUS_6;
        else if(iLevel >= 13 && iLevel <15) iDamageBonus = IP_CONST_DAMAGEBONUS_7;
        else if(iLevel >= 15 && iLevel <17) iDamageBonus = IP_CONST_DAMAGEBONUS_8;
        else if(iLevel >= 17 && iLevel <19) iDamageBonus = IP_CONST_DAMAGEBONUS_9;
        else if(iLevel >= 19 && iLevel <21) iDamageBonus = IP_CONST_DAMAGEBONUS_10;
        else if(iLevel >= 21 && iLevel <23) iDamageBonus = IP_CONST_DAMAGEBONUS_11;
        else if(iLevel >= 23 && iLevel <25) iDamageBonus = IP_CONST_DAMAGEBONUS_12;
        else if(iLevel >= 25 && iLevel <27) iDamageBonus = IP_CONST_DAMAGEBONUS_13;
        else if(iLevel >= 27 && iLevel <29) iDamageBonus = IP_CONST_DAMAGEBONUS_14;
        else if(iLevel >= 29 && iLevel <31) iDamageBonus = IP_CONST_DAMAGEBONUS_15;
        else if(iLevel >= 31 && iLevel <33) iDamageBonus = IP_CONST_DAMAGEBONUS_16;
        else if(iLevel >= 33 && iLevel <35) iDamageBonus = IP_CONST_DAMAGEBONUS_17;
        else if(iLevel >= 35 && iLevel <37) iDamageBonus = IP_CONST_DAMAGEBONUS_18;
        else if(iLevel >= 37 && iLevel <39) iDamageBonus = IP_CONST_DAMAGEBONUS_19;
        else if(iLevel >= 39)               iDamageBonus = IP_CONST_DAMAGEBONUS_20;
    }
    return iDamageBonus;
}

void AddMonkBonuses(object oPC)
{
    int iMonkLevel = GetLevelByClass(CLASS_TYPE_MONK, oPC);
    object oGloves = GetItemInSlot(INVENTORY_SLOT_ARMS);

    // sanity check
    if (!iMonkLevel || !GetIsObjectValid(oGloves) || GetBaseItemType(oGloves) != BASE_ITEM_GLOVES)
        return;

    int iWisdomMod = GetAbilityModifier(ABILITY_WISDOM, oPC);

    IPSafeAddItemProperty(oGloves, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL,
                                                           GetMonkBonusDamageAmountMagical(iMonkLevel, iWisdomMod)),
                                                           DURATION_SERVER_SESSION,
                                                           X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

    IPSafeAddItemProperty(oGloves, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_PIERCING,
                                                           GetMonkBonusDamageAmountPiercing(iMonkLevel, iWisdomMod)),
                                                           DURATION_SERVER_SESSION,
                                                           X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    if(GetHasFeat(FEAT_PAINFUL_HIT, oPC))
    {
        /*
        if (GetIsObjectValid(oRightHandWeapon) && IPGetIsMeleeWeapon(oRightHandWeapon))
            IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_PAINFUL_HIT, iSlayerLvl),
                                                    DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oLeftHandWeapon)  && IPGetIsMeleeWeapon(oLeftHandWeapon))
            IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_PAINFUL_HIT, iSlayerLvl),
                                                   DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);   */
        IPSafeAddItemProperty(oGloves, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_PAINFUL_HIT, iMonkLevel),
                                       DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
}

void AddAssassinWeaponOnHit(object oPC)
{
    int iAssLvl = GetLevelByClass(CLASS_TYPE_ASSASSIN, oPC);
    if(iAssLvl < 10) // sanity check
        return;
    object oRightHandWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if(!IPGetIsMeleeWeapon(oRightHandWeapon))
        return;
    object oLeftHandWeapon  = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    object oGloves = GetItemInSlot(INVENTORY_SLOT_ARMS);
    if (iAssLvl >= 10) // add Assasin Special hit
    {
        if (GetIsObjectValid(oRightHandWeapon) && IPGetIsMeleeWeapon(oRightHandWeapon))
            IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_SCARE, iAssLvl),
                                                    DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oLeftHandWeapon)  && IPGetIsMeleeWeapon(oLeftHandWeapon))
            IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_SCARE, iAssLvl),
                                                   DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oGloves) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
            IPSafeAddItemProperty(oGloves, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_SCARE, iAssLvl),
                                           DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
    if (iAssLvl >= 19) // add Dark hit
    {
        if (GetIsObjectValid(oRightHandWeapon) && IPGetIsMeleeWeapon(oRightHandWeapon))
            IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_DARK_HIT, iAssLvl),
                                                    DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oLeftHandWeapon)  && IPGetIsMeleeWeapon(oLeftHandWeapon))
            IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_DARK_HIT, iAssLvl),
                                                   DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oGloves) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
            IPSafeAddItemProperty(oGloves, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_DARK_HIT, iAssLvl),
                                           DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
    if (iAssLvl >= 20) // add Assassination Mark
    {
        if (GetIsObjectValid(oRightHandWeapon) && IPGetIsMeleeWeapon(oRightHandWeapon))
            IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ASSASSN_MARK, iAssLvl),
                                                    DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oLeftHandWeapon)  && IPGetIsMeleeWeapon(oLeftHandWeapon))
            IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ASSASSN_MARK, iAssLvl),
                                                   DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oGloves) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
            IPSafeAddItemProperty(oGloves, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ASSASSN_MARK, iAssLvl),
                                           DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
}


void CheckShieldOnShifter(object oPC)
{
    if (!GetIsPC(oPC))
        return;
    object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    if (!GetIsObjectValid(oShield))
        return;
    if((GetLevelByClass(CLASS_TYPE_SHIFTER, oPC) >= 1  || GetHasFeat(FEAT_EPIC_DODGE, oPC)) && MatchShield(oShield))
        NWNX_Creature_RunUnequip(oPC, oShield);
}

int BGLevelToDamage(int iLevel, object oPC)
{
    int iDamageBonus;

    if      (iLevel >= 2 && iLevel  < 5)  iDamageBonus = IP_CONST_DAMAGEBONUS_4;
    else if (iLevel >= 5 && iLevel  < 8)  iDamageBonus = IP_CONST_DAMAGEBONUS_6;
    else if (iLevel >= 8 && iLevel  < 11) iDamageBonus = IP_CONST_DAMAGEBONUS_8;
    else if (iLevel >= 11 && iLevel < 14) iDamageBonus = IP_CONST_DAMAGEBONUS_10;
    else if (iLevel >= 14 && iLevel < 17) iDamageBonus = IP_CONST_DAMAGEBONUS_12;
    else if (iLevel >= 17 && iLevel < 20) iDamageBonus = IP_CONST_DAMAGEBONUS_14;
    else if (iLevel >= 20 && iLevel < 23) iDamageBonus = IP_CONST_DAMAGEBONUS_16;
    else if (iLevel >= 23 && iLevel < 26) iDamageBonus = IP_CONST_DAMAGEBONUS_18;
    else if (iLevel >= 26 && iLevel < 29) iDamageBonus = IP_CONST_DAMAGEBONUS_20;
    else if (iLevel >= 29 && iLevel < 32) iDamageBonus = IP_CONST_DAMAGEBONUS_22;
    else if (iLevel >= 32 && iLevel < 35) iDamageBonus = IP_CONST_DAMAGEBONUS_24;
    else if (iLevel >= 35 && iLevel < 38) iDamageBonus = IP_CONST_DAMAGEBONUS_26;
    else if (iLevel >= 38)                iDamageBonus = IP_CONST_DAMAGEBONUS_28;

    return iDamageBonus;
}


void AddBgDamageBonus(object oPC)
{

    int iBGLevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD, oPC);
    if(!iBGLevel)
        return;

    object oRightHandWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    object oLeftHandWeapon  = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    object oGloves          = GetItemInSlot(INVENTORY_SLOT_ARMS);

    if (GetLevelByClass(CLASS_TYPE_MONK, oPC) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
        return;

    itemproperty ipBgDamage = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_MAGICAL, BGLevelToDamage(iBGLevel, oPC));

    if (IPGetIsMeleeWeapon(oRightHandWeapon))
        IPSafeAddItemProperty(oRightHandWeapon, ipBgDamage, DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

    if (IPGetIsMeleeWeapon(oLeftHandWeapon))
        IPSafeAddItemProperty(oLeftHandWeapon,  ipBgDamage, DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

    if (GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
        IPSafeAddItemProperty(oGloves, ipBgDamage, DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
}

void psv_TumbleCompensation(object oPC)
{
    object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    if (GetIsObjectValid(oShield) && GetBaseItemType(oShield) == BASE_ITEM_TOWERSHIELD)
    {
        int nBonus = GetHitDice(oPC)/2 /* crossclass tumble compensation */;
        IPSafeAddItemProperty(oShield, ItemPropertySkillBonus(SKILL_TUMBLE, nBonus),
                                       DURATION_SERVER_SESSION,
                                       X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    }
}

void psv_ApplyBonusCriticalRange(object oPC)
{
    int bGetHasDDabilitiesActive = GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oPC) && (GetHasSpellEffect(SPELL_WARLORD_FURY, oPC) ||
                                   GetHasSpellEffect(SPELL_BATTLEFIELD_ECHO, oPC)    ||  GetHasSpellEffect(SPELL_WARLORD_GUARD, oPC));
    // restore critical range to default value
    if(!bGetHasDDabilitiesActive)
        NWNX_Creature_SetCriticalRangeModifier(oPC, 0, 0);
    // dd has own dont stackable crit range abilities
    if(GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oPC))
        return;
    if(!GetLevelByClass(CLASS_TYPE_MONK, oPC)      && !GetLevelByClass(CLASS_TYPE_FIGHTER, oPC) &&
       !GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC) && !GetHasFeat(FEAT_KI_CRITICAL_1, oPC))
        return;
    int nBitArray = GetCriticalHitBonusesBitArray(oPC);
    if(!nBitArray && !GetHasFeat(FEAT_KI_CRITICAL_1, oPC))
        return;
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    object oGloves = GetItemInSlot(INVENTORY_SLOT_ARMS, oPC);
    if(GetLevelByClass(CLASS_TYPE_FIGHTER, oPC) > 20 && GetIsObjectValid(oWeapon))
    {
        int nFameShopPaidBonus = 0;
        if(nBitArray & FAMESHOP_FIGHTER_CRIT_RANGE_1)
            nFameShopPaidBonus += 1;
        if(nBitArray & FAMESHOP_FIGHTER_CRIT_RANGE_2)
            nFameShopPaidBonus += 1;
        int nModifier = -1 * nFameShopPaidBonus;
        NWNX_Creature_SetCriticalRangeModifier(oPC, nModifier, 0);
    }
    else if(GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC) > 30 && GetIsObjectValid(oWeapon))
    {
        int nFameShopPaidBonus = 0;
        if(nBitArray & FAMESHOP_BARBARIAN_CRIT_RANGE_1)
            nFameShopPaidBonus += 1;
        if(nBitArray & FAMESHOP_BARBARIAN_CRIT_RANGE_2)
            nFameShopPaidBonus += 1;
        int nModifier = -1 * nFameShopPaidBonus;
        NWNX_Creature_SetCriticalRangeModifier(oPC, nModifier, 0);
    }
    else if(GetLevelByClass(CLASS_TYPE_MONK, oPC) && !GetIsObjectValid(oWeapon) &&
           (GetBaseItemType(oGloves) == BASE_ITEM_GLOVES || !GetIsObjectValid(oGloves)))
    {
        int nFameShopPaidBonus = 0;
        if(nBitArray & FAMESHOP_MONK_CRIT_RANGE_1)
            nFameShopPaidBonus += 1;
        int nModifier = -1 * nFameShopPaidBonus;
        NWNX_Creature_SetCriticalRangeModifier(oPC, nModifier, 0);
    }
    else if(GetHasFeat(FEAT_KI_CRITICAL_1, oPC))
    {
        int nModifier = -1 * (GetHasFeat(FEAT_KI_CRITICAL_1, oPC) + GetHasFeat(FEAT_KI_CRITICAL_2, oPC) + GetHasFeat(FEAT_KI_CRITICAL_3, oPC));
        NWNX_Creature_SetCriticalRangeModifier(oPC, nModifier, 0);
    }
}

void psv_TauntAndConcentrationBonus(object oPC)
{
    RemoveEffectsFromSpell(oPC, SPELL_CORMYR_PASSIVE_CONCENTRATION_TAUNT);
    int nTauntBonus = (GetLevelByClass(CLASS_TYPE_ARCHMAGE, oPC) + GetLevelByClass(CLASS_TYPE_BARD, oPC) +
                       GetLevelByClass(CLASS_TYPE_HARPER, oPC)) / 4 /*+ GetLevelByClass(CLASS_TYPE_BLACKGUARD, oPC) / 4 */;
    int nConcentrationBonus = (GetLevelByClass(CLASS_TYPE_ARCHMAGE, oPC) + GetLevelByClass(CLASS_TYPE_BARD, oPC) +
                               GetLevelByClass(CLASS_TYPE_CLERIC, oPC) + GetLevelByClass(CLASS_TYPE_DRUID, oPC) +
                               GetLevelByClass(CLASS_TYPE_HARPER, oPC) + GetLevelByClass(CLASS_TYPE_SORCERER, oPC)) / 8;

    effect eTaunt = EffectSkillIncrease(SKILL_TAUNT, nTauntBonus);
    effect eConcentration = EffectSkillIncrease(SKILL_CONCENTRATION, nConcentrationBonus);
    effect eLink = EffectLinkEffects(eTaunt, eConcentration);
    eLink = HideEffectIcon(eLink);
    eLink = SetEffectSpellId(eLink, SPELL_CORMYR_PASSIVE_CONCENTRATION_TAUNT);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eLink), oPC, DURATION_SERVER_SESSION);
}

void psv_ApplyRuneOfRegenHeal(object oPC)
{
    RemoveEffectsFromSpell(oPC, SPELL_CORMYR_RUNE_OF_REGEN_HEAL);
    float fRunicRegenInterval = 0.0;
    if     (runes_GetHasRune(oPC, RUNE_TYPE_EPIC_MISC, RUNE_EPIC_MISC_REGENERATION_V))
        fRunicRegenInterval = RUNE_EPIC_MISC_REGEN_V_VALUE;
    else if(runes_GetHasRune(oPC, RUNE_TYPE_EPIC_MISC, RUNE_EPIC_MISC_REGENERATION_IV))
        fRunicRegenInterval = RUNE_EPIC_MISC_REGEN_IV_VALUE;
    else if(runes_GetHasRune(oPC, RUNE_TYPE_EPIC_MISC, RUNE_EPIC_MISC_REGENERATION_III))
        fRunicRegenInterval = RUNE_EPIC_MISC_REGEN_III_VALUE;
    if(fRunicRegenInterval != 0.0)
    {
        effect eRunicHeal = EffectRunScript("", "", "_mod_runscript", fRunicRegenInterval);
        eRunicHeal = SetEffectSpellId(eRunicHeal, SPELL_CORMYR_RUNE_OF_REGEN_HEAL);
        eRunicHeal = HideEffectIcon(eRunicHeal);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eRunicHeal), oPC, DURATION_SERVER_SESSION);
    }
}

void AddRogueWeaponOnHit(object oPC)
{
    int iRogueLvl = GetLevelByClass(CLASS_TYPE_ROGUE, oPC);
    if(iRogueLvl < 10) // sanity check
        return;
    object oRightHandWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if(!IPGetIsMeleeWeapon(oRightHandWeapon))
        return;
    object oLeftHandWeapon  = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    object oGloves = GetItemInSlot(INVENTORY_SLOT_ARMS);
    if (iRogueLvl >= 10) // add Can't see me
    {
        if (GetIsObjectValid(oRightHandWeapon) && IPGetIsMeleeWeapon(oRightHandWeapon))
            IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_CANT_SEE_ME, iRogueLvl),
                                                    DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oLeftHandWeapon)  && IPGetIsMeleeWeapon(oLeftHandWeapon))
            IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_CANT_SEE_ME, iRogueLvl),
                                                   DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oGloves) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
            IPSafeAddItemProperty(oGloves, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_CANT_SEE_ME, iRogueLvl),
                                           DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
    if (iRogueLvl >= 19) // add Dark strike
    {
        if (GetIsObjectValid(oRightHandWeapon) && IPGetIsMeleeWeapon(oRightHandWeapon))
            IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_DARK_STRIKE, iRogueLvl),
                                                    DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oLeftHandWeapon)  && IPGetIsMeleeWeapon(oLeftHandWeapon))
            IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_DARK_STRIKE, iRogueLvl),
                                                   DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oGloves) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
            IPSafeAddItemProperty(oGloves, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_DARK_STRIKE, iRogueLvl),
                                           DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
    if (iRogueLvl >= 20) // add Assassination Mark
    {
        if (GetIsObjectValid(oRightHandWeapon) && IPGetIsMeleeWeapon(oRightHandWeapon))
            IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ASSASSN_MARK, iRogueLvl),
                                                    DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oLeftHandWeapon)  && IPGetIsMeleeWeapon(oLeftHandWeapon))
            IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ASSASSN_MARK, iRogueLvl),
                                                   DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oGloves) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
            IPSafeAddItemProperty(oGloves, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_ASSASSN_MARK, iRogueLvl),
                                           DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
    if (GetHasFeat(FEAT_CRIPPLING_STRIKE_ROGUE, oPC)) // add Crippling Strike Rogue
    {
        if (GetIsObjectValid(oRightHandWeapon) && IPGetIsMeleeWeapon(oRightHandWeapon))
            IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_CRIPPLING_ROGUE, iRogueLvl),
                                                    DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oLeftHandWeapon)  && IPGetIsMeleeWeapon(oLeftHandWeapon))
            IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_CRIPPLING_ROGUE, iRogueLvl),
                                                   DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oGloves) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
            IPSafeAddItemProperty(oGloves, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_CRIPPLING_ROGUE, iRogueLvl),
                                           DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
}

void AddSlayerWeaponOnHit(object oPC)
{
    int iSlayerLvl = GetLevelByClass(CLASS_TYPE_SHIFTER, oPC);
    if(iSlayerLvl < 11) // sanity check
        return;
    object oRightHandWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if(!IPGetIsMeleeWeapon(oRightHandWeapon))
        return;
    object oLeftHandWeapon  = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    object oGloves = GetItemInSlot(INVENTORY_SLOT_ARMS);
    if (iSlayerLvl >= 11) // add Open wounds
    {
        if (GetIsObjectValid(oRightHandWeapon) && IPGetIsMeleeWeapon(oRightHandWeapon))
            IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_OPEN_WOUNDS, iSlayerLvl),
                                                    DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oLeftHandWeapon)  && IPGetIsMeleeWeapon(oLeftHandWeapon))
            IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_OPEN_WOUNDS, iSlayerLvl),
                                                   DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oGloves) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
            IPSafeAddItemProperty(oGloves, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_OPEN_WOUNDS, iSlayerLvl),
                                           DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
    if (iSlayerLvl >= 20) // add Last hit
    {
        if (GetIsObjectValid(oRightHandWeapon) && IPGetIsMeleeWeapon(oRightHandWeapon))
            IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_LAST_HIT, iSlayerLvl),
                                                    DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oLeftHandWeapon)  && IPGetIsMeleeWeapon(oLeftHandWeapon))
            IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_LAST_HIT, iSlayerLvl),
                                                   DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oGloves) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
            IPSafeAddItemProperty(oGloves, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_LAST_HIT, iSlayerLvl),
                                           DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
    if(GetHasFeat(FEAT_PAINFUL_HIT, oPC))
    {
        if (GetIsObjectValid(oRightHandWeapon) && IPGetIsMeleeWeapon(oRightHandWeapon))
            IPSafeAddItemProperty(oRightHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_PAINFUL_HIT, iSlayerLvl),
                                                    DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oLeftHandWeapon)  && IPGetIsMeleeWeapon(oLeftHandWeapon))
            IPSafeAddItemProperty(oLeftHandWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_PAINFUL_HIT, iSlayerLvl),
                                                   DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        if (GetIsObjectValid(oGloves) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
            IPSafeAddItemProperty(oGloves, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_PAINFUL_HIT, iSlayerLvl),
                                           DURATION_SERVER_SESSION, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
    }
}

void psv_AdjustCustomSaves(object oPC)
{
    // sanity check
    if(!GetHasFeat(FEAT_WILD_FORTITUDE, oPC) && !GetHasFeat(FEAT_DIVINE_SAVES, oPC))
        return;
    // get current true fortutude value
    int nTrueBaseFort = NWNX_Creature_GetBaseSavingThrow(oPC, SAVING_THROW_FORT) -   GetSkinInt(oPC, "WILD_FORT_SHIFT") - GetSkinInt(oPC, "DIVINE_SAVES_SHIFT");
    int nTrueBaseRefl = NWNX_Creature_GetBaseSavingThrow(oPC, SAVING_THROW_REFLEX) - GetSkinInt(oPC, "DIVINE_SAVES_SHIFT");
    int nTrueBaseWill = NWNX_Creature_GetBaseSavingThrow(oPC, SAVING_THROW_WILL) -   GetSkinInt(oPC, "DIVINE_SAVES_SHIFT");
    // handle wild fortitude
    int nWildFortShift = 0;
    if(GetHasFeat(FEAT_WILD_FORTITUDE, oPC))
    {
        // calc max class
        json jWildClasses = JsonArray();
        JsonArrayInsertInplace(jWildClasses, JsonInt(GetLevelByClass(CLASS_TYPE_BARBARIAN)));
        JsonArrayInsertInplace(jWildClasses, JsonInt(GetLevelByClass(CLASS_TYPE_BLACKGUARD)));
        JsonArrayInsertInplace(jWildClasses, JsonInt(GetLevelByClass(CLASS_TYPE_SHIFTER)));
        json jClassesSorted = JsonArrayTransform(jWildClasses, JSON_ARRAY_SORT_DESCENDING);
        int nMaxClassLevel = JsonGetInt(JsonArrayGet(jClassesSorted, 0));
        // calc new shift
        nWildFortShift = nMaxClassLevel / 10;
        nWildFortShift = nWildFortShift > 0 ?  nWildFortShift : 0;
        SetSkinInt(oPC, "WILD_FORT_SHIFT", nWildFortShift);
    }
    // handle divine saves
    int nDivineSavesShift = 0;
    if(GetHasFeat(FEAT_DIVINE_SAVES, oPC))
    {
        // calc max class
        json jDivineClasses = JsonArray();
        JsonArrayInsertInplace(jDivineClasses, JsonInt(GetLevelByClass(CLASS_TYPE_BARD)));
        JsonArrayInsertInplace(jDivineClasses, JsonInt(GetLevelByClass(CLASS_TYPE_CLERIC)));
        JsonArrayInsertInplace(jDivineClasses, JsonInt(GetLevelByClass(CLASS_TYPE_PALADIN)));
        json jClassesSorted = JsonArrayTransform(jDivineClasses, JSON_ARRAY_SORT_DESCENDING);
        int nMaxClassLevel = JsonGetInt(JsonArrayGet(jClassesSorted, 0));
        int nChaMod = GetAbilityModifier(ABILITY_CHARISMA, oPC);
        nDivineSavesShift = nMaxClassLevel > nChaMod ? nChaMod : nMaxClassLevel;
        nDivineSavesShift = nDivineSavesShift > 0 ? nDivineSavesShift : 0;
        if(GetAbilityModifier(ABILITY_WISDOM, oPC) >= nChaMod)
            nDivineSavesShift /= 2;
        SetSkinInt(oPC, "DIVINE_SAVES_SHIFT", nDivineSavesShift);
    }
    NWNX_Creature_SetBaseSavingThrow(oPC, SAVING_THROW_FORT, nTrueBaseFort + nWildFortShift + nDivineSavesShift);
    NWNX_Creature_SetBaseSavingThrow(oPC, SAVING_THROW_REFLEX, nTrueBaseRefl + nDivineSavesShift);
    NWNX_Creature_SetBaseSavingThrow(oPC, SAVING_THROW_WILL, nTrueBaseWill + nDivineSavesShift);
}

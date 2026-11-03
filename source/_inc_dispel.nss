///////////////////////////////////////////////////////////////////
////////// _inc_dispel 1.23.417 by ud4ever               //////////
////////// Custom dispel system based on Cormyr, ND and  //////////
////////// Validor ideas. This system uses spell sqlite  //////////
////////// arrays from _inc_array that modify when apply //////////
////////// or remove effect from target                  //////////
///////////////////////////////////////////////////////////////////

#include "_inc_players"
#include "nw_i0_spells"
#include "_inc_spells"
#include "_inc_array"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// returns TRUE if HostileSetting culumn in spells.2da = 1
int dispel_IsHostileSpell(int iSpell);

// get spell's difficulty class
int dispel_GetDcVsDispel(int iSpellID, object oTarget);

// set spell's difficulty class
void dispel_SetDcVsDispel(int iDC, int iSpellID, object oTarget);

// delete spell's difficulty class
void dispel_DeleteDcVsDispel(int iSpellID, object oTarget);

// calculates spell's Defence DC vs Dispel based on caster level/fameshop/class abilities
int dispel_CalculateDcVsDispel(object oCaster);

// calculates Attack Roll vs Defence DC based on caster level/fameshop/class abilities
int dispel_CalculateDispelAttackRoll(object oDispeller, int iSpellID);

// check if this spell can not be dispelled
int dispel_GetIsExceptionSpell(object oCaster, int SpellId);

// add info about spell in sqlite array on spell target and set local integer with spell DC
void dispel_AddSpellDataOnTarget(object oCaster, object oSpellTarget, int iSpellID);

// clear all data that sets in dispel_AddSpellDataOnTarget
void dispel_ClearSpellDataOnTarget(object oSpellTarget, int iSpellID);

// clear expired spells in spell array on oSpellTarget and return number of valid spells
int dispel_GetActualizedSpellData(object oSpellTarget);

// returns dispel check count for dispel type
int dispel_GetDispelChecks(object oDispeller, int iSpellID);

// applies dispel
void dispel_DispelTarget(object oDispeller, object oSpellTarget, int iSpellID, int DispelAOE = FALSE);

// applies in addition to dispel_DispelTarget if player uses dispel at location
void dispel_DispelAOETarget(location lLoc, int iCurrentSpell);

// get best protection for spell breach
int dispel_GetBestProtection(int iLastChecked, int iSwitch = 0);

// applies spell breach
void dispel_BreachTarget(object oCaster, object oTarget, int iSpellID);

///////////////////// Fameshop additions //////////////////////////


// get fameshop defence bonus for player's account
int dispel_GetFameshopDefenceBonusVsDispel(string sAccount);

// set fameshop defence bonus for player's account
void dispel_SetFameshopDefenceBonusVsDispel(string sAccount, int iBonusDC);

// get fameshop bonus dispel checks for nDispelType
int dispel_GetFameshopBonusChecksForDispelType(string sAccount, int nDispelType);

// get fameshop bonus to attack roll DC for nDispelType
int dispel_GetFameshopBonusToDispelAttackRoll(string sAccount, int iDispelType);


///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

const int NW_I0_SPELLS_MAX_BRCH = 12;
const string SPELL_ARRAY_TAG = "SPELL_ARRAY_TAG";
const string SPELL_TEMP_ARRAY_TAG = "SPELL_TEMP_ARRAY_TAG";


int dispel_IsHostileSpell(int iSpell)
{
    return StringToInt(Get2DAString("spells", "HostileSetting", iSpell));
}

int dispel_GetDcVsDispel(int iSpellID, object oTarget)
{
    return GetLocalInt(oTarget, "SPELL_DC_" + IntToString(iSpellID));
}

void dispel_SetDcVsDispel(int iDC, int iSpellID, object oTarget)
{
    SetLocalInt(oTarget, "SPELL_DC_" + IntToString(iSpellID), iDC);
}

void dispel_DeleteDcVsDispel(int iSpellID, object oTarget)
{
    DeleteLocalInt(oTarget, "SPELL_DC_" + IntToString(iSpellID));
}

int dispel_CalculateDcVsDispel(object oCaster)
{
    int iDC                             = 0;
    int bSpellCastItem                  = GetIsObjectValid(GetLocalObject(oCaster, "SPELLCAST_ITEM"));

    // if spellbook cast
    if (!bSpellCastItem)
    {
        int iDefenceDcCashed            = GetLocalInt(oCaster, "DEFENCE_DC_CASHED");
        // if cash is empty then calculate spell DC
        if (!iDefenceDcCashed)
        {
            int iArcaneDefense          = 0;
            int iBuildBonus             = 0;

            int iCasterLevel            = GetLocalInt(oCaster, "LAST_CASTER_LEVEL");
            int iLastSpellClass         = GetLocalInt(oCaster, "LAST_CASTER_SPELL_CLASS");

            string sAccount             = GetPCPlayerName(oCaster);
            int iFameShopDefenceBonus   = GetIsPC(oCaster) ? dispel_GetFameshopDefenceBonusVsDispel(sAccount) : 0;

            if (iLastSpellClass == CLASS_TYPE_CLERIC || iLastSpellClass == CLASS_TYPE_PALADIN ||
                iLastSpellClass == CLASS_TYPE_BARD   || iLastSpellClass == CLASS_TYPE_RANGER)
            {
                iBuildBonus += GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oCaster);
            }

            if (iLastSpellClass == CLASS_TYPE_CLERIC || iLastSpellClass == CLASS_TYPE_SORCERER ||
                iLastSpellClass == CLASS_TYPE_BARD   || iLastSpellClass == CLASS_TYPE_DRUID)
            {
                iCasterLevel += GetLevelByClass(CLASS_TYPE_ARCHMAGE, oCaster);
            }

            if(iLastSpellClass == CLASS_TYPE_PALADIN || iLastSpellClass == CLASS_TYPE_RANGER)
                iArcaneDefense = 6;
            else if (GetHasFeat(FEAT_ARCANE_DEFENSE_ABJURATION, oCaster))
                iArcaneDefense = 4;

            iDC = 14 + iCasterLevel + iBuildBonus + iArcaneDefense + iFameShopDefenceBonus;
            SetLocalInt(oCaster, "DEFENCE_DC_CASHED", iDC);
        }
        // else use cashed value
        else iDC = iDefenceDcCashed;
    }
    // calculate and cash as local defence DC vs dispel
    else
    {
        // check if cashed value is exists
        int iDefenceDcCashedFromItem    = GetLocalInt(oCaster, "DEFENCE_DC_CASHED_FROM_ITEM");
        // if no cash then cash it!
        if (!iDefenceDcCashedFromItem)
        {
            string sAccount             = GetPCPlayerName(oCaster);
            int iFameShopDefenceBonus   = GetIsPC(oCaster) ? dispel_GetFameshopDefenceBonusVsDispel(sAccount) : 0;
            iDC                         = 14 + GetHitDice(oCaster) / 2 + iFameShopDefenceBonus;
            SetLocalInt(oCaster, "DEFENCE_DC_CASHED_FROM_ITEM", iDC);
        }
        else
            iDC = iDefenceDcCashedFromItem;
    }

    return iDC;
}

int dispel_CalculateDispelAttackRoll(object oDispeller, int iSpellID)
{
    int iRoll                           = 0;
    string sCashedSpell                 = IntToString(iSpellID);
    object oSpellCastItem               = GetSpellCastItem();
    int bSpellCastItem                  = GetIsObjectValid(oSpellCastItem);

    if (!bSpellCastItem)
    {
        int iAttackRollCashed           = GetLocalInt(oDispeller, "ATTACK_ROLL_CASHED_FOR_SPELL_" + sCashedSpell);
        if (!iAttackRollCashed)
        {
            int iSpellFocus             = 0;

            int iCasterLevel            = GetLocalInt(oDispeller, "LAST_CASTER_LEVEL");
            int iLastSpellClass         = GetLocalInt(oDispeller, "LAST_CASTER_SPELL_CLASS");

            string sAccount             = GetPCPlayerName(oDispeller);
            int iFameShopAttackBonus    = GetIsPC(oDispeller) ? dispel_GetFameshopBonusToDispelAttackRoll(sAccount, iSpellID) : 0;

            if(GetHasFeat(FEAT_SPELL_FOCUS_ABJURATION, oDispeller))         iSpellFocus     = 1;
            if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ABJURATION, oDispeller)) iSpellFocus     = 3;
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ABJURATION, oDispeller))    iSpellFocus     = 6;

            if (iLastSpellClass == CLASS_TYPE_CLERIC || iLastSpellClass == CLASS_TYPE_SORCERER ||
                iLastSpellClass == CLASS_TYPE_BARD   || iLastSpellClass == CLASS_TYPE_DRUID)
            {
                iCasterLevel += GetLevelByClass(CLASS_TYPE_ARCHMAGE, oDispeller);
            }

            int iPerformanceBonus = 0;
            // bard perform bonus
            if(GetSkillRank(SKILL_PERFORM, oDispeller) >= 110)
                iPerformanceBonus = 3;

            iRoll = iCasterLevel + iSpellFocus + iPerformanceBonus + iFameShopAttackBonus;
            SetLocalInt(oDispeller, "ATTACK_ROLL_CASHED_FOR_SPELL_" + sCashedSpell, iRoll);
        }
        else
            iRoll = iAttackRollCashed;
    }
    else
    {
        int iAttackRollCashedFromItem = GetLocalInt(oDispeller, "ATTACK_ROLL_CASHED_FROM_ITEM_FOR_SPELL_" + sCashedSpell);
        if (!iAttackRollCashedFromItem)
        {
            if (iSpellID == SPELL_BESTOW_CURSE)
            {
                iRoll                       = GetLocalInt(oSpellCastItem, "ITEM_DISPEL_ATTACK");
            }
            else
            {
                string sAccount             = GetPCPlayerName(oDispeller);
                int iFameShopAttackBonus    = GetIsPC(oDispeller) ? dispel_GetFameshopBonusToDispelAttackRoll(sAccount, iSpellID) : 0;
                iRoll                       = 5 + GetHitDice(oDispeller) / 2 + iFameShopAttackBonus;
            }
            SetLocalInt(oDispeller, "ATTACK_ROLL_CASHED_FROM_ITEM_FOR_SPELL_" + sCashedSpell, iRoll);
        }
        else
            iRoll = iAttackRollCashedFromItem;
    }
    return iRoll;
}


int dispel_GetIsExceptionSpell(object oCaster, int SpellId)
{
    if (dispel_IsHostileSpell(SpellId) == TRUE                      ||
        SpellId == 669 /*chaos shield*/                             ||
        SpellId == SPELL_LIGHT                                      ||
        SpellId == SPELL_MAGIC_VESTMENT                             ||
        SpellId == SPELL_MIND_FOG                                   ||
        SpellId == SPELL_MAGIC_WEAPON                               ||
        SpellId == SPELL_GREATER_MAGIC_WEAPON                       ||
        SpellId == SPELL_KEEN_EDGE                                  ||
        SpellId == SPELL_DARKFIRE                                   ||
        SpellId == SPELL_CONTINUAL_FLAME                            ||
        SpellId == 792 /*freeze*/                                   ||
        SpellId == 198 /*Aura_Fear*/                                ||
        SpellId == 412 /*Aura_Fear_Dragon*/                         ||
        SpellId == SPELL_HOLY_SWORD                                 ||
        SpellId == SPELL_DEAFENING_CLANG                            ||
        SpellId == SPELL_DARKVISION                                 ||

        // summons can be dispelled dispelling summon as a target
        SpellId == SPELL_ELEMENTAL_SUMMONING_ITEM                   ||
        SpellId == SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW   ||
        SpellId == SPELL_PALADIN_SUMMON_MOUNT                       ||
        SpellId == SPELL_SHADES_SUMMON_SHADOW                       ||
        SpellId == SPELL_SHADOW_CONJURATION_SUMMON_SHADOW           ||
        SpellId == SPELL_SUMMON_SHADOW                              ||
        SpellId == SPELL_CREATE_GREATER_UNDEAD                      ||
        SpellId == SPELL_CREATE_UNDEAD                              ||

        SpellId == SPELL_SUMMON_CREATURE_I                          ||
        SpellId == SPELL_SUMMON_CREATURE_II                         ||
        SpellId == SPELL_SUMMON_CREATURE_III                        ||
        SpellId == SPELL_SUMMON_CREATURE_IV                         ||
        SpellId == SPELL_SUMMON_CREATURE_V                          ||
        SpellId == SPELL_SUMMON_CREATURE_VI                         ||
        SpellId == SPELL_SUMMON_CREATURE_VII                        ||
        SpellId == SPELL_SUMMON_CREATURE_VIII                       ||
        SpellId == SPELL_SUMMON_CREATURE_IX                         ||

        // spellike abilities
        SpellId == SPELLABILITY_BARBARIAN_RAGE                      ||
        SpellId == SPELLABILITY_BATTLE_MASTERY                      ||
        SpellId == SPELLABILITY_BG_BULLS_STRENGTH                   ||
        SpellId == SPELLABILITY_BG_CONTAGION                        ||
        SpellId == SPELLABILITY_BG_CREATEDEAD                       ||
        SpellId == SPELLABILITY_BG_FIENDISH_SERVANT                 ||
        SpellId == SPELLABILITY_BG_FIENDISH_SERVANT                 ||
        SpellId == SPELLABILITY_DC_DIVINE_WRATH                     ||
        SpellId == SPELLABILITY_DETECT_EVIL                         ||
        SpellId == SPELLABILITY_DIVINE_PROTECTION                   ||
        SpellId == SPELLABILITY_DIVINE_STRENGTH                     ||
        SpellId == SPELLABILITY_DIVINE_TRICKERY                     ||
        SpellId == SPELLABILITY_NEGATIVE_PLANE_AVATAR               ||

        SpellId == SPELLABILITY_PM_ANIMATE_DEAD                     ||
        SpellId == SPELLABILITY_PM_SUMMON_GREATER_UNDEAD            ||
        SpellId == SPELLABILITY_PM_SUMMON_UNDEAD                    ||

        SpellId == SPELLABILITY_SUMMON_ANIMAL_COMPANION             ||
        SpellId == SPELLABILITY_SUMMON_CELESTIAL                    ||
        SpellId == SPELLABILITY_SUMMON_FAMILIAR                     ||
        SpellId == SPELLABILITY_SUMMON_MEPHIT                       ||
        SpellId == SPELLABILITY_SUMMON_SLAAD                        ||
        SpellId == SPELLABILITY_SUMMON_TANARRI                      ||
        SpellId == 810 /* PDK Final Stand */                        ||
        SpellId == SPELL_DIVINE_FAVOR &&
        GetResRef(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCaster))
        == CONST_FAME_LONGSWORD                                     ||
        SpellId == SPELL_BLADE_THIRST)

        return TRUE;
    return FALSE;
}

void dispel_AddSpellDataOnTarget(object oCaster, object oSpellTarget, int iSpellID)
{
    if(!Array_Contains_Int(SPELL_ARRAY_TAG, iSpellID, oSpellTarget))
    {
        if(!dispel_GetIsExceptionSpell(oCaster, iSpellID))
        {
            int iCustomBonusDC = GetLocalInt(oCaster, "ADD_BONUS_DC_VS_DISPEL_" + IntToString(iSpellID));
            DelayCommand(3.0, DeleteLocalInt(oCaster, "ADD_BONUS_DC_VS_DISPEL_" + IntToString(iSpellID)));

            int iOverrideDC = GetLocalInt(oCaster, "OVERRIDE_DC_VS_DISPEL_" + IntToString(iSpellID));
            DelayCommand(3.0, DeleteLocalInt(oCaster, "OVERRIDE_DC_VS_DISPEL_" + IntToString(iSpellID)));

            dispel_SetDcVsDispel(dispel_CalculateDcVsDispel(oCaster) + iCustomBonusDC, iSpellID, oSpellTarget);
            if (iOverrideDC > 0)
                dispel_SetDcVsDispel(iOverrideDC, iSpellID, oSpellTarget);

            Array_PushBack_Int(SPELL_ARRAY_TAG, iSpellID, oSpellTarget);
        }
    }
}

void dispel_ClearSpellDataOnTarget(object oSpellTarget, int iSpellID)
{
    int iSpellIndex = Array_Find_Int(SPELL_ARRAY_TAG, iSpellID, oSpellTarget);

    if(iSpellIndex != INVALID_INDEX)
    {
        dispel_DeleteDcVsDispel(iSpellID, oSpellTarget);
        Array_Erase(SPELL_ARRAY_TAG, iSpellIndex, oSpellTarget);
    }
}

int dispel_GetActualizedSpellData(object oSpellTarget)
{
    int i;
    int iSpellCount = 0;
    int ArraySize = Array_Size(SPELL_ARRAY_TAG, oSpellTarget);

    // array copy with tag SPELL_TEMP_ARRAY_TAG for correct detection spell ID
    // because if we delete any value from array it shuffles
    // TODO check if it so in sqlite version (shuffled in nwnx_data implementation)
    Array_Copy(SPELL_ARRAY_TAG, SPELL_TEMP_ARRAY_TAG, oSpellTarget);

    for (i = 0; i <= ArraySize - 1; i++)
    {
        int iSpellID = Array_At_Int(SPELL_TEMP_ARRAY_TAG, i, oSpellTarget);
        if (GetHasSpellEffect(iSpellID, oSpellTarget) || iSpellID == SPELL_ALL_SUMMONED_CREATURES) iSpellCount++;
        else dispel_ClearSpellDataOnTarget(oSpellTarget, iSpellID);
    }
    // clear temp array
    Array_Clear(SPELL_TEMP_ARRAY_TAG, oSpellTarget);

    return iSpellCount;
}

int dispel_GetDispelChecks(object oDispeller, int iSpellID)
{
    string sAccount = GetPCPlayerName(oDispeller);
    string sSpellID = IntToString(iSpellID);
    int iDispelChecks = 0;
    int iDispelChecksCashed = GetLocalInt(oDispeller, "DISPEL_CHECKS_CASHED_FOR_SPELL_" + sSpellID);

    if (!iDispelChecksCashed)
    {
        switch (iSpellID)
        {
            case SPELL_LESSER_DISPEL:
                iDispelChecks = 1 + (GetIsPC(oDispeller) ? dispel_GetFameshopBonusChecksForDispelType(sAccount, SPELL_LESSER_DISPEL) : 2);
            break;
            case SPELL_DISPEL_MAGIC:
                iDispelChecks = 2 + (GetIsPC(oDispeller) ? dispel_GetFameshopBonusChecksForDispelType(sAccount, SPELL_DISPEL_MAGIC) : 2);
            break;
            case SPELL_GREATER_DISPELLING:
                iDispelChecks = 3 + (GetIsPC(oDispeller) ? dispel_GetFameshopBonusChecksForDispelType(sAccount, SPELL_GREATER_DISPELLING) : 3);
            break;
            case SPELL_MORDENKAINENS_DISJUNCTION:
                iDispelChecks = 5 + (GetIsPC(oDispeller) ? dispel_GetFameshopBonusChecksForDispelType(sAccount, SPELL_MORDENKAINENS_DISJUNCTION) : 4);
            break;
         }
         SetLocalInt(oDispeller, "DISPEL_CHECKS_CASHED_FOR_SPELL_" + sSpellID, iDispelChecks);
    }
    else iDispelChecks = iDispelChecksCashed;

    return iDispelChecks;
}

void dispel_DispelTarget(object oDispeller, object oSpellTarget, int iSpellID, int DispelAOE = FALSE)
{
    // actualize data and get count of buff on spell target
    int iSpellCount = dispel_GetActualizedSpellData(oSpellTarget);

     // can't cast dispel under TimeStop effect
    if (GetLocalInt(GetArea(oDispeller), "TIMESTOP_IN_AREA"))
    {
        FloatingColorTextStringOnCreature("You can`t cast Dispel or Breach during TimeStop.", TXT_COLOR_RED, oDispeller);
        return;
    }
     // if oTarget has variable IMMUNE_TO_DISPEL, dispel can't be done
    if (GetLocalInt(oSpellTarget, "IMMUNE_TO_DISPEL"))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DISPEL), oSpellTarget);
        DelayCommand(1.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE), oSpellTarget));
        return;
    }

    // declare spellcast event
    if(GetLocalInt(oSpellTarget, "IMGUARD") && !GetIsEnemy(oSpellTarget, oDispeller))
        SignalEvent(oSpellTarget, EventSpellCastAt(oDispeller, iSpellID, FALSE));
    else
        SignalEvent(oSpellTarget, EventSpellCastAt(oDispeller, iSpellID, TRUE));

    int iCheckNumber = 0;
    int iSRDecrease = 0;
    string sDispelName = "";

    switch (iSpellID)
    {
        case SPELL_LESSER_DISPEL:
            iCheckNumber = dispel_GetDispelChecks(oDispeller, iSpellID)/(1 + DispelAOE);
            sDispelName = "Lesser Dispel";
            iSRDecrease  =  3;
        break;
        case SPELL_DISPEL_MAGIC:
            iCheckNumber = dispel_GetDispelChecks(oDispeller, iSpellID)/(1 + DispelAOE);
            sDispelName = "Dispel Magic";
            iSRDecrease  =  5;
        break;
        case SPELL_GREATER_DISPELLING:
            iCheckNumber = dispel_GetDispelChecks(oDispeller, iSpellID)/(1 + DispelAOE);
            sDispelName = "Greater Dispel";
            iSRDecrease  =  8;
        break;
        case SPELL_MORDENKAINENS_DISJUNCTION:
            iCheckNumber = dispel_GetDispelChecks(oDispeller, iSpellID)/(1 + DispelAOE);
            sDispelName = "Mordenkainens Disjunction";
            iSRDecrease  =  10;
        break;
        case SPELL_BESTOW_CURSE:
            iCheckNumber = GetLocalInt(GetSpellCastItem(), "DEAF_CLANG_SPELLS_NUMBER_FOR_DISPEL") +
                          (GetBaseItemType(GetSpellCastItem()) == BASE_ITEM_LONGSWORD); // longsword bonus
            sDispelName = "Deafening Clang";
            // SendMessageToPC(oDispeller, IntToString(iCheckNumber));
        break;
    }

    /////////=================Determine Visual Effect of Dispel==============/////////////
    effect eEfx;
    if      (iSpellID == SPELL_LESSER_DISPEL)             eEfx = EffectVisualEffect(VFX_IMP_DISPEL);
    else if (iSpellID == SPELL_DISPEL_MAGIC)              eEfx = EffectVisualEffect(GAOVFX_IMP_DISPEL_BLUE);
    else if (iSpellID == SPELL_GREATER_DISPELLING)        eEfx = EffectVisualEffect(GAOVFX_IMP_DISPEL_GREEN);
    else if (iSpellID == SPELL_MORDENKAINENS_DISJUNCTION) eEfx = EffectVisualEffect(GAOVFX_IMP_DISPEL_PURPLE);
    else eEfx = EffectVisualEffect(VFX_IMP_DISPEL);
    /////////================================================================/////////////


    ApplyEffectToObject(DURATION_TYPE_INSTANT, eEfx, oSpellTarget);
    // decrease SR
    if (iSRDecrease)
    {
        effect eSRDecrease = SupernaturalEffect(EffectSpellResistanceDecrease(iSRDecrease));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSRDecrease, oSpellTarget, RoundsToSeconds(iSRDecrease));
    }

    if (iSpellCount == 0)
    {
        SendColorMessageToPC(oDispeller, "There is nothing to dispel", TXT_COLOR_RED);
        return;
    }


    int iCasterIsPlayer = GetIsPC(oDispeller);
    int iTargetIsPlayer = GetIsPC(oSpellTarget);

    string sMessageAttacker = "";
    string sMessageDefencer = "";

    if (iCasterIsPlayer) sMessageAttacker = ColorText(sDispelName + " : ", TXT_COLOR_VIOLET_L) +
        ColorText(GetName(oSpellTarget), TXT_COLOR_VIOLET_SL) + " : \n";
    if (iTargetIsPlayer) sMessageDefencer = ColorText(GetName(oDispeller), TXT_COLOR_VIOLET_SL) +
        ColorText(" attempted a " + sDispelName + " : ", TXT_COLOR_VIOLET_L) + ColorText(GetName(oSpellTarget), TXT_COLOR_BLUE_L) + " : \n" ;

    int iRandomSpell = 0;
    int i;
    int iDice;

    int iDefenseDC = 0;
    int iAttackDC  = dispel_CalculateDispelAttackRoll(oDispeller, iSpellID);

    if (iSpellCount < iCheckNumber) iCheckNumber = iSpellCount; // if buffs_count < dispel_checks then dispel_checks = buffs_count

    Array_Shuffle(SPELL_ARRAY_TAG, oSpellTarget);
    Array_Copy(SPELL_ARRAY_TAG, SPELL_TEMP_ARRAY_TAG, oSpellTarget);

    for (i = 0; i <= iCheckNumber - 1; i++)
    {
        int iRandomSpell = Array_At_Int(SPELL_TEMP_ARRAY_TAG, i, oSpellTarget);

        iDefenseDC = dispel_GetDcVsDispel(iRandomSpell, oSpellTarget);
        iDice = d20();
        if (iDice + iAttackDC >= iDefenseDC && iDice != 1 || iDice == 20)
        {
            if  (iRandomSpell == SPELL_ALL_SUMMONED_CREATURES)
            {
                object oMaster = GetMaster(oSpellTarget);
                effect eVisual = EffectVisualEffect(VFX_IMP_UNSUMMON);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oSpellTarget);
                DestroyObject(oSpellTarget, 0.5);
            }
            if (iCasterIsPlayer) sMessageAttacker += ColorText(GetSpellNameFromID(iRandomSpell), TXT_COLOR_VIOLET_L) + " : " +
                ColorText("*dispelled*", TXT_COLOR_GREEN_L) + ColorText(" : (" + IntToString(iDice) + " + " +
                IntToString(iAttackDC) + " = " + IntToString(iDice + iAttackDC) +
                " vs. DC: " + IntToString(iDefenseDC) + ") \n", TXT_COLOR_VIOLET_L);

            if (iTargetIsPlayer) sMessageDefencer += ColorText(GetSpellNameFromID(iRandomSpell), TXT_COLOR_VIOLET_L) + " : " +
                ColorText("*dispelled*", TXT_COLOR_GREEN_L) + ColorText(" : (" + IntToString(iDice) + " + " +
                IntToString(iAttackDC) + " = " + IntToString(iDice + iAttackDC) +
                " vs. DC: " + IntToString(iDefenseDC) + ") \n", TXT_COLOR_VIOLET_L);

            RemoveEffectsFromSpell(oSpellTarget, iRandomSpell);
        }
        else if (iDice + iAttackDC < iDefenseDC || iDice == 1)
        {
            if (iCasterIsPlayer) sMessageAttacker += ColorText(GetSpellNameFromID(iRandomSpell), TXT_COLOR_VIOLET_L) + " : " +
                ColorText("*not dispelled*", TXT_COLOR_RED) + ColorText(" : (" + IntToString(iDice) + " + " +
                IntToString(iAttackDC) + " = " + IntToString(iDice + iAttackDC) +
                " vs. DC: " + IntToString(iDefenseDC) + ") \n", TXT_COLOR_VIOLET_L);

                if (iTargetIsPlayer) sMessageDefencer += ColorText(GetSpellNameFromID(iRandomSpell), TXT_COLOR_VIOLET_L) + " : " +
                    ColorText("*not dispelled*", TXT_COLOR_RED) + ColorText(" : (" + IntToString(iDice) + " + " +
                    IntToString(iAttackDC) + " = " + IntToString(iDice + iAttackDC) +
                    " vs. DC: " + IntToString(iDefenseDC) + ") \n", TXT_COLOR_VIOLET_L);
        }
    }
    // clear spell array
    Array_Clear(SPELL_TEMP_ARRAY_TAG, oSpellTarget);

    if (iTargetIsPlayer && oSpellTarget != oDispeller) SendMessageToPC(oSpellTarget, sMessageDefencer);
    SendMessageToPC(oDispeller, sMessageAttacker);
}

void dispel_DispelAOETarget(location lLoc, int iCurrentSpell)
{
    ////////=================Prerequisites for Script Work=====================//////////

     //Can`t cast dispel under TimeStop
    if (GetLocalInt(GetArea(OBJECT_SELF), "TIMESTOP_IN_AREA"))
    {
        FloatingColorTextStringOnCreature("You can`t cast Dispel or Breach during TimeStop.", TXT_COLOR_RED, OBJECT_SELF);
        return;
    }

    /////=============Determine And Apply Spell Animation Based on Spell Type============////////
    effect eEfx;
    if      (iCurrentSpell == SPELL_LESSER_DISPEL)             eEfx = EffectVisualEffect(VFX_FNF_DISPEL);
    else if (iCurrentSpell == SPELL_DISPEL_MAGIC)              eEfx = EffectVisualEffect(VFX_FNF_DISPEL);
    else if (iCurrentSpell == SPELL_GREATER_DISPELLING)        eEfx = EffectVisualEffect(VFX_FNF_DISPEL_GREATER);
    else if (iCurrentSpell == SPELL_MORDENKAINENS_DISJUNCTION) eEfx = EffectVisualEffect(VFX_FNF_DISPEL_DISJUNCTION);
    else eEfx = EffectVisualEffect(VFX_IMP_DISPEL);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEfx, lLoc);
    //////////////////////////////////////////////////////////////////////////////////////////////
    ////////////==============================Apply Dispel============================///////////////

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lLoc, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE );
    while (GetIsObjectValid(oTarget))
    {
        //Fire Cast Spell at Event For The Specified Target
        if(GetLocalInt(oTarget, "IMGUARD") && !GetIsEnemy(oTarget, OBJECT_SELF))
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, iCurrentSpell, FALSE));
        else
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, iCurrentSpell, TRUE));
        //If Object is AoE
        if (GetObjectType(oTarget) == OBJECT_TYPE_AREA_OF_EFFECT && FindSubString(GetTag(oTarget), "VFX_PER") != -1)
        {
            //Determine Creator of AoE
            object oCreator = GetAreaOfEffectCreator(oTarget);
            //Declare variable
            int iChance;
            //Determine Dispell Type and Set iChance
            if      (iCurrentSpell == SPELL_LESSER_DISPEL)             iChance = 25;
            else if (iCurrentSpell == SPELL_DISPEL_MAGIC)              iChance = 50;
            else if (iCurrentSpell == SPELL_GREATER_DISPELLING)        iChance = 75;
            else if (iCurrentSpell == SPELL_MORDENKAINENS_DISJUNCTION) iChance = 100;

            //Determine Chance to Dispel AoE, Based on Caster Level of Creator AoE and Caster Level of Dispeler AoE
            //If Dispel Applied by Monster or NPC - increase iChance by 30
            if (!GetIsPC(OBJECT_SELF)) iChance += 30;
            //If AoE Was Created by Dispeler, AoE Will Be Dispeled in Any Way, Because iChance = 100
            if (OBJECT_SELF == oCreator) iChance = 100;
            if  (iChance > 100) iChance = 100;
            //If iChance Bigger then Random Number or Dispel Created by DM or by DM Possessed Object
            if (Random(100) < iChance  || GetIsDM(OBJECT_SELF) || GetIsDMPossessed(OBJECT_SELF))
            {
                FloatingColorTextStrRefOnCreature(100929, TXT_COLOR_GREEN_L, OBJECT_SELF);  // "AoE dispelled"
                //Destroy AoE
                DestroySpellMarkerPlacebles(GetLocation(oTarget), GetLocalInt(oTarget, "AOE_INDEX"), oCreator);
                DestroyObject(oTarget, 1.0);
            }
            else FloatingColorTextStrRefOnCreature(100930, TXT_COLOR_RED, OBJECT_SELF); // "AoE not dispelled"
        }
        else if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
        {
            dispel_DispelTarget(OBJECT_SELF, oTarget, iCurrentSpell, TRUE);
        }
        else if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE) SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, iCurrentSpell));
        //Get Next Object in Area We Need to Dispel
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lLoc, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE);
    }
}

int dispel_GetBestProtection(int iLastChecked, int iSwitch = 0)
{
    switch (iSwitch)
    {
        case 0:

        switch (iLastChecked)
        {
            case 1:  return SPELL_LESSER_SPELL_MANTLE;            break;
            case 2:  return SPELL_MINOR_GLOBE_OF_INVULNERABILITY; break;
            case 3:  return SPELL_GLOBE_OF_INVULNERABILITY;       break;
            case 4:  return SPELL_STONESKIN;                      break;
            case 5:  return SPELL_GREATER_STONESKIN;              break;
            case 6:  return SPELL_PREMONITION;                    break;
            case 7:  return SPELL_PROTECTION_FROM_ELEMENTS;       break;
            case 8:  return SPELL_GHOSTLY_VISAGE;                 break;
            case 9:  return SPELL_ETHEREAL_VISAGE;                break;
            case 10: return SPELL_MAGE_ARMOR;                     break;
            case 11: return SPELL_SHADOW_SHIELD;                  break;
            case 12: return SPELL_ELEMENTAL_SHIELD;               break;
        }
        break;

        case 1:

        switch (iLastChecked)
        {
            case 1:  return SPELL_SPELL_MANTLE;                   break;
            case 2:  return SPELL_MINOR_GLOBE_OF_INVULNERABILITY; break;
            case 3:  return SPELL_GLOBE_OF_INVULNERABILITY;       break;
            case 4:  return SPELL_STONESKIN;                      break;
            case 5:  return SPELL_GREATER_STONESKIN;              break;
            case 6:  return SPELL_PREMONITION;                    break;
            case 7:  return SPELL_PROTECTION_FROM_ELEMENTS;       break;
            case 8:  return SPELL_GHOSTLY_VISAGE;                 break;
            case 9:  return SPELL_ETHEREAL_VISAGE;                break;
            case 10: return SPELL_MAGE_ARMOR;                     break;
            case 11: return SPELL_SHADOW_SHIELD;                  break;
            case 12: return SPELL_ELEMENTAL_SHIELD;               break;
        }
        break;
    }

    return iLastChecked;
}

void dispel_BreachTarget(object oCaster, object oTarget, int iSpellID)
{
    int iMaxEffects;

    if (iSpellID == SPELL_GREATER_SPELL_BREACH)
        iMaxEffects = 4;
    else if (iSpellID == SPELL_LESSER_SPELL_BREACH)
        iMaxEffects = 2;
    else
        iMaxEffects = 2;

    //==================================Determine Visual Effect of Dispel=================================
    effect eEfx;
    if      (iSpellID == SPELL_GREATER_SPELL_BREACH)      eEfx = EffectVisualEffect(VFX_IMP_BREACH);
    else if (iSpellID == SPELL_LESSER_SPELL_BREACH)       eEfx = EffectVisualEffect(VFX_IMP_BREACH);
    else                                                  eEfx = EffectVisualEffect(VFX_IMP_BREACH);

    //==========================================Apply Breach==============================================


    if(GetLocalInt(oTarget, "IMGUARD") && !GetIsEnemy(oTarget, oCaster))
        SignalEvent(oTarget, EventSpellCastAt(oCaster, iSpellID, FALSE));
    else
        SignalEvent(oTarget, EventSpellCastAt(oCaster, iSpellID, TRUE));

    int iCasterIsPlayer = GetIsPC(oCaster);
    int iTargetIsPlayer = GetIsPC(oTarget);

    string sMessageAttacker = "";
    string sMessageDefencer = "";

    int iEffects = 0;

    if (iMaxEffects == 2)
    {
        int i = 0;
        while (i <= NW_I0_SPELLS_MAX_BRCH)
        {
            i++;
            iSpellID = dispel_GetBestProtection(i, 0);
            if (!GetHasSpellEffect(iSpellID, oTarget)) continue;
            if (iCasterIsPlayer) sMessageAttacker += ColorText(GetSpellNameFromID(iSpellID), TXT_COLOR_VIOLET_L) + " : " +
                ColorText("*breached*", TXT_COLOR_GREEN_L) + "\n";
            if (iTargetIsPlayer) sMessageDefencer += ColorText(GetSpellNameFromID(iSpellID), TXT_COLOR_VIOLET_L) + " : " +
                ColorText("*breached*", TXT_COLOR_GREEN_L) + " \n";

            iEffects++;
            RemoveEffectsFromSpell(oTarget, iSpellID);
            dispel_ClearSpellDataOnTarget(oTarget, iSpellID);

            if (iEffects >= iMaxEffects) break;
        }
        if (iEffects == 0)
        {
            sMessageAttacker = "";
            sMessageDefencer = "";
        }
    }
    else if (iMaxEffects == 4)
    {
        int i = 0;
        while (i <= NW_I0_SPELLS_MAX_BRCH)
        {
            i++;
            iSpellID = dispel_GetBestProtection(i, 1);
            if (!GetHasSpellEffect(iSpellID, oTarget)) continue;
            if (iCasterIsPlayer) sMessageAttacker += ColorText(GetSpellNameFromID(iSpellID), TXT_COLOR_VIOLET_L) + " : " +
                ColorText("*breached*", TXT_COLOR_GREEN_L) + "\n";
            if (iTargetIsPlayer) sMessageDefencer += ColorText(GetSpellNameFromID(iSpellID), TXT_COLOR_VIOLET_L) + " : " +
                ColorText("*breached*", TXT_COLOR_GREEN_L) + " \n";
            iEffects++;
            RemoveEffectsFromSpell(oTarget, iSpellID);
            dispel_ClearSpellDataOnTarget(oTarget, iSpellID);

            if (iEffects >= iMaxEffects) break;
        }
        if (iEffects == 0)
        {
            sMessageAttacker = "";
            sMessageDefencer = "";
        }
    }
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eEfx, oTarget);

    if (sMessageAttacker == "" && sMessageDefencer == "" && iCasterIsPlayer)
    {
        SendColorMessageToPC(oCaster, "Target has no spells to breach", TXT_COLOR_RED);
    }

    if (iTargetIsPlayer && oTarget != oCaster) SendMessageToPC(oTarget, sMessageDefencer);
        SendMessageToPC(oCaster, sMessageAttacker);
}

///////////////////// Fameshop additions //////////////////////////

int dispel_GetFameshopDefenceBonusVsDispel(string sAccount)
{
    if (sAccount == "") return 0;

    string sSQL = "SELECT dispel_defense FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);

    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    else
        return 0;
}

void dispel_SetFameshopDefenceBonusVsDispel(string sAccount, int iBonusDC)
{
    string sSQL = "UPDATE players SET dispel_defense = ? WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iBonusDC);
    NWNX_SQL_PreparedString(1, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
}

int dispel_GetFameshopBonusChecksForDispelType(string sAccount, int nDispelType)
{
    int result = 0;
    string sColumn;
    switch(nDispelType)
    {
        case SPELL_LESSER_DISPEL:
            sColumn = "dispel_1_num";
            break;
        case SPELL_DISPEL_MAGIC:
            sColumn = "dispel_3_num";
            break;
        case SPELL_GREATER_DISPELLING:
            sColumn = "dispel_6_num";
            break;
        case SPELL_MORDENKAINENS_DISJUNCTION:
            sColumn = "dispel_9_num";
            break;
        case SPELL_DEAFENING_CLANG:
            sColumn = "dispel_deafening_clang_num";
            break;
        default:
            return 0;
        break;
    }

    string sSQL = "SELECT " + sColumn + " FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);

    if(NWNX_SQL_ExecutePreparedQuery() && NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    else
        return 0;

    return result;
}

int dispel_GetFameshopBonusToDispelAttackRoll(string sAccount, int iDispelType)
{
    int result = 0;
    string sColumn;
    switch(iDispelType)
    {
        case SPELL_DEAFENING_CLANG:
            sColumn = "dispel_deafening_clang_dc";
        break;
        case SPELL_LESSER_DISPEL:
            sColumn = "dispel_1_dc";
        break;
        case SPELL_DISPEL_MAGIC:
            sColumn = "dispel_3_dc";
        break;
        case SPELL_GREATER_DISPELLING:
            sColumn = "dispel_6_dc";
        break;
        case SPELL_MORDENKAINENS_DISJUNCTION:
            sColumn = "dispel_9_dc";
        break;
        default:
            return 0;
        break;
    }

    string sSQL = "SELECT " + sColumn + " FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        return StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    else
        return 0;

    return result;
}

// void main() {}

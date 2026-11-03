#include "nwnx_events"
#include "_inc_psv_bonuses"
#include "_inc_generic"
#include "_inc_pulse_rage"
#include "x2_i0_spells"
#include "x3_inc_skin"

void main()
{
    object oPC   = OBJECT_SELF;
    object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));
    int iPlayerPCPersistentID = players_GetPCPersistentID(oPC);
    string sPlayerPCPersistentID = IntToString(iPlayerPCPersistentID);

    string sEvent = NWNX_Events_GetCurrentEvent();

    if (sEvent == NWNX_ON_ITEM_EQUIP_BEFORE)
    {
        int bAllow = TRUE;
        if (!generic_CheckFameItems(oPC, oItem))
        {
            FloatingColorTextStringOnCreature("You're not allowed to equip this item. Read requirements.",
                                              TXT_COLOR_RED, oPC, FALSE);
            bAllow = FALSE;
        }
        else if (GetHasSpellEffect(SPELL_CORMYR_DISARM, oPC) &&
            SQLite_GetTimeStamp() - GetLocalInt(oItem, "CORMYR_DISARM_TIMESTAMP") <= GetLocalInt(oItem, "CORMYR_DISARM_DURATION"))
        {
            FloatingColorTextStringOnCreature("You can't hold a weapon in your hand yet.",
                                              TXT_COLOR_RED, oPC, FALSE);
            bAllow = FALSE;
        }
        else if (GetIsPC(oPC) && GetLocalInt(GetModule(), "FIX_SWITCH_BUG_ON_PLAYER_ID_" + sPlayerPCPersistentID))
        {
            FloatingColorTextStringOnCreature("You cannot switch items too often during combat.", TXT_COLOR_RED, oPC, FALSE);
            AssignCommand(oPC, ClearAllActions());
            bAllow = FALSE;
        }

        if (!bAllow)
            NWNX_Events_SkipEvent();

    }
    if (sEvent == NWNX_ON_ITEM_EQUIP_AFTER)
    {
        if (!GetLocalInt(GetModule(), "FIX_SWITCH_BUG_ON_PLAYER_ID_" + sPlayerPCPersistentID) &&
            GetIsInCombat(oPC) && GetIsPC(oPC))
        {
            SetLocalInt(GetModule(), "FIX_SWITCH_BUG_ON_PLAYER_ID_" + sPlayerPCPersistentID, TRUE);
            AssignCommand(GetModule(), DelayCommand(6.0, DeleteLocalInt(GetModule(), "FIX_SWITCH_BUG_ON_PLAYER_ID_" + sPlayerPCPersistentID)));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectAttackDecrease(20), oPC, 3.0);
        }

        AddACAmbidex(oPC);
        SetArchmageAncientAC(oPC);
        DexDamage(oPC);
        psv_ApplyBonusCriticalRange(oPC);
        AddMonkBonuses(oPC);

        AddAssassinWeaponOnHit(oPC);
        AddRogueWeaponOnHit(oPC);
        AddSlayerWeaponOnHit(oPC);
        psv_AdjustCustomSaves(oPC);

        // dont darkfire to non clerics
        if(GetLevelByClass(CLASS_TYPE_CLERIC, oPC) < 4)
            IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_DAMAGE_BONUS,
                                                  DURATION_TYPE_TEMPORARY,
                                                  IP_CONST_DAMAGETYPE_FIRE);
        CheckShieldOnShifter(oPC);
        AddBgDamageBonus(oPC);
        UpdateEqippedInfo(oPC, oItem);
        psv_TumbleCompensation(oPC);
        // remove rage shield AC if shield is equipped
        if(MatchShield(oItem) || GetLevelByClass(CLASS_TYPE_MONK, oPC) > 2)
            RemoveEffectsFromSpell(oPC, SPELL_CORMYR_FEARLESS_RAGE_AC);
        // remove rage if not melee weapon
        object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
        if(GetIsObjectValid(oWeapon) && !GetMeleeWeapon(oWeapon))
            RemoveRageEffects(oPC);

        /* handle fameshop armor and weapon feats
        if(GetHasFeat(FEAT_WEP_PROF_GOVNOTRYAS, oPC))
        {
            object oRightHandWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
            if(GetIsObjectValid(oRightHandWeapon))
                SetSkinString(oPC, "UN_EQ_RIGHTHAND_FIX", GetObjectUUID(oRightHandWeapon));
            object oLeftHandWeapon  = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
            if(GetIsObjectValid(oLeftHandWeapon))
                SetSkinString(oPC, "UN_EQ_LEFTHAND_FIX", GetObjectUUID(oLeftHandWeapon));
        }
        if(GetHasFeat(FEAT_ARMOR_PROFICIENCY_HEAVY, oPC))
        {
            object oChest = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
            if(GetIsObjectValid(oChest))
                SetSkinString(oPC, "UN_EQ_CHEST_FIX", GetObjectUUID(oChest));
        } */

    }
}

#include "70_inc_switches"
#include "nwnx_weapon"
#include "nwnx_damage"
#include "nwnx_events"
#include "nwnx_elc"
#include "nwnx_feat"
#include "nwnx_feedback"
#include "_inc_loot_static"


//
void UpdateShaderLerpTimer();

//
void OverridePlayerListTlk();

void main()
{


    // event hooks

    // on has feat with whitelist (dont work with ranger's favored enemies)
    //NWNX_Events_AddIDToWhitelist("NWNX_ON_HAS_FEAT", FEAT_AMBIDEXTERITY);
    //NWNX_Events_AddIDToWhitelist("NWNX_ON_HAS_FEAT", FEAT_TWO_WEAPON_FIGHTING);

    // spellcasting events
    NWNX_Events_SubscribeEvent(NWNX_ON_INPUT_CAST_SPELL_BEFORE, "_ev_on_inp_cast");
    NWNX_Events_SubscribeEvent(NWNX_ON_BROADCAST_CAST_SPELL_AFTER, "_ev_on_brd_cast");
    NWNX_Events_SubscribeEvent(NWNX_ON_CAST_SPELL_BEFORE, "_ev_on_cast");
    NWNX_Events_SubscribeEvent(NWNX_ON_CAST_SPELL_AFTER, "_ev_on_cast");
    NWNX_Events_SubscribeEvent(NWNX_ON_DECREMENT_SPELL_COUNT_BEFORE, "_ev_on_sp_decr");
    NWNX_Events_SubscribeEvent(NWNX_ON_EFFECT_APPLIED_AFTER, "_ev_on_effect");
    NWNX_Events_SubscribeEvent(NWNX_ON_EFFECT_REMOVED_AFTER, "_ev_on_effect");
    NWNX_Events_SubscribeEvent(NWNX_ON_ADD_ASSOCIATE_AFTER, "_ev_on_summon");
    NWNX_Events_SubscribeEvent(NWNX_ON_SPELL_FAILED_AFTER, "_ev_on_cast_fail");

    // usage events

    NWNX_Events_SubscribeEvent(NWNX_ON_ITEM_EQUIP_BEFORE, "_ev_on_item_eq");
    NWNX_Events_SubscribeEvent(NWNX_ON_ITEM_EQUIP_AFTER, "_ev_on_item_eq");
    NWNX_Events_SubscribeEvent(NWNX_ON_ITEM_UNEQUIP_AFTER, "_ev_on_item_uneq");

    // equip/uneqip events
    //NWNX_Events_AddIDToWhitelist("NWNX_ON_ITEMPROPERTY_EFFECT", ITEM_PROPERTY_HASTE);
    //NWNX_Events_AddIDToWhitelist("NWNX_ON_ITEMPROPERTY_EFFECT", ITEM_PROPERTY_ADDITIONAL);

    // trade events

    // Healing penalties used by Poison (row 254).
    NWNX_Events_SubscribeEvent(NWNX_ON_HEAL_BEFORE, "_ev_on_heal");

    // combat events
    NWNX_Weapon_SetDevastatingCriticalEventScript("_ev_on_devast");
    NWNX_Damage_SetDamageEventScript("_ev_on_damage");
    NWNX_Damage_SetAttackEventScript("_ev_on_attack");
    NWNX_Events_SubscribeEvent(NWNX_ON_DISARM_BEFORE, "_ev_on_disarm");
    NWNX_Events_SubscribeEvent(NWNX_ON_COMBAT_MODE_ON, "_ev_on_comb_mode");
    NWNX_Events_SubscribeEvent(NWNX_ON_ITEM_AMMO_RELOAD_BEFORE, "_ev_on_amm_rld");
    NWNX_Events_SubscribeEvent(NWNX_ON_INPUT_ATTACK_OBJECT_BEFORE, "_ev_on_inp_attck");
    NWNX_Events_SubscribeEvent(NWNX_ON_COMBAT_ATTACK_OF_OPPORTUNITY_BEFORE, "_ev_on_aoo");

    // Restore the existing Cormyr prestige-class eligibility validator.
    NWNX_Events_SubscribeEvent(NWNX_ON_LEVEL_DOWN_AFTER, "_ev_on_levelling");
    NWNX_Events_SubscribeEvent(NWNX_ON_CLIENT_LEVEL_UP_BEGIN_BEFORE, "_ev_on_levelling");
    PrintString("[RDD FIX] Cormyr prestige validator subscribed");

    // custom ELC



    // ----------------------------------------------------------------------------

    SetModuleSwitch(MODULE_SWITCH_DISABLE_DAMAGE_SHIELD_STACKING, TRUE);
    SetModuleSwitch(MODULE_SWITCH_DISABLE_AOE_SPELLS_STACKING, 3);         // only 3 same type AOE's per area
    SetModuleSwitch(MODULE_SWITCH_OVERFILLED_STORES_ISSUE_FIX, 100);
    SetModuleSwitch(MODULE_SWITCH_CORMYR_NO_1_ROUND_AOE_DELAY, 1);         // delay before 1st AoE tik, possible values 1-5, zero value - disabled
    SetModuleSwitch(MODULE_SWITCH_CORMYR_MAX_LEVEL_AOE_DURATION_SEC, 60);  // AoE duration for 40 lvl character in seconds
    SetModuleSwitch(MODULE_SWITCH_CORMYR_BOSS_AI_FOR_ALL, FALSE);          // Enable AI Boss targeting tweak for all

    SetModuleSwitch(MODULE_VAR_OVERRIDE_SPELLSCRIPT, TRUE);
    SetModuleOverrideSpellscript("_mod_spellhook");

    SetModuleSwitch(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS, TRUE);
    SetModuleSwitch(MODULE_SWITCH_AOE_HURT_NEUTRAL_NPCS, FALSE);
    SetModuleSwitch(MODULE_SWITCH_ENABLE_NPC_AOE_HURT_ALLIES, FALSE);

    LootSeparator();
    SetLocalInt(GetModule(), CORMYREAN_WIPE_PHASE, CORMYREAN_WIPE_PHASE_4);
    ExecuteScript("pdk_srv_load", GetModule());
    ExecuteScript("ct_cormyr_check", GetModule());

    ExecuteScript("ct_link_check", GetModule());

    // Restored from the supplied original cormyr.mod; existing hooks retained.
    NWNX_Events_SubscribeEvent(NWNX_ON_CLIENT_CONNECT_BEFORE, "_ev_on_connect");
    NWNX_Events_SubscribeEvent(NWNX_ON_INVENTORY_ADD_ITEM_BEFORE, "_ev_on_inv_item");
    NWNX_Events_SubscribeEvent(NWNX_ON_DM_DUMP_LOCALS_BEFORE, "dm_dumplocals");
    NWNX_Events_SubscribeEvent(NWNX_ON_EXAMINE_OBJECT_BEFORE, "_ev_on_examine");
    NWNX_Events_SubscribeEvent(NWNX_ON_ABILITY_CHANGE_AFTER, "_ev_on_ability");
    NWNX_Events_SubscribeEvent(NWNX_ON_USE_FEAT_BEFORE, "_ev_on_use_feat");
    NWNX_Events_SubscribeEvent(NWNX_ON_USE_SKILL_BEFORE, "_ev_on_use_skill");
    NWNX_Events_SubscribeEvent(NWNX_ON_USE_ITEM_BEFORE, "_ev_on_use_item");
    NWNX_Events_SubscribeEvent(NWNX_ON_STORE_REQUEST_BUY_BEFORE, "_ev_on_trade");
    NWNX_Events_SubscribeEvent(NWNX_ON_STORE_REQUEST_BUY_AFTER, "_ev_on_trade");
    NWNX_Events_SubscribeEvent(NWNX_ON_STORE_REQUEST_SELL_AFTER, "_ev_on_trade");
    NWNX_ELC_SetELCScript("_mod_elc");
    NWNX_ELC_EnableCustomELCCheck(TRUE);
    DelayCommand(1.0, ExecuteScript("cs_world_init", GetModule()));
    NWNX_Feedback_SetJournalUpdatedMessageHidden(TRUE);
    NWNX_Feedback_SetCombatLogMessageHidden(NWNX_FEEDBACK_COMBATLOG_CAST_SPELL, TRUE);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_IMMUNITY, TRUE);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_RESISTANCE, TRUE);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_RESISTANCE_REMAINING, TRUE);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_REDUCTION, TRUE);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_DAMAGE_REDUCTION_REMAINING, TRUE);
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_COMBAT_WEAPON_NOT_EFFECTIVE, TRUE);
    NWNX_Feat_SetFeatModifier(FEAT_EPIC_ACCURACY_1,  NWNX_FEAT_MODIFIER_AB, 1);
    NWNX_Feat_SetFeatModifier(FEAT_EPIC_ACCURACY_2,  NWNX_FEAT_MODIFIER_AB, 2);
    NWNX_Feat_SetFeatModifier(FEAT_EPIC_ACCURACY_3,  NWNX_FEAT_MODIFIER_AB, 3);
    NWNX_Feat_SetFeatModifier(FEAT_EPIC_ACCURACY_4,  NWNX_FEAT_MODIFIER_AB, 4);
    NWNX_Feat_SetFeatModifier(FEAT_EPIC_ACCURACY_5,  NWNX_FEAT_MODIFIER_AB, 5);
    NWNX_Feat_SetFeatModifier(FEAT_EPIC_ACCURACY_6,  NWNX_FEAT_MODIFIER_AB, 6);
    NWNX_Feat_SetFeatModifier(FEAT_EPIC_ACCURACY_7,  NWNX_FEAT_MODIFIER_AB, 7);
    NWNX_Feat_SetFeatModifier(FEAT_EPIC_ACCURACY_8,  NWNX_FEAT_MODIFIER_AB, 8);
    NWNX_Feat_SetFeatModifier(FEAT_EPIC_ACCURACY_9,  NWNX_FEAT_MODIFIER_AB, 9);
    NWNX_Feat_SetFeatModifier(FEAT_EPIC_ACCURACY_10, NWNX_FEAT_MODIFIER_AB, 10);
    PrintString("[CORMYR TEST] Spell/combat hooks initialized");
}

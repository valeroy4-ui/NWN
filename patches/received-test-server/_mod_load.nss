#include "70_inc_switches"
#include "nwnx_weapon"
#include "nwnx_damage"
#include "nwnx_events"
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

    PrintString("[CORMYR TEST] Spell/combat hooks initialized");
}

#include "_inc_reputation"
#include "_inc_psv_bonuses"
#include "_inc_war_class"

void main()
{
    object oPC = OBJECT_SELF;
    // sanity check
    if (!GetIsPC(oPC) || GetIsDM(oPC))
        return;

    // restore movement rate
    NWNX_Creature_SetMovementRate(oPC, NWNX_CREATURE_MOVEMENT_RATE_PC);

    // remove all 'passive' effects
    RemoveEffectsFromSpell(oPC, SPELL_INSTANT_CHARACTER_EFFECTS);

    if(GetPCIPAddress(oPC) == "192.168.128.100" /* debug */)
    {
        effect eTest = SetEffectSpellId(ExtraordinaryEffect(EffectBonusFeat(FEAT_EXTEND_SPELL)), SPELL_INSTANT_CHARACTER_EFFECTS);
        effect eTest1 = SetEffectSpellId(ExtraordinaryEffect(EffectBonusFeat(FEAT_DIVINE_SHIELD)), SPELL_INSTANT_CHARACTER_EFFECTS);
        effect eTest2 = SetEffectSpellId(ExtraordinaryEffect(EffectBonusFeat(FEAT_EPIC_DAMAGE_REDUCTION_3)), SPELL_INSTANT_CHARACTER_EFFECTS);
        effect eTest3 = SetEffectSpellId(ExtraordinaryEffect(EffectBonusFeat(FEAT_EPIC_DAMAGE_REDUCTION_6)), SPELL_INSTANT_CHARACTER_EFFECTS);
        effect eTest4 = SetEffectSpellId(ExtraordinaryEffect(EffectBonusFeat(FEAT_EPIC_DAMAGE_REDUCTION_9)), SPELL_INSTANT_CHARACTER_EFFECTS);
        effect eTest5 = SetEffectSpellId(ExtraordinaryEffect(EffectBonusFeat(FEAT_EPIC_BARBARIAN_DAMAGE_REDUCTION)), SPELL_INSTANT_CHARACTER_EFFECTS);
        effect eTest6 = SetEffectSpellId(ExtraordinaryEffect(EffectBonusFeat(FEAT_SKILL_FOCUS_DISCIPLINE)), SPELL_INSTANT_CHARACTER_EFFECTS);
        effect eTest7 = SetEffectSpellId(ExtraordinaryEffect(EffectBonusFeat(FEAT_SKILL_FOCUS_CONCENTRATION)), SPELL_INSTANT_CHARACTER_EFFECTS);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTest, oPC, DURATION_SERVER_SESSION);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTest1, oPC, DURATION_SERVER_SESSION);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTest2, oPC, DURATION_SERVER_SESSION);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTest3, oPC, DURATION_SERVER_SESSION);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTest4, oPC, DURATION_SERVER_SESSION);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTest5, oPC, DURATION_SERVER_SESSION);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTest6, oPC, DURATION_SERVER_SESSION);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTest7, oPC, DURATION_SERVER_SESSION);
    }

    // re-apply cutscene ghost
    effect eCutsceneGhost = SetEffectSpellId(ExtraordinaryEffect(EffectCutsceneGhost()), SPELL_INSTANT_CHARACTER_EFFECTS);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCutsceneGhost, oPC, DURATION_SERVER_SESSION);

    // re-apply moon elf SR
    if(GetHasFeat(FEAT_MOONELF_SPELLRESISTANCE, oPC))
    {
        int nSR = GetHitDice(oPC) / 5 * 4;
        effect eSR = HideEffectIcon(SetEffectSpellId(ExtraordinaryEffect(EffectSpellResistanceIncrease(nSR)), SPELL_INSTANT_CHARACTER_EFFECTS));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSR, oPC, DURATION_SERVER_SESSION);
    }

    // handle player statistics
    RemoveEffectsFromSpell(oPC, SPELL_CORMYR_PSTAT);
    if(GetLocalInt(oPC, "PSTAT_ENABLED"))
    {
        effect ePStat = EffectRunScript("", "_mod_runscript", "_mod_runscript", 2.0);
        ePStat = SetEffectSpellId(ExtraordinaryEffect(ePStat), SPELL_CORMYR_PSTAT);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePStat, oPC, DURATION_SERVER_SESSION);
    }

    // 4 classes wipe support AC bonus
    if(players_GetIsSupport(oPC) && GetLocalInt(GetModule(), CORMYREAN_WIPE_PHASE) >= CORMYREAN_WIPE_PHASE_4)
    {
        int nAC = GetHitDice(oPC) / 4 + GetHitDice(oPC) / 20;
        effect eAC = EffectACIncrease(nAC, AC_DEFLECTION_BONUS);

        eAC = SetEffectSpellId(ExtraordinaryEffect(eAC), SPELL_INSTANT_CHARACTER_EFFECTS);
        eAC = HideEffectIcon(eAC);

        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAC, oPC, DURATION_SERVER_SESSION);
    }

    // restore reputation
    RestoreReputation(oPC);

    // apply Warlord passive bonuses
    ApplyWarlordPassiveAbilities(oPC);

    // apply RDD size
    if (GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oPC) >= 30)
        NWNX_Creature_SetSize(oPC, CREATURE_SIZE_LARGE);

    // set archmage wis AC bonus
    SetArchmageAncientAC(oPC);

    // apply two weapon fighting shield AC
    AddACAmbidex(oPC);

    // apply cold damage for dex toons
    DexDamage(oPC);

    // adjust crit range for fighter and monk
    psv_ApplyBonusCriticalRange(oPC);

    // add monk damage bonuses
    AddMonkBonuses(oPC);

    // apply custom onhit spells for classes
    AddAssassinWeaponOnHit(oPC);
    AddRogueWeaponOnHit(oPC);
    AddSlayerWeaponOnHit(oPC);

    // shifter/slayer can not use shields, lets check it
    CheckShieldOnShifter(oPC);

    // add BG damage bonus
    AddBgDamageBonus(oPC);

    // add 20 tumble to shield
    psv_TumbleCompensation(oPC);

    // set dislike for opposite faction PCs
    spells_SetMassDislike(oPC);

    // applies concentration and taunt bonus for specific classes
    psv_TauntAndConcentrationBonus(oPC);

    // handle runic regen
    psv_ApplyRuneOfRegenHeal(oPC);

    // add bonus saves
    psv_AdjustCustomSaves(oPC);

    // clear dd effects
    if(!(GetHasSpellEffect(SPELL_WARLORD_FURY , oPC) + GetHasSpellEffect(SPELL_BATTLEFIELD_ECHO , oPC) + GetHasSpellEffect(SPELL_WARLORD_GUARD, oPC)))
        WarlordRemoveAllActiveSpells(oPC);


    // clear dispel cash
    DeleteLocalInt(oPC, "DEFENCE_DC_CASHED");
    DeleteLocalInt(oPC, "DEFENCE_DC_CASHED_FROM_ITEM");

    DeleteLocalInt(oPC, "ATTACK_ROLL_CASHED_FOR_SPELL_" + IntToString(SPELL_LESSER_DISPEL));
    DeleteLocalInt(oPC, "ATTACK_ROLL_CASHED_FOR_SPELL_" + IntToString(SPELL_DISPEL_MAGIC));
    DeleteLocalInt(oPC, "ATTACK_ROLL_CASHED_FOR_SPELL_" + IntToString(SPELL_GREATER_DISPELLING));
    DeleteLocalInt(oPC, "ATTACK_ROLL_CASHED_FOR_SPELL_" + IntToString(SPELL_MORDENKAINENS_DISJUNCTION));

    DeleteLocalInt(oPC, "ATTACK_ROLL_CASHED_FROM_ITEM_FOR_SPELL_" + IntToString(SPELL_LESSER_DISPEL));
    DeleteLocalInt(oPC, "ATTACK_ROLL_CASHED_FROM_ITEM_FOR_SPELL_" + IntToString(SPELL_DISPEL_MAGIC));
    DeleteLocalInt(oPC, "ATTACK_ROLL_CASHED_FROM_ITEM_FOR_SPELL_" + IntToString(SPELL_GREATER_DISPELLING));
    DeleteLocalInt(oPC, "ATTACK_ROLL_CASHED_FROM_ITEM_FOR_SPELL_" + IntToString(SPELL_MORDENKAINENS_DISJUNCTION));
    DeleteLocalInt(oPC, "ATTACK_ROLL_CASHED_FROM_ITEM_FOR_SPELL_" + IntToString(SPELL_BESTOW_CURSE));

    DeleteLocalInt(oPC, "DISPEL_CHECKS_CASHED_FOR_SPELL_" + IntToString(SPELL_LESSER_DISPEL));
    DeleteLocalInt(oPC, "DISPEL_CHECKS_CASHED_FOR_SPELL_" + IntToString(SPELL_DISPEL_MAGIC));
    DeleteLocalInt(oPC, "DISPEL_CHECKS_CASHED_FOR_SPELL_" + IntToString(SPELL_GREATER_DISPELLING));
    DeleteLocalInt(oPC, "DISPEL_CHECKS_CASHED_FOR_SPELL_" + IntToString(SPELL_MORDENKAINENS_DISJUNCTION));

    /*
    int nCount = NWNX_Effect_GetTrueEffectCount(oPC);
    int i = 0;
    for (i = 0; i < nCount; i++)
    {
        struct NWNX_EffectUnpacked eEffUnpacked = NWNX_Effect_GetTrueEffect(oPC, i);
        printeff(eEffUnpacked);
    }
    */
}

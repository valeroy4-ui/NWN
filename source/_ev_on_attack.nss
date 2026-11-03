#include "nwnx_damage"
#include "_inc_itemprop"
#include "_inc_colortext"
#include "_inc_sqlocals"
#include "_inc_sqlite_time"
#include "nwnx_creature"
#include "_inc_generic"
#include "_inc_runes"
#include "_inc_fshop_bg"
#include "_inc_pulse_rage"
#include "_inc_onhit"


/*
struct NWNX_Damage_AttackEventData
{
    object oTarget; ///< The target who took the damage
    int iBludgeoning; ///< Bludgeoning damage
    int iPierce; ///< Piercing damage
    int iSlash; ///< Slashing damage
    int iMagical; ///< Magical damage
    int iAcid; ///< Acid damage
    int iCold; ///< Cold damage
    int iDivine; ///< Divine damage
    int iElectrical; ///< Electrical damage
    int iFire; ///< Fire damage
    int iNegative; ///< Negative damage
    int iPositive; ///< Positive damage
    int iSonic; ///< Sonic damage
    int iBase; ///< Base damage
    int iCustom1; ///< Custom1 damage
    int iCustom2; ///< Custom2 damage
    int iCustom3; ///< Custom3 damage
    int iCustom4; ///< Custom4 damage
    int iCustom5; ///< Custom5 damage
    int iCustom6; ///< Custom6 damage
    int iCustom7; ///< Custom7 damage
    int iCustom8; ///< Custom8 damage
    int iCustom9; ///< Custom9 damage
    int iCustom10; ///< Custom10 damage
    int iCustom11; ///< Custom11 damage
    int iCustom12; ///< Custom12 damage
    int iCustom13; ///< Custom13 damage
    int iCustom14; ///< Custom14 damage
    int iCustom15; ///< Custom15 damage
    int iCustom16; ///< Custom16 damage
    int iCustom17; ///< Custom17 damage
    int iCustom18; ///< Custom18 damage
    int iCustom19; ///< Custom19 damage
    int iAttackNumber; ///< 1-based index of the attack in current combat round
    int iAttackResult; ///< 1=hit, 2=parried, 3=critical hit, 4=miss, 5=resisted, 7=automatic hit, 8=concealed, 9=miss chance, 10=devastating crit
    int iWeaponAttackType; ///< 1=main hand, 2=offhand, 3-5=creature, 6=extra(haste), 7=unarmed, 8=unarmed extra
    int iSneakAttack; ///< 0=neither, 1=sneak attack, 2=death attack, 3=both
    int bRangedAttack; /// TRUE if it is a ranged attack
    int bKillingBlow; ///< TRUE if the hit is a killing blow
    int iAttackType; ///< 65002=Attack of Opportunity, 65003=Riposte or a FeatID like KnockDown or some other special attack.
    int iToHitRoll; ///< The to hit roll of the attack
    int iToHitModifier; ///< The to hit modifier of the attack
};

 */

    /*
    SendMessageToPC(OBJECT_SELF, "iBludgeoning: " + IntToString(AttackEventData.iBludgeoning));
    SendMessageToPC(OBJECT_SELF, "iPierce: " + IntToString(AttackEventData.iPierce));
    SendMessageToPC(OBJECT_SELF, "iSlash: " + IntToString(AttackEventData.iSlash));
    SendMessageToPC(OBJECT_SELF, "iMagical: " + IntToString(AttackEventData.iMagical));
    SendMessageToPC(OBJECT_SELF, "iAcid: " + IntToString(AttackEventData.iAcid));
    SendMessageToPC(OBJECT_SELF, "iCold: " + IntToString(AttackEventData.iCold));
    SendMessageToPC(OBJECT_SELF, "iDivine: " + IntToString(AttackEventData.iDivine));
    SendMessageToPC(OBJECT_SELF, "iElectrical: " + IntToString(AttackEventData.iElectrical));
    SendMessageToPC(OBJECT_SELF, "iFire: " + IntToString(AttackEventData.iFire));
    SendMessageToPC(OBJECT_SELF, "iNegative: " + IntToString(AttackEventData.iNegative));
    SendMessageToPC(OBJECT_SELF, "iPositive: " + IntToString(AttackEventData.iPositive));
    SendMessageToPC(OBJECT_SELF, "iSonic: " + IntToString(AttackEventData.iSonic));
    SendMessageToPC(OBJECT_SELF, "iBase: " + IntToString(AttackEventData.iBase));
    */

const float ATTACK_SPLASH_SCYTHE_DAMAGE_PERCENT        = 0.4; // 40%
const float SPELL_CORMYR_BLEED_TICK_INTERVAL           = 6.0; // every round
const float SPELL_CORMYR_BLEED_DURATION                = 18.1; // 3 rounds
const float SPELL_CORMYR_EMPOWERED_HIT_DURATION        = 12.0; // seconds/2 rounds
const float SPELL_CORMYR_EMPOWERED_HIT_BASE_MULTIPLIER = 1.1; // 10%
const float SPELL_CORMYR_EMPOWERED_HIT_UPGRADE_STEP    = 0.02; // 2%
const int BG_SEAL_OF_SILENCE_SPELLFAILURE_PERCENT      = 5; // 5%
const int BG_SEAL_OF_SILENCE_DURATION_SECONDS          = 9; // 9 seconds
const int BG_MARK_OF_DOOM_MAX_HITS                     = 5; // 5 hits to target

//
void attack_ExtendedCombatLog(object oPC, struct NWNX_Damage_AttackEventData AttackEventData);

//
void attack_CustomVorpal(object oPC, struct NWNX_Damage_AttackEventData AttackEventData);

//
void attack_Splash(object oPC, struct NWNX_Damage_AttackEventData AttackEventData, float fDamagePercent);

//
int attack_GetTotalDamage(struct NWNX_Damage_AttackEventData AttackEventData);

//
struct NWNX_Damage_AttackEventData attack_ModifyDamage(struct NWNX_Damage_AttackEventData AttackEventData, float fMultiplier);

//
struct NWNX_Damage_AttackEventData attack_AddWMDamage(struct NWNX_Damage_AttackEventData AttackEventData, int nModifier);

//
void attack_PureFighterDebuff(object oTarget, int nFighterLevel);

//
void attack_Bleed(struct NWNX_Damage_AttackEventData AttackEventData);

//
float attack_GetEmpoweredHitMultiplier(object oAttacker);

//
void attack_ExecDPSCalculator(object oPC, struct NWNX_Damage_AttackEventData AttackEventData);

//
void attack_ApplyMicroBash(object oAttacker, object oTarget);


// Mestil's Acid Sheath ESF: movement only, refresh without stacking.
const int ATTACK_MESTIL_SLOW_PERCENT = 10;
const float ATTACK_MESTIL_SLOW_SECONDS = 3.0;
const string ATTACK_MESTIL_EPIC_TAG = "MS266_EPIC_SHIELD";
const string ATTACK_MESTIL_SLOW_TAG = "MS266_SLOW";

void attack_MestilAcidSheathSlow(struct NWNX_Damage_AttackEventData data)
{
    if (data.bRangedAttack || (data.iAttackResult != 1 && data.iAttackResult != 3
        && data.iAttackResult != 7 && data.iAttackResult != 10)) return;
    object oAttacker = OBJECT_SELF, oHolder = data.oTarget;
    if (!GetIsObjectValid(oAttacker) || !GetIsObjectValid(oHolder) || oAttacker == oHolder
        || GetObjectType(oAttacker) != OBJECT_TYPE_CREATURE || GetIsDead(oAttacker)) return;
    object oCreator = OBJECT_INVALID;
    effect e = GetFirstEffect(oHolder);
    while (GetIsEffectValid(e))
    {
        if (GetEffectType(e) == EFFECT_TYPE_ELEMENTALSHIELD
            && GetEffectSpellId(e) == SPELL_MESTILS_ACID_SHEATH
            && GetEffectTag(e) == ATTACK_MESTIL_EPIC_TAG)
        { oCreator = GetEffectCreator(e);break; }
        e = GetNextEffect(oHolder);
    }
    if (!GetIsObjectValid(oCreator)) return;
    // Remove only this feature's previous debuff. Never remove the attacker's own shield.
    e = GetFirstEffect(oAttacker);
    while (GetIsEffectValid(e))
    {
        if (GetEffectTag(e) == ATTACK_MESTIL_SLOW_TAG
            && GetEffectSpellId(e) == SPELL_MESTILS_ACID_SHEATH) RemoveEffect(oAttacker, e);
        e = GetNextEffect(oAttacker);
    }
    AssignCommand(oCreator, ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
        TagEffect(SetEffectSpellId(EffectMovementSpeedDecrease(ATTACK_MESTIL_SLOW_PERCENT),
            SPELL_MESTILS_ACID_SHEATH), ATTACK_MESTIL_SLOW_TAG),
        oAttacker, ATTACK_MESTIL_SLOW_SECONDS));
}

const float PDK_EMPOWERED_HIT_BONUS = 0.10;
int attack_UsesPDKGloves(object p, struct NWNX_Damage_AttackEventData d)
{
    if(GetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT,p)<=0 || d.bRangedAttack) return FALSE;
    int unarmed=d.iWeaponAttackType==7 || d.iWeaponAttackType==8;
    if((d.iWeaponAttackType==1 || d.iWeaponAttackType==6)
       && !GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,p))) unarmed=TRUE;
    object gloves=GetItemInSlot(INVENTORY_SLOT_ARMS,p);
    return unarmed && GetIsObjectValid(gloves) && GetBaseItemType(gloves)==BASE_ITEM_GLOVES
        && ip_GetHasCormyrIP(gloves,IP_CONST_ADDITIONAL_CORMYR_EMPOWERED_HIT);
}

void main()
{
    struct NWNX_Damage_AttackEventData AttackEventData = NWNX_Damage_GetAttackEventData();
    attack_MestilAcidSheathSlow(AttackEventData);

    // DEBUG
    // ServerShout("Attack. Total Damage = " + IntToString(attack_GetTotalDamage(AttackEventData)));
    // ServerShout("Total Nwscript Damage = " + IntToString(GetTotalDamageDealt()));
    // ServerShout("Attack. iAttackType " + IntToString(AttackEventData.iAttackType));
    // ServerShout("Attack"); // triggering before damage

    // send extended log if activated
    if(GetLocalInt(OBJECT_SELF, "COMBAT_LOG_EXTEND"))
        attack_ExtendedCombatLog(OBJECT_SELF, AttackEventData);
    if(GetLocalInt(OBJECT_SELF, "DPS_CALCULATOR_ON"))
        attack_ExecDPSCalculator(OBJECT_SELF, AttackEventData);

    object oWeapon;
    if (AttackEventData.iWeaponAttackType == 1 || AttackEventData.iWeaponAttackType == 6) // main hand or hast attack
        oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, OBJECT_SELF);
    else if (AttackEventData.iWeaponAttackType == 2) // offhand attack
        oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, OBJECT_SELF);
    // if no weapon in left or right hand check gloves
    object oGloves = GetItemInSlot(INVENTORY_SLOT_ARMS, OBJECT_SELF);
    if (!GetIsObjectValid(oWeapon) && GetBaseItemType(oGloves) == BASE_ITEM_GLOVES)
        oWeapon = oGloves;

    if(GetIsPC(OBJECT_SELF) && AttackEventData.bRangedAttack && !GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER))
    {
        effect eSlow = EffectMovementSpeedIncrease(-30);
        eSlow = EffectLinkEffects(EffectIcon(EFFECT_ICON_BROKEN_RHYTHM), HideEffectIcon(eSlow));
        eSlow = ExtraordinaryEffect(SetEffectSpellId(eSlow, SPELL_BROKEN_RHYTHM));
        // remove effects
        RemoveEffectsFromSpell(OBJECT_SELF, SPELL_BROKEN_RHYTHM);
        // apply slow
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, OBJECT_SELF, 3.0);
    }
    // disarm event bugfix
    if(AttackEventData.iAttackType == FEAT_DISARM || AttackEventData.iAttackType == FEAT_IMPROVED_DISARM)
    {
        SetLocalInt(AttackEventData.oTarget, "CORMYR_DISARM_TIMESTAMP", SQLite_GetTimeStamp());
    }

    // strafe bug detection
    if(GetIsPC(OBJECT_SELF) && AttackEventData.iAttackNumber == 1 && AttackEventData.iAttackType == 0)
    {
        int nCurrentUnixTime = SQLite_GetTimeStamp();
        int nSavedTime = GetLocalInt(OBJECT_SELF, "LAST_1ST_ATTACK_TIME");
        if (nSavedTime)
        {
            int nTimingBetweenRounds = nCurrentUnixTime - nSavedTime;
            if (GetLocalInt(OBJECT_SELF, "COMBAT_LOG_EXTEND"))
                SendMessageToPC(OBJECT_SELF, "Timing between rounds = " + IntToString(nTimingBetweenRounds) + " seconds");
            if(nTimingBetweenRounds < 4)
                SetLocalInt(OBJECT_SELF, "STRAFE_BUG_DETECTIONS_NUMBER", GetLocalInt(OBJECT_SELF, "STRAFE_BUG_DETECTIONS_NUMBER") + 1);
            if(GetLocalInt(OBJECT_SELF, "STRAFE_BUG_DETECTIONS_NUMBER")/10)
            {
                // send info about cheater to discord channel or log
                DeleteLocalInt(OBJECT_SELF, "STRAFE_BUG_DETECTIONS_NUMBER");
                string sTabulation = "    ";
                string sMessage = "[STRAFE DETECTED]\n";
                sMessage += sTabulation + "Player: " + GetName(OBJECT_SELF) + "\n";
                sMessage += sTabulation + "Account: " + GetPCPlayerName(OBJECT_SELF) + "\n";
                sMessage += sTabulation + "Area: " + GetName(GetArea(OBJECT_SELF)) + "\n";
                sMessage += sTabulation + "Target: " + GetName(AttackEventData.oTarget) + "\n";
                WriteLog(sMessage, LOG_LEVEL_CHEAT);
            }
         }
         SetLocalInt(OBJECT_SELF, "LAST_1ST_ATTACK_TIME", nCurrentUnixTime);
    }

    if (AttackEventData.iAttackResult == 3) // critical hit
    {
        if (GetObjectType(AttackEventData.oTarget) == OBJECT_TYPE_CREATURE)
        {
            if (GetIsObjectValid(oWeapon))
            {
                // custom vorpal
                if (ip_GetHasCormyrIP(oWeapon, IP_CONST_ADDITIONAL_CORMYR_VORPAL) || GetHasFeat(FEAT_SAYANARA, OBJECT_SELF))
                    attack_CustomVorpal(OBJECT_SELF, AttackEventData);
                // custom bleed
                if (ip_GetHasCormyrIP(oWeapon, IP_CONST_ADDITIONAL_CORMYR_BLEED))
                    attack_Bleed(AttackEventData);
                // custom empowered
                if (ip_GetHasCormyrIP(oWeapon, IP_CONST_ADDITIONAL_CORMYR_EMPOWERED_HIT))
                {
                    RemoveEffectsFromSpell(OBJECT_SELF, SPELL_CORMYR_EMPOWERED_HIT);
                    effect eEmpowered = EffectIcon(EFFECT_ICON_EMPOWERED_HIT);
                    eEmpowered = SetEffectSpellId(eEmpowered, SPELL_CORMYR_EMPOWERED_HIT);
                    float fEmpoweredDuration=SPELL_CORMYR_EMPOWERED_HIT_DURATION;
                    if(attack_UsesPDKGloves(OBJECT_SELF,AttackEventData)) fEmpoweredDuration+=RoundsToSeconds(1);
                    AssignCommand(OBJECT_SELF, DelayCommand(0.1, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eEmpowered), OBJECT_SELF, fEmpoweredDuration)));
                }
                // custom splash
                float fSplashPercentOfCrit = 0.0;
                if      (ip_GetHasCormyrIP(oWeapon, IP_CONST_ADDITIONAL_CORMYR_SPLASH))
                    fSplashPercentOfCrit = ATTACK_SPLASH_SCYTHE_DAMAGE_PERCENT;
                else if (runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_SPLASH_V))
                    fSplashPercentOfCrit = RUNE_EPIC_COMBAT_SPLASH_V_VALUE;
                else if (runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_SPLASH_IV))
                    fSplashPercentOfCrit = RUNE_EPIC_COMBAT_SPLASH_IV_VALUE;
                else if (runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_SPLASH_III))
                    fSplashPercentOfCrit = RUNE_EPIC_COMBAT_SPLASH_III_VALUE;
                else if (runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_SPLASH_II))
                    fSplashPercentOfCrit = RUNE_EPIC_COMBAT_SPLASH_II_VALUE;
                else if (runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_SPLASH_I))
                    fSplashPercentOfCrit = RUNE_EPIC_COMBAT_SPLASH_I_VALUE;
                if (fSplashPercentOfCrit > 0.0)
                    attack_Splash(OBJECT_SELF, AttackEventData, fSplashPercentOfCrit);
            }
            // >>> Fighter's passive ability
            int nFighterLevel = GetLevelByClass(CLASS_TYPE_FIGHTER);
            if(nFighterLevel)
                attack_PureFighterDebuff(AttackEventData.oTarget, nFighterLevel);
            // <<< Fighter's passive ability
        }
        // WM critical hit bonus dmg
        int nWMLevels = GetLevelByClass(CLASS_TYPE_WEAPON_MASTER);
        if(nWMLevels)
            AttackEventData = attack_AddWMDamage(AttackEventData, nWMLevels * 2);
    }
    if (AttackEventData.iAttackResult == 1 || AttackEventData.iAttackResult == 3) // hit or critical hit
    {
        // apply microbash
        if(ip_GetHasCormyrIP(oWeapon, IP_CONST_ADDITIONAL_CORMYR_MICROBASH))
            attack_ApplyMicroBash(OBJECT_SELF, AttackEventData.oTarget);

        int nTotalDamage = attack_GetTotalDamage(AttackEventData);
        if(nTotalDamage)
        {
            int nRuneEpicLifeleech = 0;
            if     (runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_LIFELEECH_V))
                nRuneEpicLifeleech = RUNE_EPIC_COMBAT_LIFELEECH_V_VALUE;
            else if(runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_LIFELEECH_IV))
                nRuneEpicLifeleech = RUNE_EPIC_COMBAT_LIFELEECH_IV_VALUE;
            else if(runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_LIFELEECH_III))
                nRuneEpicLifeleech = RUNE_EPIC_COMBAT_LIFELEECH_III_VALUE;
            else if(runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_LIFELEECH_II))
                nRuneEpicLifeleech = RUNE_EPIC_COMBAT_LIFELEECH_II_VALUE;
            else if(runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_LIFELEECH_I))
                nRuneEpicLifeleech = RUNE_EPIC_COMBAT_LIFELEECH_I_VALUE;
            if(nRuneEpicLifeleech)
            {
                int nHealPoints = nTotalDamage*nRuneEpicLifeleech / 100;
                int nMaxHealPoints = GetMaxHitPoints(OBJECT_SELF) - GetCurrentHitPoints(OBJECT_SELF);
                nHealPoints = (nHealPoints > nMaxHealPoints) ? nMaxHealPoints : nHealPoints;
                effect eHeal = EffectHeal(nHealPoints);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, OBJECT_SELF);
            }
        }
        // >>> epic rune Extra Weapon Damage
        int nRuneEpicExtraDamagePercent = 0;
        if     (runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_V))
            nRuneEpicExtraDamagePercent += RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_V_VALUE;
        else if(runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_IV))
            nRuneEpicExtraDamagePercent += RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_IV_VALUE;
        else if(runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_III))
            nRuneEpicExtraDamagePercent += RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_III_VALUE;
        else if(runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_II))
            nRuneEpicExtraDamagePercent += RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_II_VALUE;
        else if(runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_I))
            nRuneEpicExtraDamagePercent += RUNE_EPIC_COMBAT_EXTRA_WEAPON_DAMAGE_I_VALUE;
        // <<< epic rune Extra Weapon Damage

        // >>> Divine Nature rune damage bonus
        if(runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_DIVINE_NATURE_III))
            nRuneEpicExtraDamagePercent += 10;  // +10% from Divine Nature rune
        // <<< Divine Nature rune damage bonus

        // >>> assassination mark damage bonus
        if(AttackEventData.iSneakAttack) // succesful sneak/death attack
        {
            if(onhit_GetHasAssasinationMark(OBJECT_SELF, AttackEventData.oTarget))
                nRuneEpicExtraDamagePercent += (GetLevelByClass(CLASS_TYPE_ASSASSIN, OBJECT_SELF) + GetLevelByClass(CLASS_TYPE_ROGUE, OBJECT_SELF)) / 5;
            SetLocalInt(OBJECT_SELF, "LAST_SUCCESSFUL_SNEAK_DEATH_ATTACK", SQLite_GetTimeStamp());
            //ServerShout(IntToString((GetLevelByClass(CLASS_TYPE_ASSASSIN, OBJECT_SELF) + GetLevelByClass(CLASS_TYPE_ROGUE, OBJECT_SELF)) / 5));
        }
        // <<< assassination mark damage bonus

        // >>> epic rune Extra Weapon Damage
        if(nRuneEpicExtraDamagePercent)
        {
            float fMultiplier = 1.0 + IntToFloat(nRuneEpicExtraDamagePercent)/100;
            int nDamageBefore = attack_GetTotalDamage(AttackEventData);
            AttackEventData = attack_ModifyDamage(AttackEventData, fMultiplier);
            int nDamageAfter = attack_GetTotalDamage(AttackEventData);
            int iFaction = players_GetFaction(AttackEventData.oTarget);
            //DelayCommand(0.1, SendMessageToPC(OBJECT_SELF, "Damage before:" + IntToString(nDamageBefore)));
            //DelayCommand(0.1, SendMessageToPC(OBJECT_SELF, "Damage after:" + IntToString(nDamageAfter)));
            string sMessage = ColorText(GetName(AttackEventData.oTarget), players_GetFactionColor(iFaction)) +
                              ColorText(" : Bonus damage deals " + IntToString(nDamageAfter - nDamageBefore) + " damage", TXT_COLOR_ORANGE);
            DelayCommand(0.25, SendMessageToPC(AttackEventData.oTarget, sMessage));
            DelayCommand(0.25, SendMessageToPC(OBJECT_SELF, sMessage));
            //ServerShout("Bonus Damage: " + IntToString(nDamageAfter - nDamageBefore));
        }
        // <<< epic rune Extra Weapon Damage

        // >>> BG abilities
        int nBgLevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD, OBJECT_SELF);
        if(GetHasFeat(FEAT_BG_SEAL_OF_SILENCE, OBJECT_SELF) && nBgLevel / 2 >= d100())
        {
            RemoveEffectsFromSpell(AttackEventData.oTarget, SPELL_CORMYR_SEAL_OF_SILENCE);
            int bIsEvilBlightCreator = GetEffectType(spells_GetFirstEffectWithSpecificSpellID(AttackEventData.oTarget, SPELL_EVIL_BLIGHT, OBJECT_SELF)) != EFFECT_TYPE_INVALIDEFFECT;
            int nBaseItem = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND));
            int nBonus = nBaseItem == BASE_ITEM_BASTARDSWORD ? 10 : 0; // bastard sword bonus
            int nSealPenalty = BG_SEAL_OF_SILENCE_SPELLFAILURE_PERCENT + nBonus;
            if(bIsEvilBlightCreator)
                nSealPenalty += nBgLevel / 5;
            effect eSeal = EffectSpellFailure(nSealPenalty);
            eSeal = EffectLinkEffects(EffectIcon(EFFECT_ICON_SEAL_OF_SILENCE), HideEffectIcon(eSeal));
            eSeal = SetEffectSpellId(eSeal, SPELL_CORMYR_SEAL_OF_SILENCE);
            int nDuration = BG_SEAL_OF_SILENCE_DURATION_SECONDS + 3 * ((fshop_bg_GetIsBitActivated(OBJECT_SELF, FAMESHOP_BG_SEAL_OF_SILENCE_DUR_1) > 0) +
                                                                       (fshop_bg_GetIsBitActivated(OBJECT_SELF, FAMESHOP_BG_SEAL_OF_SILENCE_DUR_2) > 0));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SILENCE), AttackEventData.oTarget);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eSeal), AttackEventData.oTarget, IntToFloat(nDuration));
            DelayCommand(0.0, SendColorMessageToPC(OBJECT_SELF, "Seal of Silence penalty: " + IntToString(nSealPenalty) + "% spellfailure.", TXT_COLOR_VIOLET_L));
            DelayCommand(0.0, SendColorMessageToPC(AttackEventData.oTarget, "Seal of Silence penalty: " + IntToString(nSealPenalty) + "% spellfailure.", TXT_COLOR_VIOLET_L));
        }
        if(GetHasSpellEffect(SPELL_BG_MARK_OF_DOOM, AttackEventData.oTarget))
        {
            int bIsCreator = GetEffectType(spells_GetFirstEffectWithSpecificSpellID(AttackEventData.oTarget, SPELL_BG_MARK_OF_DOOM, OBJECT_SELF)) != EFFECT_TYPE_INVALIDEFFECT;
            if(bIsCreator)
            {
                int nMarkCount = GetLocalInt(AttackEventData.oTarget, "MARK_OF_DOOM_COUNT_" + ObjectToString(OBJECT_SELF));
                nMarkCount++;
                AttackEventData.iFire = AttackEventData.iFire >= 0 ? (AttackEventData.iFire += nBgLevel) : (AttackEventData.iFire = nBgLevel);
                SetLocalInt(AttackEventData.oTarget, "MARK_OF_DOOM_COUNT_" + ObjectToString(OBJECT_SELF), nMarkCount);
                if(nMarkCount >= BG_MARK_OF_DOOM_MAX_HITS)
                {
                    spells_RemoveAllCreatorsEffects(AttackEventData.oTarget, OBJECT_SELF, SPELL_BG_MARK_OF_DOOM);
                    DeleteLocalInt(AttackEventData.oTarget, "MARK_OF_DOOM_COUNT_" + ObjectToString(OBJECT_SELF));
                }
            }
        }
        // <<< BG abilities
        // >>> empowered hit
        if(GetHasSpellEffect(SPELL_CORMYR_EMPOWERED_HIT, OBJECT_SELF))
        {
            float fMultiplier = attack_GetEmpoweredHitMultiplier(OBJECT_SELF);
            if(attack_UsesPDKGloves(OBJECT_SELF,AttackEventData)) fMultiplier+=PDK_EMPOWERED_HIT_BONUS;
            AttackEventData = attack_ModifyDamage(AttackEventData, fMultiplier);
        }
        // <<< empowered hit

        // >>> epic rune Damage Reduction
        int nRuneEpicReductionPercent = 0;
        if     (runes_GetHasRune(AttackEventData.oTarget, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_V))
            nRuneEpicReductionPercent += RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_V_VALUE;
        else if(runes_GetHasRune(AttackEventData.oTarget, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_IV))
            nRuneEpicReductionPercent += RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_IV_VALUE;
        else if(runes_GetHasRune(AttackEventData.oTarget, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_III))
            nRuneEpicReductionPercent += RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_III_VALUE;
        else if(runes_GetHasRune(AttackEventData.oTarget, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_II))
            nRuneEpicReductionPercent += RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_II_VALUE;
        else if(runes_GetHasRune(AttackEventData.oTarget, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_I))
            nRuneEpicReductionPercent += RUNE_EPIC_COMBAT_DAMAGE_REDUCTION_I_VALUE;

        if(nRuneEpicReductionPercent)
        {
            float fMultiplier = 1.0 - IntToFloat(nRuneEpicReductionPercent)/100;
            int nDamageBefore = attack_GetTotalDamage(AttackEventData);
            AttackEventData = attack_ModifyDamage(AttackEventData, fMultiplier);
            int nDamageAfter = attack_GetTotalDamage(AttackEventData);
            int iFaction = players_GetFaction(AttackEventData.oTarget);
            string sMessage = ColorText(GetName(AttackEventData.oTarget), players_GetFactionColor(iFaction)) +
                              ColorText(" : Runic Damage Reduction absorbs " + IntToString(nDamageBefore - nDamageAfter) + " damage", TXT_COLOR_ORANGE);
            DelayCommand(0.25, SendMessageToPC(AttackEventData.oTarget, sMessage));
            if(GetIsPC(OBJECT_SELF))
                DelayCommand(0.25, SendMessageToPC(OBJECT_SELF, sMessage));
        }
        // <<< epic rune Damage Reduction
    }
    //AttackEventData.iAttackResult = 3;
    //AttackEventData.iToHitRoll = 100; ///< The to hit roll of the attack
    //AttackEventData.iToHitModifier = 20; ///< The to hit modifier of the attack
    NWNX_Damage_SetAttackEventData(AttackEventData);
    ExecuteScript("pdk_srv_attack", OBJECT_SELF);
    AttackEventData=NWNX_Damage_GetAttackEventData();
}

void attack_ExtendedCombatLog(object oPC, struct NWNX_Damage_AttackEventData AttackEventData)
{
    float fDistance = GetDistanceBetween(oPC, AttackEventData.oTarget);

    string sAttackResult;
    switch (AttackEventData.iAttackResult)
    {
        case 1: sAttackResult = "hit"; break;
        case 3: sAttackResult = "critical hit"; break;
        case 4: sAttackResult = "miss"; break;
        case 8: sAttackResult = "concealed"; break;
    }

    string sWeaponAttackType;
    switch (AttackEventData.iWeaponAttackType)
    {
        case 1: sWeaponAttackType = "main hand"; break;
        case 2: sWeaponAttackType = "offhand"; break;
        case 3:
        case 4:
        case 5: sWeaponAttackType = "creature"; break;
        case 6: sWeaponAttackType = "extra(haste)"; break;
        case 7: sWeaponAttackType = "unarmed"; break;
        case 8: sWeaponAttackType = "unarmed extra"; break;
    }

    string sSneakAttack;
    switch (AttackEventData.iSneakAttack)
    {
        case 0: sSneakAttack = "neither"; break;
        case 1: sSneakAttack = "sneak attack"; break;
        case 2: sSneakAttack = "death attack"; break;
        case 3: sSneakAttack = "both"; break;
    }

    string sAttackType = "standart";
    if(AttackEventData.iAttackType > 0)
    {
        if(AttackEventData.iAttackType == 65002)
            sAttackType = "Attack of Opportunity";
        else if(AttackEventData.iAttackType == 65003)
            sAttackType = "Riposte";
        else
            sAttackType = GetFeatNameFrom2DA((AttackEventData.iAttackType));
    }

    SendMessageToPC(oPC,         "\n            Attack information\n" +
                                 "Attacker: " + GetName(oPC) + "\n" +
                                 "Target: " + GetName(AttackEventData.oTarget) + "\n" +
                                 "Distance: " + FloatToString(fDistance, 2, 2) + "\n" +
                                 "Attack Number: " + IntToString(AttackEventData.iAttackNumber) + "\n" +
                                 "Attack Result: " + sAttackResult + "\n" +
                                 "Attack Weapon Type: " + sWeaponAttackType + "\n" +
                                 "Attack Type: " + sAttackType + "\n" +
                                 "Sneak Attack: " + sSneakAttack + "\n");

    FloatingColorTextStringOnCreature(IntToString(AttackEventData.iToHitModifier) + " + " +
                                      IntToString(AttackEventData.iToHitRoll)     + " = " +
                                      IntToString(AttackEventData.iToHitModifier + AttackEventData.iToHitRoll),
                                      TXT_COLOR_SPECIAL_HIT,
                                      oPC,
                                      FALSE);
}

void attack_CustomVorpal(object oPC, struct NWNX_Damage_AttackEventData AttackEventData)
{
    if(GetLocalInt(AttackEventData.oTarget, "IHAVEDEVASTIMMUNITY"))
        return;
    int nDC = GetHitDice(oPC)/2;
    if(GetHasFeat(FEAT_SAYANARA, oPC)) // Vorpal with DC = mod_DEX + Slayer_LVL-10 + fame_shop_bonus
        nDC = GetAbilityModifier(ABILITY_DEXTERITY, oPC) + GetLevelByClass(CLASS_TYPE_SHIFTER, oPC) - 10 + GetCustomOnhitFameBonus(oPC, SPELL_CORMYR_SAYANARA); // fameshop done
    int nRefl = players_GetRealSavingThrowValue(AttackEventData.oTarget, SAVING_THROW_REFLEX);
    int nRoll = d20();
    int nReflSave = nRefl + nRoll;
    // debug
    //if(GetPCIPAddress(oPC) == "192.168.128.100") nDC = 100;

    if(nReflSave >= nDC && nRoll != 1)
    {
        SendMessageToPC(oPC,
                        "Vorpal Hit on " + GetName(AttackEventData.oTarget) + " failed. Reflex Save :" +
                        ColorText("*success*", TXT_COLOR_GREEN_L) + " : (" + IntToString(nRoll) + " + " +
                        IntToString(nRefl) + " = " + IntToString(nReflSave) + " vs. DC: " + IntToString(nDC) + ")");
        if (GetIsPC(AttackEventData.oTarget))
            SendMessageToPC(AttackEventData.oTarget,
                            "Vorpal Hit Reflex Save : " + ColorText("*success*", TXT_COLOR_GREEN_L) +
                            " : ("+IntToString(nRoll) + " + " + IntToString(nRefl) + " = " + IntToString(nReflSave) + " vs. DC: " +
                            IntToString(nDC) + ")");
    }
    else
    {
        effect eVorpal;
        if(nRefl < nDC)
            DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, SupernaturalEffect(EffectDeath()), AttackEventData.oTarget));  // death ward dont works
        else
        {
            struct NWNX_Damage_DamageData stVorpalDamage;
            int iMagical = FloatToInt(IntToFloat(GetMaxHitPoints(AttackEventData.oTarget)) * 0.5);
            stVorpalDamage.iMagical = iMagical;
            DelayCommand(0.0, NWNX_Damage_DealDamage(stVorpalDamage, AttackEventData.oTarget, oPC));
        }

        UpdateHostileActorsList(AttackEventData.oTarget, oPC);
        //generic_PlayAudioStreamForPlayerArea(oPC, "mus_vorpal", AUDIOSTREAM_IDENTIFIER_3);
        FloatingColorTextStringOnCreature("Vorpal Hit!", TXT_COLOR_SPECIAL_HIT, oPC, TRUE);

        SendMessageToPC(oPC,
                        "Vorpal Hit on " + GetName(AttackEventData.oTarget) + " success. Reflex Save :" +
                        ColorText("*failure*", TXT_COLOR_RED) + " : (" + IntToString(nRoll) + " + "      +
                        IntToString(nRefl) + " = " + IntToString(nReflSave) + " vs. DC: " + IntToString(nDC) + ")");
        if (GetIsPC(AttackEventData.oTarget))
        {
            FloatingColorTextStringOnCreature("Vorpal Hit!", TXT_COLOR_SPECIAL_HIT, AttackEventData.oTarget, TRUE);
            SendMessageToPC(AttackEventData.oTarget,
                            "Vorpal Hit Reflex Save : " + ColorText("*failure*", TXT_COLOR_RED)  +
                            " : (" + IntToString(nRoll) + " + " + IntToString(nRefl)+" = " + IntToString(nReflSave) +
                            " vs. DC: " + IntToString(nDC) + ")");
        }
    }
}

void attack_Splash(object oPC, struct NWNX_Damage_AttackEventData AttackEventData, float fDamagePercent)
{
    // splash settings
    int nSplashChance = 100; // 100% base chance
    // end splash settings
    if(!GetIsPC(oPC))
        fDamagePercent = 1.0;

    int iFullDamage = attack_GetTotalDamage(AttackEventData);
    if (iFullDamage > 0 && d100() <= nSplashChance)
    {
        struct NWNX_Damage_DamageData stSplashDamage;

        int iPhysDamPart = FloatToInt(IntToFloat(iFullDamage)*fDamagePercent);
        stSplashDamage.iSlash = iPhysDamPart;

        location lLocation = GetLocation(AttackEventData.oTarget);
        vector vOrigin = GetPosition(oPC);

        int i = 0;
        //object oSplashTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, fSplashDistance, lLocation, FALSE, OBJECT_TYPE_CREATURE, vOrigin);
        object oSplashTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lLocation);
        while(GetIsObjectValid(oSplashTarget))
        {
            if (oSplashTarget != oPC &&  !players_GetFactionsEqual(oPC, oSplashTarget)/* friendly fire OFF */ &&
                oSplashTarget != AttackEventData.oTarget && !GetIsUnderDefyDeath(oSplashTarget))
            {
                if (!i++)
                    FloatingColorTextStringOnCreature("Splash Hit!", TXT_COLOR_SPECIAL_HIT, oPC, TRUE);
                if (GetIsPC(oSplashTarget))
                    FloatingColorTextStringOnCreature("Splash Hit!", TXT_COLOR_SPECIAL_HIT, oSplashTarget, TRUE);

                DelayCommand(0.0, NWNX_Damage_DealDamage(stSplashDamage, oSplashTarget, oPC));
            }
            //oSplashTarget = GetNextObjectInShape(SHAPE_SPELLCONE, fSplashDistance, lLocation, FALSE, OBJECT_TYPE_CREATURE, vOrigin);
            oSplashTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lLocation);
        }
    }
}

int attack_GetTotalDamage(struct NWNX_Damage_AttackEventData AttackEventData)
{
    return (AttackEventData.iBase > 0 ? AttackEventData.iBase : 0) +
           (AttackEventData.iBludgeoning > 0 ? AttackEventData.iBludgeoning : 0) +
           (AttackEventData.iPierce > 0 ? AttackEventData.iPierce : 0) +
           (AttackEventData.iSlash > 0 ? AttackEventData.iSlash : 0)  +
           (AttackEventData.iMagical > 0 ? AttackEventData.iMagical : 0) +
           (AttackEventData.iDivine > 0 ? AttackEventData.iDivine : 0)  +
           (AttackEventData.iPositive > 0 ? AttackEventData.iPositive : 0) +
           (AttackEventData.iNegative > 0 ? AttackEventData.iNegative : 0) +
           (AttackEventData.iAcid > 0 ? AttackEventData.iAcid : 0) +
           (AttackEventData.iCold > 0 ? AttackEventData.iCold : 0) +
           (AttackEventData.iElectrical > 0 ? AttackEventData.iElectrical : 0) +
           (AttackEventData.iFire > 0 ? AttackEventData.iFire : 0) +
           (AttackEventData.iSonic > 0 ? AttackEventData.iSonic : 0) +
           (AttackEventData.iCustom1 > 0 ? AttackEventData.iCustom1 : 0) +
           (AttackEventData.iCustom2 > 0 ? AttackEventData.iCustom2 : 0) +
           (AttackEventData.iCustom3 > 0 ? AttackEventData.iCustom3 : 0) +
           (AttackEventData.iCustom4 > 0 ? AttackEventData.iCustom4 : 0) +
           (AttackEventData.iCustom5 > 0 ? AttackEventData.iCustom5 : 0) +
           (AttackEventData.iCustom6 > 0 ? AttackEventData.iCustom6 : 0) +
           (AttackEventData.iCustom7 > 0 ? AttackEventData.iCustom7 : 0);
}

struct NWNX_Damage_AttackEventData attack_ModifyDamage(struct NWNX_Damage_AttackEventData AttackEventData, float fMultiplier)
{
    AttackEventData.iBludgeoning = (AttackEventData.iBludgeoning > 0) ? FloatToInt(IntToFloat(AttackEventData.iBludgeoning) * fMultiplier) : AttackEventData.iBludgeoning;
    AttackEventData.iPierce = (AttackEventData.iPierce > 0) ? FloatToInt(IntToFloat(AttackEventData.iPierce) * fMultiplier) : AttackEventData.iPierce;
    AttackEventData.iSlash = (AttackEventData.iSlash > 0) ? FloatToInt(IntToFloat(AttackEventData.iSlash) * fMultiplier) : AttackEventData.iSlash;
    AttackEventData.iMagical = (AttackEventData.iMagical > 0) ? FloatToInt(IntToFloat(AttackEventData.iMagical) * fMultiplier) : AttackEventData.iMagical;
    AttackEventData.iAcid = (AttackEventData.iAcid > 0) ? FloatToInt(IntToFloat(AttackEventData.iAcid) * fMultiplier) : AttackEventData.iAcid;
    AttackEventData.iCold = (AttackEventData.iCold > 0) ? FloatToInt(IntToFloat(AttackEventData.iCold) * fMultiplier) : AttackEventData.iCold;
    AttackEventData.iDivine = (AttackEventData.iDivine > 0) ? FloatToInt(IntToFloat(AttackEventData.iDivine) * fMultiplier) : AttackEventData.iDivine;
    AttackEventData.iElectrical = (AttackEventData.iElectrical > 0) ? FloatToInt(IntToFloat(AttackEventData.iElectrical) * fMultiplier) : AttackEventData.iElectrical;
    AttackEventData.iFire = (AttackEventData.iFire > 0) ? FloatToInt(IntToFloat(AttackEventData.iFire) * fMultiplier) : AttackEventData.iFire;
    AttackEventData.iNegative = (AttackEventData.iNegative > 0) ? FloatToInt(IntToFloat(AttackEventData.iNegative) * fMultiplier) : AttackEventData.iNegative;
    AttackEventData.iPositive = (AttackEventData.iPositive > 0) ? FloatToInt(IntToFloat(AttackEventData.iPositive) * fMultiplier) : AttackEventData.iPositive;
    AttackEventData.iSonic = (AttackEventData.iSonic > 0) ? FloatToInt(IntToFloat(AttackEventData.iSonic) * fMultiplier) : AttackEventData.iSonic;
    AttackEventData.iBase = (AttackEventData.iBase > 0) ? FloatToInt(IntToFloat(AttackEventData.iBase) * fMultiplier) : AttackEventData.iBase;
    return AttackEventData;
}

struct NWNX_Damage_AttackEventData attack_AddWMDamage(struct NWNX_Damage_AttackEventData AttackEventData, int nModifier)
{
    AttackEventData.iCustom7 = nModifier;
    return AttackEventData;
}

void attack_PureFighterDebuff(object oTarget, int nFighterLevel)
{
    if(GetHasSpellEffect(SPELL_FIGHTER_TRAUMATIC_HIT, oTarget))
        return;
    int nDodgeACDebuff = nFighterLevel / 10;
    if(nDodgeACDebuff)
    {

        effect ePureFighterDebuff = EffectACDecrease(nDodgeACDebuff);
        ePureFighterDebuff = EffectLinkEffects(EffectIcon(EFFECT_ICON_FIGHTER_TRAUMATIC_HIT),
                                               HideEffectIcon(ePureFighterDebuff));
        ePureFighterDebuff = SetEffectSpellId(ePureFighterDebuff, SPELL_FIGHTER_TRAUMATIC_HIT);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePureFighterDebuff, oTarget, 6.0f);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(GAOVFX_IMP_NEGATIVE_ENERGY_PURPLE), oTarget);
    }
}

void attack_Bleed(struct NWNX_Damage_AttackEventData AttackEventData)
{
    if(GetHasSpellEffect(SPELL_CORMYR_BLEED, AttackEventData.oTarget))
        return;
    // ==> bleed settings
    int nBleedChance = 100; // 100% base chance
    // <== bleed settings

    int iFullDamage = attack_GetTotalDamage(AttackEventData);
    if (iFullDamage > 0 && d100() <= nBleedChance)
    {
        // base bleed damage percent
        float fBleedPercent;
        // wipe phase scaled bleed damage percent
        int nWipePhase = GetLocalInt(GetModule(), CORMYREAN_WIPE_PHASE);
        if(nWipePhase == CORMYREAN_WIPE_PHASE_4)
            fBleedPercent = 0.09;
        else if(nWipePhase == CORMYREAN_WIPE_PHASE_3)
            fBleedPercent = 0.08;
        else if(nWipePhase == CORMYREAN_WIPE_PHASE_2)
            fBleedPercent = 0.07;
        else
            fBleedPercent = 0.06;
        // ==> calculate bleed damage
        // int nFullDamage = attack_GetTotalDamage(AttackEventData);
        int nTargetHP = GetMaxHitPoints(AttackEventData.oTarget);
        int nPieceDamage = FloatToInt(nTargetHP * fBleedPercent);
        if(nPieceDamage > 100)
            nPieceDamage = 100;
        // <== calculate bleed damage
        effect eBleed = EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", SPELL_CORMYR_BLEED_TICK_INTERVAL, JsonDump(JsonObjectSet(JsonObjectSet(JSON_OBJECT,"damage",JsonInt(nPieceDamage)),"pdkFinal",JsonInt(2*GetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT,OBJECT_SELF)))));
        eBleed = EffectLinkEffects(EffectIcon(EFFECT_ICON_BLEED), eBleed);
        eBleed = SetEffectSpellId(eBleed, SPELL_CORMYR_BLEED);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eBleed), AttackEventData.oTarget, SPELL_CORMYR_BLEED_DURATION);
    }
}

float attack_GetEmpoweredHitMultiplier(object oAttacker)
{
    return SPELL_CORMYR_EMPOWERED_HIT_BASE_MULTIPLIER + SPELL_CORMYR_EMPOWERED_HIT_UPGRADE_STEP * GetEmpoweredHitDamageBonus(oAttacker);
}

void attack_ExecDPSCalculator(object oPC, struct NWNX_Damage_AttackEventData AttackEventData)
{
    int nRounds = GetLocalInt(oPC, "DPS_CALCULATOR_ROUNDS");
    if(nRounds <= 0)
        return;
    if(AttackEventData.iAttackNumber == 1)
    {
        int nRoundsDone = GetLocalInt(oPC, "DPS_CALCULATOR_ROUNDS_DONE") + 1;
        SetLocalInt(oPC, "DPS_CALCULATOR_ROUNDS_DONE", nRoundsDone);
        if(nRoundsDone == 1)
            FloatingColorTextStringOnCreature("DPS Calculator on.", TXT_COLOR_GREEN_L, oPC, FALSE);
        if(nRoundsDone >= nRounds)
        {
            AssignCommand(oPC, ClearAllActions());
            FloatingColorTextStringOnCreature("DPS Calculator off.", TXT_COLOR_RED, oPC, FALSE);
            // hits
            int nMaxHitDmg       = GetLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG_MAX");
            int nMinHitDmg       = GetLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG_MIN");
            int nTotalHits       = GetLocalInt(oPC, "DPS_CALCULATOR_HIT_COUNT");
            float fAvgHitDmg     = GetLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG") / IntToFloat(
                                   nTotalHits > 0 ? nTotalHits : 1);
            // crit hits
            int nMaxCritHitDmg   = GetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG_MAX");
            int nMinCritHitDmg   = GetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG_MIN");
            int nTotatCritHits   = GetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_COUNT");
            float fAvgCritHitDmg = GetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG") / IntToFloat(
                                   nTotatCritHits > 0 ? nTotatCritHits : 1);
            // other
            float fAvgDmg = GetLocalInt(oPC, "DPS_CALCULATOR_FULL_DMG") / IntToFloat(
                            nTotalHits + nTotatCritHits > 0 ? nTotalHits + nTotatCritHits : 1);
            int nTotalDamage = GetLocalInt(oPC, "DPS_CALCULATOR_FULL_DMG");
            float fDPS = GetLocalInt(oPC, "DPS_CALCULATOR_FULL_DMG") / (nRounds * 6.0);
            int nTotalMiss = GetLocalInt(oPC, "DPS_CALCULATOR_MISS_COUNT");
            AssignCommand(oPC, DelayCommand(1.0,
                SendMessageToPC(oPC, ColorText("    DPS Calculator Results:\n", TXT_COLOR_GREEN_L) +
                    "Max Hit Damage: " + ColorText(IntToString(nMaxHitDmg), TXT_COLOR_WHITE_T) + "\n" +
                    "Min Hit Damage: " + ColorText(IntToString(nMinHitDmg), TXT_COLOR_WHITE_T) + "\n" +
                    "Avg Hit Damage: " + ColorText(FloatToString(fAvgHitDmg, 4, 2), TXT_COLOR_WHITE_T)  + "\n" +
                    "Max Critical Hit Damage: " + ColorText(IntToString(nMaxCritHitDmg), TXT_COLOR_WHITE_T) + "\n" +
                    "Min Critical Hit Damage: " + ColorText(IntToString(nMinCritHitDmg), TXT_COLOR_WHITE_T) + "\n" +
                    "Avg Critical Hit Damage: " + ColorText(FloatToString(fAvgCritHitDmg, 4, 2), TXT_COLOR_WHITE_T) + "\n" +
                    "Avg Damage: " + ColorText(FloatToString(fAvgDmg, 4, 2), TXT_COLOR_WHITE_T) + "\n" +
                    "Total Damage: " + ColorText(IntToString(nTotalDamage), TXT_COLOR_WHITE_T) + "\n" +
                    "DPS: " + ColorText(FloatToString(fDPS, 4, 2), TXT_COLOR_WHITE_T) + "\n" +
                    "Total Hits: " + ColorText(IntToString(nTotalHits), TXT_COLOR_WHITE_T) + "\n" +
                    "Total Critical Hits: " + ColorText(IntToString(nTotatCritHits), TXT_COLOR_WHITE_T) + "\n" +
                    "Total Misses: " + ColorText(IntToString(nTotalMiss), TXT_COLOR_WHITE_T)
                    )
                )
            );
            // clear locals
            DeleteLocalInt(oPC, "DPS_CALCULATOR_ON");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_ROUNDS");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_ROUNDS_DONE");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_FULL_DMG");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_HIT_COUNT");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG_MIN");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG_MAX");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_COUNT");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG_MIN");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG_MAX");
            DeleteLocalInt(oPC, "DPS_CALCULATOR_MISS_COUNT");
            return;
        }
    }
    int nDamage = attack_GetTotalDamage(AttackEventData);
    SetLocalInt(oPC, "DPS_CALCULATOR_FULL_DMG", GetLocalInt(oPC, "DPS_CALCULATOR_FULL_DMG") + nDamage);
    switch(AttackEventData.iAttackResult)
    {
        case 1: // hit
        {
            SetLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG", GetLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG") + nDamage);
            SetLocalInt(oPC, "DPS_CALCULATOR_HIT_COUNT", GetLocalInt(oPC, "DPS_CALCULATOR_HIT_COUNT") + 1);
            int nDmgMin = GetLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG_MIN");
            if(!nDmgMin || nDamage < nDmgMin)
                SetLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG_MIN", nDamage);
            int nDmgMax = GetLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG_MAX");
            if(nDamage > nDmgMax)
                SetLocalInt(oPC, "DPS_CALCULATOR_HIT_DMG_MAX", nDamage);
        }
        break;
        case 3: // critical hit
        {
            SetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG", GetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG") + nDamage);
            SetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_COUNT", GetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_COUNT") + 1);
            int nDmgMin = GetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG_MIN");
            if(!nDmgMin || nDamage < nDmgMin)
                SetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG_MIN", nDamage);
            int nDmgMax = GetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG_MAX");
            if(nDamage > nDmgMax)
                SetLocalInt(oPC, "DPS_CALCULATOR_CRIT_HIT_DMG_MAX", nDamage);
        }
        break;
        case 4: // miss
            SetLocalInt(oPC, "DPS_CALCULATOR_MISS_COUNT", GetLocalInt(oPC, "DPS_CALCULATOR_MISS_COUNT") + 1);
        break;

    }
}

void attack_ApplyMicroBash(object oAttacker, object oTarget)
{
    // dont apply if target has KD effect, cos stun cancels KD
    if(spells_GetHasTrueEffect(oTarget, EFFECT_TRUE_TYPE_KNOCKDOWN) || spells_GetHasTrueEffect(oTarget, EFFECT_TRUE_TYPE_SETAISTATE))
        return;
    int nSpellDC = GetHitDice(oAttacker)/2;
    //Make a fortitude save
    if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nSpellDC, SAVING_THROW_TYPE_NONE, oAttacker))
    {
        RemoveEffectsFromSpell(oTarget, SPELL_CORMYR_MICROBASH);

        effect eStun = IgnoreEffectImmunity(EffectStunned());
        eStun = SetEffectSpellId(eStun, SPELL_CORMYR_MICROBASH);
        float fDuration = 0.3;
        effect eVis = EffectVisualEffect(PRCVFX_IMP_MAGRED_1);

        if (GetIsPC(oAttacker))
            FloatingColorTextStringOnCreature("Microbash Hit!", TXT_COLOR_SPECIAL_HIT, oAttacker, TRUE);
        if (GetIsPC(oTarget))
            FloatingColorTextStringOnCreature("Microbash Hit!", TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);

        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStun, oTarget, fDuration);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }
}

void attack_ApplyPlague(object oAttacker, object oTarget)
{
    int nSpellDC = GetHitDice(oAttacker)/2;

    //Make a fortitude save
    if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nSpellDC, SAVING_THROW_TYPE_NONE, oAttacker))
    {
        RemoveEffectsFromSpell(oTarget, SPELL_CORMYR_PLAGUE);

        effect ePlague = EffectIcon(EFFECT_ICON_PLAGUE);
        ePlague = SetEffectSpellId(ePlague, SPELL_CORMYR_PLAGUE);
        float fDuration = 12.0;
        effect eVis = EffectVisualEffect(PRCVFX_IMP_MAGRED_1);

        if (GetIsPC(oAttacker))
            FloatingColorTextStringOnCreature("Plague Hit!", TXT_COLOR_SPECIAL_HIT, oAttacker, TRUE);
        if (GetIsPC(oTarget))
            FloatingColorTextStringOnCreature("Plague Hit!", TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);

        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePlague, oTarget, fDuration);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }
}

#include "nwnx_damage"
#include "_inc_champ_boss"
#include "_inc_areas"
#include "_inc_runes"
#include "_inc_obelisk"
#include "_inc_guard_spawn"
#include "_inc_pulse_rage"
#include "_inc_fshop_bg"
#include "_inc_war_class"

void printdamage(object oDamager, struct NWNX_Damage_DamageEventData data)
{
    SendMessageToPC(oDamager, "iBludgeoning: " + IntToString(data.iBludgeoning));
    SendMessageToPC(oDamager, "iPierce: " + IntToString(data.iPierce));
    SendMessageToPC(oDamager, "iSlash: " + IntToString(data.iSlash));
    SendMessageToPC(oDamager, "iMagical: " + IntToString(data.iMagical));
    SendMessageToPC(oDamager, "iAcid: " + IntToString(data.iAcid));
    SendMessageToPC(oDamager, "iCold: " + IntToString(data.iCold));
    SendMessageToPC(oDamager, "iDivine: " + IntToString(data.iDivine));
    SendMessageToPC(oDamager, "iElectrical: " + IntToString(data.iElectrical));
    SendMessageToPC(oDamager, "iFire: " + IntToString(data.iFire));
    SendMessageToPC(oDamager, "iNegative: " + IntToString(data.iNegative));
    SendMessageToPC(oDamager, "iPositive: " + IntToString(data.iPositive));
    SendMessageToPC(oDamager, "iSonic: " + IntToString(data.iSonic));
    SendMessageToPC(oDamager, "iBase: " + IntToString(data.iBase));
}

    // So:
    //  - Set the numbers to -1 to hide them from the combat log
    //  - Set them to 0 to have them reported as 0
    //  - Set them to other positive numbers to change the damage values as you see fit.

struct NWNX_Damage_DamageEventData damage_ModifyDamage(struct NWNX_Damage_DamageEventData stDamageData, float fMultiplier);

//
int damage_GetTotalDamage(struct NWNX_Damage_DamageEventData stDamageData);

//
void damage_ProcessEvilBlight(object oTarget, int nTotalDamage);

//
struct NWNX_Damage_DamageEventData damage_AddRendDamage(struct NWNX_Damage_DamageEventData stDamageData, int nRendStacks);

//
void damage_StoreDPS(object oDamager, object oTarget, int nDamage);

void main()
{
    // Get all the data of the damage event
    struct NWNX_Damage_DamageEventData stDamageData = NWNX_Damage_GetDamageEventData();

    object oDamager = stDamageData.oDamager; // The damager
    object oTarget = OBJECT_SELF;    // The creature receiving the damage

    //printdamage(oDamager, stDamageData);

    int nObjType = GetObjectType(oTarget);
    switch(nObjType)
    {
        case OBJECT_TYPE_PLACEABLE:
        {
            // >>> obelisks handler
            if (FindSubString(GetTag(oTarget), OBELISK_PLACEBLE_PREFIX) >= 0 &&
                !obelisk_GetIsReadyToReceiveDamage(oTarget, damage_GetTotalDamage(stDamageData), players_GetFaction(oDamager)))
                    stDamageData = damage_ModifyDamage(stDamageData, 0.0);
            // >>> portals handler
            if     (GetResRef(oTarget) == "plc_dimdoor" && !(NWNX_Object_GetAppearance(oTarget) == 4308 /* instanse door */ && GetLocalInt(oTarget,  "VAR_PORTAL_EXIT")))
                spells_ClosePortals(GetTag(oTarget), 0.0);
            else if(GetResRef(oTarget) == "plc_stargate")
                spells_CloseStargate(oTarget, 0.0);
        }
        break;
        case OBJECT_TYPE_CREATURE:
        {
            /////////////////////////////////// all damage increase events ///////////////////////////////////

            // >>> boss scaling
            if (champion_GetIsBoss(oDamager))
            {
                // >>> boss damage scaling
                if(!GetLocalInt(oDamager, "HEAL_AND_RAGE_ACTIVATED") &&
                   !(GetLocalObject(oDamager, "TARGET_UNDER_ULTIMATE") == oTarget) &&
                   SQLite_GetTimeStamp() - SQLocals_GetLastUpdated_UnixEpoch(oDamager, "BOSS_SPELL_DAMAGE_SCALING_BLOCK", SQLOCALS_TYPE_INT) > 3)
                {
                    float fCorrection   = IntToFloat(areas_GetNumberOfPlayersInArea(GetArea(oDamager), FALSE)) - 1.0;
                    float fDPScoeff     = sqrt((fCorrection >= 2.0) ? fCorrection : 1.0);

                    if ((GetLevelByClass(CLASS_TYPE_PALE_MASTER, oTarget) || GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oTarget)) && fDPScoeff < 2.0)
                        fDPScoeff = 2.0;
                    stDamageData = damage_ModifyDamage(stDamageData, fDPScoeff);
                } // <<< boss damage scaling
            }

            // >>> Rend damage boost
            int nRendStacks = GetLocalInt(oTarget, IntToString(SPELL_REND) + "_STACKS");
            if(nRendStacks && stDamageData.iBase > 0)
                stDamageData = damage_AddRendDamage(stDamageData, nRendStacks);

            // madness buff
            int nMadnessStacksBuff = GetLocalInt(oDamager, IntToString(SPELL_MADNESS) + "_STACKS");
                stDamageData = damage_ModifyDamage(stDamageData, 1.0 + nMadnessStacksBuff * 0.07);

            /////////////////////////////////////// damage-based systems  ////////////////////////////////////

            // >>> assist system
            object oMaster = GetIsObjectValid(GetMaster(oDamager)) ? GetMaster(oDamager) : oDamager;
            if (GetIsPC(oTarget) && GetIsPC(oMaster) && oTarget != oMaster && !players_GetFactionsEqual(oTarget, oMaster))
                UpdateHostileActorsList(oTarget, oMaster);

            /////////////////////////////////// all damage decrease events ///////////////////////////////////

            // >>> apply weaken
            int nWeakenStack = GetLocalInt(oDamager, IntToString(SPELL_WEAKEN) + "_STACKS");
            if(nWeakenStack)
               stDamageData = damage_ModifyDamage(stDamageData, 1.0 - 0.07 * nWeakenStack); // -7% to dmg per stack

            // >>> threatening cry
            if(!champion_GetIsBoss(oDamager) && GetLocalFloat(oDamager, "THREATENING_CRY_MULTIPLIER") > 0.0)
                stDamageData = damage_ModifyDamage(stDamageData, GetLocalFloat(oDamager, "THREATENING_CRY_MULTIPLIER")); // -20% max

            ////////////////////////////////// all damage nullifiers events //////////////////////////////////

            // >>> process captains and guards damage
            if((guard_GetIsCaptain(oTarget) && players_GetFaction(oDamager) == players_GetFaction(oTarget) && IntToFloat(GetCurrentHitPoints(oTarget))/IntToFloat(GetMaxHitPoints(oTarget)) >= 0.25) ||
                !GetIsPC(oDamager) && GetIsPC(oTarget) && players_GetFaction(oDamager) == players_GetFaction(oTarget))
            {
                stDamageData = damage_ModifyDamage(stDamageData, 0.0);
            }

            // >>> process barbarian defy death
            if(!GetHasSpellEffect(SPELL_BARBARIAN_DEFY_DEATH, oTarget) && // barbarian is under CD
               GetIsInRage(oTarget) && // barbarian is in rage
               GetHasFeat(FEAT_BARBARIAN_DEFY_DEATH, oTarget) &&
               GetCurrentHitPoints(oTarget) - damage_GetTotalDamage(stDamageData) <= 0 // barbarian received fatal damage
              )
            {
                AssignCommand(oTarget, NWNX_Creature_DoItemCastSpell(oTarget, oTarget, LOCATION_INVALID, SPELL_BARBARIAN_DEFY_DEATH, GetHitDice(oTarget), 0.0));
                generic_PlayAudioStreamForPlayerArea(oTarget, "mus_invul");
                stDamageData = damage_ModifyDamage(stDamageData, 0.0);
            }
            ///////////////////////////////////// damage-based abilities events //////////////////////////////

            int nTotalDamage = damage_GetTotalDamage(stDamageData);

            // >>> BG Evil Blight
            if(GetHasSpellEffect(SPELL_EVIL_BLIGHT, oTarget))
                damage_ProcessEvilBlight(oTarget, nTotalDamage);

            // >>> DD Kings Power
            if(GetLocalInt(oTarget, WARLORD_FURY_ACTIVE_FLAG) && (players_GetFaction(oDamager) > 0 && !players_GetFactionsEqual(oTarget, oDamager) || champion_GetIsBoss(oDamager)))
                UpdateWarlordsFuryBonusesCounter(oTarget, nTotalDamage);
            // >>> DD Dwarven Legacy
            if(GetHasSpellEffect(SPELL_BATTLEFIELD_ECHO, oTarget))
                UpdateBattlefieldEchoBonusesCounter(oTarget, nTotalDamage);
            // >>> DD Dwarven Defence
            if(GetLocalInt(oTarget, WARLORD_GUARD_ACTIVE_FLAG) && (players_GetFaction(oDamager) > 0 && !players_GetFactionsEqual(oTarget, oDamager) || champion_GetIsBoss(oDamager)))
                UpdateWarlordsGuardBonusesCounter(oTarget, oDamager, nTotalDamage);

            // >>> top-3 dmg
            if(GetIsPC(oDamager))
                damage_StoreDPS(oDamager, oTarget, nTotalDamage);

            // madness debuff
            int nMadnessStacksDebuff = GetLocalInt(oTarget, IntToString(SPELL_MADNESS) + "_STACKS");
            if(nMadnessStacksDebuff)
                stDamageData = damage_ModifyDamage(stDamageData, 1.0 + nMadnessStacksDebuff * 0.05);

        }
        break;
    }
    // Send the modified damages to nwnx
    NWNX_Damage_SetDamageEventData(stDamageData);
    ExecuteScript("pdkl_damage", OBJECT_SELF);
    stDamageData=NWNX_Damage_GetDamageEventData();
}

struct NWNX_Damage_DamageEventData damage_ModifyDamage(struct NWNX_Damage_DamageEventData stDamageData, float fMultiplier)
{
    stDamageData.iBludgeoning = (stDamageData.iBludgeoning > 0) ? FloatToInt(stDamageData.iBludgeoning * fMultiplier) : stDamageData.iBludgeoning;
    stDamageData.iPierce = (stDamageData.iPierce > 0) ? FloatToInt(stDamageData.iPierce * fMultiplier) : stDamageData.iPierce;
    stDamageData.iSlash = (stDamageData.iSlash > 0) ? FloatToInt(stDamageData.iSlash * fMultiplier) : stDamageData.iSlash;
    stDamageData.iMagical = (stDamageData.iMagical > 0) ? FloatToInt(stDamageData.iMagical * fMultiplier) : stDamageData.iMagical;
    stDamageData.iAcid = (stDamageData.iAcid > 0) ? FloatToInt(stDamageData.iAcid * fMultiplier) : stDamageData.iAcid;
    stDamageData.iCold = (stDamageData.iCold > 0) ? FloatToInt(stDamageData.iCold * fMultiplier) : stDamageData.iCold;
    stDamageData.iDivine = (stDamageData.iDivine > 0) ? FloatToInt(stDamageData.iDivine * fMultiplier) : stDamageData.iDivine;
    stDamageData.iElectrical = (stDamageData.iElectrical > 0) ? FloatToInt(stDamageData.iElectrical * fMultiplier) : stDamageData.iElectrical;
    stDamageData.iFire = (stDamageData.iFire > 0) ? FloatToInt(stDamageData.iFire * fMultiplier) : stDamageData.iFire;
    stDamageData.iNegative = (stDamageData.iNegative > 0) ? FloatToInt(stDamageData.iNegative * fMultiplier) : stDamageData.iNegative;
    stDamageData.iPositive = (stDamageData.iPositive > 0) ? FloatToInt(stDamageData.iPositive * fMultiplier) : stDamageData.iPositive;
    stDamageData.iSonic = (stDamageData.iSonic > 0) ? FloatToInt(stDamageData.iSonic * fMultiplier) : stDamageData.iSonic;
    stDamageData.iBase = (stDamageData.iBase > 0) ? FloatToInt(stDamageData.iBase * fMultiplier) : stDamageData.iBase;
    stDamageData.iCustom1 = (stDamageData.iCustom1 > 0) ? FloatToInt(stDamageData.iCustom1 * fMultiplier) : stDamageData.iCustom1;
    stDamageData.iCustom2 = (stDamageData.iCustom2 > 0) ? FloatToInt(stDamageData.iCustom2 * fMultiplier) : stDamageData.iCustom2;
    stDamageData.iCustom3 = (stDamageData.iCustom3 > 0) ? FloatToInt(stDamageData.iCustom3 * fMultiplier) : stDamageData.iCustom3;
    stDamageData.iCustom4 = (stDamageData.iCustom4 > 0) ? FloatToInt(stDamageData.iCustom4 * fMultiplier) : stDamageData.iCustom4;
    stDamageData.iCustom5 = (stDamageData.iCustom5 > 0) ? FloatToInt(stDamageData.iCustom5 * fMultiplier) : stDamageData.iCustom5;
    stDamageData.iCustom6 = (stDamageData.iCustom6 > 0) ? FloatToInt(stDamageData.iCustom6 * fMultiplier) : stDamageData.iCustom6;
    stDamageData.iCustom7 = (stDamageData.iCustom7 > 0) ? FloatToInt(stDamageData.iCustom7 * fMultiplier) : stDamageData.iCustom7;

    return stDamageData;
}

int damage_GetTotalDamage(struct NWNX_Damage_DamageEventData stDamageData)
{
    return (stDamageData.iBase > 0 ? stDamageData.iBase : 0) +
           (stDamageData.iBludgeoning > 0 ? stDamageData.iBludgeoning : 0) +
           (stDamageData.iPierce > 0 ? stDamageData.iPierce : 0) +
           (stDamageData.iSlash > 0 ? stDamageData.iSlash : 0)  +
           (stDamageData.iMagical > 0 ? stDamageData.iMagical : 0) +
           (stDamageData.iDivine > 0 ? stDamageData.iDivine : 0)  +
           (stDamageData.iPositive > 0 ? stDamageData.iPositive : 0) +
           (stDamageData.iNegative > 0 ? stDamageData.iNegative : 0) +
           (stDamageData.iAcid > 0 ? stDamageData.iAcid : 0) +
           (stDamageData.iCold > 0 ? stDamageData.iCold : 0) +
           (stDamageData.iElectrical > 0 ? stDamageData.iElectrical : 0) +
           (stDamageData.iFire > 0 ? stDamageData.iFire : 0) +
           (stDamageData.iSonic > 0 ? stDamageData.iSonic : 0) +
           (stDamageData.iCustom1 > 0 ? stDamageData.iCustom1 : 0) +
           (stDamageData.iCustom2 > 0 ? stDamageData.iCustom2 : 0) +
           (stDamageData.iCustom3 > 0 ? stDamageData.iCustom3 : 0) +
           (stDamageData.iCustom4 > 0 ? stDamageData.iCustom4 : 0) +
           (stDamageData.iCustom5 > 0 ? stDamageData.iCustom5 : 0) +
           (stDamageData.iCustom6 > 0 ? stDamageData.iCustom6 : 0) +
           (stDamageData.iCustom7 > 0 ? stDamageData.iCustom7 : 0);
}

void damage_ProcessEvilBlight(object oTarget, int nTotalDamage)
{
    effect eLoop = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eLoop))
    {
        object oCreator = GetEffectCreator(eLoop);
        if(GetEffectSpellId(eLoop) == SPELL_EVIL_BLIGHT && oCreator != oTarget)
        {
            int nBGLevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD, oCreator);
            int  nMaxBonus = nBGLevel / 7;
            json jCash = GetLocalJson(GetModule(), JSON_VAR_EVIL_BLIGHT_DATA + "_" + ObjectToString(oCreator));
            int nDamage = JsonGetInt(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_DAMAGE)) + nTotalDamage;
            // Taunt
            int nTaunt = nDamage / BG_EVIL_BLIGHT_BONUSES_STEP;
            int nTauntFameBonus = fshop_bg_GetIsBitActivated(oCreator, FAMESHOP_BG_EVIL_BLIGHT_BONUS_TAUNT_1) > 0;
            nTaunt = nTaunt > nMaxBonus + nTauntFameBonus ? nMaxBonus + nTauntFameBonus : nTaunt;
            // SF Taunt
            int nSFTaunt = nDamage / BG_EVIL_BLIGHT_BONUSES_STEP;
            int nSFTauntFameBonus = fshop_bg_GetIsBitActivated(oCreator, FAMESHOP_BG_EVIL_BLIGHT_BONUS_SF_1) > 0;
            nSFTaunt = nSFTaunt > nMaxBonus + nSFTauntFameBonus ? nMaxBonus + nSFTauntFameBonus: nSFTaunt;
            // AB
            int nAB = nDamage / BG_EVIL_BLIGHT_BONUSES_STEP;
            int nABFameBonus = fshop_bg_GetIsBitActivated(oCreator, FAMESHOP_BG_EVIL_BLIGHT_BONUS_AB_1) > 0;
            nAB = nAB > nMaxBonus + nABFameBonus ? nMaxBonus + nABFameBonus: nAB;
            // Duration
            float fDuration = 10.0 * (nDamage / BG_EVIL_BLIGHT_BONUSES_STEP);
            // update json
            JsonObjectSetInplace(jCash, JSON_KEY_EVIL_BLIGHT_AB, JsonInt(nAB));
            JsonObjectSetInplace(jCash, JSON_KEY_EVIL_BLIGHT_TAUNT, JsonInt(nTaunt));
            JsonObjectSetInplace(jCash, JSON_KEY_EVIL_BLIGHT_SF_TAUNT, JsonInt(nSFTaunt));
            JsonObjectSetInplace(jCash, JSON_KEY_EVIL_BLIGHT_DAMAGE, JsonInt(nDamage));
            JsonObjectSetInplace(jCash, JSON_KEY_EVIL_BLIGHT_DURATION, JsonFloat(fDuration));
            SetLocalJson(GetModule(), JSON_VAR_EVIL_BLIGHT_DATA + "_" + ObjectToString(oCreator), jCash);
        }
        eLoop = GetNextEffect(oTarget);
    }
}

struct NWNX_Damage_DamageEventData damage_AddRendDamage(struct NWNX_Damage_DamageEventData stDamageData, int nRendStacks)
{
    int nBaseDamage = stDamageData.iBase;
    int nPercent = 3 * nRendStacks;
    int nRendBonus = FloatToInt(IntToFloat(nBaseDamage) * IntToFloat(nPercent) / 100.0);
    // apply as blood dmg
    stDamageData.iCustom1 = (stDamageData.iCustom1 > 0) ? stDamageData.iCustom1 + nRendBonus : nRendBonus;
    return stDamageData;
}

void damage_StoreDPS(object oDamager, object oTarget, int nDamage)
{
    json jStoredDamage = GetLocalJson(oTarget, "JSON_STORED_DPS_VALUE");
    json jStoredFaction = GetLocalJson(oTarget, "JSON_STORED_DPS_FACTION");
    if(JsonGetType(jStoredDamage) == JSON_TYPE_NULL)
    {
        jStoredDamage = JSON_OBJECT;
        jStoredFaction = JSON_OBJECT;
    }
    string sName = NWNX_Util_StripColors(GetName(oDamager));
    int nTotalDamage = JsonGetInt(JsonObjectGet(jStoredDamage, sName)) + nDamage;
    JsonObjectSetInplace(jStoredDamage, sName, JsonInt(nTotalDamage));
    JsonObjectSetInplace(jStoredFaction, sName, JsonInt(players_GetFaction(oDamager)));
    SetLocalJson(oTarget, "JSON_STORED_DPS_VALUE", jStoredDamage);
    SetLocalJson(oTarget, "JSON_STORED_DPS_FACTION", jStoredFaction);
}

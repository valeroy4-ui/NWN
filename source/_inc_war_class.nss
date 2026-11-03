#include "_inc_fameshop"
#include "_inc_players"
#include "_inc_champ_boss"
#include "nwnx_damage"

///////////////////////////////////////////////////////////////////
//////////                  Constants                    //////////
///////////////////////////////////////////////////////////////////

//////////////////// Warlord Fury Settings ////////////////////////

const string JSON_WARLORD_FURY_BONUSES            = "JSON_WARLORD_FURY_BONUSES";
const string WARLORD_FURY_ACTIVE_FLAG             = "WARLORD_FURY_ACTIVE_FLAG";

const string WARLORD_FURY_KEY_AB                  = "WARLORD_FURY_KEY_AB";
const string WARLORD_FURY_KEY_NEGATIVE            = "WARLORD_FURY_KEY_NEGATIVE";
const string WARLORD_FURY_KEY_CRIT_RANGE          = "WARLORD_FURY_KEY_CRIT_RANGE";
const string WARLORD_FURY_KEY_DURATION            = "WARLORD_FURY_KEY_DURATION";
const string WARLORD_FURY_KEY_TICK                = "WARLORD_FURY_KEY_TICK";
const string WARLORD_FURY_KEY_INCOME_DAMAGE       = "WARLORD_FURY_KEY_INCOME_DAMAGE";

const int WARLORD_FURY_BONUSES_STEP               = 500; // damage per bonuses increase
const int WARLORD_FURY_MAX_CRITICAL_RANGE         = 2;   // max crit range
const int WARLORD_FURY_DURATION                   = 180; // base duration seconds
const int WARLORD_FURY_DURATION_BONUS             = 10;  // bonus duration seconds
const int WARLORD_FURY_TICK_INTERVAL              = 3;   // tick interval seconds

/////////////////// Battlefield Echo Settings /////////////////////

const string JSON_BATTLEFIELD_ECHO_BONUSES         = "JSON_BATTLEFIELD_ECHO_BONUSES";

const string BATTLEFIELD_ECHO_KEY_AB               = "BATTLEFIELD_ECHO_KEY_AB";
const string BATTLEFIELD_ECHO_KEY_TAUNT            = "BATTLEFIELD_ECHO_KEY_TAUNT";
const string BATTLEFIELD_ECHO_KEY_SF               = "BATTLEFIELD_ECHO_KEY_SF";
const string BATTLEFIELD_ECHO_KEY_DURATION         = "BATTLEFIELD_ECHO_KEY_DURATION";
const string BATTLEFIELD_ECHO_KEY_TICK             = "BATTLEFIELD_ECHO_KEY_TICK";
const string BATTLEFIELD_ECHO_KEY_INCOME_DAMAGE    = "BATTLEFIELD_ECHO_KEY_INCOME_DAMAGE";

const int BATTLEFIELD_ECHO_BONUSES_STEP            = 1000; // damage per bonuses increase
const int BATTLEFIELD_ECHO_DURATION                = 180; // base duration seconds
const int BATTLEFIELD_ECHO_DURATION_BONUS          = 10;  // bonus duration seconds
const int BATTLEFIELD_ECHO_TICK_INTERVAL           = 3;   // tick interval seconds

//////////////////////// Warlord Guard ////////////////////////////

const string JSON_WARLORD_GUARD_BONUSES         = "JSON_WARLORD_GUARD_BONUSES";
const string WARLORD_GUARD_ACTIVE_FLAG          = "WARLORD_GUARD_ACTIVE_FLAG";

const string WARLORD_GUARD_KEY_AB               = "WARLORD_GUARD_KEY_AB";
const string WARLORD_GUARD_KEY_IMMUNITY         = "WARLORD_GUARD_KEY_IMMUNITY";
const string WARLORD_GUARD_KEY_DURATION         = "WARLORD_GUARD_KEY_DURATION";
const string WARLORD_GUARD_KEY_TICK             = "WARLORD_GUARD_KEY_TICK";
const string WARLORD_GUARD_KEY_REFLECTED_DAMAGE = "WARLORD_GUARD_KEY_REFLECTED_DAMAGE";

const int WARLORD_GUARD_IMMUNITY_STEP           = 250; // damage per bonuses increase
const int WARLORD_GUARD_DURATION_STEP           = 500; // damage per bonuses increase
const int WARLORD_GUARD_DURATION                = 180; // base duration seconds
const int WARLORD_GUARD_DURATION_BONUS          = 10;  // bonus duration seconds
const int WARLORD_GUARD_TICK_INTERVAL           = 3;   // tick interval seconds

const int POSTSTRING_START_POSITION_ABILITIES_X = 1;
const int POSTSTRING_START_POSITION_ABILITIES_Y = 3;


////////////////////// Fameshop Upgrades //////////////////////////

const string WARLORD_UPGRADES_CASH = "WARLORD_UPGRADES_CASH";

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

/////////////////////// Common Functions //////////////////////////

//
void ApplyVfxForActiveAbility(object oPC, int nSpellId);

//
void WarlordRemoveAllActiveSpells(object oPC);

////////////////////////// Warlord Fury ////////////////////////////

//
void UpdateWarlordsFuryBonusesCounter(object oPC, int nIncomeDamage);

//
void ApplyWarlordsFury(object oCaster, int nSpellId);

//
void RunScriptWarlordsFuryApply(object oCaster);

//
void RunScriptWarlordsFuryTick(object oCaster);

//////////////////////// Battlefield Echo //////////////////////////

//
void ApplyBattlefieldEcho(object oCaster, int nSpellId, float fRange, location lLoc);

//
void UpdateBattlefieldEchoBonusesCounter(object oTarget, int nIncomeDamage);

//
void RunScriptBattlefieldEchoApply(object oCaster);

//
void RunScriptBattlefieldEchoTick(object oCaster);

//////////////////////// Warlord Guard ////////////////////////////

//
void ApplyWarlordsGuard(object oCaster, int nSpellId);

//
void UpdateWarlordsGuardBonusesCounter(object oPC, object oTarget, int nIncomeDamage);

//
void RunScriptWarlordsGuardApply(object oCaster);

//
void RunScriptWarlordsGuardTick(object oCaster);

////////////////////// Fameshop Upgrades //////////////////////////

//
void WarlordFameshopRefreshTokens(object oPC);

//
int WarlordFameshopGetIsBitActivated(object oPC, int nUpgradeBit);

//
int WarlordFameshopActivateBit(object oPC, int nUpgradeBit);

//
int WarlordFameshopTryToActivateBit(object oPC, int nUpgradeBit, int nCost);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

/////////////////////// Common Functions //////////////////////////

void ApplyVfxForActiveAbility(object oPC, int nSpellId)
{
    int nVfx;
    switch(nSpellId)
    {
        case SPELL_WARLORD_FURY:     nVfx = GAOVFX_IMP_POLYMORPH_BLUE;  break;
        case SPELL_BATTLEFIELD_ECHO: nVfx = GAOVFX_IMP_POLYMORPH_RED;   break;
        case SPELL_WARLORD_GUARD:    nVfx = GAOVFX_IMP_POLYMORPH_GREEN; break;
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(nVfx), oPC);
}

void WarlordRemoveAllActiveSpells(object oPC)
{
    if(!GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oPC))
        return;
    // remove all spells + BG evil blight
    object oTarget = GetFirstPC();
    while(GetIsObjectValid(oTarget))
    {
        spells_RemoveAllCreatorsEffects(oTarget, oPC, SPELL_WARLORD_FURY);
        spells_RemoveAllCreatorsEffects(oTarget, oPC, SPELL_BATTLEFIELD_ECHO);
        spells_RemoveAllCreatorsEffects(oTarget, oPC, SPELL_WARLORD_GUARD);
        spells_RemoveAllCreatorsEffects(oTarget, oPC, SPELL_EVIL_BLIGHT);
        oTarget = GetNextPC();
    }
    // clear poststring
    PostString(oPC, "",  POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y,     SCREEN_ANCHOR_TOP_LEFT, 0.01f, 0xFFFFFFFF, 0xFFFFFF00, 1);
    PostString(oPC, "",  POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 1, SCREEN_ANCHOR_TOP_LEFT, 0.01f, 0xFFFFFFFF, 0xFFFFFF00, 2);
    PostString(oPC, "",  POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 2, SCREEN_ANCHOR_TOP_LEFT, 0.01f, 0xFFFFFFFF, 0xFFFFFF00, 3);
    PostString(oPC, "",  POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 3, SCREEN_ANCHOR_TOP_LEFT, 0.01f, 0xFFFFFFFF, 0xFFFFFF00, 4);
    PostString(oPC, "",  POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 4, SCREEN_ANCHOR_TOP_LEFT, 0.01f, 0xFFFFFFFF, 0xFFFFFF00, 5);
    // clear subspells
    RemoveEffectsFromSpell(oPC, SPELL_WARLORD_FURY_BONUSES);
    RemoveEffectsFromSpell(oPC, SPELL_BATTLEFIELD_ECHO_BONUSES);
    RemoveEffectsFromSpell(oPC, SPELL_WARLORD_GUARD_BONUSES);
    // clear crit range used by by Warlord Fury
    NWNX_Creature_SetCriticalRangeModifier(oPC, 0, 0);
    // clear used local vars by Warlord Fury
    DeleteLocalInt(oPC, WARLORD_FURY_ACTIVE_FLAG);
    DeleteLocalJson(oPC, JSON_WARLORD_FURY_BONUSES);
    // clear Battlefield Echo local vars
    DeleteLocalJson(GetModule(), JSON_BATTLEFIELD_ECHO_BONUSES + "_" + ObjectToString(oPC));
    // clear Warlords Guard vars
    DeleteLocalInt(oPC, WARLORD_GUARD_ACTIVE_FLAG);
    DeleteLocalJson(oPC, JSON_WARLORD_GUARD_BONUSES);
}

////////////////////////// Warlord Fury ///////////////////////////

void UpdateWarlordsFuryBonusesCounter(object oPC, int nIncomeDamage)
{
    json jBonuses = GetLocalJson(oPC, JSON_WARLORD_FURY_BONUSES);
    // get stored damage and calc total
    int nStoredDamage = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_FURY_KEY_INCOME_DAMAGE));
    int nTotalIncomeDamage = nStoredDamage + nIncomeDamage;
    // store total damage
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_INCOME_DAMAGE, JsonInt(nTotalIncomeDamage));
    // get DD level
    int nDDLevel = GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oPC);
    // calc attack bonus
    int nAttackBonus = nTotalIncomeDamage / WARLORD_FURY_BONUSES_STEP;
    int nMaxAttackBonus = nDDLevel / 10 + WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_FURY_AB_1) +
                                          WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_FURY_AB_2);
    nAttackBonus = nAttackBonus > nMaxAttackBonus ? nMaxAttackBonus : nAttackBonus;
    // calc negative damage
    int nNegativeDamage = (nTotalIncomeDamage / WARLORD_FURY_BONUSES_STEP) * 5;
    int nMaxNegativeDamage = nDDLevel;
    nNegativeDamage = nNegativeDamage > nMaxNegativeDamage ? nMaxNegativeDamage : nNegativeDamage;
    // calc critical range
    int nCriticalRange = nTotalIncomeDamage / WARLORD_FURY_BONUSES_STEP;
    nCriticalRange = nCriticalRange > WARLORD_FURY_MAX_CRITICAL_RANGE ? WARLORD_FURY_MAX_CRITICAL_RANGE : nCriticalRange;
    // calc duration bonus
    int nDur = (nTotalIncomeDamage / WARLORD_FURY_BONUSES_STEP) * WARLORD_FURY_DURATION_BONUS;
    // store calculated
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_AB, JsonInt(nAttackBonus));
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_NEGATIVE, JsonInt(nNegativeDamage));
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_CRIT_RANGE, JsonInt(nCriticalRange));
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_DURATION, JsonInt(nDur));
    SetLocalJson(oPC, JSON_WARLORD_FURY_BONUSES, jBonuses);
}

void ApplyWarlordsFury(object oCaster, int nSpellId)
{
    // clear all abilities effects
    WarlordRemoveAllActiveSpells(oCaster);
    // show vfx
    ApplyVfxForActiveAbility(oCaster, nSpellId);
    // determine effect
    effect eWarlordsFury = EffectRunScript("_mod_runscript", "", "_mod_runscript", IntToFloat(WARLORD_FURY_TICK_INTERVAL));
    eWarlordsFury = EffectLinkEffects(eWarlordsFury, EffectIcon(EFFECT_ICON_WARLORDS_FURY));
    SignalEvent(oCaster, EventSpellCastAt(oCaster, nSpellId));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eWarlordsFury), oCaster, DURATION_SERVER_SESSION);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEAD_HOLY), oCaster);
    SetLocalInt(oCaster, WARLORD_FURY_ACTIVE_FLAG, TRUE);
    // !! determine all fields of json object (found bugs if not)
    json jBonuses = JsonObject();
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_AB, JsonInt(0));
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_NEGATIVE, JsonInt(0));
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_CRIT_RANGE, JsonInt(0));
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_DURATION, JsonInt(0));
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_TICK, JsonInt(0));
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_INCOME_DAMAGE, JsonInt(0));
    SetLocalJson(oCaster, JSON_WARLORD_FURY_BONUSES, jBonuses);
}

void RunScriptWarlordsFuryApply(object oCaster)
{
    PostString(oCaster, "AB:   " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y,     SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 1);
    PostString(oCaster, "NDmg: " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 1,     SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 2);
    PostString(oCaster, "CRng: " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 2, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 3);
    PostString(oCaster, "Time: " + IntToString(WARLORD_FURY_DURATION), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 3, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 4);
    PostString(oCaster, "Dmg:  " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 4, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 5);
}

void RunScriptWarlordsFuryTick(object oCaster)
{
    json jBonuses = GetLocalJson(oCaster, JSON_WARLORD_FURY_BONUSES);
    // calc current tick
    int nTick = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_FURY_KEY_TICK)) + 1;
    // calc end time and interrupt spell if reached limit
    int nBonusTime = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_FURY_KEY_DURATION));
    float fMaxTicks = IntToFloat(WARLORD_FURY_DURATION + nBonusTime) / IntToFloat(WARLORD_FURY_TICK_INTERVAL);
    if(IntToFloat(nTick) >= fMaxTicks)
    {
        WarlordRemoveAllActiveSpells(oCaster);
        return;
    }
    // spell limit not reached, lets update ticks
    JsonObjectSetInplace(jBonuses, WARLORD_FURY_KEY_TICK, JsonInt(nTick));
    // get bonuses data
    int nAB = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_FURY_KEY_AB));
    int nNeg = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_FURY_KEY_NEGATIVE));
    int nCritRange = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_FURY_KEY_CRIT_RANGE));
    int nDmgReceived = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_FURY_KEY_INCOME_DAMAGE));
    //SendMessageToPC(oCaster, JsonDump(jBonuses, 1));
    // update poststring values
    PostString(oCaster, "AB:   " + IntToString(nAB), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y,     SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 1);
    PostString(oCaster, "NDmg: " + IntToString(nNeg), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 1, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 2);
    PostString(oCaster, "CRng: " + IntToString(nCritRange), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 2, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 3);
    PostString(oCaster, "Time: " + IntToString(WARLORD_FURY_DURATION + nBonusTime - nTick * WARLORD_FURY_TICK_INTERVAL), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 3, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 4);
    PostString(oCaster, "Dmg:  " + IntToString(nDmgReceived), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 4, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 5);
    // determine and apply effects
    RemoveEffectsFromSpell(oCaster, SPELL_WARLORD_FURY_BONUSES);
    effect eLink = EffectLinkEffects(EffectAttackIncrease(nAB), EffectDamageIncrease(GetDamageBonusConstantFromNumber(nNeg), DAMAGE_TYPE_NEGATIVE));
    eLink = ExtraordinaryEffect(HideEffectIcon(eLink));
    eLink = SetEffectSpellId(eLink, SPELL_WARLORD_FURY_BONUSES);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, DURATION_SERVER_SESSION);
    // set crit range
    NWNX_Creature_SetCriticalRangeModifier(oCaster, -nCritRange, 0);
}

////////////////////// Battlefield Echo ///////////////////////////

void ApplyBattlefieldEcho(object oCaster, int nSpellId, float fRange, location lLoc)
{
    // clear all abilities effects
    WarlordRemoveAllActiveSpells(oCaster);
    // apply vfx
    ApplyVfxForActiveAbility(oCaster, nSpellId);
    // determine effect
    int nUpgradeRadius = WarlordFameshopGetIsBitActivated(oCaster, FAMESHOP_WARLORD_BONUS_ECHO_RADIUS_1) > 0;
    effect eVis = EffectVisualEffect(PRCVFX_FNF_MASS_CURE, FALSE, 3.5 + 3.5 * nUpgradeRadius);
    effect eImpact = EffectVisualEffect(GAOVFX_IMP_REDUCE_ABILITY_SCORE_YELLOW);
    // determine effects for caster and targets
    effect eBattlefieldEchoTarget = EffectIcon(EFFECT_ICON_BATTLEFIELD_ECHO_TARGET);
    effect eBattlefieldEchoSelf = EffectLinkEffects(EffectRunScript("_mod_runscript", "", "_mod_runscript", IntToFloat(BATTLEFIELD_ECHO_TICK_INTERVAL)),
                                                  EffectIcon(EFFECT_ICON_BATTLEFIELD_ECHO_SELF));
    // apply caster vis and runscript effect
    AssignCommand(oCaster, DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster)));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eBattlefieldEchoSelf), oCaster, DURATION_SERVER_SESSION);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEAD_HOLY), oCaster);
    // setup radius
    fRange = RADIUS_SIZE_COLOSSAL + RADIUS_SIZE_COLOSSAL * nUpgradeRadius;
    // get first target in the area of effect
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRange, lLoc, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        //Check faction of oTarget
        if(GetIsPC(oTarget) && !players_GetFactionsEqual(oTarget, oCaster) || champion_GetIsBoss(oTarget) || players_IsTestCharacter(oTarget) && oTarget != oCaster)
        {
            // calculate range based delay
            float fDelay = GetDelayByRange(0.5, 1.5, GetDistanceBetween(oTarget, oCaster), fRange);
            // Signal spell cast at event
            SignalEvent(oTarget, EventSpellCastAt(oCaster, nSpellId));
            // apply new effect
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBattlefieldEchoTarget, oTarget, DURATION_SERVER_SESSION));
        }
        //Get next spell target
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRange, lLoc, TRUE);
    }
    // !! determine all fields of json object (i found bugs if not do it)
    json jBonuses = JsonObject();
    JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_AB, JsonInt(0));
    JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_TAUNT, JsonInt(0));
    JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_SF, JsonInt(0));
    JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_DURATION, JsonInt(0));
    JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_TICK, JsonInt(0));
    JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_INCOME_DAMAGE, JsonInt(0));
    SetLocalJson(GetModule(), JSON_BATTLEFIELD_ECHO_BONUSES + "_" + ObjectToString(oCaster), jBonuses);
}

void UpdateBattlefieldEchoBonusesCounter(object oTarget, int nIncomeDamage)
{
    effect eLoop = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eLoop))
    {
        object oCreator = GetEffectCreator(eLoop);
        if(GetEffectSpellId(eLoop) == SPELL_BATTLEFIELD_ECHO && oCreator!= oTarget)
        {
            json jBonuses = GetLocalJson(GetModule(), JSON_BATTLEFIELD_ECHO_BONUSES + "_" + ObjectToString(oCreator));
            // get stored damage and calc total
            int nStoredDamage = JsonGetInt(JsonObjectGet(jBonuses, BATTLEFIELD_ECHO_KEY_INCOME_DAMAGE));
            int nTotalIncomeDamage = nStoredDamage + nIncomeDamage;
            // store total damage
            JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_INCOME_DAMAGE, JsonInt(nTotalIncomeDamage));
            // calc max bonus
            int nDDLevel = GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oCreator);
            int nMaxBonus = nDDLevel / 10;
            // AB
            int nAttackBonus = nTotalIncomeDamage / BATTLEFIELD_ECHO_BONUSES_STEP;
            int nMaxAttackBonus = nMaxBonus + WarlordFameshopGetIsBitActivated(oCreator, FAMESHOP_WARLORD_BONUS_ECHO_AB_1);
            nAttackBonus = nAttackBonus > nMaxAttackBonus ? nMaxAttackBonus : nAttackBonus;
            // Taunt
            int nTaunt = nTotalIncomeDamage / BATTLEFIELD_ECHO_BONUSES_STEP;
            nTaunt = nTaunt > nMaxBonus ? nMaxBonus : nTaunt;
            nTaunt += WarlordFameshopGetIsBitActivated(oCreator, FAMESHOP_WARLORD_BONUS_ECHO_TAUNT_1) +
                      WarlordFameshopGetIsBitActivated(oCreator, FAMESHOP_WARLORD_BONUS_ECHO_TAUNT_2);
            // SF Taunt
            int nSFTaunt = nTotalIncomeDamage / BATTLEFIELD_ECHO_BONUSES_STEP;
            nSFTaunt = nSFTaunt > nMaxBonus ? nMaxBonus : nSFTaunt;
            nTaunt += WarlordFameshopGetIsBitActivated(oCreator, FAMESHOP_WARLORD_BONUS_ECHO_SF_1) +
                      WarlordFameshopGetIsBitActivated(oCreator, FAMESHOP_WARLORD_BONUS_ECHO_SF_2);
            // Duration
            int nDur = (nTotalIncomeDamage / BATTLEFIELD_ECHO_BONUSES_STEP) * BATTLEFIELD_ECHO_DURATION_BONUS;
            // update json
            JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_AB, JsonInt(nAttackBonus));
            JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_TAUNT, JsonInt(nTaunt));
            JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_SF, JsonInt(nSFTaunt));
            JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_DURATION, JsonInt(nDur));
            SetLocalJson(GetModule(), JSON_BATTLEFIELD_ECHO_BONUSES + "_" + ObjectToString(oCreator), jBonuses);
        }
        eLoop = GetNextEffect(oTarget);
    }
}

void RunScriptBattlefieldEchoApply(object oCaster)
{
    PostString(oCaster, "AB:    " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y,     SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 1);
    PostString(oCaster, "Taunt: " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 1,     SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 2);
    PostString(oCaster, "SF:    " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 2, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 3);
    PostString(oCaster, "Time:  " + IntToString(WARLORD_FURY_DURATION), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 3, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 4);
    PostString(oCaster, "Dmg:   " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 4, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 5);
}

void RunScriptBattlefieldEchoTick(object oCaster)
{
    json jBonuses = GetLocalJson(GetModule(), JSON_BATTLEFIELD_ECHO_BONUSES + "_" + ObjectToString(oCaster));
    // calc current tick
    int nTick = JsonGetInt(JsonObjectGet(jBonuses, BATTLEFIELD_ECHO_KEY_TICK)) + 1;
    // calc end time and interrupt spell if reached limit
    int nBonusTime = JsonGetInt(JsonObjectGet(jBonuses, BATTLEFIELD_ECHO_KEY_DURATION));
    float fMaxTicks = IntToFloat(BATTLEFIELD_ECHO_DURATION + nBonusTime) / IntToFloat(BATTLEFIELD_ECHO_TICK_INTERVAL);
    if(IntToFloat(nTick) >= fMaxTicks)
    {
        WarlordRemoveAllActiveSpells(oCaster);
        return;
    }
    // spell limit not reached, lets update ticks
    JsonObjectSetInplace(jBonuses, BATTLEFIELD_ECHO_KEY_TICK, JsonInt(nTick));
    // get bonuses data
    int nAB = JsonGetInt(JsonObjectGet(jBonuses, BATTLEFIELD_ECHO_KEY_AB));
    int nTaunt = JsonGetInt(JsonObjectGet(jBonuses, BATTLEFIELD_ECHO_KEY_TAUNT));
    int nSF = JsonGetInt(JsonObjectGet(jBonuses, BATTLEFIELD_ECHO_KEY_SF));
    int nDmgReceived = JsonGetInt(JsonObjectGet(jBonuses, BATTLEFIELD_ECHO_KEY_INCOME_DAMAGE));
    //SendMessageToPC(oCaster, JsonDump(jBonuses, 1));
    // update poststring values
    PostString(oCaster, "AB:    " + IntToString(nAB), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y,     SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 1);
    PostString(oCaster, "Taunt: " + IntToString(nTaunt), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 1, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 2);
    PostString(oCaster, "SF:    " + IntToString(nSF), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 2, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 3);
    PostString(oCaster, "Time:  " + IntToString(BATTLEFIELD_ECHO_DURATION + nBonusTime - nTick * BATTLEFIELD_ECHO_TICK_INTERVAL), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 3, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 4);
    PostString(oCaster, "Dmg:   " + IntToString(nDmgReceived), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 4, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 5);
    // determine and apply effects
    effect eLink = EffectLinkEffects(EffectAttackIncrease(nAB), EffectSkillIncrease(SKILL_TAUNT, nTaunt));
    eLink = ExtraordinaryEffect(HideEffectIcon(eLink));
    eLink = SetEffectSpellId(eLink, SPELL_BATTLEFIELD_ECHO_BONUSES);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, DURATION_SERVER_SESSION);
}

///////////////////////// Warlord Guard ///////////////////////////

void ApplyWarlordsGuard(object oCaster, int nSpellId)
{
    //
    WarlordRemoveAllActiveSpells(oCaster);
    // show vfx
    ApplyVfxForActiveAbility(oCaster, nSpellId);
    // determine effect
    effect eWarlordsGuard = EffectRunScript("_mod_runscript", "", "_mod_runscript", IntToFloat(WARLORD_FURY_TICK_INTERVAL));
    eWarlordsGuard = EffectLinkEffects(eWarlordsGuard, EffectIcon(EFFECT_ICON_WARLORDS_GUARD));
    SignalEvent(oCaster, EventSpellCastAt(oCaster, nSpellId));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eWarlordsGuard), oCaster, DURATION_SERVER_SESSION);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEAD_HOLY), oCaster);
    SetLocalInt(oCaster, WARLORD_GUARD_ACTIVE_FLAG, TRUE);
    // !! determine all fields of json object (found bugs if not)
    json jBonuses = JsonObject();
    JsonObjectSetInplace(jBonuses, WARLORD_GUARD_KEY_AB, JsonInt(0));
    JsonObjectSetInplace(jBonuses, WARLORD_GUARD_KEY_IMMUNITY, JsonInt(0));
    JsonObjectSetInplace(jBonuses, WARLORD_GUARD_KEY_DURATION, JsonInt(0));
    JsonObjectSetInplace(jBonuses, WARLORD_GUARD_KEY_TICK, JsonInt(0));
    JsonObjectSetInplace(jBonuses, WARLORD_GUARD_KEY_REFLECTED_DAMAGE, JsonInt(0));
    SetLocalJson(oCaster, JSON_WARLORD_GUARD_BONUSES, jBonuses);
}

void UpdateWarlordsGuardBonusesCounter(object oPC, object oTarget, int nIncomeDamage)
{
    json jBonuses = GetLocalJson(oPC, JSON_WARLORD_GUARD_BONUSES);
    // get DD level
    int nDDLevel = GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oPC);
    // calc reflected damage
    int nReflectedDamage = FloatToInt(IntToFloat(nDDLevel) * IntToFloat(nIncomeDamage) / 100.0);
    // get stored damage and calc total
    int nStoredDamage = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_GUARD_KEY_REFLECTED_DAMAGE));
    int nTotalReflectedDamage = nStoredDamage + nReflectedDamage;
    // store total damage
    JsonObjectSetInplace(jBonuses, WARLORD_GUARD_KEY_REFLECTED_DAMAGE, JsonInt(nTotalReflectedDamage));
    // handle reflected damage
    struct NWNX_Damage_DamageData stDamage;
    stDamage.iNegative = nReflectedDamage + 2 * WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_GUARD_REFLECT_1) +
                                            3 * WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_GUARD_REFLECT_2);
    NWNX_Damage_DealDamage(stDamage, oTarget, oPC);
    // calc AB
    int nAB = nDDLevel / 10 + WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_GUARD_AB_1);
    // calc and apply heal
    int nMaxHeal = GetMaxHitPoints(oPC) - GetCurrentHitPoints(oPC);
    int nHeal = nDDLevel - 10 > 0 ? nDDLevel - 10: 0;
    nHeal = nHeal > nMaxHeal ? nMaxHeal : nHeal;
    nHeal = nHeal + 5 * WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_GUARD_HP_1) +
                    5 * WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_GUARD_HP_2);
                    //ServerShout(IntToString(nHeal));
    nHeal = nHeal > 0 ? nHeal : 0;
    effect eHeal = EffectHeal(nHeal);
    if(nHeal)ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oPC);
    // calc immunity
    int nImmunity = (nTotalReflectedDamage / WARLORD_GUARD_IMMUNITY_STEP) * 3;
    nImmunity = nImmunity > nDDLevel ? nDDLevel : nImmunity;
    // calc duration bonus
    int nDur = (nTotalReflectedDamage / WARLORD_GUARD_DURATION_STEP) * WARLORD_GUARD_DURATION_BONUS;
    // store calculated
    JsonObjectSetInplace(jBonuses, WARLORD_GUARD_KEY_AB, JsonInt(nAB));
    JsonObjectSetInplace(jBonuses, WARLORD_GUARD_KEY_IMMUNITY, JsonInt(nImmunity));
    JsonObjectSetInplace(jBonuses, WARLORD_GUARD_KEY_DURATION, JsonInt(nDur));
    SetLocalJson(oPC, JSON_WARLORD_GUARD_BONUSES, jBonuses);
}

void RunScriptWarlordsGuardApply(object oCaster)
{
    PostString(oCaster, "AB:   " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y,     SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 1);
    PostString(oCaster, "Imm:  " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 1, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 2);
    PostString(oCaster, "Time: " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 2, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 3);
    PostString(oCaster, "Dmg:  " + IntToString(0), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 3, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 4);
}

void RunScriptWarlordsGuardTick(object oCaster)
{
    json jBonuses = GetLocalJson(oCaster, JSON_WARLORD_GUARD_BONUSES);
    // calc current tick
    int nTick = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_GUARD_KEY_TICK)) + 1;
    // calc end time and interrupt spell if reached limit
    int nBonusTime = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_GUARD_KEY_DURATION));
    float fMaxTicks = IntToFloat(WARLORD_GUARD_DURATION + nBonusTime) / IntToFloat(WARLORD_GUARD_TICK_INTERVAL);
    if(IntToFloat(nTick) >= fMaxTicks)
    {
        WarlordRemoveAllActiveSpells(oCaster);
        return;
    }
    // spell limit not reached, lets update ticks
    JsonObjectSetInplace(jBonuses, WARLORD_GUARD_KEY_TICK, JsonInt(nTick));
    // get bonuses data
    int nAB = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_GUARD_KEY_AB));
    int nImmun = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_GUARD_KEY_IMMUNITY));
    int nDmgReflected = JsonGetInt(JsonObjectGet(jBonuses, WARLORD_GUARD_KEY_REFLECTED_DAMAGE));
    //SendMessageToPC(oCaster, JsonDump(jBonuses, 1));
    // update poststring values
    PostString(oCaster, "AB:   " + IntToString(nAB), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y,     SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 1);
    PostString(oCaster, "Imm:  " + IntToString(nImmun), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 1,     SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 2);
    PostString(oCaster, "Time: " + IntToString(WARLORD_GUARD_DURATION + nBonusTime - nTick * WARLORD_GUARD_TICK_INTERVAL), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 2, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 3);
    PostString(oCaster, "Dmg:  " + IntToString(nDmgReflected), POSTSTRING_START_POSITION_ABILITIES_X, POSTSTRING_START_POSITION_ABILITIES_Y + 3, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 4);
    // determine and apply effects
    RemoveEffectsFromSpell(oCaster, SPELL_WARLORD_GUARD_BONUSES);
    effect eDamageImmunity = EffectDamageImmunityIncrease(DAMAGE_TYPE_ACID, nImmun);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_BASE_WEAPON, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_BLUDGEONING, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_COLD, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_DIVINE, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_ELECTRICAL, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_MAGICAL, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_PIERCING, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_POSITIVE, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_SLASHING, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_SONIC, nImmun), eDamageImmunity);
    eDamageImmunity = EffectLinkEffects(EffectAttackIncrease(nAB), eDamageImmunity);
    eDamageImmunity = ExtraordinaryEffect(HideEffectIcon(eDamageImmunity));
    eDamageImmunity = SetEffectSpellId(eDamageImmunity, SPELL_WARLORD_GUARD_BONUSES);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDamageImmunity, oCaster, DURATION_SERVER_SESSION);
}

////////////////////// Fameshop Upgrades //////////////////////////

void WarlordFameshopRefreshTokens(object oPC)
{
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_FURY_AB_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_FURY_AB_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_TAUNT_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_TAUNT_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_SF_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_SF_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_RADIUS_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_AB_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_GUARD_REFLECT_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_GUARD_REFLECT_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_GUARD_HP_1, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_GUARD_HP_2, CONST_FAMESHOP_LOCKED);
    NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_GUARD_AB_1, CONST_FAMESHOP_LOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_FURY_AB_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_FURY_AB_1, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_FURY_AB_2))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_FURY_AB_2, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_ECHO_TAUNT_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_TAUNT_1, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_ECHO_TAUNT_2))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_TAUNT_2, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_ECHO_SF_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_SF_1, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_ECHO_SF_2))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_SF_2, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_ECHO_RADIUS_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_RADIUS_1, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_ECHO_AB_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_ECHO_AB_1, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_GUARD_REFLECT_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_GUARD_REFLECT_1, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_GUARD_REFLECT_2))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_GUARD_REFLECT_2, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_GUARD_HP_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_GUARD_HP_1, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_GUARD_HP_2))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_GUARD_HP_2, CONST_FAMESHOP_UNLOCKED);

    if(WarlordFameshopGetIsBitActivated(oPC, FAMESHOP_WARLORD_BONUS_GUARD_AB_1))
        NWNX_Player_SetCustomToken(oPC, TOKEN_WARLORD_BONUS_GUARD_AB_1, CONST_FAMESHOP_UNLOCKED);
}

int WarlordFameshopGetIsBitActivated(object oPC, int nUpgradeBit)
{
    int nBitArray = GetLocalInt(oPC, WARLORD_UPGRADES_CASH);
    if(nBitArray > 0)
        return (nBitArray & nUpgradeBit) > 0;
    else if(nBitArray == -1)
        return 0;
    string sAccount = GetPCPlayerName(oPC);
    string sSQL = "SELECT warlord_upgrades FROM players WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sAccount);
    NWNX_SQL_ExecutePreparedQuery();
    if (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nBitArray = StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
        nBitArray = nBitArray > 0 ? nBitArray : -1;
        SetLocalInt(oPC, WARLORD_UPGRADES_CASH, nBitArray);
        if(nBitArray > 0)
            return (nBitArray & nUpgradeBit) > 0;
        else
            return 0;
    }
    return 0;
}

int WarlordFameshopActivateBit(object oPC, int nUpgradeBit)
{
    if(WarlordFameshopGetIsBitActivated(oPC, nUpgradeBit))
        return FALSE;
    int nBitArray = GetLocalInt(oPC, WARLORD_UPGRADES_CASH);
    if(nBitArray < 0)
        nBitArray = 0;
    nBitArray = nBitArray | nUpgradeBit;
    SetLocalInt(oPC, WARLORD_UPGRADES_CASH, nBitArray);
    string sAccount = GetPCPlayerName(oPC);
    string sSQL = "UPDATE players SET warlord_upgrades = ? WHERE name = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, nBitArray);
    NWNX_SQL_PreparedString(1, sAccount);
    return NWNX_SQL_ExecutePreparedQuery();
}

int WarlordFameshopTryToActivateBit(object oPC, int nUpgradeBit, int nCost)
{
    if(WarlordFameshopGetIsBitActivated(oPC, nUpgradeBit))
    {
        SendMessageToPC(oPC, "You already activated this upgrade.");
        return FALSE;
    }
    if(!SpendFame(oPC, nCost, TRUE, FALSE))
    {
        SendMessageToPC(oPC, "Upgrade is not activated. Not enough fame. Need: " + IntToString(nCost));
        return FALSE;
    }
    if(WarlordFameshopActivateBit(oPC, nUpgradeBit))
    {
        SendMessageToPC(oPC, "Upgrade activated.");
        WarlordFameshopRefreshTokens(oPC);
        return TRUE;
    }
    return FALSE;
}



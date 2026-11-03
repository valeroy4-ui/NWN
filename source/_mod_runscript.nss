#include "_inc_champ_boss"
//#include "_inc_generic"
//#include "_inc_spells"
#include "nwnx_damage"
//#include "nwnx_player"
//#include "70_inc_spells"
#include "_inc_pulse_rage"
#include "_inc_telegraph"
#include "_inc_fshop_bg"
//#include "x0_i0_position"
#include "_inc_war_class"

// BG constants
const int POSTSTRING_START_POSITION_EVIL_BLIGHT_X = 1;
const int POSTSTRING_START_POSITION_EVIL_BLIGHT_Y = 3;

//
void runscript_ShowEffectForCasterTeam(object oCaster, object oTarget, string sMessage);

//
void runscript_SpellInfernoTicks(effect eInferno, object oTarget, string sEffectData);

//
void runscript_SpellDrownTicks(effect eDrown, object oTarget, int nEffectSpellID);

//
void runscript_CameraFacingFixTicks(object oEffectTarget);

//
void runscript_SpellBleedApply(effect eBleed, object oTarget);

//
void runscript_SpellBleedTicks(effect eBleed, object oTarget, string sEffectData);

//
void runscript_ApplyMassDislike(object oTarget);

//
void runscript_EvilBlightOnApply(object oPC);

//
void runscript_EvilBlightOnRemoved(object oPC);

//
void runscript_EvilBlightOnTick(object oCreator, object oTarget);

//
void runscript_RuneOfRegenOnTick(object oPC);

//
void runscript_PStatOnTick(object oEffectTarget);

//
void runscript_PStatOnRemoved(object oEffectTarget);

//
void runscript_GrtInvOnTick(object oPC);

//
int runscript_GetIconIdForStackableSpell(int nSpell, int nStackLevel);

//
int runscript_GetTickSpellIdForStackableSpell(int nSpellId);

//
int runscript_GetStackableSpellDuration(int nSpellId);

//
void runscript_StackableEffectOnTick(object oEffectTarget, effect eRunScriptEffect, int nSpellId);

//
void RunScriptSpellShockApplied(object oEffectTarget, int nSpellId);

//
void RunScriptSpellShockRemoved(object oEffectTarget);


const int PDK_BLEED_NATURAL_TICKS = 3;
string runscript_BleedTickKey(effect e)
{
    struct NWNX_EffectUnpacked data=NWNX_Effect_UnpackEffect(e);
    return "PDK_BLEED_TICK_"+data.sID;
}

void main()
{
    object oEffectTarget = OBJECT_SELF;
    //object oArea = GetArea(oEffectTarget);
    effect eRunScriptEffect = GetLastRunScriptEffect();
    object oEffectCreator = GetEffectCreator(eRunScriptEffect);
    int nEffectSpellID = GetEffectSpellId(eRunScriptEffect);
    int nCurrentEvent = GetLastRunScriptEffectScriptType();
    string sEffectData = GetEffectString(eRunScriptEffect, 0);
    int bShowCooldownMessages = (GetEffectTag(eRunScriptEffect) == CORMYR_SPELL_COOLDOWN_TAG && StringToInt(sEffectData) & CORMYR_SPELL_COOLDOWN_SHOW_MESSAGES);

    // telegraph
    string sTelegraphScript;
    string sTtelegraphId = TelegraphGetId(eRunScriptEffect);
    object oTelegraphArea = GetObjectByUUID(TelegrafGetAreaUUID(sTtelegraphId));

    switch(nCurrentEvent)
    {
        case RUNSCRIPT_EFFECT_SCRIPT_TYPE_ON_APPLIED:
            switch(nEffectSpellID)
            {
                case SPELL_INFERNO:
                    runscript_SpellInfernoTicks(eRunScriptEffect, oEffectTarget, sEffectData);
                break;
                case SPELL_DROWN:
                    runscript_SpellDrownTicks(eRunScriptEffect, oEffectTarget, nEffectSpellID);
                break;
                case SPELL_PROTECTION_FROM_EVIL:
                case SPELL_PROTECTION_FROM_GOOD:
                    NWNX_Player_ApplyLoopingVisualEffectToObject(oEffectCreator, oEffectTarget, StringToInt(sEffectData));
                break;
                case SPELL_BARBARIAN_RAGE_FEARLESS:
                case SPELL_BARBARIAN_RAGE_MIGHTY:
                case SPELL_BARBARIAN_RAGE_CONFUSE:
                case SPELL_BARBARIAN_RAGE_MURDERER:
                    ApplyRagePulse(oEffectTarget, eRunScriptEffect);
                break;
                case SPELL_THREATENING_CRY:
                    SetLocalFloat(oEffectTarget, "THREATENING_CRY_MULTIPLIER", StringToFloat(sEffectData));
                break;
                case SPELL_CORMYR_BOSS_RAGE:
                    champion_OnBossRageEnter(oEffectTarget);
                break;
                case SPELL_CORMYR_BLEED:
                    runscript_SpellBleedApply(eRunScriptEffect, oEffectTarget);
                break;
                case SPELL_CORMYR_SET_MASS_DISLIKE:
                    runscript_ApplyMassDislike(oEffectTarget);
                break;
                case SPELL_CORMYR_TELEGRAPH:
                    sTelegraphScript = telegraph_OnApply(oTelegraphArea, sTtelegraphId);
                    telegraph_UpdateShaderForAllPcs(oTelegraphArea);
                break;
                case SPELL_EVIL_BLIGHT:
                {
                    json jObject = JsonObjectSet(JSON_OBJECT, JSON_KEY_EVIL_BLIGHT_DAMAGE, JsonInt(0));
                    SetLocalJson(GetModule(), JSON_VAR_EVIL_BLIGHT_DATA + "_" + ObjectToString(oEffectTarget), jObject);
                }
                break;
                case SPELL_WARLORD_FURY:
                    RunScriptWarlordsFuryApply(oEffectTarget);
                break;
                case SPELL_BATTLEFIELD_ECHO:
                    RunScriptBattlefieldEchoApply(oEffectTarget);
                break;
                case SPELL_WARLORD_GUARD:
                    RunScriptWarlordsGuardApply(oEffectTarget);
                break;
                case SPELL_SHOCK:
                    RunScriptSpellShockApplied(oEffectTarget, nEffectSpellID);
                break;
            }
            if(bShowCooldownMessages)
            {
                float fCorrection = 0.0; // for spells with fameshop CD decrease
                switch(nEffectSpellID - TARGET_COOLDOWN_SPELL_ID_SHIFT)
                {
                    case SPELL_BG_MARK_OF_DOOM:
                        fCorrection = 18.0 * (fshop_bg_GetIsBitActivated(oEffectCreator, FAMESHOP_BG_MARK_OF_DOOM_CD_1_3ROUNDS) > 0) +
                                      18.0 * (fshop_bg_GetIsBitActivated(oEffectCreator, FAMESHOP_BG_MARK_OF_DOOM_CD_2_3ROUNDS) > 0) +
                                      12.0 * (fshop_bg_GetIsBitActivated(oEffectCreator, FAMESHOP_BG_MARK_OF_DOOM_CD_3_2ROUNDS) > 0);
                    break;
                }
                SendMessageToPC(oEffectTarget, GetSpellNameFromID(nEffectSpellID - TARGET_COOLDOWN_SPELL_ID_SHIFT) + " has " +
                                FloatToString(GetSpellTimeoutDuration(nEffectSpellID - TARGET_COOLDOWN_SPELL_ID_SHIFT) - fCorrection, 2, 1) + " seconds cooldown.");
            }
        break;
        case RUNSCRIPT_EFFECT_SCRIPT_TYPE_ON_INTERVAL:
            switch(nEffectSpellID)
            {
                case SPELL_INFERNO:
                    runscript_SpellInfernoTicks(eRunScriptEffect, oEffectTarget, sEffectData);
                break;
                case SPELL_DROWN:
                    runscript_SpellDrownTicks(eRunScriptEffect, oEffectTarget, nEffectSpellID);
                break;
                case SPELL_BARBARIAN_RAGE_FEARLESS:
                case SPELL_BARBARIAN_RAGE_MIGHTY:
                case SPELL_BARBARIAN_RAGE_CONFUSE:
                case SPELL_BARBARIAN_RAGE_MURDERER:
                    ApplyRagePulse(oEffectTarget, eRunScriptEffect);
                break;
                case SPELL_CAMERA_FACING_FIX:
                    runscript_CameraFacingFixTicks(oEffectTarget);
                break;
                case SPELL_CORMYR_BOSS_RAGE:
                    champion_OnBossRageTicks(oEffectTarget);
                break;
                case SPELL_CORMYR_BLEED:
                    runscript_SpellBleedTicks(eRunScriptEffect, oEffectTarget, sEffectData);
                break;
                case SPELL_CORMYR_SET_MASS_DISLIKE:
                    runscript_ApplyMassDislike(oEffectTarget);
                break;
                case SPELL_CORMYR_TELEGRAPH:
                    sTelegraphScript = telegraph_OnUpdate(oTelegraphArea, sTtelegraphId);
                break;
                case SPELL_EVIL_BLIGHT:
                    runscript_EvilBlightOnTick(oEffectCreator, oEffectTarget);
                break;
                case SPELL_CORMYR_RUNE_OF_REGEN_HEAL:
                    runscript_RuneOfRegenOnTick(oEffectTarget);
                break;
                case SPELL_CORMYR_PSTAT:
                    runscript_PStatOnTick(oEffectTarget);
                break;
                case SPELL_GREATER_INVISIBILITY:
                    runscript_GrtInvOnTick(oEffectTarget);
                break;
                case SPELL_REND:    // stackable onhits
                case SPELL_PLAGUE:
                case SPELL_WEAKEN:
                case SPELL_MADNESS:
                    runscript_StackableEffectOnTick(oEffectTarget, eRunScriptEffect, nEffectSpellID);
                break;
                case SPELL_WARLORD_FURY:
                    RunScriptWarlordsFuryTick(oEffectTarget);
                break;
                case SPELL_BATTLEFIELD_ECHO:
                    RunScriptBattlefieldEchoTick(oEffectTarget);
                break;
                case SPELL_WARLORD_GUARD:
                    RunScriptWarlordsGuardTick(oEffectTarget);
                break;
            }
        break;
        case RUNSCRIPT_EFFECT_SCRIPT_TYPE_ON_REMOVED:
            switch(nEffectSpellID)
            {
                case SPELL_CORMYR_BLEED:
                    DeleteLocalInt(oEffectTarget,runscript_BleedTickKey(eRunScriptEffect));
                break;
                case SPELL_INFERNO:
                break;
                case SPELL_DROWN:
                break;
                case SPELL_PROTECTION_FROM_EVIL:
                case SPELL_PROTECTION_FROM_GOOD:
                    NWNX_Player_ApplyLoopingVisualEffectToObject(oEffectCreator, oEffectTarget, StringToInt(sEffectData));
                break;
                case SPELL_THREATENING_CRY:
                    DeleteLocalFloat(oEffectTarget, "THREATENING_CRY_MULTIPLIER");
                break;
                case SPELL_CORMYR_BOSS_RAGE:
                    champion_OnBossRageExit(oEffectTarget);
                break;
                case SPELL_CORMYR_TELEGRAPH:
                    sTelegraphScript = telegraph_OnRemove(oTelegraphArea, sTtelegraphId);
                    telegraph_UpdateShaderForAllPcs(oTelegraphArea);
                break;
                case SPELL_EVIL_BLIGHT:
                    runscript_EvilBlightOnRemoved(oEffectTarget);
                    RemoveEffectsFromSpell(oEffectTarget, SPELL_CORMYR_EVIL_BLIGHT_BONUSES);
                    DeleteLocalJson(GetModule(), JSON_VAR_EVIL_BLIGHT_DATA + "_" + ObjectToString(oEffectTarget));
                break;
                case SPELL_CORMYR_PSTAT:
                    runscript_PStatOnRemoved(oEffectTarget);
                break;
                case SPELL_GREATER_INVISIBILITY:
                    RemoveEffectsFromSpell(oEffectTarget, SPELL_GREATER_INVISIBILITY_TICK);
                break;
                case SPELL_REND:    // stackable onhits
                case SPELL_PLAGUE:
                case SPELL_WEAKEN:
                case SPELL_MADNESS:
                    RemoveEffectsFromSpell(oEffectTarget, runscript_GetTickSpellIdForStackableSpell(nEffectSpellID));
                    DeleteLocalInt(oEffectTarget, IntToString(nEffectSpellID) + "_STACKS");
                break;
                case SPELL_SHOCK:
                    RunScriptSpellShockRemoved(oEffectTarget);
                break;
            }
            if(bShowCooldownMessages)
                FloatingColorTextStringOnCreature(GetSpellNameFromID(nEffectSpellID - TARGET_COOLDOWN_SPELL_ID_SHIFT) + " is ready!", TXT_COLOR_GREEN_L, oEffectTarget, TRUE);
        break;
    }
    if(sTelegraphScript != "")
        ExecuteScript(sTelegraphScript, oEffectTarget);
    if(nCurrentEvent == RUNSCRIPT_EFFECT_SCRIPT_TYPE_ON_REMOVED) // free after exec sTelegraphScript
        _TelegraphFree(sTtelegraphId);
}

void runscript_ShowEffectForCasterTeam(object oCaster, object oTarget, string sMessage)
{
    // Show DoT to all Caster's party
    object oPC = GetFirstFactionMember(oCaster);
    while(GetIsObjectValid(oPC))
    {
        if(GetObjectSeen(oTarget, oPC))
            NWNX_Player_FloatingTextStringOnCreature(oPC, oTarget, ColorText(sMessage, TXT_COLOR_SPECIAL_HIT));
        oPC = GetNextFactionMember(oCaster);
    }
}

void runscript_SpellInfernoTicks(effect eInferno, object oTarget, string sEffectData)
{
    object oCaster = GetEffectCreator(eInferno);
    // apply visual
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(CEPVFX_FNF_GAS_EXPLOSION_FLAME), oTarget);

    int nBaseMultipiler       = StringToInt(GetTokenByPosition(sEffectData,   "|", 0));
    int nAbilityModifier      = StringToInt(GetTokenByPosition(sEffectData,   "|", 1));
    float fCriticalChance     = StringToFloat(GetTokenByPosition(sEffectData, "|", 2));
    float fCriticalMultiplier = StringToFloat(GetTokenByPosition(sEffectData, "|", 3));

    int nFireDmg = nBaseMultipiler * nAbilityModifier;

    string sMessage = "Inferno ";

    if (fCriticalChance > 0.0)
    {
        if (FloatToInt(fCriticalChance * 100.0) >= d100())
        {
            sMessage = "Inferno Critical ";
            nFireDmg = FloatToInt(IntToFloat(nFireDmg) * fCriticalMultiplier);
        }
    }

    sMessage += "Hit!";
    if(!GetFactionEqual(oCaster, oTarget))
        FloatingColorTextStringOnCreature(sMessage, TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);

    runscript_ShowEffectForCasterTeam(oCaster, oTarget, sMessage);

    struct NWNX_Damage_DamageData stInfernoDamage;
    stInfernoDamage.iFire = nFireDmg;

    AssignCommand(oCaster, DelayCommand(1.0, NWNX_Damage_DealDamage(stInfernoDamage, oTarget, oCaster)));
}

void runscript_SpellDrownTicks(effect eDrown, object oTarget, int nEffectSpellID)
{
    object oCaster = GetEffectCreator(eDrown);
    int nSpellDC = StringToInt(GetEffectString(eDrown, 0));
    effect eVis = EffectVisualEffect(VFX_IMP_FROST_L);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

    //Make a fortitude save
    if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nSpellDC, SAVING_THROW_TYPE_NONE, oCaster))
    {
        RemoveEffectsFromSpell(oTarget, nEffectSpellID);

        effect eStun = IgnoreEffectImmunity(EffectStunned());
        float fDuration = 1.5 * IntToFloat((GetLevelByClass(CLASS_TYPE_DRUID, oCaster) + GetLevelByClass(CLASS_TYPE_ARCHMAGE, oCaster)) / 10);

        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStun, oTarget, fDuration);
        runscript_ShowEffectForCasterTeam(oCaster, oTarget, "Drown Hit!");
        if(!GetFactionEqual(oCaster, oTarget))
            FloatingColorTextStringOnCreature("Drown Hit!", TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);
    }
    else
    {
        runscript_ShowEffectForCasterTeam(oCaster, oTarget, "Drown Failed!");
        if(!GetFactionEqual(oCaster, oTarget))
            FloatingColorTextStringOnCreature("Drown Failed!", TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);
    }
}

void runscript_CameraFacingFixTicks(object oEffectTarget)
{
    object oArea = GetArea(oEffectTarget);
    if(GetIsObjectValid(oArea))
    {
        object oDestination = GetLocalObject(oEffectTarget, "CAMERA_FACING_FIX");
        //ServerShout(GetName(oDestination));
        float fFacing = GetFacing(oDestination);
        //ServerShout(FloatToString(fFacing, 2, 2));
        //AssignCommand(oEffectTarget, DelayCommand(0.05, SetFacing(fFacing)));
        //AssignCommand(oEffectTarget, DelayCommand(0.10, SetFacing(fFacing)));
        //AssignCommand(oEffectTarget, DelayCommand(0.15, SetFacing(fFacing)));
        AssignCommand(oEffectTarget, DelayCommand(0.1, SetCameraFacing(fFacing, -1.0, -1.0, CAMERA_TRANSITION_TYPE_SNAP)));
        AssignCommand(oEffectTarget, DelayCommand(0.2, SetCameraFacing(fFacing, -1.0, -1.0, CAMERA_TRANSITION_TYPE_SNAP)));
        AssignCommand(oEffectTarget, DelayCommand(0.3, SetCameraFacing(fFacing, -1.0, -1.0, CAMERA_TRANSITION_TYPE_SNAP)));
        RemoveEffectsFromSpell(oEffectTarget, SPELL_CAMERA_FACING_FIX);
        DeleteLocalObject(oEffectTarget, "CAMERA_FACING_FIX");
    }
}

void runscript_SpellBleedApply(effect eBleed, object oTarget)
{
    SetLocalInt(oTarget,runscript_BleedTickKey(eBleed),0);
    object oCaster = GetEffectCreator(eBleed);
    string sMessage = "Bleed Applied!";
    if(!GetFactionEqual(oCaster, oTarget))
        FloatingColorTextStringOnCreature(sMessage, TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);

    runscript_ShowEffectForCasterTeam(oCaster, oTarget, sMessage);
}

void runscript_SpellBleedTicks(effect eBleed, object oTarget, string sEffectData)
{
    object oCaster = GetEffectCreator(eBleed);
    string key=runscript_BleedTickKey(eBleed);
    int tick=GetLocalInt(oTarget,key)+1;
    SetLocalInt(oTarget,key,tick);
    int nBloodDamage = StringToInt(sEffectData);
    if(GetSubString(sEffectData,0,1)=="{")
    {
        json data=JsonParse(sEffectData);
        nBloodDamage=JsonGetInt(JsonObjectGet(data,"damage"));
        if(tick==PDK_BLEED_NATURAL_TICKS && !GetIsDead(oTarget))
            nBloodDamage+=JsonGetInt(JsonObjectGet(data,"pdkFinal"));
    }
    if(nBloodDamage <= 0)
        return;

    string sMessage = "Bleed Hit!";
    if(!GetFactionEqual(oCaster, oTarget))
        FloatingColorTextStringOnCreature(sMessage, TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);

    runscript_ShowEffectForCasterTeam(oCaster, oTarget, sMessage);

    struct NWNX_Damage_DamageData stBleedDamage;
    stBleedDamage.iCustom1 = nBloodDamage;

    AssignCommand(oCaster, DelayCommand(1.0, NWNX_Damage_DealDamage(stBleedDamage, oTarget, oCaster)));
}

void runscript_ApplyMassDislike(object oTarget)
{
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        if(!GetIsDM(oPC) && !players_GetFactionsEqual(oTarget, oPC))
        {
            SetPCDislike(oTarget, oPC);
            SetPCDislike(oPC, oTarget);
        }
        oPC = GetNextPC();
    }
}

void runscript_EvilBlightOnApply(object oCreator)
{
    json jCash = GetLocalJson(GetModule(), JSON_VAR_EVIL_BLIGHT_DATA + "_" + ObjectToString(oCreator));
    int nAB = JsonGetInt(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_AB));
    int nTaunt = JsonGetInt(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_TAUNT));
    int nSFTaunt = JsonGetInt(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_SF_TAUNT));
    int nDamage = JsonGetInt(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_DAMAGE));
    float fDur = JsonGetFloat(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_DURATION));
    float fCurrentTick = JsonGetFloat(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_DATA_TICK));
    int nTimeLeft = FloatToInt(BG_EVIL_BLIGHT_DURATION_SEC + fDur - fCurrentTick * BG_EVIL_BLIGHT_TICK_INTERVAL_SEC);
    PostString(oCreator, "AB:    " + IntToString(nAB),       POSTSTRING_START_POSITION_EVIL_BLIGHT_X, POSTSTRING_START_POSITION_EVIL_BLIGHT_Y,     SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 1);
    PostString(oCreator, "Taunt: " + IntToString(nTaunt),    POSTSTRING_START_POSITION_EVIL_BLIGHT_X, POSTSTRING_START_POSITION_EVIL_BLIGHT_Y + 1, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 2);
    PostString(oCreator, "SF:    " + IntToString(nSFTaunt),  POSTSTRING_START_POSITION_EVIL_BLIGHT_X, POSTSTRING_START_POSITION_EVIL_BLIGHT_Y + 2, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 3);
    PostString(oCreator, "Time:  " + IntToString(nTimeLeft), POSTSTRING_START_POSITION_EVIL_BLIGHT_X, POSTSTRING_START_POSITION_EVIL_BLIGHT_Y + 3, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 4);
    PostString(oCreator, "Dmg:   " + IntToString(nDamage),   POSTSTRING_START_POSITION_EVIL_BLIGHT_X, POSTSTRING_START_POSITION_EVIL_BLIGHT_Y + 4, SCREEN_ANCHOR_TOP_LEFT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 5);
}

void runscript_EvilBlightOnRemoved(object oCreator)
{
    PostString(oCreator, "",  POSTSTRING_START_POSITION_EVIL_BLIGHT_X, POSTSTRING_START_POSITION_EVIL_BLIGHT_Y,     SCREEN_ANCHOR_TOP_LEFT, 0.01f, 0xFFFFFFFF, 0xFFFFFF00, 1);
    PostString(oCreator, "",  POSTSTRING_START_POSITION_EVIL_BLIGHT_X, POSTSTRING_START_POSITION_EVIL_BLIGHT_Y + 1, SCREEN_ANCHOR_TOP_LEFT, 0.01f, 0xFFFFFFFF, 0xFFFFFF00, 2);
    PostString(oCreator, "",  POSTSTRING_START_POSITION_EVIL_BLIGHT_X, POSTSTRING_START_POSITION_EVIL_BLIGHT_Y + 2, SCREEN_ANCHOR_TOP_LEFT, 0.01f, 0xFFFFFFFF, 0xFFFFFF00, 3);
    PostString(oCreator, "",  POSTSTRING_START_POSITION_EVIL_BLIGHT_X, POSTSTRING_START_POSITION_EVIL_BLIGHT_Y + 3, SCREEN_ANCHOR_TOP_LEFT, 0.01f, 0xFFFFFFFF, 0xFFFFFF00, 4);
    PostString(oCreator, "",  POSTSTRING_START_POSITION_EVIL_BLIGHT_X, POSTSTRING_START_POSITION_EVIL_BLIGHT_Y + 4, SCREEN_ANCHOR_TOP_LEFT, 0.01f, 0xFFFFFFFF, 0xFFFFFF00, 5);
}

void runscript_EvilBlightOnTick(object oCreator, object oTarget)
{
    json jCash = GetLocalJson(GetModule(), JSON_VAR_EVIL_BLIGHT_DATA + "_" + ObjectToString(oCreator));
    if(jCash == JSON_NULL)
        spells_RemoveAllCreatorsEffects(oTarget, oCreator, SPELL_EVIL_BLIGHT);
    if(oCreator != oTarget)
        return;
    float fBonusTicks = JsonGetFloat(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_DURATION)) / BG_EVIL_BLIGHT_TICK_INTERVAL_SEC;
    float fCurrentTick = JsonGetFloat(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_DATA_TICK));
    fCurrentTick += 1.0;
    if(fCurrentTick >= BG_EVIL_BLIGHT_DURATION_TICKS + fBonusTicks)
    {
        spells_RemoveAllCreatorsEffects(oTarget, oCreator, SPELL_EVIL_BLIGHT);
        return;
    }
    jCash = JsonObjectSet(jCash, JSON_KEY_EVIL_BLIGHT_DATA_TICK, JsonFloat(fCurrentTick));
    SetLocalJson(GetModule(), JSON_VAR_EVIL_BLIGHT_DATA + "_" + ObjectToString(oCreator), jCash);
    int nAB = JsonGetInt(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_AB));
    int nTaunt = JsonGetInt(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_TAUNT));

    RemoveEffectsFromSpell(oCreator, SPELL_CORMYR_EVIL_BLIGHT_BONUSES);
    runscript_EvilBlightOnRemoved(oCreator);
    DelayCommand(0.02, runscript_EvilBlightOnApply(oCreator));
    effect eLink = EffectLinkEffects(EffectAttackIncrease(nAB), EffectSkillIncrease(SKILL_TAUNT, nTaunt));
    eLink = ExtraordinaryEffect(HideEffectIcon(eLink));
    eLink = SetEffectSpellId(eLink, SPELL_CORMYR_EVIL_BLIGHT_BONUSES);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oCreator);
}

void runscript_RuneOfRegenOnTick(object oPC)
{
    NWNX_Creature_DoItemCastSpell(oPC, oPC, LOCATION_INVALID, SPELL_HEAL, GetHitDice(oPC), 0.5);
}

void runscript_PStatOnTick(object oEffectTarget)
{
    int nLT = GetPlayerNetworkLatency(oEffectTarget);
    int nAB = NWNX_Creature_GetAttackBonus(oEffectTarget, -1);
    int nAC = GetAC(oEffectTarget);
    int nFort = players_GetRealSavingThrowValue(oEffectTarget, SAVING_THROW_FORT);
    int nRefl = players_GetRealSavingThrowValue(oEffectTarget, SAVING_THROW_REFLEX);
    int nWill = players_GetRealSavingThrowValue(oEffectTarget, SAVING_THROW_WILL);
    int nSpace = 8;
    int nTabLT = nSpace - GetStringLength(IntToString(nLT) + "Ping:");
    int nTabAB = nSpace - GetStringLength(IntToString(nAB) + "AB:");
    int nTabAC = nSpace - GetStringLength(IntToString(nAC) + "AC:");
    int nTabF  = nSpace - GetStringLength(IntToString(nAC) + "Fort:");
    int nTabR  = nSpace - GetStringLength(IntToString(nAC) + "Refl:");
    int nTabW  = nSpace - GetStringLength(IntToString(nAC) + "Will:");

    string sTabLT, sTabAB, sTabAC, sTabF, sTabR, sTabW;
    int i;
    for (i = 0; i < nTabLT; i++)
    {
        sTabLT = InsertString(sTabLT, " ", 0);
    }
    for (i = 0; i < nTabAB; i++)
    {
        sTabAB = InsertString(sTabAB, " ", 0);
    }
    for (i = 0; i < nTabAC; i++)
    {
        sTabAC = InsertString(sTabAC, " ", 0);
    }
    for (i = 0; i < nTabF; i++)
    {
        sTabF = InsertString(sTabF, " ", 0);
    }
    for (i = 0; i < nTabR; i++)
    {
        sTabR = InsertString(sTabR, " ", 0);
    }
    for (i = 0; i < nTabW; i++)
    {
        sTabW = InsertString(sTabW, " ", 0);
    }
    PostString(oEffectTarget, "Ping:" + sTabLT + IntToString(nLT),   10, 7,  SCREEN_ANCHOR_TOP_RIGHT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 6);
    PostString(oEffectTarget, "AB:"   + sTabAB + IntToString(nAB),   10, 8,  SCREEN_ANCHOR_TOP_RIGHT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 7);
    PostString(oEffectTarget, "AC:"   + sTabAC + IntToString(nAC),   10, 9,  SCREEN_ANCHOR_TOP_RIGHT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 8);
    PostString(oEffectTarget, "Fort:" + sTabF  + IntToString(nFort), 10, 10, SCREEN_ANCHOR_TOP_RIGHT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 9);
    PostString(oEffectTarget, "Refl:" + sTabR  + IntToString(nRefl), 10, 11, SCREEN_ANCHOR_TOP_RIGHT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 10);
    PostString(oEffectTarget, "Will:" + sTabW  + IntToString(nWill), 10, 12, SCREEN_ANCHOR_TOP_RIGHT, 0.0f, 0xFFFFFFFF, 0xFFFFFF00, 11);
}

void runscript_PStatOnRemoved(object oEffectTarget)
{
    PostString(oEffectTarget, "", 10, 7,  SCREEN_ANCHOR_TOP_RIGHT, 0.01, 0xFFFFFFFF, 0xFFFFFF00, 6);
    PostString(oEffectTarget, "", 10, 8,  SCREEN_ANCHOR_TOP_RIGHT, 0.01, 0xFFFFFFFF, 0xFFFFFF00, 7);
    PostString(oEffectTarget, "", 10, 9,  SCREEN_ANCHOR_TOP_RIGHT, 0.01, 0xFFFFFFFF, 0xFFFFFF00, 8);
    PostString(oEffectTarget, "", 10, 10, SCREEN_ANCHOR_TOP_RIGHT, 0.01, 0xFFFFFFFF, 0xFFFFFF00, 9);
    PostString(oEffectTarget, "", 10, 11, SCREEN_ANCHOR_TOP_RIGHT, 0.01, 0xFFFFFFFF, 0xFFFFFF00, 10);
    PostString(oEffectTarget, "", 10, 12, SCREEN_ANCHOR_TOP_RIGHT, 0.01, 0xFFFFFFFF, 0xFFFFFF00, 11);
}

void runscript_GrtInvOnTick(object oPC)
{
    if(GetHasSpellEffect(SPELL_GREATER_INVISIBILITY_TICK, oPC))
        return;
    // determine effect
    effect eInvis = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
    eInvis = HideEffectIcon(eInvis);
    eInvis = SetEffectSpellId(eInvis, SPELL_GREATER_INVISIBILITY_TICK);
    eInvis = ExtraordinaryEffect(eInvis);
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    // apply effect
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eInvis, oPC, DurationToSeconds(GetLevelByClass(CLASS_TYPE_ROGUE, oPC)));
}

int runscript_GetIconIdForStackableSpell(int nSpell, int nStackLevel)
{
    switch(nSpell)
    {
        case SPELL_REND:
            switch(nStackLevel)
            {
                case 1: return EFFECT_ICON_REND_1;
                case 2: return EFFECT_ICON_REND_2;
                case 3: return EFFECT_ICON_REND_3;
                case 4: return EFFECT_ICON_REND_4;
                case 5: return EFFECT_ICON_REND_5;
            }
        break;
        case SPELL_PLAGUE:
            switch(nStackLevel)
            {
                case 1: return EFFECT_ICON_PLAGUE_1;
                case 2: return EFFECT_ICON_PLAGUE_2;
                case 3: return EFFECT_ICON_PLAGUE_3;
                case 4: return EFFECT_ICON_PLAGUE_4;
                case 5: return EFFECT_ICON_PLAGUE_5;
            }
        break;
        case SPELL_WEAKEN:
            switch(nStackLevel)
            {
                case 1: return EFFECT_ICON_WEAKEN_1;
                case 2: return EFFECT_ICON_WEAKEN_2;
                case 3: return EFFECT_ICON_WEAKEN_3;
                case 4: return EFFECT_ICON_WEAKEN_4;
                case 5: return EFFECT_ICON_WEAKEN_5;
            }
        break;
        case SPELL_MADNESS:
            switch(nStackLevel)
            {
                case 1: return EFFECT_ICON_MADNESS_1;
                case 2: return EFFECT_ICON_MADNESS_2;
                case 3: return EFFECT_ICON_MADNESS_3;
                case 4: return EFFECT_ICON_MADNESS_4;
                case 5: return EFFECT_ICON_MADNESS_5;
            }
        break;
    }
    return FALSE;
}

int runscript_GetTickSpellIdForStackableSpell(int nSpellId)
{
    switch(nSpellId)
    {
        case SPELL_REND:        return SPELL_REND_TICKS;
        case SPELL_PLAGUE:      return SPELL_PLAGUE_TICKS;
        case SPELL_WEAKEN:      return SPELL_WEAKEN_TICKS;
        case SPELL_MADNESS:     return SPELL_MADNESS_TICKS;
    }
    return FALSE;
}

int runscript_GetStackableSpellDuration(int nSpellId)
{
    switch(nSpellId)
    {
        case SPELL_REND:        return 9; // seconds
        case SPELL_PLAGUE:      return 9; // seconds
        case SPELL_WEAKEN:      return 9; // seconds
        case SPELL_MADNESS:     return 9; // seconds
    }
    return FALSE;
}

void runscript_StackableEffectOnTick(object oEffectTarget, effect eRunScriptEffect, int nSpellId)
{
    string sData = GetEffectTag(eRunScriptEffect);
    json jData = JsonParse(sData);
    // sanity check, remove spell if json array is empty
    if(JsonGetLength(jData) == 0)
    {
        RemoveEffectsFromSpell(oEffectTarget, nSpellId);
        return;
    }
    // get current timestamp
    int nCurrentTime = SQLite_GetTimeStamp();
    // iter JsonArray, remove expired values and save actual into jActualizedData
    json jActualizedData = JsonArray();
    int nIter;
    int nDur = runscript_GetStackableSpellDuration(nSpellId);
    for(nIter = 0; nIter <= JsonGetLength(jData) - 1; nIter++)
    {
        json jStoredTime = JsonArrayGet(jData, nIter);
        int nStoredTime = JsonGetInt(jStoredTime);
        if(nCurrentTime - nStoredTime <= nDur)
            JsonArrayInsertInplace(jActualizedData, jStoredTime);
    }
    // get current stack level saved as local var
    int nCurrentStackLevel = GetLocalInt(oEffectTarget, IntToString(nSpellId) + "_STACKS");
    // calc new level with max 5 stack  -- TODO max stack customisable
    int nNewStackLevel = JsonGetLength(jActualizedData);
    nNewStackLevel = nNewStackLevel > 5 ? 5 : nNewStackLevel;
    // if diff with nNewStackLevel and nCurrentStackLevel
    if(nNewStackLevel != nCurrentStackLevel)
    {
        // remove effect with spell icon
        int nTickSpellId = runscript_GetTickSpellIdForStackableSpell(nSpellId);
        RemoveEffectsFromSpell(oEffectTarget, nTickSpellId);
        // determine new icon effect based on nNewStackLevel
        int nUpdatedSpellIcon = runscript_GetIconIdForStackableSpell(nSpellId, nNewStackLevel);
        // if nUpdatedSpellIcon is not false then apply new effect
        if(nUpdatedSpellIcon)
        {
            effect eStack = EffectIcon(nUpdatedSpellIcon);
            eStack = SetEffectSpellId(eStack, nTickSpellId);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eStack, oEffectTarget);
        }
        // store local current stacks count
        SetLocalInt(oEffectTarget, IntToString(nSpellId) + "_STACKS", nNewStackLevel);
        // actualize main effect data
        struct NWNX_EffectUnpacked stUnpackedEff = NWNX_Effect_UnpackEffect(eRunScriptEffect);
        stUnpackedEff.sTag = JsonDump(jActualizedData);
        effect eReplaced = NWNX_Effect_PackEffect(stUnpackedEff);
        NWNX_Effect_ReplaceEffect(oEffectTarget, eRunScriptEffect, eReplaced);
    }
}

void RunScriptSpellShockApplied(object oEffectTarget, int nSpellId)
{
    int nMovementRate = GetMovementRate(oEffectTarget);
    if(!GetIsPC(oEffectTarget))
        SetLocalInt(oEffectTarget, "SHOCK_MOVERATE_SAVE", nMovementRate);
    NWNX_Creature_SetMovementRate(oEffectTarget, CORMYREAN_SPEED_ITEM_USE_SLOW);
}

void RunScriptSpellShockRemoved(object oEffectTarget)
{
    if(!GetIsPC(oEffectTarget))
        NWNX_Creature_SetMovementRate(oEffectTarget, GetLocalInt(oEffectTarget, "SHOCK_MOVERATE_SAVE"));
    else
        NWNX_Creature_SetMovementRate(oEffectTarget, NWNX_CREATURE_MOVEMENT_RATE_PC);
}

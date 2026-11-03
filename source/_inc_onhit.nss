#include "70_inc_spells"
//#include "x2_inc_spellhook"
#include "x0_i0_position"
#include "nw_i0_spells"
#include "_inc_spells"
#include "_inc_sqlite_time"
#include "_inc_fshop_spell"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

//
void onhit_DoPainfulHit(object oAttacker, object oTarget, int nSpellId);

//
void onhit_LastHitHealing(object oKiller, object oVictim, int nSpellId, int bPlayer = FALSE);

//
void onhit_DoDarkStrike(object oAttacker, object oTarget, int nSpellId);

//
void onhit_DoCantSeeMe(object oAttacker, object oTarget);

//
void onhit_DoDarkHit(object oAttacker, object oTarget, int nSpellId);

//
void onhit_DoOpenWoundsMark(object oAttacker, object oTarget, int nSpellId);

//
void onhit_DoOpenWoundsActivate(object oAttacker);

//
void onhit_DoAssasinationMark(object oAttacker, object oTarget, int nSpellId);

//
int onhit_GetHasAssasinationMark(object oAttacker, object oTarget);

//
void onhit_DoCripplingStrikeRogue(object oAttacker, object oTarget, int nSpellId);

//
void onhit_DoStackableEffect(object oAttacker, object oTarget, int nSpellId, int bSelfTarget = FALSE);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////


void onhit_DoPainfulHit(object oAttacker, object oTarget, int nSpellId)
{
    if(SQLite_GetTimeStamp() - GetLocalInt(oAttacker, "LAST_SUCCESSFUL_SNEAK_DEATH_ATTACK") > 1)
        return;
    int nChance = GetLevelByClass(CLASS_TYPE_MONK, oAttacker) + GetLevelByClass(CLASS_TYPE_SHIFTER, oAttacker);
    int nRoll = d100();
    string sMessage = "Painful Hit chance: " + IntToString(nChance) + " vs d100 roll: " + IntToString(nRoll);
    SendColorMessageToPC(oAttacker, sMessage, TXT_COLOR_VIOLET_L);
    SendColorMessageToPC(oTarget, sMessage, TXT_COLOR_VIOLET_L);
    if(nChance < nRoll)
        return;
    int nPenalty = 1 + GetCustomOnhitFameBonus(oAttacker, nSpellId); // fameshop done
    // link penalty effects
    effect ePenalty = EffectACDecrease(nPenalty);
    ePenalty = EffectLinkEffects(EffectSkillDecrease(SKILL_ALL_SKILLS, nPenalty), ePenalty);
    ePenalty = EffectLinkEffects(EffectSavingThrowDecrease(SAVING_THROW_ALL, nPenalty), ePenalty);
    ePenalty = EffectLinkEffects(EffectAttackDecrease(nPenalty), ePenalty);
    ePenalty = EffectLinkEffects(EffectIcon(EFFECT_ICON_PAINFUL_HIT), HideEffectIcon(ePenalty));
    // remove if exists and apply new penalty
    RemoveEffectsFromSpell(oTarget, nSpellId);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePenalty, oTarget, RoundsToSeconds(2));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_BLIND_DEAF_M), oTarget);
    SignalEvent(oTarget, EventSpellCastAt(oAttacker, nSpellId));
    int nVoice;
    switch(d3())
    {
        case 1: nVoice = VOICE_CHAT_PAIN1; break;
        case 2: nVoice = VOICE_CHAT_PAIN2; break;
        case 3: nVoice = VOICE_CHAT_PAIN3; break;
    }
    PlayVoiceChat(nVoice, oTarget);
    // info part
    if (GetIsPC(oAttacker))
        FloatingColorTextStringOnCreature("Painful Hit!", TXT_COLOR_SPECIAL_HIT, oAttacker, TRUE);
    if (GetIsPC(oTarget))
        FloatingColorTextStringOnCreature("Painful Hit!", TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);
}

void onhit_LastHitHealing(object oKiller, object oVictim, int nSpellId, int bPlayer = FALSE)
{
    object oStoredKiller = StringToObject(GetLocalString(oVictim, "LAST_HIT_VICTIM"));
    if(!GetIsObjectValid(oStoredKiller) || oKiller != oStoredKiller)
        return;
    int nHeal = (GetLevelByClass(CLASS_TYPE_SHIFTER, oKiller) - GetAbilityModifier(ABILITY_STRENGTH, oKiller)) * 10;
    if(!bPlayer) nHeal /= 2; // only half if victim is not player
    //SendMessageToPC(oKiller, "nHeal: " + IntToString(nHeal));
    int nMaxHealValue = GetMaxHitPoints(oKiller) - GetCurrentHitPoints(oKiller);
    //SendMessageToPC(oKiller, "nMaxHealValue: " + IntToString(nMaxHealValue));
    nHeal = nHeal > 0 ? nHeal : 0;
    nHeal = nHeal > nMaxHealValue ? nMaxHealValue : nHeal;
    effect eHeal = EffectHeal(nHeal);
    // apply effect and visual
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oKiller);
    // Fire cast spell at event for the specified target
    SignalEvent(oKiller, EventSpellCastAt(oKiller, nSpellId, FALSE));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(CEPVFX_IMP_HEALING_L_PURPLE), oKiller);
}

void onhit_DoDarkStrike(object oAttacker, object oTarget, int nSpellId)
{
    int nChance = GetAbilityModifier(ABILITY_DEXTERITY, oAttacker) / 4 + GetLevelByClass(CLASS_TYPE_ROGUE, oAttacker) / 6 + GetCustomOnhitFameBonus(oAttacker, nSpellId); // fameshop done
    int nRoll = d100();
    string sMessage = "Dark Strike chance: " + IntToString(nChance) + " vs d100 roll: " + IntToString(nRoll);
    SendColorMessageToPC(oAttacker, sMessage, TXT_COLOR_VIOLET_L);
    SendColorMessageToPC(oTarget, sMessage, TXT_COLOR_VIOLET_L);
    if(nChance > nRoll)
    {
        RemoveEffectsFromSpell(oTarget, SPELL_TRUE_SEEING);
        if(GetIsPC(oAttacker))
            FloatingColorTextStringOnCreature("Dark Strike Hit!", TXT_COLOR_SPECIAL_HIT, oAttacker, TRUE);
        if(GetIsPC(oTarget))
            FloatingColorTextStringOnCreature("Dark Strike Hit!", TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);
    }
}

void onhit_DoCantSeeMe(object oAttacker, object oTarget)
{
    int nChance = GetAbilityModifier(ABILITY_DEXTERITY, oAttacker) / 4 + GetLevelByClass(CLASS_TYPE_ROGUE, oAttacker) -
                  GetAbilityModifier(ABILITY_STRENGTH, oAttacker)      - GetLevelByClass(CLASS_TYPE_PALADIN, oAttacker);
    int nRoll = d100();
    string sMessage = "Cant See Me chance: " + IntToString(nChance) + " vs d100 roll: " + IntToString(nRoll);
    SendColorMessageToPC(oAttacker, sMessage, TXT_COLOR_VIOLET_L);
    SendColorMessageToPC(oTarget, sMessage, TXT_COLOR_VIOLET_L);
    if(nChance > nRoll)
    {
        RemoveEffectsFromSpell(oTarget, SPELL_SEE_INVISIBILITY);
        if(GetIsPC(oAttacker))
            FloatingColorTextStringOnCreature("Can't See Me Hit!", TXT_COLOR_SPECIAL_HIT, oAttacker, TRUE);
        if(GetIsPC(oTarget))
            FloatingColorTextStringOnCreature("Can't See Me Hit!", TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);
    }
}

void onhit_DoDarkHit(object oAttacker, object oTarget, int nSpellId)
{
    int nPercentCalc = GetAbilityModifier(ABILITY_DEXTERITY, oAttacker) / 4 + GetLevelByClass(CLASS_TYPE_ASSASSIN, oAttacker) / 6 + GetCustomOnhitFameBonus(oAttacker, nSpellId); // fameshop done
    int nRoll = d100();
    string sMessage = "Dark Hit chance: " + IntToString(nPercentCalc) + " vs d100 roll: " + IntToString(nRoll);
    SendColorMessageToPC(oAttacker, sMessage, TXT_COLOR_VIOLET_L);
    SendColorMessageToPC(oTarget, sMessage, TXT_COLOR_VIOLET_L);
    if(nPercentCalc > nRoll)
    {
        spells_ChangeSpellDuration(oTarget, SPELL_TRUE_SEEING, -IntToFloat(nPercentCalc));
        if(GetIsPC(oAttacker))
            FloatingColorTextStringOnCreature("Dark Hit!", TXT_COLOR_SPECIAL_HIT, oAttacker, TRUE);
        if(GetIsPC(oTarget))
            FloatingColorTextStringOnCreature("Dark Hit!", TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);
    }
}

void onhit_DoOpenWoundsMark(object oAttacker, object oTarget, int nSpellId)
{
    int nChance = GetLevelByClass(CLASS_TYPE_SHIFTER, oAttacker) - GetAbilityModifier(ABILITY_STRENGTH, oAttacker);
    int nRoll = d100();
    string sMessage = "Open Wounds chance: " + IntToString(nChance) + " vs d100 roll: " + IntToString(nRoll);
    SendColorMessageToPC(oAttacker, sMessage, TXT_COLOR_VIOLET_L);
    SendColorMessageToPC(oTarget, sMessage, TXT_COLOR_VIOLET_L);
    if(nChance < nRoll)
        return;
    string sTarget = ObjectToString(oTarget);
    json jOpenWoundsArray = GetLocalJson(oAttacker, "SPELL_OPEN_WOUNDS");
    if(JsonGetType(jOpenWoundsArray) != JSON_TYPE_ARRAY)
        jOpenWoundsArray = JsonArray();
    JsonArrayInsertInplace(jOpenWoundsArray, JsonString(sTarget));
    jOpenWoundsArray = JsonArrayTransform(jOpenWoundsArray, JSON_ARRAY_UNIQUE);
    SetLocalJson(oAttacker, "SPELL_OPEN_WOUNDS", jOpenWoundsArray);
    // calc duration
    int nDur = GetAbilityModifier(ABILITY_DEXTERITY, oAttacker) - GetAbilityModifier(ABILITY_STRENGTH, oAttacker) - 5 + GetCustomOnhitFameBonus(oAttacker, nSpellId); // fameshop done
    // determine effect parameters
    effect eOpenWounds = EffectIcon(EFFECT_ICON_OPEN_WOUNDS);
    eOpenWounds = TagEffect(eOpenWounds, ObjectToString(oAttacker));
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    // remove old effect
    RemoveEffectsFromSpell(oTarget, nSpellId);
    // Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oAttacker, nSpellId));
    // apply effect
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eOpenWounds, oTarget, DurationToSeconds(nDur));
    if(GetIsPC(oAttacker))
        FloatingColorTextStringOnCreature("Open Wounds Hit!", TXT_COLOR_SPECIAL_HIT, oAttacker, TRUE);
    if(GetIsPC(oTarget))
        FloatingColorTextStringOnCreature("Open Wounds Hit!", TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);
}

void onhit_DoAssasinationMark(object oAttacker, object oTarget, int nSpellId)
{
    int nChance = 5 * (GetLevelByClass(CLASS_TYPE_ASSASSIN, oAttacker) + GetLevelByClass(CLASS_TYPE_ROGUE, oAttacker)) / 10;
    int nRoll = d100();
    string sMessage = "Assassination Mark chance: " + IntToString(nChance) + " vs d100 roll: " + IntToString(nRoll);
    SendColorMessageToPC(oAttacker, sMessage, TXT_COLOR_VIOLET_L);
    SendColorMessageToPC(oTarget, sMessage, TXT_COLOR_VIOLET_L);
    if(nChance < nRoll)
        return;
    // determine effect parameters
    int nDur = GetAbilityModifier(ABILITY_DEXTERITY, oAttacker) - GetAbilityModifier(ABILITY_STRENGTH, oAttacker) - 5 + GetCustomOnhitFameBonus(oAttacker, nSpellId); // fameshop done
    effect eAssassinationMark = EffectIcon(EFFECT_ICON_ASSASSINATION_MARK);
    eAssassinationMark = TagEffect(eAssassinationMark, ObjectToString(oAttacker));
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    // remove old effect
    RemoveEffectsFromSpell(oTarget, nSpellId);
    // Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(oAttacker, nSpellId));
    // apply effect
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAssassinationMark, oTarget, DurationToSeconds(nDur));
    if(GetIsPC(oAttacker))
        FloatingColorTextStringOnCreature("Assassination Mark Hit!", TXT_COLOR_SPECIAL_HIT, oAttacker, TRUE);
    if(GetIsPC(oTarget))
        FloatingColorTextStringOnCreature("Assassination Mark Hit!", TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);
}

int onhit_GetHasAssasinationMark(object oAttacker, object oTarget)
{
    effect eLoop = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eLoop))
    {
        if(GetEffectSpellId(eLoop) == SPELL_ASSASSINATION_MARK)
        {
            string sTag = GetEffectTag(eLoop);
            if(sTag == ObjectToString(oAttacker))
                return TRUE;
        }
        eLoop = GetNextEffect(oTarget);
    }
    return FALSE;
}

void onhit_DoCripplingStrikeRogue(object oAttacker, object oTarget, int nSpellId)
{
    if(SQLite_GetTimeStamp() - GetLocalInt(oAttacker, "LAST_SUCCESSFUL_SNEAK_DEATH_ATTACK") > 1)
        return;
    // base decrease
    int nBase = 3;
    // if STR mod > 0 change base to 2
    if(GetAbilityModifier(ABILITY_STRENGTH, oAttacker) > 10)
        nBase = 2;
    int nStrDecr = nBase + GetLocalInt(oTarget, "CRIPPLING_STRIKE_ROGUE"); // base + stored
    effect eStrDecr = EffectAbilityDecrease(ABILITY_STRENGTH, nStrDecr);
    effect eVis = EffectVisualEffect(GAOVFX_IMP_NEGATIVE_ENERGY_RED);
    // apply effect
    SetLocalInt(oTarget, "CRIPPLING_STRIKE_ROGUE", nStrDecr);
    SignalEvent(oTarget, EventSpellCastAt(oAttacker, nSpellId));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eStrDecr, oTarget);
}


void onhit_DoStackableEffect(object oAttacker, object oTarget, int nSpellId, int bSelfTarget = FALSE)
{
    int nCurrentTimeStamp = SQLite_GetTimeStamp();
    string sData;
    int nEffectExists = FALSE;
    // if selfbuff onhit
    if(bSelfTarget)
        oTarget = oAttacker;
    // find stackable effect
    effect eStackable = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eStackable))
    {
        if(GetEffectSpellId(eStackable) == nSpellId)
        {
            sData = GetEffectTag(eStackable);
            nEffectExists = TRUE;
            break;
        }
        eStackable = GetNextEffect(oTarget);
    }
    // try to parse!
    json jData = JsonParse(sData);
    // if no stackable effect create new!
    if(JsonGetType(jData) != JSON_TYPE_ARRAY)
        jData = JsonArray();
    // insert new timestamp in array
    JsonArrayInsertInplace(jData, JsonInt(nCurrentTimeStamp));
    // generate new Tag
    sData = JsonDump(jData);
    //ServerShout(sData);

    // determine new effect or replace old
    if(!nEffectExists)
    {
        effect eApply = TagEffect(EffectRunScript("","_mod_runscript", "_mod_runscript", 0.5), sData);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eApply), oTarget, DURATION_SERVER_SESSION);
    }
    else // override old effect
    {
        struct NWNX_EffectUnpacked stUnpackedEff = NWNX_Effect_UnpackEffect(eStackable);
        stUnpackedEff.sTag = sData;
        effect eReplaced = NWNX_Effect_PackEffect(stUnpackedEff);
        NWNX_Effect_ReplaceEffect(oTarget, eStackable, eReplaced);
    }
}

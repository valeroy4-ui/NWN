#include "70_inc_spells"
#include "x0_i0_spells"
#include "_inc_sqlocals"
#include "_inc_sqlite_time"
#include "_inc_spells"
#include "_inc_generic"
#include "_inc_classes"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

//
void spellike_DoThreateningCry();

//
void spellike_DoOpenWoundsActivate();

//
void spellike_DoHeroicPower();

//
void spellike_DoHarperClairvoyance();

//
void spellike_DoHarperInvisibility();

//
void spellike_DoHarperHeroicShield();

//
void spellike_DoHarperMight();

//
void spellike_GreaterInvisibility();

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void spellike_DoThreateningCry()
{
    spell.Level = GetLevelByClass(CLASS_TYPE_BARBARIAN, spell.Caster) + GetLevelByClass(CLASS_TYPE_FIGHTER, spell.Caster) + GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, spell.Caster);
    spell.Range = 3.0 + spell.Level * 0.3;

    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    effect eVisCaster = EffectVisualEffect(VFX_IMP_PDK_GENERIC_PULSE);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisCaster, spell.Caster);
    PlayVoiceChat(VOICE_CHAT_THREATEN, spell.Caster);
    int bTimeOut = FALSE;

    effect eVisImpTarget = EffectVisualEffect(VFX_IMP_PDK_RALLYING_CRY);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    int nDuration = 1 + spell.Level/10;
    effect eVisDurTarget = EffectVisualEffect(VFX_DUR_AURA_PULSE_MAGENTA_BLACK);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster) && spell.Caster != oTarget &&
           !players_GetFactionsEqual(oTarget, spell.Caster)/* && !GetIsPC(oTarget) */ )
        {
            bTimeOut = TRUE;
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisImpTarget, oTarget);
            if(!GetIsPC(oTarget))
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVisDurTarget, oTarget, DurationToSeconds(nDuration));
                SQLocals_SetObject(oTarget, "CORMYR_AI_GLOBAL_TARGET_OVERRIDE", spell.Caster);
                SetLocalInt(oTarget, "CORMYR_AI_GLOBAL_TARGET_OVERRIDE_DURATION", nDuration * 6);
            }
            effect eThreatCry = EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", 0.0, FloatToString(1.0 - IntToFloat(spell.Level)/200.0));
            eThreatCry = EffectLinkEffects(EffectIcon(EFFECT_ICON_THREATENING_CRY), eThreatCry);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eThreatCry, oTarget, DurationToSeconds(nDuration));
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    }
    if(bTimeOut)
        spells_SetSpellCooldown(spell.Id, spell.Caster, GetSpellTimeoutDuration(spell.Id));
}


void spellike_DoOpenWoundsActivate()
{
    json jOpenWoundsArray = GetLocalJson(spell.Caster, "SPELL_OPEN_WOUNDS");
    if(JsonGetType(jOpenWoundsArray) != JSON_TYPE_ARRAY)
        return;
    //SendMessageToPC(oAttacker, JsonDump(jOpenWoundsArray));
    int nRange = JsonGetLength(jOpenWoundsArray);
    int i;
    for (i = 0; i < nRange; i++)
    {
        object oTarget = StringToObject(JsonGetString(JsonArrayGet(jOpenWoundsArray, i)));
        //SendMessageToPC(oAttacker, GetName(oTarget));
        if(!GetIsObjectValid(oTarget))
            continue;
        effect eLoop = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eLoop))
        {
            if(GetEffectSpellId(eLoop) == SPELL_OPEN_WOUNDS)
            {
                 string sTag = GetEffectTag(eLoop);
                 //SendMessageToPC(oAttacker, "Effect Found!");
                 if(sTag == ObjectToString(spell.Caster))
                 {
                    int nDamage = (GetLevelByClass(CLASS_TYPE_SHIFTER, spell.Caster) / 2) * 5;
                    nDamage = nDamage > 0 ? nDamage : 0;
                    if(nDamage)
                    {
                        effect eDamage = EffectDamage(nDamage, DAMAGE_TYPE_PIERCING);
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY), oTarget);
                    }
                    RemoveEffectsFromSpell(oTarget, SPELL_OPEN_WOUNDS);
                 }
            }
            eLoop = GetNextEffect(oTarget);
        }
    }
    DeleteLocalJson(spell.Caster, "SPELL_OPEN_WOUNDS");
    spells_SetSpellCooldown(spell.Id, spell.Caster, 2.0, CORMYR_SPELL_COOLDOWN_DONT_SHOW_MESSAGES);
}


void spellike_DoHeroicPower()
{
    // calc main class
    json jClasses = JsonArray();
    JsonArrayInsertInplace(jClasses, JsonInt(GetLevelByClass(CLASS_TYPE_BARD)));
    JsonArrayInsertInplace(jClasses, JsonInt(GetLevelByClass(CLASS_TYPE_FIGHTER)));
    JsonArrayInsertInplace(jClasses, JsonInt(GetLevelByClass(CLASS_TYPE_ROGUE)));
    JsonArrayInsertInplace(jClasses, JsonInt(GetLevelByClass(CLASS_TYPE_ASSASSIN)));
    JsonArrayInsertInplace(jClasses, JsonInt(GetLevelByClass(CLASS_TYPE_SHIFTER)));
    JsonArrayInsertInplace(jClasses, JsonInt(GetLevelByClass(CLASS_TYPE_WEAPON_MASTER)));
    json jClassesSorted = JsonArrayTransform(jClasses, JSON_ARRAY_SORT_DESCENDING);
    int nMainClass = JsonGetInt(JsonArrayGet(jClassesSorted, 0));

    // calc main ability
    json jAbilitiesMods = JsonArray();
    JsonArrayInsertInplace(jAbilitiesMods, JsonInt(GetAbilityModifier(ABILITY_CHARISMA)));
    JsonArrayInsertInplace(jAbilitiesMods, JsonInt(GetAbilityModifier(ABILITY_CONSTITUTION)));
    JsonArrayInsertInplace(jAbilitiesMods, JsonInt(GetAbilityModifier(ABILITY_DEXTERITY)));
    JsonArrayInsertInplace(jAbilitiesMods, JsonInt(GetAbilityModifier(ABILITY_INTELLIGENCE)));
    JsonArrayInsertInplace(jAbilitiesMods, JsonInt(GetAbilityModifier(ABILITY_STRENGTH)));
    JsonArrayInsertInplace(jAbilitiesMods, JsonInt(GetAbilityModifier(ABILITY_WISDOM)));
    json jAbilitiesModsSorted = JsonArrayTransform(jAbilitiesMods, JSON_ARRAY_SORT_DESCENDING);
    int nMainAbilityMod = JsonGetInt(JsonArrayGet(jAbilitiesModsSorted, 0));

    // calculate attack bonus value
    int nBonus = nMainClass / 6;
    // calculate duration value
    int nDur = nMainAbilityMod + 10;

    // if RDD main class when override nBonus value
    int nCheckRddClass = class_GetMainClass(spell.Caster);
    if(nCheckRddClass == CLASS_TYPE_DRAGON_DISCIPLE)
        nBonus = (GetLevelByClass(nCheckRddClass, spell.Caster) - 10) / 5;
    // remove prev effects
    RemoveEffectsFromSpell(spell.Caster, spell.Id);
    // sanity check
    if(nBonus <= 0) return;
    // else apply effects
    effect eAB = EffectLinkEffects(HideEffectIcon(EffectAttackIncrease(nBonus)), EffectIcon(EFFECT_ICON_HARPER_HEROIC_POWER));
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eAB), spell.Caster, RoundsToSeconds(nDur) * 2);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Caster);
    SendColorMessageToPC(spell.Caster, "+" + IntToString(nBonus) + " Attack Bonus.", TXT_COLOR_GREEN_L);
}

void spellike_DoHarperClairvoyance()
{
    object oTarget = spell.Target;
    object oCaster = spell.Caster;
    int nStrBonus = GetAbilityModifier(ABILITY_STRENGTH, oCaster);
    effect eListen = EffectSkillIncrease(SKILL_LISTEN, 10);
    effect eSpot = EffectSkillIncrease(SKILL_SPOT, 10);
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    effect eLink = EffectLinkEffects(eListen, eSpot);
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_HARPER_CLAIRVOYANCE), HideEffectIcon(eLink));

    eLink = ExtraordinaryEffect(eLink);
    RemoveEffectsFromSpell(oTarget,GetSpellId());
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nStrBonus) * 2);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
}

void spellike_DoHarperInvisibility()
{
    object oTarget = spell.Target;
    object oCaster = spell.Caster;
    int iConcealment = 40;
    int nStrBonus = GetAbilityModifier(ABILITY_STRENGTH,oCaster);
    effect eImpact = EffectVisualEffect(VFX_IMP_HEAD_MIND);
    effect eInvisibily = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
    effect eVisusal = EffectVisualEffect(VFX_DUR_INVISIBILITY);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eConcealment = EffectLinkEffects(eDuration, EffectConcealment(iConcealment));
    eConcealment = EffectLinkEffects(EffectIcon(EFFECT_ICON_HARPER_INVISIBILITY), HideEffectIcon(eConcealment));
    RemoveEffectsFromSpell(oTarget, GetSpellId());
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eConcealment, oTarget, RoundsToSeconds(nStrBonus)*2);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eInvisibily, oTarget, RoundsToSeconds(nStrBonus)*2);
}

void spellike_DoHarperHeroicShield()
{
    object oTarget = spell.Target;
    object oCaster = spell.Caster;

    int nStrMod   = GetAbilityModifier(ABILITY_STRENGTH, oCaster);
    int nAC = GetLevelByClass(CLASS_TYPE_HARPER, oCaster);

    effect eLink = EffectLinkEffects(EffectACIncrease(nAC), EffectVisualEffect(HGVFX_DUR_ENERGY_ADAPTATION_RED));
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_HARPER_HEROIC_SHIELD), HideEffectIcon(eLink));
    eLink = ExtraordinaryEffect(eLink);
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);

    // don't work if dex >= 20
    if(GetAbilityScore(oCaster, ABILITY_DEXTERITY, TRUE) >= 20)
    {
        SendMessageToPC(oCaster, "You are not allowed to use this ability with a base dexterity above 20.");
        return;
    }
    // don't work if dex >= 20
    if(GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER, oCaster))
    {
        SendMessageToPC(oCaster, "You are not allowed to use this ability with Warlord class.");
        return;
    }
    if(nStrMod)
    {
        RemoveEffectsFromSpell(oTarget, SPELL_DIVINE_SHIELD);
        RemoveEffectsFromSpell(oTarget, GetSpellId());
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nStrMod) * 2);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        SendColorMessageToPC(oCaster, "+" + IntToString(nAC) + " Dodge AC.", TXT_COLOR_GREEN_L);
    }
}

void spellike_DoHarperMight()
{
    object oTarget = spell.Target;
    object oCaster = spell.Caster;

    int iAbilityBonusStrength = GetAbilityModifier(ABILITY_STRENGTH, oCaster);

    effect eDamage = EffectDamageIncrease(GetDamageBonusConstantFromNumber(iAbilityBonusStrength/2));

    eDamage = EffectLinkEffects(EffectIcon(EFFECT_ICON_HARPER_HEROIC_MIGHT), HideEffectIcon(eDamage));

    eDamage = ExtraordinaryEffect(eDamage);
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    RemoveEffectsFromSpell(oTarget, GetSpellId());
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDamage, oTarget, RoundsToSeconds(iAbilityBonusStrength * 2));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    SendColorMessageToPC(oTarget,"Harper Scout damage bonus: +" + IntToString(iAbilityBonusStrength/2) +
        " magic damage", TXT_COLOR_GREEN_L);
}

void spellike_GreaterInvisibility()
{
    // mod_str > mod_dex -> nahyi
    if(GetAbilityModifier(ABILITY_STRENGTH, spell.Caster) > GetAbilityModifier(ABILITY_DEXTERITY, spell.Caster))
        return;
    int nDur = GetLevelByClass(CLASS_TYPE_ROGUE, spell.Caster);
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    RemoveEffectsFromSpell(spell.Caster, spell.Id);
    effect eGrtInvis = EffectRunScript("", "_mod_runscript", "_mod_runscript", 0.5);
    eGrtInvis = EffectLinkEffects(EffectIcon(EFFECT_ICON_GREATER_INVISIBILITY), eGrtInvis);
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGrtInvis, spell.Caster, DurationToSeconds(nDur));
}

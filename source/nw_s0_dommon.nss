#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

const int DOMMON_SPELL_LEVEL = 9;

// Глиф заменяет фокусы на +6, без складывания.
int DOMMON_GetFocusBonus(object oCaster)
{
    if (GetLocalInt(oCaster, "DOMMON_GLYPH_EPIC") == 1)
        return 6;

    int nBonus = 0;

    if (GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION, oCaster))
        nBonus += 1;

    if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION, oCaster))
        nBonus += 2;

    if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION, oCaster))
        nBonus += 3;

    return nBonus;
}

// Good domain: только при касте клериком.
// +1 за два CL после 23, максимум +8.
int DOMMON_GetDomainBonus(object oCaster,
                         int nCastingClass, int nCasterLevel)
{
    if (nCastingClass != CLASS_TYPE_CLERIC)
        return 0;

    if (GetDomain(oCaster, 1, CLASS_TYPE_CLERIC) != DOMAIN_GOOD
        && GetDomain(oCaster, 2, CLASS_TYPE_CLERIC) != DOMAIN_GOOD)
        return 0;

    if (nCasterLevel <= 23)
        return 0;

    int nBonus = (nCasterLevel - 23) / 2;

    if (nBonus > 8)
        nBonus = 8;

    return nBonus;
}

// Только при касте бардом:
// CL30: +1; CL31: +2; максимум +11 с CL40.
int DOMMON_GetBardBonus(int nCastingClass, int nCasterLevel)
{
    if (nCastingClass != CLASS_TYPE_BARD || nCasterLevel <= 29)
        return 0;

    int nBonus = nCasterLevel - 29;

    if (nBonus > 11)
        nBonus = 11;

    return nBonus;
}

void DOMMON_ReportEffect(object oCaster, object oTarget,
                         int nSpellId, string sStage)
{
    if (!GetIsObjectValid(oCaster) || !GetIsPC(oCaster))
        return;

    if (!GetIsObjectValid(oTarget))
    {
        SendMessageToPC(oCaster,
            "Dominate check: target no longer exists.");
        return;
    }

    int bFound = FALSE;
    effect eCheck = GetFirstEffect(oTarget);

    while (GetIsEffectValid(eCheck))
    {
        if (GetEffectType(eCheck) == EFFECT_TYPE_DOMINATED
            && GetEffectSpellId(eCheck) == nSpellId
            && GetEffectCreator(eCheck) == oCaster)
        {
            bFound = TRUE;
            break;
        }

        eCheck = GetNextEffect(oTarget);
    }

    SendMessageToPC(oCaster,
        "Dominate check [" + sStage
        + "]: effect present=" + IntToString(bFound)
        + " MindImmune="
        + IntToString(GetIsImmune(
            oTarget, IMMUNITY_TYPE_MIND_SPELLS)));
}

void main()
{
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
        return;

    spellsDeclareMajorVariables();
    spell.SavingThrow = SAVING_THROW_WILL;

    int nCastingClass = GetLastSpellCastClass();
    int nCasterLevel = GetCasterLevel(spell.Caster);

    int nWisMod = GetAbilityModifier(ABILITY_WISDOM, spell.Caster);
    int nChaMod = GetAbilityModifier(ABILITY_CHARISMA, spell.Caster);
    int nAbilityMod = nWisMod;

    if (nChaMod > nAbilityMod)
        nAbilityMod = nChaMod;

    int nFocusBonus = DOMMON_GetFocusBonus(spell.Caster);

    // Сохраняем прежние правила этих классовых бонусов.
    int nDruidBonus = 0;
    int nSorcBonus = 0;

    int nDomainBonus = DOMMON_GetDomainBonus(
        spell.Caster, nCastingClass, nCasterLevel);

    int nBardBonus = DOMMON_GetBardBonus(
        nCastingClass, nCasterLevel);

    spell.DC = 10 + nAbilityMod + DOMMON_SPELL_LEVEL
        + nFocusBonus + nDruidBonus + nDomainBonus
        + nBardBonus + nSorcBonus;

    // Целочисленное деление: 60 секунд за полные два CL.
    // Extend и дополнительные преобразования не применяются.
    float fDuration =
        180.0 + 60.0 * IntToFloat(nCasterLevel / 2);

    // Диагностика для тестирования.
    if (GetIsPC(spell.Caster))
    {
        SendMessageToPC(spell.Caster,
            "Dominate setup: ID=" + IntToString(spell.Id)
            + " School=" + Get2DAString("spells", "School", spell.Id)
            + " Wiz_Sorc=" + Get2DAString("spells", "Wiz_Sorc", spell.Id)
            + " Range=" + Get2DAString("spells", "Range", spell.Id)
            + " MetaMagic=" + Get2DAString("spells", "MetaMagic", spell.Id)
            + " Timeout(table)="
            + Get2DAString("spells", "Timeout", spell.Id));

        SendMessageToPC(spell.Caster,
            "Dominate DC: Class=" + IntToString(nCastingClass)
            + " CL=" + IntToString(nCasterLevel)
            + " WIS=" + IntToString(nWisMod)
            + " CHA=" + IntToString(nChaMod)
            + " SpellLevel=" + IntToString(DOMMON_SPELL_LEVEL)
            + " GlyphActive="
            + IntToString(
                GetLocalInt(spell.Caster, "DOMMON_GLYPH_EPIC") == 1)
            + " Focus/Glyph=" + IntToString(nFocusBonus)
            + " Druid=" + IntToString(nDruidBonus)
            + " Domain=" + IntToString(nDomainBonus)
            + " Bard=" + IntToString(nBardBonus)
            + " Sorc=" + IntToString(nSorcBonus)
            + " DC=" + IntToString(spell.DC));

        SendMessageToPC(spell.Caster,
            "Dominate duration="
            + FloatToString(fDuration, 1, 1)
            + " sec; no Extend; no target scaling.");
    }

    if (!spellsIsTarget(
        spell.Target, spell.TargetType, spell.Caster))
        return;

    // Флаг события сохранён из исходника.
    SignalEvent(spell.Target, EventSpellCastAt(
        spell.Caster, spell.Id, FALSE));

    // Мантла/сопротивление проверяются перед спасброском.
    if (MyResistSpell(spell.Caster, spell.Target))
        return;

    int bSaved = MySavingThrow(
        SAVING_THROW_WILL, spell.Target, spell.DC,
        SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster);

    if (GetIsPC(spell.Caster))
    {
        if (bSaved)
            SendMessageToPC(spell.Caster,
                "Dominate: target passed Will save.");
        else
            SendMessageToPC(spell.Caster,
                "Dominate: target failed Will save.");
    }

    if (bSaved)
        return;

    // Именно Dominate, без подмены через GetScaledEffect.
    effect eDom = EffectDominated();
    effect eMind =
        EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DOMINATED);
    effect eDur =
        EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eLink = EffectLinkEffects(eMind, eDom);
    eLink = EffectLinkEffects(eLink, eDur);

    ApplyEffectToObject(
        DURATION_TYPE_TEMPORARY,
        eLink, spell.Target, fDuration);

    ApplyEffectToObject(
        DURATION_TYPE_INSTANT,
        EffectVisualEffect(VFX_IMP_DOMINATE_S), spell.Target);

    DelayCommand(0.2, DOMMON_ReportEffect(
        spell.Caster, spell.Target, spell.Id, "after cast"));

    DelayCommand(fDuration - 0.5, DOMMON_ReportEffect(
        spell.Caster, spell.Target, spell.Id, "before expiry"));

    DelayCommand(fDuration + 0.5, DOMMON_ReportEffect(
        spell.Caster, spell.Target, spell.Id, "after expiry"));

    // TODO SPELL HOOK:
    // Добавить КД 30 секунд для SPELL_DOMINATE_MONSTER.
    // Timeout строки 44 spells.2da выставить в 30.
    // Здесь КД не записывается: подключается отдельно.
    //
    // TODO CDR RUNE:
    // Снижение КД на Random(7)+6 секунд.
    // Руны пока нет; реализация будет в отдельной библиотеке.
}

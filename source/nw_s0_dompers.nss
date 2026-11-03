// Dominate Person.
// DC = 10 + max(WIS_mod, CHA_mod) + spell level
//      + focuses/glyph + class bonuses.
// Duration = 12 + 6 * floor(caster level / 3) seconds.
// No Extend, no target scaling, no 1-second application delay.

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "dom_pc_test"

const int DOMPERS_BARD_SPELL_LEVEL = 4;
const int DOMPERS_SORC_SPELL_LEVEL = 5;

// Глиф заменяет фокусы на +6.
int DOMPERS_GetFocusBonus(object oCaster)
{
    if (GetLocalInt(oCaster, "DOMPERS_GLYPH_EPIC") == 1)
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
int DOMPERS_GetDomainBonus(object oCaster,
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

// Только при касте бардом.
// CL30: +1; далее +1 за CL, максимум +11 с CL40.
int DOMPERS_GetBardBonus(int nCastingClass, int nCasterLevel)
{
    if (nCastingClass != CLASS_TYPE_BARD || nCasterLevel <= 29)
        return 0;

    int nBonus = nCasterLevel - 29;

    if (nBonus > 11)
        nBonus = 11;

    return nBonus;
}

// Диагностика наличия эффекта и его окончания.
// Не переколдовывать на ту же цель во время теста срока.
void DOMPERS_ReportEffect(object oCaster, object oTarget,
                         int nSpellId, string sStage)
{
    if (!GetIsObjectValid(oCaster) || !GetIsPC(oCaster))
        return;

    if (!GetIsObjectValid(oTarget))
    {
        SendMessageToPC(oCaster,
            "Dominate Person check: target no longer exists.");
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
        "Dominate Person check [" + sStage
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

    // Бард: 4-й круг. Чародей/волшебник: 5-й.
    int nSpellLevel = DOMPERS_SORC_SPELL_LEVEL;
    if (nCastingClass == CLASS_TYPE_BARD)
        nSpellLevel = DOMPERS_BARD_SPELL_LEVEL;

    int nCasterLevel = GetCasterLevel(spell.Caster);
    int nWisMod = GetAbilityModifier(ABILITY_WISDOM, spell.Caster);
    int nChaMod = GetAbilityModifier(ABILITY_CHARISMA, spell.Caster);
    int nAbilityMod = nWisMod;

    if (nChaMod > nAbilityMod)
        nAbilityMod = nChaMod;

    int nFocusBonus = DOMPERS_GetFocusBonus(spell.Caster);
    int nDruidBonus = 0;
    int nSorcBonus = 0;

    int nDomainBonus = DOMPERS_GetDomainBonus(
        spell.Caster, nCastingClass, nCasterLevel);

    int nBardBonus = DOMPERS_GetBardBonus(
        nCastingClass, nCasterLevel);

    spell.DC = 10 + nAbilityMod + nSpellLevel + nFocusBonus
        + nDruidBonus + nDomainBonus + nBardBonus + nSorcBonus;

    // Прибавка 6 секунд за каждые полные три caster level.
    float fDuration =
        12.0 + 6.0 * IntToFloat(nCasterLevel / 3);

    int bHumanoid = AmIAHumanoid(spell.Target);

    // Диагностика таблицы и расчёта.
    if (GetIsPC(spell.Caster))
    {
        SendMessageToPC(spell.Caster,
            "Dominate Person setup: ID=" + IntToString(spell.Id)
            + " School=" + Get2DAString("spells", "School", spell.Id)
            + " Bard=" + Get2DAString("spells", "Bard", spell.Id)
            + " Wiz_Sorc=" + Get2DAString("spells", "Wiz_Sorc", spell.Id)
            + " Range=" + Get2DAString("spells", "Range", spell.Id)
            + " MetaMagic=" + Get2DAString("spells", "MetaMagic", spell.Id)
            + " Timeout(table)="
            + Get2DAString("spells", "Timeout", spell.Id));

        SendMessageToPC(spell.Caster,
            "Dominate Person DC: Class=" + IntToString(nCastingClass)
            + " CL=" + IntToString(nCasterLevel)
            + " WIS=" + IntToString(nWisMod)
            + " CHA=" + IntToString(nChaMod)
            + " SpellLevel=" + IntToString(nSpellLevel)
            + " GlyphActive="
            + IntToString(
                GetLocalInt(spell.Caster, "DOMPERS_GLYPH_EPIC") == 1)
            + " Focus/Glyph=" + IntToString(nFocusBonus)
            + " Druid=" + IntToString(nDruidBonus)
            + " Domain=" + IntToString(nDomainBonus)
            + " Bard=" + IntToString(nBardBonus)
            + " Sorc=" + IntToString(nSorcBonus)
            + " DC=" + IntToString(spell.DC));

        SendMessageToPC(spell.Caster,
            "Dominate Person duration="
            + FloatToString(fDuration, 1, 1)
            + " sec; no Extend; no target scaling.");

        SendMessageToPC(spell.Caster,
            "Target Humanoid=" + IntToString(bHumanoid)
            + " MindImmune="
            + IntToString(GetIsImmune(
                spell.Target, IMMUNITY_TYPE_MIND_SPELLS)));
    }

    if (!spellsIsTarget(
        spell.Target, spell.TargetType, spell.Caster))
        return;

    SignalEvent(spell.Target, EventSpellCastAt(
        spell.Caster, spell.Id, FALSE));

    // Person работает только по целям, допускаемым AmIAHumanoid.
    if (!bHumanoid)
    {
        if (GetIsPC(spell.Caster))
            SendMessageToPC(spell.Caster,
                "Dominate Person: invalid target (not humanoid).");
        return;
    }

    // Поглощение и сопротивление до спасброска и контроля.
    if (MyResistSpell(spell.Caster, spell.Target))
        return;

    int bSaved = MySavingThrow(
        SAVING_THROW_WILL, spell.Target, spell.DC,
        SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster);

    if (GetIsPC(spell.Caster))
    {
        if (bSaved)
            SendMessageToPC(spell.Caster,
                "Dominate Person: target passed Will save.");
        else
            SendMessageToPC(spell.Caster,
                "Dominate Person: target failed Will save.");
    }

    if (bSaved)
        return;

    // Нативный Dominate без масштабирования и задержки.
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

    AssignCommand(GetModule(), DelayCommand(0.2,
        DOMPC_TestStart(spell.Caster, spell.Target, spell.Id)));

    ApplyEffectToObject(
        DURATION_TYPE_INSTANT,
        EffectVisualEffect(VFX_IMP_DOMINATE_S), spell.Target);

    // Автоматическая диагностика срока.
    DelayCommand(0.2, DOMPERS_ReportEffect(
        spell.Caster, spell.Target, spell.Id, "after cast"));

    DelayCommand(fDuration - 0.5, DOMPERS_ReportEffect(
        spell.Caster, spell.Target, spell.Id, "before expiry"));

    DelayCommand(fDuration + 0.5, DOMPERS_ReportEffect(
        spell.Caster, spell.Target, spell.Id, "after expiry"));

    // TODO SPELL HOOK:
    // Добавить КД 30 секунд для SPELL_DOMINATE_PERSON.
    // Timeout строки 45 spells.2da выставить в 30.
    // Здесь КД не записывается: подключается отдельно.
    //
    // TODO CDR RUNE:
    // Снижение КД на Random(7)+6 секунд.
    // Руны пока нет; реализация будет в отдельной библиотеке.
}

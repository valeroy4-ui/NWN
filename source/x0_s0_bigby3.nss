// Bigby's Grasping Hand.
// Roll = caster level + CHA modifier + Conjuration focuses + d20.
// Roll must be strictly greater than target AC.
// Paralysis duration: 6 seconds.

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_colortext"

const float BGH_DURATION = 6.0;

// Фокусы складываются: +1 +2 +3 = +6.
// Глиф даёт +6 вместо фокусов, без складывания.
int BIGBY3_GetFocusBonus(object oCaster)
{
    if (GetLocalInt(oCaster, "BIGBY_GLYPH_EPIC") == 1)
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

void main()
{
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
        return;

    spellsDeclareMajorVariables();

        // Временная диагностика для тестирования.
    if (GetIsPC(spell.Caster))
    {
        SendMessageToPC(spell.Caster,
            "Grasping setup: ID=" + IntToString(spell.Id)
            + " School=" + Get2DAString("spells", "School", spell.Id)
            + " Wiz_Sorc=" + Get2DAString("spells", "Wiz_Sorc", spell.Id)
            + " Range=" + Get2DAString("spells", "Range", spell.Id)
            + " Timeout(table)=" + Get2DAString("spells", "Timeout", spell.Id));

        SendMessageToPC(spell.Caster,
            "Conj feats (1=yes, 0=no): SF="
            + IntToString(GetHasFeat(
                FEAT_SPELL_FOCUS_CONJURATION, spell.Caster))
            + " GSF="
            + IntToString(GetHasFeat(
                FEAT_GREATER_SPELL_FOCUS_CONJURATION, spell.Caster))
            + " ESF="
            + IntToString(GetHasFeat(
                FEAT_EPIC_SPELL_FOCUS_CONJURATION, spell.Caster)));

        SendMessageToPC(spell.Caster,
            "Target paralysis immunity="
            + IntToString(GetIsImmune(
                spell.Target, IMMUNITY_TYPE_PARALYSIS))
            + "; effect duration="
            + FloatToString(BGH_DURATION, 1, 1) + " sec");
    }

    // Сохраняем ограничения дружественной цели и Time Stop.
    if (GetIsReactionTypeFriendly(spell.Target)
        || spells_GetHasTimeStopEffect(spell.Caster, spell.Target))
        return;

    SignalEvent(spell.Target, EventSpellCastAt(
        spell.Caster, spell.Id, TRUE));

    // Общая проверка поглощения и сопротивления до эффекта.
    if (MyResistSpell(spell.Caster, spell.Target))
        return;

    // Иммунитет к параличу не обходим.
    if (GetIsImmune(spell.Target, IMMUNITY_TYPE_PARALYSIS))
    {
        FloatingColorTextStringOnCreature(
            "*Target has immunity to paralysis*",
            TXT_COLOR_RED, spell.Caster);
        return;
    }

    int nCasterLevel = GetCasterLevel(spell.Caster);
    int nChaMod = GetAbilityModifier(ABILITY_CHARISMA, spell.Caster);
    int nFocusBonus = BIGBY3_GetFocusBonus(spell.Caster);
    int nDieRoll = d20();

    int nCasterRoll =
        nCasterLevel + nChaMod + nFocusBonus + nDieRoll;

    int nTargetAC = GetAC(spell.Target);

    // Ничья — промах.
    // Одна проверка для сообщений и применения эффекта.
    int bHit = (nCasterRoll > nTargetAC);
    string sSuffix = bHit ? " *hit*" : " *missed*";



    if (GetIsPC(spell.Target))
    {
        SendMessageToPC(spell.Target, ColorText(
            "Bigby's Grasping Hand: your AC "
            + IntToString(nTargetAC)
            + ", caster roll " + IntToString(nCasterRoll)
            + sSuffix,
            TXT_COLOR_VIOLET_L));
    }

    if (!bHit)
    {
        FloatingColorTextStrRefOnCreature(
            83309, TXT_COLOR_RED, spell.Caster);
        return;
    }

    // Настоящий паралич вместо CutsceneImmobilize.
    effect eParalyze = EffectParalyze();

    effect eLink = EffectLinkEffects(
        eParalyze,
        EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE));

    eLink = EffectLinkEffects(
        EffectVisualEffect(VFX_DUR_BIGBYS_GRASPING_HAND),
        eLink);

    eLink = EffectLinkEffects(
        EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED),
        eLink);

    ApplyEffectToObject(
        DURATION_TYPE_TEMPORARY,
        eLink, spell.Target, BGH_DURATION);

    FloatingColorTextStrRefOnCreature(
        2478, TXT_COLOR_GREEN_L, spell.Caster);

    // TODO SPELL HOOK:
    // Добавить КД 36 секунд для SPELL_BIGBYS_GRASPING_HAND.
    // Timeout строки 461 spells.2da уже равен 36.
    // Здесь spells_SetSpellCooldown не вызывается,
    // чтобы не дублировать запись КД из отдельного spell hook.
    //
    // TODO CDR RUNE:
    // Случайное снижение КД на Random(7)+6 секунд.
    // Руны пока нет. Реализация будет в отдельной библиотеке.
}

// Bigby's Clenched Fist.
// Бросок: caster level + CHA modifier + фокусы/глиф + d20.
// Попадание: строго больше AC. Обездвиживание: 6 секунд.

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x2_i0_spells"
#include "_inc_colortext"
#include "_inc_spells"

// Глиф заменяет фокусы на +6 и не складывается с ними.
// Флаг устанавливается на персонаже системой глифов.
int BIGBY4_GetFocusBonus(object oCaster)
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
    // Метаданные исходника для библиотек модуля.
    // Сам скрипт не наносит урон и не вызывает спасбросок.
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_BLUDGEONING;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
        return;

    spellsDeclareMajorVariables();

    // Запрет повторного наложения двух вариантов руки.
    if (GetHasSpellEffect(SPELL_BIGBYS_CLENCHED_FIST, spell.Target)
        || GetHasSpellEffect(SPELL_BIGBYS_CRUSHING_HAND, spell.Target))
    {
        FloatingColorTextStrRefOnCreature(
            100775, TXT_COLOR_RED, spell.Caster, FALSE);
        return;
    }

    int nDuration = 1;

    if (!GetIsReactionTypeFriendly(spell.Target)
        && !spells_GetHasTimeStopEffect(spell.Caster, spell.Target))
    {
        SignalEvent(spell.Target, EventSpellCastAt(
            spell.Caster, SPELL_BIGBYS_CLENCHED_FIST, TRUE));

        // Сохраняем проверку сопротивления заклинаниям.
        int nResult = MyResistSpell(spell.Caster, spell.Target);

        if (nResult == 0)
        {
            effect eHand =
                EffectVisualEffect(VFX_DUR_BIGBYS_CLENCHED_FIST);

            // Уровень заклинателя текущего заклинания.
            int nCasterLevel = GetCasterLevel(spell.Caster);

            // Всегда модификатор Харизмы.
            int nChaMod =
                GetAbilityModifier(ABILITY_CHARISMA, spell.Caster);

            int nFocusBonus = BIGBY4_GetFocusBonus(spell.Caster);

            int nCasterRoll =
                nCasterLevel + nChaMod + nFocusBonus + d20();

            int nTargetAC = GetAC(spell.Target);

            // Равенство AC считается промахом.
            // Одна проверка для сообщений и применения эффекта.
            int bHit = (nCasterRoll > nTargetAC);

            string sSuffix = bHit
                ? ColorText("Bigby's Clenched Fist : *hit* ",
                    TXT_COLOR_VIOLET_L)
                : ColorText("Bigby's Clenched Fist : *missed* ",
                    TXT_COLOR_VIOLET_L);

            if (GetIsPC(spell.Caster))
            {
                SendMessageToPC(spell.Caster,
                    ColorText(
                        "Bigby's Clenched Fist hit attempt. Your roll ",
                        TXT_COLOR_VIOLET_L)
                    + ColorText(
                        IntToString(nCasterRoll), TXT_COLOR_VIOLET_L)
                    + ColorText(", target AC ", TXT_COLOR_VIOLET_L)
                    + ColorText(
                        IntToString(nTargetAC), TXT_COLOR_VIOLET_L)
                    + ColorText(". ", TXT_COLOR_VIOLET_L)
                    + sSuffix);
            }

            if (GetIsPC(spell.Target))
            {
                SendMessageToPC(spell.Target,
                    ColorText(
                        "Bigby's Clenched Fist hit attempt. Your AC ",
                        TXT_COLOR_VIOLET_L)
                    + ColorText(
                        IntToString(nTargetAC), TXT_COLOR_VIOLET_L)
                    + ColorText(", caster roll ", TXT_COLOR_VIOLET_L)
                    + ColorText(
                        IntToString(nCasterRoll), TXT_COLOR_VIOLET_L)
                    + ColorText(". ", TXT_COLOR_VIOLET_L)
                    + sSuffix);
            }

            if (bHit)
            {
                // Исходная система перезарядки модуля.
                spells_SetSpellCooldown(
                    spell.Id, spell.Caster,
                    GetSpellTimeoutDuration(spell.Id));

                // Обездвиживание на один раунд: 6 секунд.
                ApplyEffectToObject(
                    DURATION_TYPE_TEMPORARY,
                    EffectCutsceneImmobilize(),
                    spell.Target,
                    RoundsToSeconds(nDuration));

                ApplyEffectToObject(
                    DURATION_TYPE_TEMPORARY,
                    eHand,
                    spell.Target,
                    RoundsToSeconds(nDuration));

                FloatingColorTextStrRefOnCreature(
                    2478, TXT_COLOR_GREEN_L, spell.Caster);
            }
            else
            {
                FloatingColorTextStrRefOnCreature(
                    83309, TXT_COLOR_RED, spell.Caster);
            }
        }
    }
}

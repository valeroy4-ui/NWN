// Bigby's Forceful Hand.
// Caster: 5 + size + CHA_mod - CON_mod + d20.
// Target: max(STR_mod, DEX_mod) + target size + d20.
// size здесь означает бонус размера кастера.

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_colortext"

const float BFH_DURATION = 6.0;

void main()
{
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
        return;

    spellsDeclareMajorVariables();


    // Явно используем Харизму и Телосложение кастера.
    int nChaMod = GetAbilityModifier(ABILITY_CHARISMA, spell.Caster);
    int nConMod = GetAbilityModifier(ABILITY_CONSTITUTION, spell.Caster);
    int nCasterSize = GetSizeModifier(spell.Caster);

    // Цель использует лучший модификатор STR или DEX.
    int nStrMod = GetAbilityModifier(ABILITY_STRENGTH, spell.Target);
    int nDexMod = GetAbilityModifier(ABILITY_DEXTERITY, spell.Target);
    int nTargetAbility = nStrMod;

    if (nDexMod > nTargetAbility)
        nTargetAbility = nDexMod;

    // Сохраняем защиту дружественных IMGUARD-целей.
    if (GetLocalInt(spell.Target, "IMGUARD")
        && !GetIsEnemy(spell.Target, spell.Caster))
        return;

    int bTimeOut = FALSE;

    if (spellsIsTarget(spell.Target, spell.TargetType, spell.Caster)
        && !spells_GetHasTimeStopEffect(spell.Caster, spell.Target))
    {
        effect eImpact =
            EffectVisualEffect(VFX_IMP_BIGBYS_FORCEFUL_HAND);

        ApplyEffectToObject(
            DURATION_TYPE_INSTANT, eImpact, spell.Target);

        SignalEvent(spell.Target, EventSpellCastAt(
            spell.Caster, spell.Id, TRUE));

        // Общая проверка поглощения и сопротивления.
        // Мантла должна защищать и от слепоты при Epic Dodge.
        if (MyResistSpell(spell.Caster, spell.Target))
            return;

        if (GetHasFeat(FEAT_EPIC_DODGE, spell.Target))
        {
            // Как в исходнике: слепота без бросков и проверки SR.
            effect eBlind = ExtraordinaryEffect(EffectBlindness());
            effect eDur =
                EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
            effect eBlindVis =
                EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);

            eBlind = EffectLinkEffects(eDur, eBlind);

            if (GetIsPC(spell.Caster))
            {
                SendMessageToPC(spell.Caster, ColorText(
                    "Epic Dodge: blindness instead of knockdown (6 sec).",
                    TXT_COLOR_VIOLET_L));
                bTimeOut = TRUE;
            }

            if (GetIsPC(spell.Target))
            {
                SendMessageToPC(spell.Target, ColorText(
                    "Epic Dodge: blindness instead of knockdown (6 sec).",
                    TXT_COLOR_VIOLET_L));
            }

            ApplyEffectToObject(
                DURATION_TYPE_TEMPORARY,
                eBlind, spell.Target, BFH_DURATION);

            ApplyEffectToObject(
                DURATION_TYPE_INSTANT, eBlindVis, spell.Target);
        }
        else
        {
            int nCasterRoll =
                5 + nCasterSize + nChaMod - nConMod + d20();

            int nTargetRoll =
                nTargetAbility + GetSizeModifier(spell.Target) + d20();

            string sRollMessage =
                "Bigby's Forceful Hand: caster roll "
                + IntToString(nCasterRoll)
                + ", target roll " + IntToString(nTargetRoll);

            SendMessageToPC(spell.Caster,
                ColorText(sRollMessage, TXT_COLOR_VIOLET_L));

            SendMessageToPC(spell.Target,
                ColorText(sRollMessage, TXT_COLOR_VIOLET_L));

            // Ничья не сбивает: требуется строгое превосходство.
            if (nCasterRoll > nTargetRoll)
            {
                effect eKnockdown =
                    ExtraordinaryEffect(EffectKnockdown());

                effect eDur =
                    EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

                effect eLink = EffectLinkEffects(eDur, eKnockdown);

                if (GetIsPC(spell.Caster))
                    bTimeOut = TRUE;

                ApplyEffectToObject(
                    DURATION_TYPE_TEMPORARY,
                    eLink, spell.Target, BFH_DURATION);

                FloatingColorTextStringOnCreature(
                    "Bull Rush successful!",
                    TXT_COLOR_GREEN_L, spell.Caster, TRUE);

                FloatingColorTextStringOnCreature(
                    "Knocked down!",
                    TXT_COLOR_RED, spell.Target, FALSE);
            }
            else
            {
                FloatingColorTextStringOnCreature(
                    "Bull Rush failed!",
                    TXT_COLOR_RED, spell.Caster);
            }
        }
    }

    // КД 36 секунд: Timeout=36 в строке 460 spells.2da.
    // Сохранено исходное условие:
    // КД для PC после успешного сбивания или ветки Epic Dodge.
    //
    // Будущая руна CDR:
    // случайное снижение КД на Random(7)+6 секунд.
    // Реализация будет в отдельной библиотеке.
    // Здесь снижение не добавляем, чтобы не применить его дважды.
    if (bTimeOut)
    {
        spells_SetSpellCooldown(
            spell.Id, spell.Caster,
            GetSpellTimeoutDuration(spell.Id));
    }
}

#include "pdk_auras"
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_fshop_spell"

const float BIH_RADIUS = 10.0;
const float BIH_DURATION = 6.0;

// При Perform 110+: (бард + архимаг + харпер/2 - 25)/5.
// Деление целочисленное. Бонус ограничен диапазоном 0..3.
int BIH_GetBardBonus(object oCaster, object oItem)
{
    // Как в исходнике: бонус Perform не действует из предмета.
    if (GetIsObjectValid(oItem))
        return 0;

    if (GetSkillRank(SKILL_PERFORM, oCaster) < 110)
        return 0;

    int nBonus = (GetLevelByClass(CLASS_TYPE_BARD, oCaster)
        + GetLevelByClass(CLASS_TYPE_ARCHMAGE, oCaster)
        + GetLevelByClass(CLASS_TYPE_HARPER, oCaster) / 2 - 25) / 5;

    if (nBonus < 0)
        nBonus = 0;

    if (nBonus > 3)
        nBonus = 3;

    return nBonus;
}

// Fame shop: +1 к броску барда.
// Используем существующую покупку из исходника.
int BIH_GetBardFameBonus(object oCaster)
{
    if (GetPCSongBitArray(oCaster) & FAMESHOP_BARD_BALAGARN_IRON_HORN_DC)
        return 1;

    return 0;
}
void main()
{
    spell.Range = BIH_RADIUS;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
        return;

    spellsDeclareMajorVariables();

    object oCaster = spell.Caster;

    // Выбираем формулу по классу текущего применения заклинания.
    int nCastingClass = GetLastSpellCastClass();
    int bBard = (nCastingClass == CLASS_TYPE_BARD);
    int bSorcerer = (nCastingClass == CLASS_TYPE_SORCERER);

    // Центр эффекта всегда на заклинателе.
    spell.Loc = GetLocation(oCaster);
    spell.Range = BIH_RADIUS;

    // Руна устанавливает на персонаже BIH_RUNE_NO_FF = 1.
    // Без руны союзники и нейтральные существа могут быть задеты.
    int bNoFriendlyFire =
        (GetLocalInt(oCaster, "BIH_RUNE_NO_FF") == 1);

    // Для предметов и иных классов: база 20 без классовых бонусов.
    int nRollBase = 20;

    if (bBard)
    {
        nRollBase = 20 + BIH_GetBardBonus(oCaster, spell.Item)
            + BIH_GetBardFameBonus(oCaster);
    }
    else if (bSorcerer)
    {
        nRollBase = 12
            + GetAbilityModifier(ABILITY_CHARISMA, oCaster)
            - GetAbilityModifier(ABILITY_CONSTITUTION, oCaster);
    }

    effect eExplode = EffectVisualEffect(VFX_FNF_HOWL_WAR_CRY);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
    effect eShake = EffectVisualEffect(VFX_FNF_SCREEN_BUMP);
    effect eTrip = EffectKnockdown();

    ApplyEffectToObject(
        DURATION_TYPE_TEMPORARY, eShake, oCaster, BIH_DURATION);

    ApplyEffectAtLocation(
        DURATION_TYPE_INSTANT, eExplode, spell.Loc);

    int bTimeOut = FALSE;

    object oTarget = GetFirstObjectInShape(
        SHAPE_SPHERE, spell.Range, spell.Loc,
        TRUE, OBJECT_TYPE_CREATURE);

    while (GetIsObjectValid(oTarget))
    {
        // Кастер не поражает себя.
        // При активной руне пропускаем дружественных существ.
        if (oTarget != oCaster && !GetIsDead(oTarget)
            && (!bNoFriendlyFire || !GetIsFriend(oTarget, oCaster)))
        {
            SignalEvent(oTarget, EventSpellCastAt(
                oCaster, SPELL_BALAGARNSIRONHORN));

            float fDelay = GetDistanceBetweenLocations(
                spell.Loc, GetLocation(oTarget)) / 20.0;

            // Спасброска нет, но проверка сопротивления сохранена.
            if (!MyResistSpell(oCaster, oTarget, fDelay))
            {
                // Отдельный бросок для каждой цели.
                int nCasterRoll = nRollBase + d20();

                // Полная характеристика STR, а не её модификатор.
                int nTargetRoll =
                    GetAbilityScore(oTarget, ABILITY_STRENGTH) + d20() + PKB_StandBonus(oTarget);

                SendMessageToPC(oCaster, "Iron Horn: "
                    + IntToString(nCasterRoll)
                    + " vs " + GetName(oTarget)
                    + ": " + IntToString(nTargetRoll));

                SendMessageToPC(oTarget,
                    GetName(oCaster) + " Iron Horn: "
                    + IntToString(nCasterRoll)
                    + " vs your roll: " + IntToString(nTargetRoll));

                // Только строгое превосходство. Ничья защищает цель.
                if (nCasterRoll > nTargetRoll)
                {
                    bTimeOut = TRUE;

                    DelayCommand(fDelay, ApplyEffectToObject(
                        DURATION_TYPE_TEMPORARY,
                        eTrip, oTarget, BIH_DURATION));

                    DelayCommand(fDelay, ApplyEffectToObject(
                        DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }

        oTarget = GetNextObjectInShape(
            SHAPE_SPHERE, spell.Range, spell.Loc,
            TRUE, OBJECT_TYPE_CREATURE);
    }

    // Условие КД сохранено из исходника:
    // хотя бы один выигранный бросок против цели.
    // Иммунитет цели может помешать фактическому сбиванию.
    if (bTimeOut)
    {
        // CDR 6-12 секунд позже подключат в другой библиотеке.
        spells_SetSpellCooldown(
            spell.Id, oCaster, GetSpellTimeoutDuration(spell.Id));
    }
}

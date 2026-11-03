#include "70_inc_spells"
#include "70_inc_switches"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"

const int MF_LOCAL_WINDOWS_TEST = FALSE;

int MF_GetLingerSeconds(object oCaster)
{
    if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION, oCaster))
        return 9;

    if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION, oCaster))
        return 6;

    if (GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION, oCaster))
        return 3;

    return 0;
}

void main()
{
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    // Тип уменьшаемого спасброска. Самого броска Will нет.
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
        return;

    spellsDeclareMajorVariables();

    // Обычный каст персонажа: только Bard/Sorcerer.
    if (GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item))
    {
        int nClass = GetLastSpellCastClass();

        if (nClass != CLASS_TYPE_BARD
            && nClass != CLASS_TYPE_SORCERER)
        {
            SendMessageToPC(spell.Caster,
                "Mind Fog requires Bard or Sorcerer spellcasting.");
            return;
        }
    }

    effect eAOE = EffectAreaOfEffect(AOE_PER_FOGMIND);
    int nDurationRounds = 2 + spell.Level / 2;

    effect eImpact = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_MIND);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    if (spell.Meta & METAMAGIC_EXTEND)
        nDurationRounds *= 2;

    float fDuration = DurationToSeconds(nDurationRounds);

    int nDurationOverride = GetModuleSwitchValue(
        MODULE_SWITCH_CORMYR_MAX_LEVEL_AOE_DURATION_SEC);

    // Значение переключателя уже указано в секундах.
    if (spell.Level == CORMYREAN_CHARACTER_MAX_LVL
        && nDurationOverride != 0)
    {
        fDuration = IntToFloat(nDurationOverride);
    }

    int nLingerSeconds = MF_GetLingerSeconds(spell.Caster);
    float fRadius = GetAreaOfEffectRadius(AOE_PER_FOGMIND);

    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY,
        eAOE, spell.Loc, fDuration);

    object oAOE = spellsSetupNewAOE(AOE_PER_FOGMIND);

    if (GetIsObjectValid(oAOE))
        SetLocalInt(oAOE, "MF_LINGER_SECONDS", nLingerSeconds);

    if (GetIsPC(spell.Caster))
    {
        SendMessageToPC(spell.Caster,
            "Mind Fog: CL=" + IntToString(spell.Level)
            + " Will=-" + IntToString(spell.Level / 13)
            + " radius=" + FloatToString(fRadius, 1, 1)
            + " duration=" + FloatToString(fDuration, 1, 1)
            + "s linger=" + IntToString(nLingerSeconds)
            + "s override=" + IntToString(nDurationOverride));
    }

        if (!MF_LOCAL_WINDOWS_TEST)
    {
        AddMarkersForAOE(spell.Caster, spell.Loc, fDuration, fRadius);
    }
}

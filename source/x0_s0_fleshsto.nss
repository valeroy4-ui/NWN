#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

int FTS_CasterMarker(object oCaster, string sTag, int bRemove)
{
    if (!GetIsObjectValid(oCaster))
        return FALSE;

    effect e = GetFirstEffect(oCaster);

    while (GetIsEffectValid(e))
    {
        if (GetEffectTag(e) == sTag + "_CASTER")
        {
            if (bRemove)
                RemoveEffect(oCaster, e);

            return TRUE;
        }

        e = GetNextEffect(oCaster);
    }

    return FALSE;
}

void FTS_Watch(object oCaster, object oTarget,
    string sTag, int bPlayerCaster)
{
    if (!GetIsObjectValid(oTarget))
    {
        FTS_CasterMarker(oCaster, sTag, TRUE);
        return;
    }

    effect e = GetFirstEffect(oTarget);

    while (GetIsEffectValid(e))
    {
        if (GetEffectType(e) == EFFECT_TYPE_PETRIFY
            && GetEffectTag(e) == sTag)
            break;

        e = GetNextEffect(oTarget);
    }

    if (!GetIsEffectValid(e))
    {
        FTS_CasterMarker(oCaster, sTag, TRUE);
        return;
    }

    int bRelease = !GetIsObjectValid(oCaster);

    if (!bRelease && bPlayerCaster)
    {
        bRelease = TRUE;
        object oPC = GetFirstPC();

        while (GetIsObjectValid(oPC))
        {
            if (oPC == oCaster)
            {
                bRelease = FALSE;
                break;
            }

            oPC = GetNextPC();
        }
    }

    if (!bRelease)
    {
        bRelease = GetIsDead(oCaster)
            || GetIsResting(oCaster)
            || !FTS_CasterMarker(oCaster, sTag, FALSE);
    }

    if (bRelease)
    {
        SetCommandable(TRUE, oTarget);
        RemoveEffect(oTarget, e);
        FTS_CasterMarker(oCaster, sTag, TRUE);
        return;
    }

    AssignCommand(GetModule(), DelayCommand(0.5,
        FTS_Watch(oCaster, oTarget, sTag, bPlayerCaster)));
}

void main()
{
    spell.TargetType = SPELL_TARGET_SINGLETARGET;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
        return;

    spellsDeclareMajorVariables();

    if (!spellsIsTarget(
        spell.Target, spell.TargetType, spell.Caster))
        return;

    SignalEvent(spell.Target,
        EventSpellCastAt(spell.Caster, spell.Id));

    if (spellsIsImmuneToPetrification(spell.Target))
    {
        ApplyEffectToObject(
            DURATION_TYPE_TEMPORARY,
            EffectSpellImmunity(spell.Id),
            spell.Target,
            0.01);
    }

    if (MyResistSpell(spell.Caster, spell.Target) > 0)
        return;

    if (MySavingThrow(
        SAVING_THROW_FORT,
        spell.Target,
        spell.DC,
        SAVING_THROW_TYPE_NONE,
        spell.Caster))
        return;

    if (GetPlotFlag(spell.Target)
        || GetImmortal(spell.Target))
        return;

    int nCL = spell.Level;
    if (nCL < 1)
        nCL = 1;

    effect eLink = EffectLinkEffects(
        EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE),
        EffectPetrify());

    eLink = SupernaturalEffect(eLink);

    object oModule = GetModule();
    int nSerial = GetLocalInt(oModule, "FTS_WATCH_SERIAL") + 1;
    SetLocalInt(oModule, "FTS_WATCH_SERIAL", nSerial);

    string sTag = "FTS_" + IntToString(nSerial);
    eLink = TagEffect(eLink, sTag);

    int bPlayerCaster = GetIsPC(spell.Caster);

    ApplyEffectToObject(
        DURATION_TYPE_TEMPORARY,
        eLink,
        spell.Target,
        RoundsToSeconds(nCL));

    // Separate marker on the caster.
    effect eMarker = EffectVisualEffect(VFX_DUR_CESSATE_NEUTRAL);
    eMarker = SupernaturalEffect(eMarker);
    eMarker = SetEffectSpellId(eMarker, -1);
    eMarker = TagEffect(eMarker, sTag + "_CASTER");

    ApplyEffectToObject(
        DURATION_TYPE_TEMPORARY,
        eMarker,
        spell.Caster,
        RoundsToSeconds(nCL) + 6.0);

    AssignCommand(spell.Target, ClearAllActions(TRUE));
    ExecuteScript("70_mod_petrified", spell.Target);

    AssignCommand(GetModule(), DelayCommand(0.5,
        FTS_Watch(spell.Caster, spell.Target, sTag,
            bPlayerCaster)));
}

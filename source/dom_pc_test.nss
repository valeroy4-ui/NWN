#include "dom_pc_ai"

// Input lock lasts while the native Dominate effect is active.

int DOMPC_TestHasDominate(object oCaster, object oTarget, int nSpellId)
{
    effect e = GetFirstEffect(oTarget);

    while (GetIsEffectValid(e))
    {
        if (GetEffectType(e) == EFFECT_TYPE_DOMINATED
            && GetEffectCreator(e) == oCaster
            && GetEffectSpellId(e) == nSpellId)
        {
            return TRUE;
        }

        e = GetNextEffect(oTarget);
    }

    return FALSE;
}

void DOMPC_RemoveDominate(object oCaster, object oTarget, int nSpellId)
{
    if (!GetIsObjectValid(oTarget))
        return;

    effect e = GetFirstEffect(oTarget);

    while (GetIsEffectValid(e))
    {
        if (GetEffectType(e) == EFFECT_TYPE_DOMINATED
            && GetEffectSpellId(e) == nSpellId
            && GetEffectCreator(e) == oCaster)
        {
            RemoveEffect(oTarget, e);
            e = GetFirstEffect(oTarget);
        }
        else
        {
            e = GetNextEffect(oTarget);
        }
    }
}

void DOMPC_TestStop(object oCaster, object oTarget)
{
    if (!GetIsObjectValid(oTarget))
        return;

    if (!GetLocalInt(oTarget, "DOMPC_TEST_ACTIVE"))
        return;

    DeleteLocalInt(oTarget, "DOMPC_TEST_ACTIVE");

    DOMAI_Reset(oTarget);
    AssignCommand(oTarget, ClearAllActions(TRUE));

    if (GetCutsceneMode(oTarget))
        SetCutsceneMode(oTarget, FALSE);

    SendMessageToPC(oTarget,
        "Dominate PC test: input lock ended.");

    if (GetIsPC(oCaster))
    {
        SendMessageToPC(oCaster,
            "Dominate PC test: input lock ended.");
    }
}

void DOMPC_TestTick(object oCaster, object oTarget, int nSpellId)
{
    if (!GetIsObjectValid(oTarget))
        return;

    if (!GetLocalInt(oTarget, "DOMPC_TEST_ACTIVE"))
        return;

    if (!GetIsObjectValid(oCaster)
        || !GetIsPC(oCaster)
        || GetIsDead(oCaster)
        || GetIsDead(oTarget)
        || !GetCutsceneMode(oTarget)
        || !DOMPC_TestHasDominate(oCaster, oTarget, nSpellId))
    {
        DOMPC_RemoveDominate(oCaster, oTarget, nSpellId);
        DOMPC_TestStop(oCaster, oTarget);
        return;
    }

    AssignCommand(oTarget, DOMAI_Step(oCaster));

    AssignCommand(GetModule(), DelayCommand(0.5,
        DOMPC_TestTick(oCaster, oTarget, nSpellId)));
}

void DOMPC_TestStart(object oCaster, object oTarget, int nSpellId)
{
    if (!GetIsPC(oCaster) || !GetIsPC(oTarget))
        return;

    if (oCaster == oTarget)
        return;

    if (GetIsDead(oCaster) || GetIsDead(oTarget))
        return;

    if (GetLocalInt(oTarget, "DOMPC_TEST_ACTIVE"))
        return;

    if (GetCutsceneMode(oTarget))
    {
        SendMessageToPC(oCaster,
            "Dominate PC test skipped: target already in cutscene mode.");
        return;
    }

    if (!DOMPC_TestHasDominate(oCaster, oTarget, nSpellId))
        return;

    DOMAI_Reset(oTarget);

    int bWasPlot = GetPlotFlag(oTarget);

    SetLocalInt(oTarget, "DOMPC_TEST_ACTIVE", TRUE);

    SetCutsceneMode(oTarget, TRUE, FALSE);

    // Preserve the target's original vulnerability.
    SetPlotFlag(oTarget, bWasPlot);

    SendMessageToPC(oCaster,
        "Dominate PC test: input locked until Dominate ends.");

    SendMessageToPC(oTarget,
        "Dominate PC test: try movement, attack, quickbar, cancel, Escape.");

    DOMPC_TestTick(oCaster, oTarget, nSpellId);
}

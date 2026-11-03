#include "70_inc_spells"
#include "x0_i0_spells"
#include "nwnx_creature"

const int MF_LOCAL_WINDOWS_TEST = FALSE;

string MF_ImmunityRoot(object oTarget)
{
    return "MF_MIND_" + ObjectToString(oTarget);
}

string MF_ImmunityPair(object oTarget, object oAOE)
{
    return MF_ImmunityRoot(oTarget) + "_AOE_" + ObjectToString(oAOE);
}

void MF_EndSuppression(object oTarget, string sRoot,
    string sPair, int nToken)
{
    object oModule = GetModule();

    if (nToken <= 0 || GetLocalInt(oModule, sPair) != nToken)
        return;

    DeleteLocalInt(oModule, sPair);

    int nCount = GetLocalInt(oModule, sRoot + "_COUNT") - 1;

    if (nCount > 0)
    {
        SetLocalInt(oModule, sRoot + "_COUNT", nCount);
        return;
    }

    int nPrevious = GetLocalInt(oModule, sRoot + "_PREVIOUS");

    if (GetIsObjectValid(oTarget))
    {
        NWNX_Creature_SetBypassEffectImmunity(oTarget,
            -IMMUNITY_TYPE_MIND_SPELLS, nPrevious, FALSE);
    }

    DeleteLocalInt(oModule, sRoot + "_COUNT");
    DeleteLocalInt(oModule, sRoot + "_PREVIOUS");
}

int MF_IsInside(object oTarget, object oAOE)
{
    object oInside = GetFirstInPersistentObject(oAOE);

    while (GetIsObjectValid(oInside))
    {
        if (oInside == oTarget)
            return TRUE;

        oInside = GetNextInPersistentObject(oAOE);
    }

    return FALSE;
}

// Выполняется на модуле: исчезновение тумана не отменяет очистку.
void MF_WatchSuppression(object oTarget, object oAOE,
    string sRoot, string sPair, int nToken)
{
    if (GetLocalInt(GetModule(), sPair) != nToken)
        return;

    int bActive = GetIsObjectValid(oTarget)
        && GetIsObjectValid(oAOE);

    if (bActive)
        bActive = MF_IsInside(oTarget, oAOE);

    if (bActive)
    {
        object oCreator = GetAreaOfEffectCreator(oAOE);

        if (GetIsObjectValid(oCreator))
        {
            bActive = spellsIsTarget(oTarget,
                SPELL_TARGET_SELECTIVEHOSTILE, oCreator);
        }
    }

    if (!bActive)
    {
        MF_EndSuppression(oTarget, sRoot, sPair, nToken);
        return;
    }

    AssignCommand(GetModule(), DelayCommand(0.5,
        MF_WatchSuppression(
            oTarget, oAOE, sRoot, sPair, nToken)));
}

void MF_BeginSuppression(object oTarget, object oAOE, int nToken)
{
     if (MF_LOCAL_WINDOWS_TEST)
        return;

    object oModule = GetModule();
    string sRoot = MF_ImmunityRoot(oTarget);
    string sPair = MF_ImmunityPair(oTarget, oAOE);

    if (GetLocalInt(oModule, sPair) == 0)
    {
        int nCount = GetLocalInt(oModule, sRoot + "_COUNT");

        if (nCount <= 0)
        {
            int nPrevious = NWNX_Creature_GetBypassEffectImmunity(
                oTarget, -IMMUNITY_TYPE_MIND_SPELLS);

            SetLocalInt(oModule, sRoot + "_PREVIOUS", nPrevious);
            nCount = 0;
        }

        SetLocalInt(oModule, sRoot + "_COUNT", nCount + 1);
    }

    SetLocalInt(oModule, sPair, nToken);

    NWNX_Creature_SetBypassEffectImmunity(oTarget,
        -IMMUNITY_TYPE_MIND_SPELLS, 100, FALSE);

    AssignCommand(oModule, DelayCommand(0.5,
        MF_WatchSuppression(
            oTarget, oAOE, sRoot, sPair, nToken)));
}

void MF_ApplyIfInside(object oTarget, effect eLink, int nToken)
{
    if (!GetIsObjectValid(oTarget))
        return;

    string sKey = "MF_PENDING_" + ObjectToString(oTarget);

    if (GetLocalInt(OBJECT_SELF, sKey) != nToken)
        return;

    if (!spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE,
        GetAreaOfEffectCreator(OBJECT_SELF)))
    {
        return;
    }

    if (!MF_IsInside(oTarget, OBJECT_SELF))
        return;

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
}

void main()
{
    aoesDeclareMajorVariables();

    object oTarget = GetEnteringObject();

    if (!GetIsObjectValid(oTarget))
        return;

    if (!spellsIsTarget(oTarget,
        SPELL_TARGET_SELECTIVEHOSTILE, aoe.Creator))
    {
        return;
    }

    SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));

    // SR и мантия защищают от обоих воздействий.
    if (MyResistSpell(aoe.Creator, oTarget))
        return;

    string sKey = "MF_PENDING_" + ObjectToString(oTarget);
    int nToken = GetLocalInt(OBJECT_SELF, sKey) + 1;
    SetLocalInt(OBJECT_SELF, sKey, nToken);

    int nImmuneBefore = GetIsImmune(oTarget,
        IMMUNITY_TYPE_MIND_SPELLS, aoe.Creator);

    MF_BeginSuppression(oTarget, OBJECT_SELF, nToken);

    SetLocalInt(OBJECT_SELF,
        "MF_ACCEPTED_" + ObjectToString(oTarget), nToken);

    if (GetIsPC(aoe.Creator))
    {
        SendMessageToPC(aoe.Creator,
            "Mind Fog: " + GetName(oTarget) + " MindImmune="
            + IntToString(nImmuneBefore) + " -> "
            + IntToString(GetIsImmune(oTarget,
                IMMUNITY_TYPE_MIND_SPELLS, aoe.Creator)));
    }

    int nPenalty = spell.Level / 13;

    if (nPenalty <= 0)
        return;

    int bValid = FALSE;
    effect eLook = GetFirstEffect(oTarget);

    while (GetIsEffectValid(eLook))
    {
        if (GetEffectSpellId(eLook) == SPELL_MIND_FOG
            && GetEffectCreator(eLook) == aoe.Creator
            && GetEffectType(eLook) == EFFECT_TYPE_SAVING_THROW_DECREASE)
        {
            RemoveEffect(oTarget, eLook);
            bValid = TRUE;
            eLook = GetFirstEffect(oTarget);
        }
        else
        {
            eLook = GetNextEffect(oTarget);
        }
    }

    effect eLower = EffectSavingThrowDecrease(
        SAVING_THROW_WILL, nPenalty);

    effect eVis = EffectVisualEffect(
        VFX_DUR_MIND_AFFECTING_NEGATIVE);

    effect eLink = EffectLinkEffects(eVis, eLower);

    eLink = IgnoreEffectImmunity(eLink);
    eLink = SetEffectCreator(eLink, aoe.Creator);
    eLink = SetEffectCasterLevel(eLink, spell.Level);
    eLink = SetEffectSpellId(eLink, SPELL_MIND_FOG);
    eLink = TagEffect(eLink, "WEAKEN_MIND");

    if (bValid)
    {
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
    }
    else
    {
        DelayCommand(GetRandomDelay(1.0, 2.2),
            MF_ApplyIfInside(oTarget, eLink, nToken));
    }
}

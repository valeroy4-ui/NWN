#include "70_inc_spells"
#include "x0_i0_spells"
#include "nwnx_creature"

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

void main()
{
    aoesDeclareMajorVariables();

    object oTarget = GetExitingObject();

    if (!GetIsObjectValid(oTarget))
        return;

    string sKey = "MF_PENDING_" + ObjectToString(oTarget);
    SetLocalInt(OBJECT_SELF, sKey,
        GetLocalInt(OBJECT_SELF, sKey) + 1);

    // Возврат иммунитета не зависит от штрафа Will и Restoration.
    string sRoot = MF_ImmunityRoot(oTarget);
    string sPair = MF_ImmunityPair(oTarget, OBJECT_SELF);

    int nSuppressionToken = GetLocalInt(GetModule(), sPair);
    MF_EndSuppression(oTarget, sRoot, sPair, nSuppressionToken);

    if (nSuppressionToken > 0 && GetIsPC(aoe.Creator))
    {
        SendMessageToPC(aoe.Creator,
            "Mind Fog exit: " + GetName(oTarget) + " MindImmune="
            + IntToString(GetIsImmune(oTarget,
                IMMUNITY_TYPE_MIND_SPELLS, aoe.Creator)));
    }

    string sAcceptedKey = "MF_ACCEPTED_" + ObjectToString(oTarget);
    int nAccepted = GetLocalInt(OBJECT_SELF, sAcceptedKey);
    DeleteLocalInt(OBJECT_SELF, sAcceptedKey);

    if (nAccepted <= 0)
        return;

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

    // Если штраф снят Restoration, не создаём его заново.
    if (!bValid)
        return;

    if (!spellsIsTarget(oTarget,
        SPELL_TARGET_SELECTIVEHOSTILE, aoe.Creator))
    {
        return;
    }

    int nLingerSeconds = GetLocalInt(
        OBJECT_SELF, "MF_LINGER_SECONDS");

    if (nLingerSeconds <= 0)
        return;

    effect eSave = EffectSavingThrowDecrease(
        SAVING_THROW_WILL, nPenalty);

    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVis = EffectVisualEffect(
        VFX_DUR_MIND_AFFECTING_NEGATIVE);

    effect eLink = EffectLinkEffects(eSave, eDur);
    eLink = EffectLinkEffects(eLink, eVis);

    eLink = IgnoreEffectImmunity(eLink);
    eLink = SetEffectCreator(eLink, aoe.Creator);
    eLink = SetEffectCasterLevel(eLink, spell.Level);
    eLink = SetEffectSpellId(eLink, SPELL_MIND_FOG);
    eLink = TagEffect(eLink, "WEAKEN_MIND");

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
        eLink, oTarget, IntToFloat(nLingerSeconds));
}

#include "nwnx_events"
#include "_inc_spells"
#include "_inc_generic"

void main()
{
    string sEvent = NWNX_Events_GetCurrentEvent();
    if(sEvent == NWNX_ON_HEAL_BEFORE)
    {
        object oHealer  = OBJECT_SELF;
        object oTarget  = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));
        // ServerShout(GetName(oTarget));


        int nHealAmount = StringToInt(NWNX_Events_GetEventData("HEAL_AMOUNT"));
        // calculate penalty percent
        int nPenaltyPercent = 0;
        effect eInHeal  = spells_GetFirstEffectWithSpecificSpellID(oTarget, SPELL_POISON);
        effect eOutHeal = spells_GetFirstEffectWithSpecificSpellID(oHealer, SPELL_POISON);
        // Preserve the previous non-Poison NPC behaviour.
        if (!GetIsPC(oTarget) && !GetIsEffectValid(eInHeal) && !GetIsEffectValid(eOutHeal)) return;
        // add plague onhit
        int nPlagueInPenalty = GetIsPC(oTarget) ? GetLocalInt(oTarget, IntToString(SPELL_PLAGUE) + "_STACKS") * 7 : 0;
        int nPlagueOutPenalty = GetIsPC(oTarget) ? GetLocalInt(oHealer, IntToString(SPELL_PLAGUE) + "_STACKS") * 7 : 0;
        //
        int nInPenalty  = (GetIsEffectValid(eInHeal) ? GetEffectInteger(eInHeal, 2) : 0) + nPlagueInPenalty;
        int nOutPenalty = (GetIsEffectValid(eOutHeal) ? GetEffectInteger(eOutHeal, 2) : 0) + nPlagueOutPenalty;
        nPenaltyPercent += nInPenalty;
        if(oHealer != oTarget)
            nPenaltyPercent += nOutPenalty;

        // calculate heal amount
        if(nPenaltyPercent && nHealAmount)
        {
            nHealAmount = FloatToInt((100 - nPenaltyPercent)/100.0 * IntToFloat(nHealAmount));
            NWNX_Events_SetEventResult(IntToString(nHealAmount));
            NWNX_Events_SkipEvent();
        }
        // clear DPS locals
        // ServerShout(IntToString(GetCurrentHitPoints(oTarget) + nHealAmount));
        if(GetMaxHitPoints(oTarget) <= GetCurrentHitPoints(oTarget) + nHealAmount)
        {
            DeleteLocalJson(oTarget, "JSON_STORED_DPS_VALUE");
            DeleteLocalJson(oTarget, "JSON_STORED_DPS_FACTION");
        }
        if(GetIsPC(oTarget) && nHealAmount > 20 /* max item regen value */)
            FloatingColorTextStringOnCreature("+" + IntToString(nHealAmount) + " HP", TXT_COLOR_GREEN_L, oTarget);
    }
}

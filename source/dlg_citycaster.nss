#include "_inc_npc_cast"

void main()
{
    object oTarget = GetPCSpeaker();
    int iFaction = players_GetFaction(oTarget);
    int nCostWithObelisks;
    int nFactionTaxes;
    int iPcLevel = GetHitDice(oTarget);
    players_SetFaction(OBJECT_SELF, iFaction);

    int iBuffType = StringToInt(GetScriptParam("BUFF_TYPE"));
    switch (iBuffType)
    {
        case BUFF_TYPE_LONG:
            nCostWithObelisks = GetLocalInt(oTarget, BUFF_COST_LONG);
            nFactionTaxes = GetLocalInt(oTarget, BUFF_FACTION_TAX_LONG);
        break;
        case BUFF_TYPE_SHORT:
            nCostWithObelisks = GetLocalInt(oTarget, BUFF_COST_SHORT);
            nFactionTaxes = GetLocalInt(oTarget, BUFF_FACTION_TAX_SHORT);
        break;
        case BUFF_TYPE_LEVELING:
            nCostWithObelisks = GetLocalInt(oTarget, BUFF_COST_LEVELING);
            nFactionTaxes = GetLocalInt(oTarget, BUFF_FACTION_TAX_LEVELING);
        break;
        case BUFF_TYPE_BARD_SONG:
            nCostWithObelisks = GetLocalInt(oTarget, BUFF_COST_SONG);
            nFactionTaxes = GetLocalInt(oTarget, BUFF_FACTION_TAX_SONG);
        break;
        case BUFF_TYPE_SWITCH_TO_CASH:
            npc_Caster_SetPaymentType(oTarget, BUFF_PAYMENT_TYPE_CASH);
        return;
        case BUFF_TYPE_SWITCH_TO_CASHLESS:
            npc_Caster_SetPaymentType(oTarget, BUFF_PAYMENT_TYPE_CASHLESS);
        return;
        case BUFF_TYPE_SWITCH_TO_XP:
            npc_Caster_SetPaymentType(oTarget, BUFF_PAYMENT_TYPE_XP);
        return;
        case BUFF_TYPE_UPDATE_TOKEN:
            npc_Caster_UpdateBuffCost(oTarget, iPcLevel, iFaction);
            npc_Caster_UpdatePaymentTypeToken(oTarget);
        return;
    }

    // scale buff power and DC by PC lvl
    int nBufferLevel = factions_GetFactionBufferLevel(iFaction);
    int nDefenceBonusDC = factions_GetFactionBufferBonusDC(iFaction);

    int iCasterLevel = iPcLevel > nBufferLevel ? nBufferLevel : (iPcLevel < BUFF_MIN_LEVEL ? BUFF_MIN_LEVEL : iPcLevel);
    int iDispelDC = 14 /* base */ + 4 /*arcane defence*/ + iCasterLevel + nDefenceBonusDC;

    int nPaymentType = npc_Caster_GetPaymentType(oTarget);
    int iPcGold;
    switch(nPaymentType)
    {
        case BUFF_PAYMENT_TYPE_CASH: iPcGold = GetGold(oTarget); break;
        case BUFF_PAYMENT_TYPE_CASHLESS: iPcGold = bank_GetAccountBalance(oTarget); break;
    }

    if(iPcGold >= nCostWithObelisks || nPaymentType == BUFF_PAYMENT_TYPE_XP)
    {
        switch (iBuffType)
        {
            case BUFF_TYPE_LONG:
                DelayCommand(0.25, npc_Caster_CastLongSpells(OBJECT_SELF, oTarget, iCasterLevel, iDispelDC, nCostWithObelisks, nFactionTaxes, nPaymentType));
            break;
            case BUFF_TYPE_SHORT:
                DelayCommand(0.25, npc_Caster_CastShortSpells(OBJECT_SELF, oTarget, iCasterLevel, iDispelDC, nCostWithObelisks, nFactionTaxes, nPaymentType));
            break;
            case BUFF_TYPE_LEVELING:
                DelayCommand(0.25, npc_Caster_CastLevelingSpells(OBJECT_SELF, oTarget, iCasterLevel, iDispelDC, nCostWithObelisks, nFactionTaxes, nPaymentType));
            break;
            case BUFF_TYPE_BARD_SONG:
                DelayCommand(0.25, npc_Caster_CastBardSong(OBJECT_SELF, oTarget, iCasterLevel, factions_GetFactionBufferPerformSkill(iFaction), nCostWithObelisks, nFactionTaxes, nPaymentType));
            break;
        }
    }
    else
        SpeakString("You don't have enough gold for my services. Come back when you have alot of gold.");
}

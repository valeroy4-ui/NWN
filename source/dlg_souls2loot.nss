#include "_inc_generic"
#include "_inc_factions"

void main()
{
    string sTierValue       = GetScriptParam("LOOT_BOSS_LEVEL");
    int iCost               = StringToInt(GetScriptParam("SOULS_COST"));

    object oPC              = GetPCSpeaker();

    int nFactionsTotalFame  = factions_GetTotalFactionsFame();

    int bKeyAccepted = FALSE;

    if       (sTierValue == "12" || sTierValue == "13"  /* advanced loot */)
        bKeyAccepted =  TRUE;
    else if ((sTierValue == "15" || sTierValue == "16") /* lesser loot */  && nFactionsTotalFame > MIN_TOTAL_FAME_FOR_LESSER_LOOT_ACCESS)
        bKeyAccepted =  TRUE;
    else if ((sTierValue == "18" || sTierValue == "19") /* greater loot */ && nFactionsTotalFame > MIN_TOTAL_FAME_FOR_GREATER_LOOT_ACCESS)
        bKeyAccepted =  TRUE;

    if (bKeyAccepted)
        generic_BuyKeyForSoulStones(oPC, iCost, "fl_soul_key_tier_" + sTierValue);
    else
        FloatingColorTextStringOnCreature("Not enough total factions fame to purchase selected key.", TXT_COLOR_RED, oPC, FALSE);
}

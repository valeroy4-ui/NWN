#include "_inc_fshop_fact"

void main()
{
    object oPC = GetLastSpeaker();
    int iDialogFactionFameShopType = StringToInt(GetScriptParam("DIALOG_FACTION_FAMESHOP_TYPE"));
    switch (iDialogFactionFameShopType)
    {
        case DIALOG_FACTION_FAMESHOP_TYPE_REFRESH_TOKENS:
            fact_RefreshFactionTokens(oPC);
        break;
        case DIALOG_FACTION_FAMESHOP_TYPE_XP_LEVEL:
            fact_TryToBuyFactionXPBonus(oPC, StringToInt(GetScriptParam("DIALOG_FACTION_FAMESHOP_XP_LEVEL")),
                                             StringToInt(GetScriptParam("DIALOG_FACTION_FAMESHOP_FAME_COST")),
                                             StringToInt(GetScriptParam("DIALOG_FACTION_FAMESHOP_GOLD_COST")));
        break;
        case DIALOG_FACTION_FAMESHOP_TYPE_BUFFER_LEVELS:
            fact_TryToBuyFactionBufferLevel(oPC, StringToInt(GetScriptParam("DIALOG_FACTION_FAMESHOP_CLERIC_LEVEL")),
                                                 StringToInt(GetScriptParam("DIALOG_FACTION_FAMESHOP_GOLD_COST")));
        break;
        case DIALOG_FACTION_FAMESHOP_TYPE_BUFFER_BONUS_DC:
            fact_TryToBuyFactionBufferBonusDC(oPC, StringToInt(GetScriptParam("DIALOG_FACTION_FAMESHOP_BONUS_DC")),
                                                   StringToInt(GetScriptParam("DIALOG_FACTION_FAMESHOP_FAME_COST")));
        break;
        case DIALOG_FACTION_FAMESHOP_TYPE_BUFFER_PERFORM_SKILL:
            fact_TryToBuyFactionBufferPerformSkill(oPC, StringToInt(GetScriptParam("DIALOG_FACTION_PERFORM_SKILL_VALUE")),
                                                        StringToInt(GetScriptParam("DIALOG_FACTION_PERFORM_SKILL_COST")));
        break;
        case DIALOG_FACTION_FAMESHOP_TYPE_BUFFER_SONG_UPGRADE:
            fact_TryToBuyFactionSongUpgradeLevel(oPC, StringToInt(GetScriptParam("DIALOG_FACTION_SONG_UPGRADE_LEVEL")),
                                                      StringToInt(GetScriptParam("DIALOG_FACTION_SONG_UPGRADE_GOLD_COST")));
        break;
        case DIALOG_FACTION_FAMESHOP_TYPE_STARGATES:
            fact_TryToActivateStargates(oPC, StringToInt(GetScriptParam("DIALOG_FACTION_ACTIVE_STARGATE_NUMBER")),
                                             StringToInt(GetScriptParam("DIALOG_FACTION_ACTIVE_STARGATE_GOLD_COST")));
        break;
        case DIALOG_FACTION_FAMESHOP_TYPE_GUARDS_LEVEL:
            fact_TryToBuyGuardsLevel(oPC, StringToInt(GetScriptParam("DIALOG_FACTION_FAMESHOP_GUARDS_LEVEL")),
                                          StringToInt(GetScriptParam("DIALOG_FACTION_FAMESHOP_FAME_COST")));
        break;


    }
}

#include "_inc_generic"
#include "_inc_citykeeper"
#include "_inc_guard_spawn"
#include "_inc_discord_rpt"

void main()
{
    object oKeeper = OBJECT_SELF;
    int iKeeperFaction = players_GetFaction(oKeeper);
    object oWP = GetNearestObject(OBJECT_TYPE_WAYPOINT);
    string sDamager = GetLocalString(GetModule(), "KEEPER_KILLER");
    int nDamagerFaction = GetLocalInt(GetModule(), "KEEPER_KILLER_FACTION");

    ServerShout(ColorText(sDamager, players_GetFactionColor(nDamagerFaction)) + ColorText(" destroyed the City Keeper of ", TXT_COLOR_ORANGE) +
                players_GetFactionName(iKeeperFaction, TRUE) + ColorText(" faction", TXT_COLOR_ORANGE));
    ServerShout(ColorText("Attack begins. Remember, you have only two hours.", TXT_COLOR_ORANGE));

    SendMessageToEventChannelOfDiscord("**" + NWNX_Util_StripColors(sDamager) + "** destroyed the **City Keeper** of **" + players_GetFactionName(iKeeperFaction, FALSE) + "** faction");
    SendMessageToEventChannelOfTelegram("<b>" + NWNX_Util_StripColors(sDamager) + "</b> destroyed the <b>City Keeper</b> of <b>" + players_GetFactionName(iKeeperFaction, FALSE) + "</b> faction");

    AssignCommand(GetModule(), DelayCommand(3.0, DestroyObject(GetObjectByTag(GetTag(oKeeper))))); //crypton 05.05.2016
    AssignCommand(GetModule(), DelayCommand(KEEPER_RESPAWN_TIME, DeleteLocalInt(GetModule(), "KILLED_CAPTAINS_COUNT_FACTION_" + IntToString(iKeeperFaction))));
    AssignCommand(GetModule(), DelayCommand(KEEPER_RESPAWN_TIME, guard_SetLockedFactionTreasureDoor(iKeeperFaction, TRUE)));
    AssignCommand(GetModule(), DelayCommand(KEEPER_RESPAWN_TIME, guard_ReturnGoldInTreasure(iKeeperFaction)));
    AssignCommand(GetModule(), DelayCommand(KEEPER_RESPAWN_TIME, CreateKeeperOnWaypoint(oWP)));
    AssignCommand(GetModule(), DelayCommand(KEEPER_RESPAWN_TIME, RespawnFactionGuards(iKeeperFaction)));
    AssignCommand(GetModule(), DelayCommand(KEEPER_RESPAWN_TIME, ServerShout(ColorText("The City Keeper", TXT_COLOR_WHITE_T) + ColorText(" of ", TXT_COLOR_ORANGE) +
                                                                             players_GetFactionName(iKeeperFaction, TRUE) + ColorText(" faction is alive!", TXT_COLOR_ORANGE) )));
    AssignCommand(GetModule(), DelayCommand(KEEPER_RESPAWN_TIME, SendMessageToEventChannelOfDiscord("The **City Keeper** of **" +
                                                                                                     players_GetFactionName(iKeeperFaction, FALSE) +
                                                                                                     "** faction is alive!" )));
    AssignCommand(GetModule(), DelayCommand(KEEPER_RESPAWN_TIME, SendMessageToEventChannelOfTelegram("The <b>City Keeper</b> of <b>" +
                                                                                                     players_GetFactionName(iKeeperFaction, FALSE) +
                                                                                                     "</b> faction is alive!" )));

    SetLocalInt(GetModule(), "FACTION_" + IntToString(iKeeperFaction) + "_IS_DESTROYED", TRUE);
    WriteLog(GetTag(oKeeper) + " destroyed. RespawnTime=" + FloatToString(KEEPER_RESPAWN_TIME, 9, 0), LOG_LEVEL_INFO);
}

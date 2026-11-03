#include "_inc_players"
#include "x0_i0_spells"

void RestoreReputation(object oPlayer);

void SetFactionReputation(object oTarget, object oFactMemb, int nRep)
{
    int nAmm = nRep - GetReputation(oFactMemb, oTarget);
    ClearPersonalReputationWithFaction(oTarget, oFactMemb);
    AdjustReputationWithFaction(oTarget, oFactMemb, nAmm);
}


void RestoreReputation(object oPlayer)
{
    if (GetStandardFactionReputation(STANDARD_FACTION_COMMONER, oPlayer) <= 10)
        SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 100, oPlayer);
    if (GetStandardFactionReputation(STANDARD_FACTION_MERCHANT, oPlayer) <= 10)
        SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 100, oPlayer);
    if (GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, oPlayer) <= 10)
        SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 100, oPlayer);
    switch(players_GetFaction(oPlayer))
    {
        case FACTION_EMPIRE:
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_EMPIRE),      100);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_UNDERDARK),   0);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_IRON_THRONE), 0);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_DRAGON_CULT), 0);
        break;
        case FACTION_UNDERDARK:
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_EMPIRE),      0);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_UNDERDARK),   100);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_IRON_THRONE), 0);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_DRAGON_CULT), 0);
        break;
        case FACTION_IRON_THRONE:
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_EMPIRE),      0);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_UNDERDARK),   0);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_IRON_THRONE), 100);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_DRAGON_CULT), 0);
        break;
        case FACTION_DRAGON_CULT:
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_EMPIRE),      0);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_UNDERDARK),   0);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_IRON_THRONE), 0);
            SetFactionReputation(oPlayer, players_GetFactionSystemNPC(FACTION_DRAGON_CULT), 100);
        break;
    }
}


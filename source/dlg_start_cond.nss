#include "_inc_factions"

const int CONDITIONAL_TYPE_OPEN_CLASSES            = 1;
const int CONDITIONAL_TYPE_WIPE_PHASE              = 2;
const int CONDITIONAL_TYPE_ENABLE_BUFFER_LEVEL     = 3;
const int CONDITIONAL_TYPE_ACTIVE_STARGATES        = 4;
const int CONDITIONAL_TYPE_OPEN_GNOME              = 5;

int StartingConditional()
{
    int iResult = FALSE;
    int iConditionalType = StringToInt(GetScriptParam("CONDITIONAL_TYPE"));

    switch(iConditionalType)
    {
        case CONDITIONAL_TYPE_OPEN_CLASSES:
            iResult = FALSE;
        break;
        case CONDITIONAL_TYPE_WIPE_PHASE:
        {
            int nWipePhase = GetLocalInt(GetModule(), CORMYREAN_WIPE_PHASE);
            int nAvailableForPhase = StringToInt(GetScriptParam("CORMYREAN_WIPE_PHASE"));
            if(nWipePhase >= nAvailableForPhase)
                iResult = TRUE;
            else
                iResult = FALSE;
        }
        break;
        case CONDITIONAL_TYPE_ENABLE_BUFFER_LEVEL:
            iResult = FALSE;
        break;
        case CONDITIONAL_TYPE_ACTIVE_STARGATES:
        {
            int nFaction = players_GetFaction(OBJECT_SELF);
            object oStargate1 = players_GetFactionStargate(nFaction, 1);
            object oStargate2 = players_GetFactionStargate(nFaction, 2);
            object oStargate3 = players_GetFactionStargate(nFaction, 3);
            int nActiveStargates = factions_GetFactionActiveStargates(nFaction);
            if(OBJECT_SELF == oStargate1 && nActiveStargates >= 1 || OBJECT_SELF == oStargate2 && nActiveStargates >= 2 ||
               OBJECT_SELF == oStargate3 && nActiveStargates >= 3)
                iResult = TRUE;
        }
        break;
        case CONDITIONAL_TYPE_OPEN_GNOME:
            iResult = FALSE;
        break;
    }
    return iResult;
}

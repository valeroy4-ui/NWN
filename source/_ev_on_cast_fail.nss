#include "nwnx_events"
#include "_inc_colortext"

//
string GetReasonDescription(int nReason);

void main()
{
    if(NWNX_Events_GetCurrentEvent() == NWNX_ON_SPELL_FAILED_AFTER)
    {
        object oCaster  = OBJECT_SELF;
        int nReason = StringToInt(NWNX_Events_GetEventData("REASON"));

        string sMessage = GetReasonDescription(nReason);
        if(GetIsPC(oCaster) && sMessage != "")
            SendColorMessageToPC(oCaster, sMessage, TXT_COLOR_RED);

    }
}

string GetReasonDescription(int nReason)
{
    switch(nReason)
    {
        case NWNX_EVENTS_SPELLFAIL_REASON_CANCELED: return "Spell has been canceled.";
        case NWNX_EVENTS_SPELLFAIL_REASON_COUNTERSPELL: return "Spell has been counterspelled.";
        case NWNX_EVENTS_SPELLFAIL_REASON_ASF: return "Spell failed because ASF.";
        case NWNX_EVENTS_SPELLFAIL_REASON_SPELLFAILURE: return "Spell failed because you're under spellfailure.";
        case NWNX_EVENTS_SPELLFAIL_REASON_LOST_TARGET: return "You have lost spell target.";
        case NWNX_EVENTS_SPELLFAIL_REASON_SILENCED: return "You are silenced.";
        case NWNX_EVENTS_SPELLFAIL_REASON_DEFCAST_CONCENTRATION: return "You have failed concentration in defensive casting mode.";
        case NWNX_EVENTS_SPELLFAIL_REASON_ENTANGLE_CONCENTRATION: return "You have failed concentration";
        case NWNX_EVENTS_SPELLFAIL_REASON_POLYMORPHED: return "Spell failed because you're polymorphed.";
        case NWNX_EVENTS_SPELLFAIL_REASON_CANT_CAST: return "You can't cast.";
        case NWNX_EVENTS_SPELLFAIL_REASON_CANT_USE_HANDS: return "You can't use hands.";
    }
    return "";
}

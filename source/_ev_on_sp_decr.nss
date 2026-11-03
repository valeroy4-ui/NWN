#include "nwnx_events"
#include "_inc_runes"

void main()
{
    if (NWNX_Events_GetCurrentEvent() == "NWNX_ON_DECREMENT_SPELL_COUNT_BEFORE")
    {
        object oCaster  = OBJECT_SELF;
        int nSpellID = StringToInt(NWNX_Events_GetEventData("SPELL_ID"));
        int bSkip = FALSE;
        switch(nSpellID)
        {
            case SPELL_GATE:
            case 1800 /* Anchor */ :
                if(runes_GetHasRune(oCaster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_III))
                    bSkip = TRUE;
                break;
            default:
                break;
        }
        if(bSkip)
            NWNX_Events_SkipEvent();
    }
}

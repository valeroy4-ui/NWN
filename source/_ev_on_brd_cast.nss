/// NWNX spellhook
/// execution sequence:
/// NWNX_ON_INPUT_CAST_SPELL_*
/// NWNX_ON_BROADCAST_CAST_SPELL_*
/// NWNX_ON_CAST_SPELL_*

#include "nwnx_events"
#include "_inc_spellhook"

void main()
{
    if (NWNX_Events_GetCurrentEvent() == NWNX_ON_BROADCAST_CAST_SPELL_AFTER)
    {
        string sSpellID     = NWNX_Events_GetEventData("SPELL_ID");
        int iSpellID        = StringToInt(sSpellID);
        // show spellcast log
        ShowSpellCastMessage(OBJECT_SELF, iSpellID, EVENT_TYPE_ON_BROADCAST_CAST_SPELL);
    }
}

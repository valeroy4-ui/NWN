#include "nwnx_events"
#include "_inc_players"
#include "_inc_reputation"
#include "_inc_spells"

//
int feat_GetFeatSpellId(int nFeat);

void main()
{
    if (NWNX_Events_GetCurrentEvent() == NWNX_ON_USE_FEAT_BEFORE)
    {
        int iFeatID     = StringToInt(NWNX_Events_GetEventData("FEAT_ID"));
        object oTarget  = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));
        int iBypass     = FALSE;
        if(spells_GetHasSpellCooldown(feat_GetFeatSpellId(iFeatID), OBJECT_SELF))
        {
            FloatingColorTextStringOnCreature("Wait for the cooldown.", TXT_COLOR_RED, OBJECT_SELF, FALSE);
            iBypass  = TRUE;
        }
        if (iFeatID == FEAT_SUMMON_FAMILIAR)
        {
            FloatingColorTextStringOnCreature("Familiars are disabled.", TXT_COLOR_RED, OBJECT_SELF, FALSE);
            iBypass  = TRUE;
        }
        if(iBypass)
            NWNX_Events_SkipEvent();
    }
}



int feat_GetFeatSpellId(int nFeat)
{
    return StringToInt(Get2DAString("feat", "spellid", nFeat));
}

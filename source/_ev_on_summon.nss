#include "nwnx_events"
#include "_inc_dispel"

void main()
{
    string sEvent = NWNX_Events_GetCurrentEvent();
    if (sEvent == "NWNX_ON_ADD_ASSOCIATE_AFTER")
    {
        object oSummon = StringToObject(NWNX_Events_GetEventData("ASSOCIATE_OBJECT_ID"));
        dispel_AddSpellDataOnTarget(OBJECT_SELF, oSummon, SPELL_ALL_SUMMONED_CREATURES);
        NWNX_Creature_AddFeat(oSummon, FEAT_SPRING_ATTACK);
        NWNX_Creature_SetChallengeRating(oSummon, 0.0);
    }
}

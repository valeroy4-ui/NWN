/************************ [On Heartbeat] ***************************************
    Filename: nw_c2_default1 or j_ai_onheartbeat
************************* [On Heartbeat] ***************************************/

#include "_inc_players"
#include "_inc_generic"
#include "_inc_areas"
#include "j_inc_constants"

void AntiAlt(object oBoss, object oArea)
{
    if (GetLocalInt(oArea, "ALTEROK_DETECTED") == TRUE)
    {
        ForceRest(oBoss);
        switch(d4())
        {
            case 1: AssignCommand(OBJECT_SELF,SpeakString("Fucking ALT+F4 user!")); break;
            case 2: AssignCommand(OBJECT_SELF,SpeakString("Scaredy-cat detected!")); break;
            case 3: AssignCommand(OBJECT_SELF,SpeakString("I've found combat logger in your party!")); break;
            case 4: AssignCommand(OBJECT_SELF,SpeakString("Alterok ebuchiy!")); break;
        }
        DeleteLocalInt(oArea, "ALTEROK_DETECTED");
        // restore max heals after alt
        SetLocalInt(OBJECT_SELF, "BOSS_HEALS", GetLocalInt(OBJECT_SELF, "MAX_BOSS_HEALS"));
        // clear Satana ultimate state
        DeleteLocalInt(oBoss, "SatanaUltimateUsed");
    }
}

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    // no player in Area, let restore all heals and abilities!
    if(GetIsObjectValid(oArea) && !areas_GetNumberOfPlayersInArea(oArea, FALSE))
    {
        if(GetLocalInt(OBJECT_SELF, "MAX_BOSS_HEALS")){
            SetLocalInt(OBJECT_SELF, "BOSS_HEALS", GetLocalInt(OBJECT_SELF, "MAX_BOSS_HEALS"));
        }
        ForceRest(OBJECT_SELF);
        return;
    }
    AntiAlt(OBJECT_SELF, oArea);

    /* Debug
    object oTmp;
    oTmp = GetAIObject(AI_LAST_MELEE_TARGET);
    SpeakString("AI_LAST_MELEE_TARGET: " + GetName(oTmp));
    oTmp = GetAIObject(AI_LAST_SPELL_TARGET);
    SpeakString("AI_LAST_SPELL_TARGET: " + GetName(oTmp));
    oTmp = GetAIObject(AI_LAST_RANGED_TARGET);
    SpeakString("AI_LAST_RANGED_TARGET: " + GetName(oTmp));
    AssignCommand(OBJECT_SELF, SpeakString("TEST"));
    */

    // Great Mother Events
    if(GetTag(OBJECT_SELF) == "cr_boss_chauntea")
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_USER_DEFINED_BOSS_CHAUNTEA));
        // despawn ==>
        int bBossInstance = GetLocalInt(GetArea(OBJECT_SELF), AREA_FLAG_INSTANCE_BOSS);
        int nHour = GetLocalInt(GetModule(), "SERVER_HOUR");
        if(!db_GetIsPrimeTime() && !bBossInstance)
            generic_DestroyCreature(OBJECT_SELF, TRUE);
        // despawn <==
    }
    else if(GetLocalInt(OBJECT_SELF, "MUTATED"))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_USER_DEFINED_BOSS_MUTATED));
    }

    ExecuteScript("nw_c2_default1", OBJECT_SELF);
}

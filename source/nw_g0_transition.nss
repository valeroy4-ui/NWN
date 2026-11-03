#include "_inc_factions"
#include "_inc_death"
#include "_inc_champ_boss"



int bAllow = TRUE;
const float TRIGGER_TIMEOUT = 11.0; // +1 sec cos crutches


location GetRightLocation(object oTarget, float fDistance)
{
    float fDir = GetFacing(oTarget);
    float fAngle = GetRightDirection(fDir);
    return GenerateNewLocation(oTarget,
                               fDistance,
                               fAngle,
                               fDir);
}

location GetLeftLocation(object oTarget, float fDistance)
{
    float fDir = GetFacing(oTarget);
    float fAngle = GetLeftDirection(fDir);
    return GenerateNewLocation(oTarget,
                               fDistance,
                               fAngle,
                               fDir);
}

location GetTriggerRelativePosition(object oTrigger, object oClicker)
{

    object oDestination = GetTransitionTarget(oTrigger);
    location lDest = GetLocation(oDestination);
    // Transition object is not trigger and his destination is not waypoint (door to whatever transition type)
    if(!(GetObjectType(oTrigger) == OBJECT_TYPE_TRIGGER && GetObjectType(oDestination) == OBJECT_TYPE_WAYPOINT))
    {
        return lDest;
    }
    // One way transition
    object oSelfWaypoint = GetNearestObjectByTag("WP_"+GetTag(oTrigger), oTrigger);
    if(!GetIsObjectValid(oSelfWaypoint))
    {
        return lDest;
    }

    float fDistance = GetDistanceBetween(oSelfWaypoint, oClicker);

    location lClickerLoc = GetLocation(oClicker);

    location lWpLeft = GetStepLeftLocation(oSelfWaypoint);
    location lWpRight = GetStepRightLocation(oSelfWaypoint);

    float fDistanceToLeft = GetDistanceBetweenLocations(lClickerLoc, lWpLeft);
    float fDistanceToRight = GetDistanceBetweenLocations(lClickerLoc, lWpRight);

    if(fDistanceToLeft > fDistanceToRight)
    {
        lDest = GetLeftLocation(oDestination, fDistance);
    }
    else
    {
        lDest = GetRightLocation(oDestination, fDistance);
    }

    if(!GetIsWalkableLocation(lDest))
    {
        lDest = GetLocation(oDestination);
    }

    return lDest;
}

void ClearLocalVarsWorker(object oTransitionSrc, object oTransitionDest, object oClicker, string sAntiSpamVar)
{
    // players area is valid and player is valid => player successfully entered into area => clear local vars
    if(GetIsObjectValid(GetArea(oClicker)) && GetIsObjectValid(oClicker))
    {
        // clear local vars
        DelayCommand(TRIGGER_TIMEOUT, SetLocalInt(oTransitionSrc, sAntiSpamVar, FALSE));
        DelayCommand(TRIGGER_TIMEOUT, SetLocalInt(oTransitionDest, sAntiSpamVar, FALSE));
        DelayCommand(TRIGGER_TIMEOUT, FloatingColorTextStringOnCreature("You are allowed to leave the area now.",
                                                    TXT_COLOR_ORANGE, oClicker));
    }
    else
    {
        // character does not loaded area yet
        // run checker 1 sec later
        if(GetIsObjectValid(oClicker))
            DelayCommand(0.1, ClearLocalVarsWorker(oTransitionSrc, oTransitionDest, oClicker, sAntiSpamVar));
        // player disconnected, clear local vars
        else
        {
            SetLocalInt(oTransitionSrc, sAntiSpamVar, FALSE);
            SetLocalInt(oTransitionDest, sAntiSpamVar, FALSE);
        }
    }
}

object GetDestinationTrigger()
{
    location lLoc = GetLocation(GetTransitionTarget(OBJECT_SELF));
    int iSelfType = GetObjectType(OBJECT_SELF);
    object oSelfDest = GetTransitionTarget(OBJECT_SELF);
    string sSelfTag = GetTag(OBJECT_SELF);
    object oLoop = GetFirstObjectInShape(SHAPE_SPHERE, 10.0, lLoc, FALSE, OBJECT_TYPE_TRIGGER);
    while(GetIsObjectValid(oLoop)){
        if(iSelfType == OBJECT_TYPE_TRIGGER){
            if(GetSubString(GetTag(GetTransitionTarget(oLoop)), 3, 32) == sSelfTag)
                return oLoop;
        }
        else if(iSelfType == OBJECT_TYPE_DOOR){
            if(GetTransitionTarget(oLoop) == OBJECT_SELF)
                return oLoop;
        }
        oLoop = GetNextObjectInShape(SHAPE_SPHERE, 10.0, lLoc, FALSE, OBJECT_TYPE_TRIGGER);
    }
    return OBJECT_INVALID;
}

int GetHostileCreatureIsNear(object oClicker)
{
    int result = FALSE;
    object oArea = GetArea(OBJECT_SELF);
    location lLoc = GetLocation(OBJECT_SELF);
    object oLoop = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, lLoc, FALSE, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(oLoop)){
        if(GetIsEnemy(oClicker, oLoop) && !GetIsDead(oLoop)){
            result = TRUE;
            break;
        }
        oLoop = GetNextObjectInShape(SHAPE_SPHERE, 20.0, lLoc, FALSE, OBJECT_TYPE_CREATURE);
    }
    return result;
}

void main()
{
    object oClicker = GetClickingObject();
    object oClickerArea = GetArea(oClicker);
    object oDestObject = GetTransitionTarget(OBJECT_SELF);
    object oDestArea = GetArea(oDestObject);
    int bSetTimeoutVar = FALSE;
    int bIsPlayer = FALSE;

    if(GetIsPC(oClicker) && !GetIsDM(oClicker))
        bIsPlayer = TRUE;

    // not allowed transition for Guards, Bosses and other NPCs in PvP mode
    if(!GetIsDM(oClicker) && !GetIsPC(oClicker) && !GetIsDMPossessed(oClicker) &&
       (champion_GetIsBoss(oClicker) || players_GetHasEnemyPlayersInRelatedAreas(oDestArea, oClickerArea) ||
        GetLocalInt(oClicker, "IMGUARD")) || (champion_GetIsEliteChampion(oClicker) /* || GetChallengeRating(oClicker) >= 60.0 */) && players_GetFaction(oDestArea))
    {
        AssignCommand(oClicker, ClearAllActions());
        return;
    }

    // clicker is player => check local vars at doors/triggers
    if(bIsPlayer)
    {
        string sAccount = GetPCPlayerName(oClicker);
        string sAntiSpamVar = "AntiSpamTrig_" + GetPCPlayerName(oClicker);
        int iDestType = GetObjectType(oDestObject);
        object oVarHolder;
        if(iDestType == OBJECT_TYPE_WAYPOINT)
        {
            oVarHolder = GetDestinationTrigger();
            SetLocalObject(oClicker, "CAMERA_FACING_FIX", oDestObject);
        }
        else if(iDestType == OBJECT_TYPE_DOOR)
            oVarHolder = oDestObject;

        // Fugue exit CD
        int nTimeRest = DEATH_FUGUE_EXIT_COOLDOWN - (SQLite_GetTimeStamp() - SQLocals_GetLastUpdated_UnixEpoch(oClicker, DEATH_TIME_MARKER, SQLOCALS_TYPE_INT));
        if (GetResRef(oClickerArea) == CONST_AREA_ABYSS_RESREF && nTimeRest > 0)
        {
            AssignCommand(oClicker, ClearAllActions());
            DelayCommand(0.2, FloatingColorTextStringOnCreature("You're still recovering from the shock of your recent death. " + IntToString(nTimeRest) + " second(s) left.",
                                                TXT_COLOR_RED, oClicker, FALSE));
            return;
        }
        if(!players_GetIsFactionEnabled(players_GetFaction(oDestArea)))
        {
            AssignCommand(oClicker, ClearAllActions());
            DelayCommand(0.2, FloatingColorTextStringOnCreature("Faction disabled.", TXT_COLOR_RED, oClicker, FALSE));
            return;
        }

        int iNeedTotalFactionsFame = GetLocalInt(oDestObject, "iNeedTotalFactionsFame");
        int nWipePhase = GetLocalInt(GetModule(), CORMYREAN_WIPE_PHASE);
        int nTotalFame = factions_GetTotalFactionsFame();
        if(iNeedTotalFactionsFame > 0 &&
           (!StringToInt(db_GetModuleParameter("enable_epic_bosses_access"))                                          ||
            iNeedTotalFactionsFame > nTotalFame                                                                       ||
            iNeedTotalFactionsFame >= MIN_TOTAL_FAME_FOR_LESSER_LOOT_ACCESS  &&  nWipePhase < CORMYREAN_WIPE_PHASE_2  ||
            iNeedTotalFactionsFame >= MIN_TOTAL_FAME_FOR_GREATER_LOOT_ACCESS &&  nWipePhase < CORMYREAN_WIPE_PHASE_3)
          )
        {
            DelayCommand(0.2, FloatingColorTextStringOnCreature("Not enough total factions fame to enter this area.",
                                                                TXT_COLOR_RED, oClicker, TRUE));
            return;
        }
        // 25+ lvl required for lesser bosses, 35+ for greater
        else if(GetHitDice(oClicker) < 25 && iNeedTotalFactionsFame >= MIN_TOTAL_FAME_FOR_LESSER_LOOT_ACCESS)
        {
            DelayCommand(0.2, FloatingColorTextStringOnCreature("Not enough total factions fame or you need 25+ level to enter this area.",
                                                                    TXT_COLOR_RED, oClicker, TRUE));
            return;
        }
        else if (GetHitDice(oClicker) < 35 && iNeedTotalFactionsFame >= MIN_TOTAL_FAME_FOR_GREATER_LOOT_ACCESS)
        {
            DelayCommand(0.2, FloatingColorTextStringOnCreature("Not enough total factions fame or you need 35+ level to enter this area.",
                                                                    TXT_COLOR_RED, oClicker, TRUE));
            return;
        }

        if(GetLocalInt(OBJECT_SELF, sAntiSpamVar))
            bAllow = FALSE;
        else if(GetIsInCombat(oClicker) || GetHostileCreatureIsNear(oClicker))
        {

            bSetTimeoutVar = TRUE;
            // delay for prevent incorrect triggering
            DelayCommand(0.9, SetLocalInt(oVarHolder, sAntiSpamVar, TRUE));
            DelayCommand(0.9, SetLocalInt(OBJECT_SELF, sAntiSpamVar, TRUE));
            DelayCommand(1.0, ClearLocalVarsWorker(OBJECT_SELF, oVarHolder, oClicker, sAntiSpamVar));
        }
    }
    if(bAllow)
    {
        if(bIsPlayer && !GetIsPCAllowedToEnterArea(oClicker, oDestArea))
        {
            SendColorMessageToPC(oClicker, "The area you want to enter is protected by a city keeper statue.", TXT_COLOR_RED);
            return;
        }
        if(bIsPlayer)
        {
            // DistanceMonitor spdmon_start.nss
            SetLocalLocation(oClicker, "sm_location", GetLocation(oDestObject));
        }

        SetLocalLocation(oClicker, "LAST_PLAYER_LOCATION", GetLocation(oClicker));
        DeleteLocalInt(oClicker, "TELEPORTING");

        if(GetObjectType(oDestObject) == OBJECT_TYPE_DOOR)
        {
            AssignCommand(oClicker, JumpToObject(oDestObject));
            AssignCommand(oClicker, JumpToObject(oDestObject));
            AssignCommand(oClicker, JumpToObject(oDestObject));
        }
        else
        {
            location lDest = GetTriggerRelativePosition(OBJECT_SELF, oClicker);
            AssignCommand(oClicker, JumpToLocation(lDest));
            AssignCommand(oClicker, JumpToLocation(lDest));
            AssignCommand(oClicker, JumpToLocation(lDest));
        }

    }
    else
        SendColorMessageToPC(oClicker, "Please wait.", TXT_COLOR_ORANGE);
}

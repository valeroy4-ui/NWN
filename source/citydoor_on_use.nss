#include "x0_i0_position"
#include "_inc_factions"
#include "_inc_players"
#include "j_inc_constants"

// calculate points in oDoor front\back and teleport oCreature
void PassCreatureThroughDoor(object oDoor, object oCreature)
{
    object oDestination = GetTransitionTarget(oDoor);
    if(GetIsObjectValid(oDestination))
    {
        if(GetObjectType(oDestination) == OBJECT_TYPE_WAYPOINT)
            SetLocalObject(oCreature, "CAMERA_FACING_FIX", oDestination);
        AssignCommand(oCreature, JumpToObject(oDestination));
    }
    else
    {
        object oCurrentArea = GetArea(oDoor);

        float fOrientationDoor = GetFacing(oDoor);
        float fBackOrientationDoor = fOrientationDoor - 180.f;

        vector vDoorPosition = GetPosition(oDoor);

        vector vFrontPos = GetChangedPosition(vDoorPosition, 1.8f, fOrientationDoor);
        location lFrontLoc = Location(oCurrentArea, vFrontPos, fOrientationDoor);

        vector vBackPos = GetChangedPosition(vDoorPosition, -1.8f, fOrientationDoor);
        location lBackLoc = Location(oCurrentArea, vBackPos, fBackOrientationDoor);

        location lPlayerLoc = GetLocation(oCreature);
        float fDistanceToFront = GetDistanceBetweenLocations(lPlayerLoc, lFrontLoc);
        float fDistanceToBack = GetDistanceBetweenLocations(lPlayerLoc, lBackLoc);

        AssignCommand(oCreature, ClearAllActions());

        location lLocToJump = lBackLoc;
        if(fDistanceToFront > fDistanceToBack)
        {
            lLocToJump = lFrontLoc;
        }
        AssignCommand(oCreature, JumpToLocation(lLocToJump));
        // drop targeting
        if(!GetIsDM(oCreature)) ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectEthereal(), oCreature, 0.1);
    }
}

void main()
{
    object oDoor = OBJECT_SELF;
    if(GetIsOpen(oDoor)) return;

    object oClicker = GetClickingObject();
    int iAllowPass = FALSE;

    iAllowPass = players_GetFactionsEqual(oDoor, oClicker);
    // DM or NPC with same faction
    if(GetIsDM(oClicker))
    {
        iAllowPass = TRUE;
    }
    else if(!GetIsPC(oClicker) && GetFactionEqual(oDoor, oClicker))
    {
        iAllowPass = TRUE;
    }
    else if(GetIsPC(oClicker) && players_GetFactionsEqual(oDoor, oClicker))
    {
        iAllowPass = TRUE;
    }

    if(iAllowPass)
    {
        PassCreatureThroughDoor(oDoor, oClicker);
        object oTransitionDoor = GetTransitionTarget(oDoor);
        ActionCloseDoor(oTransitionDoor);
        ActionCloseDoor(oDoor);
        if(!GetIsPC(oClicker) && GetFactionEqual(oDoor, oClicker))
        {
            if(GetIsInCombat(oClicker))
                DelayCommand(0.1, ExecuteScript(COMBAT_FILE, oClicker));
            else
                DelayCommand(0.1, ExecuteScript(FILE_WALK_WAYPOINTS, oClicker));
        }
    }
    else
    {
        AssignCommand(oClicker, ActionAttack(oDoor));
    }
}

#include "nwnx_admin"
#include "nwnx_effect"
#include "nwnx_encounter"
#include "_inc_array"
#include "_inc_generic"
#include "_inc_champ_boss"
#include "_inc_feat2skin"
#include "x0_i0_position"


//
void area_TEST();

//
void area_GenerateMapNotes(object oArea);

//
void area_CreateMapNote(location lCenter, string sMapNoteText);

//
location area_FindPolygonCenter(object oTransition);

//
int area_GetWaypontPositionNearTrigger(object oWaypoint, object oTrigger);

//
object area_GetWayPointFromNextSideTrigger(object oTrigger, object oTargetWaypoint);


void main()
{

    object oPC = GetSpellTargetObject();
    //AddFeat(FEAT_STILL_SPELL, oPC);
    RemoveFeat(FEAT_STILL_SPELL, oPC);
    //ExecuteScript("spdmon_start", oPC);
    //CopyObject(oPC, GetLocation(oPC));
/*
    area_GenerateMapNotes(GetArea(OBJECT_SELF));


    object oBaseNPC = GetObjectByTag("member_underdark");
    ChangeFaction(oPC, oBaseNPC);



    int nArraySize = Array_Size("RANDOM_ENCOUNTERS_ARRAY", oStorage);
    ServerShout("nArraySize: " + IntToString(nArraySize));
    int i;
    for (i = 0; i < nArraySize; i++)
    {
        object oEncounter = Array_At_Obj("RANDOM_ENCOUNTERS_ARRAY", i, oStorage);
        location lLoc = GetLocation(oEncounter);
        vector vPosition = GetPositionFromLocation(lLoc);
        string sCoordinates = "x=" + FloatToString(vPosition.x, 2, 2) + " y=" + FloatToString(vPosition.y, 2, 2) + " z=" + FloatToString(vPosition.z, 2, 2);
        object oArea = GetArea(oEncounter);
        ServerShout("Area name: " + GetName(oArea) + " | Coordinates: " + sCoordinates);
    }

*/
    //champion_EliteInit();
    //champion_EliteRandomSpawn();


   // NWNX_Creature_SetDomain(oPC, CLASS_TYPE_CLERIC, 1, NWNX_CREATURE_CLERIC_DOMAIN_TRICKERY);

    //NWNX_Creature_SetDomain(oPC, CLASS_TYPE_CLERIC, 1, NWNX_CREATURE_CLERIC_DOMAIN_ANIMAL);

    //NWNX_Creature_RemoveFeat(oPC, FEAT_TRICKERY_DOMAIN_POWER);
    //NWNX_Creature_AddFeatByLevel(oPC, FEAT_TRICKERY_DOMAIN_POWER, 1);
    //RemoveFeat(FEAT_TRICKERY_DOMAIN_POWER, oPC);
    //AddFeat(FEAT_TRICKERY_DOMAIN_POWER, oPC);

    /*
    for (i=0; i< 50; i++)
    {
        ServerShout("Roll: " + IntToString(12*d12()));
    }
    */
}
/*
void area_GenerateMapNotes(object oArea)
{
    string sLogMessage = "";
    object oArea = GetFirstArea();
    while(GetIsObjectValid(oArea))
    {
        object oTransition = GetFirstObjectInArea(oArea);
        string sAreaName = GetName(oArea);
        // for all valid triggers
        while(GetIsObjectValid(oTransition))
        {
            int nTransitionObjectType = GetObjectType(oTransition);
            if(nTransitionObjectType == OBJECT_TYPE_TRIGGER || nTransitionObjectType == OBJECT_TYPE_DOOR)
            {
                // if destination target is exists
                object oTransitionTarget = GetTransitionTarget(oTransition);
                object oTransitionTargetArea = GetArea(oTransitionTarget);
                if(GetIsObjectValid(oTransitionTarget) && oArea != oTransitionTargetArea)
                {
                    location lCenter = GetLocation(oTransition);
                    // let's try to find an existing mapnote
                    object oMapNote = GetNearestObjectToLocation(OBJECT_TYPE_WAYPOINT, lCenter);
                    int bFoundedFromTrigger = FALSE;
                    if(nTransitionObjectType == OBJECT_TYPE_TRIGGER)
                    {
                        object oNearestWaypoint = area_GetWayPointFromNextSideTrigger(oTransition, oTransitionTarget);
                        if(GetIsObjectValid(oMapNote))
                        {
                            oMapNote = oNearestWaypoint;
                            bFoundedFromTrigger = TRUE;
                        }
                    }
                    string sTransitionTargetAreaName = GetName(oTransitionTargetArea);

                    // override not correct mapnote
                    if(GetIsObjectValid(oMapNote) && GetDistanceBetweenLocations(lCenter, GetLocation(oMapNote)) <= 5.0 ||
                       bFoundedFromTrigger)
                    {
                        string sMapnoteText = NWNX_Object_GetMapNote(oMapNote);
                        if(FindSubString(GetStringLowerCase(sTransitionTargetAreaName), GetStringLowerCase(sMapnoteText)) == -1)
                        {
                            sLogMessage += "[MAPNOTE INFO] mapnote with name [" + sMapnoteText + "] != [" +
                                           sTransitionTargetAreaName + "] in Area [" + sAreaName + "]\n";
                        }
                    }
                    else
                    {
                        sLogMessage += "[MAPNOTE INFO] need waypoint in Area ["+ sAreaName + "] with name [" +
                                       sTransitionTargetAreaName + "]\n";
                    }
                }
            }
            oTransition = GetNextObjectInArea(oArea);
        }
        oArea = GetNextArea();
    }
    WriteTimestampedLogEntry(sLogMessage);
}

void area_CreateMapNote(location lCenter, string sMapNoteText)
{
    object oMapNote = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_mapnote001", lCenter, FALSE, "auto_mapnote");
    NWNX_Object_SetMapNote(oMapNote, sMapNoteText);
    SetMapPinEnabled(oMapNote, TRUE);
}

object area_GetWayPointFromNextSideTrigger(object oTrigger, object oTargetWaypoint)
{
    object oNextSideTrigger = GetNearestObject(OBJECT_TYPE_TRIGGER, oTargetWaypoint);
    object oResult = GetTransitionTarget(oNextSideTrigger);
    if(GetArea(oTrigger) == GetArea(oResult))
        return oResult;
    else
        return OBJECT_INVALID;
}

int area_GetWaypontPositionNearTrigger(object oWaypoint, object oTrigger)
{
    vector vPosition = GetPositionFromLocation(GetLocation(oWaypoint));
    if(NWNX_Object_GetPositionIsInTrigger(oTrigger, Vector(vPosition.x + 1.5, vPosition.y, vPosition.z))    ||
       NWNX_Object_GetPositionIsInTrigger(oTrigger, Vector(vPosition.x - 1.5, vPosition.y, vPosition.z))   ||
       NWNX_Object_GetPositionIsInTrigger(oTrigger, Vector(vPosition.x, vPosition.y + 1.5, vPosition.z))  ||
       NWNX_Object_GetPositionIsInTrigger(oTrigger, Vector(vPosition.x, vPosition.y - 1.5, vPosition.z)))
        return TRUE;
    return FALSE;
}


/*
location area_FindPolygonCenter(object oTransition)
{
    location lResult;
    string sGeometryString = NWNX_Object_GetTriggerGeometry(oTransition);
    struct sStringTokenizer stCoordinatesTok = GetStringTokenizer(sGeometryString, "{");
    float x = 0.0;
    float y = 0.0;
    int nVertexNumber = 0;
    string sVector;
    while(HasMoreTokens(stCoordinatesTok))
    {
        stCoordinatesTok = AdvanceToNextToken(stCoordinatesTok);
        sVector = GetNextToken(stCoordinatesTok);
        x += StringToFloat(GetTokenByPosition(sVector, ",", 0));
        y += StringToFloat(GetTokenByPosition(sVector, ",", 1));
        nVertexNumber++;
    }
    x /= nVertexNumber;
    y /= nVertexNumber;
    lResult = Location(GetArea(oTransition), Vector(x, y, 0.0), 0.0);
    return lResult;
}

*/


/*
void area_GenerateMapNotes(object oArea)
{
    if(GetLocalInt(oArea, "AREA_MAP_PINS_IS_SET"))
        return;
    object oTransitionObject = GetFirstObjectInArea(oArea);
    string sAreaName = GetName(oArea);
    // for all valid triggers
    while(GetIsObjectValid(oTransitionObject))
    {
        if(GetObjectType(oTransitionObject) == OBJECT_TYPE_TRIGGER ||GetObjectType(oTransitionObject) == OBJECT_TYPE_DOOR)
        {
            // if destination target is exists
            object oTransitionObjectTarget = GetTransitionTarget(oTransitionObject);
            if(GetIsObjectValid(oTransitionObjectTarget))
            {
                // find trigger or door based on destination target
                object oCommunicatedTransitionObject;
                if(GetObjectType(oTransitionObject) == OBJECT_TYPE_DOOR && GetObjectType(oTransitionObjectTarget) == OBJECT_TYPE_DOOR)
                    oCommunicatedTransitionObject = oTransitionObjectTarget;
                else if(GetObjectType(oTransitionObject) == OBJECT_TYPE_DOOR && GetObjectType(oTransitionObjectTarget) == OBJECT_TYPE_WAYPOINT)
                    oCommunicatedTransitionObject = GetNearestObject(OBJECT_TYPE_DOOR, oTransitionObjectTarget);
                else
                    oCommunicatedTransitionObject = GetNearestObject(OBJECT_TYPE_TRIGGER, oTransitionObjectTarget);

                if(GetIsObjectValid(oCommunicatedTransitionObject))
                {
                    string sCommunicatedAreaName = GetName(GetArea(oCommunicatedTransitionObject));
                    // get destination target of trigger or door
                    object oCommunicatedTransitionTarget = GetTransitionTarget(oCommunicatedTransitionObject);
                    if(GetIsObjectValid(oCommunicatedTransitionTarget))
                    {
                        DelayCommand(1.0, area_SetMapNote(oCommunicatedTransitionTarget, sCommunicatedAreaName));
                    }
                }
            }
        }
        oTransitionObject = GetNextObjectInArea(oArea);
    }
    // ставим локалку чтобы для каждой локи обработка была только 1 раз
    SetLocalInt(oArea, "AREA_MAP_PINS_IS_SET", TRUE);
}

void area_SetMapNote(object oMapNote, string sMapNoteText)
{
    if(GetObjectType(oMapNote) == OBJECT_TYPE_DOOR)
    {
        // seems no waypoint for mapnote object,=> create one!
        location lLoc = GetLocation(oMapNote);
        oMapNote = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_mapnote001", lLoc, FALSE, "auto_mapnote");
    }
    // set destination area name as mapnote
    NWNX_Object_SetMapNote(oMapNote, sMapNoteText);
    SetMapPinEnabled(oMapNote, TRUE);
}
*/

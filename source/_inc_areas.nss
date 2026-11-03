#include "nwnx_area"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

const string AREA_TESTROOM_RESREF = "_loc_testarea";

const string AREA_FLAG_NO_DEATH                  = "NODEATH";
const string AREA_FLAG_NO_TELEPORT               = "NOTP";
const string AREA_FLAG_NO_GATE                   = "NOGATE";
const string AREA_FLAG_NO_ANCHOR                 = "NOANCHOR";
const string AREA_FLAG_INSTANCE_BOSS             = "AREA_FLAG_INSTANCE_BOSS";
const string AREA_FLAG_INSTANCE_BOSS_KILLED      = "AREA_FLAG_INSTANCE_BOSS_KILLED";
const string AREA_FLAG_DESTROY_ITEMS_AFTER_DROP  = "DESTROY_ITEMS_AFTER_DROP";
const string AREA_FLAG_PLAYERS_COUNT_WITH_DMS    = "AREA_FLAG_PLAYERS_COUNT_WITH_DMS";
const string AREA_FLAG_PLAYERS_COUNT_WITHOUT_DMS = "AREA_FLAG_PLAYERS_COUNT_WITHOUT_DMS";

//
int GetAreaFlag(object oArea, string sFlag);

//
void SetAreaFlag(object oArea, string sFlag, int iValue = TRUE);

// return number of player in Area, with or without DMs
int areas_GetNumberOfPlayersInArea(object oArea, int bWithDMs = TRUE);

//
int GetIsWalkableLocation(location lLoc);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int GetAreaFlag(object oArea, string sFlag)
{
    return GetLocalInt(oArea, sFlag);
}

void SetAreaFlag(object oArea, string sFlag, int iValue = TRUE)
{
    SetLocalInt(oArea, sFlag, iValue);
}

int areas_GetNumberOfPlayersInArea(object oArea, int bWithDMs = TRUE)
{
    int nCountWithDMs = GetLocalInt(oArea, AREA_FLAG_PLAYERS_COUNT_WITH_DMS);
    int nCountWithoutDMs = GetLocalInt(oArea, AREA_FLAG_PLAYERS_COUNT_WITHOUT_DMS);
    // if locals is set return values
    if(bWithDMs && nCountWithDMs > 0)
        return nCountWithDMs - 1;
    else if(nCountWithoutDMs > 0)
        return nCountWithoutDMs - 1;
    // else calculate and cash them
    int nPlayers = NWNX_Area_GetNumberOfPlayersInArea(oArea);
    // calculate dms
    int nDMs = 0;
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        if(GetIsDM(oPC) && GetArea(oPC) == oArea)
            nDMs++;
        oPC = GetNextPC();
    }
    // cash values to oArea
    SetLocalInt(oArea, AREA_FLAG_PLAYERS_COUNT_WITH_DMS, nPlayers + 1);
    SetLocalInt(oArea, AREA_FLAG_PLAYERS_COUNT_WITHOUT_DMS, nPlayers - nDMs + 1);
    // return values
    if(bWithDMs)
        return nPlayers;
    else
        return nPlayers - nDMs;
}

int GetIsWalkableLocation(location lLoc)
{
    int nMaterial = GetSurfaceMaterial(lLoc);
    return StringToInt(Get2DAString("surfacemat", "Walk", nMaterial));
}


//void main(){}


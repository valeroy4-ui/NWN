#include "nwnx_events"
#include "nwnx_creature"

const int SURFACE_MATERIAL_WATER    = 6;
const int SURFACE_MATERIAL_PUDDLES  = 11;
const int SURFACE_MATERIAL_SWAMP    = 12;
const int SURFACE_MATERIAL_MUD      = 13;

//
int mat_chg_GetIsSurfaceSlow(int nMaterial);

void main()
{
    if (NWNX_Events_GetCurrentEvent() == "NWNX_ON_MATERIALCHANGE_AFTER")
    {
        object oPC = OBJECT_SELF;
        int nMaterial = StringToInt(NWNX_Events_GetEventData("MATERIAL_TYPE"));
        SendMessageToPC(oPC, "surf mat = " + NWNX_Events_GetEventData("MATERIAL_TYPE"));
        if(GetIsPC(oPC) && !GetIsDM(oPC) && mat_chg_GetIsSurfaceSlow(nMaterial))
            NWNX_Creature_SetMovementRate(oPC, NWNX_CREATURE_MOVEMENT_RATE_SLOW);
        else if(GetIsPC(oPC) && !GetIsDM(oPC))
            NWNX_Creature_SetMovementRate(oPC, NWNX_CREATURE_MOVEMENT_RATE_PC);
    }
}

int mat_chg_GetIsSurfaceSlow(int nMaterial)
{
    switch(nMaterial)
    {
        case SURFACE_MATERIAL_WATER:
        case SURFACE_MATERIAL_PUDDLES:
        case SURFACE_MATERIAL_SWAMP:
        case SURFACE_MATERIAL_MUD:
            return TRUE;
    }
    return FALSE;
}

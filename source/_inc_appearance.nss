#include "nwnx_creature"
#include "x0_i0_stringlib"
#include "_inc_generic"

///////////////////////////////////////////////////////////////////
//////////                 Constants                     //////////
///////////////////////////////////////////////////////////////////

const string sAppearanceAreasList = "_loc_appear_room|";

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

//
void appearance_SetAppearanceEventHandlers(object oCreature);

//
void appearance_CreateNPC(location lLoc, int nAppearanceType);

//
void appearance_GenerateNPCsInArea(object oArea);

//
void appearance_Init();

//
int appearance_ApplyAppearanceToPC(object oNPCTemplate, object oPC);

//
void appearance_TryToBuyAppearance(object oPC, object oNPCTemplate, int nCost);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void appearance_SetAppearanceEventHandlers(object oCreature)
{
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "_on_npc_dialogue");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "");
}

void appearance_CreateNPC(location lLoc, int nAppearanceType)
{
    // use default NWN commoner model as template
    object oTemplate = CreateObject(OBJECT_TYPE_CREATURE, "nw_shopkeep", lLoc);
    int nSize =  StringToInt(Get2DAString("appearance", "sizecategory", nAppearanceType));
    string sAppearanceName = Get2DAString("appearance", "label", nAppearanceType);

    DelayCommand(0.5, SetLocalInt(oTemplate, "APPEARANCE_TYPE", nAppearanceType));
    DelayCommand(0.5, SetLocalInt(oTemplate, "APPEARANCE_SIZE", nSize));
    DelayCommand(0.5, SetName(oTemplate, sAppearanceName));
    //DelayCommand(0.5, NWNX_Creature_SetFaction(oTemplate, STANDARD_FACTION_MERCHANT));
    DelayCommand(0.5, SetPlotFlag(oTemplate, TRUE));
    DelayCommand(0.5, NWNX_Creature_SetMovementRate(oTemplate, NWNX_CREATURE_MOVEMENT_RATE_IMMOBILE));
    DelayCommand(0.5, SetCreatureAppearanceType(oTemplate, nAppearanceType));
    DelayCommand(0.5, appearance_SetAppearanceEventHandlers(oTemplate));
}

void appearance_GenerateNPCsInArea(object oArea)
{
    object oWaypoint = GetFirstObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
    while (GetIsObjectValid(oWaypoint))
    {
        if (GetLocalInt(oWaypoint, "APPEARANCE_TEMPLATE"))
            DelayCommand(1.0, appearance_CreateNPC(GetLocation(oWaypoint), StringToInt(GetTag(oWaypoint))));
        oWaypoint = GetNextObjectInArea(oArea, OBJECT_TYPE_WAYPOINT);
    }
}

void appearance_Init()
{
    struct sStringTokenizer stAreasTok = GetStringTokenizer(sAppearanceAreasList, "|");
    string sAreaTag;
    object oArea;
    while(HasMoreTokens(stAreasTok))
    {
        stAreasTok = AdvanceToNextToken(stAreasTok);
        sAreaTag = GetNextToken(stAreasTok);
        oArea = GetObjectByTag(sAreaTag);
        if(GetIsObjectValid(oArea))
            appearance_GenerateNPCsInArea(oArea);
        else
            WriteLog("generic_CreateAppearanceNPCs(): Invalid Area with tag '" + sAreaTag + "', skipping...", LOG_LEVEL_ERROR);
    }
}

int appearance_ApplyAppearanceToPC(object oNPCTemplate, object oPC)
{
    int iNPCAppearanceType = GetLocalInt(oNPCTemplate, "APPEARANCE_TYPE");
    int iNPCSize = GetLocalInt(oNPCTemplate, "APPEARANCE_SIZE");
    int iPCSize = GetCreatureSize(oPC) - (GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oPC) >= 30 ? 1 : 0);

    if (GetAppearanceType(oPC) != iNPCAppearanceType)
    {
        if (iNPCSize == iPCSize)
        {
            SetCreatureAppearanceType(oPC, iNPCAppearanceType);
            AssignCommand(oPC, DelayCommand(1.0, NWNX_Creature_SetMovementRate(OBJECT_SELF, NWNX_CREATURE_MOVEMENT_RATE_PC)));
            return TRUE;
        }
        else
            SendColorMessageToPC(oPC, "Your current size must be equal appearance size you want.", TXT_COLOR_RED);
    }
    else
        SendColorMessageToPC(oPC, "You can not purchase appearance you already have.", TXT_COLOR_RED);

    return FALSE;
}

void appearance_TryToBuyAppearance(object oPC, object oNPCTemplate, int nCost)
{
    string sAccount = GetPCPlayerName(oPC);
    int nSoulStones = generic_GetSoulStones(sAccount);
    if (nSoulStones - nCost >= 0)
    {
        if (appearance_ApplyAppearanceToPC(oNPCTemplate, oPC))
        {
            generic_ChangeSoulStonesAmount(oPC, -nCost);
            SendColorMessageToPC(oPC, "You successfully purchased new appearance.", TXT_COLOR_GREEN_L);
        }
    }
    else
        SendColorMessageToPC(oPC, "Not enough Soul Stones.", TXT_COLOR_RED);
}

//void main() {}

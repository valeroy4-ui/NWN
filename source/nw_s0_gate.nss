#include "x2_inc_spellhook"
#include "_inc_areas"
#include "_inc_factions"
#include "nw_inc_gff"
#include "_inc_spells"

const int PORTAL_APPEARANCE_INSTANCE_KEY     = 4308;
const int PORTAL_APPEARANCE_DIMENSION_DOOR   = 4309;
const int PORTAL_APPEARANCE_STARGATE         = 2466;

// creates artifact's enter/exit doors portal
void CreatePortals(string sPortalTag, location lLoc, location lDest, int nAppearance);

// create and destroy exit for city stargate
void CreateAndDestroyStargateExit(object oCaster, object oStargate, location lDestionation);

void main()
{

    if (!X2PreSpellCastCode())
        return;

    // Declare major variables
    spellsDeclareMajorVariables();

    string sStarGateUUID = GetLocalString(spell.Item, "STARGATE_UUID");

    string VAR_ANCHOR;
    if(sStarGateUUID != "")
        VAR_ANCHOR = "ANCHOR_UUID_" + sStarGateUUID;
    else if(GetIsObjectValid(spell.Item))
        VAR_ANCHOR = "ANCHOR_ID_" + IntToString(GetLocalInt(spell.Item, "ID")) + "_UUID_" + GetObjectUUID(spell.Item);
    else
        VAR_ANCHOR = "ANCHOR_UUID_" + GetObjectUUID(spell.Caster);

    object oArea = GetArea(spell.Caster);
    if(GetAreaFlag(oArea, AREA_FLAG_NO_TELEPORT) || GetAreaFlag(oArea, AREA_FLAG_NO_GATE))
    {
        SendColorMessageToPC(spell.Caster, "This spell is not allowed in this area.", TXT_COLOR_WHITE);
        return;
    }

    int bWaypointExit = GetObjectType(spell.Item) == OBJECT_TYPE_WAYPOINT ? TRUE : FALSE;
    location lDest;
    if(bWaypointExit)
        lDest = GetLocation(spell.Item);
    else if(sStarGateUUID != "")
        lDest = GetLocalLocation(spell.Item, VAR_ANCHOR);
    else if(!GetIsObjectValid(spell.Item))
        lDest = GetLocalLocation(spell.Caster, VAR_ANCHOR);
    else
        lDest = GetLocalLocation(GetModule(), VAR_ANCHOR);

    //object oCastSource = bWaypointExit ? GetLocalObject(spell.Item, "STARGATE_ENTER") : GetIsObjectValid(spell.Item) ? spell.Item : spell.Caster;
    object oCastSource = GetIsObjectValid(spell.Item) ? spell.Item : spell.Caster;
    string sPortalTag = "DIMDOOR_" + ObjectToString(oCastSource);

    switch(spell.Id)
    {
        case SPELL_GATE:
        {
            // sanity checks
            if(GetIsInCombat(spell.Caster))
            {
                FloatingColorTextStringOnCreature("You cannot concentrate for this action during combat.", TXT_COLOR_WHITE, spell.Caster);
                return;
            }
            if(!bWaypointExit && !GetIsObjectValid(GetAreaFromLocation(lDest)))
            {
                SendColorMessageToPC(spell.Caster, "Use the Anchor first.", TXT_COLOR_WHITE);
                return;
            }
            if(GetLocalInt(GetModule(), sPortalTag))
            {
                spells_ClosePortals(sPortalTag, 0.0);
            }

            // open portal
            if(bWaypointExit && GetLocalInt(spell.Item, "WAYPOYNT_EXIT_TYPE") == 1 /* buffzone */) // buffzone portal
            {
                object oStargateEnter = GetLocalObject(spell.Item, "STARGATE_ENTER");
                int nStarGateFaction = players_GetFaction(oStargateEnter);
                object oBuffZoneArea = GetLocalObject(players_GetFactionSystemNPC(nStarGateFaction), BUFFZONE_AREA_OBJECT);
                int i;
                for(i = 1; i<= 3; i++)
                {
                    object oFactionStargate = players_GetFactionStargate(nStarGateFaction, i);
                    if(oFactionStargate == oStargateEnter)
                        continue;
                    if(GetArea(GetLocalObject(oFactionStargate, "STARGATE_EXIT")) == oBuffZoneArea)
                    {
                        SendColorMessageToPC(spell.Caster, "Multiple portals to Buffzone are not allowed.", TXT_COLOR_WHITE);
                        return;
                    }
                }
                AssignCommand(GetModule(), DelayCommand(0.0, CreateAndDestroyStargateExit(spell.Caster, oStargateEnter, lDest)));
                ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(PRCVFX_DUR_CHILL_SHIELD), GetLocation(oStargateEnter), 2.2);
                ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(PRCVFX_DUR_CHILL_SHIELD), lDest, 2.2);
            }
            else if(bWaypointExit && GetLocalInt(spell.Item, "WAYPOYNT_EXIT_TYPE") == 2 /* instance */) // instance portals
            {
                location lLoc = Location(GetArea(spell.Caster), GetPositionFromLocation(spell.Loc),
                                         GetFacing(spell.Caster) + 180.0);
                ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(PRCVFX_DUR_SHADOW_BODY), lDest, 2.2);
                AssignCommand(GetModule(), DelayCommand(2.2, CreatePortals(sPortalTag, lLoc, lDest, PORTAL_APPEARANCE_INSTANCE_KEY)));
                AssignCommand(GetModule(), DelayCommand(2.3, spells_ClosePortals(sPortalTag, DURATION_INSTANCE_KEY)));
                //AssignCommand(GetModule(), DelayCommand(2.3, spells_ClosePortals(sPortalTag, 60.0))); // test
            }
            // create stargate exit
            else if(sStarGateUUID != "" && GetObjectType(spell.Item) == OBJECT_TYPE_PLACEABLE /* sanity check */ &&
               factions_TryToActivateStargate(spell.Caster, spell.Item, CORMYREAN_STARGATE_COST))
            {

                AssignCommand(GetModule(), DelayCommand(0.0, CreateAndDestroyStargateExit(spell.Caster, spell.Item, lDest)));
                ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(PRCVFX_DUR_CHILL_SHIELD), GetLocation(spell.Item), 2.2);
                ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(PRCVFX_DUR_CHILL_SHIELD), lDest, 2.2);
            }
            // create standart 2 enter/exit doors
            else
            {
                location lLoc = Location(GetArea(spell.Caster), GetPositionFromLocation(spell.Loc),
                                         GetFacing(spell.Caster) + 180.0);
                ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(PRCVFX_DUR_SHADOW_BODY), lDest, 2.2);
                AssignCommand(GetModule(), DelayCommand(2.2, CreatePortals(sPortalTag, lLoc, lDest, PORTAL_APPEARANCE_DIMENSION_DOOR)));
                AssignCommand(GetModule(), DelayCommand(2.3, spells_ClosePortals(sPortalTag, DURATION_DIMENSION_DOOR)));
            }
            break;
        }
        case SPELL_CL_GATE_ANCHOR:
        {
            if(GetAreaFlag(oArea, AREA_FLAG_NO_ANCHOR))
            {
                SendColorMessageToPC(spell.Caster, "Anchor is not allowed in this place.", TXT_COLOR_WHITE);
                return;
            }
            if(sStarGateUUID != "")
            {
                object oStargate = GetObjectByUUID(sStarGateUUID);
                object oAnchor = GetLocalObject(oStargate, "ANCHOR_OBJECT");
                if(GetIsObjectValid(oAnchor) && spell.Item != oAnchor || !GetIsObjectValid(oStargate))
                {
                    SendColorMessageToPC(spell.Caster, "Anchor is not relevant.", TXT_COLOR_WHITE);
                    return;
                }
            }
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(PRCVFX_IMP_DIMENSIONANCHOR), GetLocation(spell.Caster));

            if(sStarGateUUID != "") // stargate anchor
                SetLocalLocation(GetObjectByUUID(sStarGateUUID), VAR_ANCHOR, GetLocation(spell.Caster));
            else if(!GetIsObjectValid(spell.Item)) // spellbook anchor
                SetLocalLocation(spell.Caster, VAR_ANCHOR, GetLocation(spell.Caster));
            else // artifact anchor
                SetLocalLocation(GetModule(), VAR_ANCHOR, GetLocation(spell.Caster));

            SendColorMessageToPC(spell.Caster, "Destination has been saved.", TXT_COLOR_WHITE);
            break;
        }
    }
}

void CreatePortals(string sPortalTag, location lLoc, location lDest, int nAppearance)
{
    json jPortal = GffCreateObject(OBJECT_TYPE_PLACEABLE);
    jPortal = GffAddByte(jPortal, "AnimationState", 0);
    jPortal = GffAddDword(jPortal, "Appearance", nAppearance);
    jPortal = GffAddShort(jPortal, "CurrentHP", 100);
    jPortal = GffAddLocString(jPortal, "Description", "Portal.");
    jPortal = GffAddLocString(jPortal, "LocName", "Portal");
    jPortal = GffAddResRef(jPortal, "OnUsed", "_plc_gate_use");
    jPortal = GffAddByte(jPortal, "Plot", 1);
    jPortal = GffAddString(jPortal, "Tag", sPortalTag);
    jPortal = GffAddResRef(jPortal, "TemplateResRef", "plc_dimdoor");
    jPortal = GffAddByte(jPortal, "Useable", 1);
    object oPortalEnter = JsonToObject(jPortal, lLoc);
    object oPortalExit  = JsonToObject(jPortal, lDest);
    SetLocalInt(oPortalEnter, "VAR_PORTAL_ENTER", TRUE);
    SetLocalInt(oPortalExit,  "VAR_PORTAL_EXIT",  TRUE);
    SetLocalInt(GetModule(), sPortalTag, TRUE);
}

void CreateAndDestroyStargateExit(object oCaster, object oStargate, location lDestionation)
{
    json jStargateExit = GffCreateObject(OBJECT_TYPE_PLACEABLE);
    jStargateExit = GffAddByte(jStargateExit, "AnimationState", 4 /* value from gff editor, not found in constants */);
    jStargateExit = GffAddShort(jStargateExit, "CurrentHP", 100);
    jStargateExit = GffAddLocString(jStargateExit, "Description", "Stargate portal.");
    jStargateExit = GffAddDword(jStargateExit, "Appearance", PORTAL_APPEARANCE_STARGATE);
    jStargateExit = GffAddLocString(jStargateExit, "LocName", GetName(oStargate) + " Exit");
    jStargateExit = GffAddResRef(jStargateExit, "OnUsed", "_plc_gate_use");
    jStargateExit = GffAddByte(jStargateExit, "Plot", 1);
    jStargateExit = GffAddString(jStargateExit, "Tag", "plc_stargate");
    jStargateExit = GffAddResRef(jStargateExit, "TemplateResRef", "plc_stargate");
    jStargateExit = GffAddByte(jStargateExit, "Useable", 1);
    object oStargateExit = JsonToObject(jStargateExit, lDestionation);

    SetLocalObject(oStargate, "STARGATE_EXIT", oStargateExit);
    SetLocalObject(oStargateExit, "STARGATE_ENTER", oStargate);

    AssignCommand(oStargate, DelayCommand(1.0, ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE)));
    spells_SetStargateOnUseScript(oStargate, "_plc_gate_use");
    spells_CloseStargate(oStargate, DURATION_DIMENSION_DOOR);
}







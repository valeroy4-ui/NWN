#include "nwnx_creature"
#include "nwnx_object"
#include "_inc_factions"

const int ACTION_TYPE_OPEN_GATE      = 1;
const int ACTION_TYPE_GIVE_ANCHOR    = 2;
const int ACTION_TYPE_OPEN_BUFF_ZONE = 3;

const string CONST_ITEM_ANCHOR = "fl_anchor";

void main()
{
    object oPC = GetPCSpeaker();
    object oStargate = OBJECT_SELF;

    int iActionType = StringToInt(GetScriptParam("ACTION_TYPE"));
    switch(iActionType)
    {
        case ACTION_TYPE_OPEN_GATE:
        {
            NWNX_Creature_DoItemCastSpell(oPC, oPC, LOCATION_INVALID, SPELL_GATE, 40, 0.0, PROJECTILE_PATH_TYPE_DEFAULT,
                                          -1, oStargate);
            break;
        }
        case ACTION_TYPE_GIVE_ANCHOR:
        {
            object oOldAnchor = GetLocalObject(oStargate, "ANCHOR_OBJECT");
            if(GetIsObjectValid(oOldAnchor))
            {
                SendColorMessageToPC(oPC, "Anchor already taken.", TXT_COLOR_WHITE);
                break;
            }
            object oAnchor = CreateItemOnObject(CONST_ITEM_ANCHOR, oPC);
            SetName(oAnchor, GetName(oAnchor) + " (" + GetName(oStargate) + ")");
            string sStargateUUID = GetObjectUUID(oStargate);
            SetLocalString(oAnchor, "STARGATE_UUID", sStargateUUID);
            SetLocalObject(oStargate, "ANCHOR_OBJECT", oAnchor);
            break;
        }
        case ACTION_TYPE_OPEN_BUFF_ZONE:
        {
            int nFaction = players_GetFaction(oPC);
            object oCash = players_GetFactionSystemNPC(nFaction);
            object oBuffZoneArea = GetLocalObject(oCash, BUFFZONE_AREA_OBJECT);
            if(!GetIsObjectValid(oBuffZoneArea))
                factions_CreateFactionBuffzone(nFaction);
            object oStargateWP = GetLocalObject(oCash, BUFFZONE_STARGATE_WAYPOINT);
            SetLocalObject(oStargateWP, "STARGATE_ENTER", oStargate);
            NWNX_Creature_DoItemCastSpell(oPC, oPC, LOCATION_INVALID, SPELL_GATE, 40, 0.0, PROJECTILE_PATH_TYPE_DEFAULT,
                                          -1, oStargateWP);
            break;
        }
    }
}


#include "_inc_spells"
//#include "_inc_generic"
#include "nwnx_player"
#include "_inc_death"

void main()
{
    object oPC = GetLastUsedBy();
    object oPlaceable = OBJECT_SELF;

    string sAccount = GetPCPlayerName(oPC);
    int nCurrentAppearence = GetAppearanceType(oPC);
    int nCalculatedAppearence;

    if (GetLocalInt(oPlaceable, "PLACEABLE_TEST_EXPERIENCE"))   // testroom exp lever
    {
        int iXP = StringToInt(Get2DAString("exptable", "XP", 39));
        iXP = (iXP < 1) ? 1 : iXP;
        SetXP(oPC, iXP);
        AssignCommand(oPlaceable, ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
        AssignCommand(oPlaceable, ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
    }
    else if (GetLocalInt(oPlaceable, "PLACEABLE_REST")) // rest lever
    {
        ForceRest(oPC);
        RemoveEffectsAfterDeath(oPC);
        // remove AoE markers
        DestroyALLSpellMarkerPlacebles(oPC);
        // update char effects
        AssignCommand(oPC, DelayCommand(0.5, ExecuteScript("_mod_instant_eff", oPC)));
        // animation
        AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
        AssignCommand(OBJECT_SELF,ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
    }
    // VFX ==>
    else if (GetLocalInt(oPlaceable, "PLACEABLE_VFX_PREVIOUS"))
    {
        int iCurrentStoredVFX = db_GetVFX(sAccount);
        if (iCurrentStoredVFX > 0)
        {
            db_SetVFX(sAccount, iCurrentStoredVFX - 1);
            FloatingTextStringOnCreature("VFX has been decreased by 1. Current value is " + IntToString(iCurrentStoredVFX - 1), oPC, FALSE);
        }

    }
    else if (GetLocalInt(oPlaceable, "PLACEABLE_VFX_NEXT"))
    {
        int iCurrentStoredVFX = db_GetVFX(sAccount);
        if (iCurrentStoredVFX < 8191)
        {
            db_SetVFX(sAccount, iCurrentStoredVFX + 1);
            FloatingTextStringOnCreature("VFX has been increased by 1. Current value is " + IntToString(iCurrentStoredVFX + 1), oPC, FALSE);
        }
    }
    else if (GetLocalInt(oPlaceable, "PLACEABLE_VFX_PLAY"))
    {
        int iCurrentStoredVFX = db_GetVFX(sAccount);
        object oWaypoint = GetNearestObjectByTag("wp_" + GetSubString(GetTag(oPlaceable), 5, 1));
        object oTestChar = GetNearestObjectByTag("cr_" + GetSubString(GetTag(oPlaceable), 5, 1));
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(iCurrentStoredVFX), GetLocation(oWaypoint),6.0);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(iCurrentStoredVFX), oTestChar, 6.0);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(iCurrentStoredVFX), oPC, 6.0);
        FloatingTextStringOnCreature("Current VFX is "+IntToString(iCurrentStoredVFX), oPC, FALSE);
    }
    // VFX <==

    // appearance ==>
    else if (GetLocalInt(oPlaceable, "PLACEABLE_APPEARANCE_PREVIOUS"))
    {
        nCalculatedAppearence = --nCurrentAppearence;
        SetCreatureAppearanceType(oPC, nCalculatedAppearence < 0 ? 6543 : nCalculatedAppearence);
        FloatingTextStringOnCreature("Previous Appearance has been applied, ID = " + IntToString(nCalculatedAppearence), oPC, FALSE);
    }
    else if (GetLocalInt(oPlaceable, "PLACEABLE_APPEARANCE_DEFAULT"))
    {
        SetCreatureAppearanceType(oPC, GetSkinInt(oPC, "DEFAULT_APPEARANCE"));
        FloatingTextStringOnCreature("Current Appearance is " + IntToString(nCurrentAppearence), oPC, FALSE);
        FloatingTextStringOnCreature("Default Appearance has been applied", oPC, FALSE);
    }
    else if (GetLocalInt(oPlaceable, "PLACEABLE_APPEARANCE_NEXT"))
    {
        nCalculatedAppearence = ++nCurrentAppearence;
        SetCreatureAppearanceType(oPC, nCalculatedAppearence > 6543 ? 0 : nCalculatedAppearence);
        FloatingTextStringOnCreature("Next Appearance has been applied, ID = " + IntToString(nCalculatedAppearence), oPC, FALSE);
    }
    // appearance <==
    else if (GetLocalInt(oPlaceable, "PLACEABLE_MAGIC_FORGE"))
    {
        string sPcUUID = GetObjectUUID(oPC);
        object oPersonalMagicForge = GetLocalObject(oPlaceable, sPcUUID);

        if (!GetIsObjectValid(oPersonalMagicForge))
        {
            string MAGIC_FORGE_PLACEABLE_RESREF = "x3_plc_basket";
            location lMagicForgeLocation = GetLocation(GetWaypointByTag("wp_magic_forge"));
            oPersonalMagicForge = CreateObject(OBJECT_TYPE_PLACEABLE, MAGIC_FORGE_PLACEABLE_RESREF, lMagicForgeLocation);
            SetEventScript(oPersonalMagicForge, EVENT_SCRIPT_PLACEABLE_ON_CLOSED, "_on_place_close");
            SetLocalObject(oPlaceable, sPcUUID, oPersonalMagicForge);
            SetLocalObject(oPersonalMagicForge, "PLACEABLE_MAGIC_FORGE", oPlaceable);
            SetLocalInt(oPersonalMagicForge, "PLACEABLE_PERSONAL_MAGIC_FORGE", TRUE);
        }

        NWNX_Player_ForcePlaceableInventoryWindow(oPC, oPersonalMagicForge);
    }
    else if(GetLocalInt(oPlaceable, "CORMYREAN_STARGATE"))
    {
        AssignCommand(oPC, ActionStartConversation(oPlaceable, "dlg_stargate", TRUE, FALSE));
        SetLocalString(oPlaceable, "STARGATE_UUID", GetObjectUUID(oPlaceable));
    }
}

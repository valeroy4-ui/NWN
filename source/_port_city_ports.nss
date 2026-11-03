#include "_inc_citykeeper"

void main()
{
    object oPC = GetLastUsedBy();
    string sTpTag = GetTag(OBJECT_SELF);

    // approach to Castle portal
    if((sTpTag == "ArabApproach2ArabCastle" || sTpTag == "KulgApproach2KulgCastle" ||
        sTpTag == "RenoApproach2RenoCastle" || sTpTag == "DragonApproach2DragonCastle")  &&  GetIsPC(oPC)  &&
                                                                                             !GetIsDM(oPC) &&
                                                                                             GetIsKeeperDestroyed(players_GetFaction(GetArea(oPC))))
    {
        SendColorMessageToPC(oPC, "You can not use this portal now. Wait until City Keeper becomes alive.", TXT_COLOR_RED);
        return;
    }

    object oWP = GetWaypointByTag(sTpTag + "_exit");

    location lDestination = GetLocation(oWP);
    object oArea = GetAreaFromLocation(lDestination);
    vector vPosition = GetPositionFromLocation(lDestination);
    float fOrientation = GetFacingFromLocation(lDestination);

    location lNew = Location(oArea, vPosition, fOrientation);

    if(!GetIsDM(oPC))
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SOUND_BURST_SILENT), GetLocation(oPC));

    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, ActionJumpToLocation(lNew));
    //AssignCommand(oPC, DelayCommand(0.0, ActionJumpToLocation(lNew)));

    if(!GetIsDM(oPC))
        SetLocalLocation(oPC, "sm_location", lDestination);
}


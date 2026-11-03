#include "_inc_generic"

//
location GetTempleLocation(object oPC);

void main()
{
    object oPC = GetEnteringObject();
    if(GetIsDM(oPC)) return;

    // sanity check
    if(GetIsDM(oPC) || !players_GetIsFactionAndAlignmentValid(oPC))
        return;
    if(!players_GetIsFactionEnabled(players_GetFaction(oPC)))
    {
        AssignCommand(oPC, ClearAllActions());
        DelayCommand(0.2, FloatingColorTextStringOnCreature("Faction disabled.", TXT_COLOR_RED, oPC, FALSE));
        return;
    }

    location lTemple = GetTempleLocation(oPC);

    AssignCommand (oPC, ClearAllActions());
    AssignCommand (oPC, ActionJumpToLocation(lTemple));
}

location GetTempleLocation(object oPC)
{
    location lLoc;
    string sWPTag;

    if (GetIsObjectValid(GetItemPossessedBy(oPC, "cyric_temple_item")))     sWPTag = "DST_Tele_PC_Cyric2";
    if (GetIsObjectValid(GetItemPossessedBy(oPC, "helm_temple_item")))      sWPTag = "DST_Tele_PC_Helm";
    if (GetIsObjectValid(GetItemPossessedBy(oPC, "lathander_temple_item"))) sWPTag = "DST_Tele_PC_Lathander";
    if (GetIsObjectValid(GetItemPossessedBy(oPC, "lliira_temple_item")))    sWPTag = "DST_Tele_PC_Lliira2";
    if (GetIsObjectValid(GetItemPossessedBy(oPC, "mask_temple_item")))      sWPTag = "DST_Tele_PC_Mask2";
    if (GetIsObjectValid(GetItemPossessedBy(oPC, "silvanus_temple_item")))  sWPTag = "DST_Tele_PC_Silvanus";

    lLoc = GetLocation(GetWaypointByTag(sWPTag));
    return lLoc;
}


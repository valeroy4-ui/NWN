#include "nwnx_events"
#include "nwnx_item"
#include "_inc_chat"
#include "x0_i0_stringlib"
#include "_inc_divbuffer"
#include "_inc_obelisk"
#include "_inc_players"

string ExamineCreature(object oExamineTarget, object oExaminer);
string ExamineItem(object oExamineTarget, object oExaminer);
string ExamineDoor(object oExamineTarget, object oExaminer);
string ExaminePlaceable(object oExamineTarget, object oExaminer);

void main()
{
    string sEvent = NWNX_Events_GetCurrentEvent();

    if (sEvent == NWNX_ON_EXAMINE_OBJECT_BEFORE)
    {
        object oExaminer = OBJECT_SELF;
        object oExamineTarget = StringToObject(NWNX_Events_GetEventData("EXAMINEE_OBJECT_ID"));

        // original description
        string sOriginalDescription = GetDescription(oExamineTarget, TRUE, FALSE);

        string sOutput;
        int nType = GetObjectType(oExamineTarget);
        switch(nType)
        {
            case OBJECT_TYPE_CREATURE:
                sOutput = ExamineCreature(oExamineTarget, oExaminer);
            break;
            case OBJECT_TYPE_ITEM:
                sOutput = ExamineItem(oExamineTarget, oExaminer);
            break;
            case OBJECT_TYPE_DOOR:
                sOutput = ExamineDoor(oExamineTarget, oExaminer);
            break;
            case OBJECT_TYPE_PLACEABLE:
                sOutput = ExaminePlaceable(oExamineTarget, oExaminer);
            break;
            // not special
            default:
                sOutput = "" ;
            break;
        }
        if (GetIsPC(oExamineTarget))
            SetDescription(oExamineTarget, sOutput);
        else if (sOutput != "")
            SetDescription(oExamineTarget, sOriginalDescription + "\n\n" + sOutput, TRUE);
        else
            SetDescription(oExamineTarget, sOriginalDescription, TRUE);
    }
}

string ExamineCreature(object oExamineTarget, object oExaminer)
{
    string sResult;
    if (GetIsPC(oExamineTarget))
    {
        sResult += "Main class: " + class_GetClassNameById(class_GetDisplayedClassIdForPlayers(oExamineTarget)) + "\n";
        int iPlayerID = players_GetPCPersistentID(oExamineTarget);
        sResult += "Kills: "    + ColorText(IntToString(chat_GetCharacterStatistics(oExamineTarget, FAME_GAIN_TYPE_KILL)), TXT_COLOR_GREEN_L) + " " +
                   "Assists: "  + ColorText(IntToString(chat_GetCharacterStatistics(oExamineTarget,  FAME_GAIN_TYPE_ASSIST)), TXT_COLOR_GREEN_L) + " " +
                   "Fame: "     + ColorText(IntToString(chat_GetAccountFame(oExamineTarget)), TXT_COLOR_GREEN_L);

        string sFavoriteEnemy = chat_GetPlayerFavoriteEnemy(iPlayerID);
        if (sFavoriteEnemy != "")
        {
            string sName = GetTokenByPosition(sFavoriteEnemy, "|", 0);
            int iFactionID = StringToInt(GetTokenByPosition(sFavoriteEnemy, "|", 1));
            string sKills = GetTokenByPosition(sFavoriteEnemy, "|", 2);
            sResult += "\nFavorite victim: " + ColorText(sName, players_GetFactionColor(iFactionID)) + " Kills: " + ColorText(sKills, TXT_COLOR_GREEN_L);
        }
        string sWorstEnemy = chat_GetPlayerWorstEnemy(iPlayerID);
        if (sWorstEnemy != "")
        {
            string sName = GetTokenByPosition(sWorstEnemy, "|", 0);
            int iFactionID = StringToInt(GetTokenByPosition(sWorstEnemy, "|", 1));
            string sDeaths = GetTokenByPosition(sWorstEnemy, "|", 2);
            sResult += "\nWorst enemy: " + ColorText(sName, players_GetFactionColor(iFactionID)) + " Deaths: " + ColorText(sDeaths, TXT_COLOR_GREEN_L);
        }
    }
    return sResult;
}

string ExamineItem(object oExamineTarget, object oExaminer)
{
    string sResult = "";
    string sTag = GetTag(oExamineTarget);

    object oItemPossessor = GetItemPossessor(oExamineTarget);
    int iMinItemLevel = NWNX_Item_GetMinEquipLevel(oExamineTarget);
    int nMinLevelOverride = GetLocalInt(oExamineTarget, "LEVEL");
    if(nMinLevelOverride)
        iMinItemLevel = nMinLevelOverride;

    if(sTag == CONST_LIGHTNING_STONE) // lightning stone
    {
        string VAR_ANCHOR = "ANCHOR_ID_" + IntToString(GetLocalInt(oExamineTarget, "ID")) +
                            "_UUID_" + GetObjectUUID(oExamineTarget);
        object oArea = GetAreaFromLocation(GetLocalLocation(GetModule(), VAR_ANCHOR));

        if (GetIsObjectValid(oArea))
        {
            string sDestAreaName = GetName(oArea);
            if (sDestAreaName != "")
                sResult += ColorText("Area: ", TXT_COLOR_WHITE) + ColorText(sDestAreaName + "\n", TXT_COLOR_GREEN_L);
            else
                sResult += ColorText("Area: ", TXT_COLOR_WHITE) + ColorText("Undefined Area" + "\n", TXT_COLOR_RED);
        }
    }
    else if(sTag == CONST_CORMYR_PED_HEAD)
    {
        int nLevel = GetLocalInt(oExamineTarget, "VICTIM_LEVEL");
        string sName = GetLocalString(oExamineTarget, "VICTIM_NAME");
        sResult += "You cut off the head of your victim, whose name was " + ColorText(sName, TXT_COLOR_RED) + ".\n";
        sResult += "Now you can sell the head at the Temple of Mask and receive " + ColorText(IntToString(nLevel * 1000) + "GP", TXT_COLOR_GREEN_L) + " for it.\n";
    }
    else if(sTag == DIVINE_BUFFER_ITEM_TAG)
    {
        sResult += "Available spells list: " + divbuffer_GetAvailableSpellsString() + "\n";
        sResult += "Available spells limit: " + ColorText(IntToString(divbuffer_GetSpellLimit(oExaminer)) + "\n", TXT_COLOR_GREEN_L);
        sResult += "Saved spells: " + divbuffer_GetSavedSpellsString(oExamineTarget) + "\n";
    }
    if(nMinLevelOverride)
        NWNX_Item_SetMinEquipLevelOverride(oExamineTarget, iMinItemLevel);
    if(GetObjectType(oItemPossessor) == OBJECT_TYPE_STORE || iMinItemLevel <= GetHitDice(oExaminer))
        sResult += "\n" + "Level Required: " + IntToString(iMinItemLevel) + "\n";

    return sResult;
}

string ExamineDoor(object oExamineTarget, object oExaminer)
{
    return "";
}

string ExaminePlaceable(object oExamineTarget, object oExaminer)
{
    // obelisk HP
    if(FindSubString(GetTag(oExamineTarget), OBELISK_PLACEBLE_PREFIX) >= 0)
        return obelisk_Examine(oExamineTarget);
    // keeper HP
    if(FindSubString(GetTag(oExamineTarget), "plc_keeper") >= 0)
        return "Hitpoints: " + ColorText(IntToString(GetKeeperMaxHealth() - GetLocalInt(oExamineTarget, "DAMAGE")), TXT_COLOR_BLUE_L);
    // stargate enter destination
    if(GetResRef(oExamineTarget) == "plc_stargate" && GetTag(oExamineTarget) != "plc_stargate")
    {
        string VAR_ANCHOR = "ANCHOR_UUID_" + GetObjectUUID(oExamineTarget);
        object oArea = GetAreaFromLocation(GetLocalLocation(oExamineTarget, VAR_ANCHOR));
        string sText = "";
        if(GetIsObjectValid(oArea))
            sText += ColorText("Area: ", TXT_COLOR_WHITE) + ColorText(GetName(oArea) + "\n", TXT_COLOR_GREEN_L);
        else
            sText += ColorText("Area: ", TXT_COLOR_WHITE) + ColorText("Undefined Area" + "\n", TXT_COLOR_RED);
        object oAnchor = GetLocalObject(oExamineTarget, "ANCHOR_OBJECT");
        if(GetIsObjectValid(oAnchor))
        {
            object oAnchorOwner = GetItemPossessor(oAnchor);
            string sName = NWNX_Util_StripColors(GetName(oAnchorOwner));
            string sColor = players_GetFactionColor(players_GetFaction(oAnchorOwner));
            sText += ColorText("Anchor: ", TXT_COLOR_WHITE) + ColorText(sName + "\n", sColor);
        }
        return sText;
    }
    return "";

}

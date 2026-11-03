//::///////////////////////////////////////////////
//::  Cormyr ColorText Include
//:: _inc_colortext.nss
//:://////////////////////////////////////////////

#include "x3_inc_string"
#include "nwnx_util"

// returns ASCII color string
string colortext_GetRGB(int nRed = 255, int nGreen = 255, int nBlue = 255);

/////////////////////////==================================================================/////////////////////////////
////////////////////////                          Constants                               /////////////////////////////
///////////////////////==================================================================/////////////////////////////

const string TXT_COLOR_AQUA            = "<cþþ>"; // Aqua
const string TXT_COLOR_GRAY            = "<c°°°>"; // NWN Gray. Used in Log on players enter\leave
const string TXT_COLOR_GRAY_L          = "<c>"; // NWN Light Gray. Used in player list elsewhere reaction
const string TXT_COLOR_WHITE           = "<cððð>"; // NWN White. Used in Talk Channel
const string TXT_COLOR_YELLOW          = "<cþïP>"; // NWN Yellow. Used in Shout Channel
const string TXT_COLOR_YELLOW_T        = "<cþþ>"; // NWN True Yellow. Server standart text
const string TXT_COLOR_RED             = "<cþ>"; // NWN Red.
const string TXT_COLOR_ORANGE          = "<cþh>";   // NWN Orange. Used in Log (Ex. "... killed Goblin")
const string TXT_COLOR_GREEN_L         = "<c þ >";  // NWN Green. Used in Privat channel
const string TXT_COLOR_BLUE_L          = "<c™þþ>"; // NWN Light Blue. Used in player name
const string TXT_COLOR_VIOLET          = "<cþ>"; // NWN Violet. Used in Names in Chat Channel
const string TXT_COLOR_VIOLET_L        = "<cÌwþ>"; // NWN Light Violet. Used in cast-action in Log (Ex. "casting unnkown spell")
const string TXT_COLOR_VIOLET_SL       = "<cÌ™Ì>"; // NWN SuperLight Violet. Used in Object Names, who does cast-action in Log
const string TXT_COLOR_NONE            = "";                              // Default (No color)
const string TXT_COLOR_END             = "</c>";                          // (Color end TAG)
const string TXT_COLOR_DM_BLUE         = "<c þþ>"; // DM channel text

const string TXT_COLOR_BLUE_D          = "<cþ>"; // Dark Blue
const string TXT_COLOR_BLACK           = "<c>";
const string TXT_COLOR_GREEN_D         = "<c#ª#>";  // Dark Green
const string TXT_COLOR_WHITE_T         = "<cþþþ>"; // True White
const string TXT_COLOR_CYAN            = "<c ??>";  // Light Cyan
const string TXT_COLOR_MAGENTA         = "<c? ?>";  // Magenta
const string TXT_COLOR_MALIBU          = "<cfÌþ>"; // NWN. Used in saving throw

// loot colors
const string LOOT_COLOR_BLUE           = "<c33þ>";
const string LOOT_COLOR_GREEN          = "<cþ>";
const string LOOT_COLOR_PURPLE         = "<cþþ>";
const string LOOT_COLOR_RED            = "<cþ>";
const string LOOT_COLOR_ARTIFACT       = "<cæÌ€>";

// faction colors
const string FACTION_COLOR_EMPIRE      = "<c™þþ>";
const string FACTION_COLOR_UNDERDARK   = "<c€€€>";
const string FACTION_COLOR_IRON_THRONE = "<ctVþ>";
const string FACTION_COLOR_DRAGON_CULT = "<c¥‘>";

// custom calculated values
const string TXT_COLOR_SPECIAL_HIT     = "<cþþ>";   // color for devast, vorpal etc

/*
string TXT_COLOR_AQUA            = colortext_GetRGB(1,   254, 254); // Aqua
string TXT_COLOR_GRAY            = colortext_GetRGB(176, 176, 176); // NWN Gray. Used in Log on players enter\leave
string TXT_COLOR_GRAY_L          = colortext_GetRGB(127, 127, 127); // NWN Light Gray. Used in player list elsewhere reaction
string TXT_COLOR_WHITE           = colortext_GetRGB(240, 240, 240); // NWN White. Used in Talk Channel
string TXT_COLOR_YELLOW          = colortext_GetRGB(254, 239, 80);  // NWN Yellow. Used in Shout Channel
string TXT_COLOR_YELLOW_T        = colortext_GetRGB(254, 254, 1);   // NWN True Yellow. Server standart text
string TXT_COLOR_RED             = colortext_GetRGB(254, 1,   1);   // NWN Red.
string TXT_COLOR_ORANGE          = colortext_GetRGB(254, 104, 1);   // NWN Orange. Used in Log (Ex. "... killed Goblin")
string TXT_COLOR_GREEN_L         = colortext_GetRGB(32,  254, 32);  // NWN Green. Used in Privat channel
string TXT_COLOR_BLUE_L          = colortext_GetRGB(153, 254, 254); // NWN Light Blue. Used in player name
string TXT_COLOR_VIOLET          = colortext_GetRGB(143, 127, 254); // NWN Violet. Used in Names in Chat Channel
string TXT_COLOR_VIOLET_L        = colortext_GetRGB(204, 119, 254); // NWN Light Violet. Used in cast-action in Log (Ex. "casting unnkown spell")
string TXT_COLOR_VIOLET_SL       = colortext_GetRGB(204, 153, 204); // NWN SuperLight Violet. Used in Object Names, who does cast-action in Log
string TXT_COLOR_NONE            = "";                              // Default (No color)
string TXT_COLOR_END             = "</c>";                          // (Color end TAG)
string TXT_COLOR_DM_BLUE         = colortext_GetRGB(32,  254, 254); // DM channel text

string TXT_COLOR_BLUE_D          = colortext_GetRGB(1,   1,   254); // Dark Blue
string TXT_COLOR_BLACK           = colortext_GetRGB(0,   0,   0);
string TXT_COLOR_GREEN_D         = colortext_GetRGB(35,  170, 35);  // Dark Green
string TXT_COLOR_WHITE_T         = colortext_GetRGB(254, 254, 254); // True White
string TXT_COLOR_CYAN            = colortext_GetRGB(32,  63,  63);  // Light Cyan
string TXT_COLOR_MAGENTA         = colortext_GetRGB(63,  32,  63);  // Magenta
string TXT_COLOR_MALIBU          = colortext_GetRGB(102, 204, 254); // NWN. Used in saving throw

// loot colors
string LOOT_COLOR_BLUE           = colortext_GetRGB(51,  51,  254);
string LOOT_COLOR_GREEN          = colortext_GetRGB(1,   254, 1);
string LOOT_COLOR_PURPLE         = colortext_GetRGB(254, 1,   254);
string LOOT_COLOR_RED            = colortext_GetRGB(254, 1,   1);
string LOOT_COLOR_ARTIFACT       = colortext_GetRGB(230, 204, 128);

// faction colors
string FACTION_COLOR_EMPIRE      = colortext_GetRGB(153, 254, 254);
string FACTION_COLOR_UNDERDARK   = colortext_GetRGB(128, 128, 128);
string FACTION_COLOR_IRON_THRONE = colortext_GetRGB(116, 86,  254);
string FACTION_COLOR_DRAGON_CULT = colortext_GetRGB(0,   165, 145);

// custom calculated values
string TXT_COLOR_SPECIAL_HIT     = colortext_GetRGB(254, 0, 254);   // color for devast, vorpal etc

*/

/////////////////////////==================================================================/////////////////////////////
////////////////////////                          Prototypes                              /////////////////////////////
///////////////////////==================================================================/////////////////////////////

//Return color (sColor) text instead of sText
string ColorText(string sText, string sColor);

//Send a color (sColor) server message (sText) to the oPC.
void SendColorMessageToPC(object oPC, string sText, string sColor);

// Sends colored (sColor) szMessage to all the Dungeon Masters currently on the server.
void SendColorMessageToAllDMs(string sText, string sColor);

// The caller will immediately speak string sText in color sColor
void SpeakColorString(string sText, string sColor, int nTalkVolume=TALKVOLUME_TALK);

// Display colored floaty text above the specified creature.
// The text will also appear in the chat buffer of each player that receives the
// floaty text.
// - sStringToDisplay: String
// - oCreatureToFloatAbove
// - bBroadcastToFaction: If this is TRUE then only creatures in the same faction
//   as oCreatureToFloatAbove
//   will see the floaty text, and only if they are within range (30 metres).
void FloatingColorTextStringOnCreature(string sText, string sColor, object oPC, int bBroadcastToFaction=TRUE);

// Display colored floaty text above the specified creature.
// The text will also appear in the chat buffer of each player that receives the
// floaty text.
// - nStrRefToDisplay: String ref (therefore text is translated)
// - oCreatureToFloatAbove
// - bBroadcastToFaction: If this is TRUE then only creatures in the same faction
//   as oCreatureToFloatAbove
//   will see the floaty text, and only if they are within range (30 metres).
void FloatingColorTextStrRefOnCreature(int nStrRefToDisplay, string sColor, object oPC, int bBroadcastToFaction=TRUE);

/////////////////////////==================================================================/////////////////////////////
////////////////////////                          ColorText                               /////////////////////////////
///////////////////////==================================================================/////////////////////////////
string ColorText(string sText, string sColor)
{
    return sColor + sText + TXT_COLOR_END;
}

/////////////////////////==================================================================/////////////////////////////
////////////////////////                   SendColorMessageToPC                           /////////////////////////////
///////////////////////==================================================================/////////////////////////////
void SendColorMessageToPC(object oPC, string sText, string sColor)
{
    SendMessageToPC(oPC, ColorText(sText, sColor));
}

/////////////////////////==================================================================/////////////////////////////
////////////////////////                  SendColorMessageToAllDMs                        /////////////////////////////
///////////////////////==================================================================/////////////////////////////
void SendColorMessageToAllDMs(string sText, string sColor)
{
    SendMessageToAllDMs(ColorText(sText, sColor));
}

/////////////////////////==================================================================/////////////////////////////
////////////////////////                     SpeakColorString                             /////////////////////////////
///////////////////////==================================================================/////////////////////////////
void SpeakColorString(string sText, string sColor, int nTalkVolume=TALKVOLUME_TALK)
{
    SpeakString(ColorText(sText, sColor), nTalkVolume);
}

/////////////////////////==================================================================/////////////////////////////
////////////////////////                FloatingColorTextStringOnCreature                 /////////////////////////////
///////////////////////==================================================================/////////////////////////////
void FloatingColorTextStringOnCreature(string sText, string sColor, object oPC, int bBroadcastToFaction=TRUE)
{
    FloatingTextStringOnCreature(ColorText(sText, sColor), oPC, bBroadcastToFaction);
}

/////////////////////////==================================================================/////////////////////////////
////////////////////////                FloatingColorTextStrRefOnCreature                 /////////////////////////////
///////////////////////==================================================================/////////////////////////////
void FloatingColorTextStrRefOnCreature(int nStrRefToDisplay, string sColor, object oPC, int bBroadcastToFaction=TRUE)
{
    string sMessage = GetStringByStrRef(nStrRefToDisplay);
    FloatingColorTextStringOnCreature(sMessage, sColor, oPC, bBroadcastToFaction);
}

/////////////////////////==================================================================/////////////////////////////
////////////////////////                SendColorMessageToAllPCs                          /////////////////////////////
///////////////////////==================================================================/////////////////////////////
void SendColorMessageToAllPCs(string sText, string sColor)
{
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        SendColorMessageToPC(oPC, sText, sColor);
        oPC = GetNextPC();
    }
}

/////////////////////////==================================================================/////////////////////////////
////////////////////////                TestColorPalette                                  /////////////////////////////
///////////////////////==================================================================/////////////////////////////
void TestColors()
{
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        SendColorMessageToPC(oPC, "TXT_COLOR_AQUA", TXT_COLOR_AQUA);
        SendColorMessageToPC(oPC, "TXT_COLOR_GRAY", TXT_COLOR_GRAY);
        SendColorMessageToPC(oPC, "TXT_COLOR_WHITE", TXT_COLOR_WHITE);
        SendColorMessageToPC(oPC, "TXT_COLOR_YELLOW", TXT_COLOR_YELLOW);
        SendColorMessageToPC(oPC, "TXT_COLOR_YELLOW_T", TXT_COLOR_YELLOW_T);
        SendColorMessageToPC(oPC, "TXT_COLOR_RED", TXT_COLOR_RED);
        SendColorMessageToPC(oPC, "TXT_COLOR_ORANGE", TXT_COLOR_ORANGE);
        SendColorMessageToPC(oPC, "TXT_COLOR_GREEN_L", TXT_COLOR_GREEN_L);
        SendColorMessageToPC(oPC, "TXT_COLOR_BLUE_L", TXT_COLOR_BLUE_L);
        SendColorMessageToPC(oPC, "TXT_COLOR_VIOLET", TXT_COLOR_VIOLET);
        SendColorMessageToPC(oPC, "TXT_COLOR_VIOLET_L", TXT_COLOR_VIOLET_L);
        SendColorMessageToPC(oPC, "TXT_COLOR_VIOLET_SL", TXT_COLOR_VIOLET_SL);
        SendColorMessageToPC(oPC, "TXT_COLOR_DM_BLUE", TXT_COLOR_DM_BLUE);
        SendColorMessageToPC(oPC, "TXT_COLOR_BLUE_D", TXT_COLOR_BLUE_D);
        SendColorMessageToPC(oPC, "TXT_COLOR_GREEN_D", TXT_COLOR_GREEN_D);
        SendColorMessageToPC(oPC, "TXT_COLOR_WHITE_T", TXT_COLOR_WHITE_T);
        SendColorMessageToPC(oPC, "TXT_COLOR_CYAN", TXT_COLOR_CYAN);
        SendColorMessageToPC(oPC, "TXT_COLOR_MAGENTA", TXT_COLOR_MAGENTA);
        SendColorMessageToPC(oPC, "TXT_COLOR_MALIBU", TXT_COLOR_MALIBU);

        SendColorMessageToPC(oPC, "LOOT_COLOR_BLUE", LOOT_COLOR_BLUE);
        SendColorMessageToPC(oPC, "LOOT_COLOR_GREEN", LOOT_COLOR_GREEN);
        SendColorMessageToPC(oPC, "LOOT_COLOR_PURPLE", LOOT_COLOR_PURPLE);
        SendColorMessageToPC(oPC, "LOOT_COLOR_RED", LOOT_COLOR_RED);
        SendColorMessageToPC(oPC, "LOOT_COLOR_ARTIFACT", LOOT_COLOR_ARTIFACT);

        SendColorMessageToPC(oPC, "FACTION_COLOR_EMPIRE", FACTION_COLOR_EMPIRE);
        SendColorMessageToPC(oPC, "FACTION_COLOR_UNDERDARK", FACTION_COLOR_UNDERDARK);
        SendColorMessageToPC(oPC, "FACTION_COLOR_IRON_THRONE", FACTION_COLOR_IRON_THRONE);

        oPC = GetNextPC();
    }
}

/////////////////////////==================================================================/////////////////////////////
////////////////////////                             colortext_GetRGB                               /////////////////////////////
///////////////////////==================================================================/////////////////////////////
string colortext_GetRGB(int nRed = 255, int nGreen = 255, int nBlue = 255)
{
    //string sBuffer = NWNX_Util_GetAsciiTableString();
    string sBuffer = GetLocalString(GetModule(), "ASCII_BUFFER");
    if(sBuffer == "")
    {
        sBuffer = NWNX_Util_GetAsciiTableString();
        SetLocalString(GetModule(), "ASCII_BUFFER", sBuffer);

    }
    // WriteTimestampedLogEntry(NWNX_Util_GetCurrentScriptName());
    if(nRed > 255) nRed = 255;
    if(nGreen > 255) nGreen = 255;
    if(nBlue > 255) nBlue = 255;
    if(nRed < 1) nRed = 1;
    if(nGreen < 1) nGreen = 1;
    if(nBlue < 1) nBlue = 1;
    string sR = GetSubString(sBuffer, nRed, 1);
    string sG = GetSubString(sBuffer, nGreen, 1);
    string sB = GetSubString(sBuffer, nBlue, 1);
    return "<c" + sR + sG + sB + ">";
}

//void main(){}


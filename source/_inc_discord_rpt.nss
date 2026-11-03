#include "_inc_sqlite_time"
#include "nwnx_util"
#include "nwnx_webhook_rch"
#include "_inc_constants"
#include "nwnx_httpclient"

///////////////////////////////////////////////////////////////////
//////////                  Constants                    //////////
///////////////////////////////////////////////////////////////////

const string WEBHOOK_DISCORD_HOST = "discordapp.com";
const string IMAGES_ADDRESS = "https://portraits.cormyr.ru/portraits/";

const string COLOR_HEX_FACTION_EMPIRE = "#99FEFE";
const string COLOR_HEX_FACTION_UNDERDARK = "#808080";
const string COLOR_HEX_FACTION_IRON_THRONE = "#7456FE";
const string COLOR_HEX_FACTION_DRAGON_CULT = "#00A591";

const string DISCORD_ICON_FACTION_EMPIRE = "<:Empire:1123681835092807681>";
const string DISCORD_ICON_FACTION_UNDERDARK = "<:Underdark:1123681606738120794>";
const string DISCORD_ICON_FACTION_IRON_THRONE = "<:IronThrone:1123681361379721287>";
const string DISCORD_ICON_FACTION_DRAGON_CULT = "<:DragonCult:1123680293795151892>";
const string DISCORD_ICON_CROSSED_SWORDS = ":crossed_swords:";
const string DISCORD_ICON_MAP = ":map:";

const string COLOR_HEX_BOSS_MINI = "#0000FF";
const string COLOR_HEX_BOSS_EPIC = "#00FF00";

const string TELEGRAM_TOPIC_ONLINE = "10";
const string TELEGRAM_TOPIC_SHOUT  = "35";
const string TELEGRAM_TOPIC_BOSSES = "12";
const string TELEGRAM_TOPIC_EVENTS = "14";
const string TELEGRAM_TOPIC_PVP    = "39";

const string TELEGRAM_ICON_FACTION_EMPIRE      = "&#128998";
const string TELEGRAM_ICON_FACTION_UNDERDARK   = "&#129003";
const string TELEGRAM_ICON_FACTION_IRON_THRONE = "&#129002";
const string TELEGRAM_ICON_FACTION_DRAGON_CULT = "&#129001";
const string TELEGRAM_ICON_FACTION_UNKNOWN     = "&#11035";

const string TELEGRAM_ICON_CROSSED_SWORDS      = "&#9876";
const string TELEGRAM_ICON_WORLD_MAP           = "&#128506";

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// return HEX color code for iFaction faction
string GetFactionColorHex(int iFaction);

// get discord icon of faction
string GetFactionIcon(int iFaction);

// report information about player kill to discord pvp channel
void ReportPlayerKillToDiscord(object oKiller, object oDeadman, int iKillerFaction, int iDeadmanFaction, string sAreaName, int iFameForKill, int iPlayersInKillArea);

// report information about boss kill to discord boss channel
void ReportBossKillToDiscord(string sKillerName, string sKillerFaction, string sBossName, string sCategory, string sColorHEX, string sPortraitFilename);

// report about player enter to discord online channel
void ReportPlayerEnterToDiscord(string sPlayerName);

// report about player exit to discord online channel
void ReportPlayerExitToDiscord(string sPlayerName);

// send message to discord events channel
void SendMessageToEventChannelOfDiscord(string sPlayerMessage);

// report message about city attack to discord events channel
void ReportKeeperHasBeenDestroyedToDiscord(string sPlayerName, int nPlayerFaction, string sPlayerMessage);

// send message to cormyrean telegram chat and specific topic,  sParseMode in ("HTML", "Markdown")
void SendMessageViaTelegram(string sMsg, string sTopic, string sParseMode);

// get faction icon(emoji)
string GetTgFactionIcon(int iFaction);

// send message to pvp topic, dublicate of ReportPlayerKillToDiscord for TG
void ReportPlayerKillToTelegram(object oKiller, object oDeadman, int iKillerFaction, int iDeadmanFaction, string sAreaName, int iFameForKill, int iPlayersInKillArea);

//
void SendMessageToTGShoutTopic(object oChater, int nFaction, string sMessage);

//
void ReportBossKillToTelegram(string sKillerName, int nKillerFaction, string sBossName, string sCategory, string sPortraitFilename);

//
void SendMessageToEventChannelOfTelegram(string sPlayerMessage);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////


string GetFactionColorHex(int iFaction)
{
    string sResult;
    switch(iFaction)
    {
        case FACTION_EMPIRE:        sResult = COLOR_HEX_FACTION_EMPIRE; break;
        case FACTION_UNDERDARK:     sResult = COLOR_HEX_FACTION_UNDERDARK; break;
        case FACTION_IRON_THRONE:   sResult = COLOR_HEX_FACTION_IRON_THRONE; break;
        case FACTION_DRAGON_CULT:   sResult = COLOR_HEX_FACTION_DRAGON_CULT; break;
        default:                    sResult = "#FFFFFF"; break;
    }
    return sResult;
}

string GetFactionIcon(int iFaction)
{
    string sResult;
    switch(iFaction)
    {
        case FACTION_EMPIRE:        sResult = DISCORD_ICON_FACTION_EMPIRE; break;
        case FACTION_UNDERDARK:     sResult = DISCORD_ICON_FACTION_UNDERDARK; break;
        case FACTION_IRON_THRONE:   sResult = DISCORD_ICON_FACTION_IRON_THRONE; break;
        case FACTION_DRAGON_CULT:   sResult = DISCORD_ICON_FACTION_DRAGON_CULT; break;
        default:                    sResult = ":grey_question:"; break;
    }
    return sResult;
}

void ReportPlayerKillToDiscord(object oKiller, object oDeadman, int iKillerFaction, int iDeadmanFaction,
                               string sAreaName, int iFameForKill, int iPlayersInKillArea)
{

    string sKillerName = NWNX_Util_StripColors(GetName(oKiller));
    string sKillerIcon = GetFactionIcon(iKillerFaction);
    string sKillerLevel = IntToString(GetHitDice(oKiller));

    string sDeadmanName = NWNX_Util_StripColors(GetName(oDeadman));
    string sDeadmanIcon = GetFactionIcon(iDeadmanFaction);
    string sDeadmanLevel = IntToString(GetHitDice(oDeadman));

    string sText = sKillerIcon+" "+sKillerName+" ("+sKillerLevel+") "
                   +DISCORD_ICON_CROSSED_SWORDS+" " +
                   sDeadmanName + " ("+sDeadmanLevel+") "+sDeadmanIcon;
    if(iFameForKill > 0)
    {
        sText += " **+"+IntToString(iFameForKill)+"** fame for **" + IntToString(iPlayersInKillArea) + "** player(s) ";
    }

    sAreaName = NWNX_Util_StripColors(sAreaName);
    if(GetStringLength(sAreaName) > 0)
    {
        sText += DISCORD_ICON_MAP +" "+ sAreaName;
    }
    NWNX_WebHook_SendWebHookHTTPS(WEBHOOK_DISCORD_HOST, NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_PVP_CHANNEL"), sText);
}

void ReportBossKillToDiscord(string sKillerName, string sKillerFaction, string sBossName, string sCategory, string sColorHEX, string sPortraitFilename)
{
    struct NWNX_WebHook_Message stMessage;
    stMessage.sColor = sColorHEX;
    stMessage.sThumbnailURL = IMAGES_ADDRESS + GetStringLowerCase(sPortraitFilename) + "s.png";

    stMessage.sField1Name = "Killer";
    stMessage.sField1Value = sKillerName;
    stMessage.iField1Inline = TRUE;

    stMessage.sField2Name = "Faction";
    stMessage.sField2Value = sKillerFaction;
    stMessage.iField2Inline = TRUE;

    stMessage.sField3Name = "Category";
    stMessage.sField3Value = sCategory;
    stMessage.iField3Inline = TRUE;

    stMessage.sField4Name = "Boss";
    stMessage.sField4Value = sBossName;
    stMessage.iField4Inline = FALSE;

    stMessage.iTimestamp = SQLite_GetTimeStamp();

    string sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook(WEBHOOK_DISCORD_HOST, NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_BOSS_CHANNEL"), stMessage);
    NWNX_WebHook_SendWebHookHTTPS(WEBHOOK_DISCORD_HOST, NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_BOSS_CHANNEL"), sConstructedMsg);
}

void ReportPlayerEnterToDiscord(string sPlayerName)
{
    int nPlayersOnline = GetLocalInt(GetModule(), "PLAYERS_ONLINE") + 1;
    SetLocalInt(GetModule(), "PLAYERS_ONLINE", nPlayersOnline);

    NWNX_WebHook_SendWebHookHTTPS(WEBHOOK_DISCORD_HOST, NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_ONLINE_CHANNEL"),
                                  sPlayerName + " has joined as a player. Total online: " + IntToString(nPlayersOnline));
}

void ReportPlayerExitToDiscord(string sPlayerName)
{
    int nPlayersOnline = GetLocalInt(GetModule(), "PLAYERS_ONLINE") - 1;
    nPlayersOnline = nPlayersOnline > 0 ? nPlayersOnline : 0;
    SetLocalInt(GetModule(), "PLAYERS_ONLINE", nPlayersOnline);

    NWNX_WebHook_SendWebHookHTTPS(WEBHOOK_DISCORD_HOST, NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_ONLINE_CHANNEL"),
                                  sPlayerName + " has left as a player. Total online: " + IntToString(nPlayersOnline));
}

void ReportPlayerShoutToDiscord(object oPlayer, int nPlayerFaction, string sPlayerMessage)
{
    string sPlayerName = NWNX_Util_StripColors(GetName(oPlayer));
    string sFactionIcon = GetFactionIcon(nPlayerFaction);
    NWNX_WebHook_SendWebHookHTTPS(WEBHOOK_DISCORD_HOST, NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_SHOUT_CHANNEL"),
                                  sFactionIcon + " " + sPlayerName + ": " + sPlayerMessage);
}

void SendMessageToEventChannelOfDiscord(string sPlayerMessage)
{
    NWNX_WebHook_SendWebHookHTTPS(WEBHOOK_DISCORD_HOST, NWNX_Util_GetEnvironmentVariable("NWNX_WEBHOOK_EVENT_CHANNEL"), sPlayerMessage);
}


void SendMessageViaTelegram(string sMsg, string sTopic, string sParseMode)
{
      struct NWNX_HTTPClient_Request sPost;

      json jMessage = JsonObject();
           jMessage = JsonObjectSet(jMessage, "chat_id", JsonString("-1002316642750"));
           jMessage = JsonObjectSet(jMessage, "message_thread_id", JsonString(sTopic));
           jMessage = JsonObjectSet(jMessage, "parse_mode", JsonString(sParseMode));
           jMessage = JsonObjectSet(jMessage, "text", JsonString(sMsg));

      sPost.nRequestMethod = NWNX_HTTPCLIENT_REQUEST_METHOD_POST;
      sPost.sHost = "api.telegram.org";
      sPost.sPath = "/bot8329075530:AAEx8JcTorGfHjBt1rpxn-Ea499OBALb_54/sendMessage";
      sPost.sData = JsonDump(jMessage);
      sPost.nAuthType = NWNX_HTTPCLIENT_AUTH_TYPE_NONE;
      sPost.nContentType = NWNX_HTTPCLIENT_CONTENT_TYPE_JSON;
      //sPost.sHeaders = "Accept-Charset: UTF-8";
      NWNX_HTTPClient_SendRequest(sPost);
}


string GetTgFactionIcon(int iFaction)
{
    string sResult;
    switch(iFaction)
    {
        case FACTION_EMPIRE:        sResult = TELEGRAM_ICON_FACTION_EMPIRE; break;
        case FACTION_UNDERDARK:     sResult = TELEGRAM_ICON_FACTION_UNDERDARK; break;
        case FACTION_IRON_THRONE:   sResult = TELEGRAM_ICON_FACTION_IRON_THRONE; break;
        case FACTION_DRAGON_CULT:   sResult = TELEGRAM_ICON_FACTION_DRAGON_CULT; break;
        default:                    sResult = TELEGRAM_ICON_FACTION_UNKNOWN; break;
    }
    return sResult;
}

void ReportPlayerKillToTelegram(object oKiller, object oDeadman, int iKillerFaction, int iDeadmanFaction, string sAreaName, int iFameForKill, int iPlayersInKillArea)
{

    string sKillerName = NWNX_Util_StripColors(GetName(oKiller));
    string sKillerIcon = GetTgFactionIcon(iKillerFaction);
    string sKillerLevel = IntToString(GetHitDice(oKiller));

    string sDeadmanName = NWNX_Util_StripColors(GetName(oDeadman));
    string sDeadmanIcon = GetTgFactionIcon(iDeadmanFaction);
    string sDeadmanLevel = IntToString(GetHitDice(oDeadman));

    string sText = sKillerIcon + " " + sKillerName + " (" + sKillerLevel + ") "
                   + TELEGRAM_ICON_CROSSED_SWORDS + " " +
                   sDeadmanName + " (" + sDeadmanLevel + ") " + sDeadmanIcon;
    if(iFameForKill > 0)
    {
        sText += " <b>+"+IntToString(iFameForKill)+"</b> fame for <b>" + IntToString(iPlayersInKillArea) + "</b> player(s) ";
    }

    sAreaName = NWNX_Util_StripColors(sAreaName);
    if(GetStringLength(sAreaName) > 0)
    {
        sText += TELEGRAM_ICON_WORLD_MAP +" "+ sAreaName;
    }
    SendMessageViaTelegram(sText, TELEGRAM_TOPIC_PVP, "HTML");
}

void SendMessageToTGShoutTopic(object oChater, int nFaction, string sMessage)
{
    string sPlayerName = NWNX_Util_StripColors(GetName(oChater));
    string sPlayerIcon = GetTgFactionIcon(nFaction);
    string sText = sPlayerIcon + " <b>" + sPlayerName + "</b> : " + sMessage;
    SendMessageViaTelegram(sText, TELEGRAM_TOPIC_SHOUT, "HTML");
}


void ReportBossKillToTelegram(string sKillerName, int nKillerFaction, string sBossName, string sCategory, string sPortraitFilename)
{
    json jMessage = JsonObject();
    jMessage = JsonObjectSet(jMessage, "chat_id", JsonString("-1002316642750"));
    jMessage = JsonObjectSet(jMessage, "message_thread_id", JsonString(TELEGRAM_TOPIC_BOSSES));
    jMessage = JsonObjectSet(jMessage, "photo", JsonString(IMAGES_ADDRESS + GetStringLowerCase(sPortraitFilename) + "m.jpg"));
    jMessage = JsonObjectSet(jMessage, "parse_mode", JsonString("HTML"));
    string sPlayerIcon = GetTgFactionIcon(nKillerFaction);
    string sCaption = "Boss: <b>" + sBossName + "</b>\n" +
                      "Killer: " + sPlayerIcon + " <b>" + sKillerName + "</b>\n" +
                      "Category: <b>" + sCategory + "</b>";
    jMessage = JsonObjectSet(jMessage, "caption", JsonString(sCaption));


    struct NWNX_HTTPClient_Request stTelegramPost;
    stTelegramPost.nRequestMethod = NWNX_HTTPCLIENT_REQUEST_METHOD_POST;
    stTelegramPost.sHost = "api.telegram.org";
    stTelegramPost.sPath = "/bot8329075530:AAEx8JcTorGfHjBt1rpxn-Ea499OBALb_54/sendPhoto";

    stTelegramPost.sData = JsonDump(jMessage);

    stTelegramPost.nAuthType = NWNX_HTTPCLIENT_AUTH_TYPE_NONE;
    stTelegramPost.nContentType = NWNX_HTTPCLIENT_CONTENT_TYPE_JSON;

    NWNX_HTTPClient_SendRequest(stTelegramPost);
}


void SendMessageToEventChannelOfTelegram(string sPlayerMessage)
{
    SendMessageViaTelegram(sPlayerMessage, TELEGRAM_TOPIC_EVENTS, "HTML");
}

#include "nwnx_events"
#include "_inc_db_funcs"


const int MINIMUM_SUPPORTED_VERSION_MAJOR = 8193;
const int MINIMUM_SUPPORTED_VERSION_MINOR = 37;

// returns account linked to cdkey after first connection to server
string BootErrorLinkedAccount(string sPlayerCdKey);

// returns value in (-1, 0, 1);
// -1 = cdkey exists in database but linked to another account;
//  0 = account exists in database but linked to unused in this server key;
//  1 = validation successful or this account/cdkey pair is unused;
int CheckAccountOnConnect(string sPCPlayerName, string sPlayerCdKey);

void main()
{
    string sEvent = NWNX_Events_GetCurrentEvent();

    if (sEvent == "NWNX_ON_CLIENT_CONNECT_BEFORE")
    {
        string sPlayerName = NWNX_Events_GetEventData("PLAYER_NAME");
        string sPlayerCdKey = NWNX_Events_GetEventData("CDKEY");
        string sPlayerIP = NWNX_Events_GetEventData("IP_ADDRESS");

        string sConnectionMessage = "\naccount: '" + sPlayerName + "' with CD Key: '" + sPlayerCdKey + "' and IP: '" + sPlayerIP + "' trying to connect.\n";
        sConnectionMessage += "Key validation result: ";
        int bSuccess = TRUE;

        int iResult = CheckAccountOnConnect(sPlayerName, sPlayerCdKey);

        // if cdkey validation failed and cdkey check enabled then generate log and boot message for player
        if(iResult != 1 && db_GetCdKeyCheckMode())
        {
            string sErrorMessage;
            if      (iResult == -1)
                sConnectionMessage += "Your CD Key is assigned to '" + BootErrorLinkedAccount(sPlayerCdKey) + "' account.\n";
            else if (iResult ==  0)
                sConnectionMessage += "Your CD Key is not correct.\n";
            bSuccess = FALSE;
        }
        else
            sConnectionMessage += "success.\n";

        int nVersionMajor = StringToInt(NWNX_Events_GetEventData("VERSION_MAJOR"));
        int nVersionMinor = StringToInt(NWNX_Events_GetEventData("VERSION_MINOR"));
        //int nPlayerPlatform = StringToInt(NWNX_Events_GetEventData("PLATFORM_ID"));
        if(!(nVersionMajor >= MINIMUM_SUPPORTED_VERSION_MAJOR && nVersionMinor >= MINIMUM_SUPPORTED_VERSION_MINOR))
        {
            sConnectionMessage += "Client validation result: Your have to use >= " +
                                  IntToString(MINIMUM_SUPPORTED_VERSION_MAJOR) + "." +
                                  IntToString(MINIMUM_SUPPORTED_VERSION_MINOR) + " game version.\n";
            bSuccess = FALSE;
        }

        if(bSuccess)
            WriteLog(sConnectionMessage, LOG_LEVEL_INFO);
        else
        {
            NWNX_Events_SkipEvent();
            NWNX_Events_SetEventResult(sConnectionMessage);
            WriteLog(sConnectionMessage, LOG_LEVEL_ERROR);
        }
    }
}

string BootErrorLinkedAccount(string sPlayerCdKey)
{
    string sResult = "";

    string sSQL = "SELECT name FROM players WHERE cdkey = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedString(0, sPlayerCdKey);
    if(NWNX_SQL_ExecutePreparedQuery())
    {
        if (NWNX_SQL_ReadyToReadNextRow())
        {
            NWNX_SQL_ReadNextRow();
            sResult = NWNX_SQL_ReadDataInActiveRow();
        }
    }
    return sResult;
}

int CheckAccountOnConnect(string sPCPlayerName, string sPlayerCdKey)
{
    string sStoredCdKey = "";
    string sStoredName  = "";

    NWNX_SQL_PrepareQuery("SELECT cdkey FROM players WHERE name = ?");
    NWNX_SQL_PreparedString(0, sPCPlayerName);
    NWNX_SQL_ExecutePreparedQuery();
    if (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sStoredCdKey = NWNX_SQL_ReadDataInActiveRow();
    }

    NWNX_SQL_PrepareQuery("SELECT name FROM players WHERE cdkey = ?");
    NWNX_SQL_PreparedString(0, sPlayerCdKey);
    NWNX_SQL_ExecutePreparedQuery();
    if (NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        sStoredName = NWNX_SQL_ReadDataInActiveRow();
    }

    // exact match
    if(sStoredCdKey == sPlayerCdKey && sStoredName == sPCPlayerName)
        return 1;
    // new player or DM cleared CD key for bind new CD Key
    else if (sStoredCdKey == "" && sStoredName == "")
    {
        string sSQL = "INSERT INTO players (name, cdkey) VALUES (?,?) ON DUPLICATE KEY UPDATE cdkey = VALUES(cdkey)";
        NWNX_SQL_PrepareQuery(sSQL);
        NWNX_SQL_PreparedString(0, sPCPlayerName);
        NWNX_SQL_PreparedString(1, sPlayerCdKey);
        NWNX_SQL_ExecutePreparedQuery();
        return 1;
    }
    // CD Key is exists in database but linked to another account
    else if (sStoredName != sPCPlayerName && sStoredName != "")
        return -1;

    // else means CD Key is invalid
    return 0;
}

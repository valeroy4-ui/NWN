#include "nwnx_util"

const int LOG_LEVEL_NOTICE = 1;
const int LOG_LEVEL_INFO = 2;
const int LOG_LEVEL_WARNING = 3;
const int LOG_LEVEL_ERROR = 4;
const int LOG_LEVEL_CHEAT = 5;
const int LOG_LEVEL_DEBUG = 6;

const int LOG_ENABLE_DEBUG = TRUE;

void WriteLog(string str, int iLevel = LOG_LEVEL_NOTICE);

void WriteLog(string str, int iLevel = LOG_LEVEL_NOTICE)
{
    if(iLevel == LOG_LEVEL_DEBUG && LOG_ENABLE_DEBUG == FALSE)
        return;
    string sPrefix;
    switch(iLevel) {
        case LOG_LEVEL_NOTICE: sPrefix = "NOTICE"; break;
        case LOG_LEVEL_INFO: sPrefix = "INFO"; break;
        case LOG_LEVEL_WARNING: sPrefix = "WARNING"; break;
        case LOG_LEVEL_ERROR: sPrefix = "ERROR"; break;
        case LOG_LEVEL_CHEAT: sPrefix = "CHEAT"; break;
        case LOG_LEVEL_DEBUG: sPrefix = "DEBUG"; break;
    }
    str = NWNX_Util_StripColors(str);
    WriteTimestampedLogEntry("["+sPrefix+"] " + str);
}

//void main(){}


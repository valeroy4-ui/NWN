#include "nwnx_creature"
#include "_inc_sqlite_time"
#include "_inc_log"
#include "nwnx_util"
#include "_inc_generic"

const float BASE_DISTANCE_THRESHOLD = 4.519f; // should be ~4.519f for base mov factor(see NWNX_Creature_GetMovementRateFactor)
const float MOVEMENT_RATE_FACTOR_BASE = 1.00f;

const float MEASUREMENT_INTERVAL = 1.0f;

struct NWNX_Util_HighResTimestamp TimestampDiff(struct NWNX_Util_HighResTimestamp start, struct NWNX_Util_HighResTimestamp end)
{
    struct NWNX_Util_HighResTimestamp diff;
    diff.seconds = end.seconds - start.seconds;
    diff.microseconds = end.microseconds - start.microseconds;
    return diff;
}

void main()
{
    object oPC = OBJECT_SELF;
    /*
    if(d100() >= 98 && !GetIsPC(oPC))
    {
        int nDice = Random(25) + 1;
        switch(nDice)
        {
            case 1: SpeakString("Суки вы ебучие, опять за лутом пришли? Идите нахуй стройным шагом!", TALKVOLUME_SHOUT); break;
            case 2: SpeakString("Йоба! Чоткеи поцыки пришли! Ща вам батя будет ебало чистить!", TALKVOLUME_SHOUT); break;
            case 3: SpeakString("Пшли отсюда вон, гадины ебучии!", TALKVOLUME_SHOUT); break;
            case 4: SpeakString("Вы попали на съемки Great Fuckers Anal Drill Team и щас папа вас будет пороть продукты многолетней деградации", TALKVOLUME_SHOUT); break;
            case 5: SpeakString("А по еблу?!", TALKVOLUME_SHOUT); break;
            case 6: SpeakString("Ты кого нахуй послал??", TALKVOLUME_SHOUT); break;
            case 7: SpeakString("Ты далбаеб чтоле епты?", TALKVOLUME_SHOUT); break;
            case 8: SpeakString("Я твою жопу порву блять сука!", TALKVOLUME_SHOUT); break;
            case 9: SpeakString("За боссолутом пришли, голубки? Сосните-ка лучше хуйцов!", TALKVOLUME_SHOUT); break;
            case 10: SpeakString("Пизда вам тухложопые!", TALKVOLUME_SHOUT); break;
            case 11: SpeakString("Сейчас я вам руки-ноги переломаю, уёбки!", TALKVOLUME_SHOUT); break;
            case 12: SpeakString("Тьфу блять, однозначно скажу: среди вас есть пидор! Кто? А вон он, сзади зашел!", TALKVOLUME_SHOUT); break;
            case 13: SpeakString("Ребятушки, ну зачем вы сюда пришли? Сняли бы номер в отеле, развлеклись бы! Пидорасы.", TALKVOLUME_SHOUT); break;
            case 14: SpeakString("Муха-ха, ублюдки!", TALKVOLUME_SHOUT); break;
            case 15: SpeakString("Ну что косоротые, щас вас батя будет ебать, причем не по очереди - а всех сразу!", TALKVOLUME_SHOUT); break;
            case 16: SpeakString("Сейчас я вам руки-ноги переломаю, уёбки!", TALKVOLUME_SHOUT); break;
            case 17: SpeakString("Сейчас буду дно из жопы вышибать, кастер сдохнет первым!", TALKVOLUME_SHOUT); break;
            case 18: SpeakString("Иди сюда, кросафчег!", TALKVOLUME_SHOUT); break;
            case 19: SpeakString("К раздаче готов?", TALKVOLUME_SHOUT); break;
            case 20: SpeakString("Счас кто-то огребет!", TALKVOLUME_SHOUT); break;
            case 21: SpeakString("Ах ты ж ебаный ты нахуй, еще одни пришли!", TALKVOLUME_SHOUT); break;
            case 22: SpeakString("Я тебя ждал, подставляй ебло!", TALKVOLUME_SHOUT); break;
            case 23: SpeakString("Пиздюкиииии!?? Тут уже трое приходило до вас, их на персоналках увезли.... в морг бля!", TALKVOLUME_SHOUT); break;
            case 24: SpeakString("Хватит тыкать в меня этим говном, в очко друг другу потыкайте!", TALKVOLUME_SHOUT); break;
            case 25: SpeakString("Ну что косоротые, щас вас батя будет ебать, причем не по очереди - а всех сразу!", TALKVOLUME_SHOUT); break;
        }

    }
    */
    if(GetLocalInt(oPC, "sm_disable"))
    {
        SendMessageToAllDMs("[DistanceMonitor] stopped on Player: " + GetName(oPC)+ " ("+ GetPCPlayerName(oPC) + ")");
        DeleteLocalInt(oPC, "sm_disable");
        DeleteLocalLocation(oPC, "sm_location");
    }
    else
    {
        location lCurrLoc = GetLocation(oPC);

        //struct NWNX_Time_HighResTimestamp last;
        //last.seconds = GetLocalInt(oPC, "sm_seconds");
        //last.microseconds = GetLocalInt(oPC, "sm_microseconds");
        //struct NWNX_Time_HighResTimestamp now = NWNX_Time_GetHighResTimeStamp();
        //struct NWNX_Time_HighResTimestamp diff = TimestampDiff(last, now);

        //string sDebug = "[DistanceMonitor] Player: " + GetName(oPC)+ " ("+ GetPCPlayerName(oPC) + ")" + "diff " + IntToString(diff.seconds) + "." + IntToString(diff.microseconds);
        //SendMessageToAllDMs(sDebug);

        /*  DEBUG
        object oLeader = GetFactionLeader(oPC);
        if(GetIsObjectValid(oLeader))
        {
            float fDistance = GetDistanceBetweenLocations(GetLocation(oPC), GetLocation(oLeader));
            if (fDistance > 0.0)
                ServerShout("Distance:" + FloatToString(fDistance, 2, 2));
        } */
        float fFactor = GetLocalFloat(oPC, "MOVEMENT_FACTOR");
        if(fFactor <= 0.0)
        {
            fFactor = NWNX_Creature_GetMovementRateFactor(oPC);
            SetLocalFloat(oPC, "MOVEMENT_FACTOR", fFactor);
        }
        if(fFactor >= MOVEMENT_RATE_FACTOR_BASE) // check only players with normal movfactor (without slow effects)
        {
            location lPrevLoc = GetLocalLocation(oPC, "sm_location");
            float fDistance = GetDistanceBetweenLocations(lCurrLoc, lPrevLoc);

            float fDistanceThreshold = BASE_DISTANCE_THRESHOLD * fFactor * MEASUREMENT_INTERVAL;

            //string sDebug = "[DistanceMonitor] debug: " + FloatToString(fDistance, 2, 2) + ". Calculated:" + FloatToString(fDistanceThreshold, 2, 2) + "  Player: " + GetName(oPC)+ " ("+ GetPCPlayerName(oPC) + ")";
            //SendMessageToAllDMs(sDebug);

            if(fDistance >= fDistanceThreshold)
            {
                string sDistance = FloatToString(fDistance, 2, 2);
                string sDistanceThreshold = FloatToString(fDistanceThreshold, 2, 2);
                string sDistanceDiff = FloatToString((fDistance - fDistanceThreshold), 2, 2);
                string sFactor = FloatToString(fFactor,2,2);
                string sArea = GetName(GetArea(OBJECT_SELF));
                string sMsg = "[DistanceMonitor]("+FloatToString(MEASUREMENT_INTERVAL,2,2)+
                                                "s) factor:"+sFactor+
                                                 " real:"+sDistance+
                                                 " calc:" +sDistanceThreshold+
                                                 " diff:" + sDistanceDiff +
                                                 "  player: " + GetName(oPC)+ " ("+ GetPCPlayerName(oPC) + ") " +
                                                 "loc:"+sArea;
                SendMessageToAllDMs(sMsg);
                WriteLog(sMsg, LOG_LEVEL_INFO);
            }
        }
        SetLocalLocation(oPC, "sm_location", lCurrLoc);
        //SetLocalInt(oPC, "sm_seconds", now.seconds);
        //SetLocalInt(oPC, "sm_microseconds", now.microseconds);
        DelayCommand(MEASUREMENT_INTERVAL, ExecuteScript("spdmon_start", oPC));
    }
}

#include "_inc_generic"
#include "_inc_guard_spawn"
#include "_inc_citykeeper"
#include "_inc_discord_rpt"

const string CURRENT_DAMAGE_AMOUNT_VAR = "CURRENT_DAMAGE_AMOUNT";
const int DOOR_DAMAGE_THRESHOLD = KEEPER_MAX_HEALTH;

float fRespawnTime = KEEPER_RESPAWN_TIME;

void main()
{
    object oDoor = OBJECT_SELF;
    object oDamager = GetLastDamager();
    int iDamage = GetTotalDamageDealt();
    if(!GetLocalInt(oDoor, "Destroyed"))
    {
        int iCurHitpoints = GetLocalInt(oDoor, CURRENT_DAMAGE_AMOUNT_VAR);
        // damaged to death, open it!
        if(iCurHitpoints + iDamage >= DOOR_DAMAGE_THRESHOLD)
        {
            /*
            if(GetLocalInt(oDoor, "EntrypointToCity"))
            {
                FloatingTextStringOnCreature("Attack begins. Remember, you have only two hours.", oDamager, TRUE);
                DelayCommand(fRespawnTime, RespawnFactionGuards(GetFaction(oDoor)));
            }*/
            ServerShout(ColorText(GetName(oDoor), TXT_COLOR_WHITE_T) + ColorText(" in area ", TXT_COLOR_ORANGE) +
                        ColorText(GetName(GetArea(oDoor)), TXT_COLOR_WHITE_T) + ColorText(" has been destroyed.", TXT_COLOR_ORANGE));
            SendMessageToEventChannelOfDiscord("**" + GetName(oDoor) + "** in area **" +
                                               GetName(GetArea(oDoor)) + "** has been destroyed.");
            SendMessageToEventChannelOfTelegram("<b>" + GetName(oDoor) + "</b> in area <b>" +
                                               GetName(GetArea(oDoor)) + "</b> has been destroyed.");

            SetLocalInt(oDoor, "Destroyed", TRUE);
            AssignCommand(oDoor, ActionOpenDoor(oDoor));
            DelayCommand(fRespawnTime - 1.0f, DeleteLocalInt(oDoor, "Destroyed"));
            DelayCommand(fRespawnTime, AssignCommand(oDoor, ActionCloseDoor(oDoor)));
            DelayCommand(fRespawnTime, DeleteLocalInt(oDoor, CURRENT_DAMAGE_AMOUNT_VAR));
            // mark destination door as destroyed too.
            object oTransitionDoor = GetTransitionTarget(oDoor);
            if(GetIsObjectValid(oTransitionDoor) && GetObjectType(oTransitionDoor) == OBJECT_TYPE_DOOR)
            {
                SetLocalInt(oTransitionDoor, "Destroyed", TRUE);
                AssignCommand(oTransitionDoor, ActionOpenDoor(oTransitionDoor));
                DelayCommand(fRespawnTime - 1.0f, DeleteLocalInt(oTransitionDoor, "Destroyed"));
                DelayCommand(fRespawnTime, AssignCommand(oTransitionDoor, ActionCloseDoor(oTransitionDoor)));
                DelayCommand(fRespawnTime, DeleteLocalInt(oTransitionDoor, CURRENT_DAMAGE_AMOUNT_VAR));
            }
        }
        SetLocalInt(oDoor, CURRENT_DAMAGE_AMOUNT_VAR, iCurHitpoints + iDamage);
    }
    else
        AssignCommand(oDamager, ClearAllActions());

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oDoor)), oDoor);
}

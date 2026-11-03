#include "nwnx_events"
#include "_inc_players"
#include "_inc_reputation"
#include "nwnx_damage"


void main()
{
    if(NWNX_Events_GetCurrentEvent() == NWNX_ON_INPUT_ATTACK_OBJECT_BEFORE)
    {
        object oAttackTarget    = StringToObject(NWNX_Events_GetEventData("TARGET"));
        int iBypass             = FALSE;

        object oMaster = GetMaster(oAttackTarget);
        if(GetIsObjectValid(oMaster))
            oAttackTarget = oMaster;

        if(GetLocalInt(OBJECT_SELF, "IMGUARD") && players_GetFactionsEqual(OBJECT_SELF, oAttackTarget))
        {
            ClearAllActions();
            if(GetIsPC(oAttackTarget))
                RestoreReputation(oAttackTarget);
            iBypass = TRUE;
        }
        /*
        if(GetPCPlayerName(oAttackTarget) == "ud4ever")
        {
            AssignCommand(OBJECT_SELF, SpeakString("Прости меня, господин! Я буду лизать твое очко ежедневно до конца жизни чтобы искупить свою вину."));
            ActionPlayAnimation(ANIMATION_LOOPING_MEDITATE);

            iBypass  = TRUE;
        }  */
        if(iBypass)
            NWNX_Events_SkipEvent();
    }
}

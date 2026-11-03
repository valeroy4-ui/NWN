#include "nwnx_events"
#include "_inc_sqlite_time"
#include "_inc_spells"
#include "_inc_generic"


void main()
{
    object oPC = OBJECT_SELF;
    string sCurrentEvent = NWNX_Events_GetCurrentEvent();
    if (sCurrentEvent == NWNX_ON_DISARM_BEFORE)
    {
        NWNX_Events_SkipEvent();
        object oDisarmer = StringToObject(NWNX_Events_GetEventData("DISARMER_OBJECT_ID"));
        //ServerShout(GetName(oDisarmer));
        object oWeapon   = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
        //ServerShout(IntToString(SQLite_GetTimeStamp()));
        //ServerShout(IntToString(GetLocalInt(oWeapon, "CORMYR_DISARM_TIMESTAMP")));
        //ServerShout(IntToString(GetLocalInt(oWeapon, "CORMYR_DISARM_DURATION")));
        if (GetIsObjectValid(oWeapon) && SQLite_GetTimeStamp() - GetLocalInt(oPC, "CORMYR_DISARM_TIMESTAMP") <= 1)
        {
            SetLocalInt(oWeapon, "CORMYR_DISARM_TIMESTAMP", SQLite_GetTimeStamp());
            // apply debuff to disarmed PC
            float fDuration       = 12.0;
            if(!GetIsPC(oPC)) fDuration /= 2;
            SetLocalInt(oWeapon, "CORMYR_DISARM_DURATION", FloatToInt(fDuration));
            effect eDisarmPenalty = EffectLinkEffects(EffectAttackDecrease(10), EffectSkillDecrease(SKILL_DISCIPLINE, 5));
            eDisarmPenalty        = EffectLinkEffects(EffectACDecrease(2, AC_DODGE_BONUS), eDisarmPenalty);
            eDisarmPenalty        = EffectLinkEffects(HideEffectIcon(eDisarmPenalty), EffectIcon(EFFECT_ICON_DISARM));
            eDisarmPenalty        = SetEffectSpellId(eDisarmPenalty, SPELL_CORMYR_DISARM);
            DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eDisarmPenalty), oPC, fDuration));
            NWNX_Creature_RunUnequip(oPC, oWeapon);
        }
    }
}

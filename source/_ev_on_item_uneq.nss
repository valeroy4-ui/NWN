#include "nwnx_events"
#include "_inc_colortext"
#include "_inc_psv_bonuses"
#include "_inc_generic"

void main()
{
    string sEvent   = NWNX_Events_GetCurrentEvent();
/*
    if (sEvent=="NWNX_ON_ITEM_UNEQUIP_BEFORE")
    {
    }
*/
    if (sEvent=="NWNX_ON_ITEM_UNEQUIP_AFTER")
    {
        object oPC = OBJECT_SELF;
        //int iPlayerPCPersistentID = GetPCPersistentID(oPC);
        //string sPlayerPCPersistentID = IntToString(iPlayerPCPersistentID);
        object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));

        AddACAmbidex(oPC);
        SetArchmageAncientAC(oPC);
        psv_AdjustCustomSaves(oPC);
        psv_ApplyBonusCriticalRange(oPC);
        AddMonkBonuses(oPC);
        UpdateEqippedInfo(OBJECT_INVALID, oItem);
    }
}

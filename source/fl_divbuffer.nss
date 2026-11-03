#include "_inc_divbuffer"

void main()
{
    object oItem = GetItemActivated();
    object oActivator = GetItemPossessor(oItem);
    object oTarget = GetItemActivatedTarget();

    if(oTarget == oItem)
    {
        object oDivineBuffer = GetLocalObject(oActivator, "DIVINE_BUFFER");
        if(GetIsObjectValid(oDivineBuffer))
        {
            SendColorMessageToPC(oActivator, "Divine buffer save mode off.", TXT_COLOR_GREEN_L);
            DeleteLocalObject(oActivator, "DIVINE_BUFFER");
        }
        else
        {
            SendColorMessageToPC(oActivator, "Divine buffer save mode on.", TXT_COLOR_GREEN_L);
            SetLocalObject(oActivator, "DIVINE_BUFFER", oItem);
            SetLocalString(oItem, "DIVINE_BUFFER_STORED_SPELLS_ARRAY", "");
        }
    }
    else if(oTarget == oActivator)
        divbuffer_CastSpells(oActivator, oItem);

}

//#include "_inc_generic"

void main()
{
    object oPC = GetLastSpeaker();
    object oNPC = OBJECT_SELF;

    if (GetLocalInt(oNPC, "APPEARANCE_TYPE"))
    {
        ActionStartConversation(oPC, "dlg_appearance", TRUE);
    }
    else if(GetLocalInt(oNPC, "NPC_CITY_CASTER"))
    {
        ActionStartConversation(oPC, "dlg_citycaster", TRUE);
    }
    else if(GetLocalInt(oNPC, "NPC_CITY_MAGIC_STORE"))
    {
        ActionStartConversation(oPC, "dlg_tauster", TRUE);
        //ServerShout(IntToString(GetLocalInt(oNPC, "NPC_CITY_MAGIC_STORE")));
    }
    else if(GetLocalInt(oNPC, "NPC_CITY_BANK"))
    {
        ActionStartConversation(oPC, "dlg_bank", TRUE);
    }
    else if(GetLocalInt(oNPC, "NPC_CITY_FACTION_SHOP"))
    {
        ActionStartConversation(oPC, "dlg_fact_shop", TRUE);
    }
    else if(GetLocalInt(oNPC, "NPC_CITY_AMMUNITION_DEALER"))
    {
        ActionStartConversation(oPC, "dlg_weapons", TRUE);
    }
    else if(GetLocalInt(oNPC, "NPC_CITY_CRAFTER"))
    {
        ActionStartConversation(oPC, "dlg_crafter", TRUE);
    }
    else if(GetLocalInt(oNPC, "NPC_CITY_BARMEN"))
    {
        ActionStartConversation(oPC, "dlg_barmen", TRUE);
    }
}

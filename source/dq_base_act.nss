#include "x2_inc_switches"
#include "_inc_teleport"
#include "_inc_runes"
#include "_inc_players"
#include "_inc_bank"

// restores uses for unlim TPs
void activate_RestoreUse(object oItem);

// if character has enough gold return TRUE
int activate_MoneyDependingUse(object oPC, object oItem);

void main()
{
     object oActivator  = GetItemActivator();
     object oItem       = GetItemActivated();
     string sTag        = GetTag(oItem);

     if(FindSubString(sTag, "Tele_PC_") >= 0 && GetBaseItemType(oItem) == BASE_ITEM_POTIONS)
     {
        if(players_IsTestCharacter(oActivator))
            SendMessageToPC(oActivator, "You feel bad. Seems you grew a conscience..");
        else
        {
            if (activate_MoneyDependingUse(oActivator, oItem))
                TeleportPC(oActivator, sTag);
            if (GetPlotFlag(oItem)) // restore use for unlim potions
                activate_RestoreUse(oItem);
        }
        return;
     }
     else if(FindSubString(sTag, "fl_rune_") == 0 && GetBaseItemType(oItem) == BASE_ITEM_MISCSMALL)
     {
        int iRuneType = GetLocalInt(oItem, "RUNE_TYPE");
        int iRune = GetLocalInt(oItem, "RUNE");
        if(iRuneType && iRune && runes_TryToActivateRune(oActivator, iRuneType, iRune))
        {
            DestroyObject(oItem);
        }
        return;
     }
     //ExecuteScript(sTag, oTarget);
     // * Generic Item Script Execution Code
     // * If MODULE_SWITCH_EXECUTE_TAGBASED_SCRIPTS is set to TRUE on the module,
     // * it will execute a script that has the same name as the item's tag
     // * inside this script you can manage scripts for all events by checking against
     // * GetUserDefinedItemEventNumber(). See x2_it_example.nss
     if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS) == TRUE)
     {
        SetUserDefinedItemEventNumber(X2_ITEM_EVENT_ACTIVATE);
        int nRet = ExecuteScriptAndReturnInt(GetUserDefinedItemEventScriptName(oItem), OBJECT_SELF);
        if (nRet == X2_EXECUTE_SCRIPT_END)
           return;
     }

}

void activate_RestoreUse(object oItem)
{
    itemproperty ip =  GetFirstItemProperty(oItem);
    RemoveItemProperty(oItem, ip);
    itemproperty ipa = ItemPropertyCastSpell(IP_CONST_CASTSPELL_UNIQUE_POWER_SELF_ONLY, 1);
    AddItemProperty(DURATION_TYPE_PERMANENT, ipa, oItem);
}

int activate_MoneyDependingUse(object oPC, object oItem)
{
    int bMoneyDependingUse = FALSE;
    int iCost = 0;

    if (GetResRef(oItem) == "fl_tp_arabel_u" || GetResRef(oItem) == "fl_tp_kulg_u" ||
        GetResRef(oItem) == "fl_tp_reno_u"   || GetResRef(oItem) == "fl_tp_cult_u")
    {
        bMoneyDependingUse = TRUE;
        iCost = 7500;
    }
    else if (GetResRef(oItem) == "fl_tp_leader_u")
    {
        bMoneyDependingUse = TRUE;
        iCost = 15000;
    }
    if (bMoneyDependingUse)
    {
        int bUseBankBalance = TRUE;
        int iPcGold = bank_GetAccountBalance(oPC);

        if (iPcGold < iCost)
        {
            iPcGold = GetGold(oPC);
            bUseBankBalance = FALSE;
        }
        if(iPcGold >= iCost)
        {
            if(bUseBankBalance)
                bank_DecrementAccountBalance(oPC, iCost);
            else
                AssignCommand(oPC, TakeGoldFromCreature(iCost, oPC, TRUE));
            return TRUE;
        }
        else
        {
            FloatingColorTextStringOnCreature("Activating this item requires money.", TXT_COLOR_RED, oPC, FALSE);
            return FALSE;
        }
    }
    else
        return TRUE;
}

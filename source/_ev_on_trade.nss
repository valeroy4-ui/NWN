#include "nwnx_events"
#include "nwnx_creature"
#include "nwnx_feedback"
#include "nwnx_util"
#include "_inc_stashes"
#include "_inc_itemprop"
#include "_inc_bank"

void main()
{
    string sEvent = NWNX_Events_GetCurrentEvent();

    object oPC      = OBJECT_SELF;
    object oStore   = StringToObject(NWNX_Events_GetEventData("STORE"));
    object oItem    = StringToObject(NWNX_Events_GetEventData("ITEM"));
    int iItemPrice  = StringToInt(NWNX_Events_GetEventData("PRICE"));
    string sAccount = GetPCPlayerName(oPC);

    if (sEvent == "NWNX_ON_STORE_REQUEST_BUY_BEFORE")
    {
        int bGiveCheatGoldSilently = FALSE;
        if (GetTag(oStore) == STASH_STORE_RESREF) // take item from stash before
        {
            SetLocalInt(oPC, "STASH_GOLD_GIVEN", TRUE);
            bGiveCheatGoldSilently = TRUE;
        }
        else if(GetGold(oPC) < iItemPrice && bank_GetAccountBalance(oPC) > iItemPrice) // cashless buy
        {
            SetLocalInt(oPC, "CASHLESS_GOLD_GIVEN", TRUE);
            bGiveCheatGoldSilently = TRUE;
        }
        if(bGiveCheatGoldSilently)
        {
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_LOST, TRUE, oPC);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_GAINED, TRUE, oPC);
            GiveGoldToCreature(oPC, iItemPrice);
        }
    }
    if (sEvent == "NWNX_ON_STORE_REQUEST_BUY_AFTER")
    {
        int bBuyResult = StringToInt(NWNX_Events_GetEventData("RESULT"));
        int bUnHideGoldFeedbackMessages = FALSE;
        if(GetTag(oStore) == STASH_STORE_RESREF && bBuyResult)
        {
            SetScriptParam(STASH_DISTURB_OBJECT_UUID, GetObjectUUID(oPC));
            ExecuteScript(STASH_DISTURB_SCRIPT, oStore);
            WriteTimestampedLogEntry("[STASH] '" + GetName(oPC) + "' got item '" + NWNX_Util_StripColors(GetName(oItem)) + "' from stash.");
            bUnHideGoldFeedbackMessages = TRUE;
        }
        else if(GetLocalInt(oPC, "STASH_GOLD_GIVEN"))  // theoretically possible
        {
            DelayCommand(0.1, TakeGoldFromCreature(iItemPrice, oPC, TRUE));
            bUnHideGoldFeedbackMessages = TRUE;
        }
        else if(GetLocalInt(oPC, "CASHLESS_GOLD_GIVEN"))
        {
            // A failed buy must return the temporary cash without charging the bank.
            if(bBuyResult) bank_DecrementAccountBalance(oPC, iItemPrice);
            else TakeGoldFromCreature(iItemPrice, oPC, TRUE);
            bUnHideGoldFeedbackMessages = TRUE;
        }
        if(bUnHideGoldFeedbackMessages)
        {
            DelayCommand(0.5, NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_LOST, FALSE, oPC));
            DelayCommand(0.5, NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_GAINED, FALSE, oPC));
        }
        DeleteLocalInt(oPC, "STASH_GOLD_GIVEN");
        DeleteLocalInt(oPC, "CASHLESS_GOLD_GIVEN");
    }
    if (sEvent == "NWNX_ON_STORE_REQUEST_SELL_AFTER")
    {
        int bBuyResult = StringToInt(NWNX_Events_GetEventData("RESULT"));
        if (GetTag(oStore) == STASH_STORE_RESREF && bBuyResult)
        {
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_LOST, TRUE, oPC);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_GAINED, TRUE, oPC);
            DelayCommand(0.1, TakeGoldFromCreature(iItemPrice, oPC, TRUE));
            DelayCommand(0.5, NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_LOST, FALSE, oPC));
            DelayCommand(0.5, NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_GAINED, FALSE, oPC));
            SetScriptParam(STASH_DISTURB_OBJECT_UUID, GetObjectUUID(oPC));
            ExecuteScript(STASH_DISTURB_SCRIPT, oStore);
            WriteTimestampedLogEntry("[STASH] '" + GetName(oPC) + "' put item '" + NWNX_Util_StripColors(GetName(oItem)) + "' to stash.");
        }
        else if(GetTag(oStore) == CONST_CORMYR_MASK_TEMPLE && GetTag(oItem) == CONST_CORMYR_PED_HEAD && bBuyResult)
        {
            int nHeadLevel = GetLocalInt(oItem, "VICTIM_LEVEL");
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_LOST, TRUE, oPC);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_GAINED, TRUE, oPC);
            DelayCommand(0.0, TakeGoldFromCreature(iItemPrice, oPC, TRUE));
            DelayCommand(0.1, NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_LOST, FALSE, oPC));
            DelayCommand(0.1, NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_GOLD_GAINED, FALSE, oPC));
            DelayCommand(0.5, GiveGoldToCreature(oPC, nHeadLevel * 1000));
            DestroyObject(oItem);
        }
    }
}

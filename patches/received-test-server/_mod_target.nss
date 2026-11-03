#include "_inc_chat"

void main()
{
    object oPC = GetLastPlayerToSelectTarget();
    if (GetLocalInt(oPC, "SV257_SELECTING"))
    {
        if (!GetLocalInt(oPC, "TARGET_MODE"))
        {
            SetLocalObject(oPC, "SV257_PICKED_OBJECT", GetTargetingModeSelectedObject());
            SetLocalLocation(oPC, "SV257_PICKED_LOCATION", Location(GetArea(oPC), GetTargetingModeSelectedPosition(), 0.0));
            ExecuteScript("sv257_select", oPC);
            DeleteLocalObject(oPC, "SV257_PICKED_OBJECT");
            DeleteLocalLocation(oPC, "SV257_PICKED_LOCATION");
            return;
        }
        DeleteLocalInt(oPC, "SV257_SELECTING");
    }
    object oTarget = GetTargetingModeSelectedObject();
    //vector vSelectedPosition = GetTargetingModeSelectedPosition();

    if (GetLocalInt(oPC, "TARGET_MODE") == TARGET_MODE_SEND_MONEY)  // gold transfer
    {
        if (GetIsPC(oTarget) && oPC != oTarget)
        {
            int iValue = GetLocalInt(oPC, "MONEY_TRANSFER_AMOUNT");
            int iDepositValue = bank_GetAccountBalance(oPC);
            if (iValue > iDepositValue) iValue = iDepositValue;
            bank_DecrementAccountBalance(oPC, iValue);
            bank_IncrementAccountBalance(oTarget, iValue);
            DeleteLocalInt(oPC, "MONEY_TRANSFER_AMOUNT");
        }
        else
        {
            SendColorMessageToPC(oPC, "The selected target must be another player.", TXT_COLOR_RED);
        }

    }
    else if (GetLocalInt(oPC, "TARGET_MODE") == TARGET_MODE_SEND_FAME) // fame transfer
    {
        if (GetIsPC(oTarget) && oPC != oTarget && players_GetFactionsEqual(oPC, oTarget))
        {
            int iCost = GetLocalInt(oPC, "FAME_TRANSFER_AMOUNT");
            int iFreeFame = GetFreeFame(oPC);
            if (factions_GetFactionFame(players_GetFaction(oPC)) >= CONST_NEED_FAME_FACTION)
            {
                if (chat_GetAccountFame(oPC) >= CONST_NEED_FAME_PC)
                {
                    if (iCost > iFreeFame) iCost = iFreeFame;
                    if(iCost > 0)
                    {
                        // no log message and dont save transfered fame as spent fame for this character
                        SpendFame(oPC, iCost, FALSE, FALSE);
                        int iFame = FloatToInt(IntToFloat(iCost)*CONST_PERCENT_GAIN_FAME);
                        factions_AddFame(oTarget, iFame);
                        factions_StoreFameEventToDatabase(oTarget, oPC, GetHitDice(oTarget), GetHitDice(oPC),
                                                          SQLite_GetTimeStamp(), GetTag(GetArea(oPC)), iFame, FAME_GAIN_TYPE_TRANSFER);
                        SendMessageToPC(oTarget, "You received " + IntToString(iFame) + " fame from " + GetName(oPC));
                        SendMessageToPC(oPC, "You spent " + IntToString(iCost)+ " fame. Available: " + IntToString(GetFreeFame(oPC)));
                    }
                    else
                        SendMessageToPC(oPC, "Transfer failed: not enough free fame. Need: " + IntToString(iFreeFame));
                }
                else
                    SendMessageToPC(oPC, "Transfer failed: not enough account fame. Need: " + IntToString(CONST_NEED_FAME_PC));
            }
            else
                SendMessageToPC(oPC, "Transfer failed: not enough faction fame. Need: " + IntToString(CONST_NEED_FAME_FACTION));
        }
        else
            SendColorMessageToPC(oPC, "The selected target must be another player of your faction.", TXT_COLOR_RED);
    }
    else if (GetLocalInt(oPC, "TARGET_MODE") == TARGET_MODE_SEND_SOUL_STONES) // soul stones transfer
    {
        if (GetIsPC(oTarget) && oPC != oTarget)
        {
            //
            int iCost = GetLocalInt(oPC, "SOUL_STONES_TRANSFER_AMOUNT");
            if(generic_ChangeSoulStonesAmount(oPC, -iCost))
                generic_ChangeSoulStonesAmount(oTarget, iCost);
        }
        else
            SendColorMessageToPC(oPC, "The selected target must be another player.", TXT_COLOR_RED);
    }
    else if (GetLocalInt(oPC, "TARGET_MODE") == TARGET_MODE_DPS_CALCULATOR) // for dps calculator
    {
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionAttack(oTarget));
    }
    else if (GetLocalInt(oPC, "TARGET_MODE") == TARGET_MODE_USE_BARD_AS_YOUR_SLAVE) // for bard usage
    {
        if(GetLevelByClass(CLASS_TYPE_BARD, oTarget) <= 20)
        {
            SendColorMessageToPC(oPC, "The selected bard is too weak for this job.", TXT_COLOR_RED);
            return;
        }
        int nAreaFaction = players_GetFaction(GetArea(oTarget));
        int nPCFaction = players_GetFaction(oPC);
        int oTargetFaction = players_GetFaction(oTarget);
        if(nAreaFaction != nPCFaction || nPCFaction != oTargetFaction)
        {
            SendColorMessageToPC(oPC, "You can only use this option in your territory with a friendly bard.", TXT_COLOR_RED);
            return;
        }
        AssignCommand(oTarget, ClearAllActions());
        AssignCommand(oTarget, ActionUseFeat(FEAT_BARD_SONGS));
        if(!GetHasSpellEffect(SPELL_SEE_INVISIBILITY, oTarget))
            AssignCommand(oTarget, ActionCastSpellAtObject(SPELL_SEE_INVISIBILITY, oTarget, METAMAGIC_EXTEND));
        AssignCommand(oTarget, DelayCommand(1.5, ActionCastSpellAtObject(SPELL_DISPLACEMENT, oTarget, METAMAGIC_EXTEND)));
        AssignCommand(oTarget, DelayCommand(1.5, ActionCastSpellAtObject(SPELL_WAR_CRY, oTarget, METAMAGIC_EXTEND)));
        // rest bard if no songs
        if(!GetFeatRemainingUses(FEAT_BARD_SONGS, oTarget))
        {
            ForceRest(oTarget);
            DestroyALLSpellMarkerPlacebles(oTarget);
            ExecuteScript("_mod_instant_eff", oTarget);
        }
    }

    // clear locals
    DeleteLocalInt(oPC, "TARGET_MODE");
    DeleteLocalInt(oPC, "MONEY_TRANSFER_AMOUNT");
    DeleteLocalInt(oPC, "FAME_TRANSFER_AMOUNT");
    DeleteLocalInt(oPC, "SOUL_STONES_TRANSFER_AMOUNT");
}

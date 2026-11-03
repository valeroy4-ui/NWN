#include "_inc_nui"
#include "_inc_spells"

void main()
{
    object oPC = GetLastGuiEventPlayer();
    int nGuiEvent = GetLastGuiEventType();
    int nGuiEventInt = GetLastGuiEventInteger();

    int nPlayerMenuToken = NuiFindWindow(oPC, CONST_CORMYR_NUI_PLAYER_MENU);

    if     (nGuiEvent == GUIEVENT_OPTIONS_OPEN)
    {
        if(nPlayerMenuToken)
            NuiDestroy(oPC, nPlayerMenuToken);
    }
    // handle disabled GUI panels
    else if(nGuiEvent == GUIEVENT_DISABLED_PANEL_ATTEMPT_OPEN)
    {
        switch(nGuiEventInt)
        {
            case GUI_PANEL_JOURNAL:
            {
                if(nPlayerMenuToken)
                    NuiDestroy(oPC, nPlayerMenuToken);
                else
                    nui_CreatePlayerMenu(oPC);
            }
            break;
        }
    }
    else if(nGuiEvent == GUIEVENT_EFFECTICON_CLICK)
    {
        int nEffectIconId = nGuiEventInt;
        //FloatingColorTextStringOnCreature("nEffectIconId: " + IntToString(nEffectIconId), TXT_COLOR_GRAY, oPC, FALSE);
        effect eLoop = GetFirstEffect(oPC);
        while(GetIsEffectValid(eLoop))
        {
            struct NWNX_EffectUnpacked eEffUnpacked = NWNX_Effect_UnpackEffect(eLoop);
            //printeff(eEffUnpacked);
            if(eEffUnpacked.bShowIcon && eEffUnpacked.nParam0 == nEffectIconId)
            {
                string sName = GetSpellNameFromID(eEffUnpacked.nSpellId);
                if(sName != "")
                {
                    int nDurationRemaining = GetEffectDurationRemaining(eLoop);
                    if(eEffUnpacked.fDuration > 0.0)
                    {
                        FloatingColorTextStringOnCreature(sName +" will expire in " + IntToString(nDurationRemaining) + " seconds.", TXT_COLOR_WHITE_T, oPC, FALSE);
                        break;
                    }
                }
            }
            eLoop = GetNextEffect(oPC);
        }
    }
}

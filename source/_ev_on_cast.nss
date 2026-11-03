/// NWNX spellhook
/// execution sequence:
/// NWNX_ON_INPUT_CAST_SPELL_*
/// NWNX_ON_BROADCAST_CAST_SPELL_*
/// NWNX_ON_CAST_SPELL_*

#include "nwnx_events"
#include "_inc_spells"
#include "_inc_spellhook"
#include "_inc_champ_boss"
#include "_inc_sqlocals"
#include "_inc_divbuffer"
#include "_inc_runes"


// exclude spells that activate the cooldown only after successful roll
// or the cooldown is activated on the target
int CheckTimeOutException(int iSpellID);

void main()
{
    object oCaster      = OBJECT_SELF;
    string sSpellID     = NWNX_Events_GetEventData("SPELL_ID");
    object oTarget      = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));
    object oSpellItem   = StringToObject(NWNX_Events_GetEventData("ITEM_OBJECT_ID"));

    if (NWNX_Events_GetCurrentEvent() == NWNX_ON_CAST_SPELL_BEFORE)
    {
        int iSpellID        = StringToInt(sSpellID);
        int iBypass         = FALSE;

        // fix blink by spellike abilities
        generic_BrokenAnimationBlinkFix(OBJECT_SELF, OBJECT_INVALID, NWNX_Object_GetLastSpellCastFeat(OBJECT_SELF));

        iBypass = OnSpellCast(oCaster, oTarget, iSpellID);

        if(spells_GetHasSpellCooldown(iSpellID, oCaster))
        {
            FloatingColorTextStringOnCreature(GetSpellNameFromID(iSpellID)+ " is not ready!",
                                              TXT_COLOR_RED, oCaster, FALSE);
            iBypass = TRUE;
        }

        //if(GetSpellFeatId() == -1 && (GetActionMode(oCaster, ACTION_MODE_EXPERTISE) || GetActionMode(oCaster, ACTION_MODE_IMPROVED_EXPERTISE)) &&
        //   Get2DAString("spells", "UseConcentration", iSpellID) == "1" && !GetIsObjectValid(oSpellItem))
        if(GetSpellFeatId() == -1 && !GetIsObjectValid(oSpellItem) &&
          (GetActionMode(oCaster, ACTION_MODE_EXPERTISE) || GetActionMode(oCaster, ACTION_MODE_IMPROVED_EXPERTISE)))
        {

            FloatingColorTextStringOnCreature("Spellcasting while using expertise is not allowed.",
                                              TXT_COLOR_RED, oCaster, FALSE);
            iBypass = TRUE;
        }

        if(iBypass)
            NWNX_Events_SkipEvent();
    }
    else if (NWNX_Events_GetCurrentEvent() == NWNX_ON_CAST_SPELL_AFTER)
    {
        int iSpellID        = StringToInt(sSpellID);
        int iMultiClass     = StringToInt(NWNX_Events_GetEventData("MULTI_CLASS"));

        // show spell cast log
        ShowSpellCastMessage(oCaster, iSpellID, EVENT_TYPE_ON_CAST_SPELL, oSpellItem);
        //TestColors();

        // check and apply cooldown for specific spells
        float fCooldown = GetSpellTimeoutDuration(iSpellID);
        if (fCooldown > 0.0 && !spells_GetHasSpellCooldown(iSpellID, oCaster) && !CheckTimeOutException(iSpellID))
            spells_SetSpellCooldown(iSpellID, oCaster, fCooldown);

        // don't scale boss spells damage!
        if (champion_GetIsBoss(oCaster))
            SQLocals_SetInt(oCaster, "BOSS_SPELL_DAMAGE_SCALING_BLOCK", TRUE);

        // decrement runic spell uses
        int nInvertRunicSpellId = runes_GetStandartSpellIdFromRunic(iSpellID);
        if(nInvertRunicSpellId != RUNE_SPELL_ID_NONE)
        {
            int nRunicMeta = GetLocalInt(oCaster, "RUNIC_META");
            int nRunicClass = GetLocalInt(oCaster, "RUNIC_CLASS");
            int nRunicDomain = GetLocalInt(oCaster, "RUNIC_DOMAIN");
            //SendMessageToPC(oCaster, IntToString(nInvertRunicSpellId) + " " + IntToString(nRunicMeta) + " " + IntToString(nRunicClass) + " " + IntToString(nRunicDomain) + " ");
            divbuffer_DecrementSpellUses(oCaster, nInvertRunicSpellId, nRunicMeta, nRunicDomain, nRunicClass);
            if(nRunicClass == CLASS_TYPE_DRUID && nInvertRunicSpellId == SPELL_GREATER_RESTORATION)
            {
                if(nRunicMeta & METAMAGIC_STILL || nRunicMeta & METAMAGIC_SILENT ||  nRunicMeta & METAMAGIC_EXTEND)
                    DecrementRemainingSpellUses(oCaster, SPELL_SUNBURST);
                else
                    DecrementRemainingSpellUses(oCaster, nInvertRunicSpellId);
            }
        }

        if(GetIsObjectValid(oSpellItem))
        {
            if (GetTag(oSpellItem) != DIVINE_BUFFER_ITEM_TAG)
            {
                SetLocalObject(oCaster, "SPELLCAST_ITEM", oSpellItem);
                DelayCommand(3.0, DeleteLocalObject(oCaster, "SPELLCAST_ITEM"));
            }
        }
        else
        {
            int iLastSpellClass  = GetClassByPosition(iMultiClass + 1, oCaster);
            int iLastCasterLevel = GetLevelByClass(iLastSpellClass);
            SetLocalInt(oCaster, "LAST_CASTER_SPELL_CLASS", iLastSpellClass);
            SetLocalInt(oCaster, "LAST_CASTER_LEVEL", iLastCasterLevel);

            object oDivineBuffer = GetLocalObject(oCaster, "DIVINE_BUFFER");
            if(GetIsObjectValid(oDivineBuffer))
                divbuffer_SaveSpell(oCaster, oDivineBuffer, iSpellID, iLastSpellClass);
        }
        // DEBUG show spellID
        // SendMessageToPC(OBJECT_SELF, "[DEBUG] SpellID: " + sSpellID);
    }
}

int CheckTimeOutException(int iSpellID)
{
    switch(iSpellID)
    {
        case SPELL_TASHAS_HIDEOUS_LAUGHTER:
        case SPELL_BIGBYS_INTERPOSING_HAND:
        case SPELL_BIGBYS_FORCEFUL_HAND:
        case SPELL_BIGBYS_GRASPING_HAND:
        case SPELL_BIGBYS_CLENCHED_FIST:
        case SPELL_WORD_OF_FAITH:
        case SPELL_EARTHQUAKE:
        case SPELL_BALAGARNSIRONHORN:
        case SPELL_THREATENING_CRY:
        case SPELL_EVIL_BLIGHT:
        case SPELL_BG_MARK_OF_DOOM:
        case SPELL_GUST_OF_WIND:
        case SPELL_ICE_STORM:
        case SPELL_INFERNO:
            return TRUE;
    }
    return FALSE;
}


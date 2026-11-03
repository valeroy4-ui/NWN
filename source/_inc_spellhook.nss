#include "70_inc_switches"
#include "_inc_dispel"
#include "x2_inc_itemprop"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// checks if it is possible to cast under this effect
int NoCastEffect(effect eBad);

// returns TRUE if this spellID not hostile but can not be recasted (timestop, gr sanctuary etc)
int spellhook_GetIsRecastExceptionSpell(int nSpellID);

// remove spell effects for spell recast
void RemoveSpellBuff(object oCaster, object oTarget, int iSpell);

// remove AOE spell effects for spell recast
void OnAreaSpellCast(object oCaster, object oTarget, int iSpell);

// returns TRUE if cast illegal
int OnSpellCast(object oCaster, object oTarget, int iSpell);

// show spellcast log to caster and target
// nEvent = EVENT_TYPE_*
void ShowSpellCastMessage(object oCaster, int iSpellID, int nEvent, object oSpellCastItem = OBJECT_INVALID);

const int EVENT_TYPE_ON_BROADCAST_CAST_SPELL    = 1;
const int EVENT_TYPE_ON_CAST_SPELL              = 2;

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int NoCastEffect(effect eBad)
{
    int nEffectType = GetEffectType(eBad);
    if (
        nEffectType == EFFECT_TYPE_PARALYZE                  ||
        nEffectType == EFFECT_TYPE_CHARMED                   ||
        nEffectType == EFFECT_TYPE_DOMINATED                 ||
        nEffectType == EFFECT_TYPE_CONFUSED                  ||
        nEffectType == EFFECT_TYPE_FRIGHTENED                ||
        nEffectType == EFFECT_TYPE_STUNNED                   ||
        nEffectType == EFFECT_TYPE_PETRIFY
       ) return TRUE;
    return FALSE;
}

int spellhook_GetIsRecastExceptionSpell(int nSpellID)
{
    switch(nSpellID)
    {
        case SPELLABILITY_EPIC_CURSE_SONG: return TRUE;
        case SPELL_ETHEREALNESS: return TRUE;
        case SPELL_TIME_STOP: return TRUE;
    }
    return FALSE;
}

void RemoveSpellBuff(object oCaster, object oTarget, int iSpell)
{
    if(dispel_IsHostileSpell(iSpell) || spellhook_GetIsRecastExceptionSpell(iSpell))
        return;

    if(GetHasSpellEffect(iSpell, oTarget))
    {
        string sName = GetSpellNameFromID(iSpell);
        if(sName != "")
        {
            if(GetIsPC(oCaster))
                SendMessageToPC(oCaster, TXT_COLOR_WHITE_T + "Recasted spell " + sName + TXT_COLOR_END);

            if(GetIsPC(oTarget) && oTarget != oCaster)
                SendMessageToPC(oTarget, TXT_COLOR_WHITE_T + "Recasted spell " + sName + TXT_COLOR_END);

        }
        RemoveEffectsFromSpell(oTarget, iSpell);
        dispel_ClearSpellDataOnTarget(oTarget, iSpell);
    }
}


void OnAreaSpellCast(object oCaster, object oTarget, int iSpell)
{
    if(GetIsObjectValid(oTarget))
    {
        if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE)
        {
            SendColorMessageToPC(oCaster, "Placeables not valid target for spells!", TXT_COLOR_RED);
            SetModuleOverrideSpellScriptFinished();
            return;
        }
        RemoveSpellBuff(oCaster, oTarget, iSpell);
    }
}


int OnSpellCast(object oCaster, object oTarget, int iSpell)
{
    // dont cast if disabled
    effect eEffect = GetFirstEffect(oCaster);
    while(GetIsEffectValid(eEffect))
    {
        if (NoCastEffect(eEffect))
        {
            SendColorMessageToPC(oCaster, "You are disabled now.", TXT_COLOR_RED);
            return TRUE;
        }
        eEffect = GetNextEffect(oCaster);
    }

    object oArea = GetArea(oCaster);

    // dont cast in Timestop if you are not TS creator
    if (GetLocalInt(oArea, "TIMESTOP_IN_AREA"))
    {
        if(GetLocalObject(oArea, "TIMESTOP_CASTER") != oCaster)
        {
            return TRUE;
        }
    }

    // dont cast if Area not allows magic
    if(GetLocalInt(oArea, "iNOMAGIC") && !GetIsDM(oCaster))
    {
        FloatingColorTextStringOnCreature("You can not use magic here.", TXT_COLOR_RED, oCaster, FALSE);
        return TRUE;
    }

    if(GetIsObjectValid(oTarget))
    {
        if(!dispel_IsHostileSpell(iSpell))
        {
            // dont allow cast at placeable, only at corpses
            if(GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE && GetTag(oTarget) != CONST_CORPSE_TAG)
            {
                SendColorMessageToPC(oCaster,"You can not cast on placeable.", TXT_COLOR_RED);
                return TRUE;
            }
            // dont allow recast most of spells recast at enemy, only protect from aligment
            if(oCaster != oTarget &&
              (GetIsEnemy(oCaster, oTarget) || GetIsEnemy(oTarget, oCaster)) &&
               GetHasSpellEffect(iSpell, oTarget) &&
              (iSpell != SPELL_PROTECTION_FROM_EVIL && iSpell != SPELL_PROTECTION_FROM_GOOD))
            {
                return TRUE;
            }
        }
        // remove spell effect before buff
        RemoveSpellBuff(oCaster, oTarget, iSpell);
    }
    return FALSE;
}

void ShowSpellCastMessage(object oCaster, int iSpellID, int nEvent, object oSpellCastItem = OBJECT_INVALID)
{

    string sMessage;
    sMessage += ColorText(NWNX_Util_StripColors(GetName(oCaster)), GetIsPC(oCaster) ? players_GetFactionColor(players_GetFaction(oCaster)) : TXT_COLOR_NONE);

    /*
    int nFeatID = StringToInt(Get2DAString("spells", "FeatID", iSpellID));
    if (nFeatID)
    {
        if (nEvent == EVENT_TYPE_ON_BROADCAST_CAST_SPELL)
            return;
        string sFeatName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nFeatID)));
        sMessage += ColorText(" uses feat " + sFeatName, TXT_COLOR_VIOLET_L);
    }          */
    if (iSpellID == 413 /* activate item self */ || iSpellID == 386 /* activate item */)
    {
        sMessage += ColorText(" activates item " + GetName(oSpellCastItem), TXT_COLOR_VIOLET_L);
    }
    else
    {
        /*
        int nFeatID = StringToInt(Get2DAString("spells", "FeatID", iSpellID));
        if (nEvent == EVENT_TYPE_ON_BROADCAST_CAST_SPELL && nFeatID)
            return;       */
        if (nEvent == EVENT_TYPE_ON_BROADCAST_CAST_SPELL)
            sMessage += ColorText(" casting ", TXT_COLOR_VIOLET_L);
        if (nEvent == EVENT_TYPE_ON_CAST_SPELL)
            sMessage += ColorText(" casts ", TXT_COLOR_VIOLET_L);
        sMessage += ColorText(GetSpellNameFromID(iSpellID), TXT_COLOR_VIOLET_L);
        if (GetIsObjectValid(oSpellCastItem))
        {
            string sBaseTypeName;
            int ItemBaseType = GetBaseItemType(oSpellCastItem);

            if (IPGetIsItemEquipable(oSpellCastItem) ||
                ItemBaseType == BASE_ITEM_ENCHANTED_POTION ||
                ItemBaseType == BASE_ITEM_ENCHANTED_SCROLL ||
                ItemBaseType == BASE_ITEM_ENCHANTED_WAND ||
                ItemBaseType == BASE_ITEM_MAGICROD ||
                ItemBaseType == BASE_ITEM_MAGICWAND ||
                ItemBaseType == BASE_ITEM_POTIONS ||
                ItemBaseType == BASE_ITEM_SCROLL ||
                ItemBaseType == BASE_ITEM_SPELLSCROLL)
            {
                sBaseTypeName = GetStringByStrRef(StringToInt(Get2DAString("baseitems", "Name", ItemBaseType)));
            }
            else
            {
                sBaseTypeName = "Item";
            }
            sMessage += ColorText(" using " + sBaseTypeName, TXT_COLOR_VIOLET_L);
        }
    }
    // sending messages
    object oCasterArea = GetArea(oCaster);
    object oTarget = GetFirstPC();
    while (GetIsObjectValid(oTarget))
    {
        if(oCasterArea == GetArea(oTarget) && (GetObjectSeen(oCaster, oTarget) || GetIsDM(oTarget)) && (GetIsPC(oTarget) || GetIsDM(oTarget)))
            SendMessageToPC(oTarget, sMessage);
        oTarget = GetNextPC();
    }
}

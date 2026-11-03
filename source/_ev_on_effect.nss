#include "nwnx_events"
#include "_inc_dispel"
#include "_inc_runes"
#include "_inc_psv_bonuses"
#include "_inc_constants"
#include "_inc_spells"
#include "nwnx_player"
#include "_inc_generic"
#include "_inc_war_class"

const string SPELL_ID_APPLY_BLOCK = "SPELL_ID_APPLY_BLOCK";
const string SPELL_ID_REMOVE_BLOCK = "SPELL_ID_REMOVE_BLOCK";

// adds custom DC bonus for specific spell ID
void AddCustomBonusDcVsDispel(object oEffectCreator, int iSpellId, int iCustomBonusDC);

// overrides DC for specific spell ID
void OverrideDcVsDispel(object oEffectCreator, int iSpellId, int iValue);

// forcefully adds some spells to the list of those that can be dispelled
// mostly it's a spellike abilities
int CanBeDispelled(int iSpellId);

// actualizes an array of spells on the effect targets with a delay
void GetActualizedSpellDataWithDelay(object oEffectTarget);

// returns TRUE if EffectTrueType is classified as hostile
int GetIsHostileEffect(int nEffectTrueType, object oEffectTarget, object oEffectCreator);

// returns TRUE if EffectTrueType is classified as friendly
int GetIsBuffEffect(int nEffectTrueType);

// set cooldown for spell DC updates
void effect_SetSpellIdBlock(object oPC, int nSpellId, string sBlockType);

// get is spell DC updates cooldown active
int effect_GetSpellIdBlock(object oPC, int nSpellId, string sBlockType);


void main()
{
    string sEvent = NWNX_Events_GetCurrentEvent();
    if (sEvent == NWNX_ON_EFFECT_APPLIED_AFTER)
    {
        object oEffectTarget    = OBJECT_SELF;
        object oEffectCreator   = StringToObject(NWNX_Events_GetEventData("CREATOR"));
        int iEffectSubType      = StringToInt(NWNX_Events_GetEventData("SUB_TYPE"));
        int iSpellId            = StringToInt(NWNX_Events_GetEventData("SPELL_ID"));
        int iEffectTrueType     = StringToInt(NWNX_Events_GetEventData("TYPE"));

        // set true_effect local var for speed up spells_GetHasTrueEffect
        SetLocalInt(oEffectTarget, "TRUE_EFFECT_" + IntToString(iEffectTrueType), TRUE);

        if (GetIsPC(oEffectTarget))
        {
            // assists system ==>
            object oMaster = GetIsObjectValid(GetMaster(oEffectCreator)) ? GetMaster(oEffectCreator) : oEffectCreator;
            if (oEffectTarget != oMaster && GetIsPC(oMaster))
            {
                if (GetIsHostileEffect(iEffectTrueType, oEffectTarget, oMaster) && !players_GetFactionsEqual(oEffectTarget, oMaster))
                    UpdateHostileActorsList(oEffectTarget, oMaster);
                else if (GetIsBuffEffect(iEffectTrueType) && players_GetFactionsEqual(oEffectTarget, oMaster))
                    UpdateSupportActorsList(oEffectTarget, oMaster);

            }
            // <== assist system
            // clear saved movement factor
            DeleteLocalFloat(oEffectTarget, "MOVEMENT_FACTOR");
        }
        if(iEffectTrueType == EFFECT_TRUE_TYPE_TAUNT)
        {
            int nTauntSpellFailure = 10 + (GetLevelByClass(CLASS_TYPE_BARD, oEffectCreator) +
                                           GetLevelByClass(CLASS_TYPE_HARPER, oEffectCreator) +
                                           GetLevelByClass(CLASS_TYPE_ARCHMAGE, oEffectCreator))/2;
            int nBonus = 0;
            effect eEvilBlight = spells_GetFirstEffectWithSpecificSpellID(oEffectTarget, SPELL_EVIL_BLIGHT, oEffectCreator);
            if(GetEffectType(eEvilBlight) != EFFECT_TYPE_INVALIDEFFECT)
            {
                json jCash = GetLocalJson(GetModule(), JSON_VAR_EVIL_BLIGHT_DATA + "_" + ObjectToString(oEffectCreator));
                int nSFTaunt = JsonGetInt(JsonObjectGet(jCash, JSON_KEY_EVIL_BLIGHT_SF_TAUNT));
                nBonus += nSFTaunt;
            }
            effect eWarlordEcho = spells_GetFirstEffectWithSpecificSpellID(oEffectTarget, SPELL_BATTLEFIELD_ECHO, oEffectCreator);
            if(GetEffectType(eWarlordEcho) != EFFECT_TYPE_INVALIDEFFECT)
            {
                json jBonuses = GetLocalJson(GetModule(), JSON_BATTLEFIELD_ECHO_BONUSES + "_" + ObjectToString(oEffectCreator));
                int nSFTaunt = JsonGetInt(JsonObjectGet(jBonuses, BATTLEFIELD_ECHO_KEY_SF));
                nBonus += nSFTaunt;
            }
            string sAcPenalty = NWNX_Events_GetEventData("INT_PARAM_1");
            int nSfPenalty = nTauntSpellFailure + nBonus;
            // create and apply
            effect eTaunt = EffectSpellFailure(nSfPenalty);
            eTaunt = ExtraordinaryEffect(HideEffectIcon(eTaunt));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTaunt, oEffectTarget, 30.0);
            // send info about taunt penalty
            string sMessage = "Taunt penalty: -" + sAcPenalty + "AC, " + IntToString(nSfPenalty) + "% spellfailure.";
            DelayCommand(0.0, SendColorMessageToPC(oEffectCreator, sMessage, TXT_COLOR_VIOLET_L));
            DelayCommand(0.0, SendColorMessageToPC(oEffectTarget, sMessage, TXT_COLOR_VIOLET_L));
        }
        if(!effect_GetSpellIdBlock(oEffectTarget, iSpellId, SPELL_ID_APPLY_BLOCK) &&
          ((iEffectSubType == SUBTYPE_MAGICAL && GetIsObjectValid(oEffectCreator)) || CanBeDispelled(iSpellId)))
        {
            object oSpellCastItem = OBJECT_INVALID;
            if (oEffectCreator != oEffectTarget)
                oSpellCastItem = GetLocalObject(oEffectCreator, "SPELLCAST_ITEM");
            else
                oSpellCastItem = GetSpellCastItem();

            switch (iSpellId)
            {
            //------------------------------------------------------------------------------------------------------------------------------
                case SPELL_HARPER_INVISIBILITY:
                    OverrideDcVsDispel(oEffectCreator, iSpellId, 70);
                break;
            //------------------------------------------------------------------------------------------------------------------------------
                case SPELL_GREATER_INVISIBILITY:
                {
                    int nDCOverride = GetHitDice(oEffectCreator) / 2 + GetAbilityModifier(ABILITY_DEXTERITY, oEffectCreator) + GetLevelByClass(CLASS_TYPE_ROGUE, oEffectCreator) -
                    GetAbilityModifier(ABILITY_STRENGTH, oEffectCreator) + dispel_GetFameshopDefenceBonusVsDispel(GetPCPlayerName(oEffectCreator));
                    OverrideDcVsDispel(oEffectCreator, iSpellId, nDCOverride);
                }
                break;
            //------------------------------------------------------------------------------------------------------------------------------
                case SPELL_DIVINE_FAVOR:
                {
                    int iDispelDCModifier = 0;
                    if(runes_GetHasRune(oEffectCreator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_DIVINE_NATURE_I))
                        iDispelDCModifier = 10;
                    int nDcOverride = 12 + GetLevelByClass(CLASS_TYPE_PALADIN, oEffectCreator) + GetLevelByClass(CLASS_TYPE_PALADIN, oEffectCreator) +
                                      (GetLevelByClass(CLASS_TYPE_PALADIN, oEffectCreator) + GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oEffectCreator)) / 3 +
                                      dispel_GetFameshopDefenceBonusVsDispel(GetPCPlayerName(oEffectCreator)) + iDispelDCModifier;
                    OverrideDcVsDispel(oEffectCreator, iSpellId, nDcOverride);
                }
                break;
                case SPELL_BLADE_OF_WRATH:
                {
                    int iDispelDCModifier = 0;
                    if(runes_GetHasRune(oEffectCreator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_DIVINE_NATURE_I))
                        iDispelDCModifier = 10;
                    int nDcOverride = 12 + GetLevelByClass(CLASS_TYPE_RANGER, oEffectCreator) + GetLevelByClass(CLASS_TYPE_HARPER, oEffectCreator) +
                                      (GetLevelByClass(CLASS_TYPE_RANGER, oEffectCreator) + GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oEffectCreator)) / 3 +
                                      dispel_GetFameshopDefenceBonusVsDispel(GetPCPlayerName(oEffectCreator)) + iDispelDCModifier;
                    OverrideDcVsDispel(oEffectCreator, iSpellId, nDcOverride);
                }
                break;
            //------------------------------------------------------------------------------------------------------------------------------
                case SPELL_TRUE_SEEING:
                    if(runes_GetHasRune(oEffectCreator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_TRUE_SEEING_I))
                        AddCustomBonusDcVsDispel(oEffectCreator, iSpellId, 1);
                break;
            //------------------------------------------------------------------------------------------------------------------------------
                case SPELL_DEATH_WARD:
                    if(runes_GetHasRune(oEffectCreator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_DEATH_WARD_I))
                        AddCustomBonusDcVsDispel(oEffectCreator, iSpellId, 1);
                break;
            //------------------------------------------------------------------------------------------------------------------------------
                case SPELL_CLARITY:
                    if(runes_GetHasRune(oEffectCreator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_CLARITY_I))
                        AddCustomBonusDcVsDispel(oEffectCreator, iSpellId, 1);
                break;
            //------------------------------------------------------------------------------------------------------------------------------
                case SPELL_FREEDOM_OF_MOVEMENT:
                    if(runes_GetHasRune(oEffectCreator, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_FREEDOM_OF_MOVEMENT_I))
                        AddCustomBonusDcVsDispel(oEffectCreator, iSpellId, 1);
                break;

            //------------------------------------------------------------------------------------------------------------------------------
                case SPELLABILITY_AS_GHOSTLY_VISAGE:
                case SPELLABILITY_AS_IMPROVED_INVISIBLITY:
                case SPELLABILITY_AS_INVISIBILITY:
                    if(!GetIsObjectValid(oSpellCastItem))
                    {
                        int iAssassinLvl = GetLevelByClass(CLASS_TYPE_ASSASSIN, oEffectCreator);
                        if(iAssassinLvl >= 10)
                            AddCustomBonusDcVsDispel(oEffectCreator, iSpellId, iAssassinLvl);
                    }
                break;
            //------------------------------------------------------------------------------------------------------------------------------
            }
            // set local var to prevent multiple calls with same spell id
            effect_SetSpellIdBlock(oEffectTarget, iSpellId, SPELL_ID_APPLY_BLOCK);
            // add spell DC data to effect target
            dispel_AddSpellDataOnTarget(oEffectCreator, oEffectTarget, iSpellId);
            //ServerShout(IntToString(iSpellId));
        }
    }

    if (sEvent == NWNX_ON_EFFECT_REMOVED_AFTER)
    {
        object oEffectTarget    = OBJECT_SELF;
        int iSpellId            = StringToInt(NWNX_Events_GetEventData("SPELL_ID"));
        int iEffectTrueType     = StringToInt(NWNX_Events_GetEventData("TYPE"));
        string sEffectTag = NWNX_Events_GetEventData("CUSTOM_TAG");

        // set true_effect local var for speed up spells_GetHasTrueEffect
        DeleteLocalInt(oEffectTarget, "TRUE_EFFECT_" + IntToString(iEffectTrueType));

        // update the array of spells on the target
        if (iSpellId > 0 && !effect_GetSpellIdBlock(oEffectTarget, iSpellId, SPELL_ID_REMOVE_BLOCK))
        {
            effect_SetSpellIdBlock(oEffectTarget, iSpellId, SPELL_ID_REMOVE_BLOCK);
            AssignCommand(oEffectTarget, DelayCommand(0.15, GetActualizedSpellDataWithDelay(oEffectTarget)));
        }
        // clear saved movement factor
        if(GetIsPC(oEffectTarget))
            DeleteLocalFloat(oEffectTarget, "MOVEMENT_FACTOR");
        // clear rogue crippling strike stored value
        if(iSpellId == SPELL_CRIPPLING_STRIKE_ROGUE)
            DeleteLocalInt(oEffectTarget, "CRIPPLING_STRIKE_ROGUE");
    }
}

void AddCustomBonusDcVsDispel(object oEffectCreator, int iSpellId, int iCustomBonusDC)
{
    if (iCustomBonusDC > 0) SetLocalInt(oEffectCreator, "ADD_BONUS_DC_VS_DISPEL_" + IntToString(iSpellId), iCustomBonusDC);
}

void OverrideDcVsDispel(object oEffectCreator, int iSpellId, int iValue)
{
    if (iValue > 0) SetLocalInt(oEffectCreator, "OVERRIDE_DC_VS_DISPEL_" + IntToString(iSpellId), iValue);
}

int CanBeDispelled(int iSpellId)
{
    switch (iSpellId)
    {
        case SPELL_HARPER_INVISIBILITY: return TRUE;
        case SPELL_GREATER_INVISIBILITY: return TRUE;
    }
    return FALSE;
}

void GetActualizedSpellDataWithDelay(object oEffectTarget)
{
    dispel_GetActualizedSpellData(oEffectTarget);
}

int GetIsHostileEffect(int nEffectTrueType, object oEffectTarget, object oEffectCreator)
{
    int iResult = FALSE;
    switch (nEffectTrueType)
    {
        // don't trigger when target has immunity
        case EFFECT_TRUE_TYPE_SETSTATE:
            if (!GetIsImmune(oEffectTarget, IMMUNITY_TYPE_MIND_SPELLS, oEffectCreator))
                iResult = TRUE;
        break;

        case EFFECT_TRUE_TYPE_SLOW:
        case EFFECT_TRUE_TYPE_DISEASE:
        case EFFECT_TRUE_TYPE_ATTACKDECREASE:
        case EFFECT_TRUE_TYPE_DAMAGEDECREASE:
        case EFFECT_TRUE_TYPE_DAMAGEIMMUNITYDECREASE:
        case EFFECT_TRUE_TYPE_ENTANGLE:
        case EFFECT_TRUE_TYPE_KNOCKDOWN:
        case EFFECT_TRUE_TYPE_DEAF:
        case EFFECT_TRUE_TYPE_SAVINGTHROWDECREASE:
        case EFFECT_TRUE_TYPE_MOVEMENTSPEEDINCREASE:
        case EFFECT_TRUE_TYPE_MOVEMENTSPEEDDECREASE:
        case EFFECT_TRUE_TYPE_SPELLRESISTANCEDECREASE:
        case EFFECT_TRUE_TYPE_POISON:
        case EFFECT_TRUE_TYPE_ABILITYDECREASE:
        case EFFECT_TRUE_TYPE_DAMAGE:
        case EFFECT_TRUE_TYPE_CURSE:
        case EFFECT_TRUE_TYPE_SILENCE:
        case EFFECT_TRUE_TYPE_ACDECREASE:
        case EFFECT_TRUE_TYPE_TAUNT:
        case EFFECT_TRUE_TYPE_SKILLDECREASE:
        case EFFECT_TRUE_TYPE_BLINDNESS:
        case EFFECT_TRUE_TYPE_MISSCHANCE:
        case EFFECT_TRUE_TYPE_NEGATIVELEVEL:
        case EFFECT_TRUE_TYPE_WOUNDING:
        case EFFECT_TRUE_TYPE_DISARM:
        case EFFECT_TRUE_TYPE_PETRIFY:
        case EFFECT_TRUE_TYPE_SPELLFAILURE:
        case EFFECT_TRUE_TYPE_CUTSCENEIMMOBILE:
            iResult = TRUE;
        break;
    }
    return iResult;
}

int GetIsBuffEffect(int nEffectTrueType)
{
    switch (nEffectTrueType)
    {
        case EFFECT_TRUE_TYPE_HASTE:
        case EFFECT_TRUE_TYPE_DAMAGERESISTANCE:
        case EFFECT_TRUE_TYPE_REGENERATE:
        case EFFECT_TRUE_TYPE_ATTACKINCREASE:
        case EFFECT_TRUE_TYPE_DAMAGEREDUCTION:
        case EFFECT_TRUE_TYPE_DAMAGEINCREASE:
        case EFFECT_TRUE_TYPE_TEMPORARYHITPOINTS:
        case EFFECT_TRUE_TYPE_DAMAGEIMMUNITYINCREASE:
        case EFFECT_TRUE_TYPE_IMMUNITY:
        case EFFECT_TRUE_TYPE_SAVINGTHROWINCREASE:
        case EFFECT_TRUE_TYPE_MOVEMENTSPEEDINCREASE:
        case EFFECT_TRUE_TYPE_SPELLRESISTANCEINCREASE:
        case EFFECT_TRUE_TYPE_ABILITYINCREASE:
        case EFFECT_TRUE_TYPE_HEAL:
        case EFFECT_TRUE_TYPE_INVISIBILITY:
        case EFFECT_TRUE_TYPE_ACINCREASE:
        case EFFECT_TRUE_TYPE_SPELLIMMUNITY:
        case EFFECT_TRUE_TYPE_SKILLINCREASE:
        case EFFECT_TRUE_TYPE_SPELLLEVELABSORPTION:
        case EFFECT_TRUE_TYPE_SEEINVISIBLE:
        case EFFECT_TRUE_TYPE_ULTRAVISION:
        case EFFECT_TRUE_TYPE_TRUESEEING:
        case EFFECT_TRUE_TYPE_CONCEALMENT:
            return TRUE;
    }
    return FALSE;
}

void effect_SetSpellIdBlock(object oPC, int nSpellId, string sBlockType)
{
    object oCash = players_GetSpellIDsCashNPC();
    string sLocalVar = sBlockType + "_" + ObjectToString(oPC) + "_" + IntToString(nSpellId);
    SetLocalInt(oCash, sLocalVar, TRUE);
    AssignCommand(GetModule(), DelayCommand(0.25, DeleteLocalInt(oCash, sLocalVar)));
}

int effect_GetSpellIdBlock(object oPC, int nSpellId, string sBlockType)
{
    object oCash = players_GetSpellIDsCashNPC();
    string sLocalVar = sBlockType + "_" + ObjectToString(oPC) + "_" + IntToString(nSpellId);
    return GetLocalInt(oCash, sLocalVar);
}


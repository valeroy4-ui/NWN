/// NWNX spellhook
/// execution sequence:
/// NWNX_ON_INPUT_CAST_SPELL_*
/// NWNX_ON_BROADCAST_CAST_SPELL_*
/// NWNX_ON_CAST_SPELL_*

#include "nwnx_events"
#include "_inc_colortext"
#include "_inc_players"
#include "70_inc_spells"
#include "nwnx_creature"
#include "_inc_runes"
#include "inc_heal_range"

const int RULESET_ROW_METAMAGIC_EMPOWER      = 459;
const int RULESET_ROW_METAMAGIC_EXTEND       = 460;
const int RULESET_ROW_METAMAGIC_MAXIMIZE     = 461;
const int RULESET_ROW_METAMAGIC_QUICKEN      = 462;
const int RULESET_ROW_METAMAGIC_SILENT       = 463;
const int RULESET_ROW_METAMAGIC_STILL        = 464;

// returns TRUE if caster has no slots for this spell level
int inp_cast_CheckBonusSpellSlotsBugUsage(int iSpellClass, int iSpellID, int nDomainLevel, int nMeta, object oCaster);

// returns nMeta cost
int inp_cast_GetMetamagicCost(int nMeta);

void main()
{
    if (NWNX_Events_GetCurrentEvent() == NWNX_ON_INPUT_CAST_SPELL_BEFORE)
    {
        int iSpellID     = StringToInt(NWNX_Events_GetEventData("SPELL_ID"));
        int iMultiClass  = StringToInt(NWNX_Events_GetEventData("MULTICLASS"));
        int iSpellClass  = GetClassByPosition(iMultiClass + 1);
        int nSpellMeta   = StringToInt(NWNX_Events_GetEventData("META_TYPE"));
        int nSpellDomain = StringToInt(NWNX_Events_GetEventData("DOMAIN_LEVEL"));
        object oTarget   = StringToObject(NWNX_Events_GetEventData("TARGET"));
        int iBypassEvent = FALSE;

        if (GetIsPC(OBJECT_SELF) && !GetIsDM(OBJECT_SELF))
            iBypassEvent = inp_cast_CheckBonusSpellSlotsBugUsage(iSpellClass, iSpellID, nSpellDomain, nSpellMeta, OBJECT_SELF);

        if (iBypassEvent)
            NWNX_Events_SkipEvent();

        // One common Healing Domain route for CCW, CSW, Greater Restoration, Heal, Mass Heal.
        if(HealRange_RouteInput(iSpellID,iSpellClass,nSpellMeta,nSpellDomain,oTarget,iBypassEvent))
            return;

        // rune empowered spells
        int nRunicSpellID = runes_GetRunicSpellIdFromStandart(iSpellID);
        if((nRunicSpellID == SPELL_RUNIC_HEAL || nRunicSpellID == SPELL_RUNIC_GREATER_RESTORATION || nRunicSpellID == SPELL_RUNIC_MASS_HEAL) &&
            runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_HEALING_III) ||
            nRunicSpellID == SPELL_RUNIC_DEATH_WARD && runes_GetHasRune(OBJECT_SELF, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_DEATH_WARD_III))
        {
            NWNX_Events_SkipEvent();
            SetLocalInt(OBJECT_SELF, "RUNIC_META", nSpellMeta);
            SetLocalInt(OBJECT_SELF, "RUNIC_CLASS", iSpellClass);
            SetLocalInt(OBJECT_SELF, "RUNIC_DOMAIN", nSpellDomain);
            ActionCastSpellAtObject(nRunicSpellID, oTarget, METAMAGIC_ANY, TRUE);
        }
        //if(iSpellID == SPELL_IMPLOSION)
        //{
        //    NWNX_Events_SkipEvent();
        //    ActionCastSpellAtObject(SPELL_IMPLOSION, oTarget, nSpellMeta, FALSE, nSpellDomain, PROJECTILE_PATH_TYPE_DEFAULT, FALSE, iSpellClass, TRUE);
        //}
    }
}

int inp_cast_CheckBonusSpellSlotsBugUsage(int iSpellClass, int iSpellID, int nDomainLevel, int nMeta, object oCaster)
{
    string sSpellLevel;
    int iNumSpellsForSpellLevel;
    int iSpgn2daRow = GetLevelByClass(iSpellClass) - 1;

    // read cls_spgn_* that define how many spell slots a class has at each level
    string sSpellBookTable = GetStringLowerCase(Get2DAString("classes", "SpellGainTable", iSpellClass));

    if(GetStringLength(sSpellBookTable) > 0)
    {
        if(nDomainLevel > 0)
            sSpellLevel = IntToString(nDomainLevel);
        else
        {
            // read spell level from spells.2da
            sSpellLevel = IntToString(GetSpellLevel(iSpellID, iSpellClass));
            if(sSpellLevel == "-1")
                sSpellLevel = Get2DAString("spells", "Innate", iSpellID);
        }
        int nMetaCost = inp_cast_GetMetamagicCost(nMeta);
        int nFoundSpellLevel = StringToInt(sSpellLevel) + nMetaCost;
        if(!GetSpellMinAbilityMet(oCaster, iSpellClass, nFoundSpellLevel))
        {
            FloatingColorTextStringOnCreature("Your base ability isn't enough for cast this spell.",
                                              TXT_COLOR_RED, OBJECT_SELF);
            return TRUE;
        }
        // read how many spell slots has our caster at his caster level for this innate spell level
        iNumSpellsForSpellLevel = StringToInt(Get2DAString(sSpellBookTable, "SpellLevel" +
                                              IntToString(StringToInt(sSpellLevel) + nMetaCost),
                                              iSpgn2daRow));
        if (iNumSpellsForSpellLevel == 0)
        {
            FloatingColorTextStringOnCreature("You do not meet the requirements for cast this spell.",
                                              TXT_COLOR_RED, OBJECT_SELF);
            return TRUE;
        }
    }
    return FALSE;
}

int inp_cast_GetMetamagicCost(int nMeta)
{
    int nRow = -1;
    switch(nMeta)
    {
        case METAMAGIC_EMPOWER:  nRow = RULESET_ROW_METAMAGIC_EMPOWER;  break;
        case METAMAGIC_EXTEND:   nRow = RULESET_ROW_METAMAGIC_EXTEND;   break;
        case METAMAGIC_MAXIMIZE: nRow = RULESET_ROW_METAMAGIC_MAXIMIZE; break;
        case METAMAGIC_QUICKEN:  nRow = RULESET_ROW_METAMAGIC_QUICKEN;  break;
        case METAMAGIC_SILENT:   nRow = RULESET_ROW_METAMAGIC_SILENT;   break;
        case METAMAGIC_STILL:    nRow = RULESET_ROW_METAMAGIC_STILL;    break;
        default: nRow = 0; break;
    }
    return nRow > 0 ? StringToInt(Get2DAString("ruleset", "value", nRow)) : 0;
}

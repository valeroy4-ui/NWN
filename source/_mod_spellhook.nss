#include "_inc_spellhook"
#include "70_inc_spells"
#include "_inc_runes"

void main()
{

    DeleteLocalInt(OBJECT_SELF, CREATURE_VAR_SPELL_DC_MODIFIER);
    DeleteLocalInt(OBJECT_SELF, CREATURE_VAR_SPELL_DC_OVERRIDE);
    DeleteLocalInt(OBJECT_SELF, CREATURE_VAR_SPELL_CASTER_LEVEL_MODIFIER);
    DeleteLocalInt(OBJECT_SELF, CREATURE_VAR_SPELL_DURATION_TYPE_OVERRIDE);

    spellsDeclareMajorVariables();

    int nCharacterLevel = GetHitDice(spell.Caster);

    if (GetIsObjectValid(spell.Item))
    {
        if (spell.Id == SPELL_CLARITY               || spell.Id == SPELL_TRUE_SEEING            ||
            spell.Id == SPELL_LESSER_SPELL_MANTLE   || spell.Id == SPELL_SPELL_MANTLE           ||
            spell.Id == SPELL_GREATER_SPELL_MANTLE  || spell.Id == SPELL_UNDEATHS_ETERNAL_FOE   ||
            spell.Id == SPELL_DIVINE_FAVOR          || spell.Id == SPELL_DIVINE_POWER           ||
            /*spell.Id == SPELL_EXPEDITIOUS_RETREAT || */ dispel_IsHostileSpell(spell.Id))
        {
            // do nothing
        }
        else
        {
            string sAccount           = GetPCPlayerName(spell.Caster);
            int iFameShopDefenceBonus = dispel_GetFameshopDefenceBonusVsDispel(sAccount);
            int iItemCasterLevel      = nCharacterLevel + iFameShopDefenceBonus;

            SetLocalInt(spell.Item, ITEM_VAR_CASTER_LEVEL_OVERRIDE, iItemCasterLevel);
            DelayCommand(3.0, DeleteLocalInt(spell.Item, ITEM_VAR_CASTER_LEVEL_OVERRIDE));
        }
    }
    else
    {
        SetLocalInt(spell.Caster, CREATURE_VAR_SPELL_CASTER_LEVEL_MODIFIER, GetLevelByClass(CLASS_TYPE_ARCHMAGE));
    }

    //////////////////////////////////////////////////
    /////        modify spell DC                //////
    //////////////////////////////////////////////////

    int nDcModifier = 0;
    int nDcOverride = 0;
    int nCasterLevel = spell.Level + GetLevelByClass(CLASS_TYPE_ARCHMAGE);
    // calc new DC adjustment
    int nMod = (nCasterLevel - 21) > 1 ? (nCasterLevel - 21) / 2 : 0;
    nMod = nMod > 8 ? 8 : nMod;

    if(!GetIsObjectValid(spell.Item))
    {
        switch(spell.Id)
        {
            case SPELL_DESTRUCTION:
            case SPELL_BLADE_BARRIER:
                if(GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER, spell.Caster) &&
                   spell.Class == CLASS_TYPE_CLERIC)
                {
                    nDcModifier = nMod;
                }
            break;
            case SPELL_STORM_OF_VENGEANCE:
                if((GetHasFeat(FEAT_EVIL_DOMAIN_POWER, spell.Caster) && spell.Class == CLASS_TYPE_CLERIC) ||
                   spell.Class == CLASS_TYPE_DRUID)
                {
                    nDcModifier = nMod;
                }
            break;
            case SPELL_IMPLOSION:
                if(GetHasFeat(FEAT_DEATH_DOMAIN_POWER, spell.Caster) && spell.Class == CLASS_TYPE_CLERIC)
                {
                    nDcModifier = nMod;
                }
                if     (runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_IMPLOSION_III))
                    nDcModifier += 1;
                if     (runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_IMPLOSION_II))
                    SetLocalFloat(spell.Caster, IntToString(spell.Id) + "_RANGE_OVERRIDE", RADIUS_SIZE_LARGE);
                else if(runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_IMPLOSION_I))
                    SetLocalFloat(spell.Caster, IntToString(spell.Id) + "_RANGE_OVERRIDE", RADIUS_SIZE_MEDIUM);
            break;
            case SPELL_DROWN:
                if(spell.Class == CLASS_TYPE_DRUID)
                {
                    switch(nCasterLevel)
                    {
                        case 30: nDcModifier += 1;break;
                        case 31: nDcModifier += 2;break;
                        case 32: nDcModifier += 3;break;
                        case 33: nDcModifier += 4;break;
                        case 34: nDcModifier += 5;break;
                        case 35: nDcModifier += 6;break;
                        case 36: nDcModifier += 7;break;
                        case 37: nDcModifier += 8;break;
                        case 38: nDcModifier += 9;break;
                        case 39: nDcModifier += 10;break;
                        case 40: nDcModifier += 11;break;
                        default: break;
                    }
                }
            break;
            default: break;
        }
    }

    SetLocalInt(spell.Caster, CREATURE_VAR_SPELL_DC_MODIFIER, nDcModifier);
    SetLocalInt(spell.Caster, CREATURE_VAR_SPELL_DC_OVERRIDE, nDcOverride);

    //SendMessageToPC(spell.Caster, IntToString(nDcModifier) + " Caster Level: " + IntToString(spell.Level));

    //////////////////////////////////////////////////
    /////       end modify spell DC             //////
    //////////////////////////////////////////////////



    //////////////////////////////////////////////////
    /////        modify AoE duration            //////
    //////////////////////////////////////////////////

    if (nCharacterLevel == CORMYREAN_CHARACTER_MAX_LVL && GetModuleSwitchValue(MODULE_SWITCH_CORMYR_MAX_LEVEL_AOE_DURATION_SEC))
    {
        if (spell.Id == SPELL_ACID_FOG  || spell.Id == SPELL_ENTANGLE   ||
            spell.Id == SPELL_GREASE    || spell.Id == SPELL_STORM_OF_VENGEANCE ||
            spell.Id == SPELL_STONEHOLD || spell.Id == SPELL_VINE_MINE || spell.Id == SPELL_POISON)
        {
            SetLocalInt(spell.Caster, CREATURE_VAR_SPELL_DURATION_TYPE_OVERRIDE, SPELL_DURATION_TYPE_SECONDS);
        }
    }

    //////////////////////////////////////////////////
    /////        end modify AoE duration        //////
    //////////////////////////////////////////////////
}

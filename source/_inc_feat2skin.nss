#include "x3_inc_skin"
#include "_inc_constants"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// возвращает значение IP_CONST_FEAT_*, соответствующее указанному фиту
int FeatToItemPropertyConstant(int nFeat);

//Adds feat to player. Uses PC Skin system from 1.69 + expanded iprp_feats.2da from patch 1.72.
void AddFeat(int nFeat, object oPC);

// Removes feat from player's PC skin
void RemoveFeat(int nFeat, object oPC);


///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int FeatToItemPropertyConstant(int nFeat)
{
    switch(nFeat)
    {
        case FEAT_ALERTNESS:
            nFeat = IP_CONST_FEAT_ALERTNESS;
            break;
        case FEAT_AMBIDEXTERITY:
            nFeat = IP_CONST_FEAT_AMBIDEXTROUS;
            break;
        case FEAT_ARMOR_PROFICIENCY_HEAVY:
            nFeat = IP_CONST_FEAT_ARMOR_PROF_HEAVY;
            break;
        case FEAT_ARMOR_PROFICIENCY_LIGHT:
            nFeat = IP_CONST_FEAT_ARMOR_PROF_LIGHT;
            break;
        case FEAT_ARMOR_PROFICIENCY_MEDIUM:
            nFeat = IP_CONST_FEAT_ARMOR_PROF_MEDIUM;
            break;
        case FEAT_CLEAVE:
            nFeat = IP_CONST_FEAT_CLEAVE;
            break;
        case FEAT_COMBAT_CASTING:
            nFeat = IP_CONST_FEAT_COMBAT_CASTING;
            break;
        case FEAT_DISARM:
            nFeat = IP_CONST_FEAT_DISARM;
            break;
        case FEAT_DODGE:
            nFeat = IP_CONST_FEAT_DODGE;
            break;
        case FEAT_EXTRA_TURNING:
            nFeat = IP_CONST_FEAT_EXTRA_TURNING;
            break;
        case FEAT_HIDE_IN_PLAIN_SIGHT:
            nFeat = IP_CONST_FEAT_HIDE_IN_PLAIN_SIGHT;
            break;
        case FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE:
            nFeat = IP_CONST_FEAT_IMPCRITUNARM;
            break;
        case FEAT_KNOCKDOWN:
            nFeat = IP_CONST_FEAT_KNOCKDOWN;
            break;
        case FEAT_MOBILITY:
            nFeat = IP_CONST_FEAT_MOBILITY;
            break;
        case FEAT_PLAYER_TOOL_01:
            nFeat = IP_CONST_FEAT_PLAYER_TOOL_01;
            break;
        case FEAT_PLAYER_TOOL_02:
            nFeat = IP_CONST_FEAT_PLAYER_TOOL_02;
            break;
        case FEAT_PLAYER_TOOL_03:
            nFeat = IP_CONST_FEAT_PLAYER_TOOL_03;
            break;
        case FEAT_PLAYER_TOOL_04:
            nFeat = IP_CONST_FEAT_PLAYER_TOOL_04;
            break;
        case FEAT_PLAYER_TOOL_05:
            nFeat = IP_CONST_FEAT_PLAYER_TOOL_05;
            break;
        case FEAT_PLAYER_TOOL_06:
            nFeat = IP_CONST_FEAT_PLAYER_TOOL_06;
            break;
        case FEAT_PLAYER_TOOL_07:
            nFeat = IP_CONST_FEAT_PLAYER_TOOL_07;
            break;
        case FEAT_PLAYER_TOOL_08:
            nFeat = IP_CONST_FEAT_PLAYER_TOOL_08;
            break;
        case FEAT_PLAYER_TOOL_09:
            nFeat = IP_CONST_FEAT_PLAYER_TOOL_09;
            break;
        case FEAT_PLAYER_TOOL_10:
            nFeat = IP_CONST_FEAT_PLAYER_TOOL_10;
            break;
        case FEAT_POINT_BLANK_SHOT:
            nFeat = IP_CONST_FEAT_POINTBLANK;
            break;
        case FEAT_POWER_ATTACK:
            nFeat = IP_CONST_FEAT_POWERATTACK;
            break;
        case FEAT_RAPID_SHOT:
            nFeat = IP_CONST_FEAT_RAPID_SHOT;
            break;
        case FEAT_SHIELD_PROFICIENCY:
            nFeat = IP_CONST_FEAT_SHIELD_PROFICIENCY;
            break;
        case FEAT_SNEAK_ATTACK:
            nFeat = IP_CONST_FEAT_SNEAK_ATTACK_1D6;
            break;
        case 345:
            nFeat = IP_CONST_FEAT_SNEAK_ATTACK_2D6;
            break;
        case 346:
            nFeat = IP_CONST_FEAT_SNEAK_ATTACK_3D6;
            break;
        case 348:
            nFeat = IP_CONST_FEAT_SNEAK_ATTACK_5D6;
            break;
        case FEAT_SPELL_FOCUS_ABJURATION:
            nFeat = IP_CONST_FEAT_SPELLFOCUSABJ;
            break;
        case FEAT_SPELL_FOCUS_CONJURATION:
            nFeat = IP_CONST_FEAT_SPELLFOCUSCON;
            break;
        case FEAT_SPELL_FOCUS_DIVINATION:
            nFeat = IP_CONST_FEAT_SPELLFOCUSDIV;
            break;
        case FEAT_SPELL_FOCUS_ENCHANTMENT:
            nFeat = IP_CONST_FEAT_SPELLFOCUSENC;
            break;
        case FEAT_SPELL_FOCUS_EVOCATION:
            nFeat = IP_CONST_FEAT_SPELLFOCUSEVO;
            break;
        case FEAT_SPELL_FOCUS_ILLUSION:
            nFeat = IP_CONST_FEAT_SPELLFOCUSILL;
            break;
        case FEAT_SPELL_FOCUS_NECROMANCY:
            nFeat = IP_CONST_FEAT_SPELLFOCUSNEC;
            break;
        case FEAT_SPELL_FOCUS_TRANSMUTATION:
            nFeat = IP_CONST_FEAT_SPELLPENETRATION;
            break;
        case FEAT_TWO_WEAPON_FIGHTING:
            nFeat = IP_CONST_FEAT_TWO_WEAPON_FIGHTING;
            break;
        case FEAT_USE_POISON:
            nFeat = IP_CONST_FEAT_USE_POISON;
            break;
        case FEAT_WEAPON_FINESSE:
            nFeat = IP_CONST_FEAT_WEAPFINESSE;
            break;
        case FEAT_WEAPON_PROFICIENCY_CREATURE:
            nFeat = IP_CONST_FEAT_WEAPON_PROF_CREATURE;
            break;
        case FEAT_WEAPON_PROFICIENCY_EXOTIC:
            nFeat = IP_CONST_FEAT_WEAPON_PROF_EXOTIC;
            break;
        case FEAT_WEAPON_PROFICIENCY_MARTIAL:
            nFeat = IP_CONST_FEAT_WEAPON_PROF_MARTIAL;
            break;
        case FEAT_WEAPON_PROFICIENCY_SIMPLE:
            nFeat = IP_CONST_FEAT_WEAPON_PROF_SIMPLE;
            break;
        case FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE:
            nFeat = IP_CONST_FEAT_WEAPSPEUNARM;
            break;
        case FEAT_WHIRLWIND_ATTACK:
            nFeat = IP_CONST_FEAT_WHIRLWIND;
            break;
        case FEAT_IMPROVED_TAUNT:
            nFeat = IP_CONST_FEAT_IMPROVED_TAUNT;
            break;
        case FEAT_WOODEN_BODY:
            nFeat = IP_CONST_FEAT_WOODEN_BODY;
            break;
        case FEAT_MOONELF_SPELLRESISTANCE:
            nFeat = IP_CONST_FEAT_MOONELF_SPELLRESISTANCE;
            break;
        case FEAT_WEP_PROF_GOVNOTRYAS:
            nFeat = IP_CONST_FEAT_WEP_PROF_GOVNOTRYAS;
            break;
        default:
            nFeat += 100;
            break;
    }
    return nFeat;
}


void AddFeat(int nFeat, object oPC)
{
    itemproperty ipBonusFeat = ItemPropertyBonusFeat(FeatToItemPropertyConstant(nFeat));
    if(GetIsItemPropertyValid(ipBonusFeat))
    {
        object oSkin = SKIN_SupportGetSkin(oPC);
        AddItemProperty(DURATION_TYPE_PERMANENT, ipBonusFeat, oSkin);
    }
    else
    {
        WriteTimestampedLogEntry("Function AddFeat used with unsupported feat.");
    }
}

void RemoveFeat(int nFeat, object oPC)
{
    int ipFeat = FeatToItemPropertyConstant(nFeat);
    itemproperty ipBonusFeat = ItemPropertyBonusFeat(ipFeat);
    if(GetIsItemPropertyValid(ipBonusFeat))
    {
        object oSkin = SKIN_SupportGetSkin(oPC);
        itemproperty ipLoop=GetFirstItemProperty(oSkin);
        while (GetIsItemPropertyValid(ipLoop))
        {
            if(GetItemPropertyType(ipLoop)    == ITEM_PROPERTY_BONUS_FEAT &&
               GetItemPropertySubType(ipLoop) == ipFeat)
                    RemoveItemProperty(oSkin, ipLoop);

            ipLoop=GetNextItemProperty(oSkin);
        }
    }
    else
    {
        WriteTimestampedLogEntry("Function RemoveFeat used with unsupported feat.");
    }
}

//void main() {}



#include "nwnx_itemprop"
#include "nwnx_item"
#include "_inc_constants"
#include "_inc_db_funcs"
#include "nw_inc_gff"
#include "_inc_generic"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// unpack IP and log parameters
void ip_PrintIP(struct NWNX_IPUnpacked n);

// returns TRUE if oItem has IP with sTag
int ip_GetHasIpWithTag(object oItem, string sTag);

// remove IP with sTag from oItem
void ip_RemoveIpWithTag(object oItem, string sTag);

// remove temporary item properties at following items
void ip_RemoveTempIPsAtItem(object oItem);

// remove temporary item properties at oPC's inventory and equipped items
void ip_ClearAllTempItemPropAtPC(object oPC);

// returns TRUE if oItem has cormyrean additional <iSubType> item property and cash this value
int ip_GetHasCormyrIP(object oItem, int iSubType);

// remove/replace illegal properties;
void ip_FixIllegalIPs(object oItem);

// Add/Replace/Remove nSkill
// use nSkill = <some skill> and nValue = -1 to remove specific nSkill or
// use nSkill = -1  and nValue = -1 to remove all skills
void ip_ItemPropertyModifySkill(object oItem, int nSkill, int nValue, int bOverride = TRUE);

// return sum of nSkill or sum of all item's skills if nSkill = -1
int ip_GetSkillBonus(object oItem, int nSkill);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void ip_PrintIP(struct NWNX_IPUnpacked n)
{
    string s = "Unpacked IP: \n";

    s += "sID = " + "'" + n.sID + "'" + "\n";
    s += "nProperty = " + IntToString(n.nProperty) + "\n";
    s += "nSubType = " + IntToString(n.nSubType) + "\n";
    s += "nCostTable = " + IntToString(n.nCostTable) + "\n";
    s += "nCostTableValue = " + IntToString(n.nCostTableValue) + "\n";
    s += "nParam1 = " + IntToString(n.nParam1) + "\n";
    s += "nParam1Value = " + IntToString(n.nParam1Value) + "\n";
    s += "nUsesPerDay = " + IntToString(n.nUsesPerDay) + "\n";
    s += "nChanceToAppear = " + IntToString(n.nChanceToAppear) + "\n";
    s += "bUsable = " + IntToString(n.bUsable) + "\n";
    s += "nSpellId = " + IntToString(n.nSpellId) + "\n";
    s += "sTag = " + "'" + n.sTag + "'" + "\n";

    WriteTimestampedLogEntry(s);
}

int ip_GetHasIpWithTag(object oItem, string sTag)
{
    itemproperty ip_Itemproperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip_Itemproperty))
    {
        if (GetItemPropertyTag(ip_Itemproperty) == sTag) return TRUE;
        ip_Itemproperty = GetNextItemProperty(oItem);
    }
    return FALSE;
}

void ip_RemoveIpWithTag(object oItem, string sTag)
{
    itemproperty ip_Itemproperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip_Itemproperty))
    {
        if (GetItemPropertyTag(ip_Itemproperty) == sTag)
        {
            RemoveItemProperty(oItem, ip_Itemproperty);
        }
        ip_Itemproperty = GetNextItemProperty(oItem);
    }
}

void ip_RemoveTempIPsAtItem(object oItem)
{
    itemproperty ipEff = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipEff))
    {
        if(GetItemPropertyDurationType(ipEff) == DURATION_TYPE_TEMPORARY) RemoveItemProperty(oItem, ipEff);
        ipEff = GetNextItemProperty(oItem);
    }
}

void ip_ClearAllTempItemPropAtPC(object oPC)
{
    object oItem;
    int i;
    // equiped items
    for(i = INVENTORY_SLOT_HEAD; i <= INVENTORY_SLOT_BOLTS; i++)
    {
        oItem = GetItemInSlot(i, oPC);
        if(!GetIsObjectValid(oItem))
            continue;
        ip_RemoveTempIPsAtItem(oItem);
        oItem = GetItemInSlot(i, oPC);
    }
    // inventory
    oItem = GetFirstItemInInventory(oPC);
    while(GetIsObjectValid(oItem))
    {
        ip_RemoveTempIPsAtItem(oItem);
        oItem = GetNextItemInInventory(oPC);
    }
}

int ip_GetHasCormyrIP(object oItem, int iSubType)
{
    string sCashVarName = "CORMYR_ADDITIONAL_IP_" + IntToString(iSubType);
    int iCashCondition = GetLocalInt(oItem, sCashVarName);
    if (iCashCondition == 1)
        return TRUE;
    else if (iCashCondition == -1)
        return FALSE;
    else
    {
        itemproperty ip_Itemproperty = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(ip_Itemproperty))
        {
            if (GetItemPropertyType(ip_Itemproperty) == ITEM_PROPERTY_ADDITIONAL)
            {
                struct NWNX_IPUnpacked stIpUnpacked = NWNX_ItemProperty_UnpackIP(ip_Itemproperty);
                if (stIpUnpacked.nCostTableValue == iSubType)
                {
                    SetLocalInt(oItem, sCashVarName, 1);
                    return TRUE;
                }
            }
            ip_Itemproperty = GetNextItemProperty(oItem);
        }
        SetLocalInt(oItem, sCashVarName, -1);
        return FALSE;
    }
}

void ip_FixIllegalIPs(object oItem)
{
    if(!GetIsObjectValid(oItem))
        return;
    int nBaseType = GetBaseItemType(oItem);
    if(nBaseType > 68 && nBaseType < 74)
        return;

    itemproperty nItemProperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(nItemProperty))
    {
        int nType = GetItemPropertyType(nItemProperty);
        int nItemPropertyDurationType = GetItemPropertyDurationType(nItemProperty);
        switch(nType)
        {
            case ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL:
            case ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL:
            case ITEM_PROPERTY_FREEDOM_OF_MOVEMENT:
                RemoveItemProperty(oItem, nItemProperty);
            break;

            case ITEM_PROPERTY_DAMAGE_REDUCTION:
            {
                int nEnhancement = GetItemPropertySubType(nItemProperty);
                int nHPSoak = GetItemPropertyCostTableValue(nItemProperty);
                if (nHPSoak > IP_CONST_DAMAGESOAK_15_HP)
                {
                    RemoveItemProperty(oItem, nItemProperty);
                    AddItemProperty(nItemPropertyDurationType, ItemPropertyDamageReduction(nEnhancement, IP_CONST_DAMAGESOAK_15_HP), oItem);
                }
            }
            break;

            case ITEM_PROPERTY_DAMAGE_RESISTANCE:
            {
                int nDamageType = GetItemPropertySubType(nItemProperty);
                int nHPResist = GetItemPropertyCostTableValue(nItemProperty);
                if (nHPResist > IP_CONST_DAMAGERESIST_15)
                {
                    RemoveItemProperty(oItem, nItemProperty);
                    AddItemProperty(nItemPropertyDurationType, ItemPropertyDamageResistance(nDamageType, IP_CONST_DAMAGERESIST_15), oItem);
                }
            }
            break;

            case ITEM_PROPERTY_SKILL_BONUS:
            {
                int nSkill = GetItemPropertySubType(nItemProperty);
                int nBonus = GetItemPropertyCostTableValue(nItemProperty);
                if(nSkill == SKILL_DISCIPLINE && nBonus > 5)
                {
                    RemoveItemProperty(oItem, nItemProperty);
                    AddItemProperty(nItemPropertyDurationType, ItemPropertySkillBonus(nSkill, 5), oItem);
                }
                else if(nBonus > 10)
                {
                    RemoveItemProperty(oItem, nItemProperty);
                    AddItemProperty(nItemPropertyDurationType, ItemPropertySkillBonus(nSkill, 10), oItem);
                }
            }
            break;

            case ITEM_PROPERTY_IMPROVED_EVASION:
                RemoveItemProperty(oItem, nItemProperty);
                AddItemProperty(nItemPropertyDurationType, ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX, 5), oItem);
            break;

            case ITEM_PROPERTY_TRUE_SEEING:
                RemoveItemProperty(oItem, nItemProperty);
                AddItemProperty(nItemPropertyDurationType, ItemPropertyCastSpell(IP_CONST_CASTSPELL_TRUE_SEEING_9, IP_CONST_CASTSPELL_NUMUSES_1_USE_PER_DAY), oItem);
            break;

            case ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS:
            {
                int nImm = GetItemPropertySubType(nItemProperty);
                switch (nImm)
                {
                    case IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN:
                        RemoveItemProperty(oItem, nItemProperty);
                    break;
                    case IP_CONST_IMMUNITYMISC_KNOCKDOWN:
                        RemoveItemProperty(oItem, nItemProperty);
                    break;
                    case IP_CONST_IMMUNITYMISC_DEATH_MAGIC:
                        RemoveItemProperty(oItem, nItemProperty);
                        AddItemProperty(nItemPropertyDurationType, ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_DEATH, 5), oItem);
                    break;
                    case IP_CONST_IMMUNITYMISC_DISEASE:
                        RemoveItemProperty(oItem, nItemProperty);
                        AddItemProperty(nItemPropertyDurationType, ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_DISEASE, 5), oItem);
                    break;
                    case IP_CONST_IMMUNITYMISC_POISON:
                        RemoveItemProperty(oItem, nItemProperty);
                        AddItemProperty(nItemPropertyDurationType, ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_POISON, 5), oItem);
                    break;
                    case IP_CONST_IMMUNITYMISC_MINDSPELLS:
                        RemoveItemProperty(oItem, nItemProperty);
                        AddItemProperty(nItemPropertyDurationType, ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_MINDAFFECTING, 5), oItem);
                    break;
                    case IP_CONST_IMMUNITYMISC_FEAR:
                        RemoveItemProperty(oItem, nItemProperty);
                        AddItemProperty(nItemPropertyDurationType, ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_FEAR, 5), oItem);
                    break;
                    case IP_CONST_IMMUNITYMISC_BACKSTAB:
                    case IP_CONST_IMMUNITYMISC_CRITICAL_HITS:
                        RemoveItemProperty(oItem, nItemProperty);
                    break;
                }
            }
            break;

            case ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE:
            {
                int nDamageType = GetItemPropertySubType(nItemProperty);
                RemoveItemProperty(oItem, nItemProperty);
                AddItemProperty(nItemPropertyDurationType, ItemPropertyDamageResistance(nDamageType, IP_CONST_DAMAGERESIST_15), oItem);
            }
            break;

            case ITEM_PROPERTY_BONUS_FEAT:
            {
                int nFeat = GetItemPropertySubType(nItemProperty);
                if (nFeat == IP_CONST_FEAT_EXTRA_TURNING) RemoveItemProperty(oItem, nItemProperty);
            }
            break;
        }
        nItemProperty = GetNextItemProperty(oItem);
    }
}

void ip_ItemPropertyModifySkill(object oItem, int nSkill, int nValue, int bOverride = TRUE)
{
    itemproperty ip_Skill = ItemPropertySkillBonus(nSkill, nValue > 50 ? 50 : nValue <= 0 ? 1 : nValue);

    itemproperty ip_Loop = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip_Loop))
    {
        if(GetItemPropertyType(ip_Loop) == ITEM_PROPERTY_SKILL_BONUS)
        {
            if(bOverride && GetItemPropertySubType(ip_Loop) == nSkill ||
               nSkill == -1 && nValue == -1 || GetItemPropertySubType(ip_Loop) == nSkill && nValue == -1)
                RemoveItemProperty(oItem, ip_Loop);
        }
        ip_Loop = GetNextItemProperty(oItem);
    }
    if(nValue > 0)
        AddItemProperty(DURATION_TYPE_PERMANENT, ip_Skill, oItem);
}

int ip_GetSkillBonus(object oItem, int nSkill)
{
    int nResult = 0;
    itemproperty ip_Loop = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip_Loop))
    {
        if(GetItemPropertyType(ip_Loop) == ITEM_PROPERTY_SKILL_BONUS)
        {
            if(GetItemPropertySubType(ip_Loop) == nSkill || nSkill == -1)
                nResult += GetItemPropertyCostTableValue(ip_Loop);
        }
        ip_Loop = GetNextItemProperty(oItem);
    }
    return nResult;
}

void ip_ItemPropertyModifyAbility(object oItem, int nAbility, int nValue, int bOverride = TRUE)
{
    itemproperty ip_Ability = ItemPropertyAbilityBonus(nAbility, nValue > 12 ? 12 : nValue <= 0 ? 1 : nValue);

    itemproperty ip_Loop = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip_Loop))
    {
        if(GetItemPropertyType(ip_Loop) == ITEM_PROPERTY_ABILITY_BONUS)
        {
            if(bOverride && GetItemPropertySubType(ip_Loop) == nAbility ||
               nAbility == -1 && nValue == -1 || GetItemPropertySubType(ip_Loop) == nAbility && nValue == -1)
                RemoveItemProperty(oItem, ip_Loop);
        }
        ip_Loop = GetNextItemProperty(oItem);
    }
    if(nValue > 0)
        AddItemProperty(DURATION_TYPE_PERMANENT, ip_Ability, oItem);
}

int ip_GetAbilityBonus(object oItem, int nAbility)
{
    int nResult = 0;
    itemproperty ip_Loop = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip_Loop))
    {
        if(GetItemPropertyType(ip_Loop) == ITEM_PROPERTY_ABILITY_BONUS)
        {
            if(GetItemPropertySubType(ip_Loop) == nAbility || nAbility == -1)
                nResult += GetItemPropertyCostTableValue(ip_Loop);
        }
        ip_Loop = GetNextItemProperty(oItem);
    }
    return nResult;
}

void ip_ItemPropertyModifyAC(object oItem, int nValue, int bOverride = TRUE)
{
    itemproperty ip_Ability = ItemPropertyACBonus(nValue > 20 ? 20 : nValue <= 0 ? 1 : nValue);

    itemproperty ip_Loop = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip_Loop))
    {
        if(GetItemPropertyType(ip_Loop) == ITEM_PROPERTY_AC_BONUS)
        {
            if(bOverride || nValue == -1)
                RemoveItemProperty(oItem, ip_Loop);
        }
        ip_Loop = GetNextItemProperty(oItem);
    }
    if(nValue > 0)
        AddItemProperty(DURATION_TYPE_PERMANENT, ip_Ability, oItem);
}

int ip_GetACBonus(object oItem)
{
    int nResult = 0;
    itemproperty ip_Loop = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip_Loop))
    {
        if(GetItemPropertyType(ip_Loop) == ITEM_PROPERTY_AC_BONUS)
            nResult += GetItemPropertyCostTableValue(ip_Loop);
        ip_Loop = GetNextItemProperty(oItem);
    }
    return nResult;
}



//void main()  {}

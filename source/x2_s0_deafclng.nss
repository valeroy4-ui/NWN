//::///////////////////////////////////////////////
//:: Deafening Clang
//:: X2_S0_DeafClng
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants a +1 to attack and +3 bonus sonic damage to
  a weapon. Also the weapon will deafen on hit.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 28, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 08, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
//:: 2003-07-17: Complete Rewrite to make use of Item Property System


#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_fameshop"
#include "nwnx_object"
#include "_inc_itemprop"

int GetDispelDC(object oCaster)
{
    int iDC = GetHitDice(oCaster)/2 + GetAbilityModifier(ABILITY_STRENGTH, oCaster) + dispel_GetFameshopBonusToDispelAttackRoll(GetPCPlayerName(oCaster), SPELL_DEAFENING_CLANG);
    return (iDC > 48) ? 48 : iDC;
}

void AddDeafeningClangEffectToWeapon(object oWeapon, float fDuration, int nLvl)
{
    object oCaster = GetItemPossessor(oWeapon);
    string sAccount = GetPCPlayerName(oCaster);

    IPSafeAddItemProperty(oWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_BESTOW_CURSE, nLvl), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

    itemproperty ipCormyrDeafClang = ItemPropertyAdditional(IP_CONST_ADDITIONAL_CORMYR_DEAFCLANG);
    struct NWNX_IPUnpacked ip_Unpacked;
    ip_Unpacked = NWNX_ItemProperty_UnpackIP(ipCormyrDeafClang);
    ip_Unpacked.nSubType = IP_CONST_ADDITIONAL_CORMYR_DEAFCLANG;
    ip_Unpacked.sTag    = "IP_CONST_ADDITIONAL_CORMYR_DEAFCLANG";
    //printip(ip_Unpacked);
    ipCormyrDeafClang = NWNX_ItemProperty_PackIP(ip_Unpacked);

    int iSpellsToDispel = 1 + dispel_GetFameshopBonusChecksForDispelType(sAccount , SPELL_DEAFENING_CLANG);

    IPSafeAddItemProperty(oWeapon, ipCormyrDeafClang, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    SetLocalInt(oWeapon, "ITEM_DISPEL_ATTACK", GetDispelDC(oCaster));
    SetLocalInt(oWeapon, "DEAF_CLANG_SPELLS_NUMBER_FOR_DISPEL", iSpellsToDispel);

    object oOffHandWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCaster);
    if(GetIsObjectValid(oOffHandWeapon) && IPGetIsMeleeWeapon(oOffHandWeapon))
    {
        IPSafeAddItemProperty(oOffHandWeapon, ipCormyrDeafClang, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        SetLocalInt(oOffHandWeapon, "ITEM_DISPEL_ATTACK", GetDispelDC(oCaster));
        SetLocalInt(oOffHandWeapon, "DEAF_CLANG_SPELLS_NUMBER_FOR_DISPEL", iSpellsToDispel);
    }
}

void main()
{

    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    int nDuration = spell.Level;
    object oWeapon = IPGetTargetedOrEquippedMeleeWeapon();
    object oPossessor = GetItemPossessor(oWeapon);

    if(spell.Meta == METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2; //Duration is +100%
    }
    if(nDuration == 0)
    {
      nDuration =1;
    }
    if(GetIsObjectValid(oWeapon))
    {
        SignalEvent(oWeapon, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        if (nDuration > 0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor);
            AddDeafeningClangEffectToWeapon(oWeapon, RoundsToSeconds(nDuration), spell.Level);
            if(GetHasSpellEffect(spell.Id, oPossessor))
            {
                RemoveEffectsFromSpell(oPossessor, spell.Id);
            }
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectIcon(EFFECT_ICON_SPELL_DEAFENING_CLANG)), oPossessor, RoundsToSeconds(nDuration));
        }
    }
    else
    {
       FloatingTextStrRefOnCreature(83615, OBJECT_SELF);
       return;
    }
}


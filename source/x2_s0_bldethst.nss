//::///////////////////////////////////////////////
//:: Blade Thrist
//:: X2_S0_BldeThst
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants a +3 enhancement bonus to a slashing weapon
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 27, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 08, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
//:: 2003-07-21: Complete Rewrite to make use of Item Property System

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_itemprop"
#include "_inc_colortext"

int LevelToEnhancement(int iLevel)
{
    int nResult = iLevel / 3 - 2;
    return nResult = nResult > 0 ? nResult : 0;
}

int LevelToDamage(int iLevel)
{
    int iDamageBonus;
    switch(iLevel / 5)
    {
        case 1: return DAMAGE_BONUS_1d4;
        case 2: return DAMAGE_BONUS_2d4;
        case 3: return IP_CONST_DAMAGEBONUS_3d4;
        case 4: return IP_CONST_DAMAGEBONUS_4d4;
        case 5: return IP_CONST_DAMAGEBONUS_5d4;
        case 6: return IP_CONST_DAMAGEBONUS_6d4;
        case 7: return IP_CONST_DAMAGEBONUS_7d4;
        case 8: return IP_CONST_DAMAGEBONUS_8d4;
    }
    return DAMAGE_BONUS_1; // crutch for potential exceptions
}

void AddEnhanceEffectToWeapon(object oItem, float fDuration, int iDamageBonus, int iEnhancementBonus, int iDamageType)
{
    string sItemPropertyMarker = "SPELL_BLADE_THIRST";

    itemproperty ipEnchancement = ItemPropertyEnhancementBonus(iEnhancementBonus);
    ipEnchancement = TagItemProperty(ipEnchancement, sItemPropertyMarker);

    itemproperty ipDamage = ItemPropertyDamageBonus(iDamageType, iDamageBonus);
    ipDamage = TagItemProperty(ipDamage, sItemPropertyMarker);

    itemproperty ipVisual = ItemPropertyVisualEffect(ITEM_VISUAL_SHOCK_RED);
    ipVisual = TagItemProperty(ipVisual, sItemPropertyMarker);

    ip_RemoveIpWithTag(oItem, sItemPropertyMarker);

    AddItemProperty(DURATION_TYPE_TEMPORARY, ipEnchancement, oItem, fDuration);
    AddItemProperty(DURATION_TYPE_TEMPORARY, ipDamage, oItem, fDuration);
    AddItemProperty(DURATION_TYPE_TEMPORARY, ipVisual, oItem, fDuration);
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
    effect eDur = ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    int nDuration = 2 * spell.Level;

    // debug
    if(GetPCIPAddress(spell.Caster) == "192.168.128.100" /* debug */)
    {
        nDuration *= 3;
    }
    //

    object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spell.Caster);
    object oLeftHand = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spell.Caster);
    oLeftHand = GetMeleeWeapon(oLeftHand) ? oLeftHand : OBJECT_INVALID;

    object oPossessor = GetItemPossessor(oItem);
    if (!GetIsObjectValid(oItem))
    {
        SendColorMessageToPC(spell.Caster, "You must hold your weapon in your hands.", TXT_COLOR_RED);
        return;
    }
    if (!GetMeleeWeapon(oItem))
    {
        SendColorMessageToPC(spell.Caster, "This spell can only be used on melee weapons.", TXT_COLOR_RED);
        return;
    }

    if (spell.Meta == METAMAGIC_EXTEND) nDuration = nDuration * 2; //Duration is +100%
    if (GetIsObjectValid(oItem))
    {
        SignalEvent(oItem, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        if (nDuration > 0)
        {
            float fDuration = DurationToSeconds(nDuration);
            if(spell.Level > 20)
            {
                itemproperty ipKeen = ItemPropertyKeen();
                if(GetIsObjectValid(oLeftHand)) IPSafeAddItemProperty(oLeftHand, ipKeen, fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, TRUE);
                IPSafeAddItemProperty(oItem, ipKeen, fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, FALSE, TRUE);
            }
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, fDuration);

            int iDamage = LevelToDamage(spell.Level);
            int iEnhancement = LevelToEnhancement(spell.Level);
            AddEnhanceEffectToWeapon(oItem, fDuration, iDamage, iEnhancement, IP_CONST_DAMAGETYPE_NEGATIVE);
            // Left Hand
            if(GetIsObjectValid(oLeftHand))
                AddEnhanceEffectToWeapon(oLeftHand, fDuration, iDamage, iEnhancement, IP_CONST_DAMAGETYPE_NEGATIVE);
        }
    }
    else
    {
        FloatingColorTextStrRefOnCreature(83615, TXT_COLOR_GREEN_L, spell.Caster);
        return;
    }
}


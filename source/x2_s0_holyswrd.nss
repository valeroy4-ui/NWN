//::///////////////////////////////////////////////
//:: Holy Sword
//:: X2_S0_HolySwrd
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants holy avenger properties.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 28, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 08, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"
#include "nwnx_object"
#include "_inc_itemprop"
#include "_inc_spells"

int GetSlowSaveDC(object oCaster)
{
    int iDC = GetHitDice(oCaster)/2 + GetAbilityModifier(ABILITY_STRENGTH, oCaster) + GetAbilityModifier(ABILITY_WISDOM, oCaster);
    return iDC;
}

void SetHolyAvenger(object oWeapon, float fDuration, int nLvl, int nSpellID)
{
    object oPC = GetItemPossessor(oWeapon);

     if(!GetIsObjectValid(oPC) || !GetIsObjectValid(oWeapon))
        return;

    itemproperty ipHolyAvenger = ItemPropertyAdditional(IP_CONST_ADDITIONAL_CORMYR_HOLYAVENGER);
    struct NWNX_IPUnpacked ip_Unpacked;
    ip_Unpacked = NWNX_ItemProperty_UnpackIP(ipHolyAvenger);
    ip_Unpacked.nSubType = IP_CONST_ADDITIONAL_CORMYR_HOLYAVENGER; // change subtype to make ipprop stackable
    ip_Unpacked.sTag    = "IP_CONST_ADDITIONAL_CORMYR_HOLYAVENGER";
    ipHolyAvenger = NWNX_ItemProperty_PackIP(ip_Unpacked);

    SetLocalInt(oWeapon, "SLOWDC", GetSlowSaveDC(oPC));

    IPSafeAddItemProperty(oWeapon, ItemPropertyOnHitCastSpell(IP_CONST_ONHIT_CASTSPELL_BESTOW_CURSE, nLvl), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    IPSafeAddItemProperty(oWeapon, ipHolyAvenger, fDuration);
    IPSafeAddItemProperty(oWeapon, ItemPropertyVisualEffect(ITEM_VISUAL_PSIONIC_MIND), fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);

    if(GetHasSpellEffect(nSpellID, oPC))
        RemoveEffectsFromSpell(oPC, nSpellID);

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectIcon(EFFECT_ICON_SPELL_HOLY_SWORD)), oPC, fDuration);
    SendMessageToPC(oPC, GetName(oWeapon) + "  was enchanted.");
}

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if(GetLevelByClass(CLASS_TYPE_PALADIN, spell.Caster) < 12)
    {
        SendMessageToPC(spell.Caster, "The minimum paladin level for this spell is 12.");
        return;
    }

    object oMainWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spell.Target);
    object oOffhandWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spell.Target);

    if(GetIsObjectValid(oMainWeapon) && IPGetIsMeleeWeapon(oMainWeapon))
    {
        SignalEvent(GetItemPossessor(oMainWeapon), EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        int nDuration = spell.Level;
        int nLvl = nDuration;

        if(spell.Meta == METAMAGIC_EXTEND)
            nDuration = nDuration * 2; //Duration is +100%

        float fDuration = /*14.0f;*/ DurationToSeconds(nDuration);

        effect eVis = EffectVisualEffect(VFX_IMP_GOOD_HELP);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, GetItemPossessor(oMainWeapon));

        SetHolyAvenger(oMainWeapon, fDuration, nLvl, spell.Id);

        if(GetIsObjectValid(oOffhandWeapon) && IPGetIsMeleeWeapon(oOffhandWeapon))
            SetHolyAvenger(oOffhandWeapon, fDuration, nLvl, spell.Id);

        object oArea = GetArea(spell.Caster);
        vector vLoc = GetPosition(spell.Caster);
        vLoc.z += 6.0f;

        float fStep = 1.0;

        int nCount = 0;
        for( ; nCount < nDuration/6; nCount++)
        {
            DelayCommand(0.15f * nCount, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GOOD_HELP), Location(oArea, vLoc, 0.0f)));

            vLoc.z -= fStep;
        }
        DelayCommand(0.20 + 0.15 * IntToFloat(nCount) , ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SUPER_HEROISM), GetLocation(GetSpellTargetObject())));
    }
    else
    {
        FloatingTextStrRefOnCreature(83615, spell.Caster);
    }
}

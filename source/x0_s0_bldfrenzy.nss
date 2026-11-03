//::///////////////////////////////////////////////
//:: Blood Frenzy
//:: x0_s0_bldfrenzy.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_itemprop"
#include "x2_i0_spells"

void AddFrenzyEffectToWeapon(object oItem, float fDuration, int iDamageBonus, int iDamageType)
{
    string sItemPropertyMarker = "SPELL_BLOOD_FRENZY";

    itemproperty ipDamage = ItemPropertyDamageBonus(iDamageType, GetDamageBonusConstantFromNumber(iDamageBonus));
    ipDamage = TagItemProperty(ipDamage, sItemPropertyMarker);

    itemproperty ipVisual = ItemPropertyVisualEffect(ITEM_VISUAL_FIRE_BLACK);
    ipVisual = TagItemProperty(ipVisual, sItemPropertyMarker);

    ip_RemoveIpWithTag(oItem, sItemPropertyMarker);

    AddItemProperty(DURATION_TYPE_TEMPORARY, ipDamage, oItem, fDuration);
    AddItemProperty(DURATION_TYPE_TEMPORARY, ipVisual, oItem, fDuration);
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    object oRightHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spell.Caster);
    object oLeftHand = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spell.Caster);

    // calculate duration
    int nDuration = spell.Level;
    if(spell.Meta & METAMAGIC_EXTEND)
        nDuration = nDuration * 2;
    float fDuration = DurationToSeconds(nDuration);

    PlayVoiceChat(VOICE_CHAT_BATTLECRY1);
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    // calculate attack
    int nAttack = spell.Level/8;
    effect eAttack = EffectAttackIncrease(nAttack);

    // calculate damage
    int iDamageBonus = spell.Level/3;

    if(GetIsObjectValid(oRightHand))
    {
        AddFrenzyEffectToWeapon(oRightHand, fDuration, iDamageBonus, IP_CONST_DAMAGETYPE_NEGATIVE);
        if(GetIsObjectValid(oLeftHand) && (GetWeaponRanged(oLeftHand) || GetMeleeWeapon(oLeftHand)))
            AddFrenzyEffectToWeapon(oLeftHand, fDuration, iDamageBonus, IP_CONST_DAMAGETYPE_NEGATIVE);
    }
    // Apply the VFX and attack bonus
    effect eVis = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Caster);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAttack, spell.Target, fDuration);
}

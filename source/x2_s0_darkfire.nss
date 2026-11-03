//::///////////////////////////////////////////////
//:: Darkfire
//:: X2_S0_Darkfire
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Gives a melee weapon 1d6 fire damage +1 per two caster
  levels to a maximum of +10.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Dec 04, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 08, 2003
//:: 2003-07-29: Rewritten, Georg Zoeller


#include "nw_i0_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_constants"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    if(spell.Target != spell.Caster)
        return;
    spell.Level = GetLevelByClass(CLASS_TYPE_CLERIC, spell.Caster) + GetLevelByClass(CLASS_TYPE_ARCHMAGE, spell.Caster);
    if(!spell.Level || GetLevelByClass(CLASS_TYPE_WEAPON_MASTER, spell.Caster))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(PRCVFX_FNF_HELLFIRE_2), spell.Caster);
        FloatingColorTextStringOnCreature("Your ass was burned!",
                                          TXT_COLOR_RED, spell.Caster, TRUE);
        return;
    }
    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_FIRE);
    eVis = EffectLinkEffects(EffectVisualEffect(VFX_IMP_FLAME_M), eVis);

    int nDuration = 2 * spell.Level;

    if(spell.Meta == METAMAGIC_EXTEND)
        nDuration *= 2;

   object oMainWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spell.Target);
   object oOffhandWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spell.Target);

   if(GetIsObjectValid(oMainWeapon) && IPGetIsMeleeWeapon(oMainWeapon))
   {
        SignalEvent(GetItemPossessor(oMainWeapon), EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        if(nDuration > 0)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, GetItemPossessor(oMainWeapon));

            int nDmg = 0;
            if     (spell.Level <= 6)
                nDmg = IP_CONST_DAMAGEBONUS_1d6;
            else if(spell.Level <= 8)
                nDmg = IP_CONST_DAMAGEBONUS_1d8;
            else if(spell.Level <= 10)
                nDmg = IP_CONST_DAMAGEBONUS_1d10;
            else if(spell.Level <= 12)
                nDmg = IP_CONST_DAMAGEBONUS_2d6;
            else if(spell.Level <= 14)
                nDmg = IP_CONST_DAMAGEBONUS_2d8;
            else if(spell.Level <= 16)
                nDmg = IP_CONST_DAMAGEBONUS_2d10;
            else
                nDmg = IP_CONST_DAMAGEBONUS_2d12;

            float fDuration = DurationToSeconds(nDuration);
            itemproperty ipFlames = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_FIRE, nDmg);

            IPSafeAddItemProperty(oMainWeapon, ItemPropertyVisualEffect(ITEM_VISUAL_FIRE_INFERNO_DF), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, 0 , 1);
            IPSafeAddItemProperty(oMainWeapon, ipFlames, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, 0, 0);

            if(GetIsObjectValid(oOffhandWeapon) && IPGetIsMeleeWeapon(oOffhandWeapon))
            {
                IPSafeAddItemProperty(oOffhandWeapon, ItemPropertyVisualEffect(ITEM_VISUAL_FIRE_INFERNO_DF), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, 0 , 1);
                IPSafeAddItemProperty(oOffhandWeapon, ipFlames, fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, 0, 0);
            }
         }
    }
    else
    {
         FloatingTextStrRefOnCreature(83615, spell.Caster);
         return;
    }
}


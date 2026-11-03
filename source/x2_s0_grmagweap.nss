//::///////////////////////////////////////////////
//:: Greater Magic Weapon
//:: X2_S0_GrMagWeap
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants a +1 enhancement bonus per 3 caster levels
  (maximum of +5).
  lasts 1 hour per level
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 28, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 08, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
//:: 2003-07-17: Complete Rewrite to make use of Item Property System
/*
Patch 1.72

- the duration visual effect is no longer dispellable
- VFX added if cast on weapon on ground
- spell will apply attack bonus instead of enhancement if ever targets ranged weapon or gloves
*/

#include "70_inc_spells"
#include "_inc_itemprop"
//#include "x2_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_runes"

void AddGreaterEnhancementEffectToWeapon(object oMyWeapon, float fDuration, int nBonus, int bRanged = FALSE)
{
    itemproperty ipEnhancement;

    if(bRanged)
        ipEnhancement = ItemPropertyAttackBonus(nBonus);
    else
        ipEnhancement = ItemPropertyEnhancementBonus(nBonus);

    ipEnhancement = TagItemProperty(ipEnhancement, "WEAPON_ENCHANTMENT_BONUS");

    int bApply = TRUE;
    itemproperty ipProperty = GetFirstItemProperty(oMyWeapon);
    while(GetIsItemPropertyValid(ipProperty))
    {
        if(GetItemPropertyDurationType(ipProperty) == DURATION_TYPE_TEMPORARY
            && GetItemPropertyTag(ipProperty) == "WEAPON_ENCHANTMENT_BONUS")
        {
            RemoveItemProperty(oMyWeapon, ipProperty);
        }
        if(GetItemPropertyDurationType(ipProperty) == DURATION_TYPE_PERMANENT &&
           GetItemPropertyType(ipProperty) == ITEM_PROPERTY_ENHANCEMENT_BONUS &&
           GetItemPropertyCostTableValue(ipProperty) >= nBonus)
        {
            bApply = FALSE;
        }
        ipProperty = GetNextItemProperty(oMyWeapon);
    }
    if(bApply) DelayCommand(0.1, AddItemProperty(DURATION_TYPE_TEMPORARY, ipEnhancement, oMyWeapon, fDuration));
}


void ApplyGreaterWeaponToCreature(object oTarget, float fDuration, int nEnhancementBonus)
{
    object oMainWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
    object oOffhandWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
    int isMainValid = IPGetIsMeleeWeapon(oMainWeapon);
    int isOffhandValid = IPGetIsMeleeWeapon(oOffhandWeapon);
    if(GetIsObjectValid(oMainWeapon) || GetIsObjectValid(oOffhandWeapon))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(PRCVFX_FNF_MAGIC_WEAPON_2), oTarget);
        DelayCommand(1.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SUPER_HEROISM), oTarget));
    }
    if(isMainValid)
        DelayCommand(1.5, AddGreaterEnhancementEffectToWeapon(oMainWeapon, fDuration, nEnhancementBonus));
    else if(GetIsObjectValid(oMainWeapon))
        DelayCommand(1.5, AddGreaterEnhancementEffectToWeapon(oMainWeapon, fDuration, nEnhancementBonus, TRUE));
    if(isOffhandValid)
        DelayCommand(1.5, AddGreaterEnhancementEffectToWeapon(oOffhandWeapon, fDuration, nEnhancementBonus));
    else if(GetIsObjectValid(oOffhandWeapon))
        DelayCommand(1.5, AddGreaterEnhancementEffectToWeapon(oMainWeapon, fDuration, nEnhancementBonus, TRUE));
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    //spell.Limit = 5;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nCasterLevel = spell.Level;
    int nDuration = nCasterLevel;
    int nEnhancementBonus = nCasterLevel / 3;

    //Limit nCasterLvl to 5, so it max out at +5 enhancement to the weapon.
    nEnhancementBonus = nEnhancementBonus > 5 ? 5 : nEnhancementBonus;

    if(!GetIsObjectValid(spell.Item))
    {
        if(GetHasFeat(FEAT_STRENGTH_DOMAIN_POWER, spell.Caster) && spell.Class == CLASS_TYPE_CLERIC)
        {
            if(nCasterLevel > 29)      nEnhancementBonus = 7;
            else if(nCasterLevel > 19) nEnhancementBonus = 6;
        }
    }

    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration *= 2; //Duration is +100%

    int iTargetObjectType = GetObjectType(spell.Target);
    if(iTargetObjectType == OBJECT_TYPE_ITEM)
    {
        if(IPGetIsMeleeWeapon(spell.Target))
        {
            SignalEvent(GetItemPossessor(spell.Target), EventSpellCastAt(spell.Caster, spell.Id, FALSE));
            AddGreaterEnhancementEffectToWeapon(spell.Target, DurationToSeconds(nDuration), nEnhancementBonus);
        }
    }
    else if(iTargetObjectType == OBJECT_TYPE_CREATURE)
    {
        if(runes_GetHasRune(spell.Caster, RUNE_TYPE_MASS_CAST, RUNE_SPELL_MASS_CAST_GREATER_MAGIC_WEAPON) && !GetIsObjectValid(spell.Item))
        {
            object oTargetInShape = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
            while(GetIsObjectValid(oTargetInShape))
            {
                if(GetFactionEqual(oTargetInShape, spell.Caster))
                {
                    SignalEvent(oTargetInShape, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                    ApplyGreaterWeaponToCreature(oTargetInShape, DurationToSeconds(nDuration), nEnhancementBonus);
                }
                oTargetInShape = GetNextObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
            }
        }
        else
            ApplyGreaterWeaponToCreature(spell.Target, DurationToSeconds(nDuration), nEnhancementBonus);
    }
}


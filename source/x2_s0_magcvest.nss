//::///////////////////////////////////////////////
//:: Magic Vestment
//:: X2_S0_MagcVest
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants a +1 AC bonus to armor touched per 3 caster
  levels (maximum of +5).
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 28, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 09, 2003
//:: 2003-07-29: Rewritten, Georg Zoeller

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_runes"

int GetItemHasChaosChield(object oItem)
{
    itemproperty ip = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(ip)) {
        if (GetItemPropertyType(ip) == ITEM_PROPERTY_ONHITCASTSPELL && GetItemPropertySubType(ip) == IP_CONST_ONHIT_CASTSPELL_ONHIT_CHAOSSHIELD) {
            return TRUE;
        }
        ip = GetNextItemProperty(oItem);
    }
    return FALSE;
}

void AddACBonusToArmor(object oMyArmor, float fDuration, int nAmount)
{
    IPSafeAddItemProperty(oMyArmor, ItemPropertyACBonus(nAmount), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
}


void ApplyMagicVestmentToCreature(object oTarget, int nDuration, int nAmount)
{
    object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, oTarget);
    object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
    int isArmor = GetBaseItemType(oArmor) == BASE_ITEM_ARMOR;
    int isShield = MatchShield(oShield);
    if(isArmor || isShield)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(PRCVFX_FNF_MAGIC_VESTMENT), oTarget);
        DelayCommand(1.3f, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GLOBE_USE), oTarget));
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
        if(isArmor && !GetItemHasChaosChield(oArmor))
        {
            DelayCommand(1.3f, AddACBonusToArmor(oArmor, HoursToSeconds(nDuration), nAmount));
        }
        if(isShield && !GetItemHasChaosChield(oShield))
        {
            DelayCommand(1.3f, AddACBonusToArmor(oShield, HoursToSeconds(nDuration), nAmount));
        }
    }
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    spell.Limit = 5;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    effect eVis = EffectVisualEffect(VFX_IMP_GLOBE_USE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    int nCasterLevel = spell.Level;
    int nAmount = nCasterLevel / 3;
    /*
    if (!GetIsPC(OBJECT_SELF) && GetLocalInt(OBJECT_SELF, "CastForMoney")) {
        OnMobSpellCast(GetSpellTargetObject(), OBJECT_SELF, GetSpellId());
        nCasterLevel = 20;
        nAmount = GetScalableModifyByLevel(GetHitDice(GetSpellTargetObject()), GetSpellId());
    }       */

    int nDuration = nCasterLevel;

    if (nAmount < 0) {
        nAmount = 1;
    }
    else if (nAmount > 5) {
        nAmount = 5;
    }
    if(!GetIsObjectValid(spell.Item))
    {
        if(GetHasFeat(FEAT_PROTECTION_DOMAIN_POWER, spell.Caster) && spell.Class == CLASS_TYPE_CLERIC)
        {
            if(nCasterLevel > 29)      nAmount = 7;
            else if(nCasterLevel > 19) nAmount = 6;
        }
    }
    if (spell.Meta == METAMAGIC_EXTEND) {
        nDuration *= 2; //Duration is +100%
    }

    //if(nDuration <= 0) return;

    int iTargetObjectType = GetObjectType(spell.Target);

    if(iTargetObjectType == OBJECT_TYPE_ITEM)
    {
        if(GetBaseItemType(spell.Target) == BASE_ITEM_ARMOR || MatchShield(spell.Target))
        {
            if(!GetItemHasChaosChield(spell.Target))
            {
                SignalEvent(GetItemPossessor(spell.Target), EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                DelayCommand(1.3f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, GetItemPossessor(spell.Target)));
                DelayCommand(1.3f, AddACBonusToArmor(spell.Target, DurationToSeconds(nDuration), nAmount));
            }
        }

    }
    else if(iTargetObjectType == OBJECT_TYPE_CREATURE)
    {
        if(runes_GetHasRune(spell.Caster, RUNE_TYPE_MASS_CAST, RUNE_SPELL_MASS_CAST_MAGIC_VESTMENT) && !GetIsObjectValid(spell.Item))
        {
            object oTargetInShape = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
            while(GetIsObjectValid(oTargetInShape))
            {
                if(GetFactionEqual(oTargetInShape, spell.Caster))
                {
                    ApplyMagicVestmentToCreature(oTargetInShape, nDuration, nAmount);
                }
                oTargetInShape = GetNextObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
            }
        }
        else
        {
            ApplyMagicVestmentToCreature(spell.Target, nDuration, nAmount);
        }
    }
}

//::///////////////////////////////////////////////
//:: Cure Critical Wounds
//:: NW_S0_CurCrWn
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// As cure light wounds, except cure critical wounds
// heals 3 * caster level + 20/40/70/120 HP by Enchantment focus.
// Touch by default; Cleric-book + actual Healing Domain receives native Short range.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 18, 2000
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 26, 2001
/*
Patch 1.72
- touch attack will be skipped in case target is a caster himself
Patch 1.71
- missing saving throw added
- the healing domain power doesn't work anymore when the spell is cast from an item
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "inc_heal_range"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_POSITIVE;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    // Use the engine's current spellbook, not the presence of a Cleric level
    // or a cached class from another spell. NWN EE 8193.37.17 native API.
    spell.Class=GetLastSpellCastClass();
    spellsDeclareMajorVariables();
    if(GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class!=CLASS_TYPE_BARD && spell.Class!=CLASS_TYPE_CLERIC && spell.Class!=CLASS_TYPE_DRUID)
    { SendMessageToPC(spell.Caster,"Cure Critical Wounds requires Bard, Cleric or Druid spellcasting.");return; }
    int vfx_impactHurt=spell.DmgVfxL;
    int vfx_impactHeal=VFX_IMP_HEALING_G;
    int nFlat=20;
    int nFocus=0;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,spell.Caster)) { nFlat=120;nFocus=3; }
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,spell.Caster)) { nFlat=70;nFocus=2; }
    else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,spell.Caster)) { nFlat=40;nFocus=1; }
    int nBase=3*spell.Level+nFlat;
    int bHealingBook=HealRange_HasDomain(spell.Caster,spell.Class);
    // The hidden Short variant retains the native Cleric book and Master=31 slot.
    if(GetSpellId()==CCW275_DOMAIN_SPELL && (!bHealingBook || GetIsObjectValid(spell.Item)))
        return;
    spell.Id=SPELL_CURE_CRITICAL_WOUNDS;
    int nDamage=nBase;
    // Healing uses the table formula for every metamagic variant.
    // Preserve the existing Empower behavior only for damage to undead.
    int bUndead=spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD);
    int bDomainEmpower=FALSE;
    if(bUndead && (spell.Meta & METAMAGIC_EMPOWER)) nDamage+=nDamage/2;
    if(GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0)
    {
        string trace="[CCW275] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)
            +" focus="+IntToString(nFocus)+" base="+IntToString(nBase)+" final="+IntToString(nDamage)
            +" meta="+IntToString(spell.Meta)+" domainEmpower="+IntToString(bDomainEmpower)
            +" nativeId="+IntToString(GetSpellId())+" range="+((GetSpellId()==CCW275_DOMAIN_SPELL)?"short":"touch")
            +" target="+GetName(spell.Target);
        PrintString(trace);SendMessageToPC(spell.Caster,trace);
    }

    if(!bUndead)
    {
        //Set the heal effect
        effect eHeal = EffectHeal(nDamage);
        //Apply heal effect and VFX impact
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spell.Target);
        effect eVis2 = EffectVisualEffect(vfx_impactHeal);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    }
    //Check that the target is undead
    else
    {
        if (spell.Target == spell.Caster || TouchAttackMelee(spell.Target) > 0)
        {
            if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
                if (!MyResistSpell(spell.Caster, spell.Target))
                {
                    if(MySavingThrow(spell.SavingThrow,spell.Target,spell.DC,spell.SaveType,spell.Caster))
                    {
                        nDamage/= 2;
                    }
                    effect eDam = EffectDamage(nDamage,spell.DamageType);
                    //Apply the VFX impact and effects
                    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                    effect eVis = EffectVisualEffect(vfx_impactHurt);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                }
            }
        }
    }
}

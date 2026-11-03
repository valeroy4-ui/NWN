//::///////////////////////////////////////////////
//:: Cure Serious Wounds
//:: NW_S0_CurSerW
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Healing: 2 * caster level +20/40/70/120 HP by highest Enchantment focus.
// Metamagic does not change healing. Existing undead damage is retained.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 18, 2000
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: July 25, 2001
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

    // Read the actual casting book, including multiclass casts.
    spell.Class=GetLastSpellCastClass();
    spellsDeclareMajorVariables();
    if(GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class!=CLASS_TYPE_BARD && spell.Class!=CLASS_TYPE_CLERIC
        && spell.Class!=CLASS_TYPE_DRUID && spell.Class!=CLASS_TYPE_PALADIN
        && spell.Class!=CLASS_TYPE_RANGER)
    {SendMessageToPC(spell.Caster,"Cure Serious Wounds requires Bard, Cleric, Druid, Paladin or Ranger spellcasting.");return;}
    int healingBook=HealRange_HasDomain(spell.Caster,spell.Class);
    if(GetSpellId()==CSW276_DOMAIN_SPELL && (!healingBook || GetIsObjectValid(spell.Item)))return;
    spell.Id=SPELL_CURE_SERIOUS_WOUNDS;
    int nDice = spell.Dice;
    int nNumDice = 3;
    int nMaxExtraDamage = 15;
    int vfx_impactHurt = spell.DmgVfxL;
    int vfx_impactHeal = VFX_IMP_HEALING_L;

    int focus=0,flat=20;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=3;flat=120;}
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=2;flat=70;}
    else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=1;flat=40;}
    int healing=2*spell.Level+flat;
    int undead=spellsIsRacialType(spell.Target,RACIAL_TYPE_UNDEAD);
    int nDamage=0;
    // The legacy dice/metamagic/domain damage path is used only for undead.
    if(undead)
    {
        int nExtraDamage = spell.Level; // * figure out the bonus damage
        if (nExtraDamage > nMaxExtraDamage)
        {
            nExtraDamage = nMaxExtraDamage;
        }

        if(GetIsPC(spell.Target) && GetGameDifficulty() < GAME_DIFFICULTY_CORE_RULES)
        {   // * if low or normal difficulty then MAXMIZED is doubled.
            if(spell.Meta & METAMAGIC_MAXIMIZE)
            {
                nExtraDamage = nExtraDamage*2;
            }
            spell.Meta|= METAMAGIC_MAXIMIZE;//this will make spell also maximized if not already
        }

        //Calculate damage
        nDamage = MaximizeOrEmpower(nDice,nNumDice,spell.Meta,nExtraDamage);

        if(!(spell.Meta & METAMAGIC_EMPOWER) && spell.Item == OBJECT_INVALID && GetHasFeat(FEAT_HEALING_DOMAIN_POWER, spell.Caster))
        {   // * if the caster has healing domain, the spell is empowered
            nDamage = nDamage + (nDamage/2);
        }

    }
    if(GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0)
    {
        string report="[CSW276] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)
            +" focus="+IntToString(focus)+" base="+IntToString(healing)
            +" final="+IntToString(undead?nDamage:healing)+" meta="+IntToString(spell.Meta)
            +" nativeId="+IntToString(GetSpellId())+" tableRange="+Get2DAString("spells","Range",GetSpellId())
            +" target="+GetName(spell.Target);
        PrintString(report);SendMessageToPC(spell.Caster,report);
    }

    if(!undead)
    {
        //Set the heal effect
        effect eHeal = EffectHeal(healing);
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

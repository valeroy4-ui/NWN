//::///////////////////////////////////////////////
//:: Heal
//:: [NW_S0_Heal.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Living targets: 5*CL +100/120/150/200 by Enchantment focus.
//:: If undead they reduced to 1d4 HP.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 12, 2001
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: Aug 1, 2001
/*
Patch 1.72
- touch attack will be skipped in case target is a caster himself
Patch 1.70
- dying target wasn't healed to its maximum hitpoints
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_runes"
#include "inc_heal_range"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageType = DAMAGE_TYPE_POSITIVE;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spell.Class=GetLastSpellCastClass();
    spellsDeclareMajorVariables();

    // update spell.Level for runic empowered spells
    if(runes_GetStandartSpellIdFromRunic(spell.Id) != RUNE_SPELL_ID_NONE)
        spell.Level = GetLevelByClass(GetLocalInt(spell.Caster, "RUNIC_CLASS"), spell.Caster);

    int nativeId=GetSpellId();
    if((nativeId==SPELL_HEAL || nativeId==HEAL279_DOMAIN_SPELL)
        && GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class!=CLASS_TYPE_CLERIC && spell.Class!=CLASS_TYPE_DRUID)
    {SendMessageToPC(spell.Caster,"Heal requires Cleric or Druid spellcasting.");return;}
    int healingBook=HealRange_HasDomain(spell.Caster,spell.Class);
    if(nativeId==HEAL279_DOMAIN_SPELL && (!healingBook || GetIsObjectValid(spell.Item)))return;
    if(nativeId==SPELL_HEAL || nativeId==HEAL279_DOMAIN_SPELL)spell.Id=SPELL_HEAL;
    int focus=0,flat=100;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=3;flat=200;}
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=2;flat=150;}
    else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=1;flat=120;}
    int healing=5*spell.Level+flat;

    effect eKill, eHeal;
    int nDamage, nHeal, nModify, nTouch;
    effect eSun = EffectVisualEffect(spell.DmgVfxL);
    effect eHealVis = EffectVisualEffect(VFX_IMP_HEALING_X);
    //Check to see if the target is an undead
    if (spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD))
    {
        if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            //Make a touch attack
            if (spell.Target == spell.Caster || TouchAttackMelee(spell.Target))
            {
                //Make SR check
                if (!MyResistSpell(spell.Caster, spell.Target))
                {
                    //Roll damage
                    nModify = d4();
                    //Make metamagic check
                    if (spell.Meta & METAMAGIC_MAXIMIZE)
                    {
                        nModify = 1;
                    }
                    //Figure out the amount of damage to inflict
                    nDamage = GetCurrentHitPoints(spell.Target) - nModify;
                    //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
                    if(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
                    {
                        nDamage/= 2;
                    }
                    //Set damage
                    eKill = EffectDamage(nDamage, spell.DamageType);
                    //Apply damage effect and VFX impact
                    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, spell.Target));
                    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eSun, spell.Target));
                }
            }
        }
    }
    else
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        // New healing formula applies to all living targets and casters.
        // No dice, metamagic, automatic domain bonus or Healing Rune multiplier.
        nHeal=GetMaxHitPoints(spell.Target)-GetCurrentHitPoints(spell.Target);
        if(nHeal<0)nHeal=0;
        if(nHeal>healing)nHeal=healing;
        if(GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0)
        {
            string report="[HEAL279] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)
                +" focus="+IntToString(focus)+" base="+IntToString(healing)
                +" final="+IntToString(nHeal)+" meta="+IntToString(spell.Meta)
                +" nativeId="+IntToString(nativeId)+" tableRange="+Get2DAString("spells","Range",nativeId)
                +" target="+GetName(spell.Target);
            PrintString(report);SendMessageToPC(spell.Caster,report);
        }
        //Set the heal effect
        eHeal = EffectHeal(nHeal);
        //Apply the heal effect and the VFX impact
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHealVis, spell.Target);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHeal, spell.Target);
    }
}



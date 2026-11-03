//::///////////////////////////////////////////////
//:: Mass Heal
//:: [NW_S0_MasHeal.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Heals living allies within 3.3m for CL+100/120/150/200 HP
//:: unless they are undead.
//:: If undead they reduced to 1d4 HP.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 11, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- dying targets wasn't healed to their maximum hitpoints
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
    spell.Range = 3.3;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

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
    if((nativeId==SPELL_MASS_HEAL || nativeId==MH282_DOMAIN_SPELL)
        && GetIsPC(spell.Caster) && !GetIsObjectValid(spell.Item)
        && spell.Class!=CLASS_TYPE_CLERIC && spell.Class!=CLASS_TYPE_DRUID)
    {SendMessageToPC(spell.Caster,"Mass Heal requires Cleric or Druid spellcasting.");return;}
    int healingBook=HealRange_HasDomain(spell.Caster,spell.Class);
    if(nativeId==MH282_DOMAIN_SPELL && (!healingBook || GetIsObjectValid(spell.Item)))return;
    if(nativeId==SPELL_MASS_HEAL || nativeId==MH282_DOMAIN_SPELL)spell.Id=SPELL_MASS_HEAL;
    int focus=0,flat=100;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=3;flat=200;}
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=2;flat=150;}
    else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=1;flat=120;}
    int healing=spell.Level+flat;
    int debug=GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0;
    int allies=0;

    effect eKill;
    effect eVis = EffectVisualEffect(spell.DmgVfxL);
    effect eHeal;
    effect eVis2 = EffectVisualEffect(VFX_IMP_HEALING_G);
    effect eStrike = EffectVisualEffect(VFX_FNF_LOS_HOLY_10);
    int nTouch, nModify, nDamage, nHeal;
    float fDelay;

    //Apply VFX area impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eStrike, spell.Loc);
    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(oTarget))
    {
        if(GetDistanceBetweenLocations(GetLocation(oTarget),spell.Loc)>spell.Range)
        {oTarget=GetNextObjectInShape(SHAPE_SPHERE,spell.Range,spell.Loc,TRUE,OBJECT_TYPE_CREATURE);continue;}
        fDelay = GetRandomDelay();
        //Check to see if the target is an undead
        if (spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make a touch attack
            nTouch = TouchAttackRanged(oTarget);
            if (nTouch > 0)
            {
                if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
                {
                    //Make an SR check
                    if (!MyResistSpell(spell.Caster, oTarget, fDelay))
                    {
                        //Roll damage
                        nModify = d4();
                        //make metamagic check
                        if (spell.Meta & METAMAGIC_MAXIMIZE)
                        {
                            nModify = 1;
                        }
                        //Detemine the damage to inflict to the undead
                        nDamage =  GetCurrentHitPoints(oTarget) - nModify;
                        //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
                        if(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
                        {
                            nDamage/= 2;
                        }
                        //Set the damage effect
                        eKill = EffectDamage(nDamage, spell.DamageType);
                        //Apply the VFX impact and damage effect
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, oTarget));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    }
                }
            }
        }
        else//not an undead
        {
            //Make a faction check
            int alive=!GetIsDead(oTarget) || (GetIsPC(oTarget) && GetCurrentHitPoints(oTarget)>=-10);
            if(alive && (oTarget==spell.Caster || GetIsFriend(oTarget,spell.Caster)))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                //Determine amount to heal
                nHeal = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
                nHeal = (nHeal > 0) ? nHeal : 0;

                // cormyr fix max heal effect
                if(nHeal>healing)nHeal=healing;
                allies++;
                if(debug)
                {
                    string report="[MH282 TARGET] name="+GetName(oTarget)+" heal="+IntToString(nHeal)
                        +" distanceCenter="+FloatToString(GetDistanceBetweenLocations(GetLocation(oTarget),spell.Loc),0,2);
                    PrintString(report);SendMessageToPC(spell.Caster,report);
                }

                //Set the damage effect
                eHeal = EffectHeal(nHeal);
                //Apply the VFX impact and heal effect
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHeal, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
            }
        }
        //Get next target in the spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    }
    if(debug)
    {
        string report="[MH282] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)
            +" focus="+IntToString(focus)+" base="+IntToString(healing)+" meta="+IntToString(spell.Meta)
            +" nativeId="+IntToString(nativeId)+" tableRange="+Get2DAString("spells","Range",nativeId)
            +" radius="+FloatToString(spell.Range,0,2)+" allies="+IntToString(allies)
            +" center="+GetName(spell.Target);
        PrintString(report);SendMessageToPC(spell.Caster,report);
    }
}

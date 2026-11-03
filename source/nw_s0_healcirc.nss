//::///////////////////////////////////////////////
//:: Healing Circle
//:: NW_S0_HealCirc
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Positive energy spreads out in all directions
// from the caster, healing 3*CL +20/40/70/120 HP
// by highest Enchantment focus to living allies and self.
// Neutral and hostile living creatures are not healed.
//
// Like cure spells, healing circle damages undead in
// its area rather than curing them.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 18,2000
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: Aug 1, 2001
/*
Patch 1.71

- added missing saving throw subtype as per spell's descriptor
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_POSITIVE;
    spell.Range = 6.7;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spell.Class=GetLastSpellCastClass();
    spellsDeclareMajorVariables();
    // Self circle: always center it on the actual caster.
    spell.Target=spell.Caster;
    spell.Loc=GetLocation(spell.Caster);
    int focus=0,flat=20;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=3;flat=120;}
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=2;flat=70;}
    else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,spell.Caster)){focus=1;flat=40;}
    int healing=3*spell.Level+flat;
    int debug=GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)),"[test]")>=0;
    int allies=0;
    object oTarget;
    int nCasterLvl = spell.Level;
    int nDamagen, nModify, nHP;
    effect eKill;
    effect eHeal;
    effect eVis = EffectVisualEffect(spell.DmgVfxL);
    effect eVis2 = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_HOLY_20);
    float fDelay;
    // Keep the legacy caster-level cap only for the undead damage branch.
    if (nCasterLvl > 20)
    {
        nCasterLvl = 20;
    }
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
    //Get first target in shape
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE,spell.Range,spell.Loc,TRUE,OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(oTarget))
    {
        // Shape queries can include a creature's physical bounds: keep the
        // requested center-to-center radius precise, including near its edge.
        if(GetDistanceBetween(oTarget,spell.Caster)>spell.Range)
        {oTarget=GetNextObjectInShape(SHAPE_SPHERE,spell.Range,spell.Loc,TRUE,OBJECT_TYPE_CREATURE);continue;}
        fDelay = GetRandomDelay();
        //Check if racial type is undead
        if (spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD))
        {
            if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
                //Make SR check
                if (!MyResistSpell(spell.Caster, oTarget, fDelay))
                {
                    nModify = MaximizeOrEmpower(spell.Dice,1,spell.Meta,nCasterLvl);

                    //Make Fort save
                    if (MySavingThrow(spell.SavingThrow, oTarget, spell.DC, spell.SaveType, spell.Caster, fDelay))
                    {
                        nModify /= 2;
                    }

                    //Set damage effect
                    eKill = EffectDamage(nModify, spell.DamageType);
                    //Apply damage effect and VFX impact
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }
        else
        {
            // Heal self and living allies only; no neutral/hostile living targets.
            int alive=!GetIsDead(oTarget) || (GetIsPC(oTarget) && GetCurrentHitPoints(oTarget)>=-10);
            if(alive && (oTarget==spell.Caster || GetIsFriend(oTarget,spell.Caster)))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                nHP=healing; // No metamagic or automatic domain multiplier for healing.
                allies++;
                if(debug)
                {
                    string report="[HC280 TARGET] name="+GetName(oTarget)+" heal="+IntToString(nHP)
                        +" missingBefore="+IntToString(GetMaxHitPoints(oTarget)-GetCurrentHitPoints(oTarget))
                        +" distance="+FloatToString(GetDistanceBetween(oTarget,spell.Caster),0,2);
                    PrintString(report);SendMessageToPC(spell.Caster,report);
                }

                //Set healing effect
                eHeal = EffectHeal(nHP);
                //Apply heal effect and VFX impact
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
            }
        }
        //Get next target in the shape
        oTarget = GetNextObjectInShape(SHAPE_SPHERE,spell.Range,spell.Loc,TRUE,OBJECT_TYPE_CREATURE);
    }
    if(debug)
    {
        string report="[HC280] CL="+IntToString(spell.Level)+" class="+IntToString(spell.Class)
            +" focus="+IntToString(focus)+" base="+IntToString(healing)
            +" radius="+FloatToString(spell.Range,0,2)+" meta="+IntToString(spell.Meta)
            +" allies="+IntToString(allies)+" center="+GetName(spell.Caster);
        PrintString(report);SendMessageToPC(spell.Caster,report);
    }
}

//::///////////////////////////////////////////////
//:: Ice Storm
//:: NW_S0_IceStorm
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Everyone in the area takes 3d6 Bludgeoning
    and 2d6 Cold damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 12, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "nwnx_object"

//
void DoDamageInAOE(object oCaster, int nCasterLvl, int nMetaMagic, location lLoc, int nSpellID, int nSchoolFocus, float fRadius);

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageCap = 20;
    spell.DamageType = DAMAGE_TYPE_COLD;
    spell.Range = RADIUS_SIZE_HUGE;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nCasterLvl = (spell.Level > spell.DamageCap) ? spell.DamageCap : spell.Level;
    effect eExplode = EffectVisualEffect(VFX_FNF_ICESTORM);

    int nSchoolFocus = GetSpellSchoolFocus(SPELL_SCHOOL_EVOCATION, spell.Caster);
    if(GetLevelByClass(CLASS_TYPE_DRUID, spell.Caster) >= 30) nSchoolFocus = 3;

    DelayCommand(1.8 - 0.6 * nSchoolFocus, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spell.Loc));
    DelayCommand(2.6 - 0.7 * nSchoolFocus, DoDamageInAOE(spell.Caster, nCasterLvl, spell.Meta, spell.Loc, spell.Id, nSchoolFocus, spell.Range));
}

void DoDamageInAOE(object oCaster, int nCasterLvl, int nMetaMagic, location lLoc, int nSpellID, int nSchoolFocus, float fRadius)
{
    effect eDam;
    effect eDam2;
    effect eVis = EffectVisualEffect(VFX_IMP_FROST_S);

    int nDamage;
    int nDamage2;
    int nSlow = 0;
    float fSlowDuration = 0.0;
    effect eSlow;

    if(nSchoolFocus > 0 || GetLevelByClass(CLASS_TYPE_DRUID, oCaster) >= 30)
    {
        if(GetLevelByClass(CLASS_TYPE_DRUID, oCaster) >= 30) nSchoolFocus = 3;
        nSlow += nSchoolFocus * 10;
        fSlowDuration = nSchoolFocus * 3.0;
        eSlow = EffectMovementSpeedDecrease(nSlow);
        eSlow = EffectLinkEffects(EffectVisualEffect(VFX_IMP_SLOW), eSlow);
        eSlow = SetEffectSpellId(eSlow, nSpellID);
    }

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLoc, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    while (GetIsObjectValid(oTarget))
    {
        // don't work at friendly guards, plot objects and static placeables
        if  (!(GetLocalInt(oTarget, "IMGUARD") && !GetIsEnemy(oTarget, oCaster) ||
               GetPlotFlag(oTarget) ||
               GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE && NWNX_Object_GetPlaceableIsStatic(oTarget)))
        {
            SignalEvent(oTarget, EventSpellCastAt(oCaster, SPELL_ICE_STORM));
            if (!MyResistSpell(oCaster, oTarget) && !spells_GetHasSpellCooldown(nSpellID, oTarget, CORMYR_SPELL_COOLDOWN_TARGET))
            {
                nDamage = d6(3);
                nDamage2 = d6(nCasterLvl);
                if (nMetaMagic == METAMAGIC_MAXIMIZE)
                    nDamage2 = 6*(nCasterLvl);

                if (nMetaMagic == METAMAGIC_EMPOWER)
                {
                    nDamage2 += nDamage2 / 2;
                    nDamage += nDamage / 2;
                }
                eDam = EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_PLUS_NINTEEN);
                eDam2 = EffectDamage(nDamage2, DAMAGE_TYPE_COLD);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam2, oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, oTarget, fSlowDuration);
                // apply cooldown effect and icon
                if(GetIsPC(oCaster) && GetIsPC(oTarget))
                    spells_SetSpellCooldown(nSpellID, oTarget, 30.0, CORMYR_SPELL_COOLDOWN_DONT_SHOW_MESSAGES, CORMYR_SPELL_COOLDOWN_TARGET, EFFECT_ICON_IMMUNITY_ICESTORM);
            }
            else
                AssignCommand(oTarget, DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GLOBE_USE), oTarget)));
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLoc, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}

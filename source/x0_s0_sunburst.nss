//::///////////////////////////////////////////////
//:: Sunburst
//:: X0_S0_Sunburst
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Brilliant globe of heat
// All creatures in the globe are blinded and
// take 6d6 damage
// Undead creatures take 1d6 damage (max 25d6)
// The blindness is permanent unless cast to remove it
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 23 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs May 14, 2003
//:: Notes: Changed damage to non-undead to 6d6
//:: 2003-10-09: GZ Added Subrace check for vampire special case, bugfix
/*
Patch 1.72
- fixed a minor 1.71 bug that didn't print kill feedback in case this spell slayed vampire
Patch 1.71
- fixed Arcane Defense feat not working against this spell
- was missing delay in few effect applications
- was missing VFXs in few cases
- killing method could fail in special case (magic damage immune/resistant vampire)
- removed second and third save - all effects are now tied with first save
- oozes and plants takes full damage as if they were undead
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageCap = 25;//max 25d6 damage
    spell.DamageType = DAMAGE_TYPE_DIVINE;
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.SaveType = SAVING_THROW_TYPE_NONE;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nCasterLvl = spell.Level;
    //int nDamage;
    int nOrgDam;
    float fDelay;
    effect eDeath = SupernaturalEffect(EffectDeath(FALSE,TRUE));
    effect eBlindness = EffectBlindness();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eBlindness, eDur);
    effect eExplode = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    effect eHitVis = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_FIRE);
    effect eLOS = EffectVisualEffect(VFX_FNF_LOS_HOLY_30);

    //Limit Caster level for the purposes of damage
    if (nCasterLvl > spell.DamageCap)
    {
        nCasterLvl = spell.DamageCap;
    }

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Caster);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eLOS, spell.Loc);

    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay();//random delay so each target gets hit in different moment
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //This visual effect is applied to the target object not the location as above.  This visual effect
            //represents the flame that erupts on the target not on the ground.
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHitVis, oTarget);

            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                //Check if the target is an undead, ooze or plant
                nOrgDam = MaximizeOrEmpower(spell.Dice, nCasterLvl, spell.Meta);

                if(spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD) || spellsIsRacialType(oTarget, RACIAL_TYPE_OOZE) ||
                   FindSubString(GetStringLowerCase(GetSubRace(oTarget)),"plant") > -1                              ||
                   GetAppearanceType(oTarget) == APPEARANCE_TYPE_VAMPIRE_MALE                                       ||
                   GetAppearanceType(oTarget) == APPEARANCE_TYPE_VAMPIRE_FEMALE                                     ||
                   GetStringLowerCase(GetSubRace(oTarget)) == "vampire")
                {
                    if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster, fDelay))
                    {
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eExplode, oTarget);
                        DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetCurrentHitPoints(oTarget) * 2), oTarget));
                    }
                    else
                    {
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eExplode, oTarget);
                        DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nOrgDam/2, spell.DamageType), oTarget));
                    }
                }
                else
                {
                    if(MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster, fDelay))
                    {
                        nOrgDam /= 2;
                    }
                    else
                    {
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, 6.0));
                    }
                    if (nOrgDam > 0)
                    {
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eExplode, oTarget));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nOrgDam, spell.DamageType), oTarget));
                    }
                }
            }
       }
       //Select the next target within the spell shape.
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    }
}


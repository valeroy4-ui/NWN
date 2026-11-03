//::///////////////////////////////////////////////
//:: Great Thunderclap
//:: X2_S0_GrtThdclp
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// You create a loud noise equivalent to a peal of
// thunder and its acommpanying shock wave. The
// spell has three effects. First, all creatures
// in the area must make Will saves to avoid being
// stunned for 1 round. Second, the creatures must
// make Fortitude saves or be deafened for 1 minute.
// Third, they must make Reflex saves or fall prone.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 20, 2002
//:: Updated On: Oct 20, 2003 - some nice Vfx:)
//:://////////////////////////////////////////////
/*
Patch 1.70

- was missing delay in saving throw VFX
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

int GTC_GetFocusCorrection(object oCaster)
{
    int nEngineFocus = 0;
    int nWantedFocus = 0;

    if (GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION, oCaster))
    {
        nEngineFocus = 2;
        nWantedFocus += 1;
    }

    if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION, oCaster))
    {
        nEngineFocus = 4;
        nWantedFocus += 2;
    }

    if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION, oCaster))
    {
        nEngineFocus = 6;
        nWantedFocus += 3;
    }

    // Integration/test flag for the glyph.
    if (GetLocalInt(oCaster, "GTC_GLYPH_EPIC") == 1)
        nWantedFocus = 6;

    return nWantedFocus - nEngineFocus;
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = 8.0;
    spell.SR = NO;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

        if (!GetIsObjectValid(spell.Item)
        && GetLastSpellCastClass() == CLASS_TYPE_SORCERER)
    {
        spell.DC += GTC_GetFocusCorrection(spell.Caster);
    }

    int nEngineDC = GetSpellSaveDC();

    if (GetIsPC(spell.Caster))
    {
        SendMessageToPC(spell.Caster,
            "Great Thunderclap: EngineDC="
            + IntToString(nEngineDC)
            + " FinalDC=" + IntToString(spell.DC));
    }

    int nDamage = 0;
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_MYSTICAL_EXPLOSION);
    effect eVis  = EffectVisualEffect(VFX_IMP_SONIC);
    effect eVis2 = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    effect eVis3 = EffectVisualEffect(VFX_IMP_STUN);
    effect eDeaf = EffectDeaf();
    effect eKnock = EffectKnockdown();
    effect eStun = EffectStunned();
    effect eShake = EffectVisualEffect(356);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spell.Loc);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShake, spell.Caster, 2.0);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(oTarget))
    {
        if(oTarget != spell.Caster && spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));

            //Get the distance between the explosion and the target to calculate delay
            fDelay = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget))/20;

            //1.72: this will do nothing by default, but allows to dynamically enforce spell resistance
            if (spell.SR != YES || !MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                if(!MySavingThrow(SAVING_THROW_FORT, oTarget, spell.DC, SAVING_THROW_TYPE_SONIC, spell.Caster, fDelay))
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDeaf, oTarget, RoundsToSeconds(10)));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
                }
                if(!MySavingThrow(SAVING_THROW_WILL, oTarget, spell.DC, SAVING_THROW_TYPE_SONIC, spell.Caster, fDelay))
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStun, oTarget, RoundsToSeconds(1)));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
                if(!MySavingThrow(SAVING_THROW_REFLEX, oTarget, spell.DC, SAVING_THROW_TYPE_SONIC, spell.Caster, fDelay))
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnock, oTarget, 6.0));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis3, oTarget,4.0));
                }
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    }
}

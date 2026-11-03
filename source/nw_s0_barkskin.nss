//::///////////////////////////////////////////////
//:: [Barkskin]
//:: [NW_S0_BarkSkin.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
   Enhances the casters Natural AC by an amount
   dependant on the caster's level.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 21, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 5, 2001
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 20, 2001

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_spellhook"
#include "_inc_runes"

void main()
{

/*
  Spellcast Hook Code
  Added 2003-06-23 by GeorgZ
  If you want to make changes to all spells,
  check x2_inc_spellhook.nss to find out more

*/

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook


    //Declare major variables
    spellsDeclareMajorVariables();

    int nBonus;
    float fDuration = HoursToSeconds(spell.Level);
    effect eVis     = EffectVisualEffect(HGVFX_DUR_IOUNSTONE_PALE_GREEN);
    effect eHead    = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eAC;

    if (spell.Meta == METAMAGIC_EXTEND) //Duration is +100%
        fDuration *= 2;

    if (spell.Level <= 6)
        nBonus = 3;
    else
    {
        if (spell.Level <= 14)
            nBonus = 4;
        else
            nBonus = 5;
    }
    if(!GetIsObjectValid(spell.Item))
    {
        if(GetHasFeat(FEAT_PROTECTION_DOMAIN_POWER, spell.Caster) && spell.Class == CLASS_TYPE_CLERIC)
        {
            if(spell.Level > 29)      nBonus = 7;
            else if(spell.Level > 19) nBonus = 6;
        }
    }

    eAC = EffectACIncrease(nBonus, AC_NATURAL_BONUS);
    effect eLink = EffectLinkEffects(eVis, eAC);
    eLink = EffectLinkEffects(eLink, eDur);

    int bMassEffect = GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_MASS_CAST, RUNE_SPELL_MASS_CAST_BARK_SKIN) && !GetIsObjectValid(spell.Item);

    if(bMassEffect)
    {
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        while(GetIsObjectValid(oTarget))
        {
            if(GetFactionEqual(oTarget, spell.Caster))
            {
                if(GetHitDice(oTarget) < 40)
                {
                    float fDelay = GetRandomDelay(0.4, 1.1);
                    //Fire cast spell at event for the specified target
                    SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

                    // recast spell
                    DelayCommand(fDelay*0.5, OnAreaSpellCast(spell.Caster, oTarget, spell.Id));

                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, fDuration));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHead, oTarget));
                }
            }
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        }
    }
    else
    {
        if(GetHitDice(spell.Target) < 40)
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHead, spell.Target);
        }
        else
        {
            SendColorMessageToPC(OBJECT_SELF, "Spell may only be used on characters below level 40.", TXT_COLOR_RED);
            return;
        }
    }
}


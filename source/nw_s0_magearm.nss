//::///////////////////////////////////////////////
//:: Mage Armor
//:: [NW_S0_MageArm.nss]
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_spellhook"
#include "_inc_runes"

void main()
{

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

// End of Spell Cast Hook

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    int nAC = 1;
    int nVFX = VFX_IMP_AC_BONUS;

    if(!GetIsObjectValid(GetSpellCastItem()))
    {
        if(GetHasFeat(FEAT_PROTECTION_DOMAIN_POWER) && spell.Class == CLASS_TYPE_CLERIC)
        {
            if(spell.Level > 29)
            {
                nAC = 3;
                nVFX = GAOVFX_IMP_AC_BONUS_RED;
            }
            else if(spell.Level > 19)
            {
                nAC = 2;
                nVFX = GAOVFX_IMP_AC_BONUS_RED;
            }
        }
        else if(spell.Class == CLASS_TYPE_SORCERER)
        {
            nAC = 2;
            nVFX = GAOVFX_IMP_AC_BONUS_BLUE;
        }
    }

    if (spell.Meta & METAMAGIC_EXTEND) nDuration *= 2;

    effect eVis = EffectVisualEffect(nVFX);
    effect eAC = EffectACIncrease(nAC);
    effect eDur = EffectLinkEffects(EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE), eAC);
    eDur = EffectLinkEffects(EffectIcon(EFFECT_ICON_MAGE_ARMOR), HideEffectIcon(eDur));

    int bMassEffect = GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_MASS_CAST, RUNE_SPELL_MASS_CAST_MAGE_ARMOR) && !GetIsObjectValid(spell.Item);

    if(bMassEffect)
    {
        object oLoop = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        while(GetIsObjectValid(oLoop))
        {
            if(GetFactionEqual(oLoop, spell.Caster))
            {
                float fDelay = GetRandomDelay(0.4, 1.1);
                // rebuff
                DelayCommand(fDelay * 0.5, OnAreaSpellCast(spell.Caster, oLoop, spell.Id));

                SignalEvent(oLoop, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oLoop, HoursToSeconds(nDuration)));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oLoop));
            }
            oLoop = GetNextObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
        }
    }
    else
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spell.Target, HoursToSeconds(nDuration));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    }
}


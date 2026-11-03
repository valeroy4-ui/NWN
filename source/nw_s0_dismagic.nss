//::///////////////////////////////////////////////
//:: Dispel Magic
//:: NW_S0_DisMagic.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: Attempts to dispel all magic on a targeted
//:: object, or simply the most powerful that it
//:: can on every object in an area if no target
//:: specified.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:: Updated On: Oct 20, 2003, Georg Zoeller
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_dispel"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    //spell.Range = RADIUS_SIZE_LARGE;
    //spell.SR = NO;
    //spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    if(GetIsObjectValid(spell.Target))
        dispel_DispelTarget(spell.Caster, spell.Target, spell.Id);
    else
        dispel_DispelAOETarget(spell.Loc, spell.Id);
}

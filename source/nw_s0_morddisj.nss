//::///////////////////////////////////////////////
//:: Mordenkainen's Disjunction
//:: NW_S0_MordDisj.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Massive Dispel Magic and Spell Breach rolled into one
    If the target is a general area of effect they lose
    6 spell protections.  If it is an area of effect everyone
    in the area loses 2 spells protections.
*/
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
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }


    //Declare major variables
    spellsDeclareMajorVariables();

    if (GetIsObjectValid(spell.Target))
        dispel_DispelTarget(spell.Caster, spell.Target, spell.Id);
    else
        dispel_DispelAOETarget(spell.Loc, spell.Id);
}

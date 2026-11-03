//::///////////////////////////////////////////////
//:: Greater Dispelling
//:: NW_S0_GrDispel.nss
//:: Copyright (c) 2001 Bioware Corp.
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
    {
        dispel_DispelTarget(spell.Caster, spell.Target, spell.Id);
    }
    else
    {
        dispel_DispelAOETarget(spell.Loc, spell.Id);
    }
}

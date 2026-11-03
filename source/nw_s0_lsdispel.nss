//::///////////////////////////////////////////////
//:: Lesser Dispel
//:: NW_S0_LsDispel.nss
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
    //1.72: pre-declare some of the spell informations to be able to process them
    //spell.Range = RADIUS_SIZE_LARGE;
    //spell.SR = NO;
    //spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

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

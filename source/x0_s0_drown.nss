//::///////////////////////////////////////////////
//:: Drown
//:: [X0_S0_Drown.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    if the creature fails a FORT throw.
    Does not work against Undead, Constructs, or Elementals.

January 2003:
 - Changed to instant kill the target.
May 2003:
 - Changed damage to 90% of current HP, instead of instant kill.

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 26 2002
//:://////////////////////////////////////////////
//:: Last Update By: Andrew Nobbs May 01, 2003
/*
Patch 1.70

- won't affect wrong target at all (previously could still took spell mantle)
- added additional creatures being immune: oozes and various creatures of water
or aquatic subtype
- added immunity feedback to caster in case the target is immune
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

const float SPELL_DROWN_TICK_INTERVAL       = 4.5;
const int SPELL_DROWN_TICK_NUMBER           = 3;

void main()
{
    if (!X2PreSpellCastCode())
    {
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    if (GetHasSpellEffect(spell.Id, spell.Target))
    {
        FloatingColorTextStringOnCreature("The target is already under the effect of this spell!", TXT_COLOR_RED, spell.Caster, FALSE);
        return;
    }

    string sSpellData = IntToString(spell.DC);

    effect eDrown = EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", SPELL_DROWN_TICK_INTERVAL, sSpellData);
    eDrown = EffectLinkEffects(EffectIcon(EFFECT_ICON_SPELL_DROWN), eDrown);
    float fDuration = SPELL_DROWN_TICK_INTERVAL * (SPELL_DROWN_TICK_NUMBER - 1) + 1.0;

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

    //Make SR Check
    if(!MyResistSpell(spell.Caster, spell.Target))
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
                            ExtraordinaryEffect(eDrown),
                            spell.Target,
                            fDuration);
    }
}

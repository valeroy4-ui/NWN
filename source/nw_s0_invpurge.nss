//::///////////////////////////////////////////////
//:: Invisibility Purge
//:: NW_S0_InvPurge.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All invisible creatures become invisible in the
    area of effect even if they leave the AOE.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- disabled aura stacking
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_MOB_INVISIBILITY_PURGE);
    int nDuration = spell.Level;
    effect eDur1 = EffectVisualEffect(VFX_DUR_MAGICAL_SIGHT);
    effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eDur1, eDur2);

    //Check Extend metamagic feat.
    if (spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration *2;    //Duration is +100%
    }

    //prevent stacking
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spell.Target, DurationToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    spellsSetupNewAOE(AOE_MOB_INVISIBILITY_PURGE);

    if (GetIsPC(spell.Caster) && FindSubString(GetStringLowerCase(GetName(spell.Caster)), "[test]") >= 0)
    {
        SetLocalObject(GetModule(), "IP265_LAST_CASTER", spell.Caster);
        string s = "[IP265] CL=" + IntToString(spell.Level) + " class=" + IntToString(spell.Class)
            + " duration=" + FloatToString(DurationToSeconds(nDuration), 0, 2)
            + " radius=" + FloatToString(GetAreaOfEffectRadius(AOE_MOB_INVISIBILITY_PURGE), 0, 2)
            + " meta=" + IntToString(spell.Meta);
        WriteTimestampedLogEntry(s);
        SendMessageToPC(spell.Caster, s);
    }
}

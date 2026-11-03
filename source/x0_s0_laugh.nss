//::///////////////////////////////////////////////
//:: Tasha's Hideous Laughter
//:: [x0_s0_laugh.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Target is held, laughing for the duration
    of the spell (1d3 rounds)

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 6, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- alignment immune creatures were ommited
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_colortext"
#include "_inc_spells"
#include "nwnx_util"


void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    // Declare major variables
    spellsDeclareMajorVariables();

    // don't tasha under TS
    if (GetLocalInt(GetArea(spell.Caster), "TIMESTOP_IN_AREA"))
    {
        FloatingColorTextStringOnCreature("You can`t cast Tasha's Hideous Laughter during TimeStop.", TXT_COLOR_RED, spell.Caster);
        return;
    }
    // no item casts
    object oItemOwner = GetItemPossessor(spell.Item);
    if (GetIsObjectValid(oItemOwner))
    {
        SendColorMessageToPC(oItemOwner, "You aren`t allowed to cast this spell from item.", TXT_COLOR_RED);
        return;
    }
    // check target's CD
    if(spells_GetHasSpellCooldown(spell.Id, spell.Target, CORMYR_SPELL_COOLDOWN_TARGET))
    {
        SendColorMessageToPC(spell.Caster, "Target is still laughing :-)", TXT_COLOR_RED);
        return;
    }

    effect eVis = EffectVisualEffect(VFX_IMP_WILL_SAVING_THROW_USE);

    int nDuration = d3();
    int nModifier = 0;

    // * creatures of different race find different things funny
    if (GetRacialType(spell.Target) != GetRacialType(spell.Caster))
        nModifier = 4;

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

        if (!spellsIsMindless(spell.Target))
        {
            if (!MyResistSpell(spell.Caster, spell.Target))
            {
                // tasha 2025
                string sEffectTag = GetObjectUUID(spell.Caster) + "_" + IntToString(SPELL_TASHAS_HIDEOUS_LAUGHTER);
                int bKnoked = FALSE;
                if(!GetIsImmune(spell.Target, IMMUNITY_TYPE_MIND_SPELLS) && GetHasEffectWithSpecificTag(spell.Target, sEffectTag))
                {
                    if(GetHasSpellEffect(SPELL_PROTECTION_FROM_GOOD, spell.Target))
                        RemoveSpellEffects(SPELL_PROTECTION_FROM_GOOD, spell.Caster, spell.Target);
                    if(GetHasSpellEffect(SPELL_PROTECTION_FROM_EVIL, spell.Target))
                        RemoveSpellEffects(SPELL_PROTECTION_FROM_EVIL, spell.Caster, spell.Target);
                    bKnoked = TRUE;
                }
                else if(!GetIsImmune(spell.Target, IMMUNITY_TYPE_MIND_SPELLS, spell.Caster) &&
                        !MySavingThrow(spell.SavingThrow, spell.Target, spell.DC-nModifier, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
                    bKnoked = TRUE;
                else
                    FloatingColorTextStringOnCreature("Fail!", TXT_COLOR_RED, spell.Caster);
                if(bKnoked)
                {
                    effect eDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
                    float fDur = DurationToSeconds(nDuration);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spell.Target, fDur);
                    AssignCommand(spell.Target, ClearAllActions());
                    AssignCommand(spell.Target, PlayVoiceChat(VOICE_CHAT_LAUGH));
                    AssignCommand(spell.Target, ActionPlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING));
                    effect eLaugh = EffectKnockdown();
                    eLaugh = ExtraordinaryEffect(eLaugh);
                    DelayCommand(0.3, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLaugh, spell.Target, fDur));
                    FloatingColorTextStringOnCreature("Knocked down!", TXT_COLOR_RED, spell.Target, TRUE);
                    FloatingColorTextStringOnCreature("Target fell about laughing!", TXT_COLOR_GREEN_L, spell.Caster);
                    spells_SetSpellCooldown(spell.Id, spell.Target, GetSpellTimeoutDuration(spell.Id), CORMYR_SPELL_COOLDOWN_DONT_SHOW_MESSAGES, CORMYR_SPELL_COOLDOWN_TARGET);
                }
            }
        }
    }
}


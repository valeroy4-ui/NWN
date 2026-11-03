//::///////////////////////////////////////////////
//:: Word of Faith
//:: [NW_S0_WordFaith.nss]
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A 30ft blast of divine energy rushs out from the
    Cleric blasting all enemies with varying effects
    depending on their HD.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 5, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: Sep 2002: fixed the 'level 8' instantkill problem
//:: description is slightly inaccurate but I won't change it
//:: Georg: It's nerf time! oh yes. The spell now matches it's description.

#include "70_inc_spells"
#include "_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    effect eBlind       = EffectBlindness();
    effect eStun        = EffectStunned();
    effect eConfuse     = EffectConfused();
    effect eVis         = EffectVisualEffect(VFX_IMP_DEATH);
    effect eSmite       = EffectVisualEffect(VFX_FNF_WORD);
    effect eSonic       = EffectVisualEffect(VFX_IMP_SONIC);
    effect eUnsummon    = EffectVisualEffect(VFX_IMP_UNSUMMON);
    effect eMind        = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink;
    effect eKill;
    int nHD;
    float fDelay;
    int nDuration = spell.Level / 2;

    int bWithoutSavingThrow = FALSE;
    if (!GetIsObjectValid(spell.Item))
    {
        if (GetHasFeat(FEAT_MAGIC_DOMAIN_POWER, spell.Caster) && spell.Class == CLASS_TYPE_CLERIC)
        {
            eSmite = EffectVisualEffect(HGVFX_FNF_WORD_CN);
            bWithoutSavingThrow = TRUE;
        }
    }

    int bTimeOut = FALSE;
    // Apply the FNF VFX impact to the target location
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eSmite, spell.Loc);
    // Get the first target in the spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    while (GetIsObjectValid(oTarget))
    {
        // Make a faction check
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay(0.5, 0.5);
            // Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            // Make SR check
            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                ///----------------------------------------------------------
                // And this is the part where the divine power smashes the
                // unholy summoned creature and makes it return to its homeplane
                //----------------------------------------------------------
                if (GetIsObjectValid(GetMaster(oTarget)))
                {
                    if (GetAssociateType(oTarget) == ASSOCIATE_TYPE_SUMMONED)
                    {
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eUnsummon, oTarget));
                        eKill = EffectDeath(TRUE);
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, oTarget));
                    }
                }
                else if(!spells_GetHasSpellCooldown(spell.Id, oTarget, CORMYR_SPELL_COOLDOWN_TARGET))
                {
                    if (bWithoutSavingThrow || !MySavingThrow(spell.SavingThrow, oTarget, spell.DC))
                    {
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eSonic, oTarget);
                        eLink = EffectLinkEffects(eLink, eDur);
                        eLink = EffectLinkEffects(eLink, eBlind);
                        if (GetIsPC(oTarget))
                            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration)));
                        else
                            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(3)));

                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_BLIND_DEAF_M), oTarget));
                        if(GetIsPC(oTarget) && GetIsPC(spell.Caster))
                            spells_SetSpellCooldown(spell.Id, oTarget, 30.0, CORMYR_SPELL_COOLDOWN_DONT_SHOW_MESSAGES, CORMYR_SPELL_COOLDOWN_TARGET, EFFECT_ICON_WOF_IMMUNITY);
                    }
                }
                else    // add spell immunity globe use visual effect
                    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GLOBE_USE), oTarget));
            }
        }
        // Get the next target in the spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    }
}



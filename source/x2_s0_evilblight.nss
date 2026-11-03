#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_champ_boss"
#include "_inc_fshop_bg"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    int bRadiusUpgrade = fshop_bg_GetIsBitActivated(OBJECT_SELF, FAMESHOP_BG_EVIL_BLIGHT_BONUS_RADIUS_1) > 0;

    spell.Range = RADIUS_SIZE_COLOSSAL + bRadiusUpgrade * RADIUS_SIZE_COLOSSAL;

    if (!X2PreSpellCastCode()) return;

    //Declare major variables
    spellsDeclareMajorVariables();

    effect eImpact = EffectVisualEffect(SHADVFX_IMP_REDUCE_ABILITY_SCORE_RED);
    effect eVis = EffectVisualEffect(PRCVFX_FNF_MASS_INFLICT, FALSE, 3.5 + 3.5 * bRadiusUpgrade);
    effect eEvilBlightTarget = EffectIcon(EFFECT_ICON_EVIL_BLIGHT_TARGET);
    effect eEvilBlightSelf   = EffectLinkEffects(EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", BG_EVIL_BLIGHT_TICK_INTERVAL_SEC),
                                                 EffectIcon(EFFECT_ICON_EVIL_BLIGHT_SELF));

    //spells_RemoveAllCreatorsEffects(spell.Caster, spell.Caster, SPELL_DD_KINGS_POWER);
    //spells_RemoveAllCreatorsEffects(spell.Caster, spell.Caster, SPELL_DD_LEGACY);
    //spells_RemoveAllCreatorsEffects(spell.Caster, spell.Caster, SPELL_DD_DEFENCE);
    //spells_RemoveAllCreatorsEffects(spell.Caster, spell.Caster, spell.Id);

    object oTarget = GetFirstPC();
    while(GetIsObjectValid(oTarget))
    {
        spells_RemoveAllCreatorsEffects(oTarget, spell.Caster, SPELL_WARLORD_FURY);
        spells_RemoveAllCreatorsEffects(oTarget, spell.Caster, SPELL_BATTLEFIELD_ECHO);
        spells_RemoveAllCreatorsEffects(oTarget, spell.Caster, SPELL_WARLORD_GUARD);
        spells_RemoveAllCreatorsEffects(oTarget, spell.Caster, SPELL_EVIL_BLIGHT);
        oTarget = GetNextPC();
    }

    // apply caster vis and runscript effect
    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Caster));
    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eEvilBlightSelf), spell.Caster, DURATION_SERVER_SESSION));
    //spells_SetSpellCooldown(spell.Id, spell.Caster, GetSpellTimeoutDuration(spell.Id) - 60.0 * ((fshop_bg_GetIsBitActivated(spell.Caster, FAMESHOP_BG_EVIL_BLIGHT_BONUS_CD_1) > 0) +
    //                                                                                     (fshop_bg_GetIsBitActivated(spell.Caster, FAMESHOP_BG_EVIL_BLIGHT_BONUS_CD_2) > 0)));

    // get first target in the area of effect
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        //Check faction of oTarget
        if(GetIsPC(oTarget) && !players_GetFactionsEqual(oTarget, spell.Caster) || champion_GetIsBoss(oTarget) || players_IsTestCharacter(oTarget) && oTarget != spell.Caster)
        {
            // calculate range based delay
            float fDelay = GetDelayByRange(0.5, 1.5, GetDistanceBetween(oTarget, spell.Caster), spell.Range);
            //Signal spell cast at event
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            // remove all creators spell effects
            //spells_RemoveAllCreatorsEffects(oTarget, spell.Caster, spell.Id);
            // apply new effect
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEvilBlightTarget, oTarget, DURATION_SERVER_SESSION));
        }
        //Get next spell target
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}

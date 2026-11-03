//::///////////////////////////////////////////////
//:: Inferno
//:: x0_s0_inferno.nss
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
30.05.2021 Cormyr Edition spell by ud4ever

*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_fshop_spell"

const float SPELL_INFERNO_TICK_INTERVAL         = 4.5;
const int SPELL_INFERNO_TICK_NUMBER             = 3;

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

    float fCriticalChance = 0.0;
    float fCriticalMultiplier = 0.0;
    switch(GetSpellUpgradeLevel(spell.Caster, spell.Id))
    {
        case 1:
            fCriticalChance = 0.15; // 15%
            fCriticalMultiplier = 1.25; // 125%
        break;
        case 2:
            fCriticalChance = 0.25; // 25%
            fCriticalMultiplier = 1.5; // 150%
        break;
        case 3:
            fCriticalChance = 0.35; // 35%
            fCriticalMultiplier = 1.75; // 175%
        break;
    }

    int nCaterLevel = spell.Level + GetLevelByClass(CLASS_TYPE_ARCHMAGE, spell.Caster);
    int nInfernoBaseMultiplier = nCaterLevel / 10;

    string sSpellData = IntToString(nInfernoBaseMultiplier) + "|" + // base multiplier
                        IntToString(GetAbilityModifier(ABILITY_WISDOM, spell.Caster)) + "|" + // ability modifier
                        FloatToString(fCriticalChance) + "|" + // critical chance
                        FloatToString(fCriticalMultiplier); // critical multiplier

    effect eInferno = EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", SPELL_INFERNO_TICK_INTERVAL, sSpellData);
    eInferno = EffectLinkEffects(EffectIcon(EFFECT_ICON_SPELL_INFERNO), eInferno);
    float fDuration = SPELL_INFERNO_TICK_INTERVAL * (SPELL_INFERNO_TICK_NUMBER - 1) + 1.0;

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

    //Make SR Check
    if(!MyResistSpell(spell.Caster, spell.Target) && !spells_GetHasSpellCooldown(spell.Id, spell.Target, CORMYR_SPELL_COOLDOWN_TARGET))
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,
                            ExtraordinaryEffect(eInferno),
                            spell.Target,
                            fDuration);
        // SetSpellCooldown(spell.Id, spell.Caster, GetSpellTimeoutDuration(spell.Id));
        if(GetIsPC(spell.Target))
            spells_SetSpellCooldown(spell.Id, spell.Target, 30.0, CORMYR_SPELL_COOLDOWN_DONT_SHOW_MESSAGES, CORMYR_SPELL_COOLDOWN_TARGET);
    }
    else if(spells_GetHasSpellCooldown(spell.Id, spell.Target, CORMYR_SPELL_COOLDOWN_TARGET))  // add spell immunity globe use visual effect
        DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GLOBE_USE), spell.Target));
}

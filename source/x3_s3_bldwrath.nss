#include "70_inc_spells"
#include "_inc_generic"
#include "_inc_runes"

void main()
{
    //Declare major variables
    spellsDeclareMajorVariables();

    // calc parameters
    int nAB = spell.Level / 5 + runes_GetHasRune(spell.Caster, RUNE_TYPE_EPIC_SPELLS, RUNE_EPIC_SPELLS_DIVINE_NATURE_II);
    int nDamage = spell.Level / 3;
    int nDuration = 2 * spell.Level;

    // debug
    if(GetPCIPAddress(spell.Caster) == "192.168.128.100" /* debug */)
    {
        nDuration *= 3;
    }
    //

    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    // determine effects
    effect eVis = EffectVisualEffect(SHADVFX_IMP_HOLY_AID_BLUE);
    effect eAttack = EffectAttackIncrease(nAB);
    effect eDamage = EffectDamageIncrease(GetDamageBonusConstantFromNumber(nDamage), DAMAGE_TYPE_MAGICAL);
    effect eLink = EffectLinkEffects(eAttack, eDamage);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(EffectIcon(EFFECT_ICON_BLADE_OF_WRATH), HideEffectIcon(eLink));

    if (spell.Meta == METAMAGIC_EXTEND)
        nDuration = nDuration * 2;

    //Fire spell cast at event for target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Apply VFX impact and bonus effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Caster);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Caster, DurationToSeconds(nDuration));
    SendColorMessageToPC(spell.Caster, "+" + IntToString(nAB) + " Attack Bonus.", TXT_COLOR_GREEN_L);
    SendColorMessageToPC(spell.Caster, "+" + IntToString(nDamage) + " Damage Bonus.", TXT_COLOR_GREEN_L);
}


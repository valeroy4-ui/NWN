#include "_inc_spells"

void main()
{
    object oItem = GetItemActivated();
    object oActivator = GetItemActivator();

    int iResist = 300;
    effect eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_ACID, iResist), EffectDamageImmunityDecrease(DAMAGE_TYPE_BLUDGEONING, iResist));
    eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_COLD, iResist), eVaseline);
    eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_DIVINE, iResist), eVaseline);
    eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_ELECTRICAL, iResist), eVaseline);
    eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_FIRE, iResist), eVaseline);
    eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_MAGICAL, iResist), eVaseline);
    eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_NEGATIVE, iResist), eVaseline);
    eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_SLASHING, iResist), eVaseline);
    eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_PIERCING, iResist), eVaseline);
    eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_POSITIVE, iResist), eVaseline);
    eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_SLASHING, iResist), eVaseline);
    eVaseline = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_SONIC, iResist), eVaseline);
    eVaseline = EffectLinkEffects(EffectIcon(EFFECT_ICON_VASELINE), HideEffectIcon(eVaseline));

    eVaseline = SetEffectSpellId(eVaseline, SPELL_VASELINE_POTION);

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, UnyieldingEffect(eVaseline), oActivator, 30.0);
    FloatingColorTextStringOnCreature("Perfectly vaselined!", TXT_COLOR_GREEN_L, oActivator, TRUE);
}

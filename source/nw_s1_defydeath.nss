#include "_inc_pulse_rage"

void main()
{
    // determine effects
    effect eDefyDeath = EffectIcon(EFFECT_ICON_DEFY_DEATH);
    int nMaxHeal = GetMaxHitPoints(OBJECT_SELF) - GetCurrentHitPoints(OBJECT_SELF);
    int nHeal = (GetAbilityModifier(ABILITY_STRENGTH) - GetAbilityModifier(ABILITY_DEXTERITY)) *
                (GetLevelByClass(CLASS_TYPE_BARBARIAN) + GetLevelByClass(CLASS_TYPE_DRAGONDISCIPLE) + GetLevelByClass(CLASS_TYPE_PALE_MASTER));
    nHeal = nHeal > nMaxHeal ? nMaxHeal : nHeal;
    nHeal = nHeal > 0 ? nHeal : 0;
    effect eHeal = EffectHeal(nHeal);
    // Fire cast spell at event for the specified target
    SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, SPELL_BARBARIAN_DEFY_DEATH, FALSE));
    // apply effect and visual
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eDefyDeath), OBJECT_SELF, GetSpellTimeoutDuration(SPELL_BARBARIAN_DEFY_DEATH));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(HUGVFX_FNF_SUMMON_EPIC_UNDEAD_PURPLE), OBJECT_SELF);
}

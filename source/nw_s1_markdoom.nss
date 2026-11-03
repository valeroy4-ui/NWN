#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "_inc_players"
#include "_inc_spells"
#include "_inc_generic"
#include "_inc_fshop_bg"

void main()
{
    if (!X2PreSpellCastCode()) return;

    //Declare major variables
    spellsDeclareMajorVariables();

    DeleteLocalInt(spell.Target, "MARK_OF_DOOM_COUNT_" + ObjectToString(spell.Caster));

    if(!GetIsPC(spell.Target) || players_GetFactionsEqual(spell.Target, spell.Caster))
    {
        FloatingColorTextStringOnCreature("The target must be a player of another faction.", TXT_COLOR_RED, spell.Caster, FALSE);
        return;
    }
    float fCooldown = GetSpellTimeoutDuration(spell.Id) - (18.0 * (fshop_bg_GetIsBitActivated(spell.Caster, FAMESHOP_BG_MARK_OF_DOOM_CD_1_3ROUNDS) > 0) +
                                                           18.0 * (fshop_bg_GetIsBitActivated(spell.Caster, FAMESHOP_BG_MARK_OF_DOOM_CD_2_3ROUNDS) > 0) +
                                                           12.0 * (fshop_bg_GetIsBitActivated(spell.Caster, FAMESHOP_BG_MARK_OF_DOOM_CD_3_2ROUNDS) > 0));
    spells_SetSpellCooldown(spell.Id, spell.Caster, fCooldown);

    effect eMark = EffectIcon(EFFECT_ICON_MARK_OF_DOOM);

    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DESTRUCTION_LOW), spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eMark), spell.Target, DURATION_SERVER_SESSION);
}

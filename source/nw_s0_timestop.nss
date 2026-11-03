#include "x2_inc_spellhook"
#include "70_inc_spells"
#include "nw_i0_spells"
#include "_inc_spells"

void main()
{
    if(!X2PreSpellCastCode()) return;

    spellsDeclareMajorVariables();

    object oModule = GetModule();
    object oArea = GetArea(spell.Caster);

    // no items/scrolls cast
    if (GetIsPC(spell.Caster) && GetIsObjectValid(spell.Item))
        return;

    // Fire cast spell at event for the specified target
    SignalEvent(spell.Caster, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    // timestop duration
    float fDuration = 12.0;

    if(GetPCIPAddress(spell.Caster) == "192.168.128.100")
        DelayCommand(11.0, FloatingTextStringOnCreature(ColorText("Dice!", TXT_COLOR_WHITE_T), spell.Caster, FALSE));

    // area local vars     ==>
    SetLocalInt(oArea, "TIMESTOP_IN_AREA", TRUE);
    SetLocalObject(oArea, "TIMESTOP_CASTER", spell.Caster);
    AssignCommand(oModule, DelayCommand(fDuration + 0.5, DeleteLocalInt(oArea, "TIMESTOP_IN_AREA")));
    AssignCommand(oModule, DelayCommand(fDuration + 0.5, DeleteLocalObject(oArea, "TIMESTOP_CASTER")));
    // end area local vars <==

    location lTSLocation = GetLocation(spell.Caster);

    DelayCommand(0.5, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_TIME_STOP), lTSLocation));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(PRCVFX_DUR_TEMPORAL_ACCELERATION), spell.Caster, fDuration + 0.5);

    effect eEff = EffectTimeStopCustom();

    object oTarget = GetFirstObjectInArea(oArea, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != spell.Caster && !GetIsDM(oTarget) && !GetIsDead(oTarget))
        {
            if(GetIsPC(oTarget))
                DelayCommand(0.5, FloatingColorTextStringOnCreature("Timestop!", TXT_COLOR_WHITE_T, oTarget, FALSE));
            DelayCommand(GetRandomDelay(0.01, 0.25), ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SLOW), oTarget));
            AssignCommand(oTarget, DelayCommand(0.5, ClearAllActions()));
            DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEff, oTarget, fDuration));
            DelayCommand(0.5, SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE)));
        }
        oTarget = GetNextObjectInArea(oArea, OBJECT_TYPE_CREATURE);
    }
}


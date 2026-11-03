#include "x0_i0_spells"
#include "_inc_spells"
#include "_inc_constants"

void DukeWarCry()
{
    PlayVoiceChat(Random(4));
    float fDur = 60.0;

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_PDK_RALLYING_CRY), OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_HOWL_WAR_CRY), OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(EffectVisualEffect(1906)), OBJECT_SELF, fDur);

    effect eEff = EffectACDecrease(6 + Random(3), AC_NATURAL_BONUS);
    float fDelay;
    location lLoc = GetLocation(OBJECT_SELF);
    object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, 7.0, lLoc);
    while(GetIsObjectValid(oCreature))
    {
        if(GetIsEnemy(oCreature))
        {
            fDelay = GetRandomDelay(0.3, 0.9);
            eEff = EffectLinkEffects(EffectAttackDecrease(4 + Random(3)), eEff);
            eEff = SetEffectSpellId(eEff, SPELL_DUKE_WARCRY);
            eEff = SupernaturalEffect(eEff);

            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEff, oCreature, fDur));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_IMP_HEAD_SONIC), oCreature));
        }
        oCreature = GetNextObjectInShape(SHAPE_SPHERE, 7.0, lLoc);
    }
}

void main()
{
    if(GetIsInCombat(OBJECT_SELF) && !GetLocalInt(OBJECT_SELF, "DukeWarCryUsed") && GetCurrentHitPoints() < (GetMaxHitPoints() / 2))
    {
        DukeWarCry();
        SetLocalInt(OBJECT_SELF, "DukeWarCryUsed", TRUE);
        DelayCommand(60.0, DeleteLocalInt(OBJECT_SELF, "DukeWarCryUsed"));
    }
    ExecuteScript("ai_boss_onheart", OBJECT_SELF);
}

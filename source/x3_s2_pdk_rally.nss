//::///////////////////////////////////////////////
//:: Purple Dragon Knight - Rallying Cry
//:: x3_s2_pdk_rally.nss
//:://////////////////////////////////////////////
//:: Increase attack & movement for friends in
//:: area of spell
//:://////////////////////////////////////////////
//:: Created By: Stratovarius
//:: Created On: Sept 22, 2005
//:://////////////////////////////////////////////

#include "x0_i0_spells"
#include "nwnx_creature"

void main()
{
    object oPDK = OBJECT_SELF;
    NWNX_Creature_SetFeatRemainingUses(oPDK, FEAT_PDK_RALLY, 1);
    int iMod = GetAbilityModifier(ABILITY_CHARISMA, oPDK);
    int iLvl = GetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT, oPDK);
    int iSpellID = GetSpellId();
    effect eAB = EffectAttackIncrease(2);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    //int iDuration = iMod * iLvl;
    int iDuration = 10 * iLvl;
    float fDelay;

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_PDK_RALLYING_CRY), oPDK);
    DelayCommand(0.8, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_PDK_GENERIC_PULSE), oPDK));

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(oPDK));
    while(GetIsObjectValid(oTarget))
    {
        if(GetFactionEqual(oPDK, oTarget))
        {
            if(GetHasSpellEffect(iSpellID, oTarget))
            {
                RemoveEffectsFromSpell(oTarget, iSpellID);
            }
            fDelay = GetRandomDelay(0.4, 1.1);
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(eAB), oTarget, IntToFloat(iDuration));
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(oPDK));
    }
}

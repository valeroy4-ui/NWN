#include "nwnx_creature"
#include "nwnx_admin"
#include "nwnx_weapon"
#include "_inc_feat2skin"
#include "nwnx_rename"
#include "_inc_players"
#include "_inc_generic"

void main()
{
    object oPC = GetSpellTargetObject();
    //AssignCommand(oPC, ApplyEffectToObject(DURATION_TYPE_INSTANT, SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_SCALE, 1.00 + (IntToFloat(Random(50) + 1))/100);, oPC, 10.0));
    //SetObjectVisualTransform(oPC, OBJECT_VISUAL_TRANSFORM_SCALE, 1.0);
    //NWNX_Administration_ReloadRules();
    //NWNX_Weapon_SetWeaponFinesseSize(BASE_ITEM_TWOBLADEDSWORD, 3);
    //AddFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC,oPC);
    //DeleteLocalInt(oPC, "Destroyed");
    //AssignCommand(oPC, ActionCloseDoor(oPC));
    //DeleteLocalInt(oPC, "CURRENT_DAMAGE_AMOUNT");
    //    NWNX_Rename_SetPCNameOverride(oPC, GetFactionColor(GetFaction(oPC)) + "petyx" + TXT_COLOR_END,
    //                                  "", "", NWNX_RENAME_PLAYERNAME_DEFAULT);
    //generic_DestroyCreature(oPC);
    //RemoveEffectsFromSpell(oPC, SPELL_DEATH_WARD);
    effect eVis = EffectVisualEffect(HGVFX_DUR_MAGICAL_SIGHT_GREEN);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eSight = EffectSeeInvisible();
    effect eLink = EffectLinkEffects(eVis, eSight);
    eLink = EffectLinkEffects(eLink, eDur);
    int nDuration = 60;
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 150.0, GetLocation(OBJECT_SELF), FALSE);
        while(GetIsObjectValid(oTarget))
        {
                float fDelay = GetRandomDelay(0.4, 1.1);
                //Fire cast spell at event for the specified target
                //SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, spell.Id, FALSE));

                // recast
                //DelayCommand(fDelay*0.5, OnAreaSpellCast(spell.Caster, oTarget, spell.Id));

                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(nDuration)));
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, 150.0, GetLocation(OBJECT_SELF), FALSE);
        }

}

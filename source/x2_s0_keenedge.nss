//::///////////////////////////////////////////////
//:: Keen Edge
//:: X2_S0_KeenEdge
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////

#include "nw_i0_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_runes"

void AddKeenEffectToWeapon(object oMyWeapon, float fDuration)
{
   IPSafeAddItemProperty(oMyWeapon,ItemPropertyKeen(), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING ,TRUE,TRUE);
}

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    float fDuration = TurnsToSeconds(10 * spell.Level);
    if (spell.Meta & METAMAGIC_EXTEND) fDuration *= 2;


    if(GetObjectType(spell.Target) == OBJECT_TYPE_CREATURE)
    {
        object oMainWeapon;
        object oOffhandWeapon;
        int bMassEffect = GetIsPC(spell.Caster) && runes_GetHasRune(spell.Caster, RUNE_TYPE_MASS_CAST, RUNE_SPELL_MASS_CAST_KEEN_EDGE) && !GetIsObjectValid(spell.Item);
        if(bMassEffect)
        {
            object oLoop = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
            while(GetIsObjectValid(oLoop))
            {
                if(GetFactionEqual(oLoop, spell.Caster))
                {
                    oMainWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oLoop);
                    oMainWeapon = IPGetIsMeleeWeapon(oMainWeapon) ? oMainWeapon : OBJECT_INVALID;
                    oOffhandWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oLoop);
                    oOffhandWeapon = IPGetIsMeleeWeapon(oOffhandWeapon) ? oOffhandWeapon : OBJECT_INVALID;
                    if(GetIsObjectValid(oMainWeapon) || GetIsObjectValid(oOffhandWeapon))
                    {
                        SignalEvent(oLoop, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oLoop);
                        if(GetIsObjectValid(oMainWeapon))    AddKeenEffectToWeapon(oMainWeapon, fDuration);
                        if(GetIsObjectValid(oOffhandWeapon)) AddKeenEffectToWeapon(oOffhandWeapon, fDuration);
                    }
                }
                oLoop = GetNextObjectInShape(SHAPE_SPHERE, 5.0, spell.Loc, FALSE);
            }
        }
        else
        {
            oMainWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spell.Target);
            oMainWeapon = IPGetIsMeleeWeapon(oMainWeapon) ? oMainWeapon : OBJECT_INVALID;
            oOffhandWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spell.Target);
            oOffhandWeapon = IPGetIsMeleeWeapon(oOffhandWeapon) ? oOffhandWeapon : OBJECT_INVALID;
            if(GetIsObjectValid(oMainWeapon) || GetIsObjectValid(oOffhandWeapon))
            {
                SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                if(GetIsObjectValid(oMainWeapon))    AddKeenEffectToWeapon(oMainWeapon, fDuration);
                if(GetIsObjectValid(oOffhandWeapon)) AddKeenEffectToWeapon(oOffhandWeapon, fDuration);
            }
        }


    }
    else if(GetObjectType(spell.Target) == OBJECT_TYPE_ITEM)
    {
        SignalEvent(GetItemPossessor(spell.Target), EventSpellCastAt(spell.Caster, GetSpellId(), FALSE));
        if(IPGetIsMeleeWeapon(spell.Target))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, GetItemPossessor(spell.Target));
            AddKeenEffectToWeapon(spell.Target, fDuration);
        }
        else
        {
            FloatingTextStrRefOnCreature(83615, OBJECT_SELF);
        }
    }
}


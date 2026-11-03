//#include "nwnx_object"
#include "_inc_spells"
//#include "_inc_generic"
#include "_inc_death"

void main()
{
    object oPC = GetLastPCRested();

    object oBedrollGrnd;
    object oBedroll;
    object oMod = GetModule();

    if(GetIsDM(oPC))
        return;

    int nRest = GetLastRestEventType();
    if(nRest == REST_EVENTTYPE_REST_FINISHED)
    {
        RemoveEffectsAfterDeath(oPC);
        DelayCommand(0.1, ExecuteScript("_mod_instant_eff", oPC));
    }

    if(nRest == REST_EVENTTYPE_REST_STARTED)
    {
        object oFood = GetItemPossessedBy(oPC, "fl_food");
        if(GetIsObjectValid(oFood))
        {
            if(GetItemStackSize(oFood) > 1)
                SetItemStackSize(oFood, GetItemStackSize(oFood) - 1);
            else
                DestroyObject(oFood);
            FloatingTextStringOnCreature("You ate food", oPC, FALSE);
        }
        else
        {
            AssignCommand(oPC, ClearAllActions());
            SendMessageToPC(oPC, "You can't sleep hungry");
            return;
        }
        oBedroll = GetItemPossessedBy(oPC, CONST_ITEM_BEDROLL);
        if (GetIsObjectValid(oBedroll))
        {
            DestroyObject(oBedroll);
            oBedroll = CreateObject(OBJECT_TYPE_PLACEABLE, CONST_PLACEABLE_BEDROLL, GetLocation(oPC));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SLEEP), oPC);
            SetLocalObject(oPC, "Bedroll", oBedroll);
        }
        else
        {
            AssignCommand(oPC, ClearAllActions());
            SendMessageToPC(oPC, "You need a bedroll to sleep on the ground");
            oBedroll = GetLocalObject(oPC, "Bedroll");
            if (GetIsObjectValid(oBedroll))
            {
                DestroyObject(oBedroll);
                CreateItemOnObject(CONST_ITEM_BEDROLL, oPC);
                DeleteLocalObject(oPC, "Bedroll");
            }
            return;
        }
        // destroy AoE markers
        DestroyALLSpellMarkerPlacebles(oPC);
    }
    else
    {
        oBedroll = GetLocalObject(oPC, "Bedroll");
        if (GetIsObjectValid(oBedroll))
        {
            DestroyObject(oBedroll);
            CreateItemOnObject(CONST_ITEM_BEDROLL, oPC);
            DeleteLocalObject(oPC, "Bedroll");
        }
    }
}


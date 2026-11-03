#include "_inc_itemprop"
#include "_inc_generic"
#include "_inc_telegraph"
#include "_inc_array"

void UpdateShaderLerpTimer()
{
    int counter = GetMicrosecondCounter();

    object pc = GetFirstPC();
    while (pc != OBJECT_INVALID)
    {
        SetShaderUniformInt(pc, SHADER_UNIFORM_16, counter);
        pc = GetNextPC();
    }

    DelayCommand(1.0f / TARGET_FPS, UpdateShaderLerpTimer());
}



void main()
{
    object oPC = GetSpellTargetObject();
    location lLoc = GetSpellTargetLocation();
   //SetCreatureAppearanceType(oPC, GetRacialType(oPC));
    SetCreatureAppearanceType(oPC, 0);

    //AssignCommand(GetModule(), UpdateShaderLerpTimer());
    //ExecuteScript("_mod_despawn", oPC);
    //SpawnAngryOrbs(oPC, 6);
    //object oItem = CopyItem(ip_CreateStoredItem(164), oPC, TRUE);
    //NWNX_Item_SetBaseItemType(oPC, BASE_ITEM_ARMOR);
   //     ServerShout(IntToString(ip_GetAbilityBonus(oPC, -1)));
   //ip_ItemPropertyModifyAbility(oPC, ABILITY_CONSTITUTION, 11);
   //generic_InitEncounters();
}

void main()
{
    PrintString("[HC280 CHECK] READ ONLY; spell80 school="+Get2DAString("spells","School",80)
        +" range="+Get2DAString("spells","Range",80)+" radius2DA="+Get2DAString("spells","TargetSizeX",80));
    object pc=GetFirstPC();object target=GetObjectByTag("CT_SPELL_T7");
    while(GetIsObjectValid(pc))
    {
        if(!GetIsDM(pc))
        {
            PrintString("[HC280 CHECK] name="+GetName(pc)+" HP="+IntToString(GetCurrentHitPoints(pc))+"/"+IntToString(GetMaxHitPoints(pc))
                +" Bard="+IntToString(GetLevelByClass(CLASS_TYPE_BARD,pc))
                +" Cleric="+IntToString(GetLevelByClass(CLASS_TYPE_CLERIC,pc))
                +" Druid="+IntToString(GetLevelByClass(CLASS_TYPE_DRUID,pc))
                +" SF="+IntToString(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,pc))
                +" GSF="+IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,pc))
                +" ESF="+IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,pc)));
            if(GetIsObjectValid(target) && GetArea(pc)==GetArea(target))
                PrintString("[HC280 CHECK] name="+GetName(pc)+" distanceT7="+FloatToString(GetDistanceBetween(pc,target),0,2)
                    +" T7friendly="+IntToString(GetIsFriend(target,pc))
                    +" T7HP="+IntToString(GetCurrentHitPoints(target))+"/"+IntToString(GetMaxHitPoints(target)));
        }
        pc=GetNextPC();
    }
}

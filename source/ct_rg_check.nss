void main()
{
    PrintString("[RG284 CHECK] READ ONLY; spell374 school="+Get2DAString("spells","School",374)
        +" range="+Get2DAString("spells","Range",374));
    object pc=GetFirstPC();
    while(GetIsObjectValid(pc))
    {
        if(!GetIsDM(pc))
        {
            int count=0;effect e=GetFirstEffect(pc);
            while(GetIsEffectValid(e))
            {
                if(GetEffectType(e)==EFFECT_TYPE_REGENERATE && GetEffectSpellId(e)==374)
                {
                    count++;
                    PrintString("[RG284 CHECK] name="+GetName(pc)+" spell=374 regen="+IntToString(GetEffectInteger(e,0))
                        +" duration="+IntToString(GetEffectDuration(e))+" remaining="+IntToString(GetEffectDurationRemaining(e)));
                }
                e=GetNextEffect(pc);
            }
            PrintString("[RG284 CHECK] name="+GetName(pc)+" HP="+IntToString(GetCurrentHitPoints(pc))+"/"+IntToString(GetMaxHitPoints(pc))
                +" regen374Effects="+IntToString(count)+" SF="+IntToString(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,pc))
                +" GSF="+IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,pc))
                +" ESF="+IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,pc)));
        }
        pc=GetNextPC();
    }
}

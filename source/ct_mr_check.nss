void main()
{
    PrintString("[MR283 CHECK] READ ONLY; spell525 school="+Get2DAString("spells","School",525)
        +" range="+Get2DAString("spells","Range",525));
    object pc=GetFirstPC();
    while(GetIsObjectValid(pc))
    {
        if(!GetIsDM(pc))
        {
            int count=0;effect e=GetFirstEffect(pc);
            while(GetIsEffectValid(e))
            {
                if(GetEffectType(e)==EFFECT_TYPE_REGENERATE && GetEffectSpellId(e)==525)
                {
                    count++;
                    PrintString("[MR283 CHECK] name="+GetName(pc)+" spell=525 regen="+IntToString(GetEffectInteger(e,0))
                        +" duration="+IntToString(GetEffectDuration(e))+" remaining="+IntToString(GetEffectDurationRemaining(e)));
                }
                e=GetNextEffect(pc);
            }
            PrintString("[MR283 CHECK] name="+GetName(pc)+" HP="+IntToString(GetCurrentHitPoints(pc))+"/"+IntToString(GetMaxHitPoints(pc))
                +" regen525Effects="+IntToString(count)+" SF="+IntToString(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,pc))
                +" GSF="+IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,pc))
                +" ESF="+IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,pc)));
        }
        pc=GetNextPC();
    }
}

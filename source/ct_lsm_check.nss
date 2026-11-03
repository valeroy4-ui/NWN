void main()
{
    PrintString("[LSM281 CHECK] READ ONLY; spell99 school="+Get2DAString("spells","School",99)
        +" range="+Get2DAString("spells","Range",99));
    object pc=GetFirstPC();
    while(GetIsObjectValid(pc))
    {
        if(!GetIsDM(pc))
        {
            int count=0;effect e=GetFirstEffect(pc);
            while(GetIsEffectValid(e))
            {
                if(GetEffectType(e)==EFFECT_TYPE_SPELLLEVELABSORPTION)
                {
                    count++;
                    PrintString("[LSM281 CHECK] name="+GetName(pc)+" spell="+IntToString(GetEffectSpellId(e))
                        +" maxLevel="+IntToString(GetEffectInteger(e,0))+" pool="+IntToString(GetEffectInteger(e,1))
                        +" school="+IntToString(GetEffectInteger(e,2))+" duration="+IntToString(GetEffectDuration(e))
                        +" remaining="+IntToString(GetEffectDurationRemaining(e)));
                }
                e=GetNextEffect(pc);
            }
            PrintString("[LSM281 CHECK] name="+GetName(pc)+" mantleEffects="+IntToString(count)
                +" SF="+IntToString(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,pc))
                +" GSF="+IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,pc))
                +" ESF="+IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,pc)));
        }
        pc=GetNextPC();
    }
}

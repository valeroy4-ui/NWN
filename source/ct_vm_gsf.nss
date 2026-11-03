void Report(object pc)
{
    PrintString("[VM286 FOCUS] name="+GetName(pc)
        +" SF="+IntToString(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,pc))
        +" GSF="+IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,pc))
        +" ESF="+IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,pc)));
}
void main()
{
    object pc=GetFirstPC(),chosen=OBJECT_INVALID;int matches=0;
    object wp=GetWaypointByTag("CT_SPELL_LAB");
    while(GetIsObjectValid(pc))
    {
        string name=GetStringLowerCase(GetName(pc));
        if(!GetIsDM(pc) && name=="druid[test]"
            && GetIsObjectValid(wp) && GetArea(pc)==GetArea(wp))
        {chosen=pc;matches++;}
        pc=GetNextPC();
    }
    if(matches!=1)
    {PrintString("[VM286 FOCUS] Need exactly one Druid[test] in !lab; no changes.");return;}
    pc=chosen;
    effect e=GetFirstEffect(pc);
    while(GetIsEffectValid(e))
    {
        if(GetEffectTag(e)=="VM286_TEST_FOCUS")RemoveEffect(pc,e);
        e=GetNextEffect(pc);
    }
    // Only temporary effects with our own tag are removed. Permanent feats are untouched.
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,TagEffect(EffectBonusFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT),"VM286_TEST_FOCUS"),pc,600.0);
    DelayCommand(0.5,Report(pc));
}

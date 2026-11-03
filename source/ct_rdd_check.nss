// Read-only console diagnostic. Does not grant class eligibility.
void main()
{
    object p=GetFirstPC();
    int count=0;
    while(GetIsObjectValid(p))
    {
        if(!GetIsDM(p))
        {
            int bard=GetLevelByClass(CLASS_TYPE_BARD,p);
            int harper=GetLevelByClass(CLASS_TYPE_HARPER,p);
            int persuade=GetSkillRank(SKILL_PERSUADE,p,TRUE);
            int rdd=GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE,p);
            int wm=GetLevelByClass(CLASS_TYPE_WEAPON_MASTER,p);
            int pdk=GetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT,p);
            int dd=GetLevelByClass(CLASS_TYPE_DWARVEN_DEFENDER,p);
            int expertise=GetHasFeat(FEAT_IMPROVED_EXPERTISE,p);
            int rule=(bard>=5 || harper>=5 || persuade>=17) && !wm && !pdk && !(rdd>10 && expertise);
            PrintString("[RDD CHECK] name="+GetName(p,TRUE)+" bard="+IntToString(bard)+" harper="+IntToString(harper)+" persuade="+IntToString(persuade)+" rdd="+IntToString(rdd)+" BAB="+IntToString(GetBaseAttackBonus(p)));
            PrintString("[RDD CHECK] name="+GetName(p,TRUE)+" rule="+IntToString(rule)+" X1_AllowDraDis="+IntToString(GetLocalInt(p,"X1_AllowDraDis"))+" WM="+IntToString(wm)+" PDK="+IntToString(pdk)+" DD="+IntToString(dd)+" improvedExpertise="+IntToString(expertise));
            PrintString("[RDD CHECK] name="+GetName(p,TRUE)+" classes="+IntToString(GetClassByPosition(1,p))+","+IntToString(GetClassByPosition(2,p))+","+IntToString(GetClassByPosition(3,p)));
            count++;
        }
        p=GetNextPC();
    }
    PrintString("[RDD CHECK] online="+IntToString(count)+" req0="+Get2DAString("cls_pres_dradis","ReqType",0)+":"+Get2DAString("cls_pres_dradis","ReqParam1",0)+" req1="+Get2DAString("cls_pres_dradis","ReqType",1)+":"+Get2DAString("cls_pres_dradis","ReqParam1",1)+":"+Get2DAString("cls_pres_dradis","ReqParam2",1));
}

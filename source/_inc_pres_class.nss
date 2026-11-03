///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

int pres_RDD(object oPC);
int pres_PDK(object oPC);

void pres_RunValidator(object oPC);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int pres_RDD(object oPC)
{
    if(GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oPC) > 10 && GetHasFeat(FEAT_IMPROVED_EXPERTISE, oPC))
    {
        SetLocalInt(oPC, "X1_AllowDraDis", 0);
        return FALSE;
    }
    if(GetLevelByClass(CLASS_TYPE_WEAPON_MASTER, oPC) || GetLevelByClass(CLASS_TYPE_PURPLE_DRAGON_KNIGHT, oPC))
    {
        SetLocalInt(oPC, "X1_AllowDraDis", 0);
        return FALSE;
    }
    if(GetLevelByClass(CLASS_TYPE_BARD, oPC) >= 5       ||
       GetLevelByClass(CLASS_TYPE_HARPER, oPC) >= 5     ||
       GetSkillRank(SKILL_PERSUADE, oPC, TRUE) >= 17)
    {
        SetLocalInt(oPC, "X1_AllowDraDis", 1);
        return TRUE;
    }
    else
    {
        SetLocalInt(oPC, "X1_AllowDraDis", 0);
        return FALSE;
    }
}

int pres_PDK(object oPC)
{
    SetLocalInt(oPC, "X1_AllowPDK", 1);
    return TRUE;
    if (GetLevelByClass(CLASS_TYPE_PALADIN, oPC) >= 17 && GetLevelByClass(CLASS_TYPE_BLACKGUARD, oPC) >= 17)
    {
        SetLocalInt(oPC, "X1_AllowPDK", 1);
        return TRUE;
    }
    else
    {
        SetLocalInt(oPC, "X1_AllowPDK", 0);
        return FALSE;
    }
}

void pres_RunValidator(object oPC)
{
    pres_RDD(oPC);
    pres_PDK(oPC);
}


//void main()  {}

#include "_inc_db_funcs"
#include "_inc_log"
#include "_inc_factions"
#include "_inc_players"
#include "_inc_champ_boss"


object CheckKiller(object oKiller)
{
    if (!GetIsPC(oKiller)){
        if (GetObjectType(oKiller) == OBJECT_TYPE_CREATURE)
            oKiller = GetMaster(oKiller);
        else{
        oKiller = GetTrapCreator(oKiller);
        SetLocalInt(OBJECT_SELF, "Trapped", TRUE);
        SendMessageToPC(oKiller, "Finded Trap Master!");
        }
    }
    if (GetIsPC(oKiller) && !GetIsDM(oKiller)) return oKiller;
    return OBJECT_INVALID;
}

int GetXpRequiredForLevel(int iLevel)
{
    if(iLevel > 40) return 0;
    return StringToInt(Get2DAString("exptable", "XP", iLevel - 1));
}

float CalculateCR_Coefficient(int iHighLevel, object oMonster = OBJECT_SELF)
{
    float base;
    int iMobCR = FloatToInt(GetChallengeRating(oMonster));
    int iDiff = iMobCR - iHighLevel;
    // impossible
    if(iDiff >= 5)
        base = 1.0;
    // overpowering
    else if(iDiff == 4)
        base = 0.85;
    // overpowering
    else if(iDiff == 3)
        base = 0.70;
    // very difficult
    else if(iDiff == 2)
        base = 0.55;
    // very difficult
    else if(iDiff == 1)
        base = 0.4;
    // challenging
    else if(iDiff == 0)
        base = 0.3;
    // challenging
    else if(iDiff == -1)
        base = 0.2;
    // moderate
    else if(iDiff == -2)
        base = 0.1;
    // moderate
    else if(iDiff == -3)
        base = 0.05;
    // easy
    else if(iDiff == -4)
        base = 0.02;
    // effortless
    else if(iDiff == -5)
        base = 0.01;
    else
        base = 0.0;

    if (champion_GetIsChampion(oMonster)) // champion bonus exp 33%
        base *= 1.33;
    if(champion_GetIsEliteChampion(oMonster) || iMobCR >= 60) // elite champ or hardcore bonus 400%
        base *= 4.0;

    return base;
}

float CalculatePartyCoeff(int iDiff)
{
    float result;
    switch(iDiff){
        case 0: result = 1.0; break;
        case 1: result = 0.95; break;
        case 2: result = 0.90; break;
        case 3: result = 0.85; break;
        case 4: result = 0.80; break;
        case 5: result = 0.75; break;
        case 6: result = 0.70; break;
        case 7: result = 0.65; break;
        case 8: result = 0.55; break;
        case 9: result = 0.50; break;
        case 10: result = 0.40; break;
        case 11: result = 0.30; break;
        case 12: result = 0.20; break;
        case 13: result = 0.10; break;
        default: result = 0.0; break;
    }
    return result;
}

float GetXpClassCoefficient(int iClass)
{
    float result;
    switch(iClass)
    {
        // base classes
        case CLASS_TYPE_BARBARIAN: result = 1.2; break;
        case CLASS_TYPE_BARD: result = 1.0; break;
        case CLASS_TYPE_CLERIC: result = 1.0; break;
        case CLASS_TYPE_DRUID: result = 1.1; break;
        case CLASS_TYPE_FIGHTER: result = 1.3; break;
        case CLASS_TYPE_MONK: result = 0.9; break;
        case CLASS_TYPE_PALADIN: result = 1.2; break;
        case CLASS_TYPE_RANGER: result = 1.2; break;
        case CLASS_TYPE_ROGUE: result = 1.1; break;
        case CLASS_TYPE_SORCERER: result = 0.6; break;
        // case CLASS_TYPE_WIZARD: result = 0.5; break; // disabled prestige classes
        case CLASS_TYPE_ARCANE_ARCHER: result = 1.0; break;
        case CLASS_TYPE_ASSASSIN: result = 0.9; break;
        case CLASS_TYPE_BLACKGUARD: result = 1.2; break;
        case CLASS_TYPE_DIVINE_CHAMPION: result = 1.2; break;
        case CLASS_TYPE_DRAGON_DISCIPLE: result = 0.8; break;
        case CLASS_TYPE_DWARVEN_DEFENDER: result = 0.5; break;
        case CLASS_TYPE_HARPER: result = 0.8; break;
        case CLASS_TYPE_PALE_MASTER: result = 0.5; break;
        case CLASS_TYPE_PURPLE_DRAGON_KNIGHT: result = 1.1; break;
        case CLASS_TYPE_SHADOWDANCER: result = 0.9; break;
        case CLASS_TYPE_SHIFTER: result = 0.9; break; // slayer
        case CLASS_TYPE_WEAPON_MASTER: result = 1.3; break;
        case CLASS_TYPE_ARCHMAGE: result = 1.0; break;
        default: result = 0.0; break;
    }
    return result;
}

float GetXpCoefficient(object oPC)
{
    if(!GetHitDice(oPC)) WriteLog("GetHitDice()=0", LOG_LEVEL_ERROR);
    float result = ((GetLevelByPosition(1, oPC) * GetXpClassCoefficient(GetClassByPosition(1, oPC))) +
                    (GetLevelByPosition(2, oPC) * GetXpClassCoefficient(GetClassByPosition(2, oPC))) +
                    (GetLevelByPosition(4, oPC) > 0 ? (GetLevelByPosition(4, oPC) * GetXpClassCoefficient(GetClassByPosition(4, oPC))) : 0.0) +
                    (GetLevelByPosition(3, oPC) * GetXpClassCoefficient(GetClassByPosition(3, oPC)))) / GetHitDice(oPC);
    return result;

}

int HasGainedExp(object oPC)
{
    // Don't give XP if player dead!
    if (GetCurrentHitPoints(oPC) < -10)
    {
        SendMessageToPC(oPC, "You didn't gain any experience because you are dead!");
        return FALSE;
    }
    // Don't give XP if player under "level up"
    int iPC_XP = GetXP(oPC);
    int iLevelPC = GetHitDice(oPC);
    if ((iPC_XP > GetXpRequiredForLevel(iLevelPC + 1)) && iLevelPC < 40){
        SendMessageToPC(oPC,"You need to level up before getting new experience points.");
        return FALSE;
    }
    return TRUE;
}
// crypton 2014 -->
int GetBonusXPByLvl(object oPC)
{
    int iLvl = GetHitDice(oPC);
    int iBonusXP = 0;
    if (iLvl>1 && iLvl<=10){
        iBonusXP = 0;
    } else if (iLvl>10 && iLvl<=20) {
        iBonusXP = 0;
    } else if (iLvl>20 && iLvl<=30) {
        iBonusXP = 0;
    } else if (iLvl>30 && iLvl<=40) {
        iBonusXP = 0;
    }

    return iBonusXP;
}

int GetBaseXPByLvl(object oPC)
{
    int iLvl = GetHitDice(oPC);
    int iBaseXP = 0;
    switch(iLvl){
    case 1: iBaseXP = 1000; break;
    case 2: iBaseXP = 987; break;
    case 3: iBaseXP = 974; break;
    case 4: iBaseXP = 961; break;
    case 5: iBaseXP = 948; break;
    case 6: iBaseXP = 935; break;
    case 7: iBaseXP = 923; break;
    case 8: iBaseXP = 910; break;
    case 9: iBaseXP = 897; break;
    case 10: iBaseXP = 884; break;
    case 11: iBaseXP = 871; break;
    case 12: iBaseXP = 858; break;
    case 13: iBaseXP = 846; break;
    case 14: iBaseXP = 833; break;
    case 15: iBaseXP = 820; break;
    case 16: iBaseXP = 807; break;
    case 17: iBaseXP = 794; break;
    case 18: iBaseXP = 782; break;
    case 19: iBaseXP = 769; break;
    case 20: iBaseXP = 756; break;
    case 21: iBaseXP = 743; break;
    case 22: iBaseXP = 730; break;
    case 23: iBaseXP = 717; break;
    case 24: iBaseXP = 705; break;
    case 25: iBaseXP = 692; break;
    case 26: iBaseXP = 679; break;
    case 27: iBaseXP = 666; break;
    case 28: iBaseXP = 653; break;
    case 29: iBaseXP = 641; break;
    case 30: iBaseXP = 628; break;
    case 31: iBaseXP = 615; break;
    case 32: iBaseXP = 602; break;
    case 33: iBaseXP = 589; break;
    case 34: iBaseXP = 576; break;
    case 35: iBaseXP = 564; break;
    case 36: iBaseXP = 551; break;
    case 37: iBaseXP = 538; break;
    case 38: iBaseXP = 525; break;
    case 39: iBaseXP = 512; break;
    case 40: iBaseXP = 500; break;
    }
    return iBaseXP;
}

int GetExpBoostFameForPC(object oPC)
{
    int iBoost = factions_GetFactionXPBoost(players_GetFaction(oPC));
    int iLevel = GetHitDice(oPC);
    if(iLevel < 35 || iBoost == 0) return iBoost;

    int iPercent;
    switch(iLevel)
    {
        case 35: iPercent = 85; break;
        case 36: iPercent = 70; break;
        case 37: iPercent = 55; break;
        case 38: iPercent = 40; break;
        case 39: iPercent = 25;  break;
        case 40: iPercent = 10;  break;
    }
    float fBoost = IntToFloat(iBoost);
    iBoost = FloatToInt(fBoost / 100 * iPercent);
    return iBoost;
}

int GetExpBoostTotalFameForPC(object oPC)
{
    int iBoost = factions_GetTotalXPBoost();
    int iLevel = GetHitDice(oPC);
    if(iLevel < 35 || iBoost == 0) return iBoost;

    int iPercent;
    switch(iLevel)
    {
        case 35: iPercent = 85; break;
        case 36: iPercent = 70; break;
        case 37: iPercent = 55; break;
        case 38: iPercent = 40; break;
        case 39: iPercent = 25;  break;
        case 40: iPercent = 10;  break;
    }
    float fBoost = IntToFloat(iBoost);

    iBoost = FloatToInt(fBoost / 100 * iPercent);
    return iBoost;
}

//crypton 2014 <--
void GiveExperience(object oLastKiller, object oMob = OBJECT_SELF)
{
    float BASE_EXPERIENCE = IntToFloat(GetBaseXPByLvl(oLastKiller)+GetBonusXPByLvl(oLastKiller));
    int iLevelPC;
    float fDistance;

    int iLevelParty;


    int iPlayers = 0;
    float iPartyClassCoeff;

    object oPartyMember;
    object oArea = GetArea(oMob);

    // Checking Killer
    object oKiller = CheckKiller(oLastKiller);
    if (oKiller == OBJECT_INVALID || GetIsDM(oKiller)) return;

    int PC_HitPoints;

    int HIGHEST_LEVEL;
    int LOWEST_LEVEL = 40;
    // Checking Party, finding the "Highest Level"
    oPartyMember = GetFirstFactionMember(oKiller);
    while(GetIsObjectValid(oPartyMember))
    {
        fDistance = GetDistanceBetween(oPartyMember, oMob);
        PC_HitPoints = GetCurrentHitPoints(oPartyMember);
        if ((oArea == GetArea(oPartyMember)) && (fDistance <= 45.0) && (PC_HitPoints > -10))
        {
            if ((GetIsPC(oPartyMember)) && (!GetIsDM(oPartyMember)))
            {
                iPlayers++;
                iLevelPC = GetHitDice(oPartyMember);

                if (iLevelPC > HIGHEST_LEVEL) HIGHEST_LEVEL = iLevelPC;
                if (iLevelPC < LOWEST_LEVEL)  LOWEST_LEVEL =  iLevelPC;

                iPartyClassCoeff += GetXpCoefficient(oPartyMember);
            }
        }
        oPartyMember = GetNextFactionMember(oKiller);
    }
    if(!iPlayers) return;

    int iPartyDiff = HIGHEST_LEVEL - LOWEST_LEVEL;
    float fPartyCoeff = CalculatePartyCoeff(iPartyDiff);
    float fCRCoeff = CalculateCR_Coefficient(HIGHEST_LEVEL);
    float fModXP = iPartyClassCoeff / IntToFloat(iPlayers);
    float fXP;
    float fPlayers = IntToFloat(iPlayers)/10.0;
    float fBasePercent;
    if(iPlayers > 1)
        fBasePercent = 0.9 - (fPlayers - 0.2) * 0.5;
    else
        fBasePercent = 1.0;

    float fBaseExpMultiplier = StringToFloat(db_GetModuleParameter(MODULE_SETTING_EXPERIENCE_MULTIPLIER));
    fXP = BASE_EXPERIENCE * fModXP * fBasePercent * fPartyCoeff * fCRCoeff * fBaseExpMultiplier;
    int XP = FloatToInt(fXP);

    // Giving EXP to Players
    int IssuedXP = XP;
    oPartyMember = GetFirstFactionMember(oKiller);
    while(GetIsObjectValid(oPartyMember))
    {
        fDistance = GetDistanceBetween(oPartyMember, oMob);
        PC_HitPoints = GetCurrentHitPoints(oPartyMember);
        if (oArea == GetArea(oPartyMember) && GetIsPC(oPartyMember) && !GetIsDM(oPartyMember) && fDistance <= 45.0 && PC_HitPoints > -10)
        {
            iLevelPC = GetHitDice(oPartyMember);
            IssuedXP = XP;
            if(iPlayers > 1)
            {
                if(GetLevelByClass(CLASS_TYPE_SORCERER, oPartyMember) || GetLevelByClass(CLASS_TYPE_WIZARD, oPartyMember))
                {
                    IssuedXP = XP/3;
                }
            }
            int iGold = 50 + iLevelPC * 8;
            if (iGold > 1000) iGold = 1000;
            SetLocalInt(oKiller, "GOLD", iGold + Random(50));
            if(HasGainedExp(oPartyMember))
            {
                int iXpBoostPercentFame = GetExpBoostFameForPC(oPartyMember);
                int iXpBoostPercentFameTotal = GetExpBoostTotalFameForPC(oPartyMember);
                int BaseXP = IssuedXP;
                string sMessage = "+" + IntToString(IssuedXP);

                if(iXpBoostPercentFame > 0)
                {
                    int iXpBoost;
                    iXpBoost = BaseXP / 100 * iXpBoostPercentFame;
                    if(IssuedXP > 0)
                        sMessage += players_GetFactionColor(players_GetFaction(oPartyMember)) + "(+" + IntToString(iXpBoost) +")" + TXT_COLOR_END;

                    IssuedXP += iXpBoost;
                }
                if (iXpBoostPercentFameTotal>0)
                {
                    int iXpBoost;
                    iXpBoost = BaseXP / 100 * iXpBoostPercentFameTotal;
                    if(IssuedXP > 0)
                        sMessage += TXT_COLOR_WHITE + "(+" + IntToString(iXpBoost) +")" + TXT_COLOR_END;

                    IssuedXP += iXpBoost;
                }
                if(IssuedXP > 0)
                {
                    FloatingTextStringOnCreature(sMessage, oPartyMember);
                    GiveXPToCreature(oPartyMember, IssuedXP);
                    db_AddDBXP(oPartyMember, IssuedXP);
                }
            }
        }
        oPartyMember = GetNextFactionMember(oKiller, TRUE);
    }
    if(GetLocalInt(oKiller,"GOLD") > 0)
    {
        GiveGoldToCreature(oKiller, GetLocalInt(oKiller, "GOLD"));
        DeleteLocalInt(oKiller, "GOLD");
    }
}
//void main() {}

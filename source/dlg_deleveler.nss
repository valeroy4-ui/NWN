#include "_inc_generic"

void main()
{
    object oPC = GetPCSpeaker();
    int nLvl = GetHitDice(oPC);

    int nLevelsForDelevel = StringToInt(GetScriptParam("HOW_MANY_LEVELS_BURN"));

    int nXP1 = StringToInt(Get2DAString("exptable", "XP", nLvl - nLevelsForDelevel)) - 1;
    if(nXP1 > 1)
        SetXP(oPC, nXP1);
    else
        SetXP(oPC, 1);

    players_UpdateXpBar(oPC);
}


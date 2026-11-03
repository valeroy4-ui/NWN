#include "_inc_constants"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// returns "main build class" displayed for other players
int class_GetDisplayedClassIdForPlayers(object oPC);

// returns displayed class name by ID
string class_GetClassNameById(int Id);

// returns main player's class
int class_GetMainClass(object oPC);


///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int class_GetDisplayedClassIdForPlayers(object oPC)
{
    int i,
    iPrestigeLvl, iBaseLvl,
    iPrestigeID,  iBaseID;

    for (i=1; i<=4; i++)
    {
        int iClassID  = GetClassByPosition(i, oPC);
        int iClassLvl = GetLevelByClass(iClassID, oPC);
        if (iClassID > 10) // prestige class
        {
            if (iClassLvl > iPrestigeLvl)
            {
                iPrestigeLvl = iClassLvl;
                iPrestigeID  = iClassID;
            }
        }
        else  // base class
        {
            if (iClassLvl > iBaseLvl)
            {
                iBaseLvl = iClassLvl;
                iBaseID  = iClassID;
            }
        }
    }
    if (iPrestigeLvl >= iBaseLvl)
        return iPrestigeID;
    else
        return iBaseID;
}

string class_GetClassNameById(int Id)
{
    switch(Id)
    {
        case CLASS_TYPE_BARBARIAN: return "Barbarian";
        case CLASS_TYPE_BARD: return "Bard";
        case CLASS_TYPE_PALE_MASTER: return "PM";
        case CLASS_TYPE_BLACKGUARD: return "BG";
        case CLASS_TYPE_CLERIC: return "Cleric";
        case CLASS_TYPE_DIVINE_CHAMPION: return "CoT";
        case CLASS_TYPE_ASSASSIN: return "Assasin";
        case CLASS_TYPE_DRAGONDISCIPLE: return "RDD";
        case CLASS_TYPE_DWARVENDEFENDER: return "Warlord";
        case CLASS_TYPE_DRUID: return "Druid";
        case CLASS_TYPE_FIGHTER: return "Fighter";
        case CLASS_TYPE_HARPER: return "Harper Scout";
        case CLASS_TYPE_MONK: return "Monk";
        case CLASS_TYPE_PALADIN: return "Paladin";
        case CLASS_TYPE_RANGER: return "Ranger";
        case CLASS_TYPE_PURPLE_DRAGON_KNIGHT: return "PDK";
        case CLASS_TYPE_ROGUE: return "Rogue";
        case CLASS_TYPE_SHADOWDANCER: return "ShD";
        case CLASS_TYPE_SHIFTER: return "Slayer";
        case CLASS_TYPE_SORCERER: return "Sorcerer";
        case CLASS_TYPE_WEAPON_MASTER: return "WM";
        case CLASS_TYPE_WIZARD: return "Wizard";
        case CLASS_TYPE_ARCANE_ARCHER: return "Arcan Archer";
        case CLASS_TYPE_ARCHMAGE: return "Archmage";
    }
    return "";
}

int class_GetMainClass(object oPC)
{
    int iClassLevel;
    int iClassType = 255;
    int iMax = 0;
    int iClassPos;
    for(iClassPos = 1; iClassPos <= 4; iClassPos++)
    {
        iClassLevel = GetLevelByPosition(iClassPos, oPC);
        if(iClassLevel > iMax)
        {
            iMax = iClassLevel;
            iClassType = GetClassByPosition(iClassPos, oPC);
        }
    }
    return iClassType;
}

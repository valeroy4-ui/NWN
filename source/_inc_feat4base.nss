///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

int GetWeaponFocusFeatForItemBaseType(int nItemBaseType);

int GetEpicWeaponFocusFeatForItemBaseType(int nItemBaseType);

int GetWeaponSpecializationFeatForItemBaseType(int nItemBaseType);

int GetEpicWeaponSpecializationFeatForItemBaseType(int nItemBaseType);

int GetWeaponImprovedCriticalFeatForItemBaseType(int nItemBaseType);

int GetEpicWeaponOverwhelmingCriticalFeatForItemBaseType(int nItemBaseType);

int GetEpicWeaponDevastatingCriticalFeatForItemBaseType(int nItemBaseType);

int GetWeaponOfChoiceFeatForItemBaseType(int nItemBaseType);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int GetWeaponFocusFeatForItemBaseType(int nItemBaseType)
{
    return StringToInt(Get2DAString("baseitems", "WeaponFocusFeat", nItemBaseType));
}

int GetEpicWeaponFocusFeatForItemBaseType(int nItemBaseType)
{
    return StringToInt(Get2DAString("baseitems", "EpicWeaponFocusFeat", nItemBaseType));
}

int GetWeaponSpecializationFeatForItemBaseType(int nItemBaseType)
{
    return StringToInt(Get2DAString("baseitems", "WeaponSpecializationFeat", nItemBaseType));
}

int GetEpicWeaponSpecializationFeatForItemBaseType(int nItemBaseType)
{
    return StringToInt(Get2DAString("baseitems", "EpicWeaponSpecializationFeat", nItemBaseType));
}

int GetWeaponImprovedCriticalFeatForItemBaseType(int nItemBaseType)
{
    return StringToInt(Get2DAString("baseitems", "WeaponImprovedCriticalFeat", nItemBaseType));
}

int GetEpicWeaponOverwhelmingCriticalFeatForItemBaseType(int nItemBaseType)
{
    return StringToInt(Get2DAString("baseitems", "EpicWeaponOverwhelmingCriticalFeat", nItemBaseType));
}

int GetEpicWeaponDevastatingCriticalFeatForItemBaseType(int nItemBaseType)
{
    return StringToInt(Get2DAString("baseitems", "EpicWeaponDevastatingCriticalFeat", nItemBaseType));
}

int GetWeaponOfChoiceFeatForItemBaseType(int nItemBaseType)
{
    return StringToInt(Get2DAString("baseitems", "WeaponOfChoiceFeat", nItemBaseType));
}

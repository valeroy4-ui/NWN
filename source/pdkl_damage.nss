#include "pdkl_core"
#include "nwnx_damage"
void main()
{
    int nCount = PDKL_ActiveCount(OBJECT_SELF);
    if(nCount <= 0) return;
    struct NWNX_Damage_DamageEventData d = NWNX_Damage_GetDamageEventData();
    if(d.iBludgeoning > 0) d.iBludgeoning += d.iBludgeoning * (10 * nCount) / 100;
    if(d.iPierce > 0) d.iPierce += d.iPierce * (10 * nCount) / 100;
    if(d.iSlash > 0) d.iSlash += d.iSlash * (10 * nCount) / 100;
    if(d.iMagical > 0) d.iMagical += d.iMagical * (10 * nCount) / 100;
    if(d.iAcid > 0) d.iAcid += d.iAcid * (10 * nCount) / 100;
    if(d.iCold > 0) d.iCold += d.iCold * (10 * nCount) / 100;
    if(d.iDivine > 0) d.iDivine += d.iDivine * (10 * nCount) / 100;
    if(d.iElectrical > 0) d.iElectrical += d.iElectrical * (10 * nCount) / 100;
    if(d.iFire > 0) d.iFire += d.iFire * (10 * nCount) / 100;
    if(d.iNegative > 0) d.iNegative += d.iNegative * (10 * nCount) / 100;
    if(d.iPositive > 0) d.iPositive += d.iPositive * (10 * nCount) / 100;
    if(d.iSonic > 0) d.iSonic += d.iSonic * (10 * nCount) / 100;
    if(d.iBase > 0) d.iBase += d.iBase * (10 * nCount) / 100;
    if(d.iCustom1 > 0) d.iCustom1 += d.iCustom1 * (10 * nCount) / 100;
    if(d.iCustom2 > 0) d.iCustom2 += d.iCustom2 * (10 * nCount) / 100;
    if(d.iCustom3 > 0) d.iCustom3 += d.iCustom3 * (10 * nCount) / 100;
    if(d.iCustom4 > 0) d.iCustom4 += d.iCustom4 * (10 * nCount) / 100;
    if(d.iCustom5 > 0) d.iCustom5 += d.iCustom5 * (10 * nCount) / 100;
    if(d.iCustom6 > 0) d.iCustom6 += d.iCustom6 * (10 * nCount) / 100;
    if(d.iCustom7 > 0) d.iCustom7 += d.iCustom7 * (10 * nCount) / 100;
    if(d.iCustom8 > 0) d.iCustom8 += d.iCustom8 * (10 * nCount) / 100;
    if(d.iCustom9 > 0) d.iCustom9 += d.iCustom9 * (10 * nCount) / 100;
    if(d.iCustom10 > 0) d.iCustom10 += d.iCustom10 * (10 * nCount) / 100;
    if(d.iCustom11 > 0) d.iCustom11 += d.iCustom11 * (10 * nCount) / 100;
    if(d.iCustom12 > 0) d.iCustom12 += d.iCustom12 * (10 * nCount) / 100;
    if(d.iCustom13 > 0) d.iCustom13 += d.iCustom13 * (10 * nCount) / 100;
    if(d.iCustom14 > 0) d.iCustom14 += d.iCustom14 * (10 * nCount) / 100;
    if(d.iCustom15 > 0) d.iCustom15 += d.iCustom15 * (10 * nCount) / 100;
    if(d.iCustom16 > 0) d.iCustom16 += d.iCustom16 * (10 * nCount) / 100;
    if(d.iCustom17 > 0) d.iCustom17 += d.iCustom17 * (10 * nCount) / 100;
    if(d.iCustom18 > 0) d.iCustom18 += d.iCustom18 * (10 * nCount) / 100;
    if(d.iCustom19 > 0) d.iCustom19 += d.iCustom19 * (10 * nCount) / 100;
    NWNX_Damage_SetDamageEventData(d);
}

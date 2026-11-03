// Independent damage component for the revised Link specification.
// The caller resolves the owning class and active link slots.
// One call applies ONE selected subtype, never the entire Dmg category.
#include "nwnx_damage"

const int PDKL_DMG_PHYSICAL = 1;
const int PDKL_DMG_NEGATIVE = 2;
const int PDKL_DMG_NEGCRIT = 3;

int PDKL_PhysicalPercent(int nLevel, int nStrMod)
{ return nLevel / 3 + nStrMod / 2; }
int PDKL_NegativeDice(int nLevel)
{ return nLevel / 6; }
int PDKL_NegativeFlat(int nDexMod)
{ return nDexMod / 2; }
int PDKL_NegativeCrit(int nLevel)
{ return nLevel + 10; }

int PDKL_PhysAmount(int nDamage, int nPercent)
{
    // Keep NWNX's -1 sentinel when this damage component is absent.
    if(nDamage <= 0) return nDamage;
    int nResult = nDamage + nDamage * nPercent / 100;
    return nResult > 0 ? nResult : 0;
}

struct NWNX_Damage_AttackEventData PDKL_ApplyDamage(
    struct NWNX_Damage_AttackEventData d, int nSubtype,
    int nLevel, int nStrMod, int nDexMod)
{
    if(nLevel <= 0) return d;
    if(d.iAttackResult != 1 && d.iAttackResult != 3 && d.iAttackResult != 7 && d.iAttackResult != 10) return d;
    if(nSubtype == PDKL_DMG_PHYSICAL)
    {
        int p = PDKL_PhysicalPercent(nLevel, nStrMod);
        d.iBase = PDKL_PhysAmount(d.iBase, p);
        d.iBludgeoning = PDKL_PhysAmount(d.iBludgeoning, p);
        d.iPierce = PDKL_PhysAmount(d.iPierce, p);
        d.iSlash = PDKL_PhysAmount(d.iSlash, p);
    }
    else if(nSubtype == PDKL_DMG_NEGATIVE)
    {
        int nBonus = PDKL_NegativeFlat(nDexMod);
        int i;
        for(i = 0; i < PDKL_NegativeDice(nLevel); i++) nBonus += d2();
        if(nBonus > 0) d.iNegative = (d.iNegative > 0 ? d.iNegative : 0) + nBonus;
    }
    else if(nSubtype == PDKL_DMG_NEGCRIT && (d.iAttackResult == 3 || d.iAttackResult == 10))
    {
        d.iNegative = (d.iNegative > 0 ? d.iNegative : 0) + PDKL_NegativeCrit(nLevel);
    }
    return d;
}

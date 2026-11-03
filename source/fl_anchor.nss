#include "nwnx_creature"
#include "_inc_constants"

void main()
{
    object oItem = GetItemActivated();
    object oActivator = GetItemPossessor(oItem);
    object oTarget = GetItemActivatedTarget();
    NWNX_Creature_DoItemCastSpell(oActivator, oActivator, LOCATION_INVALID, SPELL_CL_GATE_ANCHOR,
                                  40, 0.0, PROJECTILE_PATH_TYPE_DEFAULT, -1, oItem, "nw_s0_gate");
    DestroyObject(oItem, 0.1);
}

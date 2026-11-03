#include "_inc_colortext"
#include "_inc_citykeeper"

void main()
{
    int iLimit = GetKeeperMaxHealth();
    object oDamager = GetLastDamager();
    object oKeeper = OBJECT_SELF;
    int nTotalDamageDealt = GetLocalInt(oKeeper, "DAMAGE") + GetTotalDamageDealt();
    SetLocalInt(oKeeper, "DAMAGE", nTotalDamageDealt);
    SetLocalInt(oKeeper, "ALARM", TRUE);
    DelayCommand(12.0, AssignCommand(GetModule(), SetLocalInt(oKeeper, "ALARM", FALSE)));
    if(nTotalDamageDealt >= iLimit && !GetLocalInt(oKeeper, "DEAD"))
    {
        SetLocalString(GetModule(), "KEEPER_KILLER", ColorText(GetName(oDamager), players_GetFactionColor(players_GetFaction(oDamager))));
        SetLocalInt(GetModule(), "KEEPER_KILLER_FACTION", players_GetFaction(oDamager));
        AssignCommand(GetModule(), ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oKeeper));
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_FIREBALL), GetLocation(oKeeper));
        SetLocalInt(oKeeper, "DEAD", TRUE);
    }
}

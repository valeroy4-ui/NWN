#include "nwnx_creature"
#include "nwnx_events"

void main()
{
    object oPC = GetSpellTargetObject();

    //AssignCommand(oPC, ActionUseFeat(FEAT_BARD_SONGS, oPC));

    NWNX_Creature_RestoreFeats(oPC);
    NWNX_Creature_RestoreSpecialAbilities(oPC);
    int i;
    for(i = 0; i <= 9; i++)
    {
        ReadySpellLevel(oPC, i);
    }
    NWNX_Creature_RestoreItems(oPC);
}

#include "_inc_death"


void main()
{
    object oPC = GetLastUsedBy();
    CreateCorpseInInventory(OBJECT_SELF, oPC);
}

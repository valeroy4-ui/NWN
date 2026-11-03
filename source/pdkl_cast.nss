#include "pdkl_use"
void main()
{
    if(!GetIsPC(OBJECT_SELF)) return;
    PDKL_Cast(OBJECT_SELF, GetSpellTargetObject(), GetSpellId());
}

#include "_inc_spells"

void main()
{
    DestroySpellMarkerPlacebles(GetLocation(OBJECT_SELF), GetLocalInt(OBJECT_SELF, "AOE_INDEX"),
                                GetLocalObject(OBJECT_SELF, "AOE_OWNER"));
}

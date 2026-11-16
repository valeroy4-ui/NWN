// Explicit test-server chat command; does not start combat or reset the boss.
void main()
{
    object oPC = OBJECT_SELF;
    if (!GetIsPC(oPC) || GetIsDead(oPC)) return;
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        if (GetResRef(oArea) == "ct_malveris")
        {
            // Eight metres north of the original boss position, inside the arena.
            JumpToLocation(Location(oArea,Vector(40.49437,47.00119,0.0),270.0));
            SendMessageToPC(oPC,"Malveris test arena.");
            return;
        }
        oArea = GetNextArea();
    }
    SendMessageToPC(oPC,"Malveris arena is not loaded. Install the module patch and restart cormyr.");
}

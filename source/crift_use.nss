void main()
{
    object pc = GetLastUsedBy();
    object area = GetLocalObject(OBJECT_SELF, "CRIFT_AREA");
    if (!GetIsPC(pc) || !GetIsObjectValid(area) || GetLocalInt(area, "CRIFT_CLOSED")) return;
    location dest = GetLocalLocation(OBJECT_SELF, "CRIFT_DEST");
    if (!GetIsObjectValid(GetAreaFromLocation(dest))) return;
    // Intentionally no combat, boss, party, faction, level or ownership checks.
    SetLocalObject(pc, "CRIFT_MOVE_DEST", GetAreaFromLocation(dest));
    AssignCommand(GetModule(), DelayCommand(1.0, DeleteLocalObject(pc, "CRIFT_MOVE_DEST")));
    AssignCommand(pc, ClearAllActions(TRUE));
    AssignCommand(pc, JumpToLocation(dest));
}

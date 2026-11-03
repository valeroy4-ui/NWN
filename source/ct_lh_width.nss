// TEST ONLY, read-only: use actual last Line Heal cast, never GetFacing().
void main()
{
    object mod = GetModule();
    object caster = GetLocalObject(mod, "LH_WIDTH_CASTER");
    location cast = GetLocalLocation(mod, "LH_WIDTH_CAST");
    object area = GetAreaFromLocation(cast);
    vector origin = GetPositionFromLocation(cast);
    vector direction = AngleToVector(GetFacingFromLocation(cast));
    if(!GetIsObjectValid(caster) || !GetIsObjectValid(area) || VectorMagnitude(direction) < 0.9)
    {PrintString("[LH WIDTH] Cast Line Heal first.");return;}
    PrintString("[LH WIDTH] actual caster=" + GetName(caster) + "; saved cast direction; visual unchanged.");
    object target = GetFirstPC();
    while(GetIsObjectValid(target))
    {
        if(target != caster && GetArea(target) == area)
        {
            vector delta = GetPosition(target) - origin;
            float forward = delta.x * direction.x + delta.y * direction.y;
            float side = -delta.x * direction.y + delta.y * direction.x;
            if(side < 0.0) side = -side;
            string status = "";
            if(forward < 0.5 || forward >= 8.0) status = " OUTSIDE_LENGTH";
            PrintString("[LH WIDTH] " + GetName(target) + " side=" + FloatToString(side,0,2)
                + " width=" + FloatToString(2.0*side,0,2) + " forward=" + FloatToString(forward,0,2) + status);
        }
        target = GetNextPC();
    }
}

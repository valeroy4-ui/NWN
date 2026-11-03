#include "_inc_colortext"
#include "_inc_citykeeper"
#include "_inc_generic"

void main()
{
    object oKeeper = OBJECT_SELF;
    int iDRemain = GetKeeperMaxHealth() - GetLocalInt(oKeeper, "DAMAGE");
    if(GetLocalInt(oKeeper, "ALARM"))
    {
        object oPC = GetFirstObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_COLOSSAL, GetLocation(oKeeper), FALSE, OBJECT_TYPE_CREATURE);
        while(GetIsObjectValid(oPC))
        {
            if(GetIsPC(oPC))
                FloatingColorTextStringOnCreature(IntToString(iDRemain) + " hitpoints left.", TXT_COLOR_BLUE_L, oPC, FALSE);
            oPC = GetNextObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_COLOSSAL, GetLocation(oKeeper), FALSE, OBJECT_TYPE_CREATURE);
        }
        if(!GetLocalInt(oKeeper, "DONT_SPAM"))
        {
            ServerShout(ColorText(GetName(oKeeper), TXT_COLOR_WHITE_T) + ColorText(" has been attacked!", TXT_COLOR_ORANGE));
            SetLocalInt(oKeeper, "DONT_SPAM", TRUE);
            DelayCommand(30.0, DeleteLocalInt(oKeeper, "DONT_SPAM"));
        }
    }
    if(GetCurrentHitPoints() != GetMaxHitPoints())
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(100500), oKeeper);

}

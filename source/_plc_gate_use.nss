#include "_inc_citykeeper"
#include "_inc_champ_boss"

void main()
{
    object oPC = GetLastUsedBy();
    // try to find portal exit
    object oPort = GetObjectByTag(GetTag(OBJECT_SELF)) != OBJECT_SELF ?
                   GetObjectByTag(GetTag(OBJECT_SELF)) : GetObjectByTag(GetTag(OBJECT_SELF), 1);

    // try to find stargate
    oPort = GetIsObjectValid(GetLocalObject(OBJECT_SELF, "STARGATE_EXIT"))  ? GetLocalObject(OBJECT_SELF, "STARGATE_EXIT"):
            GetIsObjectValid(GetLocalObject(OBJECT_SELF, "STARGATE_ENTER")) ? GetLocalObject(OBJECT_SELF, "STARGATE_ENTER"):
            oPort;

    AssignCommand(oPC, ClearAllActions());

    if(!GetIsDM(oPC) && !GetIsPCAllowedToEnterArea(oPC, GetArea(oPort)))
    {
        SendColorMessageToPC(oPC, "The area you're trying to get into is protected by a City Keeper.", TXT_COLOR_RED);
        return;
    }

    object oClickerArea = GetArea(oPC);
    int iDenyClicker = FALSE;
    object oEnemy = GetFirstObjectInArea(oClickerArea, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(oEnemy))
    {
        if(GetIsPC(oEnemy))
        {
            if(GetIsEnemy(oPC,oEnemy) || GetIsEnemy(oEnemy,oPC))
            {
                iDenyClicker = TRUE;
                break;
            }
        }
        if(champion_GetIsBoss(oEnemy))
        {
            iDenyClicker = TRUE;
            break;
        }
        oEnemy = GetNextObjectInArea(oClickerArea, OBJECT_TYPE_CREATURE);
    }

    object oDestinationArea = GetArea(oPort);
    int iDenyDestination = FALSE;
    oEnemy = GetFirstObjectInArea(oDestinationArea);
    while(GetIsObjectValid(oEnemy))
    {
          if(champion_GetIsBoss(oEnemy))
          {
               iDenyDestination = TRUE;
               break;
          }
          oEnemy = GetNextObjectInArea(oDestinationArea);
    }
    // no block enter into boss instance area
    int bBossInstance = GetLocalInt(oDestinationArea, AREA_FLAG_INSTANCE_BOSS);

    if(iDenyClicker)
    {
        SendColorMessageToPC(oPC, "You can't go through the portal. There is a hostile player or boss in your area.", TXT_COLOR_RED);
        AssignCommand(oPC, ClearAllActions());
    }
    else if(iDenyDestination && !bBossInstance)
    {
        SendColorMessageToPC(oPC, "You can't go through the portal. There is a boss in the destination area.", TXT_COLOR_RED);
        AssignCommand(oPC, ClearAllActions());
    }
    else
    {
        AssignCommand(oPC, ActionJumpToLocation(GetLocation(oPort)));
    }
}

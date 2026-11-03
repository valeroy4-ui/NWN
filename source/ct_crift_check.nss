#include "nwnx_area"
void main()
{
    object area = GetFirstArea();
    int count = 0;
    while (GetIsObjectValid(area))
    {
        if (GetLocalInt(area, "CRIFT_AREA"))
        {
            count++;
            PrintString("[CRIFT CHECK] area=" + ObjectToString(area) + " template=" + GetLocalString(area, "CRIFT_TEMPLATE") +
                " fired=" + IntToString(GetLocalInt(area, "CRIFT_FIRED_COUNT")) + "/" +
                IntToString(GetLocalInt(area, "CRIFT_ENCOUNTERS")) +
                " killed=" + IntToString(GetLocalInt(area, "CRIFT_KILLED")) + "/" +
                IntToString(GetLocalInt(area, "CRIFT_CREATED")) +
                " mini=" + IntToString(GetLocalInt(area, "CRIFT_HAS_MINI")) +
                " grand=" + IntToString(GetLocalInt(area, "CRIFT_GRAND_DONE")) +
                " players=" + IntToString(NWNX_Area_GetNumberOfPlayersInArea(area)) +
                " closed=" + IntToString(GetLocalInt(area, "CRIFT_CLOSED")));
        }
        area = GetNextArea();
    }
    PrintString("[CRIFT CHECK] instances=" + IntToString(count));
}

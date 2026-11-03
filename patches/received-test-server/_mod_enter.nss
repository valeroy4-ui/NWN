
void main()
{
    object oPC = GetEnteringObject();
    if (!GetIsPC(oPC) || GetIsDM(oPC)) return;
    DelayCommand(0.1, ExecuteScript("ct_pshik_login", oPC));
    DelayCommand(0.5, ExecuteScript("sv257_ui_watch", oPC));

    SendMessageToPC(oPC, "Cormyr spell test: database login disabled.");
    SendMessageToPC(oPC, "Type !lab in chat to enter the spell laboratory.");

    PrintString("[CORMYR TEST] Player entered");
}

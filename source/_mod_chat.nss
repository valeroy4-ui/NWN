void main()
{
    string msg = GetStringLowerCase(GetPCChatMessage());
    if (msg == "!daily" || msg == ".daily" || msg == "!dailyold" || msg == ".dailyold" || msg == "!dailyitem" || msg == ".dailyitem")
    {
        object pc = GetPCChatSpeaker(); SetPCChatMessage(""); if (!GetIsPC(pc)) return;
        if (msg == "!dailyitem" || msg == ".dailyitem") ExecuteScript("dq_item",pc);
        else
        {
            int carried = msg == "!dailyold" || msg == ".dailyold";
            if (GetLocalInt(pc,"DQ_UI_CARRIED") != carried) { int token = NuiFindWindow(pc,"dq_journal"); if (token) NuiDestroy(pc,token); }
            SetLocalInt(pc,"DQ_UI_CARRIED",carried);
            ExecuteScript("dq_open",pc);
        }
        return;
    }
    ExecuteScript("dq_base_chat",OBJECT_SELF);
}

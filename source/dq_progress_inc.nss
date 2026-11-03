// Feedback only for objectives changed in a committed event. No mutations or SQL.
string DQP_Progress(json before, json after)
{
    json old = JsonObjectGet(before,"quests"); json current = JsonObjectGet(after,"quests"); int i;
    string message;
    for (i = 0; i < JsonGetLength(current) && i < JsonGetLength(old); i++)
    {
        json q = JsonArrayGet(current,i); json previous = JsonArrayGet(old,i);
        if (DQC_Str(q,"id") == "" || DQC_Str(q,"id") != DQC_Str(previous,"id") || DQC_Int(q,"reward_claimed")) continue;
        if (DQC_Int(q,"progress") <= DQC_Int(previous,"progress")) continue;
        string prefix = DQC_Int(q,"origin_cycle") == DQC_Int(after,"cycle") ? "[Daily] " : "[Daily carried] ";
        string ready = DQC_Int(q,"objective_completed") ? " - READY: click chest" : "";
        if (message != "") message += "\n";
        message += prefix+DQC_Str(q,"title")+": "+IntToString(DQC_Int(q,"progress"))+"/"+IntToString(DQC_Int(q,"required"))+ready;
    }
    return message;
}

// Only currencies present in the successfully committed reward snapshot.
// Items have their own delivery status and are never asserted as delivered here.
string DQP_CurrencyMessage(json reward)
{
    string amounts;
    int gold = DQC_Int(reward,"gold");
    int fame = DQC_Int(reward,"fame");
    int coins = DQC_Int(reward,"coins");
    if (gold > 0) amounts = IntToString(gold)+" Gold (bank)";
    if (fame > 0)
    {
        if (amounts != "") amounts += ", ";
        amounts += IntToString(fame)+" Fame";
    }
    if (coins > 0)
    {
        if (amounts != "") amounts += ", ";
        amounts += IntToString(coins)+" Rune Coins";
    }
    return amounts == "" ? "" : "[Daily] Credited: "+amounts+".";
}

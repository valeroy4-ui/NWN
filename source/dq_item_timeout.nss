void main()
{
    object pc=OBJECT_SELF;
    if(GetLocalString(pc,"DQR_WAITING_SAVE")=="")return;
    // Leave the durable outbox row issuing. An uncertain export is never replayed.
    DeleteLocalString(pc,"DQR_WAITING_SAVE");DeleteLocalString(pc,"DQR_WAITING_UUID");DeleteLocalInt(pc,"DQR_DELIVERING");
    string message="Item received; server save was not confirmed. Delivery needs review and will not be repeated automatically.";
    SetLocalString(pc,"DQR_DELIVERY_MESSAGE",message);SendMessageToPC(pc,"[Daily] "+message);
}

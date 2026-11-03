void main()
{
    if(GetLocalInt(OBJECT_SELF, "Destroyed"))
    {
         ActionOpenDoor(OBJECT_SELF);
    }
}

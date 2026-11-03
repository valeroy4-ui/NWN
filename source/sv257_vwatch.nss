void SVVisualWatch(object cloud)
{
    if(!GetIsObjectValid(cloud)) {DestroyObject(OBJECT_SELF);return;}
    DelayCommand(0.5,SVVisualWatch(cloud));
}
void main()
{
    SVVisualWatch(GetLocalObject(OBJECT_SELF,"SV257_CLOUD"));
}

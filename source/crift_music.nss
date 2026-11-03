// Battle music applies only to a correctly marked Champion Rift clone.
int CRFM_Apply(object area)
{
    object source=GetLocalObject(area,"CRIFT_SOURCE");
    if(!GetIsObjectValid(area) || !GetLocalInt(area,"CRIFT_AREA") || !GetIsObjectValid(source) || source==area)return FALSE;
    int cached=GetLocalInt(GetModule(),"CRFM_TRACK_V01");int track=cached-1;int count=Get2DARowCount("ambientmusic");int i;
    if(track<0 || track>=count || Get2DAString("ambientmusic","Resource",track)!="mus_crfbaba")
    {
        track=-1;
        for(i=count-1;i>=0;i--)
            if(Get2DAString("ambientmusic","Resource",i)=="mus_crfbaba"){track=i;break;}
        if(track<0){PrintString("[CRIFT MUSIC] Custom battle track missing; original battle track retained.");return FALSE;}
        SetLocalInt(GetModule(),"CRFM_TRACK_V01",track+1);
    }
    MusicBattleChange(area,track);return MusicBackgroundGetBattleTrack(area)==track;
}

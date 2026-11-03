// Six independent choices: no implicit chance or lower-tier bundle.
int PDKL_ProcMinLevel(int kind)
{
    if(kind==14 || kind==17) return 10;
    if(kind==15 || kind==18) return 20;
    if(kind==16 || kind==19) return 30;
    return 0;
}
int PDKL_ProcDC(int kind,int level,int strength,int dexterity)
{
    int dc=level+(kind<=16?strength:dexterity)-5;
    int cap=kind<=16?48:45;
    return dc<cap?dc:cap;
}
int PDKL_ProcSaveType(int kind)
{
    if(kind==14 || kind==15) return SAVING_THROW_WILL;
    if(kind==16 || kind==17) return SAVING_THROW_FORT;
    return SAVING_THROW_REFLEX;
}
int PDKL_ProcTriggers(int kind,int level,int result)
{
    int minimum=PDKL_ProcMinLevel(kind);
    if(minimum==0 || level<minimum) return FALSE;
    int crit=result==3 || result==10;
    int hit=result==1 || result==7 || crit;
    return kind<=16?hit:crit;
}

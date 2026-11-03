// Included after pdkl_core definitions; no circular core include.

int PDKL_EndValue(object p, int kind)
{
    int level=PDKL_Level(p);
    int con=GetAbilityModifier(ABILITY_CONSTITUTION,p);
    int value;
    if(kind==6) value=level*4;
    else if(kind==7) value=level/2+con/2;
    else if(kind==8) value=level/3+con/2;
    else if(kind==9) value=level/3;
    else if(kind==10) value=level/3+con;
    return value>0?value:0;
}

float PDKL_HealInterval(object p)
{
    int seconds=60-GetAbilityModifier(ABILITY_CONSTITUTION,p);
    // A repeated timer must have a positive interval at extreme server stats.
    return IntToFloat(seconds>0?seconds:1);
}

int PDKL_EndCount(int kind,int value)
{
    if(value<=0) return 0;
    if(kind==7) return 5;
    if(kind==8) return 3;
    if(kind==9) return 4;
    if(kind==10) return 1;
    return 0;
}

int PDKL_EndDamageType(int kind,int index)
{
    if(kind==7)
    {
        if(index==0) return DAMAGE_TYPE_ACID;
        if(index==1) return DAMAGE_TYPE_COLD;
        if(index==2) return DAMAGE_TYPE_ELECTRICAL;
        if(index==3) return DAMAGE_TYPE_FIRE;
        return DAMAGE_TYPE_SONIC;
    }
    if(kind==8)
    {
        if(index==0) return DAMAGE_TYPE_BLUDGEONING;
        if(index==1) return DAMAGE_TYPE_PIERCING;
        return DAMAGE_TYPE_SLASHING;
    }
    if(index==0) return DAMAGE_TYPE_MAGICAL;
    if(index==1) return DAMAGE_TYPE_DIVINE;
    if(index==2) return DAMAGE_TYPE_NEGATIVE;
    return DAMAGE_TYPE_POSITIVE;
}

void PDKL_RemoveEndurance(object p,int slot)
{
    object target=GetLocalObject(p,PDKL_Key("END_TARGET",slot));
    string tag=GetLocalString(p,PDKL_Key("END_TAG",slot));
    if(GetIsObjectValid(target) && tag!="")
    {
        effect e=GetFirstEffect(target);
        while(GetIsEffectValid(e))
        {
            if(GetEffectTag(e)==tag) RemoveEffect(target,e);
            e=GetNextEffect(target);
        }
    }
    // Invalidates every delayed heal from the old selection/target.
    string key=PDKL_Key("END_TOKEN",slot);
    SetLocalInt(p,key,GetLocalInt(p,key)+1);
    DeleteLocalObject(p,PDKL_Key("END_TARGET",slot));
    DeleteLocalInt(p,PDKL_Key("END_KIND",slot));
    DeleteLocalInt(p,PDKL_Key("END_VALUE",slot));
    DeleteLocalString(p,PDKL_Key("END_TAG",slot));
}

void PDKL_HealTick(object p,object target,int slot,int token)
{
    if(!GetIsObjectValid(p) || GetLocalInt(p,PDKL_Key("END_TOKEN",slot))!=token) return;
    if(GetLocalObject(p,PDKL_Key("TARGET",slot))!=target
        || GetLocalInt(p,PDKL_Key("KIND",slot))!=6 || !PDKL_BenefitActive(p,slot)) return;
    int amount=PDKL_EndValue(p,6);
    if(amount>0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT,
            SetEffectCreator(SupernaturalEffect(EffectHeal(amount)),p),target);
        ApplyEffectToObject(DURATION_TYPE_INSTANT,
            EffectVisualEffect(VFX_IMP_HEALING_L),target);
    }
    // Current level is used for each heal. CON is sampled for the next period.
    DelayCommand(PDKL_HealInterval(p),PDKL_HealTick(p,target,slot,token));
}

void PDKL_UpdateEndurance(object p)
{
    int slot;
    for(slot=1;slot<=PDKL_MAX;slot++)
    {
        int kind=GetLocalInt(p,PDKL_Key("KIND",slot));
        object target=GetLocalObject(p,PDKL_Key("TARGET",slot));
        if(kind<6 || kind>10 || !PDKL_BenefitActive(p,slot))
        {
            // No stored selection means there is nothing to remove or cancel.
            if(GetLocalInt(p,PDKL_Key("END_KIND",slot))) PDKL_RemoveEndurance(p,slot);
            continue;
        }
        int value=PDKL_EndValue(p,kind);
        int sameTarget=GetLocalObject(p,PDKL_Key("END_TARGET",slot))==target;
        int sameKind=GetLocalInt(p,PDKL_Key("END_KIND",slot))==kind;
        string tag=GetLocalString(p,PDKL_Key("END_TAG",slot));
        if(sameTarget && sameKind)
        {
            if(kind==6)
            {
                SetLocalInt(p,PDKL_Key("END_VALUE",slot),value);
                continue; // Refreshes never restart or duplicate the timer.
            }
            if(GetLocalInt(p,PDKL_Key("END_VALUE",slot))==value
                && PDKL_ExperienceEffectCount(target,tag)==PDKL_EndCount(kind,value)) continue;
        }
        PDKL_RemoveEndurance(p,slot);
        int token=GetLocalInt(p,PDKL_Key("END_TOKEN",slot));
        tag="PDKL_END_"+ObjectToString(p)+"_"+IntToString(slot)+"_"+IntToString(token);
        SetLocalObject(p,PDKL_Key("END_TARGET",slot),target);
        SetLocalInt(p,PDKL_Key("END_KIND",slot),kind);
        SetLocalInt(p,PDKL_Key("END_VALUE",slot),value);
        SetLocalString(p,PDKL_Key("END_TAG",slot),tag);
        if(kind==6)
        {
            // The first heal is delayed by the full interval, as requested.
            DelayCommand(PDKL_HealInterval(p),PDKL_HealTick(p,target,slot,token));
        }
        else if(kind==10 && value>0)
        {
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,
                TagEffect(SetEffectCreator(SupernaturalEffect(EffectRegenerate(value,6.0)),p),tag),target);
        }
        else
        {
            int i;
            for(i=0;i<PDKL_EndCount(kind,value);i++)
                ApplyEffectToObject(DURATION_TYPE_PERMANENT,
                    TagEffect(SetEffectCreator(SupernaturalEffect(
                        EffectDamageResistance(PDKL_EndDamageType(kind,i),value)),p),tag),target);
        }
    }
}

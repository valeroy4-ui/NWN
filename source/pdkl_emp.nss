// Included after core lifecycle functions.
void PDKL_RemoveEmpower(object owner,int slot)
{
    object target=GetLocalObject(owner,PDKL_Key("EMP_TARGET",slot));
    string tag=GetLocalString(owner,PDKL_Key("EMP_TAG",slot));
    if(GetIsObjectValid(target) && tag!="")
    {
        effect e=GetFirstEffect(target);
        while(GetIsEffectValid(e))
        {
            if(GetEffectTag(e)==tag) RemoveEffect(target,e);
            e=GetNextEffect(target);
        }
    }
    if(GetLocalInt(owner,PDKL_Key("EMP_KIND",slot))==4) PDKL_NativeLink(owner,OBJECT_INVALID,0);
    DeleteLocalObject(owner,PDKL_Key("EMP_TARGET",slot));
    DeleteLocalInt(owner,PDKL_Key("EMP_KIND",slot));
    DeleteLocalInt(owner,PDKL_Key("EMP_VALUE",slot));
    DeleteLocalString(owner,PDKL_Key("EMP_TAG",slot));
}

void PDKL_UpdateEmpower(object owner)
{
    int slot;int abslot;
    for(slot=1;slot<=PDKL_MAX;slot++)
    {
        int kind=GetLocalInt(owner,PDKL_Key("KIND",slot));
        object target=GetLocalObject(owner,PDKL_Key("TARGET",slot));
        if(PDKL_Group(kind)!=2 || !PDKL_BenefitActive(owner,slot))
        {
            if(GetLocalInt(owner,PDKL_Key("EMP_KIND",slot))) PDKL_RemoveEmpower(owner,slot);
            continue;
        }
        int value=PDKL_Level(owner)/10;
        if(kind==20) value-=PDKL_ShieldBase(target);
        if(value<0) value=0;
        if(kind==4) { abslot=slot;value=0; }
        string tag=GetLocalString(owner,PDKL_Key("EMP_TAG",slot));
        if(GetLocalObject(owner,PDKL_Key("EMP_TARGET",slot))==target
            && GetLocalInt(owner,PDKL_Key("EMP_KIND",slot))==kind
            && GetLocalInt(owner,PDKL_Key("EMP_VALUE",slot))==value
            && PDKL_ExperienceEffectCount(target,tag)==(value>0)) continue;
        PDKL_RemoveEmpower(owner,slot);
        string key=PDKL_Key("EMP_GEN",slot);int generation=GetLocalInt(owner,key)+1;
        SetLocalInt(owner,key,generation);
        tag="PDKL_EMP_"+ObjectToString(owner)+"_"+IntToString(slot)+"_"+IntToString(generation);
        SetLocalObject(owner,PDKL_Key("EMP_TARGET",slot),target);
        SetLocalInt(owner,PDKL_Key("EMP_KIND",slot),kind);
        SetLocalInt(owner,PDKL_Key("EMP_VALUE",slot),value);
        SetLocalString(owner,PDKL_Key("EMP_TAG",slot),tag);
        if(value>0)
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,
                TagEffect(SetEffectCreator(SupernaturalEffect(EffectACIncrease(value,
                    kind==5?AC_DODGE_BONUS:AC_SHIELD_ENCHANTMENT_BONUS)),owner),tag),target);
    }
    if(abslot) PDKL_NativeLink(owner,GetLocalObject(owner,PDKL_Key("TARGET",abslot)),abslot);
    else PDKL_NativeLink(owner,OBJECT_INVALID,0);
}

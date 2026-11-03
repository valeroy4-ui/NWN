int DQS_Enabled(string feature)
{
    if(DQC_C("reward_policy")!=2)return FALSE; // Existing durable item entitlement schema is mandatory.
    json settings=JsonObjectGet(DQC_Config(),"special_contracts_v07");
    if (JsonGetType(settings)==JSON_TYPE_NULL) return TRUE;
    return DQC_Int(settings,feature);
}
int DQS_LevelAllowed(int killerLevel,int victimLevel,int areaFaction,int victimFaction)
{
    return victimLevel-killerLevel >= -5 || (areaFaction != 0 && areaFaction != victimFaction);
}
json DQS_KeyReward(int quantity)
{
    json reward=DQC_Reward();json items=JsonArray();
    if(quantity>0)
    {
        json item=JsonObject();JsonObjectSetInplace(item,"resref",JsonString("fl_inst_key"));
        JsonObjectSetInplace(item,"quantity",JsonInt(quantity));JsonObjectSetInplace(item,"charges",JsonInt(0));
        JsonObjectSetInplace(item,"category",JsonString("BLUE"));JsonObjectSetInplace(item,"label",JsonString("Newbie Instance Key"));
        JsonArrayInsertInplace(items,item);
    }
    JsonObjectSetInplace(reward,"items",items);return reward;
}
// The three actual Herald ResRefs are one encounter, never three pool entries.
int DQS_IsHerald(string ref)
{
    return ref=="cr_hrldanger" || ref=="cr_hrlddeath" || ref=="cr_hrlddoom";
}
json DQS_GroupMiniPool(json raw)
{
    raw=JsonParse(JsonDump(raw));json pool=JsonArray();json members=JsonArray();json seen=JsonObject();int i;
    for(i=0;i<JsonGetLength(raw);i++)
    {
        json boss=JsonArrayGet(raw,i);string ref=DQC_Str(boss,"resref");
        if(!DQS_IsHerald(ref)){JsonArrayInsertInplace(pool,boss);continue;}
        if(DQC_Int(seen,ref))continue;
        JsonObjectSetInplace(seen,ref,JsonInt(TRUE));
        JsonObjectSetInplace(boss,"done",JsonInt(FALSE));JsonObjectSetInplace(boss,"keys",JsonInt(0));
        JsonArrayInsertInplace(members,boss);
    }
    // Never offer a partial/unverified trio if a blue row, UTC or drop adapter is missing.
    if(JsonGetLength(members)==3)
    {
        json group=JsonObject();JsonObjectSetInplace(group,"resref",JsonString("cr_hrldanger"));
        JsonObjectSetInplace(group,"name",JsonString("Heralds of Anger, Death and Doom"));
        JsonObjectSetInplace(group,"members",members);JsonArrayInsertInplace(pool,group);
    }
    return pool;
}
json DQS_MiniRefs(json target)
{
    json refs=JsonArray();json members=JsonObjectGet(target,"members");int i;
    if(JsonGetLength(members)==0)JsonArrayInsertInplace(refs,JsonObjectGet(target,"resref"));
    else for(i=0;i<JsonGetLength(members);i++)JsonArrayInsertInplace(refs,JsonObjectGet(JsonArrayGet(members,i),"resref"));
    return refs;
}
string DQS_MiniNames(json targets)
{
    string names;int i;int j;
    for(i=0;i<JsonGetLength(targets);i++)
    {
        json target=JsonArrayGet(targets,i);if(names!="")names+="\n";
        names+=(DQC_Int(target,"done")?"[done] ":"[ ] ")+DQC_Str(target,"name");
        json members=JsonObjectGet(target,"members");int count=JsonGetLength(members);int done=0;
        for(j=0;j<count;j++)done+=DQC_Int(JsonArrayGet(members,j),"done")?1:0;
        if(count>0)names+=" ("+IntToString(done)+"/"+IntToString(count)+")";
    }
    return names;
}
int DQS_MiniHasMemberProgress(json quest)
{
    if(DQC_Str(quest,"kind")!="mini_set")return FALSE;
    json targets=JsonObjectGet(quest,"targets");int i;int j;
    for(i=0;i<JsonGetLength(targets);i++)
    {
        json members=JsonObjectGet(JsonArrayGet(targets,i),"members");
        for(j=0;j<JsonGetLength(members);j++)if(DQC_Int(JsonArrayGet(members,j),"done"))return TRUE;
    }
    return FALSE;
}
json DQS_CreateMini(json q)
{
    json pool=JsonParse(JsonDump(GetLocalJson(GetModule(),"DQS_MINI_POOL_V07")));
    if(JsonGetLength(pool)<5) return JsonNull();
    json targets=JsonArray();json refs=JsonArray();string names;int i;
    for(i=0;i<5;i++)
    {
        int pick=Random(JsonGetLength(pool));json target=JsonParse(JsonDump(JsonArrayGet(pool,pick)));
        JsonArrayDelInplace(pool,pick);JsonObjectSetInplace(target,"done",JsonInt(FALSE));
        JsonArrayInsertInplace(targets,target);json targetRefs=DQS_MiniRefs(target);int j;
        for(j=0;j<JsonGetLength(targetRefs);j++)JsonArrayInsertInplace(refs,JsonArrayGet(targetRefs,j));
        if(names!="")names+="\n";names+=IntToString(i+1)+". "+DQC_Str(target,"name");
    }
    JsonObjectSetInplace(q,"targets",targets);JsonObjectSetInplace(q,"resrefs",refs);
    JsonObjectSetInplace(q,"locations",JsonString(names));JsonObjectSetInplace(q,"keys_total",JsonInt(0));
    JsonObjectSetInplace(q,"required",JsonInt(5));JsonObjectSetInplace(q,"base_count",JsonInt(5));
    JsonObjectSetInplace(q,"roll",JsonInt(0));JsonObjectSetInplace(q,"die_sides",JsonInt(0));
    JsonObjectSetInplace(q,"reward",DQS_KeyReward(0));return q;
}

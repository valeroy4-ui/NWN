#include "dq_config"
#include "dq_defs"

// Pure contract transitions. No PC locals, SQL, party loops or reward side effects.
int DQC_Int(json value, string key) { return JsonGetInt(JsonObjectGet(value,key)); }
string DQC_Str(json value, string key) { return JsonGetString(JsonObjectGet(value,key)); }
int DQS_Enabled(string feature);
json DQC_Config()
{
    json cfg = GetLocalJson(GetModule(),"DQ_CONFIG_V05");
    if (JsonGetType(cfg) != JSON_TYPE_OBJECT) cfg = DQC_DefaultConfig();
    return cfg;
}
int DQC_C(string key) { return DQC_Int(DQC_Config(),key); }
int DQC_Cycle(int utc)
{
    // Moscow is UTC+3 with no daylight saving. 09:00 MSK is 06:00 UTC.
    if (utc <= 0) return -1;
    return (utc+DQC_C("moscow_utc_offset_seconds")-DQC_C("reset_hour_moscow")*3600)/86400;
}
// Cached catalogue is read-only. DQC_Create deep-copies the chosen definition.
json DQC_Catalogue()
{
    json definitions = GetLocalJson(GetModule(),"DQ_DEFINITIONS_V05");
    if (JsonGetType(definitions) != JSON_TYPE_ARRAY)
    {
        definitions = DQC_Definitions();
        JsonArrayInsertInplace(definitions,JsonParse("{\"id\":\"MINI_BLUE_V07\",\"kind\":\"mini_set\",\"title\":\"Mini Boss Hunt\",\"cr\":0.0,\"min_phase\":1,\"icon\":0,\"resrefs\":[],\"locations\":\"Five named mini bosses\"}"));
        JsonArrayInsertInplace(definitions,JsonParse("{\"id\":\"PVP_V07\",\"kind\":\"pvp_hunt\",\"title\":\"PvP Hunt\",\"cr\":0.0,\"min_phase\":1,\"icon\":0,\"resrefs\":[],\"locations\":\"Defeat distinct enemy players. Fame level restriction applies.\"}"));
        SetLocalJson(GetModule(),"DQ_DEFINITIONS_V05",definitions);
    }
    return definitions;
}
json DQC_Reward(int gold = 0, int coins = 0, int fame = 0)
{
    json value = JsonObject();
    JsonObjectSetInplace(value,"gold",JsonInt(gold));
    JsonObjectSetInplace(value,"coins",JsonInt(coins));
    JsonObjectSetInplace(value,"fame",JsonInt(fame));
    return value;
}
#include "dq_rewardpool"
#include "dq_special"
int DQC_Overlap(json a, json b)
{
    if (DQC_Str(a,"definition_id") != "" && DQC_Str(a,"definition_id") == DQC_Str(b,"id")) return TRUE;
    json ar = JsonObjectGet(a,"resrefs"); json br = JsonObjectGet(b,"resrefs");
    int i; int j;
    for (i = 0; i < JsonGetLength(ar); i++)
        for (j = 0; j < JsonGetLength(br); j++)
            if (JsonGetString(JsonArrayGet(ar,i)) == JsonGetString(JsonArrayGet(br,j))) return TRUE;
    return FALSE;
}
json DQC_Pool(json definitions, json assigned, int phase, int level, string exclude = "", string desired = "", int currentCycle = -1)
{
    json result = JsonArray(); int i; int j;
    if (phase < 1 || phase > 4) return result;
    json used = JsonObject();
    int champions = 0; int minis = 0; int pvps = 0;
    for (i = 0; i < JsonGetLength(assigned); i++)
    {
        json old = JsonArrayGet(assigned,i);
        if (currentCycle < 0 || DQC_Int(old,"origin_cycle") == currentCycle)
        {
            if (DQC_Str(old,"kind") == "mini_set") minis++;
            if (DQC_Str(old,"kind") == "pvp_hunt") pvps++;
        }
        if (DQC_Int(old,"reward_claimed")) continue;
        // New offers are unique within their cycle. Overlaps with preserved
        // carry are queued, never simultaneously eligible for kill credit.
        if (currentCycle >= 0 && DQC_Int(old,"origin_cycle") != currentCycle) continue;
        if (DQC_Str(old,"kind") == "champion" || DQC_Str(old,"kind") == "champion_any") champions++;
        JsonObjectSetInplace(used,"id:"+DQC_Str(old,"definition_id"),JsonInt(TRUE));
        json refs = JsonObjectGet(old,"resrefs");
        for (j = 0; j < JsonGetLength(refs); j++)
            JsonObjectSetInplace(used,JsonGetString(JsonArrayGet(refs,j)),JsonInt(TRUE));
    }
    int cap = JsonGetInt(JsonArrayGet(JsonObjectGet(DQC_Config(),"phase_cr_caps"),phase-1));
    if (cap > level+DQC_C("level_cr_allowance")) cap = level+DQC_C("level_cr_allowance");
    for (i = 0; i < JsonGetLength(definitions); i++)
    {
        json q = JsonArrayGet(definitions,i);
        string kind = DQC_Str(q,"kind");
        if (desired != "" && kind != desired) continue;
        if (DQC_Str(q,"id") == exclude || DQC_Int(q,"min_phase") > phase ||
            JsonGetFloat(JsonObjectGet(q,"cr")) > IntToFloat(cap)) continue;
        if (kind != "hunt" && kind != "champion" && kind != "mini_set" && kind != "pvp_hunt") continue;
        if (kind == "mini_set" && (!DQS_Enabled("mini_enabled") || minis > 0 || JsonGetLength(GetLocalJson(GetModule(),"DQS_MINI_POOL_V07")) < 5)) continue;
        if (kind == "pvp_hunt" && (!DQS_Enabled("pvp_enabled") || pvps > 0 || level < 2)) continue;
        if (kind == "champion" && (!DQC_C("champion_contracts_enabled") || champions >= DQC_C("champion_slots"))) continue;
        int conflict = DQC_Int(used,"id:"+DQC_Str(q,"id"));
        json refs = JsonObjectGet(q,"resrefs");
        for (j = 0; j < JsonGetLength(refs); j++)
        {
            if (DQC_Int(used,JsonGetString(JsonArrayGet(refs,j)))) conflict = TRUE;
        }
        if (!conflict) JsonArrayInsertInplace(result,q);
    }
    return result;
}
json DQC_Pick(json pool, int level)
{
    int total = 0; int i;
    int near = DQC_C("weight_near"); int far = DQC_C("weight_far"); int cutoff = DQC_C("near_cr_distance");
    for (i = 0; i < JsonGetLength(pool); i++)
    {
        int distance = FloatToInt(JsonGetFloat(JsonObjectGet(JsonArrayGet(pool,i),"cr")))-level;
        if (distance < 0) distance = -distance;
        total += distance <= cutoff ? near : far;
    }
    if (total <= 0) return JsonNull();
    int roll = Random(total);
    for (i = 0; i < JsonGetLength(pool); i++)
    {
        json q = JsonArrayGet(pool,i);
        int distance = FloatToInt(JsonGetFloat(JsonObjectGet(q,"cr")))-level;
        if (distance < 0) distance = -distance;
        roll -= distance <= cutoff ? near : far;
        if (roll < 0) return q;
    }
    return JsonNull();
}
json DQC_Create(json definition, int owner, int cycle, int sequence, int phase, int utc, string previous = "")
{
    json q = JsonParse(JsonDump(definition));
    int baseCount = DQC_C("hunt_base"); int die = DQC_C("hunt_die");
    int roll = 1+Random(die); int required = baseCount+roll;
    int cr = FloatToInt(JsonGetFloat(JsonObjectGet(q,"cr")));
    json bands = JsonObjectGet(DQC_Config(),"hunt_gold_bands"); int base; int i;
    for (i = 0; i < JsonGetLength(bands); i++)
    {
        json band = JsonArrayGet(bands,i);
        if (cr <= JsonGetInt(JsonArrayGet(band,0))) { base = JsonGetInt(JsonArrayGet(band,1)); break; }
    }
    // Integer nearest-1000 rounding; snapshot the actual roll and reward.
    int gold = ((base*required/20+500)/1000)*1000;
    json reward = DQC_Reward(gold);
    int rewardRequired=required;
    if (DQC_Str(q,"kind") == "champion")
    {
        json settings = JsonObjectGet(JsonObjectGet(DQC_Config(),"special_rewards"),"champion");
        baseCount = DQC_C("hunt_base"); die = DQC_C("hunt_die");
        roll = 1+Random(die); required = baseCount+roll;
        rewardRequired=DQC_Int(settings,"required_base")+1+Random(DQC_Int(settings,"required_die"));
        JsonObjectSetInplace(q,"reward_basis_required",JsonInt(rewardRequired));
        int low = DQC_Int(settings,"gold_min")/1000; int high = DQC_Int(settings,"gold_max")/1000;
        int fame = Random(100) < DQC_Int(settings,"fame_chance") ? DQC_Int(settings,"fame") : 0;
        reward = DQC_Reward((low+Random(high-low+1))*1000,0,fame);
    }
    if (DQC_Int(DQC_Config(),"reward_policy") == 2)
    {
        gold = DQR_CategoryGold(JsonGetFloat(JsonObjectGet(q,"cr")),rewardRequired,DQC_Str(q,"kind"),DQC_Int(reward,"gold"));
        reward = DQR_Additional(DQC_Reward(gold),JsonGetFloat(JsonObjectGet(q,"cr")),DQC_Str(q,"kind"),rewardRequired);
    }
    // Existing eligible champion definitions retain their verified reward basis.
    // Only NEW snapshots become generic. Saved specific contracts are untouched.
    if (DQC_Str(q,"kind") == "champion")
    {
        JsonObjectSetInplace(q,"reward_basis_title",JsonObjectGet(q,"title"));
        JsonObjectSetInplace(q,"reward_basis_resrefs",JsonObjectGet(q,"resrefs"));
        JsonObjectSetInplace(q,"kind",JsonString("champion_any"));
        JsonObjectSetInplace(q,"title",JsonString("Champion Hunt"));
        JsonObjectSetInplace(q,"locations",JsonString("Any ordinary Champion, anywhere. Grand Champions and bosses do not count."));
        JsonObjectSetInplace(q,"resrefs",JsonArray());
    }
    if (DQC_Str(q,"kind") == "pvp_hunt")
    {
        baseCount=0;die=phase<3?phase:3;roll=1+Random(die);required=roll;
        reward=DQR_Additional(DQC_Reward(DQC_Int(JsonObjectGet(JsonObjectGet(DQC_Config(),"special_rewards"),"pvp"),"gold")),0.0,"pvp",required);
        JsonObjectSetInplace(q,"victims",JsonObject());
    }
    JsonObjectSetInplace(q,"definition_id",JsonObjectGet(definition,"id"));
    if(DQC_Str(q,"kind")=="champion_any")
    {
        JsonObjectSetInplace(q,"reward_basis_definition_id",JsonObjectGet(definition,"id"));
        JsonObjectSetInplace(q,"definition_id",JsonString("C_ANY"));
    }
    JsonObjectSetInplace(q,"id",JsonString(IntToString(owner)+":"+IntToString(cycle)+":"+IntToString(sequence)));
    JsonObjectSetInplace(q,"owner",JsonInt(owner));
    JsonObjectSetInplace(q,"origin_cycle",JsonInt(cycle));
    JsonObjectSetInplace(q,"required",JsonInt(required));
    JsonObjectSetInplace(q,"roll",JsonInt(roll));
    JsonObjectSetInplace(q,"base_count",JsonInt(baseCount));
    JsonObjectSetInplace(q,"die_sides",JsonInt(die));
    JsonObjectSetInplace(q,"progress",JsonInt(0));
    JsonObjectSetInplace(q,"objective_completed",JsonInt(FALSE));
    JsonObjectSetInplace(q,"reward_claimed",JsonInt(FALSE));
    JsonObjectSetInplace(q,"reward",reward);
    JsonObjectSetInplace(q,"stage",JsonInt(phase));
    JsonObjectSetInplace(q,"created_at",JsonInt(utc));
    JsonObjectSetInplace(q,"rerolled_from",JsonString(previous));
    return DQC_Str(q,"kind") == "mini_set" ? DQS_CreateMini(q) : q;
}
json DQC_ChestReward(int phase, int chest, float maxAssignedCR = 0.0)
{
    if (DQC_Int(DQC_Config(),"reward_policy") == 2) return DQR_Chest(phase,chest,maxAssignedCR);
    json cfg = DQC_Config();
    int gold = JsonGetInt(JsonArrayGet(JsonArrayGet(JsonObjectGet(cfg,"milestone_gold"),phase-1),chest));
    int coins = JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"milestone_coins"),chest));
    int fame = 0; int choice = 0; int roll = Random(100); int i;
    json weights = JsonArrayGet(JsonObjectGet(cfg,"bonus_weights"),chest);
    for (i = 0; i < 4; i++) { roll -= JsonGetInt(JsonArrayGet(weights,i)); if (roll < 0) { choice = i; break; } }
    if (choice == 0) gold += JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"bonus_gold"),chest));
    else if (choice == 1) coins += DQC_C("bonus_coins");
    else if (choice == 2)
    {
        int low = JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"bonus_fame_min"),chest));
        int high = JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"bonus_fame_max"),chest));
        fame = low+Random(high-low+1);
    }
    // No verified category/durable item-delivery adapter: safe configured alternative.
    else gold += JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"key_fallback_gold"),chest));
    json reward = DQC_Reward(gold,coins,fame);
    JsonObjectSetInplace(reward,"bonus_choice",JsonInt(choice));
    if (choice == 3) JsonObjectSetInplace(reward,"key_fallback",JsonString("No verified eligible Instance Key category"));
    return reward;
}
json DQC_NewCycle(json state, json definitions, int owner, int phase, int level, int utc)
{
    int cycle = DQC_Cycle(utc);
    // Never destroy/rotate persisted progress on a failed or backwards clock.
    if (cycle <= 0 || owner <= 0 || phase < 1 || phase > 4 || DQC_Int(state,"cycle") > cycle) return JsonNull();
    if (JsonGetType(state) == JSON_TYPE_OBJECT && DQC_Int(state,"cycle") == cycle && !DQC_Int(state,"issuance_blocked")) return state;
    state = JsonParse(JsonDump(state));
    json carry = JsonArray(); json old = JsonObjectGet(state,"quests"); int i;
    for (i = 0; i < JsonGetLength(old); i++)
    {
        json q = JsonArrayGet(old,i);
        if (!DQC_Int(q,"reward_claimed") && (DQC_Int(q,"progress") > 0 || DQS_MiniHasMemberProgress(q))) JsonArrayInsertInplace(carry,q);
    }
    json assigned = JsonParse(JsonDump(carry));
    int sequence = DQC_Int(state,"sequence");
    int blocked = FALSE;
    for (i = 0; i < DQC_C("daily_count"); i++)
    {
        string wanted = DQC_C("champion_contracts_enabled") && i >= DQC_C("daily_count")-DQC_C("champion_slots") ? "champion" : "hunt";
        if(i == DQC_C("daily_count")-2 && DQS_Enabled("mini_enabled")) wanted="mini_set";
        if(i == DQC_C("daily_count")-3 && DQS_Enabled("pvp_enabled")) wanted="pvp_hunt";
        json pool = DQC_Pool(definitions,assigned,phase,level,"",wanted,cycle);
        if (JsonGetLength(pool) == 0 && wanted != "hunt") pool = DQC_Pool(definitions,assigned,phase,level,"","hunt",cycle);
        json definition = DQC_Pick(pool,level);
        // Atomic caller keeps the complete previous state; no partial daily issuance.
        if (JsonGetType(definition) != JSON_TYPE_OBJECT) { blocked = TRUE; break; }
        sequence++;
        JsonArrayInsertInplace(assigned,DQC_Create(definition,owner,cycle,sequence,phase,utc));
    }
    json result = JsonObject();
    JsonObjectSetInplace(result,"schema",JsonInt(1));
    JsonObjectSetInplace(result,"owner",JsonInt(owner));
    JsonObjectSetInplace(result,"cycle",JsonInt(cycle));
    JsonObjectSetInplace(result,"stage",JsonInt(phase));
    JsonObjectSetInplace(result,"sequence",JsonInt(sequence));
    JsonObjectSetInplace(result,"rerolls_remaining",JsonInt(DQC_C("rerolls")));
    JsonObjectSetInplace(result,"claimed_count",JsonInt(0));
    JsonObjectSetInplace(result,"chests",JsonParse("[0,0,0]"));
    JsonObjectSetInplace(result,"issuance_blocked",JsonInt(blocked));
    JsonObjectSetInplace(result,"quests",blocked ? carry : assigned);
    JsonObjectSetInplace(result,"pvp_seen",JsonParse(JsonDump(JsonObjectGet(state,"pvp_seen"))));
    float maxAssignedCR = 0.0;
    for (i = 0; i < JsonGetLength(assigned); i++)
    {
        json assignedQuest = JsonArrayGet(assigned,i);
        float cr = JsonGetFloat(JsonObjectGet(assignedQuest,"cr"));
        if (DQC_Int(assignedQuest,"origin_cycle") == cycle && cr > maxAssignedCR) maxAssignedCR = cr;
    }
    json rewards = JsonArray();
    if (DQC_Int(state,"cycle") == cycle) rewards = JsonObjectGet(state,"chest_rewards");
    else for (i = 0; i < 3; i++) JsonArrayInsertInplace(rewards,DQC_ChestReward(phase,i,maxAssignedCR));
    JsonObjectSetInplace(result,"chest_rewards",rewards);
    return result;
}
json DQC_Reroll(json state, json definitions, string id, int phase, int level, int utc, int confirm)
{
    state = JsonParse(JsonDump(state));
    if (DQC_Int(state,"rerolls_remaining") <= 0 || DQC_Int(state,"cycle") != DQC_Cycle(utc)) return JsonNull();
    json quests = JsonObjectGet(state,"quests"); int i;
    for (i = 0; i < JsonGetLength(quests); i++)
    {
        json q = JsonArrayGet(quests,i);
        if (DQC_Str(q,"id") != id) continue;
        if (DQC_Int(q,"origin_cycle") != DQC_Int(state,"cycle") || DQC_Int(q,"objective_completed") ||
            DQC_Int(q,"reward_claimed") || ((DQC_Int(q,"progress") > 0 || DQS_MiniHasMemberProgress(q)) && !confirm)) return JsonNull();
        // Include the previous row in conflict checks: overlapping targets cannot replace themselves.
        json pool = DQC_Pool(definitions,quests,phase,level,DQC_Str(q,"definition_id"),"",DQC_Int(state,"cycle"));
        json definition = DQC_Pick(pool,level);
        if (JsonGetType(definition) != JSON_TYPE_OBJECT) return JsonNull();
        int sequence = DQC_Int(state,"sequence")+1;
        JsonArraySetInplace(quests,i,DQC_Create(definition,DQC_Int(state,"owner"),DQC_Int(state,"cycle"),sequence,phase,utc,id));
        JsonObjectSetInplace(state,"sequence",JsonInt(sequence));
        JsonObjectSetInplace(state,"quests",quests);
        JsonObjectSetInplace(state,"rerolls_remaining",JsonInt(DQC_Int(state,"rerolls_remaining")-1));
        return state;
    }
    return JsonNull();
}
json DQC_CarryRefs(json state)
{
    json used = JsonObject(); json quests = JsonObjectGet(state,"quests"); int i; int j;
    for (i = 0; i < JsonGetLength(quests); i++)
    {
        json q = JsonArrayGet(quests,i);
        if (DQC_Int(q,"origin_cycle") == DQC_Int(state,"cycle") || DQC_Int(q,"reward_claimed")) continue;
        if (DQC_Str(q,"kind") == "champion" || DQC_Str(q,"kind") == "champion_any")
            JsonObjectSetInplace(used,"@champion",JsonInt(TRUE));
        if (DQC_Str(q,"kind") == "pvp_hunt") JsonObjectSetInplace(used,"@pvp",JsonInt(TRUE));
        json refs = JsonObjectGet(q,"resrefs");
        for (j = 0; j < JsonGetLength(refs); j++) JsonObjectSetInplace(used,JsonGetString(JsonArrayGet(refs,j)),JsonInt(TRUE));
    }
    return used;
}
int DQC_Waiting(json q, json carryRefs, int cycle)
{
    if (DQC_Int(q,"origin_cycle") != cycle || DQC_Int(q,"reward_claimed")) return FALSE;
    if (DQC_Str(q,"kind") == "champion_any" && DQC_Int(carryRefs,"@champion")) return TRUE;
    if (DQC_Str(q,"kind") == "pvp_hunt" && DQC_Int(carryRefs,"@pvp")) return TRUE;
    json refs = JsonObjectGet(q,"resrefs"); int i;
    for (i = 0; i < JsonGetLength(refs); i++) if (DQC_Int(carryRefs,JsonGetString(JsonArrayGet(refs,i)))) return TRUE;
    return FALSE;
}
json DQC_Credit(json state, string resref, string kind)
{
    state = JsonParse(JsonDump(state));
    json quests = JsonObjectGet(state,"quests"); int i; int j;
    json carryRefs = DQC_CarryRefs(state);
    // First: at most one ResRef-bound hunt or preserved old specific contract.
    for (i = 0; i < JsonGetLength(quests); i++)
    {
        json q = JsonArrayGet(quests,i);
        string objectiveKind = DQC_Str(q,"kind");
        int matchesKind = objectiveKind == kind || (objectiveKind == "hunt" && kind == "champion");
        if (DQC_Int(q,"reward_claimed") || DQC_Int(q,"objective_completed") || !matchesKind) continue;
        if (DQC_Waiting(q,carryRefs,DQC_Int(state,"cycle"))) continue;
        json refs = JsonObjectGet(q,"resrefs"); int matched = FALSE;
        for (j = 0; j < JsonGetLength(refs); j++)
            if (JsonGetString(JsonArrayGet(refs,j)) == resref) matched = TRUE;
        if (!matched) continue;
        int progress = DQC_Int(q,"progress")+1;
        JsonObjectSetInplace(q,"progress",JsonInt(progress));
        JsonObjectSetInplace(q,"objective_completed",JsonInt(progress >= DQC_Int(q,"required")));
        JsonArraySetInplace(quests,i,q);
        break;
    }
    // User-approved exception: the same ordinary Champion ALSO advances one
    // generic champion hunt. Its type, tag, ResRef and location are immaterial.
    if (kind == "champion")
    {
        for (i = 0; i < JsonGetLength(quests); i++)
        {
            json q = JsonArrayGet(quests,i);
            if (DQC_Str(q,"kind") != "champion_any" || DQC_Int(q,"reward_claimed") || DQC_Int(q,"objective_completed")) continue;
            if (DQC_Waiting(q,carryRefs,DQC_Int(state,"cycle"))) continue;
            int progress = DQC_Int(q,"progress")+1;
            JsonObjectSetInplace(q,"progress",JsonInt(progress));
            JsonObjectSetInplace(q,"objective_completed",JsonInt(progress >= DQC_Int(q,"required")));
            JsonArraySetInplace(quests,i,q);
            break;
        }
    }
    JsonObjectSetInplace(state,"quests",quests);
    return state;
}
json DQS_CreditMini(json state,string resref,int keyCount)
{
    if(resref=="cr_drmundo" || keyCount<0 || keyCount>200) return state;
    state=JsonParse(JsonDump(state));json quests=JsonObjectGet(state,"quests");json carry=DQC_CarryRefs(state);int i;int j;
    for(i=0;i<JsonGetLength(quests);i++)
    {
        json q=JsonArrayGet(quests,i);
        if(DQC_Str(q,"kind")!="mini_set" || DQC_Int(q,"reward_claimed") || DQC_Int(q,"objective_completed") || DQC_Waiting(q,carry,DQC_Int(state,"cycle")))continue;
        json targets=JsonObjectGet(q,"targets");
        for(j=0;j<JsonGetLength(targets);j++)
        {
            json t=JsonArrayGet(targets,j);
            if(DQC_Int(t,"done"))continue;
            json members=JsonObjectGet(t,"members");int count=JsonGetLength(members);int completed=TRUE;
            if(count>0)
            {
                int m;int matched=FALSE;
                for(m=0;m<count;m++)
                {
                    json member=JsonArrayGet(members,m);
                    if(DQC_Str(member,"resref")!=resref)continue;
                    if(DQC_Int(member,"done"))return state;
                    JsonObjectSetInplace(member,"done",JsonInt(TRUE));JsonObjectSetInplace(member,"keys",JsonInt(keyCount));
                    JsonArraySetInplace(members,m,member);matched=TRUE;break;
                }
                if(!matched)continue;
                for(m=0;m<count;m++)if(!DQC_Int(JsonArrayGet(members,m),"done"))completed=FALSE;
                JsonObjectSetInplace(t,"members",members);
                JsonObjectSetInplace(t,"keys",JsonInt(DQC_Int(t,"keys")+keyCount));
            }
            else
            {
                // Preserve already assigned legacy snapshots and their actual saved key totals.
                if(DQC_Str(t,"resref")!=resref)continue;
                JsonObjectSetInplace(t,"keys",JsonInt(keyCount));
            }
            JsonObjectSetInplace(t,"done",JsonInt(completed));JsonArraySetInplace(targets,j,t);
            int progress=DQC_Int(q,"progress")+(completed?1:0);int total=DQC_Int(q,"keys_total")+keyCount;
            JsonObjectSetInplace(q,"locations",JsonString(DQS_MiniNames(targets)));
            JsonObjectSetInplace(q,"targets",targets);JsonObjectSetInplace(q,"progress",JsonInt(progress));JsonObjectSetInplace(q,"keys_total",JsonInt(total));
            JsonObjectSetInplace(q,"objective_completed",JsonInt(progress>=5));
            if(progress>=5)JsonObjectSetInplace(q,"reward",DQS_KeyReward(total/4));
            JsonArraySetInplace(quests,i,q);JsonObjectSetInplace(state,"quests",quests);return state;
        }
    }
    return state;
}
json DQS_CreditPvP(json state,int victim,int now)
{
    if(victim<=0 || now<=0)return state;
    string key=IntToString(victim);json seen=JsonObjectGet(state,"pvp_seen");int last=DQC_Int(seen,key);
    if(last>0 && now-last<DQC_C("pvp_pair_cooldown_seconds"))return state;
    state=JsonParse(JsonDump(state));seen=JsonObjectGet(state,"pvp_seen");
    if(JsonGetType(seen)!=JSON_TYPE_OBJECT)seen=JsonObject();
    json quests=JsonObjectGet(state,"quests");json carry=DQC_CarryRefs(state);int i;
    for(i=0;i<JsonGetLength(quests);i++)
    {
        json q=JsonArrayGet(quests,i);
        if(DQC_Str(q,"kind")!="pvp_hunt" || DQC_Int(q,"reward_claimed") || DQC_Int(q,"objective_completed") || DQC_Waiting(q,carry,DQC_Int(state,"cycle")))continue;
        json victims=JsonObjectGet(q,"victims");if(DQC_Int(victims,key))continue;
        if(JsonGetType(victims)!=JSON_TYPE_OBJECT)victims=JsonObject();
        JsonObjectSetInplace(victims,key,JsonInt(now));JsonObjectSetInplace(q,"victims",victims);
        int progress=DQC_Int(q,"progress")+1;JsonObjectSetInplace(q,"progress",JsonInt(progress));
        JsonObjectSetInplace(q,"objective_completed",JsonInt(progress>=DQC_Int(q,"required")));
        JsonObjectSetInplace(seen,key,JsonInt(now));JsonObjectSetInplace(state,"pvp_seen",seen);
        JsonArraySetInplace(quests,i,q);JsonObjectSetInplace(state,"quests",quests);return state;
    }
    return state;
}
json DQC_Claim(json state, string id)
{
    state = JsonParse(JsonDump(state));
    json quests = JsonObjectGet(state,"quests"); int i;
    for (i = 0; i < JsonGetLength(quests); i++)
    {
        json q = JsonArrayGet(quests,i);
        if (DQC_Str(q,"id") != id) continue;
        if (!DQC_Int(q,"objective_completed") || DQC_Int(q,"reward_claimed") ||
            DQC_Int(q,"required") <= 0 || DQC_Int(q,"progress") < DQC_Int(q,"required")) return JsonNull();
        JsonObjectSetInplace(q,"reward_claimed",JsonInt(TRUE));
        JsonArraySetInplace(quests,i,q);
        JsonObjectSetInplace(state,"quests",quests);
        if (DQC_Int(q,"origin_cycle") == DQC_Int(state,"cycle"))
            JsonObjectSetInplace(state,"claimed_count",JsonInt(DQC_Int(state,"claimed_count")+1));
        return state;
    }
    return JsonNull();
}
json DQC_ClaimChest(json state, int index)
{
    state = JsonParse(JsonDump(state));
    if (index < 0 || index >= 3) return JsonNull();
    json flags = JsonObjectGet(state,"chests");
    int threshold = JsonGetInt(JsonArrayGet(JsonObjectGet(DQC_Config(),"thresholds"),index));
    if (DQC_Int(state,"claimed_count") < threshold || JsonGetInt(JsonArrayGet(flags,index))) return JsonNull();
    JsonArraySetInplace(flags,index,JsonInt(TRUE));
    JsonObjectSetInplace(state,"chests",flags);
    return state;
}

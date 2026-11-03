#include "dq_core"
#include "_inc_players"
#include "dq_progress_inc"
#include "nw_inc_gff"

// Existing persistent character identity and NWNX SQL connection are reused.
// All contract, receipt, wallet and existing bank/Fame writes share one transaction.
int DQC_Now()
{
    sqlquery query = SqlPrepareQueryObject(GetModule(),"SELECT CAST(strftime('%s','now') AS INTEGER)");
    if (!SqlStep(query)) return 0;
    return SqlGetInt(query,0);
}
int DQC_Query(string statement) { return NWNX_SQL_ExecuteQuery(statement) != 0; }
void DQC_Abort() { DQC_Query("ROLLBACK"); }
#include "dq_itemstore"
void DQC_Error(object pc, string code)
{
    SetLocalString(pc,"DQ_LAST_ERROR",code);
    PrintString("[DQ ERROR] character="+IntToString(players_GetPCPersistentID(pc))+" stage="+code);
}
int DQS_TemplateHasKeys(json blueprint)
{
    json inventory=GffGetList(blueprint,"ItemList");int i;
    for(i=0;i<JsonGetLength(inventory);i++)
    {
        json item=JsonArrayGet(inventory,i);
        if(!JsonGetInt(GffGetByte(item,"Dropable")))continue;
        string ref=JsonGetString(GffGetResRef(item,"InventoryRes"));
        // This is the existing SetTimeStampValidation key classification.
        if(FindSubString(ref,"_key")>=0)return TRUE;
        if(ref!="" && ResManGetAliasFor(ref,RESTYPE_UTI)!="")
        {
            json data=TemplateToJson(ref,RESTYPE_UTI);
            if(JsonGetInt(GffGetInt(data,"BaseItem"))==BASE_ITEM_KEY)return TRUE;
        }
    }
    return FALSE;
}
int DQS_LoadMiniPool()
{
    json pool=JsonArray();
    if(!DQC_Query("SELECT boss_resref,boss_name FROM boss_cooldowns WHERE LOWER(category)='blue' ORDER BY boss_resref"))return FALSE;
    while(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();string ref=GetStringLowerCase(NWNX_SQL_ReadDataInActiveRow(0));string name=NWNX_SQL_ReadDataInActiveRow(1);
        if(ref=="cr_drmundo")continue;
        if(ResManGetAliasFor(ref,RESTYPE_UTC)=="")continue;
        json blueprint=TemplateToJson(ref,RESTYPE_UTC);
        if(JsonGetType(blueprint)!=JSON_TYPE_OBJECT)continue;
        if(JsonGetString(GffGetResRef(blueprint,"ScriptDeath"))!="nw_c2_default7" || !DQS_TemplateHasKeys(blueprint))continue;
        json boss=JsonObject();JsonObjectSetInplace(boss,"resref",JsonString(ref));
        JsonObjectSetInplace(boss,"name",JsonString(name!=""?name:ref));JsonArrayInsertInplace(pool,boss);
    }
    SetLocalJson(GetModule(),"DQS_MINI_POOL_V07",DQS_GroupMiniPool(pool));return TRUE;
}
int DQS_MiniKeyCount(object victim)
{
    string ref=GetStringLowerCase(GetResRef(victim));if(ref=="cr_drmundo")return -1;
    json pool=GetLocalJson(GetModule(),"DQS_MINI_POOL_V07");int found=FALSE;int i;
    for(i=0;i<JsonGetLength(pool);i++)
    {
        json refs=DQS_MiniRefs(JsonArrayGet(pool,i));int j;
        for(j=0;j<JsonGetLength(refs);j++)if(JsonGetString(JsonArrayGet(refs,j))==ref)found=TRUE;
    }
    if(!found)return -1;
    int count=0;object item=GetFirstItemInInventory(victim);
    while(GetIsObjectValid(item))
    {
        if(GetDroppableFlag(item) && (GetBaseItemType(item)==BASE_ITEM_KEY || FindSubString(GetStringLowerCase(GetResRef(item)),"_key")>=0))count+=GetItemStackSize(item);
        if(count>200)return -1;
        item=GetNextItemInInventory(victim);
    }
    return count;
}
int DQC_ValidConfig(json cfg)
{
    if (DQC_Int(cfg,"schema") != 1 || DQC_Int(cfg,"daily_count") != 15 ||
        DQC_Int(cfg,"hunt_base") != 15 || DQC_Int(cfg,"hunt_die") != 10 ||
        DQC_Int(cfg,"moscow_utc_offset_seconds") != 10800 || DQC_Int(cfg,"reset_hour_moscow") != 9 ||
        DQC_Int(cfg,"rerolls") != 3 || DQC_Int(cfg,"level_cr_allowance") < 0 || DQC_Int(cfg,"level_cr_allowance") > 30 ||
        DQC_Int(cfg,"weight_far") <= 0 || DQC_Int(cfg,"weight_near") <= 0 ||
        DQC_Int(cfg,"account_daily_limit") != 0 ||
        DQC_Int(cfg,"champion_slots") < 0 || DQC_Int(cfg,"champion_slots") > 1 || DQC_Int(cfg,"boss_contracts_enabled") ||
        DQC_Int(cfg,"instance_contracts_enabled") || DQC_Int(cfg,"pvp_contracts_enabled") ||
        JsonGetLength(JsonObjectGet(cfg,"allowed_key_categories")) != 0) return FALSE;
    if (JsonDump(JsonObjectGet(cfg,"thresholds")) != "[5,10,15]") return FALSE;
    if (JsonGetLength(JsonObjectGet(cfg,"milestone_gold")) != 4 ||
        JsonGetLength(JsonObjectGet(cfg,"bonus_weights")) != 3) return FALSE;
    if (JsonGetLength(JsonObjectGet(cfg,"phase_cr_caps")) != 4 || JsonGetLength(JsonObjectGet(cfg,"hunt_gold_bands")) != 6 ||
        DQC_Int(cfg,"bonus_coins") < 0 || DQC_Int(cfg,"bonus_coins") > 1000) return FALSE;
    int i; int j;
    for (i = 0; i < 4; i++)
    {
        int cap = JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"phase_cr_caps"),i));
        if (cap < 1 || cap > (i == 0 ? 29 : (i == 1 ? 39 : (i == 2 ? 49 : 999)))) return FALSE;
        json golds = JsonArrayGet(JsonObjectGet(cfg,"milestone_gold"),i);
        if (JsonGetLength(golds) != 3) return FALSE;
        for (j = 0; j < 3; j++) if (JsonGetInt(JsonArrayGet(golds,j)) < 0 || JsonGetInt(JsonArrayGet(golds,j)) > 10000000) return FALSE;
    }
    for (i = 0; i < 3; i++)
    {
        json weights = JsonArrayGet(JsonObjectGet(cfg,"bonus_weights"),i); int sum = 0;
        if (JsonGetLength(weights) != 4) return FALSE;
        for (j = 0; j < 4; j++) { int weight = JsonGetInt(JsonArrayGet(weights,j)); if (weight < 0) return FALSE; sum += weight; }
        if (sum != 100) return FALSE;
        int low = JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"bonus_fame_min"),i));
        int high = JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"bonus_fame_max"),i));
        if (low < 0 || high < low || high > 1000) return FALSE;
        int gold = JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"bonus_gold"),i));
        int fallback = JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"key_fallback_gold"),i));
        int coins = JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"milestone_coins"),i));
        if (gold < 0 || gold > 10000000 || fallback < 0 || fallback > 10000000 || coins < 0 || coins > 1000) return FALSE;
    }
    for (i = 0; i < 6; i++)
    {
        json band = JsonArrayGet(JsonObjectGet(cfg,"hunt_gold_bands"),i);
        if (JsonGetLength(band) != 2 || JsonGetInt(JsonArrayGet(band,1)) < 0 || JsonGetInt(JsonArrayGet(band,1)) > 1000000) return FALSE;
    }
    json champion = JsonObjectGet(JsonObjectGet(cfg,"special_rewards"),"champion");
    if (DQC_Int(champion,"required_base") < 0 || DQC_Int(champion,"required_base") > 10 ||
        DQC_Int(champion,"required_die") < 1 || DQC_Int(champion,"required_die") > 10 ||
        DQC_Int(champion,"gold_min") < 0 || DQC_Int(champion,"gold_max") < DQC_Int(champion,"gold_min") ||
        DQC_Int(champion,"gold_max") > 10000000 || DQC_Int(champion,"fame") < 0 || DQC_Int(champion,"fame") > 1000 ||
        DQC_Int(champion,"fame_chance") < 0 || DQC_Int(champion,"fame_chance") > 100) return FALSE;
    json special=JsonObjectGet(cfg,"special_contracts_v07");
    if(JsonGetType(special)!=JSON_TYPE_NULL && JsonGetType(special)!=JSON_TYPE_OBJECT)return FALSE;
    int policy = DQC_Int(cfg,"reward_policy");
    if (policy != 0 && policy != 2) return FALSE;
    if (policy == 2 && !DQR_Valid(JsonObjectGet(cfg,"reward_v06"))) return FALSE;
    return TRUE;
}
int DQC_Ready(int force = FALSE)
{
    int now = DQC_Now(); object module = GetModule();
    if (now <= 0) return FALSE;
    if (!force && GetLocalInt(module,"DQ_CONFIG_CHECK_AFTER") > now)
        return GetLocalInt(module,"DQ_CONFIG_READY");
    SetLocalInt(module,"DQ_CONFIG_CHECK_AFTER",now+60);
    SetLocalInt(module,"DQ_CONFIG_READY",FALSE);
    if (!DQC_Query("SELECT schema_version, config_json FROM dq_meta_v05 WHERE id = 1") || !NWNX_SQL_ReadyToReadNextRow()) return FALSE;
    NWNX_SQL_ReadNextRow();
    if (StringToInt(NWNX_SQL_ReadDataInActiveRow(0)) != 1) return FALSE;
    string rawConfig = NWNX_SQL_ReadDataInActiveRow(1);
    json cfg = JsonParse(rawConfig);
    if (!DQC_ValidConfig(cfg) || !DQC_Int(cfg,"live_enabled")) return FALSE;
    if (DQC_Int(cfg,"reward_policy") == 2 && !DQR_OutboxReady()) return FALSE;
    SetLocalString(module,"DQ_CONFIG_RAW_V05",rawConfig);
    SetLocalJson(module,"DQ_CONFIG_V05",cfg);
    if(DQS_Enabled("mini_enabled") && !DQS_LoadMiniPool())return FALSE;
    SetLocalInt(module,"DQ_CONFIG_READY",TRUE);
    return TRUE;
}
json DQC_Read(object pc)
{
    int owner = players_GetPCPersistentID(pc);
    if (owner <= 0) return JsonNull();
    NWNX_SQL_PrepareQuery("SELECT D.payload FROM dq_contract_state_v05 D JOIN characters C ON C.id = D.character_id WHERE D.character_id = ? AND C.account = ?");
    NWNX_SQL_PreparedInt(0,owner); NWNX_SQL_PreparedString(1,GetPCPlayerName(pc));
    if (!NWNX_SQL_ExecutePreparedQuery() || !NWNX_SQL_ReadyToReadNextRow()) return JsonNull();
    NWNX_SQL_ReadNextRow();
    return JsonParse(NWNX_SQL_ReadDataInActiveRow());
}
json DQC_Begin(object pc, int create)
{
    DeleteLocalString(pc,"DQ_LAST_ERROR");
    int now = DQC_Now();
    if (now <= 0) { DQC_Error(pc,"clock_unavailable"); return JsonNull(); }
    SetLocalInt(pc,"DQ_TX_NOW",now);
    int owner = players_GetPCPersistentID(pc);
    if (owner <= 0 || GetIsDM(pc) || GetIsDMPossessed(pc)) { DQC_Error(pc,"identity_unavailable"); return JsonNull(); }
    if (!DQC_Query("START TRANSACTION")) { DQC_Error(pc,"transaction_begin"); return JsonNull(); }
    // Check ownership in the real characters table; never trust a window index.
    NWNX_SQL_PrepareQuery("SELECT id FROM characters WHERE id = ? AND account = ?");
    NWNX_SQL_PreparedInt(0,owner); NWNX_SQL_PreparedString(1,GetPCPlayerName(pc));
    if (!NWNX_SQL_ExecutePreparedQuery() || !NWNX_SQL_ReadyToReadNextRow()) { DQC_Error(pc,"ownership_check"); DQC_Abort(); return JsonNull(); }
    if (create)
    {
        NWNX_SQL_PrepareQuery("INSERT IGNORE INTO dq_contract_state_v05 (character_id, revision, payload) VALUES (?, 0, '{}')");
        NWNX_SQL_PreparedInt(0,owner);
        if (!NWNX_SQL_ExecutePreparedQuery()) { DQC_Abort(); return JsonNull(); }
    }
    NWNX_SQL_PrepareQuery("SELECT payload, revision FROM dq_contract_state_v05 WHERE character_id = ? FOR UPDATE");
    NWNX_SQL_PreparedInt(0,owner);
    if (!NWNX_SQL_ExecutePreparedQuery() || !NWNX_SQL_ReadyToReadNextRow()) { DQC_Error(pc,"state_read"); DQC_Abort(); return JsonNull(); }
    NWNX_SQL_ReadNextRow();
    json state = JsonParse(NWNX_SQL_ReadDataInActiveRow(0));
    int revision = StringToInt(NWNX_SQL_ReadDataInActiveRow(1));
    SetLocalInt(pc,"DQ_TX_REVISION",revision);
    if (JsonGetType(state) != JSON_TYPE_OBJECT || (revision > 0 && (DQC_Int(state,"owner") != owner || DQC_Int(state,"schema") != 1 || DQC_Int(state,"cycle") <= 0)) ||
        (DQC_Int(state,"owner") != 0 && DQC_Int(state,"owner") != owner) ||
        (DQC_Int(state,"schema") != 0 && DQC_Int(state,"schema") != 1)) { DQC_Error(pc,"state_invalid"); DQC_Abort(); return JsonNull(); }
    return state;
}
int DQC_End(object pc, json state, json reward, string receipt = "")
{
    if (JsonGetType(state) != JSON_TYPE_OBJECT) { DQC_Abort(); return FALSE; }
    int owner = players_GetPCPersistentID(pc);
    int gold = DQC_Int(reward,"gold"); int coins = DQC_Int(reward,"coins"); int fame = DQC_Int(reward,"fame");
    if (owner <= 0 || DQC_Int(state,"owner") != owner || DQC_Int(state,"cycle") <= 0 ||
        GetLocalInt(pc,"DQ_TX_NOW") <= 0 || DQC_Int(state,"rerolls_remaining") < 0 ||
        DQC_Int(state,"rerolls_remaining") > 3 || DQC_Int(state,"claimed_count") < 0 ||
        DQC_Int(state,"claimed_count") > 15 || gold < 0 || coins < 0 || fame < 0)
    { DQC_Error(pc,"state_write_invalid"); DQC_Abort(); return FALSE; }
    if (receipt != "")
    {
        NWNX_SQL_PrepareQuery("INSERT INTO dq_receipts_v05 (character_id, receipt_id, gold, rune_coins, fame, created_at) VALUES (?, ?, ?, ?, ?, ?)");
        NWNX_SQL_PreparedInt(0,owner); NWNX_SQL_PreparedString(1,receipt); NWNX_SQL_PreparedInt(2,gold);
        NWNX_SQL_PreparedInt(3,coins); NWNX_SQL_PreparedInt(4,fame); NWNX_SQL_PreparedInt(5,GetLocalInt(pc,"DQ_TX_NOW"));
        if (!NWNX_SQL_ExecutePreparedQuery()) { DQC_Abort(); return FALSE; }
        if (!DQR_RecordEntitlement(pc,reward,receipt)) { DQC_Error(pc,"item_entitlement_write"); DQC_Abort(); return FALSE; }
        // The existing server gold bank and Fame are account balances. Assignment
        // and claim eligibility remain character-specific. No new bank is created.
        NWNX_SQL_PrepareQuery("UPDATE players SET gold_deposit = gold_deposit + ?, fame_total = fame_total + ? WHERE name = ? AND gold_deposit <= 2147483647 - ? AND fame_total <= 2147483647 - ?");
        NWNX_SQL_PreparedInt(0,gold); NWNX_SQL_PreparedInt(1,fame); NWNX_SQL_PreparedString(2,GetPCPlayerName(pc));
        NWNX_SQL_PreparedInt(3,gold); NWNX_SQL_PreparedInt(4,fame);
        if (!NWNX_SQL_ExecutePreparedQuery() || ((gold > 0 || fame > 0) && NWNX_SQL_GetAffectedRows() != 1)) { DQC_Abort(); return FALSE; }
        NWNX_SQL_PrepareQuery("INSERT IGNORE INTO dq_wallet_v05 (character_id, rune_coins) VALUES (?, 0)");
        NWNX_SQL_PreparedInt(0,owner);
        if (!NWNX_SQL_ExecutePreparedQuery()) { DQC_Abort(); return FALSE; }
        NWNX_SQL_PrepareQuery("UPDATE dq_wallet_v05 SET rune_coins = rune_coins + ? WHERE character_id = ? AND rune_coins <= 2147483647 - ?");
        NWNX_SQL_PreparedInt(0,coins); NWNX_SQL_PreparedInt(1,owner); NWNX_SQL_PreparedInt(2,coins);
        if (!NWNX_SQL_ExecutePreparedQuery() || (coins > 0 && NWNX_SQL_GetAffectedRows() != 1)) { DQC_Abort(); return FALSE; }
    }
    NWNX_SQL_PrepareQuery("UPDATE dq_contract_state_v05 SET payload = ?, revision = revision + 1 WHERE character_id = ? AND revision = ?");
    NWNX_SQL_PreparedString(0,JsonDump(state)); NWNX_SQL_PreparedInt(1,owner); NWNX_SQL_PreparedInt(2,GetLocalInt(pc,"DQ_TX_REVISION"));
    if (!NWNX_SQL_ExecutePreparedQuery() || NWNX_SQL_GetAffectedRows() != 1) { DQC_Error(pc,"state_write"); DQC_Abort(); return FALSE; }
    if (!DQC_Query("COMMIT")) { DQC_Error(pc,"commit"); DQC_Abort(); return FALSE; }
    if (receipt != "" && gold > 0) DeleteLocalInt(pc,"BANK_DEPOSIT_CASH");
    SetLocalJson(pc,"DQ_LIVE_STATE",state);
    if (receipt != "") SetLocalJson(pc,"DQ_LAST_REWARD",reward);
    return TRUE;
}
string DQC_RewardMessage(object pc)
{
    json reward = GetLocalJson(pc,"DQ_LAST_REWARD");
    string message = "Reward: "+IntToString(DQC_Int(reward,"gold"))+" gold (bank), "+IntToString(DQC_Int(reward,"coins"))+" Rune Coins, "+IntToString(DQC_Int(reward,"fame"))+" Fame.";
    if (JsonGetLength(JsonObjectGet(reward,"items")) > 0) message += " " + GetLocalString(pc,"DQR_DELIVERY_MESSAGE");
    return message;
}
json DQC_Rotate(json state, object pc, int now)
{
    int cycle = DQC_Cycle(now);
    if (cycle <= 0 || DQC_Int(state,"cycle") > cycle)
    { DQC_Error(pc,"clock_invalid_or_backwards"); return JsonNull(); }
    int phase = GetLocalInt(GetModule(),CORMYREAN_WIPE_PHASE);
    if (phase < 1 || phase > 4) { DQC_Error(pc,"phase_invalid"); return JsonNull(); }
    if (DQC_Int(state,"cycle") == cycle && !DQC_Int(state,"issuance_blocked")) return state;
    return DQC_NewCycle(state,DQC_Catalogue(),players_GetPCPersistentID(pc),phase,GetHitDice(pc),now);
}
int DQC_Enter(object pc)
{
    if (!DQC_Ready()) { DQC_Error(pc,"clock_or_config_unavailable"); return FALSE; }
    json state = DQC_Begin(pc,TRUE);
    if (JsonGetType(state) != JSON_TYPE_OBJECT) return FALSE;
    state = DQC_Rotate(state,pc,GetLocalInt(pc,"DQ_TX_NOW"));
    int ok = DQC_End(pc,state,DQC_Reward());
    if (ok && DQC_Int(DQC_Config(),"reward_policy") == 2) ExecuteScript("dq_deliver",pc);
    return ok;
}
int DQC_LiveClaim(object pc, string id, int chest = -1)
{
    if (!DQC_Ready()) return FALSE;
    json state = DQC_Begin(pc,FALSE);
    if (JsonGetType(state) != JSON_TYPE_OBJECT) return FALSE;
    state = DQC_Rotate(state,pc,GetLocalInt(pc,"DQ_TX_NOW"));
    if (JsonGetType(state) != JSON_TYPE_OBJECT) { DQC_Abort(); return FALSE; }
    json reward = JsonNull(); string receipt;
    if (chest >= 0)
    {
        reward = JsonArrayGet(JsonObjectGet(state,"chest_rewards"),chest);
        receipt = "chest:"+IntToString(DQC_Int(state,"cycle"))+":"+IntToString(chest);
        state = DQC_ClaimChest(state,chest);
    }
    else
    {
        json quests = JsonObjectGet(state,"quests"); int i;
        for (i = 0; i < JsonGetLength(quests); i++)
        {
            json q = JsonArrayGet(quests,i);
            if (DQC_Str(q,"id") == id) reward = JsonObjectGet(q,"reward");
        }
        receipt = "quest:"+id;
        state = DQC_Claim(state,id);
    }
    if (JsonGetType(reward) != JSON_TYPE_OBJECT) { DQC_Abort(); return FALSE; }
    int ok = DQC_End(pc,state,reward,receipt);
    // The receipt, balances and state have committed. Log before inventory/save
    // callbacks so a delayed item delivery cannot hide the credited currencies.
    if (ok)
    {
        string message = DQP_CurrencyMessage(reward);
        if (message != "") SendMessageToPC(pc,message);
    }
    if (ok && JsonGetLength(JsonObjectGet(reward,"items")) > 0) ExecuteScript("dq_deliver",pc);
    return ok;
}
int DQC_LiveReroll(object pc, string id, int confirm)
{
    if (!DQC_Ready()) return FALSE;
    json state = DQC_Begin(pc,FALSE);
    if (JsonGetType(state) != JSON_TYPE_OBJECT) return FALSE;
    int now = GetLocalInt(pc,"DQ_TX_NOW"); state = DQC_Rotate(state,pc,now);
    if (JsonGetType(state) != JSON_TYPE_OBJECT) { DQC_Abort(); return FALSE; }
    state = DQC_Reroll(state,DQC_Catalogue(),id,GetLocalInt(GetModule(),CORMYREAN_WIPE_PHASE),GetHitDice(pc),now,confirm);
    return DQC_End(pc,state,DQC_Reward());
}
object DQC_Killer(object killer, object victim)
{
    // No last damager/party/faction/nearest-PC fallback. Resolve a true master chain only.
    int depth;
    for (depth = 0; depth < 8 && GetIsObjectValid(killer); depth++)
    {
        if (killer == victim || GetIsDM(killer) || GetIsDMPossessed(killer)) return OBJECT_INVALID;
        if (GetIsPC(killer)) return killer;
        object master = GetMaster(killer);
        if (master == killer) return OBJECT_INVALID;
        killer = master;
    }
    return OBJECT_INVALID;
}
void DQC_Death(object victim, object rawKiller)
{
    if (GetLocalInt(victim,"DQ_DEATH_HANDLED_V05")) return;
    SetLocalInt(victim,"DQ_DEATH_HANDLED_V05",TRUE);
    object pc = DQC_Killer(rawKiller,victim);
    if (!GetIsObjectValid(pc) || GetIsPC(victim) || !DQC_Ready()) return;
    if(GetStringLowerCase(GetResRef(victim))=="cr_drmundo")return;
    int miniKeys=DQS_MiniKeyCount(victim);
    if(miniKeys>=0)
    {
        json miniState=DQC_Begin(pc,FALSE);if(JsonGetType(miniState)!=JSON_TYPE_OBJECT)return;
        miniState=DQC_Rotate(miniState,pc,GetLocalInt(pc,"DQ_TX_NOW"));
        if(JsonGetType(miniState)!=JSON_TYPE_OBJECT){DQC_Abort();return;}
        json miniNext=DQS_CreditMini(miniState,GetStringLowerCase(GetResRef(victim)),miniKeys);
        if(JsonDump(miniNext)==JsonDump(miniState)){DQC_Abort();return;}
        if(DQC_End(pc,miniNext,DQC_Reward()))
        {
            string message=DQP_Progress(miniState,miniNext);if(message!="")SendMessageToPC(pc,message);
            ExecuteScript("dq_sync",pc);
        }
        return;
    }
    // Ordinary champion dispatch excludes boss, Mutated, Grand and guard objects.
    if (GetLocalInt(victim,"IMGUARD") || GetLocalInt(victim,"BOSS_TYPE") || GetLocalInt(victim,"MUTATED") ||
        GetLocalInt(victim,"ELITECHAMPIONSPAWNED")) return;
    json state = DQC_Begin(pc,FALSE);
    if (JsonGetType(state) != JSON_TYPE_OBJECT) return;
    state = DQC_Rotate(state,pc,GetLocalInt(pc,"DQ_TX_NOW"));
    if (JsonGetType(state) != JSON_TYPE_OBJECT) { DQC_Abort(); return; }
    string kind = GetLocalInt(victim,"CHAMPIONSPAWNED") ? "champion" : "hunt";
    json next = DQC_Credit(state,GetStringLowerCase(GetResRef(victim)),kind);
    if (JsonDump(next) == JsonDump(state)) { DQC_Abort(); return; }
    if (DQC_End(pc,next,DQC_Reward()))
    {
        string message = DQP_Progress(state,next);
        if (message != "") SendMessageToPC(pc,message);
        ExecuteScript("dq_sync",pc);
    }
}

void DQS_PvPDeath(object victim,object rawKiller)
{
    object pc=DQC_Killer(rawKiller,victim);
    if(!GetIsPC(victim) || !GetIsObjectValid(pc) || !GetIsDead(victim) || GetIsDM(victim) || GetIsDMPossessed(victim) ||
       players_IsTestCharacter(pc) || players_IsTestCharacter(victim) || GetHitDice(victim)<=1 || !DQC_Ready() || !DQS_Enabled("pvp_enabled"))return;
    int victimFaction=players_GetFaction(victim);int killerFaction=players_GetFaction(pc);
    if(victimFaction==0 || killerFaction==0 || victimFaction==killerFaction)return;
    object area=GetArea(pc);
    if(!GetIsObjectValid(area))area=GetAreaFromLocation(GetLocalLocation(pc,"sm_location"));
    if(!GetIsObjectValid(area))area=GetAreaFromLocation(GetLocalLocation(pc,"LAST_PLAYER_LOCATION"));
    if(!DQS_LevelAllowed(GetHitDice(pc),GetHitDice(victim),players_GetFaction(area),victimFaction))return;
    int victimID=players_GetPCPersistentID(victim);
    if(victimID<=0 || victimID==players_GetPCPersistentID(pc))return;
    json before=DQC_Begin(pc,FALSE);if(JsonGetType(before)!=JSON_TYPE_OBJECT)return;
    int now=GetLocalInt(pc,"DQ_TX_NOW");before=DQC_Rotate(before,pc,now);
    if(JsonGetType(before)!=JSON_TYPE_OBJECT){DQC_Abort();return;}
    json next=DQS_CreditPvP(before,victimID,now);
    if(JsonDump(next)==JsonDump(before)){DQC_Abort();return;}
    if(DQC_End(pc,next,DQC_Reward()))
    {
        string message=DQP_Progress(before,next);if(message!="")SendMessageToPC(pc,message);
        ExecuteScript("dq_sync",pc);
    }
}

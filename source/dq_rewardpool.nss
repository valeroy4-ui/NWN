#include "dq_rewardcfg"
json DQR_Settings()
{
    json cfg = JsonObjectGet(DQC_Config(),"reward_v06");
    return JsonGetType(cfg) == JSON_TYPE_OBJECT ? cfg : DQR_Defaults();
}
int DQR_Value(string key) { return DQC_Int(DQR_Settings(),key); }
int DQR_WeightsValid(json cfg, string key, int count, int itemsOnly = FALSE, int low = FALSE)
{
    json weights = JsonObjectGet(cfg,key); int i; int total = 0;
    if (JsonGetType(weights) != JSON_TYPE_ARRAY || JsonGetLength(weights) != count) return FALSE;
    for (i = 0; i < count; i++)
    {
        json value = JsonArrayGet(weights,i); int weight = JsonGetInt(value);
        if (JsonGetType(value) != JSON_TYPE_INTEGER || weight < 0 || weight > 100) return FALSE;
        if ((itemsOnly && i == 0 || low && i >= 5) && weight != 0) return FALSE;
        total += weight;
    }
    return total == 100;
}
int DQR_DiceValid(json spec)
{
    int base = DQC_Int(spec,"base"); int dice = DQC_Int(spec,"dice"); int sides = DQC_Int(spec,"sides");
    return base >= 0 && base <= 100 && dice >= 1 && dice <= 10 && sides >= 1 && sides <= 20 && base+dice*sides <= 200;
}
int DQR_Valid(json cfg)
{
    if (DQC_Int(cfg,"version") != 2 || DQC_Int(cfg,"high_scroll_min_cr") < 45 || DQC_Int(cfg,"high_scroll_min_cr") > 99 ||
        DQC_Int(cfg,"hunt_wand_charges") != 25 || DQC_Int(cfg,"champion_equivalent_kills") < 1 || DQC_Int(cfg,"champion_equivalent_kills") > 20 ||
        DQC_Int(cfg,"champion_large_count") != 10 || DQC_Int(cfg,"champion_large_bonus_percent") < 0 || DQC_Int(cfg,"champion_large_bonus_percent") > 100 ||
        DQC_Int(cfg,"grand_equivalent_kills") < 1 || DQC_Int(cfg,"grand_equivalent_kills") > 80 ||
        !DQR_WeightsValid(cfg,"hunt_weights_low",7,FALSE,TRUE) || !DQR_WeightsValid(cfg,"hunt_weights_high",7) ||
        !DQR_WeightsValid(cfg,"chest_item_weights_low",7,TRUE,TRUE) || !DQR_WeightsValid(cfg,"chest_item_weights_high",7,TRUE) ||
        !DQR_WeightsValid(cfg,"chest_currency_weights",2) || !DQR_DiceValid(JsonObjectGet(cfg,"hunt_fame")) ||
        !DQR_DiceValid(JsonObjectGet(cfg,"hunt_heal")) || !DQR_DiceValid(JsonObjectGet(cfg,"hunt_scroll"))) return FALSE;
    if (DQC_Int(cfg,"grand_reward_assignment_enabled") || DQC_Int(cfg,"pvp_reward_assignment_enabled")) return FALSE;
    json minimums = JsonParse("[\"chest_coins_min\",\"chest_fame_min\",\"grand_coins_min\"]");
    json maximums = JsonParse("[\"chest_coins_max\",\"chest_fame_max\",\"grand_coins_max\"]"); int i;
    for (i = 0; i < 3; i++)
    {
        int low = DQC_Int(cfg,JsonGetString(JsonArrayGet(minimums,i))); int high = DQC_Int(cfg,JsonGetString(JsonArrayGet(maximums,i)));
        if (low < 1 || high < low || high > 1000) return FALSE;
    }
    json keys = JsonParse("[\"champion_gold_min\",\"grand_gold_min\",\"champion_fame_base\",\"champion_large_fame_base\",\"champion_fame_die\",\"pvp_fame_base\",\"pvp_fame_extra_per_victim\",\"pvp_fame_die\"]");
    for (i = 0; i < JsonGetLength(keys); i++)
    {
        int value = DQC_Int(cfg,JsonGetString(JsonArrayGet(keys,i)));
        if (value < 1 || value > (i < 2 ? 1000000 : 100)) return FALSE;
    }
    if (JsonGetLength(JsonObjectGet(cfg,"chest_heal")) != 3 || JsonGetLength(JsonObjectGet(cfg,"chest_scroll")) != 3 || JsonGetLength(JsonObjectGet(cfg,"chest_wand_charges")) != 3) return FALSE;
    for (i = 0; i < 3; i++)
    {
        int charges = JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"chest_wand_charges"),i));
        if (charges <= 25 || charges > 250 || !DQR_DiceValid(JsonArrayGet(JsonObjectGet(cfg,"chest_heal"),i)) || !DQR_DiceValid(JsonArrayGet(JsonObjectGet(cfg,"chest_scroll"),i))) return FALSE;
    }
    json currencyKeys = JsonParse("[\"chest_coins_ranges\",\"chest_fame_ranges\"]"); int k;
    for (k = 0; k < 2; k++)
    {
        json ranges = JsonObjectGet(cfg,JsonGetString(JsonArrayGet(currencyKeys,k))); int previousMax = 0;
        if (JsonGetLength(ranges) != 3) return FALSE;
        for (i = 0; i < 3; i++)
        {
            json range = JsonArrayGet(ranges,i); int low = JsonGetInt(JsonArrayGet(range,0)); int high = JsonGetInt(JsonArrayGet(range,1));
            if (JsonGetLength(range) != 2 || low <= previousMax || high < low || low < (k == 0 ? 15 : 50) || high > (k == 0 ? 25 : 70)) return FALSE;
            previousMax = high;
        }
    }
    // Recipes are verified resources, not arbitrary item ResRefs from SQL input.
    if (JsonDump(JsonObjectGet(cfg,"recipe_ids")) != "[\"fame\",\"heal\",\"restoration\",\"clarity\",\"freedom\",\"greater_sanctuary\",\"greater_spell_mantle\"]") return FALSE;
    json refs = JsonParse("[\"\",\"nw_it_mpotion012\",\"dq_wand_rest\",\"dq_wand_clar\",\"dq_wand_free\",\"fl_scr_grtsanc\",\"fl_scr_grtspml\"]");
    for (i = 1; i < 7; i++)
    {
        string id = JsonGetString(JsonArrayGet(JsonObjectGet(cfg,"recipe_ids"),i));
        if (DQC_Str(JsonObjectGet(JsonObjectGet(cfg,"item_recipes"),id),"resref") != JsonGetString(JsonArrayGet(refs,i))) return FALSE;
    }
    if (DQC_Int(cfg,"easy_hunt_max_cr") != 20 || DQC_Int(cfg,"easy_hunt_gold_min") != 45000 || DQC_Int(cfg,"easy_hunt_gold_max") != 85000) return FALSE;
    json bands = JsonObjectGet(cfg,"gold_bands_v06");
    if (JsonGetLength(bands) != 7) return FALSE;
    int previous = 0;
    for (i = 0; i < 7; i++)
    {
        json band = JsonArrayGet(bands,i); int base = JsonGetInt(JsonArrayGet(band,1));
        if (JsonGetLength(band) != 2 || JsonGetInt(JsonArrayGet(band,0)) <= previous || base < 1 || base > 1000000) return FALSE;
        previous = JsonGetInt(JsonArrayGet(band,0));
    }
    return TRUE;
}
int DQR_Dice(json spec)
{
    int result = DQC_Int(spec,"base"); int i;
    for (i = 0; i < DQC_Int(spec,"dice"); i++) result += 1+Random(DQC_Int(spec,"sides"));
    return result;
}
int DQR_Pick(json weights, int skipFame = FALSE)
{
    int total = 0; int i;
    for (i = skipFame ? 1 : 0; i < JsonGetLength(weights); i++) total += JsonGetInt(JsonArrayGet(weights,i));
    if (total <= 0) return -1;
    int roll = Random(total);
    for (i = skipFame ? 1 : 0; i < JsonGetLength(weights); i++)
    {
        roll -= JsonGetInt(JsonArrayGet(weights,i));
        if (roll < 0) return i;
    }
    return -1;
}
json DQR_Item(int choice, int tier = -1)
{
    json cfg = DQR_Settings();
    string id = JsonGetString(JsonArrayGet(JsonObjectGet(cfg,"recipe_ids"),choice));
    json recipe = JsonObjectGet(JsonObjectGet(cfg,"item_recipes"),id);
    json item = JsonParse(JsonDump(recipe)); int quantity = 1; int charges = 0;
    if (choice == 1)
        quantity = DQR_Dice(tier < 0 ? JsonObjectGet(cfg,"hunt_heal") : JsonArrayGet(JsonObjectGet(cfg,"chest_heal"),tier));
    else if (choice >= 2 && choice <= 4)
        charges = tier < 0 ? DQC_Int(cfg,"hunt_wand_charges") : JsonGetInt(JsonArrayGet(JsonObjectGet(cfg,"chest_wand_charges"),tier));
    else if (choice >= 5)
        quantity = DQR_Dice(tier < 0 ? JsonObjectGet(cfg,"hunt_scroll") : JsonArrayGet(JsonObjectGet(cfg,"chest_scroll"),tier));
    JsonObjectSetInplace(item,"quantity",JsonInt(quantity)); JsonObjectSetInplace(item,"charges",JsonInt(charges));
    return item;
}
json DQR_Additional(json reward, float cr, string kind, int required)
{
    if (kind == "pvp" && (required < 1 || required > 3)) return JsonNull();
    json cfg = DQR_Settings();
    if (kind == "hunt" && cr <= IntToFloat(DQC_Int(cfg,"easy_hunt_max_cr")))
    {
        JsonObjectSetInplace(reward,"items",JsonArray());
        JsonObjectSetInplace(reward,"reward_version",JsonInt(2));
        JsonObjectSetInplace(reward,"bonus_type",JsonString("easy_gold_only"));
        return reward;
    }
    int high = cr >= IntToFloat(DQC_Int(cfg,"high_scroll_min_cr"));
    int special = kind == "pvp" || kind == "grand";
    json weights = JsonObjectGet(cfg,high ? "hunt_weights_high" : "hunt_weights_low");
    int choice = DQR_Pick(weights,special);
    json items = JsonArray();
    if (choice == 0) JsonObjectSetInplace(reward,"fame",JsonInt(DQR_Dice(JsonObjectGet(cfg,"hunt_fame"))));
    else if (choice > 0)
    {
        int tier = -1;
        if (kind == "champion") tier = required >= DQR_Value("champion_large_count") ? 1 : 0;
        else if (kind == "grand") tier = 2;
        else if (kind == "pvp" && required >= 3) tier = 0;
        JsonArrayInsertInplace(items,DQR_Item(choice,tier));
    }
    if (kind == "champion" && choice == 0)
        JsonObjectSetInplace(reward,"fame",JsonInt((required >= DQR_Value("champion_large_count") ? DQR_Value("champion_large_fame_base") : DQR_Value("champion_fame_base"))+1+Random(DQR_Value("champion_fame_die"))));
    if (kind == "pvp")
        JsonObjectSetInplace(reward,"fame",JsonInt(DQC_Int(cfg,"pvp_fame_base")+DQC_Int(cfg,"pvp_fame_extra_per_victim")*(required-1)+1+Random(DQC_Int(cfg,"pvp_fame_die"))));
    if (kind == "grand") JsonObjectSetInplace(reward,"coins",JsonInt(DQR_Value("grand_coins_min")+Random(DQR_Value("grand_coins_max")-DQR_Value("grand_coins_min")+1)));
    JsonObjectSetInplace(reward,"items",items);
    JsonObjectSetInplace(reward,"reward_version",JsonInt(2));
    JsonObjectSetInplace(reward,"bonus_type",JsonArrayGet(JsonObjectGet(cfg,"recipe_ids"),choice));
    return reward;
}
int DQR_BaseGold(float cr)
{
    json bands = JsonObjectGet(DQR_Settings(),"gold_bands_v06"); int i;
    for (i = 0; i < JsonGetLength(bands); i++)
    {
        json band = JsonArrayGet(bands,i);
        if (cr <= IntToFloat(JsonGetInt(JsonArrayGet(band,0)))) return JsonGetInt(JsonArrayGet(band,1));
    }
    return 0;
}
int DQR_CategoryGold(float cr, int required, string kind, int originalGold)
{
    if (required < 1 || required > 25) return 0;
    int ordinaryBase = DQR_BaseGold(cr); int gold = originalGold;
    if (ordinaryBase < 1 || ordinaryBase > 1000000) return 0;
    if (kind == "hunt")
    {
        if (cr <= IntToFloat(DQR_Value("easy_hunt_max_cr")))
        {
            int crPart = FloatToInt(cr)-12; if (crPart < 0) crPart = 0; if (crPart > 8) crPart = 8;
            int countPart = required-16; if (countPart < 0) countPart = 0; if (countPart > 9) countPart = 9;
            gold = DQR_Value("easy_hunt_gold_min")+(crPart*9+countPart*8)*(DQR_Value("easy_hunt_gold_max")-DQR_Value("easy_hunt_gold_min"))/144;
        }
        else gold = ordinaryBase*required/20;
    }
    else if (kind == "champion")
    {
        gold = ordinaryBase*DQR_Value("champion_equivalent_kills")*required/20;
        if (required >= DQR_Value("champion_large_count")) gold = (gold/100)*(100+DQR_Value("champion_large_bonus_percent"))+(gold%100)*(100+DQR_Value("champion_large_bonus_percent"))/100;
        if (gold < DQR_Value("champion_gold_min")) gold = DQR_Value("champion_gold_min");
    }
    else if (kind == "grand")
    {
        gold = ordinaryBase*DQR_Value("grand_equivalent_kills")*required/20;
        if (gold < DQR_Value("grand_gold_min")) gold = DQR_Value("grand_gold_min");
    }
    if (gold > 10000000) gold = 10000000;
    return ((gold+500)/1000)*1000;
}

json DQR_Chest(int phase, int chest, float maxAssignedCR)
{
    json cfg = DQR_Settings();
    int gold = JsonGetInt(JsonArrayGet(JsonArrayGet(JsonObjectGet(DQC_Config(),"milestone_gold"),phase-1),chest));
    int coins = 0; int fame = 0;
    if (DQR_Pick(JsonObjectGet(cfg,"chest_currency_weights")) == 0)
        {
        json range = JsonArrayGet(JsonObjectGet(cfg,"chest_coins_ranges"),chest);
        coins = JsonGetInt(JsonArrayGet(range,0))+Random(JsonGetInt(JsonArrayGet(range,1))-JsonGetInt(JsonArrayGet(range,0))+1);
    }
    else
    {
        json range = JsonArrayGet(JsonObjectGet(cfg,"chest_fame_ranges"),chest);
        fame = JsonGetInt(JsonArrayGet(range,0))+Random(JsonGetInt(JsonArrayGet(range,1))-JsonGetInt(JsonArrayGet(range,0))+1);
    }
    json reward = DQC_Reward(gold,coins,fame);
    int choice = DQR_Pick(JsonObjectGet(cfg,maxAssignedCR >= IntToFloat(DQC_Int(cfg,"high_scroll_min_cr")) ? "chest_item_weights_high" : "chest_item_weights_low"),TRUE);
    json items = JsonArray(); JsonArrayInsertInplace(items,DQR_Item(choice,chest));
    JsonObjectSetInplace(reward,"items",items);
    JsonObjectSetInplace(reward,"reward_version",JsonInt(2));
    JsonObjectSetInplace(reward,"bonus_type",JsonArrayGet(JsonObjectGet(cfg,"recipe_ids"),choice));
    return reward;
}

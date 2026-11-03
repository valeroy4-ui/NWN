#include "nw_inc_nui"
#include "dq_catalog"
#include "dq_store"
#include "dq_mobicons"
#include "dq_mobart"

// Existing table renderer preserved. Backend actions live in dq_store/dq_core.
const string DQ_WINDOW = "dq_journal";

const string DQ_DESC_CHARS = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
const string DQ_DESC_METRICS = "[[0,0,0,0,6,0,0],[33,5,10,17,8,-1,3],[65,5,11,17,9,-1,3],[97,6,19,16,17,-1,4],[129,4,15,21,13,-1,2],[161,5,21,17,19,-1,3],[193,5,20,17,18,-1,3],[225,5,8,17,6,-1,3],[257,5,10,20,8,-1,3],[289,5,10,20,8,-1,3],[321,5,12,17,10,-1,3],[353,8,19,14,17,-1,6],[385,18,8,7,6,-1,16],[417,14,9,8,7,-1,12],[449,17,8,5,6,-1,15],[481,5,9,18,7,-1,3],[1,37,15,17,13,-1,3],[33,37,15,17,13,-1,3],[65,37,15,17,13,-1,3],[97,37,15,17,13,-1,3],[129,37,15,17,13,-1,3],[161,37,15,17,13,-1,3],[193,37,15,17,13,-1,3],[225,37,15,17,13,-1,3],[257,37,15,17,13,-1,3],[289,37,15,17,13,-1,3],[321,43,9,11,7,-1,9],[353,43,9,14,7,-1,9],[385,40,19,14,17,-1,6],[417,43,19,11,17,-1,9],[449,40,19,14,17,-1,6],[481,37,13,17,11,-1,3],[1,70,22,20,20,-1,4],[32,69,18,17,14,-2,3],[65,69,17,17,15,-1,3],[97,69,17,17,15,-1,3],[129,69,18,17,16,-1,3],[161,69,17,17,15,-1,3],[193,69,16,17,14,-1,3],[225,69,18,17,16,-1,3],[257,69,19,17,17,-1,3],[289,69,10,17,8,-1,3],[319,69,12,21,8,-3,3],[353,69,18,17,15,-1,3],[385,69,15,17,13,-1,3],[417,69,22,17,20,-1,3],[449,69,20,17,18,-1,3],[481,69,18,17,16,-1,3],[1,101,15,17,13,-1,3],[33,101,18,20,16,-1,3],[65,101,18,17,15,-1,3],[97,101,16,17,14,-1,3],[129,101,16,17,13,-1,3],[161,101,19,17,17,-1,3],[192,101,18,17,14,-2,3],[225,101,23,17,21,-1,3],[257,101,17,17,14,-1,3],[288,101,17,17,13,-2,3],[321,101,16,17,14,-1,3],[353,101,10,20,8,-1,3],[385,101,9,18,7,-1,3],[417,101,10,20,8,-1,3],[449,101,19,17,17,-1,3],[481,116,12,7,10,-1,18],[1,132,12,18,10,-1,2],[33,138,14,12,12,-1,8],[65,133,15,17,13,-1,3],[97,138,13,12,11,-1,8],[129,133,15,17,13,-1,3],[161,138,14,12,12,-1,8],[193,133,11,17,7,-1,3],[225,138,15,16,13,-1,8],[257,133,15,17,13,-1,3],[289,134,8,16,6,-1,4],[319,134,10,20,6,-3,4],[353,133,15,17,12,-1,3],[385,133,8,17,6,-1,3],[417,138,21,12,19,-1,8],[449,138,15,12,13,-1,8],[481,138,14,12,12,-1,8],[1,170,15,16,13,-1,8],[33,170,15,16,13,-1,8],[65,170,12,12,10,-1,8],[97,170,12,12,10,-1,8],[129,167,10,15,8,-1,5],[161,170,15,12,13,-1,8],[192,170,15,12,11,-2,8],[225,170,19,12,17,-1,8],[257,170,14,12,11,-1,8],[288,170,15,16,11,-2,8],[321,170,13,12,11,-1,8],[353,165,15,20,13,-1,3],[385,165,9,22,7,-1,3],[417,165,15,20,13,-1,3],[449,171,19,11,17,-1,9]]";


json DQ_CatalogFor(object pc)
{
    json catalog = DQ_Catalog();
    json all = JsonObjectGet(catalog,"quests");
    json rows = JsonArray(); int i;
    if (GetLocalInt(pc,"DQ_UI_UNAVAILABLE"))
    {
        JsonObjectSetInplace(catalog,"quests",rows);
        return catalog;
    }
    if (GetLocalInt(pc,"DQ_UI_PREVIEW"))
    {
        for (i = 0; i < 15 && i < JsonGetLength(all); i++) JsonArrayInsertInplace(rows,JsonArrayGet(all,i));
    }
    else
    {
        json state = GetLocalJson(pc,"DQ_LIVE_STATE");
        json carryRefs = DQC_CarryRefs(state);
        all = JsonObjectGet(state,"quests");
        int carried = GetLocalInt(pc,"DQ_UI_CARRIED");
        for (i = 0; i < JsonGetLength(all); i++)
        {
            json q = JsonParse(JsonDump(JsonArrayGet(all,i)));
            int old = DQC_Int(q,"origin_cycle") != DQC_Int(state,"cycle");
            if (old != carried || (old && DQC_Int(q,"reward_claimed"))) continue;
            JsonObjectSetInplace(q,"waiting",JsonInt(DQC_Waiting(q,carryRefs,DQC_Int(state,"cycle"))));
            JsonObjectSetInplace(q,"tab",JsonString("daily"));
            json reward = JsonObjectGet(q,"reward");
            json rewards = JsonArray(); int j;
            json keys = JsonParse("[\"gold\",\"coins\",\"fame\"]");
            for (j = 0; j < 3; j++)
            {
                string key = JsonGetString(JsonArrayGet(keys,j));
                int amount = DQC_Int(reward,key);
                if (!amount) continue;
                json r = JsonObjectSet(JsonObjectSet(JsonObject(),"type",JsonString(key == "coins" ? "rune_coins" : key)),"amount",JsonInt(amount));
                JsonArrayInsertInplace(rewards,r);
            }
            json itemRewards = JsonObjectGet(reward,"items");
            for (j = 0; j < JsonGetLength(itemRewards); j++)
            {
                json item = JsonArrayGet(itemRewards,j); string ref = DQC_Str(item,"resref");
                string full = DQC_Str(item,"label"); string brief = full;
                if (ref == "nw_it_mpotion012") brief = "Heal potions";
                else if (ref == "dq_wand_rest") brief = "Restore wand";
                else if (ref == "dq_wand_clar") brief = "Clarity wand";
                else if (ref == "dq_wand_free") brief = "Freedom wand";
                else if (ref == "fl_scr_grtsanc") brief = "G. Sanctuary";
                else if (ref == "fl_scr_grtspml") brief = "G. Sp.Mantle";
                int charges = DQC_Int(item,"charges");
                if (charges > 0) { full += " ("+IntToString(charges)+" uses)"; brief += " "+IntToString(charges); }
                json r = JsonObject();
                JsonObjectSetInplace(r,"type",JsonString("item")); JsonObjectSetInplace(r,"amount",JsonObjectGet(item,"quantity")); JsonObjectSetInplace(r,"resref",JsonObjectGet(item,"resref"));
                if(ref=="fl_inst_key")JsonObjectSetInplace(r,"category",JsonObjectGet(item,"category"));
                JsonObjectSetInplace(r,"label",JsonString(full)); JsonObjectSetInplace(r,"brief",JsonString(brief));
                JsonArrayInsertInplace(rewards,r);
            }
            JsonObjectSetInplace(q,"rewards",rewards);
            JsonArrayInsertInplace(rows,q);
        }
    }
    JsonObjectSetInplace(catalog,"quests",rows);
    return catalog;
}

json DQ_Items(json catalog, string tab)
{
    json result = JsonArray();
    json all = JsonObjectGet(catalog, "quests");
    int i;
    for (i = 0; i < JsonGetLength(all); i++)
    {
        json q = JsonArrayGet(all, i);
        if (JsonGetString(JsonObjectGet(q,"tab")) == tab)
            result = JsonArrayInsert(result, q);
    }
    return result;
}

int DQ_HasTab(json catalog, string tab)
{
    json tabs = JsonObjectGet(catalog,"tabs");
    int i;
    for (i = 0; i < JsonGetLength(tabs); i++)
        if (JsonGetString(JsonObjectGet(JsonArrayGet(tabs,i),"id")) == tab) return TRUE;
    return FALSE;
}

string DQ_RewardText(json rewards, int brief = FALSE)
{
    string result;
    int i;
    for (i = 0; i < JsonGetLength(rewards); i++)
    {
        json reward = JsonArrayGet(rewards,i);
        json amount = JsonObjectGet(reward,"amount");
        string value = "#";
        if (JsonGetType(amount) == JSON_TYPE_INTEGER) value = IntToString(JsonGetInt(amount));
        string type = JsonGetString(JsonObjectGet(reward,"type"));
        string name = "Reputation";
        if (type == "gold") name = "Gold (bank)";
        else if (type == "fame") name = "Fame";
        else if (type == "rune_coins") name = "Rune Coins";
        else if (type == "instance_key") name = "Instance Key: " + JsonGetString(JsonObjectGet(reward,"group"));
        else if (type == "item") name = DQC_Str(reward,brief ? "brief" : "label");
        if (brief && type == "gold") name = "Gold";
        if (result != "") result += "\n";
        result += value + " " + name;
    }
    return result;
}

json DQ_Portrait(int index)
{
    float y = 392.0;
    if (index == 1) y = 486.0;
    else if (index == 2) y = 580.0;
    else if (index == 3) y = 675.0;
    else if (index == 4) y = 768.0;
    else if (index == 5) y = 863.0;
    return NuiRect(115.0,y,100.0,74.0);
}

json DQ_Image(json region)
{
    return NuiImageRegion(NuiImage(JsonString("dq_atlas"),JsonInt(NUI_ASPECT_STRETCH),
        JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE)),region);
}

json DQ_Label(json value)
{
    return NuiStyleForegroundColor(NuiLabel(value,JsonInt(NUI_HALIGN_LEFT),JsonInt(NUI_VALIGN_MIDDLE)),
        NuiColor(231,210,157));
}

// NUI applies a 2px margin to controls unless explicitly overridden. Required
// child dimensions must fit WITH those margins; normalize the complete widget
// tree, including list templates. Keep deliberately configured padding.
json DQ_LayoutSpacing(json node)
{
    int kind = JsonGetType(node);
    int i;
    if (kind == JSON_TYPE_ARRAY)
    {
        for (i = 0; i < JsonGetLength(node); i++)
            JsonArraySetInplace(node,i,DQ_LayoutSpacing(JsonArrayGet(node,i)));
    }
    else if (kind == JSON_TYPE_OBJECT && JsonGetType(JsonObjectGet(node,"type")) == JSON_TYPE_STRING)
    {
        // Traverse widget structure only. Colors, rectangles, bindings and paint
        // commands cannot contain widgets; walking them wastes the VM budget.
        json children = JsonObjectGet(node,"children");
        if (JsonGetType(children) == JSON_TYPE_ARRAY)
            JsonObjectSetInplace(node,"children",DQ_LayoutSpacing(children));
        json cells = JsonObjectGet(node,"row_template");
        if (JsonGetType(cells) == JSON_TYPE_ARRAY)
            JsonObjectSetInplace(node,"row_template",DQ_LayoutSpacing(cells));
        if (JsonGetType(JsonObjectGet(node,"margin")) == JSON_TYPE_NULL)
            JsonObjectSetInplace(node,"margin",JsonFloat(0.0));
        if (JsonGetType(JsonObjectGet(node,"padding")) == JSON_TYPE_NULL)
            JsonObjectSetInplace(node,"padding",JsonFloat(0.0));
    }
    return node;
}

json DQ_SkinPaint(json rect, json region, int order = NUI_DRAW_LIST_ITEM_ORDER_BEFORE)
{
    return NuiDrawListImageRegion(NuiDrawListImage(JsonBool(TRUE),JsonString("dq_skin"),rect,
        JsonInt(NUI_ASPECT_STRETCH),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE),order),region);
}

json DQ_Material(json element, float width, float height, int panel)
{
    json region = NuiRect(0.0,264.0,1774.0,202.0);
    if (panel == 1) region = NuiRect(10.0,478.0,1754.0,163.0);
    else if (panel == 2) region = NuiRect(300.0,500.0,1000.0,100.0);
    json paint = JsonArray();
    paint = JsonArrayInsert(paint,DQ_SkinPaint(NuiRect(0.0,0.0,width,height),region));
    return NuiDrawList(element,JsonBool(FALSE),paint);
}

int DQ_ReplacementEligible(json state, json quest)
{
    return JsonGetType(quest) == JSON_TYPE_OBJECT && DQC_Str(quest,"id") != "" &&
        DQC_Int(quest,"origin_cycle") == DQC_Int(state,"cycle") &&
        DQC_Int(state,"rerolls_remaining") > 0 &&
        !DQC_Int(quest,"objective_completed") && !DQC_Int(quest,"reward_claimed");
}

json DQ_ReplacementWindow(json quest)
{
    // Use the client's documented cursor anchor; no server-side row/scroll guess.
    float innerWidth = 320.0;
    json rows = JsonArray();
    rows = JsonArrayInsert(rows,NuiHeight(NuiWidth(NuiText(JsonString("Are you sure you want to\nreplace this quest?"),FALSE,NUI_SCROLLBARS_NONE),innerWidth),44.0));
    rows = JsonArrayInsert(rows,NuiHeight(NuiWidth(NuiText(JsonObjectGet(quest,"title"),FALSE,NUI_SCROLLBARS_NONE),innerWidth),44.0));
    json warning = JsonString("Progress: "+IntToString(DQC_Int(quest,"progress"))+" / "+IntToString(DQC_Int(quest,"required"))+" will be lost.\nThis will use 1 replacement.");
    rows = JsonArrayInsert(rows,NuiHeight(NuiWidth(NuiText(warning,FALSE,NUI_SCROLLBARS_NONE),innerWidth),44.0));
    rows = JsonArrayInsert(rows,NuiHeight(NuiSpacer(),6.0));
    json choices = JsonArray();
    choices = JsonArrayInsert(choices,NuiWidth(NuiId(NuiButton(JsonString("Yes")),"confirm_replace"),154.0));
    choices = JsonArrayInsert(choices,NuiWidth(NuiSpacer(),12.0));
    choices = JsonArrayInsert(choices,NuiWidth(NuiId(NuiButton(JsonString("No")),"cancel_replace"),154.0));
    rows = JsonArrayInsert(rows,NuiHeight(NuiWidth(NuiRow(choices),innerWidth),30.0));
    json root = DQ_LayoutSpacing(NuiWidth(NuiHeight(NuiPadding(NuiCol(rows),8.0),184.0),336.0));
    return NuiWindow(root,JsonString("Replace quest"),NuiRect(-3.0,-3.0,360.0,220.0),
        JsonBool(FALSE),JsonBool(FALSE),JsonBool(TRUE),JsonBool(FALSE),JsonBool(TRUE),JsonBool(TRUE),
        NuiRect(360.0,220.0,360.0,220.0),NuiRect(8.0,8.0,8.0,8.0));
}

string DQ_TooltipText(string text)
{
    // Native one-line tooltips render newline control characters as '?'.
    // Keep the stored description/painted row text, normalize only the tooltip.
    // NSS supports \n; obtain CR/TAB through JSON rather than unsupported escapes.
    string crChar = JsonGetString(JsonParse("\"\\r\""));
    string tabChar = JsonGetString(JsonParse("\"\\t\""));
    string result;
    while (text != "")
    {
        int lf = FindSubString(text,"\n");
        int cr = FindSubString(text,crChar);
        int tab = FindSubString(text,tabChar);
        int at = lf;
        if (at < 0 || (cr >= 0 && cr < at)) at = cr;
        if (at < 0 || (tab >= 0 && tab < at)) at = tab;
        if (at < 0) { result += text; break; }
        result += GetStringLeft(text,at);
        int newline = at != tab;
        text = GetSubString(text,at+1,GetStringLength(text)-at-1);
        if (newline)
        {
            while (text != "" && (GetStringLeft(text,1) == crChar || GetStringLeft(text,1) == "\n" || GetStringLeft(text,1) == " " || GetStringLeft(text,1) == tabChar))
                text = GetSubString(text,1,GetStringLength(text)-1);
            if (result != "" && text != "") result += "; ";
        }
        else result += " ";
    }
    return result;
}

string DQ_WrapText(string text, int columns, int lines)
{
    string result = "";
    int position = 0;
    int line = 0;
    int length = GetStringLength(text);
    while (position < length && line < lines)
    {
        int take = columns;
        if (take > length-position) take = length-position;
        int forced = -1;
        int i;
        for (i = 0; i < take; i++)
            if (GetSubString(text,position+i,1) == "\n" && forced < 0) forced = i;
        if (forced >= 0) take = forced;
        else if (position+take < length)
        {
            int cut = take;
            while (cut > 0 && GetSubString(text,position+cut,1) != " ") cut--;
            if (cut > 0) take = cut;
        }
        string part = GetSubString(text,position,take);
        position += take;
        while (position < length && (GetSubString(text,position,1) == " " || GetSubString(text,position,1) == "\n")) position++;
        if (line == lines-1 && position < length)
        {
            if (GetStringLength(part) > columns-3) part = GetStringLeft(part,columns-3);
            part += "...";
            position = length;
        }
        if (result != "") result += "\n";
        result += part;
        line++;
    }
    return result;
}

json DQ_PaintedText(json value, float width, float height, json color)
{
    json paint = JsonArray();
    paint = JsonArrayInsert(paint,NuiDrawListText(JsonBool(TRUE),color,NuiRect(0.0,0.0,width,height),value));
    return NuiDrawList(NuiLabel(JsonString(""),JsonInt(NUI_HALIGN_LEFT),JsonInt(NUI_VALIGN_TOP)),JsonBool(FALSE),paint);
}

json DQ_SmallButton(json button, float width, float height, json label, json textRect, json ready)
{
    json paint = JsonArray();
    json points = JsonArray();
    points = JsonArrayInsert(points,JsonFloat(4.0)); points = JsonArrayInsert(points,JsonFloat(0.0));
    points = JsonArrayInsert(points,JsonFloat(width-4.0)); points = JsonArrayInsert(points,JsonFloat(0.0));
    points = JsonArrayInsert(points,JsonFloat(width)); points = JsonArrayInsert(points,JsonFloat(4.0));
    points = JsonArrayInsert(points,JsonFloat(width)); points = JsonArrayInsert(points,JsonFloat(height-4.0));
    points = JsonArrayInsert(points,JsonFloat(width-4.0)); points = JsonArrayInsert(points,JsonFloat(height));
    points = JsonArrayInsert(points,JsonFloat(4.0)); points = JsonArrayInsert(points,JsonFloat(height));
    points = JsonArrayInsert(points,JsonFloat(0.0)); points = JsonArrayInsert(points,JsonFloat(height-4.0));
    points = JsonArrayInsert(points,JsonFloat(0.0)); points = JsonArrayInsert(points,JsonFloat(4.0));
    points = JsonArrayInsert(points,JsonFloat(4.0)); points = JsonArrayInsert(points,JsonFloat(0.0));
    paint = JsonArrayInsert(paint,NuiDrawListRect(JsonBool(TRUE),NuiColor(12,13,14),JsonBool(TRUE),JsonFloat(0.0),NuiRect(0.0,0.0,width,height)));
    paint = JsonArrayInsert(paint,NuiDrawListPolyLine(JsonBool(TRUE),NuiColor(100,96,82),JsonBool(TRUE),JsonFloat(1.0),points));
    paint = JsonArrayInsert(paint,NuiDrawListRect(JsonBool(TRUE),NuiColor(22,23,24),JsonBool(TRUE),JsonFloat(0.0),NuiRect(1.0,1.0,width-2.0,height-2.0)));
    paint = JsonArrayInsert(paint,NuiDrawListRect(ready,NuiColor(58,40,73,140),JsonBool(TRUE),JsonFloat(0.0),NuiRect(2.0,2.0,width-4.0,height-4.0)));
    paint = JsonArrayInsert(paint,NuiDrawListPolyLine(ready,NuiColor(235,190,88),JsonBool(TRUE),JsonFloat(1.0),points));
    paint = JsonArrayInsert(paint,NuiDrawListText(JsonBool(TRUE),NuiColor(192,188,174),textRect,label));
    paint = JsonArrayInsert(paint,NuiDrawListText(ready,NuiColor(0,0,0),textRect,label));
    return NuiDrawList(button,JsonBool(FALSE),paint);
}

json DQ_TabSkin(json button, string label, float width, float height, json selected)
{
    json paint = JsonArray();
    paint = JsonArrayInsert(paint,NuiDrawListRect(JsonBool(TRUE),NuiColor(18,17,23),JsonBool(TRUE),JsonFloat(0.0),NuiRect(0.0,0.0,width,height)));
    paint = JsonArrayInsert(paint,NuiDrawListRect(selected,NuiColor(45,25,61),JsonBool(TRUE),JsonFloat(0.0),NuiRect(1.0,1.0,width-2.0,height-2.0)));
    paint = JsonArrayInsert(paint,NuiDrawListRect(JsonBool(TRUE),NuiColor(150,114,54),JsonBool(FALSE),JsonFloat(1.0),NuiRect(1.0,1.0,width-2.0,height-2.0)));
    float x = (width-IntToFloat(GetStringLength(label))*7.0)/2.0;
    paint = JsonArrayInsert(paint,NuiDrawListText(JsonBool(TRUE),NuiColor(232,211,140),NuiRect(x,6.0,width-x,18.0),JsonString(label)));
    return NuiDrawList(button,JsonBool(FALSE),paint);
}

json DQ_WobbleRect(int frame, int size)
{
    float x = 0.0;
    if (frame == 1 || frame == 5) x = -1.0;
    else if (frame == 2 || frame == 6) x = 1.0;
    else if (frame == 3) x = -2.0;
    else if (frame == 4) x = 2.0;
    float y = (frame == 3 || frame == 4) ? -1.0 : 0.0;
    if (size == 3) return NuiRect(2.0+x*0.5,2.0+y,46.0,30.0);
    if (size == 4) return NuiRect(5.75+x,1.0+y,64.5,42.0);
    if (size == 1) return NuiRect(3.0+x*0.5,3.0+y,38.0,36.0);
    if (size == 2) return NuiRect(4.0+x,2.0+y,68.0,44.0);
    return NuiRect(3.0+x,2.0+y,52.0,46.0);
}

json DQ_RowChestRegion()
{
    return NuiRect(91.0,84.0,1203.0,984.0);
}

json DQ_RowChestRect(int frame, int size)
{
    json box = DQ_WobbleRect(frame,size);
    float boxW = JsonGetFloat(JsonObjectGet(box,"w"));
    float boxH = JsonGetFloat(JsonObjectGet(box,"h"));
    float w = boxW; float h = boxH;
    if (1203.0/984.0 > boxW/boxH) h = w*984.0/1203.0;
    else w = h*1203.0/984.0;
    return NuiRect(JsonGetFloat(JsonObjectGet(box,"x"))+(boxW-w)/2.0,
        JsonGetFloat(JsonObjectGet(box,"y"))+(boxH-h)/2.0,w,h);
}

json DQ_ChestArt(json button, json ready, json idle, int size, float rowWidth, float rowHeight)
{
    string motion = size == 1 ? "dq_rowchest_motion_small" : "dq_rowchest_motion";
    json region = DQ_RowChestRegion();
    json paint = JsonArray();
    float surfaceWidth = size == 4 ? 76.0 : (size == 3 ? 50.0 : (size == 1 ? 44.0 : (size == 2 ? 76.0 : 58.0)));
    float surfaceHeight = size == 4 ? 34.0 : (size == 3 ? 32.0 : (size == 1 ? 42.0 : (size == 2 ? 48.0 : 50.0)));
    // Redraw this exact fragment of the row material over the native button.
    // Avoid a darker rectangular swatch around the transparent object.
    float rewardX = rowWidth-10.0-(size == 1 ? 154.0+78.0 : 230.0+100.0);
    float centeredY = (rowHeight-surfaceHeight)/2.0;
    json rowRegion = NuiRect(10.0+rewardX/rowWidth*1754.0,
        478.0+centeredY/rowHeight*163.0,surfaceWidth/rowWidth*1754.0,surfaceHeight/rowHeight*163.0);
    paint = JsonArrayInsert(paint,DQ_SkinPaint(NuiRect(0.0,0.0,surfaceWidth,surfaceHeight),rowRegion,NUI_DRAW_LIST_ITEM_ORDER_AFTER));
    json resting = NuiDrawListImage(idle,JsonString("dq_chest_r2"),DQ_RowChestRect(0,size),
        JsonInt(NUI_ASPECT_STRETCH),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE));
    json moving = NuiDrawListImage(ready,JsonString("dq_chest_r2"),NuiBind(motion),
        JsonInt(NUI_ASPECT_STRETCH),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE));
    paint = JsonArrayInsert(paint,NuiDrawListImageRegion(resting,region));
    paint = JsonArrayInsert(paint,NuiDrawListImageRegion(moving,region));
    return NuiDrawList(NuiEncouraged(button,ready),JsonBool(FALSE),paint);
}

json DQ_TierChestRegion(int tier)
{
    if (tier == 1) return NuiRect(696.0,104.0,703.0,547.0);
    if (tier == 2) return NuiRect(1430.0,72.0,767.0,588.0);
    return NuiRect(18.0,143.0,633.0,508.0);
}

json DQ_TierChestRect(int frame, int tier, int compact)
{
    json motionBox = DQ_WobbleRect(frame,compact ? 3 : 4);
    float dx = JsonGetFloat(JsonObjectGet(motionBox,"x"))-(compact ? 2.0 : 5.75);
    float dy = JsonGetFloat(JsonObjectGet(motionBox,"y"))-(compact ? 2.0 : 1.0);
    json box = NuiRect(2.0+dx,0.0+dy,compact ? 46.0 : 72.0,compact ? 34.0 : 44.0);
    if (dy < 0.0) box = NuiRect(2.0+dx,0.0,compact ? 46.0 : 72.0,compact ? 34.0 : 44.0);
    json source = DQ_TierChestRegion(tier);
    float sourceW = JsonGetFloat(JsonObjectGet(source,"w"));
    float sourceH = JsonGetFloat(JsonObjectGet(source,"h"));
    float boxW = JsonGetFloat(JsonObjectGet(box,"w"));
    float boxH = JsonGetFloat(JsonObjectGet(box,"h"));
    float w = boxW; float h = boxH;
    if (sourceW/sourceH > boxW/boxH) h = w*sourceH/sourceW;
    else w = h*sourceW/sourceH;
    return NuiRect(JsonGetFloat(JsonObjectGet(box,"x"))+(boxW-w)/2.0,
        JsonGetFloat(JsonObjectGet(box,"y"))+(boxH-h)/2.0,w,h);
}

// Three distinct matte milestone sprites, separate from ordinary row art.
json DQ_BonusChest(int tier, float fullWidth, float bannerHeight, float inset, float lane, int compact)
{
    float w = compact ? 50.0 : 76.0;
    float h = compact ? 34.0 : 44.0;
    float left = inset+lane*IntToFloat(tier+1);
    // Redraw the exact panorama under the hit target, covering the native button
    // skin. Alpha outside the icon reveals this matching banner fragment.
    json region = NuiRect(left/fullWidth*1774.0,16.0+18.0/bannerHeight*226.0,
        w/fullWidth*1774.0,h/bannerHeight*226.0);
    json paint = JsonArray();
    paint = JsonArrayInsert(paint,DQ_SkinPaint(NuiRect(0.0,0.0,w,h),region,NUI_DRAW_LIST_ITEM_ORDER_AFTER));
    float tintStart = bannerHeight-48.0-18.0;
    if (tintStart < h)
        paint = JsonArrayInsert(paint,NuiDrawListRect(JsonBool(TRUE),NuiColor(6,8,12,90),JsonBool(TRUE),JsonFloat(0.0),NuiRect(0.0,tintStart,w,h-tintStart)));
    string motion = "dq_tier_motion_"+IntToString(tier)+(compact ? "_compact" : "_captioned");
    // Transparent object art is lit for this banner; no backing rectangle.
    json source = DQ_TierChestRegion(tier);
    json still = NuiDrawListImage(NuiBind("dq_chest_idle_"+IntToString(tier)),JsonString("dq_chest_t2"),DQ_TierChestRect(0,tier,compact),JsonInt(NUI_ASPECT_STRETCH),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE));
    json moving = NuiDrawListImage(NuiBind("dq_chest_ready_"+IntToString(tier)),JsonString("dq_chest_t2"),NuiBind(motion),JsonInt(NUI_ASPECT_STRETCH),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE));
    paint = JsonArrayInsert(paint,NuiDrawListImageRegion(still,source));
    paint = JsonArrayInsert(paint,NuiDrawListImageRegion(moving,source));
    return NuiDrawList(NuiEncouraged(NuiButton(JsonString("")),NuiBind("dq_chest_ready_"+IntToString(tier))),JsonBool(FALSE),paint);
}

json DQ_RewardIcons(json rewards)
{
    json icons = JsonArray(); int i;
    for (i = 0; i < JsonGetLength(rewards); i++)
    {
        json reward = JsonArrayGet(rewards,i); string type = DQC_Str(reward,"type"); int kind = -1; string tip;
        json amount = JsonObjectGet(reward,"amount");
        if (JsonGetType(amount) == JSON_TYPE_INTEGER && JsonGetInt(amount) <= 0) continue;
        if (type == "gold") { kind = 0; tip = "Gold"; }
        else if (type == "fame") { kind = 1; tip = "Fame"; }
        else if (type == "rune_coins") { kind = 2; tip = "Rune Coins"; }
        else if (type == "reputation") { kind = 1; tip = "Reputation (Preview)"; }
        else if (type == "item")
        {
            string ref = DQC_Str(reward,"resref");
            if (ref == "nw_it_mpotion012") { kind = 3; tip = "Potion"; }
            else if (ref == "fl_scr_grtsanc") { kind = 4; tip = "Scroll"; }
            else if (ref == "fl_scr_grtspml") { kind = 4; tip = "Scroll"; }
            else if (ref == "dq_wand_rest") { kind = 5; tip = "Wand"; }
            else if (ref == "dq_wand_clar") { kind = 5; tip = "Wand"; }
            else if (ref == "dq_wand_free") { kind = 5; tip = "Wand"; }
            else if (ref == "fl_inst_key" && DQC_Str(reward,"category")=="BLUE") { kind = 6; tip = "Newbie Instance Key"; }
            else if (FindSubString("|fl_rune_mass_001|fl_rune_mass_002|fl_rune_mass_003|fl_rune_mass_004|fl_rune_mass_005|fl_rune_mass_006|fl_rune_mass_007|fl_rune_mass_008|fl_rune_mass_009|fl_rune_mass_010|fl_rune_mass_011|fl_rune_mass_012|fl_rune_mass_013|fl_rune_mass_014|fl_rune_mass_015|fl_rune_mass_016|","|"+ref+"|") >= 0) { kind = 7; tip = "Mass Cast Rune"; }
        }
        if (kind < 0) continue;
        json icon = JsonObject(); JsonObjectSetInplace(icon,"kind",JsonInt(kind)); JsonObjectSetInplace(icon,"tip",JsonString(tip)); JsonArrayInsertInplace(icons,icon);
    }
    return icons;
}
json DQ_QuestRewardIcons(json quest)
{
    json icons = DQ_RewardIcons(JsonObjectGet(quest,"rewards"));
    // Mini quantity is intentionally unknown until the fifth credited boss.
    // Show its known reward category in the view without inventing an item
    // entitlement, mutating the saved reward, or advancing any milestone.
    if (DQC_Str(quest,"kind") == "mini_set" && !DQC_Int(quest,"objective_completed") && !DQC_Int(quest,"reward_claimed"))
    {
        int i; int hasKey = FALSE;
        for (i = 0; i < JsonGetLength(icons); i++) if (DQC_Int(JsonArrayGet(icons,i),"kind") == 6) hasKey = TRUE;
        if (!hasKey)
        {
            json icon = JsonObject(); JsonObjectSetInplace(icon,"kind",JsonInt(6));
            JsonObjectSetInplace(icon,"tip",JsonString("Newbie Instance Key")); JsonArrayInsertInplace(icons,icon);
        }
    }
    return icons;
}
json DQ_RewardIconRegion(int kind)
{
    // Fame uses the whole existing inventory texture from client HAKs.
    if (kind == 6) return NuiRect(0.0,0.0,1.0,2.0);
    if (kind == 1 || kind == 7) return NuiRect(0.0,0.0,1.0,1.0);
    if (kind == 2) return NuiRect(252.0,138.0,763.0,1012.0);
    if (kind == 3) return NuiRect(1112.0,162.0,279.0,382.0);
    if (kind == 4) return NuiRect(1434.0,199.0,391.0,327.0);
    if (kind == 5) return NuiRect(1826.0,176.0,293.0,375.0);
    return NuiRect(48.0,237.0,312.0,270.0);
}
json DQ_RewardIconPos(json region)
{
    float w = JsonGetFloat(JsonObjectGet(region,"w")); float h = JsonGetFloat(JsonObjectGet(region,"h"));
    if (w >= h) { h = 24.0*h/w; w = 24.0; }
    else { w = 24.0*w/h; h = 24.0; }
    return NuiRect((28.0-w)/2.0,(28.0-h)/2.0,w,h);
}

json DQ_Bindings(object state, json items, string tab)
{
    json result = JsonObject();
    json titles = JsonArray(); json targets = JsonArray(); json places = JsonArray();
    json objectives = JsonArray(); json completedRows = JsonArray();
    json rewards = JsonArray(); json progress = JsonArray(); json labels = JsonArray();
    json rewardHints = JsonArray();
    json ready = JsonArray(); json portraits = JsonArray(); json fractions = JsonArray();
    json ids = JsonArray(); json hints = JsonArray(); json rewardIcons = JsonArray();
    json mobTextures = JsonArray(); json mobRegions = JsonArray(); json mobPresent = JsonArray(); json mobPainted = JsonArray(); json mobNative = JsonArray();
    int completed = 0;
    int anyReady = FALSE;
    int i;
    for (i = 0; i < JsonGetLength(items); i++)
    {
        json q = JsonArrayGet(items,i);
        json mob = DQ_PaintedPortrait(q);
        JsonArrayInsertInplace(mobPainted,JsonBool(DQC_Int(mob,"painted")));
        JsonArrayInsertInplace(mobNative,JsonBool(!DQC_Int(mob,"painted") && DQC_Str(mob,"texture") != ""));
        JsonArrayInsertInplace(mobTextures,JsonObjectGet(mob,"texture"));
        JsonArrayInsertInplace(mobRegions,JsonObjectGet(mob,"region"));
        JsonArrayInsertInplace(mobPresent,JsonBool(DQC_Str(mob,"texture") != ""));
        string id = JsonGetString(JsonObjectGet(q,"id"));
        int live = JsonGetType(JsonObjectGet(q,"owner")) == JSON_TYPE_INTEGER;
        int status = GetLocalInt(state,"DQ_PREVIEW_"+id);
        if (live) status = DQC_Int(q,"reward_claimed") ? 2 : (DQC_Int(q,"objective_completed") ? 1 : 0);
        if (status == 2) completed++;
        if (status == 1) anyReady = TRUE;
        string objective = "Defeat ## enemies";
        if (live) objective = "Defeat "+IntToString(DQC_Int(q,"required"))+" enemies";
        if (live && (DQC_Str(q,"kind") == "champion" || DQC_Str(q,"kind") == "champion_any")) objective = "Defeat "+IntToString(DQC_Int(q,"required"))+" champions";
        if (live && DQC_Str(q,"kind")=="mini_set") objective="Defeat 5 named mini bosses";
        if (live && DQC_Str(q,"kind")=="pvp_hunt") objective="Defeat "+IntToString(DQC_Int(q,"required"))+" distinct enemy players";
        if (live && DQC_Int(q,"waiting")) objective = "Waiting for carried quest";
        if (JsonGetString(JsonObjectGet(q,"kind")) == "kill_boss_set") objective = "Defeat every boss in this set";
        string text = "Replace";
        titles = JsonArrayInsert(titles,JsonObjectGet(q,"title"));
        targets = JsonArrayInsert(targets,JsonString(objective));
        places = JsonArrayInsert(places,JsonObjectGet(q,"locations"));
        objectives = JsonArrayInsert(objectives,JsonString(JsonGetString(JsonObjectGet(q,"title"))+"\n"+
            objective+"\n"+JsonGetString(JsonObjectGet(q,"locations"))));
        completedRows = JsonArrayInsert(completedRows,JsonBool(status > 0));
        rewards = JsonArrayInsert(rewards,JsonString(DQ_RewardText(JsonObjectGet(q,"rewards"),DQC_Int(JsonObjectGet(q,"reward"),"reward_version") == 2)));
        json rowIcons = DQ_QuestRewardIcons(q); JsonArrayInsertInplace(rewardIcons,rowIcons);
        string progressText = status > 0 ? "## / ##" : "0 / ##";
        if (live) progressText = IntToString(DQC_Int(q,"progress"))+" / "+IntToString(DQC_Int(q,"required"));
        progress = JsonArrayInsert(progress,JsonString(progressText));
        labels = JsonArrayInsert(labels,JsonString(text));
        ready = JsonArrayInsert(ready,JsonBool(status == 1));
        portraits = JsonArrayInsert(portraits,DQ_Portrait(JsonGetInt(JsonObjectGet(q,"icon"))));
        float fraction = status > 0 ? 1.0 : 0.0;
        if (live && DQC_Int(q,"required") > 0) fraction = IntToFloat(DQC_Int(q,"progress"))/IntToFloat(DQC_Int(q,"required"));
        fractions = JsonArrayInsert(fractions,JsonFloat(fraction));
        ids = JsonArrayInsert(ids,JsonString(id));
        string rewardState = status == 2 ? "Claimed" : (status == 1 ? "Click chest to claim" : "Complete this quest to unlock");
        if (live && DQC_Int(q,"waiting")) rewardState = "Claim the overlapping carried quest first. No shared kill credit";
        string rewardNames; int n;
        for (n = 0; n < JsonGetLength(rowIcons); n++)
        {
            if (rewardNames != "") rewardNames += ", "; rewardNames += DQC_Str(JsonArrayGet(rowIcons,n),"tip");
        }
        rewardHints = JsonArrayInsert(rewardHints,JsonString(rewardState+". "+rewardNames));
        hints = JsonArrayInsert(hints,JsonString(DQ_TooltipText(JsonGetString(JsonObjectGet(q,"title"))+" | "+
            JsonGetString(JsonObjectGet(q,"locations")))));
    }
    JsonObjectSetInplace(result,"dq_title",titles);
    JsonObjectSetInplace(result,"dq_target",targets);
    JsonObjectSetInplace(result,"dq_places",places);
    JsonObjectSetInplace(result,"dq_objective",objectives);
    JsonObjectSetInplace(result,"dq_complete",completedRows);
    JsonObjectSetInplace(result,"dq_rewards",rewards);
    JsonObjectSetInplace(result,"dq_reward_icons",rewardIcons);
    JsonObjectSetInplace(result,"dq_reward_hint",rewardHints);
    JsonObjectSetInplace(result,"dq_progress",progress);
    JsonObjectSetInplace(result,"dq_claim_label",labels);
    JsonObjectSetInplace(result,"dq_ready",ready);
    JsonObjectSetInplace(result,"dq_portrait",portraits);
    JsonObjectSetInplace(result,"dq_mobtex",mobTextures);
    JsonObjectSetInplace(result,"dq_mobregion",mobRegions);
    JsonObjectSetInplace(result,"dq_mobpresent",mobPresent);
    JsonObjectSetInplace(result,"dq_mobpainted",mobPainted);
    JsonObjectSetInplace(result,"dq_mobnative",mobNative);
    JsonObjectSetInplace(result,"dq_fraction",fractions);
    JsonObjectSetInplace(result,"dq_ids",ids);
    JsonObjectSetInplace(result,"dq_hint",hints);
    JsonObjectSetInplace(result,"dq_count",JsonInt(JsonGetLength(items)));
    JsonObjectSetInplace(result,"dq_completed",JsonInt(completed));
    int total = 15;
    int preview = GetLocalInt(state,"DQ_UI_PREVIEW");
    json saved = GetLocalJson(state,"DQ_LIVE_STATE");
    if (!preview) completed = DQC_Int(saved,"claimed_count");
    JsonObjectSetInplace(result,"dq_completed",JsonInt(completed));
    JsonObjectSetInplace(result,"dq_overall_text",JsonString("Daily completion: "+IntToString(completed)+" / 15"));
    JsonObjectSetInplace(result,"dq_overall",JsonFloat(IntToFloat(completed)/15.0));
    JsonObjectSetInplace(result,"dq_reset",JsonString("Daily reset: 09:00 MSK"));
    int unavailable = GetLocalInt(state,"DQ_UI_UNAVAILABLE");
    int used = 3-DQC_Int(saved,"rerolls_remaining");
    string bannerHint = preview ? "PREVIEW - no rewards" : "Bonuses: 5 / 10 / 15 claimed";
    if (!preview && DQC_Int(saved,"issuance_blocked")) bannerHint = "Finish carried quests first";
    if (unavailable) bannerHint = "Daily temporarily unavailable";
    JsonObjectSetInplace(result,"dq_banner_hint",JsonString(bannerHint));
    JsonObjectSetInplace(result,"dq_rerolls",JsonString(unavailable ? "Replacements used: --/3" : (preview ? "Preview: no replacements" : "Replacements used: "+IntToString(used)+"/3")));
    JsonObjectSetInplace(result,"dq_reroll_hint",JsonString(unavailable ? "Stored attempts could not be loaded. Reopen the journal to retry." : (preview ? "Preview never spends replacements." : IntToString(used)+" of 3 replacements used; "+IntToString(3-used)+" remaining. Resets at 09:00 MSK.")));
    for (i = 0; i < 3; i++) JsonObjectSetInplace(result,"dq_reroll_used_"+IntToString(i),JsonBool(!preview && !unavailable && used > i));
    if (unavailable)
    {
        completed = 0;
        JsonObjectSetInplace(result,"dq_overall_text",JsonString("Daily completion: -- / 15"));
        JsonObjectSetInplace(result,"dq_overall",JsonFloat(0.0));
    }
    for (i = 0; i < 3; i++)
    {
        string suffix = IntToString(i);
        int threshold = (i+1)*5;
        int claimed = preview ? GetLocalInt(state,"DQ_PREVIEW_CHEST_"+tab+"_"+suffix) : JsonGetInt(JsonArrayGet(JsonObjectGet(saved,"chests"),i));
        int available = !unavailable && completed >= threshold && !claimed;
        string label = claimed ? "Claimed" : (available ? "Available" : "Locked");
        JsonObjectSetInplace(result,"dq_chest_ready_"+suffix,JsonBool(available));
        JsonObjectSetInplace(result,"dq_chest_idle_"+suffix,JsonBool(!available));
        JsonObjectSetInplace(result,"dq_chest_label_"+suffix,JsonString(label));
        JsonObjectSetInplace(result,"dq_chest_text_"+suffix,JsonString(IntToString(threshold)+" quests: "+label+(preview ? " (Preview, no rewards)" : "")));
        if (available) anyReady = TRUE;
    }
    JsonObjectSetInplace(result,"dq_any_ready",JsonBool(anyReady));
    JsonObjectSetInplace(result,"dq_chest_motion",DQ_WobbleRect(0,0));
    JsonObjectSetInplace(result,"dq_chest_motion_small",DQ_WobbleRect(0,1));
    JsonObjectSetInplace(result,"dq_chest_motion_milestone",DQ_WobbleRect(0,2));
    JsonObjectSetInplace(result,"dq_chest_motion_compact",DQ_WobbleRect(0,3));
    JsonObjectSetInplace(result,"dq_chest_motion_captioned",DQ_WobbleRect(0,4));
    JsonObjectSetInplace(result,"dq_rowchest_motion",DQ_RowChestRect(0,0));
    JsonObjectSetInplace(result,"dq_rowchest_motion_small",DQ_RowChestRect(0,1));
    for (i = 0; i < 3; i++)
    {
        JsonObjectSetInplace(result,"dq_tier_motion_"+IntToString(i)+"_compact",DQ_TierChestRect(0,i,TRUE));
        JsonObjectSetInplace(result,"dq_tier_motion_"+IntToString(i)+"_captioned",DQ_TierChestRect(0,i,FALSE));
    }
    return result;
}

json DQ_ViewData(object state, json items, string tab, float width = 960.0)
{
    json data = DQ_Bindings(state,items,tab);
    json keys = JsonObjectKeys(data);
    int small = width < 900.0;
    float fixedWidth = small ? 386.0 : 574.0;
    int columns = FloatToInt((width-44.0-fixedWidth)/7.2);
    if (columns < 16) columns = 16;
    int rewardColumns = small ? 14 : 23;
    int row;
    for (row = 0; row < JsonGetLength(items); row++)
    {
        json quest = JsonArrayGet(items,row);
        int live = JsonGetType(JsonObjectGet(quest,"owner")) == JSON_TYPE_INTEGER;
        int canReplace = live && !DQC_Int(quest,"objective_completed") && !DQC_Int(quest,"reward_claimed") &&
            DQC_Int(quest,"origin_cycle") == DQC_Int(GetLocalJson(state,"DQ_LIVE_STATE"),"cycle") &&
            DQC_Int(GetLocalJson(state,"DQ_LIVE_STATE"),"rerolls_remaining") > 0;
        JsonObjectSetInplace(data,"dq_action_ready_"+IntToString(row),JsonBool(canReplace));
        JsonObjectSetInplace(data,"dq_idle_"+IntToString(row),JsonBool(!JsonGetInt(JsonArrayGet(JsonObjectGet(data,"dq_ready"),row))));
        int keyIndex;
        for (keyIndex = 0; keyIndex < JsonGetLength(keys); keyIndex++)
        {
            string rowKey = JsonGetString(JsonArrayGet(keys,keyIndex));
            json values = JsonObjectGet(data,rowKey);
            if (JsonGetType(values) == JSON_TYPE_ARRAY)
                JsonObjectSetInplace(data,rowKey+"_"+IntToString(row),JsonArrayGet(values,row));
        }
        if (JsonGetInt(JsonObjectGet(data,"dq_mobpainted_"+IntToString(row))))
            JsonObjectSetInplace(data,"dq_mobregion_"+IntToString(row),DQA_Region(JsonObjectGet(data,"dq_mobregion_"+IntToString(row)),small ? 50.0 : 66.0,42.0));
        json rowIcons = JsonArrayGet(JsonObjectGet(data,"dq_reward_icons"),row); int iconIndex;
        for (iconIndex = 0; iconIndex < 3; iconIndex++)
        {
            string key = IntToString(iconIndex)+"_"+IntToString(row);
            json icon = JsonArrayGet(rowIcons,iconIndex); json region = DQ_RewardIconRegion(DQC_Int(icon,"kind"));
            JsonObjectSetInplace(data,"dq_reward_icon_visible_"+key,JsonBool(iconIndex < JsonGetLength(rowIcons)));
            JsonObjectSetInplace(data,"dq_reward_icon_tip_"+key,JsonString(DQC_Str(icon,"tip")));
            int nativeIcon = DQC_Int(icon,"kind") == 1 || DQC_Int(icon,"kind") == 6 || DQC_Int(icon,"kind") == 7;
            string nativeTexture = DQC_Int(icon,"kind") == 6 ? "iit_key_t_022" : (DQC_Int(icon,"kind") == 7 ? "iit_smlmisc_028" : "iit_smlmis_001");
            JsonObjectSetInplace(data,"dq_reward_icon_texture_"+key,JsonString(nativeIcon ? nativeTexture : (DQC_Int(icon,"kind") == 2 ? "dq_rune" : "dq_rewards")));
            JsonObjectSetInplace(data,"dq_reward_icon_keyparts_"+key,JsonBool(DQC_Int(icon,"kind") == 6));
            JsonObjectSetInplace(data,"dq_reward_icon_native_"+key,JsonBool(nativeIcon));
            JsonObjectSetInplace(data,"dq_reward_icon_slice_"+key,JsonBool(!nativeIcon));
            JsonObjectSetInplace(data,"dq_reward_icon_region_"+key,region);
            JsonObjectSetInplace(data,"dq_reward_icon_pos_"+key,DQ_RewardIconPos(region));
        }
        string number = IntToString(row);
        JsonObjectSetInplace(data,"dq_places_paint_"+number,JsonString(DQ_WrapText(JsonGetString(JsonObjectGet(data,"dq_places_"+number)),columns,2)));
        JsonObjectSetInplace(data,"dq_rewards_paint_"+number,JsonString(DQ_WrapText(JsonGetString(JsonObjectGet(data,"dq_rewards_"+number)),rewardColumns,3)));
        string label = JsonGetString(JsonObjectGet(data,"dq_claim_label_"+number));
        float buttonWidth = small ? 70.0 : 92.0;
        float labelWidth = IntToFloat(GetStringLength(label))*6.2;
        float labelX = (buttonWidth-labelWidth)/2.0;
        if (labelX < 0.0) labelX = 0.0;
        JsonObjectSetInplace(data,"dq_claim_text_rect_"+number,NuiRect(labelX,8.0,buttonWidth-labelX,16.0));
    }
    return data;
}

int DQ_DescIndex(string character)
{
    int index = FindSubString(DQ_DESC_CHARS,character);
    if (index < 0) index = FindSubString(DQ_DESC_CHARS,"?");
    return index;
}

int DQ_DescWidth(string text, json metrics)
{
    int width = 0;
    int i;
    for (i = 0; i < GetStringLength(text); i++)
        width += JsonGetInt(JsonArrayGet(JsonArrayGet(metrics,DQ_DescIndex(GetSubString(text,i,1))),4));
    return width;
}

json DQ_DescLines(string text, int available, json metrics)
{
    json lines = JsonArray();
    int position = 0;
    int length = GetStringLength(text);
    while (position < length && JsonGetLength(lines) < 2)
    {
        while (position < length && (GetSubString(text,position,1) == " " || GetSubString(text,position,1) == "\n")) position++;
        if (position >= length) break;
        int start = position;
        int lastSpace = -1;
        int pixels = 0;
        while (position < length)
        {
            string character = GetSubString(text,position,1);
            if (character == "\n") break;
            int advance = JsonGetInt(JsonArrayGet(JsonArrayGet(metrics,DQ_DescIndex(character)),4));
            if (pixels+advance > available) break;
            if (character == " ") lastSpace = position;
            pixels += advance;
            position++;
        }
        if (position < length && GetSubString(text,position,1) != "\n" && lastSpace > start)
            position = lastSpace;
        if (position == start) position++;
        string part = GetSubString(text,start,position-start);
        while (GetStringLength(part) > 0 && GetStringRight(part,1) == " ") part = GetStringLeft(part,GetStringLength(part)-1);
        while (position < length && (GetSubString(text,position,1) == " " || GetSubString(text,position,1) == "\n")) position++;
        if (JsonGetLength(lines) == 1 && position < length)
        {
            while (GetStringLength(part) > 0 && DQ_DescWidth(part+"...",metrics) > available)
                part = GetStringLeft(part,GetStringLength(part)-1);
            part += "...";
        }
        JsonArrayInsertInplace(lines,JsonString(part));
    }
    return lines;
}

json DQ_Description(string text, float width)
{
    json metrics = JsonParse(DQ_DESC_METRICS);
    json lines = DQ_DescLines(text,FloatToInt(width-16.0),metrics);
    json paint = JsonArray();
    float top = (52.0-IntToFloat(JsonGetLength(lines))*26.0)/2.0;
    int line;
    for (line = 0; line < JsonGetLength(lines); line++)
    {
        string part = JsonGetString(JsonArrayGet(lines,line));
        float x = (width-IntToFloat(DQ_DescWidth(part,metrics)))/2.0;
        int i;
        for (i = 0; i < GetStringLength(part); i++)
        {
            json m = JsonArrayGet(metrics,DQ_DescIndex(GetSubString(part,i,1)));
            float w = IntToFloat(JsonGetInt(JsonArrayGet(m,2)));
            float h = IntToFloat(JsonGetInt(JsonArrayGet(m,3)));
            if (w > 0.0 && h > 0.0)
            {
                json source = NuiRect(IntToFloat(JsonGetInt(JsonArrayGet(m,0))),IntToFloat(JsonGetInt(JsonArrayGet(m,1))),w,h);
                json target = NuiRect(x+IntToFloat(JsonGetInt(JsonArrayGet(m,5))),top+IntToFloat(line)*26.0+IntToFloat(JsonGetInt(JsonArrayGet(m,6))),w,h);
                json glyph = NuiDrawListImage(JsonBool(TRUE),JsonString("dq_desc20"),target,
                    JsonInt(NUI_ASPECT_STRETCH),JsonInt(NUI_HALIGN_LEFT),JsonInt(NUI_VALIGN_TOP));
                paint = JsonArrayInsert(paint,NuiDrawListImageRegion(glyph,source));
            }
            x += IntToFloat(JsonGetInt(JsonArrayGet(m,4)));
        }
    }
    return DQ_LayoutSpacing(NuiTooltip(NuiDrawList(NuiLabel(JsonString(""),JsonInt(NUI_HALIGN_LEFT),JsonInt(NUI_VALIGN_TOP)),
        JsonBool(FALSE),paint),NuiBind("dq_feedback")));
}

void DQ_SetFeedback(object pc, int token, string text)
{
    NuiSetBind(pc,token,"dq_feedback",JsonString(text));
    float width = JsonGetFloat(JsonObjectGet(NuiGetUserData(pc,token),"width"));
    if (width >= 400.0) NuiSetGroupLayout(pc,token,"dq_description",DQ_Description(text,width-64.0));
}

void DQ_Refresh(object pc, int token, string tab)
{
    json data = DQ_ViewData(pc,DQ_Items(DQ_CatalogFor(pc),tab),tab,JsonGetFloat(JsonObjectGet(NuiGetUserData(pc,token),"width")));
    json keys = JsonObjectKeys(data);
    int i;
    for (i = 0; i < JsonGetLength(keys); i++)
    {
        string key = JsonGetString(JsonArrayGet(keys,i));
        NuiSetBind(pc,token,key,JsonObjectGet(data,key));
    }
    NuiSetUserData(pc,token,JsonObjectSet(JsonObjectSet(NuiGetUserData(pc,token),"tab",JsonString(tab)),
        "ids",JsonObjectGet(data,"dq_ids")));
    NuiSetUserData(pc,token,JsonObjectSet(NuiGetUserData(pc,token),"ready",JsonObjectGet(data,"dq_ready")));
    DQ_SetFeedback(pc,token,GetLocalInt(pc,"DQ_UI_UNAVAILABLE") ? "Daily temporarily unavailable. Close and reopen the journal to retry. Stored progress is retained." : (GetLocalInt(pc,"DQ_UI_PREVIEW") ? "Preview. No rewards are granted." : "Click a ready chest for rewards. Use Replace to change a quest. Gold goes to your bank."));
}

// Scalar row bindings allow ordinary scroll groups to use compact, nested
// layouts. NuiList cells cannot contain these rows/columns on EE 8193.37.
string DQ_RowKey(string name, int index)
{
    return name+"_"+IntToString(index);
}

json DQ_RowBind(string name, int index)
{
    return NuiBind(DQ_RowKey(name,index));
}

json DQ_Centered(json element, float elementHeight)
{
    json parts = JsonArray();
    parts = JsonArrayInsert(parts,NuiSpacer());
    parts = JsonArrayInsert(parts,NuiHeight(element,elementHeight));
    parts = JsonArrayInsert(parts,NuiSpacer());
    return NuiCol(parts);
}

json DQ_Outline(json element, float width, float height)
{
    json paint = JsonArray();
    paint = JsonArrayInsert(paint,NuiDrawListRect(JsonBool(TRUE),NuiColor(108,84,42),
        JsonBool(FALSE),JsonFloat(1.0),NuiRect(0.0,0.0,width,height)));
    return NuiDrawList(element,JsonBool(FALSE),paint);
}

// Use the already installed description glyph sheet at 12 px. No global
// nui_skin/font registry changes. The full location remains in the tooltip.
json DQ_Location(string text, float width, float height)
{
    float scale = 0.60;
    json metrics = JsonParse(DQ_DESC_METRICS);
    json lines = DQ_DescLines(text,FloatToInt((width-4.0)/scale),metrics);
    json paint = JsonArray(); int line;
    for (line = 0; line < JsonGetLength(lines); line++)
    {
        string part = JsonGetString(JsonArrayGet(lines,line)); float x = 0.0; int i;
        for (i = 0; i < GetStringLength(part); i++)
        {
            json m = JsonArrayGet(metrics,DQ_DescIndex(GetSubString(part,i,1)));
            float w = IntToFloat(JsonGetInt(JsonArrayGet(m,2)));
            float h = IntToFloat(JsonGetInt(JsonArrayGet(m,3)));
            if (w > 0.0 && h > 0.0)
            {
                json source = NuiRect(IntToFloat(JsonGetInt(JsonArrayGet(m,0))),IntToFloat(JsonGetInt(JsonArrayGet(m,1))),w,h);
                json target = NuiRect(2.0+x+IntToFloat(JsonGetInt(JsonArrayGet(m,5)))*scale,IntToFloat(line)*12.0+IntToFloat(JsonGetInt(JsonArrayGet(m,6))-2)*scale,w*scale,h*scale);
                json glyph = NuiDrawListImage(JsonBool(TRUE),JsonString("dq_desc20"),target,JsonInt(NUI_ASPECT_STRETCH),JsonInt(NUI_HALIGN_LEFT),JsonInt(NUI_VALIGN_TOP));
                JsonArrayInsertInplace(paint,NuiDrawListImageRegion(glyph,source));
            }
            x += IntToFloat(JsonGetInt(JsonArrayGet(m,4)))*scale;
        }
    }
    return NuiTooltip(NuiDrawList(NuiLabel(JsonString(""),JsonInt(NUI_HALIGN_LEFT),JsonInt(NUI_VALIGN_TOP)),JsonBool(FALSE),paint),JsonString(DQ_TooltipText(text)));
}

json DQ_QuestRow(int index, float width, float rowHeight, json quest)
{
    int small = width < 900.0;
    float portraitWidth = small ? 60.0 : 76.0;
    float progressWidth = small ? 86.0 : 158.0;
    float rewardWidth = small ? 154.0 : 230.0;
    float claimWidth = small ? 78.0 : 100.0;
    float insideHeight = rowHeight-8.0;
    float textHeight = small ? 56.0 : rowHeight-38.0;
    float descriptionWidth = width-44.0-(small ? 386.0 : 574.0);
    json parts = JsonArray();
    json portrait = NuiImageRegion(NuiButtonImage(JsonString("dq_atlas")),DQ_RowBind("dq_portrait",index));
    portrait = JsonObjectSet(portrait,"image_aspect",JsonInt(NUI_ASPECT_FIT));
    // Paint only the interior; keep the established portrait frame and click ID.
    float artHeight = small ? 52.0 : rowHeight-12.0;
    json mobPaint = JsonArray();
    json portraitRect = NuiRect(5.0,5.0,portraitWidth-10.0,artHeight-10.0);
    // Clear the old atlas picture inside its existing gold frame. Display the
    // whole native portrait with one uniform scale; no crop or forced fill.
    JsonArrayInsertInplace(mobPaint,NuiDrawListRect(DQ_RowBind("dq_mobpresent",index),NuiColor(10,11,12),JsonBool(TRUE),JsonFloat(0.0),portraitRect));
    json mobImage = NuiDrawListImage(DQ_RowBind("dq_mobnative",index),DQ_RowBind("dq_mobtex",index),portraitRect,JsonInt(NUI_ASPECT_FIT),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE));
    JsonArrayInsertInplace(mobPaint,mobImage);
    json artwork = NuiDrawListImage(DQ_RowBind("dq_mobpainted",index),DQ_RowBind("dq_mobtex",index),portraitRect,JsonInt(NUI_ASPECT_STRETCH),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE));
    JsonArrayInsertInplace(mobPaint,NuiDrawListImageRegion(artwork,DQ_RowBind("dq_mobregion",index)));
    portrait = NuiDrawList(portrait,JsonBool(FALSE),mobPaint);
    portrait = NuiTooltip(NuiId(portrait,"details_"+IntToString(index)),DQ_RowBind("dq_hint",index));
    parts = JsonArrayInsert(parts,NuiWidth(DQ_Centered(portrait,small ? 52.0 : rowHeight-12.0),portraitWidth));
    parts = JsonArrayInsert(parts,NuiWidth(NuiSpacer(),small ? 8.0 : 10.0));
    json objective = JsonArray();
    objective = JsonArrayInsert(objective,NuiHeight(DQ_Label(DQ_RowBind("dq_title",index)),16.0));
    objective = JsonArrayInsert(objective,NuiHeight(NuiStyleForegroundColor(NuiLabel(DQ_RowBind("dq_target",index),
        JsonInt(NUI_HALIGN_LEFT),JsonInt(NUI_VALIGN_MIDDLE)),NuiColor(220,217,208)),14.0));
    objective = JsonArrayInsert(objective,NuiHeight(DQ_Location(DQC_Str(quest,"locations"),descriptionWidth,textHeight),textHeight));
    parts = JsonArrayInsert(parts,NuiCol(objective));
    json progressParts = JsonArray();
    progressParts = JsonArrayInsert(progressParts,NuiSpacer());
    progressParts = JsonArrayInsert(progressParts,NuiHeight(NuiStyleForegroundColor(NuiLabel(DQ_RowBind("dq_progress",index),
        JsonInt(NUI_HALIGN_LEFT),JsonInt(NUI_VALIGN_MIDDLE)),NuiColor(225,223,215)),20.0));
    progressParts = JsonArrayInsert(progressParts,NuiHeight(NuiStyleForegroundColor(NuiProgress(DQ_RowBind("dq_fraction",index)),
        NuiColor(104,68,155)),10.0));
    progressParts = JsonArrayInsert(progressParts,NuiHeight(NuiSpacer(),8.0));
    parts = JsonArrayInsert(parts,NuiWidth(NuiPadding(NuiCol(progressParts),4.0),progressWidth));
    json chest = DQ_ChestArt(NuiButton(JsonString("")),DQ_RowBind("dq_ready",index),DQ_RowBind("dq_idle",index),small ? 1 : 0,width-34.0,insideHeight);
    // Match milestone art: locked/claimed icons keep full visual brightness.
    // dq_event still checks displayed readiness and saved objective before claim.
    chest = NuiEnabled(NuiId(chest,"reward_"+IntToString(index)),JsonBool(TRUE));
    chest = NuiDisabledTooltip(NuiTooltip(chest,DQ_RowBind("dq_reward_hint",index)),DQ_RowBind("dq_reward_hint",index));
    json rewardParts = JsonArray();
    rewardParts = JsonArrayInsert(rewardParts,NuiWidth(DQ_Centered(chest,small ? 42.0 : 50.0),small ? 44.0 : 58.0));
    rewardParts = JsonArrayInsert(rewardParts,NuiWidth(NuiSpacer(),6.0));
    json iconRow = JsonArray(); int iconIndex;
    for (iconIndex = 0; iconIndex < 3; iconIndex++)
    {
        string key = IntToString(iconIndex)+"_"+IntToString(index);
        json paint = JsonArray();
        json sprite = NuiDrawListImage(NuiBind("dq_reward_icon_slice_"+key),NuiBind("dq_reward_icon_texture_"+key),NuiBind("dq_reward_icon_pos_"+key),JsonInt(NUI_ASPECT_STRETCH),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE));
        paint = JsonArrayInsert(paint,NuiDrawListImageRegion(sprite,NuiBind("dq_reward_icon_region_"+key)));
        // Native Fame inventory icon has no atlas crop or invented replacement art.
        paint = JsonArrayInsert(paint,NuiDrawListImage(NuiBind("dq_reward_icon_native_"+key),NuiBind("dq_reward_icon_texture_"+key),NuiBind("dq_reward_icon_pos_"+key),JsonInt(NUI_ASPECT_FIT),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE)));
        // fl_inst_key is a three-part model (22/33/33), not iit_key_022.
        paint = JsonArrayInsert(paint,NuiDrawListImage(NuiBind("dq_reward_icon_keyparts_"+key),JsonString("iit_key_m_033"),NuiBind("dq_reward_icon_pos_"+key),JsonInt(NUI_ASPECT_FIT),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE)));
        paint = JsonArrayInsert(paint,NuiDrawListImage(NuiBind("dq_reward_icon_keyparts_"+key),JsonString("iit_key_b_033"),NuiBind("dq_reward_icon_pos_"+key),JsonInt(NUI_ASPECT_FIT),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE)));
        json icon = NuiDrawList(NuiLabel(JsonString(""),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE)),JsonBool(FALSE),paint);
        icon = NuiId(NuiVisible(NuiTooltip(icon,NuiBind("dq_reward_icon_tip_"+key)),NuiBind("dq_reward_icon_visible_"+key)),"loot_icon_"+key);
        iconRow = JsonArrayInsert(iconRow,NuiWidth(icon,28.0));
    }
    iconRow = JsonArrayInsert(iconRow,NuiSpacer());
    rewardParts = JsonArrayInsert(rewardParts,DQ_Centered(NuiRow(iconRow),28.0));
    parts = JsonArrayInsert(parts,NuiWidth(NuiRow(rewardParts),rewardWidth));
    json claim = NuiEnabled(NuiId(NuiButton(JsonString("")),"claim_"+IntToString(index)),
        DQ_RowBind("dq_action_ready",index));
    claim = DQ_SmallButton(claim,claimWidth-8.0,30.0,DQ_RowBind("dq_claim_label",index),DQ_RowBind("dq_claim_text_rect",index),DQ_RowBind("dq_action_ready",index));
    claim = NuiDisabledTooltip(NuiTooltip(claim,DQ_RowBind("dq_hint",index)),DQ_RowBind("dq_hint",index));
    // Reserve an actual trailing gutter; padding on the surrounding column
    // does not reliably constrain the button paint in the EE client.
    json claimSlot = JsonArray();
    claimSlot = JsonArrayInsert(claimSlot,NuiWidth(claim,claimWidth-8.0));
    claimSlot = JsonArrayInsert(claimSlot,NuiWidth(NuiSpacer(),8.0));
    parts = JsonArrayInsert(parts,NuiWidth(DQ_Centered(NuiRow(claimSlot),30.0),claimWidth));
    // The painted frame must cover the rightmost controls, not stop 16px
    // before the row's available width as in the previous release.
    json row = NuiId(NuiHeight(NuiMargin(NuiPadding(NuiGroup(DQ_Material(NuiRow(parts),width-34.0,insideHeight,1),FALSE,NUI_SCROLLBARS_NONE),4.0),1.0),rowHeight),
        "quest_"+IntToString(index));
    return row;
}

json DQ_Content(json catalog, float width, float height, string tab)
{
    int small = width < 900.0;
    int compact = height < 600.0;
    int medium = height < 760.0;
    float headerHeight = compact ? 64.0 : 96.0;
    float bannerHeight = compact ? 84.0 : 120.0;
    float footerHeight = 72.0;
    float labelsHeight = 24.0;
    float listHeight = height-headerHeight-bannerHeight-footerHeight-labelsHeight-24.0;
    float rowHeight = small ? 96.0 : 64.0;
    float progressWidth = small ? 86.0 : 158.0;
    float rewardWidth = small ? 154.0 : 230.0;
    float claimWidth = small ? 78.0 : 100.0;
    float logoSlotWidth = compact ? 128.0 : 196.0;
    float logoWidth = logoSlotWidth-32.0;
    float logoHeight = logoWidth/2.05;
    json col = JsonArray();
    json header = JsonArray();
    json logo = JsonArray();
    logo = JsonArrayInsert(logo,NuiSpacer());
    json logoArt = DQ_Image(NuiRect(80.0,16.0,345.0,168.0));
    json corners = JsonArray();
    corners = JsonArrayInsert(corners,DQ_SkinPaint(NuiRect(0.0,0.0,logoWidth*0.12,logoHeight*0.045),NuiRect(300.0,300.0,100.0,40.0),NUI_DRAW_LIST_ITEM_ORDER_AFTER));
    corners = JsonArrayInsert(corners,DQ_SkinPaint(NuiRect(logoWidth*0.88,0.0,logoWidth*0.12,logoHeight*0.045),NuiRect(300.0,300.0,100.0,40.0),NUI_DRAW_LIST_ITEM_ORDER_AFTER));
    logo = JsonArrayInsert(logo,NuiWidth(NuiDrawList(logoArt,JsonBool(FALSE),corners),logoWidth));
    logo = JsonArrayInsert(logo,NuiSpacer());
    header = JsonArrayInsert(header,NuiWidth(DQ_Centered(NuiRow(logo),logoHeight),logoSlotWidth));
    json right = JsonArray();
    json titleParts = JsonArray();
    float titleHeight = compact ? 28.0 : 36.0;
    float titleWidth = small ? 218.0 : 280.0;
    json title = DQ_Label(JsonObjectGet(catalog,"window_title"));
    if (JsonGetString(JsonObjectGet(catalog,"window_title")) == "DAILY QUESTS")
        title = DQ_Image(NuiRect(445.0,52.0,372.0,50.0));
    titleParts = JsonArrayInsert(titleParts,NuiWidth(DQ_Centered(title,titleHeight),titleWidth));
    titleParts = JsonArrayInsert(titleParts,NuiSpacer());
    titleParts = JsonArrayInsert(titleParts,NuiWidth(NuiSpacer(),68.0)); // Preview control hidden; internal preview remains available.
    titleParts = JsonArrayInsert(titleParts,NuiWidth(NuiSpacer(),6.0));
    titleParts = JsonArrayInsert(titleParts,NuiWidth(DQ_Centered(NuiId(NuiButton(JsonString("X")),"close"),28.0),30.0));
    json tabs = JsonObjectGet(catalog,"tabs");
    int showTabs = JsonGetLength(tabs) > 1;
    right = JsonArrayInsert(right,NuiHeight(NuiRow(titleParts),showTabs ? (compact ? 36.0 : 52.0) : headerHeight));
    int i;
    if (showTabs)
    {
        json tabrow = JsonArray();
        for (i = 0; i < JsonGetLength(tabs); i++)
        {
            json t = JsonArrayGet(tabs,i);
            string id = JsonGetString(JsonObjectGet(t,"id"));
            float tabWidth = small ? 100.0 : 150.0;
            json button = NuiId(DQ_TabSkin(NuiButtonSelect(JsonString(""),NuiBind("dq_tab_"+id)),JsonGetString(JsonObjectGet(t,"label")),tabWidth,28.0,NuiBind("dq_tab_"+id)),"tab_"+id);
            tabrow = JsonArrayInsert(tabrow,NuiWidth(button,small ? 100.0 : 150.0));
        }
        tabrow = JsonArrayInsert(tabrow,NuiSpacer());
        right = JsonArrayInsert(right,NuiHeight(NuiRow(tabrow),28.0));
    }
    right = JsonArrayInsert(right,NuiSpacer());
    header = JsonArrayInsert(header,NuiCol(right));
    header = JsonArrayInsert(header,NuiWidth(NuiSpacer(),16.0));
    col = JsonArrayInsert(col,DQ_Material(NuiHeight(NuiRow(header),headerHeight),width-16.0,headerHeight,0));

    // Full-width three-milestone banner. Its height and all lower layout stay unchanged.
    float inset = small ? 12.0 : 20.0;
    float barWidth = width-16.0-2.0*inset;
    float chestHeight = compact ? 34.0 : 56.0;
    float chestWidth = compact ? 50.0 : 76.0;
    float trackWidth = barWidth-chestWidth;
    float lane = trackWidth/3.0;
    json bannerCol = JsonArray();
    json summary = JsonArray();
    summary = JsonArrayInsert(summary,NuiWidth(DQ_Label(NuiBind("dq_overall_text")),small ? 225.0 : 280.0));
    summary = JsonArrayInsert(summary,NuiSpacer());
    summary = JsonArrayInsert(summary,NuiWidth(NuiStyleForegroundColor(NuiLabel(NuiBind("dq_reset"),JsonInt(NUI_HALIGN_RIGHT),JsonInt(NUI_VALIGN_MIDDLE)),NuiColor(231,210,157)),small ? 205.0 : 235.0));
    bannerCol = JsonArrayInsert(bannerCol,NuiHeight(NuiRow(summary),18.0));
    json chests = JsonArray();
    chests = JsonArrayInsert(chests,NuiWidth(NuiSpacer(),lane));
    for (i = 0; i < 3; i++)
    {
        string suffix = IntToString(i);
        // Keep the image enabled so Locked art remains legible. Click handler
        // checks readiness and the transactional backend independently verifies it.
        json chest = NuiId(DQ_BonusChest(i,width-16.0,bannerHeight,inset,lane,compact),"milestone_"+suffix);
        chest = NuiDisabledTooltip(NuiTooltip(chest,NuiBind("dq_chest_text_"+suffix)),NuiBind("dq_chest_text_"+suffix));
        if (compact) chests = JsonArrayInsert(chests,NuiWidth(NuiHeight(chest,chestHeight),chestWidth));
        else
        {
            json captioned = JsonArray();
            captioned = JsonArrayInsert(captioned,NuiHeight(chest,44.0));
            captioned = JsonArrayInsert(captioned,NuiHeight(NuiStyleForegroundColor(NuiLabel(NuiBind("dq_chest_label_"+suffix),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE)),NuiColor(231,210,157)),12.0));
            chests = JsonArrayInsert(chests,NuiWidth(NuiCol(captioned),chestWidth));
        }
        if (i < 2) chests = JsonArrayInsert(chests,NuiWidth(NuiSpacer(),lane-chestWidth));
    }
    bannerCol = JsonArrayInsert(bannerCol,NuiHeight(NuiRow(chests),chestHeight));
    json progressBar = NuiStyleForegroundColor(NuiProgress(NuiBind("dq_overall")),NuiColor(104,68,155));
    json marks = JsonArray();
    for (i = 0; i < 3; i++)
    {
        float x = lane*IntToFloat(i+1);
        if (i < 2) marks = JsonArrayInsert(marks,NuiDrawListRect(JsonBool(TRUE),NuiColor(234,198,113),JsonBool(TRUE),JsonFloat(0.0),NuiRect(x,0.0,2.0,compact ? 16.0 : 20.0)));
        marks = JsonArrayInsert(marks,NuiDrawListText(JsonBool(TRUE),NuiColor(255,237,184),NuiRect(x-(i == 2 ? 32.0 : 15.0),0.0,32.0,compact ? 16.0 : 18.0),JsonString(IntToString((i+1)*5)),NUI_DRAW_LIST_ITEM_ORDER_AFTER));
    }
    json track = JsonArray();
    track = JsonArrayInsert(track,NuiWidth(NuiSpacer(),chestWidth/2.0));
    track = JsonArrayInsert(track,NuiWidth(NuiDrawList(progressBar,JsonBool(FALSE),marks),trackWidth));
    track = JsonArrayInsert(track,NuiWidth(NuiSpacer(),chestWidth/2.0));
    bannerCol = JsonArrayInsert(bannerCol,NuiHeight(NuiRow(track),compact ? 16.0 : 20.0));
    // Dedicated used-attempts badge: visible at all sizes, independent of feedback.
    float badgeWidth = compact ? 250.0 : 280.0;
    float badgeHeight = compact ? 16.0 : 26.0;
    json badgePaint = JsonArray();
    badgePaint = JsonArrayInsert(badgePaint,NuiDrawListRect(JsonBool(TRUE),NuiColor(10,10,12,235),JsonBool(TRUE),JsonFloat(0.0),NuiRect(0.0,0.0,badgeWidth,badgeHeight)));
    badgePaint = JsonArrayInsert(badgePaint,NuiDrawListRect(JsonBool(TRUE),NuiColor(190,149,72),JsonBool(FALSE),JsonFloat(1.0),NuiRect(0.0,0.0,badgeWidth,badgeHeight)));
    badgePaint = JsonArrayInsert(badgePaint,NuiDrawListText(JsonBool(TRUE),NuiColor(255,237,184),NuiRect(8.0,compact ? 0.0 : 5.0,badgeWidth-70.0,compact ? 16.0 : 18.0),NuiBind("dq_rerolls"),NUI_DRAW_LIST_ITEM_ORDER_AFTER));
    for (i = 0; i < 3; i++)
    {
        json pip = NuiRect(badgeWidth-57.0+IntToFloat(i)*18.0,compact ? 3.0 : 8.0,12.0,10.0);
        badgePaint = JsonArrayInsert(badgePaint,NuiDrawListRect(NuiBind("dq_reroll_used_"+IntToString(i)),NuiColor(232,187,87),JsonBool(TRUE),JsonFloat(0.0),pip));
        badgePaint = JsonArrayInsert(badgePaint,NuiDrawListRect(JsonBool(TRUE),NuiColor(190,149,72),JsonBool(FALSE),JsonFloat(1.0),pip));
    }
    json badge = NuiTooltip(NuiDrawList(NuiLabel(JsonString(""),JsonInt(NUI_HALIGN_LEFT),JsonInt(NUI_VALIGN_MIDDLE)),JsonBool(FALSE),badgePaint),NuiBind("dq_reroll_hint"));
    json hintRow = JsonArray();
    hintRow = JsonArrayInsert(hintRow,NuiTooltip(DQ_Label(NuiBind("dq_banner_hint")),NuiBind("dq_banner_hint")));
    hintRow = JsonArrayInsert(hintRow,NuiWidth(badge,badgeWidth));
    bannerCol = JsonArrayInsert(bannerCol,NuiHeight(NuiRow(hintRow),badgeHeight));
    json banner = JsonArray();
    banner = JsonArrayInsert(banner,NuiWidth(NuiSpacer(),inset));
    banner = JsonArrayInsert(banner,NuiWidth(NuiCol(bannerCol),barWidth));
    banner = JsonArrayInsert(banner,NuiWidth(NuiSpacer(),inset));
    json bannerPaint = JsonArray();
    json panorama = NuiDrawListImage(JsonBool(TRUE),JsonString("dq_skin"),NuiRect(0.0,0.0,width-16.0,bannerHeight),JsonInt(NUI_ASPECT_STRETCH),JsonInt(NUI_HALIGN_CENTER),JsonInt(NUI_VALIGN_MIDDLE),NUI_DRAW_LIST_ITEM_ORDER_BEFORE);
    bannerPaint = JsonArrayInsert(bannerPaint,NuiDrawListImageRegion(panorama,NuiRect(0.0,16.0,1774.0,226.0)));
    bannerPaint = JsonArrayInsert(bannerPaint,NuiDrawListRect(JsonBool(TRUE),NuiColor(6,8,12,90),JsonBool(TRUE),JsonFloat(0.0),NuiRect(0.0,bannerHeight-48.0,width-16.0,48.0),NUI_DRAW_LIST_ITEM_ORDER_BEFORE));
    bannerPaint = JsonArrayInsert(bannerPaint,NuiDrawListRect(JsonBool(TRUE),NuiColor(132,100,49),JsonBool(FALSE),JsonFloat(1.0),NuiRect(0.0,0.0,width-16.0,bannerHeight)));
    col = JsonArrayInsert(col,NuiDrawList(NuiHeight(NuiRow(banner),bannerHeight),JsonBool(FALSE),bannerPaint));

    json labels = JsonArray();
    labels = JsonArrayInsert(labels,NuiWidth(NuiSpacer(),28.0));
    labels = JsonArrayInsert(labels,DQ_Label(JsonString("Objective")));
    labels = JsonArrayInsert(labels,NuiWidth(DQ_Label(JsonString("Progress")),progressWidth));
    labels = JsonArrayInsert(labels,NuiWidth(DQ_Label(JsonString("Rewards")),rewardWidth));
    labels = JsonArrayInsert(labels,NuiWidth(NuiSpacer(),claimWidth+26.0));
    col = JsonArrayInsert(col,NuiHeight(NuiPadding(NuiRow(labels),2.0),labelsHeight));
    json rows = JsonArray();
    json items = DQ_Items(catalog,tab);
    for (i = 0; i < JsonGetLength(items); i++)
        rows = JsonArrayInsert(rows,DQ_QuestRow(i,width,rowHeight,JsonArrayGet(items,i)));
    rows = JsonArrayInsert(rows,NuiSpacer());
    // Group scrolling supports ordinary nested rows, unlike NuiList templates.
    col = JsonArrayInsert(col,NuiHeight(NuiId(NuiGroup(NuiCol(rows),FALSE,NUI_SCROLLBARS_Y),"quests"),listHeight));
    json footer = JsonArray();
    footer = JsonArrayInsert(footer,NuiHeight(NuiSpacer(),6.0));
    json description = NuiId(NuiWidth(NuiHeight(NuiGroup(DQ_Description("Character-specific interface preview.",width-64.0),
        FALSE,NUI_SCROLLBARS_NONE),52.0),width-64.0),"dq_description");
    json descriptionRow = JsonArray();
    descriptionRow = JsonArrayInsert(descriptionRow,NuiSpacer());
    descriptionRow = JsonArrayInsert(descriptionRow,description);
    descriptionRow = JsonArrayInsert(descriptionRow,NuiSpacer());
    footer = JsonArrayInsert(footer,NuiHeight(NuiRow(descriptionRow),52.0));
    footer = JsonArrayInsert(footer,NuiHeight(NuiSpacer(),14.0));
    col = JsonArrayInsert(col,DQ_Material(NuiHeight(NuiCol(footer),footerHeight),width-16.0,footerHeight,2));
    return DQ_LayoutSpacing(NuiPadding(NuiCol(col),8.0));
}

json DQ_Layout(json catalog, float width, float height = 732.0, string tab = "")
{
    if (tab == "") tab = JsonGetString(JsonObjectGet(JsonArrayGet(JsonObjectGet(catalog,"tabs"),0),"id"));
    json root = NuiGroup(DQ_Content(catalog,width,height,tab),FALSE,NUI_SCROLLBARS_NONE);
    json paint = JsonArray();
    paint = JsonArrayInsert(paint,NuiDrawListRect(JsonBool(TRUE),NuiColor(142,103,45),JsonBool(FALSE),JsonFloat(1.0),
        NuiRect(1.0,1.0,width-8.0,height-8.0)));
    paint = JsonArrayInsert(paint,NuiDrawListRect(JsonBool(TRUE),NuiColor(68,54,29),JsonBool(FALSE),JsonFloat(1.0),
        NuiRect(4.0,4.0,width-14.0,height-14.0)));
    // A clean edge from the same framed panel as the header. Unlike the old
    // footer crop it contains no central diamond/tail ornaments.
    paint = JsonArrayInsert(paint,DQ_SkinPaint(NuiRect(1.0,height-18.0,width-8.0,14.0),
        NuiRect(0.0,450.0,1774.0,16.0),NUI_DRAW_LIST_ITEM_ORDER_AFTER));
    return NuiId(NuiDrawList(NuiMargin(NuiPadding(root,0.0),0.0),JsonBool(FALSE),paint),"dq_body");
}

void DQ_Animate(object pc, int token, int serial, int frame)
{
    if (!GetIsObjectValid(pc) || !GetIsPC(pc)) return;
    if (NuiFindWindow(pc,DQ_WINDOW) != token || GetLocalInt(pc,"DQ_ANIM_SERIAL") != serial) return;
    if (!GetLocalInt(pc,"DQ_UI_PREVIEW") && !GetLocalInt(pc,"DQ_UI_UNAVAILABLE"))
    {
        int now = DQC_Now();
        if (now > 0 && now >= GetLocalInt(pc,"DQ_CLOCK_CHECK_AFTER"))
        {
            SetLocalInt(pc,"DQ_CLOCK_CHECK_AFTER",now+1);
            if (DQC_Cycle(now) != DQC_Int(GetLocalJson(pc,"DQ_LIVE_STATE"),"cycle")) ExecuteScript("dq_sync",pc);
        }
    }
    if (!JsonGetInt(NuiGetBind(pc,token,"dq_any_ready")))
    {
        DelayCommand(0.75,DQ_Animate(pc,token,serial,0));
        return;
    }
    NuiSetBind(pc,token,"dq_chest_motion",DQ_WobbleRect(frame,0));
    NuiSetBind(pc,token,"dq_chest_motion_small",DQ_WobbleRect(frame,1));
    NuiSetBind(pc,token,"dq_chest_motion_milestone",DQ_WobbleRect(frame,2));
    NuiSetBind(pc,token,"dq_chest_motion_compact",DQ_WobbleRect(frame,3));
    NuiSetBind(pc,token,"dq_chest_motion_captioned",DQ_WobbleRect(frame,4));
    NuiSetBind(pc,token,"dq_rowchest_motion",DQ_RowChestRect(frame,0));
    NuiSetBind(pc,token,"dq_rowchest_motion_small",DQ_RowChestRect(frame,1));
    int tier;
    for (tier = 0; tier < 3; tier++)
    {
        NuiSetBind(pc,token,"dq_tier_motion_"+IntToString(tier)+"_compact",DQ_TierChestRect(frame,tier,TRUE));
        NuiSetBind(pc,token,"dq_tier_motion_"+IntToString(tier)+"_captioned",DQ_TierChestRect(frame,tier,FALSE));
    }
    int next = (frame+1)%8;
    DelayCommand(next == 0 ? 2.2 : 0.10,DQ_Animate(pc,token,serial,next));
}

void DQ_StartAnimation(object pc, int token)
{
    int serial = GetLocalInt(pc,"DQ_ANIM_SERIAL")+1;
    SetLocalInt(pc,"DQ_ANIM_SERIAL",serial);
    DQ_Animate(pc,token,serial,0);
}

void DQ_SelectTab(object pc, int token, string tab, int rebuild = TRUE)
{
    json catalog = DQ_CatalogFor(pc);
    if (!DQ_HasTab(catalog,tab)) return;
    json size = NuiGetUserData(pc,token);
    float width = JsonGetFloat(JsonObjectGet(size,"width"));
    float height = JsonGetFloat(JsonObjectGet(size,"height"));
    if (width < 400.0 || height < 300.0) return;
    if (rebuild) NuiSetGroupLayout(pc,token,"dq_body",DQ_Content(catalog,width,height,tab));
    SetLocalString(pc,"DQ_PREVIEW_TAB",tab);
    DQ_Refresh(pc,token,tab);
    json tabs = JsonObjectGet(catalog,"tabs");
    int i;
    for (i = 0; i < JsonGetLength(tabs); i++)
    {
        json t = JsonArrayGet(tabs,i);
        string id = JsonGetString(JsonObjectGet(t,"id"));
        NuiSetBind(pc,token,"dq_tab_"+id,JsonBool(id == tab));
        if (id == tab) NuiSetBind(pc,token,"dq_reset",JsonObjectGet(t,"reset_label"));
    }
}

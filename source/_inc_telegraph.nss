#include "x3_inc_string"
#include "_inc_spells"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// constants

const int TARGET_FPS = 30;

const int TELEGRAPH_SHAPE_NONE = 0;
const int TELEGRAPH_SHAPE_SPHERE = 1;
const int TELEGRAPH_SHAPE_SPELLCONE = 2;
const int TELEGRAPH_SHAPE_SPELLCYLINDER = 3;
const int TELEGRAPH_SHAPE_CUBE = 4;


const string _TELEGRAPH_SHAPE = ".shape";
const string _TELEGRAPH_X = ".x";
const string _TELEGRAPH_Y = ".y";
const string _TELEGRAPH_Z = ".z";
const string _TELEGRAPH_ROTATION = ".rotation";
const string _TELEGRAPH_SIZEX = ".sizeX";
const string _TELEGRAPH_SIZEY = ".sizeY";
const string _TELEGRAPH_DURATION = ".duration";
const string _TELEGRAPH_CREATOR_UUID = ".creator_uuid";
const string _TELEGRAPH_AREA_UUID = ".area_uuid";
const string _TELEGRAPH_ONSTART = ".onStart";
const string _TELEGRAPH_ONUPDATE = ".onUpdate";
const string _TELEGRAPH_ONFINISH = ".onFinish";

// Creates a telegraph, obviously. onFinish won't be called if you don't set updateInterval.
// Note: I recommend adding a small negative bias (0.1 or so) to the duration you pass in here compared to the one you pass when
//       you apply the effect to an object, e.g. TelegraphCreate(..., duration - 0.1f) then ApplyEffectToObject(..., duration)).
//       This gives a brief overlap between the telegraph visually filing to max and actually ending, which feels good as a player!
// Note: TELEGRAPH_SHAPE_CUBE ignores rotation (matching the GetFirstObjectInShape(...) functions)
effect TelegraphCreate(int shape, float x, float y, float z, float rotation, float sizeX, float sizeY, float duration, string sCreatorUUID, string sAreaUUID, string onStart, string onUpdate, string onFinish, float updateInterval = 0.0);

// Returns the telegraph ID used to access all properties.
string TelegraphGetId(effect telegraph);

// Getters for each property; use with the ID from TelegraphGetId().
int TelegraphGetShape(string telegraphId);
float TelegraphGetX(string telegraphId);
float TelegraphGetY(string telegraphId);
float TelegraphGetZ(string telegraphId);
float TelegraphGetRotation(string telegraphId);
float TelegraphGetSizeX(string telegraphId);
float TelegraphGetSizeY(string telegraphId);
float TelegraphGetDuration(string telegraphId);
string TelegrafGetCreatorUUID(string telegraphId);
string TelegrafGetAreaUUID(string telegraphId);
string TelegraphGetOnStart(string telegraphId);
string TelegraphGetOnUpdate(string telegraphId);
string TelegraphGetOnFinish(string telegraphId);


//
void _TelegraphFree(string telegraphId);

//
string _TelegraphKey(string telegraphId, string field);

//
string telegraph_OnApply(object area, string telegraphId);

//
string telegraph_OnUpdate(object area, string telegraphId);

//
string telegraph_OnRemove(object area, string telegraphId);

//
void telegraph_UpdateShaderForAllPcs(object oArea);

//
void telegraph_UpdateShaderForPc(object oPC, object oArea);


///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////


effect TelegraphCreate(int shape,
    float x,
    float y,
    float z,
    float rotation,
    float sizeX,
    float sizeY,
    float duration,
    string sCreatorUUID,
    string sAreaUUID,
    string onStart,
    string onUpdate,
    string onFinish,
    float updateInterval = 0.0)
{
    object module = GetModule();

    effect eTelegraph = UnyieldingEffect(EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", updateInterval));
    eTelegraph = SetEffectSpellId(eTelegraph, SPELL_CORMYR_TELEGRAPH);
    string telegraphId = TelegraphGetId(eTelegraph);

    SetLocalInt(module, _TelegraphKey(telegraphId, _TELEGRAPH_SHAPE), shape);
    SetLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_X), x);
    SetLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_Y), y);
    SetLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_Z), z);
    SetLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_ROTATION), rotation);
    SetLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_SIZEX), sizeX);
    SetLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_SIZEY), sizeY);
    SetLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_DURATION), duration);
    SetLocalString(module, _TelegraphKey(telegraphId, _TELEGRAPH_CREATOR_UUID), sCreatorUUID);
    SetLocalString(module, _TelegraphKey(telegraphId, _TELEGRAPH_AREA_UUID), sAreaUUID);
    SetLocalString(module, _TelegraphKey(telegraphId, _TELEGRAPH_ONSTART), onStart);
    SetLocalString(module, _TelegraphKey(telegraphId, _TELEGRAPH_ONUPDATE), onUpdate);
    SetLocalString(module, _TelegraphKey(telegraphId, _TELEGRAPH_ONFINISH), onFinish);

    return eTelegraph;
}

string TelegraphGetId(effect telegraph)
{
    return GetEffectLinkId(telegraph);
}

int TelegraphGetShape(string telegraphId) { return GetLocalInt(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_SHAPE)); }
float TelegraphGetX(string telegraphId) { return GetLocalFloat(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_X)); }
float TelegraphGetY(string telegraphId) { return GetLocalFloat(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_Y)); }
float TelegraphGetZ(string telegraphId) { return GetLocalFloat(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_Z)); }
float TelegraphGetRotation(string telegraphId) { return GetLocalFloat(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_ROTATION)); }
float TelegraphGetSizeX(string telegraphId) { return GetLocalFloat(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_SIZEX)); }
float TelegraphGetSizeY(string telegraphId) { return GetLocalFloat(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_SIZEY)); }
float TelegraphGetDuration(string telegraphId) { return GetLocalFloat(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_DURATION)); }
string TelegrafGetCreatorUUID(string telegraphId) { return GetLocalString(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_CREATOR_UUID)); }
string TelegrafGetAreaUUID(string telegraphId) { return GetLocalString(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_AREA_UUID)); }
string TelegraphGetOnStart(string telegraphId) { return GetLocalString(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_ONSTART)); }
string TelegraphGetOnUpdate(string telegraphId) { return GetLocalString(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_ONUPDATE)); }
string TelegraphGetOnFinish(string telegraphId) { return GetLocalString(GetModule(), _TelegraphKey(telegraphId, _TELEGRAPH_ONFINISH)); }

void _TelegraphFree(string telegraphId)
{
    object module = GetModule();

    DeleteLocalInt(module, _TelegraphKey(telegraphId, _TELEGRAPH_SHAPE));
    DeleteLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_X));
    DeleteLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_Y));
    DeleteLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_Z));
    DeleteLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_ROTATION));
    DeleteLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_SIZEX));
    DeleteLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_SIZEY));
    DeleteLocalFloat(module, _TelegraphKey(telegraphId, _TELEGRAPH_DURATION));
    DeleteLocalString(module, _TelegraphKey(telegraphId, _TELEGRAPH_CREATOR_UUID));
    DeleteLocalString(module, _TelegraphKey(telegraphId, _TELEGRAPH_AREA_UUID));
    DeleteLocalString(module, _TelegraphKey(telegraphId, _TELEGRAPH_ONSTART));
    DeleteLocalString(module, _TelegraphKey(telegraphId, _TELEGRAPH_ONUPDATE));
    DeleteLocalString(module, _TelegraphKey(telegraphId, _TELEGRAPH_ONFINISH));
}

string _TelegraphKey(string telegraphId, string field) { return telegraphId + field; }


string telegraph_OnApply(object area, string telegraphId)
{
    int start = GetMicrosecondCounter();
    int end = start + FloatToInt(TelegraphGetDuration(telegraphId) * 1000 * 1000);

    json telegraphIds = GetLocalJson(area, "TELEGRAPHS");
    telegraphIds = JsonGetType(telegraphIds) == JSON_TYPE_NULL ? JsonArray() : telegraphIds;
    telegraphIds = JsonArrayInsert(telegraphIds, JsonString(telegraphId));

    SetLocalInt(area, _TelegraphKey(telegraphId, ".start"), start);
    SetLocalInt(area, _TelegraphKey(telegraphId, ".end"), end);
    SetLocalJson(area, "TELEGRAPHS", telegraphIds);

    return TelegraphGetOnStart(telegraphId);
}

string telegraph_OnUpdate(object area, string telegraphId)
{
    return TelegraphGetOnUpdate(telegraphId);
}

string telegraph_OnRemove(object area, string telegraphId)
{
    json telegraphIds = GetLocalJson(area, "TELEGRAPHS");
    telegraphIds = JsonArrayDel(telegraphIds, JsonGetInt(JsonFind(telegraphIds, JsonString(telegraphId))));

    DeleteLocalInt(area, _TelegraphKey(telegraphId, ".start"));
    DeleteLocalInt(area, _TelegraphKey(telegraphId, ".end"));
    SetLocalJson(area, "TELEGRAPHS", telegraphIds);

    return TelegraphGetOnFinish(telegraphId);
}

void telegraph_UpdateShaderForAllPcs(object oArea)
{
    //object oPC = GetFirstObjectInArea(oArea, OBJECT_TYPE_CREATURE);
    object oPC = GetFirstPC();
    while(GetIsObjectValid(oPC))
    {
        object oPlayerArea = GetArea(oPC);
        if(GetIsObjectValid(oPlayerArea) && oPlayerArea == oArea)
            telegraph_UpdateShaderForPc(oPC, oArea);
        oPC = GetNextPC();
    }
}

void telegraph_UpdateShaderForPc(object oPC, object oArea)
{
    json telegraphs = GetLocalJson(oArea, "TELEGRAPHS");
    int telegraphCount = JsonGetLength(telegraphs);
    int telegraphCountToRender = telegraphCount > 8 ? 8 : telegraphCount;
    int telegraphCountToReset = 8 - telegraphCountToRender;

    int i;
    for (i = 0; i < telegraphCountToRender; ++i)
    {
        string telegraphId = JsonGetString(JsonArrayGet(telegraphs, i));

        int shape = TelegraphGetShape(telegraphId);
        float x = TelegraphGetX(telegraphId);
        float y = TelegraphGetY(telegraphId);
        float z = TelegraphGetZ(telegraphId);
        float rotation = TelegraphGetRotation(telegraphId);
        float sizeX = TelegraphGetSizeX(telegraphId);
        float sizeY = TelegraphGetSizeY(telegraphId);

        int start = GetLocalInt(oArea, _TelegraphKey(telegraphId, ".start"));
        int end = GetLocalInt(oArea, _TelegraphKey(telegraphId, ".end"));

        int uniformIdx = SHADER_UNIFORM_1 + i;
        SetShaderUniformInt(oPC, SHADER_UNIFORM_1 + i, shape);
        SetShaderUniformVec(oPC, SHADER_UNIFORM_1 + i * 2 + 0, x, y, z, rotation);
        SetShaderUniformVec(oPC, SHADER_UNIFORM_1 + i * 2 + 1, IntToFloat(start), IntToFloat(end), sizeX, sizeY);
    }

    for (i = 0; i < telegraphCountToReset; ++i)
    {
        int uniformIdx = SHADER_UNIFORM_1 + telegraphCountToRender + i;
        SetShaderUniformInt(oPC, uniformIdx, TELEGRAPH_SHAPE_NONE);
    }
}

// TEST CANDIDATE: Path of Grace / Line Heal. Isolated stand only.
// Actual saved rules: length8m, total healing width1.0m; CL+100+[0,20,30,50].
// Living non-enemies except caster; neutrals remain eligible as in the original.
const float LINE_RANGE = 8.0;
const float LINE_HALF_WIDTH = 0.50; // Visual-edge test: Godish at side0.40 must be included.
const float VISUAL_SIDE_OFFSET = 0.25; // Keep VFX spacing independent of healing width.
const float WAVE_STEP = 0.75;
const float WAVE_DELAY = 0.04;

int LineHeal_Amount(object caster)
{
    int bonus = 0;
    if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT, caster)) bonus = 50;
    else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT, caster)) bonus = 30;
    else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT, caster)) bonus = 20;
    return GetCasterLevel(caster) + 100 + bonus;
}

// One projection check uses the immutable cast origin for both line and segment.
int LineHeal_InSegment(vector point, vector origin, vector direction, float from, float to)
{
    float dx = point.x - origin.x;
    float dy = point.y - origin.y;
    float forward = dx * direction.x + dy * direction.y;
    float side = -dx * direction.y + dy * direction.x;
    if(side < 0.0) side = -side;
    return forward >= 0.5 && forward >= from && forward < to && side <= LINE_HALF_WIDTH;
}

// Same three VFX per step, same offsets and scales as the saved source.
void LineHeal_Visual(object area, vector origin, vector direction, float distance)
{
    int i;
    for(i = 0; i < 3; i++)
    {
        int side = i;
        if(i == 2) side = -1;
        float offset = IntToFloat(side) * VISUAL_SIDE_OFFSET;
        vector point = Vector(origin.x + direction.x * distance - direction.y * offset,
                              origin.y + direction.y * distance + direction.x * offset, origin.z);
        float scale = 0.45;
        if(side == 0) scale = 0.70;
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT,
            EffectVisualEffect(VFX_IMP_HEALING_G, FALSE, scale), Location(area, point, 0.0));
    }
}

void LineHeal_Step(object caster, object area, vector origin, vector direction,
                   float from, float to, string waveKey, int last)
{
    if(!GetIsObjectValid(caster)) return;
    if(!GetIsObjectValid(area) || GetArea(caster) != area)
    {
        DeleteLocalJson(caster, waveKey);
        return;
    }
    json healed = GetLocalJson(caster, waveKey);
    if(JsonGetType(healed) != JSON_TYPE_OBJECT) return;
    LineHeal_Visual(area, origin, direction, to);

    // Keep the original area scan and target policy. LOS/spatial-query changes
    // require a separate gameplay decision, rather than being hidden in cleanup.
    object target = GetFirstObjectInArea(area);
    while(GetIsObjectValid(target))
    {
        if(GetObjectType(target) == OBJECT_TYPE_CREATURE && target != caster
            && GetCurrentHitPoints(target) > 0 && !GetIsEnemy(target, caster)
            && LineHeal_InSegment(GetPosition(target), origin, direction, from, to))
        {
            string id = GetObjectUUID(target);
            if(JsonGetType(JsonObjectGet(healed, id)) == JSON_TYPE_NULL)
            {
                // Per-wave state belongs to this caster, not to a shared target
                // marker. Different casters and overlapping waves cannot collide.
                healed = JsonObjectSet(healed, id, JsonBool(TRUE));
                SetLocalJson(caster, waveKey, healed);
                ApplyEffectToObject(DURATION_TYPE_INSTANT,
                    EffectVisualEffect(VFX_IMP_HEALING_G, FALSE, 1.25), target);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(LineHeal_Amount(caster)), target);
            }
        }
        target = GetNextObjectInArea(area);
    }
    if(last) DeleteLocalJson(caster, waveKey);
}

void main()
{
    object caster = OBJECT_SELF;
    if(!GetIsObjectValid(caster)) return;
    object area = GetArea(caster);
    if(!GetIsObjectValid(area)) return;
    vector origin = GetPosition(caster);
    vector point = GetPositionFromLocation(GetSpellTargetLocation());
    vector direction = Vector(point.x - origin.x, point.y - origin.y, 0.0);
    if(VectorMagnitude(direction) < 0.10) return;
    direction = VectorNormalize(direction);

    // Temporary stand measurement: capture the real cast, not current facing.
    SetLocalObject(GetModule(), "LH_WIDTH_CASTER", caster);
    SetLocalLocation(GetModule(), "LH_WIDTH_CAST", Location(area, origin, VectorToAngle(direction)));

    int serial = GetLocalInt(caster, "LINE_HEAL_COUNTER") + 1;
    SetLocalInt(caster, "LINE_HEAL_COUNTER", serial);
    string waveKey = "LINE_HEAL_HITS_" + IntToString(serial);
    SetLocalJson(caster, waveKey, JsonObject());

    int steps = FloatToInt(LINE_RANGE / WAVE_STEP);
    if(IntToFloat(steps) * WAVE_STEP < LINE_RANGE) steps++;
    int i;
    for(i = 0; i < steps; i++)
    {
        float from = IntToFloat(i) * WAVE_STEP;
        float to = from + WAVE_STEP;
        if(to > LINE_RANGE) to = LINE_RANGE;
        if(i == 0) LineHeal_Step(caster, area, origin, direction, from, to, waveKey, i == steps - 1);
        else DelayCommand(IntToFloat(i) * WAVE_DELAY,
            LineHeal_Step(caster, area, origin, direction, from, to, waveKey, i == steps - 1));
    }
}

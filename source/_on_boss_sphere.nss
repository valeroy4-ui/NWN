#include "_inc_telegraph"

void main()
{
    string telegraphId = GetEffectLinkId(GetLastRunScriptEffect());
    int telegraphShape = TelegraphGetShape(telegraphId);
    float telegraphX = TelegraphGetX(telegraphId);
    float telegraphY = TelegraphGetY(telegraphId);
    float telegraphZ = TelegraphGetZ(telegraphId);
    float telegraphRotation = TelegraphGetRotation(telegraphId);
    float telegraphSize = TelegraphGetSizeX(telegraphId);
    string sCreatorUUID = TelegrafGetCreatorUUID(telegraphId);
    object oCreator = GetObjectByUUID(sCreatorUUID);
    int nCreatorLevel = GetHitDice(oCreator);

    int shape = telegraphShape == TELEGRAPH_SHAPE_SPHERE ? SHAPE_SPHERE : SHAPE_CUBE;

    location loc = Location(GetArea(OBJECT_SELF), Vector(telegraphX, telegraphY, telegraphZ), telegraphRotation);
    //ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_FIREBALL, FALSE, telegraphSize / 5.0f), loc);
    //ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(852, FALSE, unpacked.sizeX / 5.0f), loc);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(884, FALSE, telegraphSize / 5.0f), loc);

    int nDamageType = FloatToInt(pow(2.0, IntToFloat(Random(12)))); // random damage

    object overlapped = GetFirstObjectInShape(shape, telegraphSize, loc);
    while (GetIsObjectValid(overlapped))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_HIT_FIRE), overlapped);
        if(oCreator != overlapped)
            AssignCommand(oCreator, DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nCreatorLevel * d3(2), nDamageType), overlapped)));
        overlapped = GetNextObjectInShape(shape, telegraphSize, loc);
    }
}

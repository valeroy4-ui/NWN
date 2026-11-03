void main()
{
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectCutsceneParalyze()), OBJECT_SELF);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectRegenerate(10, 6.0)), OBJECT_SELF);
}

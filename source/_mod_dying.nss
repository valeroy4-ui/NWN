void main()
{
    object oPlayerDying = GetLastPlayerDying();
    int iHPs = GetCurrentHitPoints(oPlayerDying);
    effect eHPLoss = EffectHitPointChangeWhenDying(-1.0);
    effect eDeathVis = EffectVisualEffect(VFX_IMP_DEATH);
    effect eDeath = EffectDeath(FALSE, FALSE);

    if (GetIsPossessedFamiliar(oPlayerDying))
        DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(10000), oPlayerDying));
    else if(iHPs >= -9)
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHPLoss, oPlayerDying, 10.0);
    else
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeathVis, oPlayerDying);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oPlayerDying);
    }
}

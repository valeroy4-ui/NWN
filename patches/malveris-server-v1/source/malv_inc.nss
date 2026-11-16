// Encounter mechanics only. Ordinary attacks, spells and pursuit belong to Cormyr.
#include "malv_config"

void MV_Control(object oBoss, int nEpoch);
void MV_Step(object oBoss, int nEpoch, int nCast, int nPhase, int nTick);

int MV_IsBoss(object oBoss)
{
    return GetIsObjectValid(oBoss) && GetObjectType(oBoss) == OBJECT_TYPE_CREATURE &&
        GetStringLowerCase(GetTag(oBoss)) == "malveris" && !GetIsPC(oBoss);
}

int MV_IsTarget(object oBoss, object oPC, float fRadius = 0.0)
{
    if (!MV_IsBoss(oBoss) || GetIsDead(oBoss) || GetCurrentHitPoints(oBoss) <= 0 ||
        !GetIsObjectValid(oPC) || !GetIsPC(oPC) || GetIsDM(oPC) || GetIsDMPossessed(oPC) ||
        GetIsDead(oPC) || GetCurrentHitPoints(oPC) <= 0 ||
        GetArea(oPC) != GetArea(oBoss) || !GetIsEnemy(oPC,oBoss)) return FALSE;
    return fRadius <= 0.0 || GetDistanceBetween(oBoss,oPC) <= fRadius;
}

int MV_HasTarget(object oBoss)
{
    object oPC = GetFirstObjectInArea(GetArea(oBoss),OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(oPC))
    {
        if (MV_IsTarget(oBoss,oPC,MV_ENCOUNTER_RADIUS)) return TRUE;
        oPC = GetNextObjectInArea(GetArea(oBoss),OBJECT_TYPE_CREATURE);
    }
    return FALSE;
}

string MV_Tag(object oBoss, string sSuffix)
{
    return "MV_"+GetObjectUUID(oBoss)+"_"+sSuffix;
}

void MV_Remove(object oBoss, object oTarget, string sSuffix)
{
    if (!GetIsObjectValid(oTarget)) return;
    string sTag = MV_Tag(oBoss,sSuffix);
    effect e = GetFirstEffect(oTarget);
    while (GetIsEffectValid(e))
    {
        // Restart after removal: effect iteration is invalidated by mutation.
        if (GetEffectTag(e) == sTag)
        {
            RemoveEffect(oTarget,e);
            e = GetFirstEffect(oTarget);
        }
        else e = GetNextEffect(oTarget);
    }
}

void MV_Touch(object oBoss, object oPC)
{
    if (!GetIsObjectValid(oPC) || !GetIsPC(oPC)) return;
    int nCount = GetLocalInt(oBoss,"MV_TOUCH_COUNT");
    int i;
    for (i=0;i<nCount;i++)
        if (GetLocalObject(oBoss,"MV_TOUCH_"+IntToString(i)) == oPC) return;
    SetLocalObject(oBoss,"MV_TOUCH_"+IntToString(nCount),oPC);
    SetLocalInt(oBoss,"MV_TOUCH_COUNT",nCount+1);
}

void MV_Visual(object oBoss, object oTarget, int nVfx, string sTag = "", float fTime = 0.0)
{
    if (!GetIsObjectValid(oTarget)) return;
    effect e = EffectVisualEffect(nVfx);
    if (sTag != "") e = TagEffect(e,MV_Tag(oBoss,sTag));
    if (fTime > 0.0) ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e,oTarget,fTime);
    else ApplyEffectToObject(DURATION_TYPE_INSTANT,e,oTarget);
}

void MV_DestroyPoints(object oBoss, string sPrefix, int nCount)
{
    int i;
    for (i=1;i<=nCount;i++)
    {
        string sKey = sPrefix+IntToString(i);
        object oPoint = GetLocalObject(oBoss,sKey);
        if (GetIsObjectValid(oPoint)) DestroyObject(oPoint);
        DeleteLocalObject(oBoss,sKey);
    }
}

void MV_RemoveLinks(object oBoss)
{
    int nCount = GetLocalInt(oBoss,"MV_TOUCH_COUNT");
    int i;
    for (i=0;i<nCount;i++)
    {
        object oPC = GetLocalObject(oBoss,"MV_TOUCH_"+IntToString(i));
        MV_Remove(oBoss,oPC,"F"); MV_Remove(oBoss,oPC,"C");
        MV_Remove(oBoss,oPC,"H"); MV_Remove(oBoss,oPC,"SWAP");
    }
}

void MV_ClearCast(object oBoss)
{
    // Invalidate callbacks BEFORE removing any effect or helper.
    SetLocalInt(oBoss,"MV_CAST",GetLocalInt(oBoss,"MV_CAST")+1);
    SetLocalInt(oBoss,"MV_PHASE",MV_IDLE);
    MV_RemoveLinks(oBoss);
    MV_Remove(oBoss,oBoss,"HOLD");
    MV_Remove(oBoss,oBoss,"SWEEP");
    MV_Remove(oBoss,oBoss,"ABSORB");
    MV_DestroyPoints(oBoss,"MV_WS",3);
    MV_DestroyPoints(oBoss,"MV_WE",3);
    MV_DestroyPoints(oBoss,"MV_SE",3);
    int i;
    for (i=0;i<3;i++)
    {
        SetLocalInt(oBoss,"MV_COLOUR_"+IntToString(i),FALSE);
        DeleteLocalObject(oBoss,"MV_TARGET_"+IntToString(i));
    }
}

void MV_Reset(object oBoss)
{
    if (!MV_IsBoss(oBoss)) return;
    SetLocalInt(oBoss,"MV_EPOCH",GetLocalInt(oBoss,"MV_EPOCH")+1);
    DeleteLocalInt(oBoss,"MV_RUNNING");
    MV_ClearCast(oBoss);
    int nCount = GetLocalInt(oBoss,"MV_TOUCH_COUNT");
    int i;
    for (i=0;i<nCount;i++)
    {
        object oPC = GetLocalObject(oBoss,"MV_TOUCH_"+IntToString(i));
        MV_Remove(oBoss,oPC,"SLOW");
        MV_Remove(oBoss,oPC,"KD");
        DeleteLocalInt(oBoss,"MV_HIT_"+ObjectToString(oPC));
        DeleteLocalInt(oBoss,"MV_HIT_"+ObjectToString(oPC)+"_CAST");
        DeleteLocalObject(oBoss,"MV_TOUCH_"+IntToString(i));
    }
    DeleteLocalInt(oBoss,"MV_TOUCH_COUNT");
    DeleteLocalObject(oBoss,"MV_AREA");
}

int MV_Alive(object oBoss, int nEpoch)
{
    return MV_IsBoss(oBoss) && !GetIsDead(oBoss) && GetCurrentHitPoints(oBoss) > 0 &&
        GetLocalInt(oBoss,"MV_RUNNING") && GetLocalInt(oBoss,"MV_EPOCH") == nEpoch &&
        GetIsObjectValid(GetArea(oBoss)) && GetArea(oBoss) == GetLocalObject(oBoss,"MV_AREA");
}

void MV_After(object oBoss, int nEpoch, int nCast, int nPhase, int nTick, float fDelay)
{
    DelayCommand(fDelay,MV_Step(oBoss,nEpoch,nCast,nPhase,nTick));
}

int MV_Enter(object oBoss, int nPhase)
{
    int nCast = GetLocalInt(oBoss,"MV_CAST")+1;
    SetLocalInt(oBoss,"MV_CAST",nCast);
    SetLocalInt(oBoss,"MV_PHASE",nPhase);
    return nCast;
}

void MV_Recovery(object oBoss)
{
    MV_ClearCast(oBoss);
    int nCast = MV_Enter(oBoss,MV_RECOVERY);
    MV_After(oBoss,GetLocalInt(oBoss,"MV_EPOCH"),nCast,MV_RECOVERY,0,MV_RECOVERY_TIME);
}

object MV_Pick(object oBoss, object oExclude1 = OBJECT_INVALID, object oExclude2 = OBJECT_INVALID,
    object oEnemyOf = OBJECT_INVALID)
{
    object oSelected = OBJECT_INVALID;
    int nCount = 0;
    object oPC = GetFirstObjectInArea(GetArea(oBoss),OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(oPC))
    {
        if (oPC != oExclude1 && oPC != oExclude2 && MV_IsTarget(oBoss,oPC,MV_TARGET_RADIUS) &&
            (!GetIsObjectValid(oEnemyOf) || GetIsEnemy(oPC,oEnemyOf)))
        {
            nCount++;
            if (Random(nCount) == 0) oSelected = oPC;
        }
        oPC = GetNextObjectInArea(GetArea(oBoss),OBJECT_TYPE_CREATURE);
    }
    return oSelected;
}

void MV_Beam(object oBoss, object oFrom, object oTarget, int nVfx, string sTag, float fTime)
{
    effect e = TagEffect(EffectBeam(nVfx,oFrom,BODY_NODE_CHEST),MV_Tag(oBoss,sTag));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e,oTarget,fTime);
    MV_Touch(oBoss,oTarget);
}

int MV_StartTriple(object oBoss)
{
    object oA = MV_Pick(oBoss);
    if (!GetIsObjectValid(oA)) return FALSE;
    object oB = MV_Pick(oBoss,oA);
    object oC = MV_Pick(oBoss,oA,oB);
    // Uniform random permutation of the three original beam colours.
    int nFirst = Random(3);
    int nSecond = (nFirst+1+Random(2))%3;
    int nThird = 3-nFirst-nSecond;
    int i;
    for (i=0;i<3;i++)
    {
        object oPC = oA;
        int nColour = nFirst;
        if (i == 1) { oPC = oB; nColour = nSecond; }
        if (i == 2) { oPC = oC; nColour = nThird; }
        string sKey = IntToString(nColour);
        SetLocalInt(oBoss,"MV_COLOUR_"+sKey,FALSE);
        SetLocalObject(oBoss,"MV_TARGET_"+sKey,oPC);
        if (MV_IsTarget(oBoss,oPC))
        {
            string sTag = "F";
            int nVfx = 210;
            if (nColour == 1) { sTag = "C"; nVfx = 211; }
            if (nColour == 2) { sTag = "H"; nVfx = 447; }
            SetLocalInt(oBoss,"MV_COLOUR_"+sKey,TRUE);
            MV_Beam(oBoss,oBoss,oPC,nVfx,sTag,13.0);
        }
    }
    // A finite, owned restriction for this stationary cast. No AI flags change.
    effect eHold = TagEffect(EffectCutsceneImmobilize(),MV_Tag(oBoss,"HOLD"));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eHold,oBoss,MV_CAST_HOLD_MAX);
    int nCast = MV_Enter(oBoss,MV_TRIPLE);
    PrintString("[MALVERIS v1] triple started; native AI queue retained");
    MV_After(oBoss,GetLocalInt(oBoss,"MV_EPOCH"),nCast,MV_TRIPLE,1,MV_BEAM_INTERVAL);
    return TRUE;
}

int MV_InBeam(vector vStart, vector vEnd, vector vPC, float fWidth)
{
    float fDX = vEnd.x-vStart.x;
    float fDY = vEnd.y-vStart.y;
    float fLength = sqrt(fDX*fDX+fDY*fDY);
    if (fLength <= 0.01) return FALSE;
    float fX = vPC.x-vStart.x;
    float fY = vPC.y-vStart.y;
    float fAlong = (fX*fDX+fY*fDY)/fLength;
    float fSide = fabs((-fX*fDY+fY*fDX)/fLength);
    return fAlong >= 0.0 && fAlong <= fLength && fSide <= fWidth;
}

void MV_ColourEffect(object oBoss, object oPC, int nColour, int nAmount, int nBreak)
{
    if (!MV_IsTarget(oBoss,oPC)) return;
    if (nColour == 2)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(nAmount),oPC);
        MV_Visual(oBoss,oPC,VFX_IMP_HEALING_G);
    }
    else
    {
        int nType = DAMAGE_TYPE_FIRE;
        int nVfx = VFX_IMP_FLAME_M;
        if (nColour == 1) { nType = DAMAGE_TYPE_COLD; nVfx = VFX_IMP_FROST_L; }
        if (nBreak) { nVfx = 260; if (nColour == 1) nVfx = 262; }
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(nAmount,nType),oPC);
        MV_Visual(oBoss,oPC,nVfx);
    }
}

void MV_Absorb(object oBoss)
{
    int i;
    int nCount = 0;
    for (i=0;i<3;i++)
    {
        string sKey = IntToString(i);
        if (!GetLocalInt(oBoss,"MV_COLOUR_"+sKey)) continue;
        nCount++;
        int nVfx = 1223;
        int nBeam = VFX_BEAM_FIRE;
        int nField = 1515;
        if (i == 1) { nVfx = 1225; nBeam = VFX_BEAM_COLD; nField = 1810; }
        if (i == 2) { nVfx = 1224; nBeam = VFX_BEAM_HOLY; nField = 1813; }
        MV_Visual(oBoss,oBoss,nVfx);
        object oPC = GetLocalObject(oBoss,"MV_TARGET_"+sKey);
        if (MV_IsTarget(oBoss,oPC))
        {
            MV_Beam(oBoss,oPC,oBoss,nBeam,"ABSORB",MV_ABSORB_TIME);
            MV_Visual(oBoss,oBoss,nField,"ABSORB",MV_ABSORB_TIME);
        }
    }
    if (nCount > 0) MV_Visual(oBoss,oBoss,1829);
    if (nCount == 3) MV_Visual(oBoss,oBoss,1883,"ABSORB",MV_ABSORB_TIME);
    MV_Visual(oBoss,oBoss,VFX_IMP_PULSE_HOLY);
}

vector MV_Ray(object oBoss, float fAngle, float fDistance, float fZ = 0.0)
{
    vector v = GetPosition(oBoss);
    vector d = AngleToVector(fAngle);
    return Vector(v.x+d.x*fDistance,v.y+d.y*fDistance,v.z+fZ);
}

object MV_Point(object oBoss, float fAngle, float fDistance, float fZ, float fLifetime)
{
    object oPoint = CreateObject(OBJECT_TYPE_CREATURE,"prism_sweep_end",
        Location(GetArea(oBoss),MV_Ray(oBoss,fAngle,fDistance,fZ),fAngle));
    if (!GetIsObjectValid(oPoint)) return OBJECT_INVALID;
    SetCreatureAppearanceType(oPoint,APPEARANCE_TYPE_INVISIBLE_HUMAN_MALE);
    SetName(oPoint," ");
    SetPlotFlag(oPoint,TRUE);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectCutsceneGhost(),oPoint,fLifetime);
    SetObjectVisualTransform(oPoint,OBJECT_VISUAL_TRANSFORM_SCALE,0.01);
    // Lifetime is owned by the helper, even if the boss itself is destroyed.
    AssignCommand(oPoint,DelayCommand(fLifetime,DestroyObject(OBJECT_SELF)));
    return oPoint;
}

void MV_MovePoint(object oPoint, vector vDestination, float fTime)
{
    vector vStart = GetPosition(oPoint);
    vector d = AngleToVector(GetFacing(oPoint));
    float fDX = vDestination.x-vStart.x;
    float fDY = vDestination.y-vStart.y;
    SetObjectVisualTransform(oPoint,OBJECT_VISUAL_TRANSFORM_TRANSLATE_X,
        fDX*d.y-fDY*d.x,OBJECT_VISUAL_TRANSFORM_LERP_LINEAR,fTime);
    SetObjectVisualTransform(oPoint,OBJECT_VISUAL_TRANSFORM_TRANSLATE_Y,
        fDX*d.x+fDY*d.y,OBJECT_VISUAL_TRANSFORM_LERP_LINEAR,fTime);
}

int MV_StartWarning(object oBoss)
{
    float fBase = IntToFloat(Random(360));
    SetLocalFloat(oBoss,"MV_ANGLE",fBase);
    int i;
    for (i=1;i<=3;i++)
    {
        float fAngle = fBase+IntToFloat(i-1)*120.0;
        object oStart = MV_Point(oBoss,fAngle,0.8,-1.0,6.0);
        object oEnd = MV_Point(oBoss,fAngle,1.5,-1.0,6.0);
        SetLocalObject(oBoss,"MV_WS"+IntToString(i),oStart);
        SetLocalObject(oBoss,"MV_WE"+IntToString(i),oEnd);
        if (!GetIsObjectValid(oStart) || !GetIsObjectValid(oEnd)) return FALSE;
        MV_Beam(oBoss,oStart,oEnd,213,"WARN",5.0);
    }
    return TRUE;
}

int MV_StartSweep(object oBoss)
{
    MV_DestroyPoints(oBoss,"MV_WS",3);
    MV_DestroyPoints(oBoss,"MV_WE",3);
    float fBase = GetLocalFloat(oBoss,"MV_ANGLE");
    int i;
    for (i=1;i<=3;i++)
    {
        object oEnd = MV_Point(oBoss,fBase+IntToFloat(i-1)*120.0,MV_SWEEP_LENGTH,0.0,10.0);
        SetLocalObject(oBoss,"MV_SE"+IntToString(i),oEnd);
        if (!GetIsObjectValid(oEnd)) return FALSE;
        MV_Beam(oBoss,oBoss,oEnd,444,"RAY",8.5);
    }
    MV_Visual(oBoss,oBoss,467,"SWEEP",8.5);
    return TRUE;
}

void MV_SweepHit(object oBoss, object oPC, int nTick)
{
    if (!MV_IsTarget(oBoss,oPC)) return;
    string sKey = "MV_HIT_"+ObjectToString(oPC);
    string sSerialKey = sKey+"_CAST";
    int nCast = GetLocalInt(oBoss,"MV_CAST");
    if (GetLocalInt(oBoss,sSerialKey) == nCast && nTick < GetLocalInt(oBoss,sKey)) return;
    SetLocalInt(oBoss,sSerialKey,nCast);
    SetLocalInt(oBoss,sKey,nTick+MV_SWEEP_HIT_TICKS);
    MV_Touch(oBoss,oPC);
    // Preserve the original sweep's mantle removal.
    effect e = GetFirstEffect(oPC);
    while (GetIsEffectValid(e))
    {
        if (GetEffectType(e) == EFFECT_TYPE_SPELLLEVELABSORPTION)
        { RemoveEffect(oPC,e); e = GetFirstEffect(oPC); }
        else e = GetNextEffect(oPC);
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(MV_SWEEP_DAMAGE),oPC);
    MV_Visual(oBoss,oPC,258);
    if (!MV_IsTarget(oBoss,oPC) || GetLocalInt(oBoss,"MV_CAST") != nCast) return;
    if (GetLocalInt(oBoss,"MV_COLOUR_0"))
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(MV_SWEEP_DAMAGE,DAMAGE_TYPE_FIRE),oPC);
    if (!MV_IsTarget(oBoss,oPC) || GetLocalInt(oBoss,"MV_CAST") != nCast) return;
    if (GetLocalInt(oBoss,"MV_COLOUR_1"))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(MV_SWEEP_DAMAGE,DAMAGE_TYPE_COLD),oPC);
        MV_Remove(oBoss,oPC,"SLOW");
        effect eSlow = TagEffect(EffectMovementSpeedDecrease(20),MV_Tag(oBoss,"SLOW"));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eSlow,oPC,2.0);
    }
    if (!MV_IsTarget(oBoss,oPC) || GetLocalInt(oBoss,"MV_CAST") != nCast) return;
    if (GetLocalInt(oBoss,"MV_COLOUR_2"))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(MV_SWEEP_DAMAGE),oBoss);
        MV_Visual(oBoss,oBoss,201);
    }
}

int MV_StartSwap(object oBoss)
{
    object oA = MV_Pick(oBoss);
    if (!GetIsObjectValid(oA)) return FALSE;
    // Original rule: the two selected PCs must be enemies of each other too.
    object oB = MV_Pick(oBoss,oA,OBJECT_INVALID,oA);
    if (!GetIsObjectValid(oB)) return FALSE;
    SetLocalObject(oBoss,"MV_SWAP_A",oA);
    SetLocalObject(oBoss,"MV_SWAP_B",oB);
    MV_Touch(oBoss,oA);
    MV_Beam(oBoss,oA,oB,213,"SWAP",6.5);
    int nCast = MV_Enter(oBoss,MV_SWAP);
    PrintString("[MALVERIS v1] swap started");
    MV_After(oBoss,GetLocalInt(oBoss,"MV_EPOCH"),nCast,MV_SWAP,1,MV_SWAP_INTERVAL);
    return TRUE;
}

void MV_BreakSwap(object oBoss, object oPC)
{
    if (!MV_IsTarget(oBoss,oPC)) return;
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(MV_BREAK_DAMAGE),oPC);
    if (!MV_IsTarget(oBoss,oPC) || GetLocalInt(oBoss,"MV_PHASE") != MV_SWAP) return;
    effect e = TagEffect(EffectKnockdown(),MV_Tag(oBoss,"KD"));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e,oPC,MV_SWAP_KNOCKDOWN);
    MV_Visual(oBoss,oPC,258);
}

void MV_Step(object oBoss, int nEpoch, int nCast, int nPhase, int nTick)
{
    // A stale callback cannot cancel or mutate a newer encounter/cast.
    if (!MV_IsBoss(oBoss) || GetLocalInt(oBoss,"MV_EPOCH") != nEpoch || GetLocalInt(oBoss,"MV_CAST") != nCast ||
        GetLocalInt(oBoss,"MV_PHASE") != nPhase) return;
    if (!MV_Alive(oBoss,nEpoch) || !MV_HasTarget(oBoss)) { MV_Reset(oBoss); return; }
    if (nPhase == MV_RECOVERY)
    {
        SetLocalInt(oBoss,"MV_PHASE",MV_IDLE);
        return;
    }
    if (nPhase == MV_SWAP)
    {
        object oA = GetLocalObject(oBoss,"MV_SWAP_A");
        object oB = GetLocalObject(oBoss,"MV_SWAP_B");
        if (!MV_IsTarget(oBoss,oA) || !MV_IsTarget(oBoss,oB))
        { MV_ClearCast(oBoss); return; }
        if (GetDistanceBetween(oA,oB) > MV_TARGET_RADIUS)
        {
            MV_BreakSwap(oBoss,oA); MV_BreakSwap(oBoss,oB);
            MV_ClearCast(oBoss);
            return;
        }
        if (nTick >= MV_SWAP_TICKS)
        {
            location lA = GetLocation(oA);
            location lB = GetLocation(oB);
            MV_ClearCast(oBoss);
            // Instant native relocation; never alter either player's queue/control.
            AssignCommand(oA,JumpToLocation(lB));
            AssignCommand(oB,JumpToLocation(lA));
            return;
        }
        MV_After(oBoss,nEpoch,nCast,nPhase,nTick+1,MV_SWAP_INTERVAL);
        return;
    }
    if (nPhase == MV_TRIPLE)
    {
        int i;
        int nActive = 0;
        for (i=0;i<3;i++)
        {
            string sKey = IntToString(i);
            if (!GetLocalInt(oBoss,"MV_COLOUR_"+sKey)) continue;
            object oTarget = GetLocalObject(oBoss,"MV_TARGET_"+sKey);
            string sTag = "F";
            if (i == 1) sTag = "C";
            if (i == 2) sTag = "H";
            if (!MV_IsTarget(oBoss,oTarget) || GetDistanceBetween(oBoss,oTarget) > MV_TARGET_RADIUS)
            {
                MV_Remove(oBoss,oTarget,sTag);
                SetLocalInt(oBoss,"MV_COLOUR_"+sKey,FALSE);
                // Leaving the area/dying cancels a beam without a remote hit.
                if (MV_IsTarget(oBoss,oTarget)) MV_ColourEffect(oBoss,oTarget,i,MV_BREAK_DAMAGE,TRUE);
                continue;
            }
            nActive++;
            if (nTick%4 == 0)
            {
                object oPC = GetFirstObjectInArea(GetArea(oBoss),OBJECT_TYPE_CREATURE);
                while (GetIsObjectValid(oPC))
                {
                    if (MV_IsTarget(oBoss,oPC) && MV_InBeam(GetPosition(oBoss),GetPosition(oTarget),GetPosition(oPC),MV_BEAM_WIDTH))
                        MV_ColourEffect(oBoss,oPC,i,MV_CROSS_DAMAGE,FALSE);
                    oPC = GetNextObjectInArea(GetArea(oBoss),OBJECT_TYPE_CREATURE);
                }
            }
        }
        if (!MV_Alive(oBoss,nEpoch) || GetLocalInt(oBoss,"MV_CAST") != nCast) return;
        if (!nActive || nTick >= MV_BEAM_TICKS)
        {
            MV_RemoveLinks(oBoss);
            SetLocalInt(oBoss,"MV_PHASE",MV_ABSORB_WAIT);
            MV_After(oBoss,nEpoch,nCast,MV_ABSORB_WAIT,0,MV_ABSORB_PAUSE);
        }
        else MV_After(oBoss,nEpoch,nCast,nPhase,nTick+1,MV_BEAM_INTERVAL);
        return;
    }
    if (nPhase == MV_ABSORB_WAIT)
    {
        MV_Absorb(oBoss);
        SetLocalInt(oBoss,"MV_PHASE",MV_ABSORB);
        MV_After(oBoss,nEpoch,nCast,MV_ABSORB,0,MV_ABSORB_TIME);
        return;
    }
    if (nPhase == MV_ABSORB)
    {
        MV_Remove(oBoss,oBoss,"ABSORB");
        if (!MV_StartWarning(oBoss)) { MV_Recovery(oBoss); return; }
        SetLocalInt(oBoss,"MV_PHASE",MV_WARNING);
        MV_After(oBoss,nEpoch,nCast,MV_WARNING,2,MV_WARN_INTERVAL);
        return;
    }
    if (nPhase == MV_WARNING)
    {
        if (nTick > MV_WARN_STEPS)
        {
            if (!MV_StartSweep(oBoss)) { MV_Recovery(oBoss); return; }
            SetLocalInt(oBoss,"MV_PHASE",MV_SWEEP);
            MV_Step(oBoss,nEpoch,nCast,MV_SWEEP,0);
            return;
        }
        float fAngle = GetLocalFloat(oBoss,"MV_ANGLE");
        int i;
        for (i=1;i<=3;i++)
        {
            object oEnd = GetLocalObject(oBoss,"MV_WE"+IntToString(i));
            if (!GetIsObjectValid(oEnd)) { MV_Recovery(oBoss); return; }
            MV_MovePoint(oEnd,MV_Ray(oBoss,fAngle+IntToFloat(i-1)*120.0,IntToFloat(nTick)*1.5,-1.0),MV_WARN_INTERVAL);
        }
        float fDelay = MV_WARN_INTERVAL;
        if (nTick == MV_WARN_STEPS) fDelay = MV_WARN_HOLD;
        MV_After(oBoss,nEpoch,nCast,nPhase,nTick+1,fDelay);
        return;
    }
    if (nPhase == MV_SWEEP)
    {
        if (nTick >= MV_SWEEP_TICKS) { MV_Recovery(oBoss); return; }
        float fAngle = GetLocalFloat(oBoss,"MV_ANGLE")+IntToFloat(nTick)*MV_SWEEP_ANGLE_STEP;
        object oPC = GetFirstObjectInArea(GetArea(oBoss),OBJECT_TYPE_CREATURE);
        while (GetIsObjectValid(oPC))
        {
            if (MV_IsTarget(oBoss,oPC))
            {
                int i;
                int nHit = FALSE;
                for (i=0;i<3 && !nHit;i++)
                    nHit = MV_InBeam(GetPosition(oBoss),MV_Ray(oBoss,fAngle+IntToFloat(i)*120.0,MV_SWEEP_LENGTH),GetPosition(oPC),MV_SWEEP_WIDTH);
                if (nHit) MV_SweepHit(oBoss,oPC,nTick);
            }
            oPC = GetNextObjectInArea(GetArea(oBoss),OBJECT_TYPE_CREATURE);
        }
        if (!MV_Alive(oBoss,nEpoch) || GetLocalInt(oBoss,"MV_CAST") != nCast) return;
        int i;
        for (i=1;i<=3;i++)
        {
            object oEnd = GetLocalObject(oBoss,"MV_SE"+IntToString(i));
            if (!GetIsObjectValid(oEnd)) { MV_Recovery(oBoss); return; }
            MV_MovePoint(oEnd,MV_Ray(oBoss,fAngle+MV_SWEEP_ANGLE_STEP+IntToFloat(i-1)*120.0,MV_SWEEP_LENGTH),MV_SWEEP_INTERVAL);
        }
        MV_After(oBoss,nEpoch,nCast,nPhase,nTick+1,MV_SWEEP_INTERVAL);
    }
}

void MV_Control(object oBoss, int nEpoch)
{
    if (!MV_Alive(oBoss,nEpoch))
    {
        // Only the current encounter may clean up its own state.
        if (MV_IsBoss(oBoss) && GetLocalInt(oBoss,"MV_EPOCH") == nEpoch) MV_Reset(oBoss);
        return;
    }
    if (!MV_HasTarget(oBoss)) { MV_Reset(oBoss); return; }
    int nPhase = GetLocalInt(oBoss,"MV_PHASE");
    if (nPhase == MV_IDLE && !GetIsInCombat(oBoss) && !GetIsObjectValid(GetAttackTarget(oBoss)))
    { MV_Reset(oBoss); return; }
    float fTime = GetLocalFloat(oBoss,"MV_TIME")+MV_CONTROL_INTERVAL;
    SetLocalFloat(oBoss,"MV_TIME",fTime);
    if (nPhase == MV_IDLE)
    {
        if (fTime >= GetLocalFloat(oBoss,"MV_SWAP_CHECK"))
        {
            SetLocalFloat(oBoss,"MV_SWAP_CHECK",fTime+MV_SWAP_CHECK);
            if (fTime >= GetLocalFloat(oBoss,"MV_SWAP_DUE") && MV_StartSwap(oBoss))
                SetLocalFloat(oBoss,"MV_SWAP_DUE",fTime+MV_SWAP_COOLDOWN);
        }
        if (GetLocalInt(oBoss,"MV_PHASE") == MV_IDLE && fTime >= GetLocalFloat(oBoss,"MV_TRI_DUE") && MV_StartTriple(oBoss))
            SetLocalFloat(oBoss,"MV_TRI_DUE",fTime+MV_TRIPLE_COOLDOWN);
    }
    DelayCommand(MV_CONTROL_INTERVAL,MV_Control(oBoss,nEpoch));
}

void MV_Observe(object oBoss)
{
    if (!MV_IsBoss(oBoss)) return;
    if (GetIsDead(oBoss) || GetCurrentHitPoints(oBoss) <= 0)
    { if (GetLocalInt(oBoss,"MV_RUNNING")) MV_Reset(oBoss); return; }
    if (GetLocalInt(oBoss,"MV_RUNNING")) return;
    // The native AI must enter combat first. This controller never acquires targets.
    if ((!GetIsInCombat(oBoss) && !GetIsObjectValid(GetAttackTarget(oBoss))) || !MV_HasTarget(oBoss)) return;
    MV_Reset(oBoss);
    SetLocalObject(oBoss,"MV_AREA",GetArea(oBoss));
    SetLocalInt(oBoss,"MV_RUNNING",TRUE);
    SetLocalFloat(oBoss,"MV_TIME",0.0);
    SetLocalFloat(oBoss,"MV_TRI_DUE",MV_FIRST_TRIPLE);
    SetLocalFloat(oBoss,"MV_SWAP_DUE",MV_FIRST_SWAP);
    SetLocalFloat(oBoss,"MV_SWAP_CHECK",MV_FIRST_SWAP);
    int nEpoch = GetLocalInt(oBoss,"MV_EPOCH");
    PrintString("[MALVERIS v1] encounter started by native AI; epoch="+IntToString(nEpoch));
    DelayCommand(MV_CONTROL_INTERVAL,MV_Control(oBoss,nEpoch));
}

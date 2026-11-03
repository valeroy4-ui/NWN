// Link lifecycle. Only existing Purple Dragon Knight (class 41).
// Slots are owned by the PDK; categories never imply bundled effects.
#include "nwnx_object"
#include "pdkl_native"
#include "pdkl_proc_math"
const int PDKL_CLASS = 41;
const int PDKL_MAX = 3;
const string PDKL_AC_TAG = "PDKL_OWNER_AC";

void PDKL_RemoveEndurance(object oPDK, int nSlot);
void PDKL_UpdateEndurance(object oPDK);
void PDKL_RemoveEmpower(object owner,int slot);
void PDKL_UpdateEmpower(object owner);
void PDKL_RemoveSound(object owner,int slot);
void PDKL_NotifyBreak(object owner,object target);
void PDKL_UpdateSounds(object owner);

string PDKL_Key(string sField, int nSlot)
{ return "PDKL_" + sField + "_" + IntToString(nSlot); }

int PDKL_Group(int nKind)
{
    if(nKind >= 1 && nKind <= 3) return 1;
    if((nKind >= 4 && nKind <= 5) || nKind==20) return 2;
    if(nKind >= 6 && nKind <= 10) return 3;
    if(nKind >= 11 && nKind <= 13) return 4;
    if(nKind >= 14 && nKind <= 16) return 5;
    if(nKind >= 17 && nKind <= 19) return 6;
    return 0;
}

int PDKL_GroupSlot(object oPDK, int nGroup)
{
    int i;
    for(i=1;i<=PDKL_MAX;i++)
        if(PDKL_Group(GetLocalInt(oPDK,PDKL_Key("KIND",i))) == nGroup) return i;
    return 0;
}

string PDKL_ExperienceTag(object oPDK, int nSlot)
{ return "PDKL_XP_" + ObjectToString(oPDK) + "_" + IntToString(nSlot); }

// Track the applied target separately: the slot may change target or be broken.
// Each owner/slot has a unique tag, so unrelated buffs and other owners survive.
void PDKL_RemoveExperience(object oPDK, int nSlot)
{
    object oTarget = GetLocalObject(oPDK, PDKL_Key("XP_TARGET", nSlot));
    if(GetIsObjectValid(oTarget))
    {
        string sTag = PDKL_ExperienceTag(oPDK, nSlot);
        effect e = GetFirstEffect(oTarget);
        while(GetIsEffectValid(e))
        {
            if(GetEffectTag(e) == sTag) RemoveEffect(oTarget, e);
            e = GetNextEffect(oTarget);
        }
    }
    DeleteLocalObject(oPDK, PDKL_Key("XP_TARGET", nSlot));
    DeleteLocalInt(oPDK, PDKL_Key("XP_KIND", nSlot));
    DeleteLocalInt(oPDK, PDKL_Key("XP_VALUE", nSlot));
}

int PDKL_ExperienceEffectCount(object oTarget, string sTag)
{
    int nCount = 0;
    effect e = GetFirstEffect(oTarget);
    while(GetIsEffectValid(e))
    {
        if(GetEffectTag(e) == sTag) nCount++;
        e = GetNextEffect(oTarget);
    }
    return nCount;
}

void PDKL_ApplyExperienceEffects(object oPDK, object oTarget, int nKind, int nValue, string sTag)
{
    if(nKind == 11)
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,
            TagEffect(SetEffectCreator(SupernaturalEffect(EffectSavingThrowIncrease(SAVING_THROW_ALL, nValue)), oPDK), sTag), oTarget);
    else
    {
        int a = SKILL_CONCENTRATION;
        int b = SKILL_SPOT;
        int c = SKILL_LISTEN;
        if(nKind == 13) { a = SKILL_TAUNT; b = SKILL_HIDE; c = SKILL_MOVE_SILENTLY; }
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,
            TagEffect(SetEffectCreator(SupernaturalEffect(EffectSkillIncrease(a, nValue)), oPDK), sTag), oTarget);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,
            TagEffect(SetEffectCreator(SupernaturalEffect(EffectSkillIncrease(b, nValue)), oPDK), sTag), oTarget);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,
            TagEffect(SetEffectCreator(SupernaturalEffect(EffectSkillIncrease(c, nValue)), oPDK), sTag), oTarget);
    }
}

string PDKL_BeamTag(object oPDK, int nGroup)
{ return "PDKL_BEAM_" + ObjectToString(oPDK) + "_" + IntToString(nGroup); }

int PDKL_BeamVFX(int nGroup)
{ return StringToInt(Get2DAString("pdkl_beams", "VFX", nGroup)); }

void PDKL_RemoveBeam(object oPDK, int nSlot)
{
    object oldTarget=GetLocalObject(oPDK,PDKL_Key("BEAM_TARGET",nSlot));
    int oldGroup=GetLocalInt(oPDK,PDKL_Key("BEAM_GROUP",nSlot));
    if(GetIsObjectValid(oldTarget) && oldGroup>0)
    {
        string tag=PDKL_BeamTag(oPDK,oldGroup);
        effect e=GetFirstEffect(oldTarget);
        while(GetIsEffectValid(e))
        {
            if(GetEffectTag(e)==tag) RemoveEffect(oldTarget,e);
            e=GetNextEffect(oldTarget);
        }
    }
    object oAnchor = GetLocalObject(oPDK, PDKL_Key("BEAM_ANCHOR", nSlot));
    if(GetIsObjectValid(oAnchor)) DestroyObject(oAnchor);
    DeleteLocalObject(oPDK, PDKL_Key("BEAM_ANCHOR", nSlot));
    DeleteLocalObject(oPDK, PDKL_Key("BEAM_TARGET", nSlot));
    DeleteLocalInt(oPDK, PDKL_Key("BEAM_GROUP", nSlot));
    DeleteLocalInt(oPDK, PDKL_Key("BEAM_MODE", nSlot));
}

int PDKL_BeamsOnTarget(object oPDK, object oTarget)
{
    int nCount=0;
    int i;
    for(i = 1; i <= PDKL_MAX; i++)
    {
        object a=GetLocalObject(oPDK,PDKL_Key("BEAM_ANCHOR",i));
        int g=GetLocalInt(oPDK,PDKL_Key("BEAM_GROUP",i));
        if(GetLocalInt(oPDK,PDKL_Key("BEAM_MODE",i))) a=oTarget;
        if(GetLocalObject(oPDK,PDKL_Key("BEAM_TARGET",i))==oTarget && GetIsObjectValid(a)
            && PDKL_ExperienceEffectCount(a,PDKL_BeamTag(oPDK,g))==1) nCount++;
    }
    return nCount;
}

vector PDKL_BeamEndpoint(object oPDK, object oTarget, int nSlot)
{
    vector p=GetPosition(oTarget);
    vector d=p-GetPosition(oPDK);
    float length=sqrt(d.x*d.x+d.y*d.y);
    vector side=Vector(1.0,0.0,0.0);
    if(length>0.01) side=Vector(-d.y/length,d.x/length,0.0);
    // Small fan at the target; all beams retain the same caster chest source.
    p=p+side*(IntToFloat(nSlot)-2.0)*0.28;
    p.z+=1.1;
    return p;
}

void PDKL_ApplyBeam(object oPDK, object oAnchor, int nGroup, string sTag, vector offset=[0.0,0.0,0.0])
{
    ApplyEffectToObject(DURATION_TYPE_PERMANENT,
        TagEffect(SetEffectCreator(SupernaturalEffect(EffectBeam(PDKL_BeamVFX(nGroup), oPDK, BODY_NODE_CHEST,
            FALSE,1.0,offset)), oPDK), sTag), oAnchor);
}

int PDKL_Now()
{ return GetLocalInt(GetModule(), "PDKL_TICK"); }

int PDKL_Level(object oPDK)
{ return GetLevelByClass(PDKL_CLASS, oPDK); }

int PDKL_Alive(object oCreature)
{
    return GetIsObjectValid(oCreature) && GetObjectType(oCreature) == OBJECT_TYPE_CREATURE
        && !GetIsDead(oCreature) && GetCurrentHitPoints(oCreature) > 0;
}

int PDKL_Ally(object oPDK, object oTarget)
{
    if(oPDK == oTarget || !PDKL_Alive(oTarget)) return FALSE;
    if(GetIsEnemy(oTarget, oPDK)) return FALSE;
    int a = GetLocalInt(oPDK, "FACTION");
    int b = GetLocalInt(oTarget, "FACTION");
    if(a > 0 && b > 0) return a == b;
    return GetIsFriend(oTarget, oPDK) || GetFactionEqual(oPDK, oTarget);
}

int PDKL_Limit(object oPDK)
{
    // A separate test setting grants slots only, not Fame/rune effects.
    int n = StringToInt(Get2DAString("pdkl_config", "TestSlots", 0));
    if(n <= 0)
        n = 1 + (GetLocalInt(oPDK, "PDKL_FAME_SLOT") != 0)
              + (GetLocalInt(oPDK, "PDKL_RUNE3_SLOT") != 0);
    return n > PDKL_MAX ? PDKL_MAX : n;
}

float PDKL_Range(object oPDK)
{
    float f = 5.0 + IntToFloat(PDKL_Level(oPDK)) / 5.0;
    if(GetLocalInt(oPDK, "PDKL_FAME_RANGE")) f += 5.0;
    return f;
}

int PDKL_InRange(object oPDK, object oTarget)
{
    if(!PDKL_Alive(oPDK) || PDKL_Level(oPDK) < 1 || !PDKL_Ally(oPDK, oTarget)) return FALSE;
    if(!GetIsObjectValid(GetArea(oPDK)) || GetArea(oPDK) != GetArea(oTarget)) return FALSE;
    float fRange = PDKL_Range(oPDK);
    float fDistance = GetDistanceBetween(oPDK, oTarget);
    return fDistance >= 0.0 && fDistance <= fRange;
}

void PDKL_ClearSlot(object oPDK, int nSlot, int notify=TRUE)
{
    if(notify && GetLocalInt(oPDK,PDKL_Key("KIND",nSlot))>0)
        PDKL_NotifyBreak(oPDK,GetLocalObject(oPDK,PDKL_Key("TARGET",nSlot)));
    PDKL_RemoveEmpower(oPDK,nSlot);
    PDKL_RemoveSound(oPDK,nSlot);
    PDKL_RemoveEndurance(oPDK, nSlot);
    PDKL_RemoveExperience(oPDK, nSlot);
    PDKL_RemoveBeam(oPDK, nSlot);
    DeleteLocalObject(oPDK, PDKL_Key("TARGET", nSlot));
    DeleteLocalInt(oPDK, PDKL_Key("KIND", nSlot));
    DeleteLocalInt(oPDK, PDKL_Key("LAST", nSlot));
    DeleteLocalInt(oPDK, PDKL_Key("ORDER", nSlot));
}

int PDKL_ActiveCount(object oPDK)
{
    int n = 0;
    int i;
    for(i = 1; i <= PDKL_Limit(oPDK); i++)
        if(GetLocalInt(oPDK, PDKL_Key("KIND", i)) > 0
            && PDKL_InRange(oPDK, GetLocalObject(oPDK, PDKL_Key("TARGET", i)))) n++;
    return n;
}

void PDKL_RemoveAC(object oPDK)
{
    effect e = GetFirstEffect(oPDK);
    while(GetIsEffectValid(e))
    {
        if(GetEffectTag(e) == PDKL_AC_TAG) RemoveEffect(oPDK, e);
        e = GetNextEffect(oPDK);
    }
}

void PDKL_UpdateAC(object oPDK)
{
    int n = PDKL_ActiveCount(oPDK);
    int nFound = 0;
    effect e = GetFirstEffect(oPDK);
    while(GetIsEffectValid(e))
    {
        if(GetEffectTag(e) == PDKL_AC_TAG) nFound++;
        e = GetNextEffect(oPDK);
    }
    if(n == GetLocalInt(oPDK, "PDKL_AC_COUNT") && nFound == (n > 0)) return;
    PDKL_RemoveAC(oPDK);
    SetLocalInt(oPDK, "PDKL_AC_COUNT", n);
    if(n > 0)
        ApplyEffectToObject(DURATION_TYPE_PERMANENT,
            TagEffect(SupernaturalEffect(EffectACDecrease(6 * n, AC_DODGE_BONUS)), PDKL_AC_TAG), oPDK);
}

void PDKL_UpdateExperience(object oPDK);
void PDKL_UpdateBeams(object oPDK);

void PDKL_Refresh(object oPDK)
{
    int i;
    int nNow = PDKL_Now();
    int nGroups = 0;
    for(i = 1; i <= PDKL_MAX; i++)
    {
        if(GetLocalInt(oPDK, PDKL_Key("KIND", i)) > 0)
        {
            object oTarget = GetLocalObject(oPDK, PDKL_Key("TARGET", i));
            int nGroup = PDKL_Group(GetLocalInt(oPDK, PDKL_Key("KIND", i)));
            int nBit = 1 << nGroup;
            if(i > PDKL_Limit(oPDK) || nGroup == 0 || (nGroups & nBit) || !PDKL_InRange(oPDK, oTarget)
                || PDKL_Level(oPDK)<PDKL_ProcMinLevel(GetLocalInt(oPDK,PDKL_Key("KIND",i))))
            {
                PDKL_ClearSlot(oPDK, i);
                if(GetIsPC(oPDK)) SendMessageToPC(oPDK, "Link broken. Slot "+IntToString(i)+" is free; cast again to reconnect.");
            }
            else
            {
                nGroups = nGroups | nBit;
                SetLocalInt(oPDK, PDKL_Key("LAST", i), nNow);
            }
        }
    }
    PDKL_UpdateAC(oPDK);
    PDKL_UpdateExperience(oPDK);
    PDKL_UpdateEndurance(oPDK);
    PDKL_UpdateEmpower(oPDK);
    PDKL_UpdateBeams(oPDK);
    PDKL_UpdateSounds(oPDK);
}

int PDKL_BenefitActive(object oPDK, int nSlot)
{
    if(nSlot > PDKL_Limit(oPDK) || GetLocalInt(oPDK, PDKL_Key("KIND", nSlot)) <= 0) return FALSE;
    object oTarget = GetLocalObject(oPDK, PDKL_Key("TARGET", nSlot));
    if(!PDKL_Alive(oPDK) || PDKL_Level(oPDK) < 1 || !PDKL_Ally(oPDK, oTarget)) return FALSE;
    return PDKL_InRange(oPDK, oTarget);
}

void PDKL_UpdateBeams(object oPDK)
{
    int i;
    for(i = 1; i <= PDKL_MAX; i++)
    {
        object oTarget = GetLocalObject(oPDK, PDKL_Key("TARGET", i));
        int nGroup = PDKL_Group(GetLocalInt(oPDK, PDKL_Key("KIND", i)));
        if(!PDKL_BenefitActive(oPDK, i)) { PDKL_RemoveBeam(oPDK, i); continue; }
        int direct=GetLocalInt(oPDK,"PDKL_BEAM_DIRECT")!=0;
        if(GetLocalObject(oPDK, PDKL_Key("BEAM_TARGET", i)) != oTarget
            || GetLocalInt(oPDK, PDKL_Key("BEAM_GROUP", i)) != nGroup
            || GetLocalInt(oPDK,PDKL_Key("BEAM_MODE",i))!=direct)
            PDKL_RemoveBeam(oPDK, i);
        SetLocalObject(oPDK, PDKL_Key("BEAM_TARGET", i), oTarget);
        SetLocalInt(oPDK, PDKL_Key("BEAM_GROUP", i), nGroup);
        SetLocalInt(oPDK,PDKL_Key("BEAM_MODE",i),direct);
        string sTag = PDKL_BeamTag(oPDK, nGroup);
        if(direct)
        {
            // Optional native-target mode: the client follows the real target's
            // interpolated movement instead of receiving teleported anchors.
            // The EffectBeam offset/fan appearance needs Windows verification.
            if(PDKL_ExperienceEffectCount(oTarget,sTag)==0)
            {
                PDKL_ApplyBeam(oPDK,oTarget,nGroup,sTag,Vector((IntToFloat(i)-2.0)*0.28,0.0,0.0));
                string gen=PDKL_Key("BEAM_GEN",i);
                SetLocalInt(oPDK,gen,GetLocalInt(oPDK,gen)+1);
            }
            continue;
        }
        object oAnchor=GetLocalObject(oPDK,PDKL_Key("BEAM_ANCHOR",i));
        vector vEnd=PDKL_BeamEndpoint(oPDK,oTarget,i);
        if(!GetIsObjectValid(oAnchor))
        {
            oAnchor=CreateObject(OBJECT_TYPE_PLACEABLE,"pdkl_anchor",Location(GetArea(oTarget),vEnd,0.0));
            SetLocalObject(oPDK,PDKL_Key("BEAM_ANCHOR",i),oAnchor);
        }
        else NWNX_Object_SetPosition(oAnchor,vEnd,FALSE);
        if(GetIsObjectValid(oAnchor) && PDKL_ExperienceEffectCount(oAnchor, sTag) == 0)
            PDKL_ApplyBeam(oPDK, oAnchor, nGroup, sTag);
    }
}

void PDKL_UpdateExperience(object oPDK)
{
    int nSlot;
    for(nSlot = 1; nSlot <= PDKL_MAX; nSlot++)
    {
        int nKind = GetLocalInt(oPDK, PDKL_Key("KIND", nSlot));
        object oTarget = GetLocalObject(oPDK, PDKL_Key("TARGET", nSlot));
        int nValue = PDKL_Level(oPDK) / 10;
        if(nKind < 11 || nKind > 13 || nValue <= 0 || !PDKL_BenefitActive(oPDK, nSlot))
        {
            PDKL_RemoveExperience(oPDK, nSlot);
            continue;
        }
        int nExpected = nKind == 11 ? 1 : 3;
        string sTag = PDKL_ExperienceTag(oPDK, nSlot);
        if(GetLocalObject(oPDK, PDKL_Key("XP_TARGET", nSlot)) == oTarget
            && GetLocalInt(oPDK, PDKL_Key("XP_KIND", nSlot)) == nKind
            && GetLocalInt(oPDK, PDKL_Key("XP_VALUE", nSlot)) == nValue
            && PDKL_ExperienceEffectCount(oTarget, sTag) == nExpected) continue;
        PDKL_RemoveExperience(oPDK, nSlot);
        SetLocalObject(oPDK, PDKL_Key("XP_TARGET", nSlot), oTarget);
        SetLocalInt(oPDK, PDKL_Key("XP_KIND", nSlot), nKind);
        SetLocalInt(oPDK, PDKL_Key("XP_VALUE", nSlot), nValue);
        // Apply synchronously so repeated instant requests cannot queue duplicates.
        // Explicitly retain the PDK as creator even when the module pulse runs this.
        PDKL_ApplyExperienceEffects(oPDK, oTarget, nKind, nValue, sTag);
    }
}

void PDKL_EndCooldown(object oPDK, int nToken)
{
    if(GetIsObjectValid(oPDK) && GetLocalInt(oPDK, "PDKL_CD_TOKEN") == nToken)
    {
        DeleteLocalInt(oPDK, "PDKL_BUSY");
        DeleteLocalInt(oPDK, "PDKL_READY");
    }
}

void PDKL_ClearOwner(object oPDK, int bKeepCooldown = FALSE)
{
    int i;
    for(i = 1; i <= PDKL_MAX; i++) PDKL_ClearSlot(oPDK, i);
    PDKL_RemoveAC(oPDK);
    DeleteLocalInt(oPDK, "PDKL_AC_COUNT");
    DeleteLocalInt(oPDK, "PDKL_READY");
    DeleteLocalInt(oPDK, "PDKL_BUSY");
    SetLocalInt(oPDK, "PDKL_CD_TOKEN", GetLocalInt(oPDK, "PDKL_CD_TOKEN") + 1);
}

void PDKL_Disconnect(object oCreature)
{
    if(!GetIsObjectValid(oCreature)) return;
    PDKL_ClearOwner(oCreature);
    object oPDK = GetFirstPC();
    int i;
    while(GetIsObjectValid(oPDK))
    {
        if(oPDK != oCreature)
        {
            for(i = 1; i <= PDKL_MAX; i++)
                if(GetLocalObject(oPDK, PDKL_Key("TARGET", i)) == oCreature)
                    PDKL_ClearSlot(oPDK, i);
            PDKL_UpdateAC(oPDK);
        }
        oPDK = GetNextPC();
    }
}

#include "pdkl_endur"
#include "pdkl_emp"
#include "pdkl_sound"

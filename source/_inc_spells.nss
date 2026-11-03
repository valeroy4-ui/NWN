#include "x0_i0_spells"
#include "nwnx_effect"
#include "_inc_players"
#include "_inc_draw"
#include "nwnx_creature"
#include "x0_i0_stringlib"
#include "_inc_areas"
#include "nw_i0_spells"

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// prints unpacked effect fields
void printeff(struct NWNX_EffectUnpacked n);

// returns custom timestop effect
effect EffectTimeStopCustom();

// returns FALSE if target not under timestop effect, TODO modify this function cos
// it used in bigby only
int spells_GetHasTimeStopEffect(object oCaster, object oTarget);

// activates cooldown for specific spell and creature
// nShowMessages values in (CORMYR_SPELL_COOLDOWN_SHOW_MESSAGES, CORMYR_SPELL_COOLDOWN_DONT_SHOW_MESSAGES)
// nTargetOrCaster values in (CORMYR_SPELL_COOLDOWN_CASTER, CORMYR_SPELL_COOLDOWN_TARGET)
// nCustomIconID can use value from effecticons.2da and display custom CD icon for PC
void spells_SetSpellCooldown(int iSpellId, object oTarget, float fTime, int nShowMessages = CORMYR_SPELL_COOLDOWN_SHOW_MESSAGES, int nTargetOrCaster = CORMYR_SPELL_COOLDOWN_CASTER, int nCustomIconID = EFFECT_ICON_INVALID);

// returns value from Timeout column spells.2da
float GetSpellTimeoutDuration(int iSpellId);

// returns TRUE if target has active cooldown for specific spell
// nBitDataArray values in (CORMYR_SPELL_COOLDOWN_CASTER, CORMYR_SPELL_COOLDOWN_TARGET)
int spells_GetHasSpellCooldown(int iSpellId, object oCreature, int nBitDataArray = CORMYR_SPELL_COOLDOWN_CASTER);

// returns TRUE if spell can not be removed by Greater Restoration spell etc
int GetIsSupernaturalCurse(effect eEff);

// returns spell name using spells.2da
string GetSpellNameFromID(int iSpellID);

// applies damage to caster after death magic usage, dont used in latest builds
void DoDeathSpellSelfDamage(object oCaster);

// returns spell focus level (1, 2, 3) for (spellfoc, greater spellfoc, epic spellfoc)
int GetSpellSchoolFocus(int nSchool, object oPC = OBJECT_SELF);

// returns TRUE if target has effect with sTag
int GetHasEffectWithSpecificTag(object oPC, string sTag);

// remove effect with <sTag> tag
void RemoveEffectWithSpecificTag(object oPC, string sTag);

// returns the first effect with specific nSpellID, can be filtered by optional parameter oCreator
effect spells_GetFirstEffectWithSpecificSpellID(object oTarget, int nSpellID, object oCreator=OBJECT_INVALID);

// remove all oCreator's effects, can be filtered by optional parameter nSpellID
void spells_RemoveAllCreatorsEffects(object oTarget, object oCreator, int nSpellID=-1);

// dirty hack for correct killer detection if caster kills himself
void spells_FixLastKillerAfterDeath(object oCaster, object oVictim, effect eDeath);

// sets effect that updates mass dislike
void spells_SetMassDislike(object oPC);

//
void spells_ClosePortals(string sPortalTag, float fDelay);

//
void spells_CloseStargate(object oStargate, float fDelay);

//
void spells_CloseStargateEnter(object oStargateEnter, object oStargateExit);

//
void spells_SetStargateOnUseScript(object oStargate, string sScript);

//
int spells_GetHasTrueEffect(object oTarget, int nEffect);

// decrease duration of spell with specific nSpellID
// if fChangeFactor < 1.0, then decrease calculates as percent, else as seconds
// if bPercentFlag == TRUE, then calculate the new duration relative to the original duration of the cast
// if bUseInitialCastDuration == TRUE, then use the spell duration determined at the original cast
void spells_ChangeSpellDuration(object oTarget, int nSpellID, float fChangeFactor, int bPercentFlag = TRUE, int bUseInitialCastDuration = TRUE);

// custom stun-like effect
effect spells_Shock();

/////////////////////
///  AOE section  ///
/////////////////////

// returns TRUE if there is a Caster's AoE next to it
int CheckNearAoes(object oCaster, location lLocation, float fRadius, float fMaxCheckDist = 30.0);

// returns TRUE if the casted AoE is too close to the trigger or portal's exit
int GetNearTriggers(object oCaster, location lLocation, float fDist=16.0);

void AddMarkersForAOE(object oPC, location lTarget, float fDuration, float fRadius);
string GetPlacebleByFaction(int nFaction);
void MarkSpellAOE(location lTarget, int iPlayerID, int iIndexAOE, object oAOE_Center);
void DestroyALLSpellMarkerPlacebles(object oCreatorAOE);
void DestroySpellMarkerPlacebles(location lTarget, int iIndexAOE, object oCreatorAOE);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void printeff(struct NWNX_EffectUnpacked n)
{
    string s = "Unpacked effect: \n";
    s += "sID = " + n.sID + "\n";
    s += "nType = " + IntToString(n.nType) + "\n";
    s += "nSubType = " + IntToString(n.nSubType) + "\n";

    s += "fDuration = " + FloatToString(n.fDuration) + "\n";
    s += "nExpiryCalendarDay = " + IntToString(n.nExpiryCalendarDay) + "\n";
    s += "nExpiryTimeOfDay = " + IntToString(n.nExpiryTimeOfDay) + "\n";

    s += "oCreator = " + ObjectToString(n.oCreator) + "\n";
    s += "nSpellId = " + IntToString(n.nSpellId) + "\n";
    s += "bExpose = " + IntToString(n.bExpose) + "\n";
    s += "bShowIcon = " + IntToString(n.bShowIcon) + "\n";
    s += "nCasterLevel = " + IntToString(n.nCasterLevel) + "\n";

    s += "bLinkLeftValid = " + IntToString(n.bLinkLeftValid) + "\n";
    struct NWNX_EffectUnpacked link = NWNX_Effect_UnpackEffect(n.eLinkLeft);
    s += "bLinkLeft (nType) = " + IntToString(link.nType) + "\n";
    s += "bLinkRightValid = " + IntToString(n.bLinkRightValid) + "\n";
    link = NWNX_Effect_UnpackEffect(n.eLinkRight);
    s += "bLinkRight (nType) = " + IntToString(link.nType) + "\n";

    s += "nNumIntegers = " + IntToString(n.nNumIntegers) + "\n";
    s += "nParam0 = " + IntToString(n.nParam0) + "\n";
    s += "nParam1 = " + IntToString(n.nParam1) + "\n";
    s += "nParam2 = " + IntToString(n.nParam2) + "\n";
    s += "nParam3 = " + IntToString(n.nParam3) + "\n";
    s += "nParam4 = " + IntToString(n.nParam4) + "\n";
    s += "nParam5 = " + IntToString(n.nParam5) + "\n";
    s += "nParam6 = " + IntToString(n.nParam6) + "\n";
    s += "nParam7 = " + IntToString(n.nParam7) + "\n";
    s += "fParam0 = " + FloatToString(n.fParam0) + "\n";
    s += "fParam1 = " + FloatToString(n.fParam1) + "\n";
    s += "fParam2 = " + FloatToString(n.fParam2) + "\n";
    s += "fParam3 = " + FloatToString(n.fParam3) + "\n";
    s += "sParam0 = " + "'" + n.sParam0 + "'" + "\n";
    s += "sParam1 = " + "'" + n.sParam1 + "'" + "\n";
    s += "sParam2 = " + "'" + n.sParam2 + "'" + "\n";
    s += "sParam3 = " + "'" + n.sParam3 + "'" + "\n";
    s += "sParam4 = " + "'" + n.sParam4 + "'" + "\n";
    s += "sParam5 = " + "'" + n.sParam5 + "'" + "\n";
    s += "oParam0 = " + ObjectToString(n.oParam0) + "\n";
    s += "oParam1 = " + ObjectToString(n.oParam1) + "\n";
    s += "oParam2 = " + ObjectToString(n.oParam2) + "\n";
    s += "oParam3 = " + ObjectToString(n.oParam3) + "\n";
    s += "vParam0 = {" + FloatToString(n.vParam0.x) + ", " + FloatToString(n.vParam0.y) + ", " + FloatToString(n.vParam0.z) + "}\n";
    s += "vParam1 = {" + FloatToString(n.vParam1.x) + ", " + FloatToString(n.vParam1.y) + ", " + FloatToString(n.vParam1.z) + "}\n";

    s += "sTag = " + "'" + n.sTag + "'" + "\n";

    s += "sItemProp = " + "'" + n.sItemProp + "'" + "\n";

    WriteTimestampedLogEntry(s);
}


effect EffectTimeStopCustom()
{
    effect eEff = EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION);
    eEff = EffectLinkEffects(eEff, EffectCutsceneImmobilize());
    eEff = EffectLinkEffects(eEff, EffectCutsceneParalyze());
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_ACID,        50));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_BASE_WEAPON, 50));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_BLUDGEONING, 50));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_COLD,        50));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_DIVINE,      10));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL,  50));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_FIRE,        50));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_MAGICAL,     10));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_NEGATIVE,    50));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_PIERCING,    30));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_POSITIVE,    10));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_SLASHING,    30));
    eEff = EffectLinkEffects(eEff, EffectDamageResistance(DAMAGE_TYPE_SONIC,       50));
    eEff = EffectLinkEffects(eEff, EffectAttackDecrease(30));
    eEff = EffectLinkEffects(eEff, EffectImmunity(IMMUNITY_TYPE_DEATH));
    eEff = EffectLinkEffects(eEff, EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS));
    eEff = EffectLinkEffects(eEff, EffectImmunity(IMMUNITY_TYPE_KNOCKDOWN));
    eEff = EffectLinkEffects(eEff, EffectImmunity(IMMUNITY_TYPE_PARALYSIS));
    eEff = EffectLinkEffects(eEff, EffectImmunity(IMMUNITY_TYPE_ENTANGLE));
    eEff = EffectLinkEffects(eEff, EffectImmunity(IMMUNITY_TYPE_SLOW));
    eEff = EffectLinkEffects(eEff, EffectImmunity(IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE));
    eEff = EffectLinkEffects(eEff, EffectSpellImmunity(SPELL_FLESH_TO_STONE));
    eEff = EffectLinkEffects(eEff, EffectImmunity(IMMUNITY_TYPE_CRITICAL_HIT));
    eEff = EffectLinkEffects(eEff, EffectImmunity(IMMUNITY_TYPE_SNEAK_ATTACK));
    //eEff = EffectLinkEffects(eEff, EffectIcon(EFFECT_ICON_TIMESTOP));
    eEff = SupernaturalEffect(eEff);
    eEff = SetEffectSpellId(eEff, SPELL_TIME_STOP);
    return eEff;
}

int spells_GetHasTimeStopEffect(object oCaster, object oTarget)
{
    effect eLoop = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eLoop))
    {
        if(GetEffectSpellId(eLoop) == SPELL_TIME_STOP && GetEffectTag(eLoop) != CORMYR_SPELL_COOLDOWN_TAG)
        {
            if (GetIsPC(oCaster))
                SendColorMessageToPC(oCaster, "The target cannot be affected by this spell during a Timestop.", TXT_COLOR_RED);
            return TRUE;
        }
        eLoop = GetNextEffect(oTarget);
    }
    return FALSE;
}

void spells_SetSpellCooldown(int iSpellId, object oTarget, float fTime, int nShowMessages = CORMYR_SPELL_COOLDOWN_SHOW_MESSAGES,
                             int nTargetOrCaster = CORMYR_SPELL_COOLDOWN_CASTER, int nCustomIconID = EFFECT_ICON_INVALID)
{
    iSpellId += TARGET_COOLDOWN_SPELL_ID_SHIFT; // shift to unused zone
    RemoveEffectsFromSpell(oTarget, iSpellId);
    string sBitDataArray = IntToString(nShowMessages | nTargetOrCaster);
    effect eCooldown = EffectRunScript("_mod_runscript", "_mod_runscript", "", 0.0, sBitDataArray);
    if(nCustomIconID != EFFECT_ICON_INVALID)
        eCooldown = EffectLinkEffects(EffectIcon(nCustomIconID), eCooldown);
    eCooldown = ExtraordinaryEffect(eCooldown);
    eCooldown = SetEffectSpellId(eCooldown, iSpellId);
    eCooldown = TagEffect(eCooldown, CORMYR_SPELL_COOLDOWN_TAG);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCooldown, oTarget, fTime);
}

float GetSpellTimeoutDuration(int iSpellId)
{
    return StringToFloat(Get2DAString("spells", "Timeout", iSpellId));
}

int spells_GetHasSpellCooldown(int iSpellId, object oCreature, int nBitDataArray = CORMYR_SPELL_COOLDOWN_CASTER)
{
    iSpellId += TARGET_COOLDOWN_SPELL_ID_SHIFT;
    effect eLoop = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eLoop))
    {
        if(GetEffectTag(eLoop) == CORMYR_SPELL_COOLDOWN_TAG && GetEffectSpellId(eLoop) == iSpellId &&
           StringToInt(GetEffectString(eLoop, 0)) &  nBitDataArray)
            return TRUE;
        eLoop = GetNextEffect(oCreature);
    }
    return FALSE;
}

int GetIsSupernaturalCurse(effect eEff)
{
    switch(GetEffectSpellId(eEff))
    {
        case 247: case 248: case 249: //ferocity
        case 273: case 274: case 275: //intensity
        case 299: case 300: case 301: //rage
        case SPELL_EVIL_BLIGHT:
        case SPELL_FLARE: /*monk painful hit*/
        case SPELL_PAINFUL_HIT: /*new painful hit*/
        case SPELL_TIME_STOP:
        case SPELL_DUKE_WARCRY:
        case SPELL_CORMYR_DISARM:
        case SPELL_BARBARIAN_RAGE_FEARLESS:
        case SPELL_BARBARIAN_RAGE_CONFUSE:
        case SPELL_BARBARIAN_RAGE_MIGHTY:
        case SPELL_BARBARIAN_RAGE_MURDERER:
        case SPELL_VASELINE_POTION:
        case SPELL_BIGBYS_INTERPOSING_HAND:
        return TRUE;
    }
    string sTag = GetTag(GetEffectCreator(eEff));
    return sTag == "q6e_ShaorisFellTemple" || sTag == "X3_EC_HORSE";
}

string GetSpellNameFromID(int iSpellID)
{
    string sResult = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", iSpellID)));
    if (iSpellID == SPELL_ALL_SUMMONED_CREATURES) sResult = "Summoned Creature";
    return sResult;
}

int GetSpellSchoolFocus(int nSchool, object oPC = OBJECT_SELF)
{
    switch(nSchool)
    {
        case SPELL_SCHOOL_ABJURATION:
        {
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ABJURATION,oPC))
                return 3;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ABJURATION,oPC))
                return 2;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_ABJURATION,oPC))
                return 1;
        }
        case SPELL_SCHOOL_CONJURATION:
        {
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION,oPC))
                return 3;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION,oPC))
                return 2;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION,oPC))
                return 1;
        }
        case SPELL_SCHOOL_DIVINATION:{
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_DIVINATION,oPC))
                return 3;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_DIVINATION,oPC))
                return 2;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION,oPC))
                return 1;}
        case SPELL_SCHOOL_ENCHANTMENT:{
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,oPC))
                return 3;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,oPC))
                return 2;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,oPC))
                return 1;}
        case SPELL_SCHOOL_EVOCATION:{
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_EVOCATION,oPC))
                return 3;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_EVOCATION,oPC))
                return 2;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_EVOCATION,oPC))
                return 1;}
        case SPELL_SCHOOL_ILLUSION:{
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ILLUSION,oPC))
                return 3;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ILLUSION,oPC))
                return 2;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_ILLUSION,oPC))
                return 1;}
        case SPELL_SCHOOL_NECROMANCY:{
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_NECROMANCY,oPC))
                return 3;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_NECROMANCY,oPC))
                return 2;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_NECROMANCY,oPC))
                return 1;}
        case SPELL_SCHOOL_TRANSMUTATION:{
            if(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_TRANSMUTATION,oPC))
                return 3;
            else if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_TRANSMUTATION,oPC))
                return 2;
            else if(GetHasFeat(FEAT_SPELL_FOCUS_TRANSMUTATION,oPC))
                return 1;}
    }
    return 0;
}

int GetHasEffectWithSpecificTag(object oPC, string sTag)
{
    effect eLoop = GetFirstEffect(oPC);
    while (GetIsEffectValid(eLoop))
    {
        if (GetEffectTag(eLoop) == sTag) return TRUE;
        eLoop = GetNextEffect(oPC);
    }
    return FALSE;
}

void RemoveEffectWithSpecificTag(object oPC, string sTag)
{
    effect eLoop = GetFirstEffect(oPC);
    while (GetIsEffectValid(eLoop))
    {
        if (GetEffectTag(eLoop) == sTag)
            RemoveEffect(oPC, eLoop);
        eLoop = GetNextEffect(oPC);
    }
}

effect spells_GetFirstEffectWithSpecificSpellID(object oTarget, int nSpellID, object oCreator=OBJECT_INVALID)
{
    effect eEmpty;
    effect eLoop = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eLoop))
    {
        if(GetIsObjectValid(oCreator))
        {
            if(GetEffectCreator(eLoop) == oCreator && GetEffectSpellId(eLoop) == nSpellID)
                return eLoop;
        }
        else if(GetEffectSpellId(eLoop) == nSpellID)
            return eLoop;

        eLoop = GetNextEffect(oTarget);
    }
    return eEmpty;
}

void spells_RemoveAllCreatorsEffects(object oTarget, object oCreator, int nSpellID=-1)
{
    effect eLoop = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eLoop))
    {
        if(nSpellID != -1)
        {
            if(GetEffectCreator(eLoop) == oCreator && GetEffectSpellId(eLoop) == nSpellID)
                RemoveEffect(oTarget, eLoop);
        }
        else if(GetEffectCreator(eLoop) == oCreator)
            RemoveEffect(oTarget, eLoop);

        eLoop = GetNextEffect(oTarget);
    }
}

void spells_FixLastKillerAfterDeath(object oCaster, object oVictim, effect eDeath)
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oVictim);
    NWNX_Creature_SetLastKiller(oVictim, oCaster);
}

void spells_SetMassDislike(object oPC)
{
    RemoveEffectsFromSpell(oPC, SPELL_CORMYR_SET_MASS_DISLIKE);
    effect eMassDislike = EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", 12.0);
    eMassDislike = SetEffectSpellId(eMassDislike, SPELL_CORMYR_SET_MASS_DISLIKE);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eMassDislike), oPC, DURATION_SERVER_SESSION);
}

void spells_ClosePortals(string sPortalTag, float fDelay)
{
    int nNth = 0;
    object oPortal = GetObjectByTag(sPortalTag, nNth);
    object oArea = GetArea(oPortal);
    while(GetIsObjectValid(oPortal))
    {
        if(GetLocalInt(oArea, AREA_FLAG_INSTANCE_BOSS))
            AssignCommand(GetModule(), DelayCommand(fDelay, ExecuteScript("_on_inst_destroy", oArea)));
        AssignCommand(GetModule(), DelayCommand(fDelay,
                      ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEAD_ELECTRICITY), oPortal)));
        AssignCommand(GetModule(), DestroyObject(oPortal, fDelay));
        oPortal = GetObjectByTag(sPortalTag, ++nNth);
    }
    AssignCommand(GetModule(), DelayCommand(fDelay, DeleteLocalInt(GetModule(), sPortalTag)));
}

void spells_CloseStargate(object oStargate, float fDelay)
{
    object oStargateEnter = GetIsObjectValid(GetLocalObject(oStargate, "STARGATE_ENTER")) ?
                            GetLocalObject(oStargate, "STARGATE_ENTER") :
                            GetLocalObject(GetLocalObject(oStargate, "STARGATE_EXIT"), "STARGATE_ENTER");
    object oStargateExit  = GetIsObjectValid(GetLocalObject(oStargate, "STARGATE_EXIT")) ?
                            GetLocalObject(oStargate, "STARGATE_EXIT") :
                            GetLocalObject(GetLocalObject(oStargate, "STARGATE_ENTER"), "STARGATE_EXIT");
    AssignCommand(GetModule(), DelayCommand(fDelay,
                               spells_CloseStargateEnter(oStargateEnter, oStargateExit)));
    AssignCommand(GetModule(), DelayCommand(fDelay,
                  ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEAD_ELECTRICITY), oStargateExit)));
    AssignCommand(GetModule(), DestroyObject(oStargateExit, 1.0 + fDelay));
}

void spells_CloseStargateEnter(object oStargateEnter, object oStargateExit)
{
    if(GetLocalObject(oStargateEnter, "STARGATE_EXIT") != oStargateExit)
        return;
    AssignCommand(oStargateEnter, DelayCommand(1.0, ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE)));
    AssignCommand(oStargateEnter, DelayCommand(1.0, spells_SetStargateOnUseScript(oStargateEnter, "_on_place_use")));
    AssignCommand(GetModule(), DelayCommand(0.0,
                  ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEAD_ELECTRICITY), oStargateEnter)));
}

void spells_SetStargateOnUseScript(object oStargate, string sScript)
{
    SetEventScript(oStargate, EVENT_SCRIPT_PLACEABLE_ON_USED, sScript);
}

int spells_GetHasTrueEffect(object oTarget, int nEffect)
{
    return GetLocalInt(oTarget, "TRUE_EFFECT_" + IntToString(nEffect));
    /*  too slow code ~15ms for following block =>
    int nCount = NWNX_Effect_GetTrueEffectCount(oTarget);
    int nIndex = 0;
    while(nIndex < nCount)
    {
        int nType = NWNX_Effect_GetTrueEffect(oTarget, nIndex).nType;
        if(nType == nEffect)
            return TRUE;
        nIndex++;
    }
    return FALSE; */
}

void spells_ChangeSpellDuration(object oTarget, int nSpellID, float fChangeFactor, int bPercentFlag = TRUE, int bUseInitialCastDuration = TRUE)
{
    effect eEff = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eEff))
    {
        struct NWNX_EffectUnpacked stUnpackedEff = NWNX_Effect_UnpackEffect(eEff);
        if (stUnpackedEff.nSpellId == nSpellID)
        {
            // get eff duration and save initial duration into sTag if sTag not used
            if(stUnpackedEff.sTag == "")
                stUnpackedEff.sTag = FloatToString(stUnpackedEff.fDuration);
            float fCreationDur = StringToFloat(stUnpackedEff.sTag);
            // calc fDiff (seconds to increase or decrease duration)
            float fDiff;
            if(bPercentFlag)
            {
                if(bUseInitialCastDuration)
                    fDiff = fCreationDur * fChangeFactor / 100.0;
                else
                    fDiff = stUnpackedEff.fDuration * fChangeFactor / 100.0;
            }
            else
                fDiff = fChangeFactor;
            // get remaining effect duration
            float fRemainingDur = IntToFloat(GetEffectDurationRemaining(eEff));
            // generate worldtime and update stUnpackedEff
            struct NWNX_Util_WorldTime stWorldTime = NWNX_Util_GetWorldTime(fRemainingDur + fDiff);
            stUnpackedEff.nExpiryCalendarDay = stWorldTime.nCalendarDay;
            stUnpackedEff.nExpiryTimeOfDay = stWorldTime.nTimeOfDay;
            // update stUnpackedEff.fDuration
            stUnpackedEff.fDuration = stUnpackedEff.fDuration + fDiff;
            // replace effect
            effect eReplaced = NWNX_Effect_PackEffect(stUnpackedEff);
            if(NWNX_Effect_ReplaceEffect(oTarget, eEff, eReplaced))
                break;
        }
        eEff = GetNextEffect(oTarget);
    }
}

effect spells_Shock()
{
    effect eSlow  = EffectRunScript("_mod_runscript", "_mod_runscript");
    effect eShock = EffectLinkEffects(EffectConfused(), EffectPacified());
    effect eLink = EffectLinkEffects(eShock, eSlow);
    eLink = HideEffectIcon(eLink);
    eLink = EffectLinkEffects(eLink, EffectIcon(EFFECT_ICON_SHOCK));
    return SetEffectSpellId(eLink, SPELL_SHOCK);
}

int CheckNearAoes(object oCaster, location lLocation, float fRadius, float fMaxCheckDist = 30.0)
{
    object oAOE = GetFirstObjectInShape(SHAPE_SPHERE, fMaxCheckDist, lLocation, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    while(GetIsObjectValid(oAOE))
    {
        float fDistance = GetDistanceBetweenLocations(lLocation, GetLocation(oAOE));
        float fAreaEffectRadius = GetLocalFloat(oAOE, "AOE_RANGE");
        object oAreaEffectOwner = GetLocalObject(oAOE, "AOE_OWNER");
        int nSpellID = GetLocalInt(oAOE, "AOE_ID");
        if(fAreaEffectRadius > 0.0 && fDistance < (fRadius + fAreaEffectRadius) * 0.75 && (GetLocalInt(oAOE, "AOE_GROUND_RULES") || !GetHasSpellEffect(nSpellID, oAreaEffectOwner)))
        {
            FloatingColorTextStringOnCreature("AoE stacking is not allowed.", TXT_COLOR_RED, oCaster, FALSE);
            return TRUE;
        }
        oAOE = GetNextObjectInShape(SHAPE_SPHERE, fMaxCheckDist, lLocation, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    }
    return FALSE;
}

int GetNearTriggers(object oCaster, location lLocation, float fDist = 16.0)
{
    object oObject = GetFirstObjectInShape(SHAPE_SPHERE, fDist, lLocation, FALSE, OBJECT_TYPE_TRIGGER | OBJECT_TYPE_DOOR | OBJECT_TYPE_WAYPOINT);
    while(GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_WAYPOINT)
        {
            string sTagRightFiveSymbols = GetStringRight(GetTag(oObject), 5);
            string sTagRightSixSymbols  = GetStringRight(GetTag(oObject), 6);
            if (sTagRightFiveSymbols == "_exit" ||
                (StringToInt(GetTokenByPosition(sTagRightSixSymbols, "_", 1)) > 0 && GetTokenByPosition(sTagRightSixSymbols, "_", 0) == "exit"))
            {
                FloatingColorTextStringOnCreature("Cast AoE near triggers is not allowed.", TXT_COLOR_RED, oCaster, FALSE);
                return 1;
            }
        }
        else if (GetIsObjectValid(GetTransitionTarget(oObject)))
        {
           FloatingColorTextStringOnCreature("Cast AoE near triggers is not allowed.", TXT_COLOR_RED, oCaster, FALSE);
           return 1;
        }
        oObject = GetNextObjectInShape(SHAPE_SPHERE, fDist, lLocation, FALSE, OBJECT_TYPE_TRIGGER | OBJECT_TYPE_DOOR | OBJECT_TYPE_WAYPOINT);
    }
    return 0;
}

void AddMarkersForAOE(object oPC, location lTarget, float fDuration, float fRadius)
{
    if(!GetIsPC(oPC) || GetIsDM(oPC)) return;
    string sPlaceble = GetPlacebleByFaction(players_GetFaction(oPC));
    // set AoE index to PC
    int iIndexAOE = GetLocalInt(oPC, "AOE_INDEX") + 1;
    int iPlayerID = players_GetPCPersistentID(oPC);
    SetLocalInt(oPC, "AOE_INDEX", iIndexAOE);
    // set local location to PC for clearing placeables during rest
    SetLocalLocation(oPC, "AOE_LOCATION_" + IntToString(iIndexAOE), lTarget);

    object oAOE_Center = ObjectPlaceSpring(sPlaceble, lTarget, fRadius, fRadius, 0.0, 0.0, 12, 1.0, 0.0, 0.0, "z",
        -1, -1, 0.0, 0.0, fDuration, "AOE_FACTION_MARKER");

    DelayCommand(0.25, MarkSpellAOE(lTarget, iPlayerID, iIndexAOE, oAOE_Center));
}

string GetPlacebleByFaction(int nFaction)
{
    string sPlaceble = "";
    switch (nFaction)
    {
        case FACTION_EMPIRE:
            sPlaceble = "plc_magiccyan";
        break;
        case FACTION_UNDERDARK:
            sPlaceble = "plc_magicred";
        break;
        case FACTION_IRON_THRONE:
            sPlaceble = "plc_magicpurple";
        break;
        case FACTION_DRAGON_CULT:
            sPlaceble = "plc_magicgreen";
        break;
    }
    return sPlaceble;
}

void MarkSpellAOE(location lTarget, int iPlayerID, int iIndexAOE, object oAOE_Center)
{
    object oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lTarget);
    if (GetIsObjectValid(oAOE))
    {
        SetLocalInt(oAOE, "AOE_PLAYER_ID", iPlayerID);
        SetLocalInt(oAOE, "AOE_INDEX", iIndexAOE);
        SetLocalObject(oAOE, "AOE_CENTER", oAOE_Center);
    }
    int i;
    for (i = 0; i<= GetLocalInt(oAOE_Center, "storetotal"); i++)
    {
        object oCircle = GetLocalObject(oAOE_Center, "store" + IntToString(i));
        SetPlotFlag(oCircle, TRUE);
        SetObjectVisualTransform(oCircle, OBJECT_VISUAL_TRANSFORM_SCALE, 0.2);
    }
}

void DestroyALLSpellMarkerPlacebles(object oCreatorAOE)
{
    int i = 1;
    int iNumberAOEs = GetLocalInt(oCreatorAOE, "AOE_INDEX");
    while(i <= iNumberAOEs)
    {
        DestroySpellMarkerPlacebles(GetLocalLocation(oCreatorAOE, "AOE_LOCATION_" + IntToString(i)), i, oCreatorAOE);
        DeleteLocalLocation(oCreatorAOE, "AOE_LOCATION_" + IntToString(i));
        i++;
    }
    SetLocalInt(oCreatorAOE, "AOE_INDEX", 0);
}

void DestroySpellMarkerPlacebles(location lTarget, int iIndexAOE, object oCreatorAOE)
{
    int     iAOE_Player_ID  = 0;
    int     iAOE_Index      = 0;
    object  oAOE_Center     = OBJECT_INVALID;

    object oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lTarget);
    if (GetIsObjectValid(oAOE))
    {
        iAOE_Player_ID  = GetLocalInt(oAOE, "AOE_PLAYER_ID");
        iAOE_Index      = GetLocalInt(oAOE, "AOE_INDEX");
    }

    int iPlayerID = players_GetPCPersistentID(oCreatorAOE);

    if ((iAOE_Player_ID == iPlayerID && iAOE_Index == iIndexAOE) || !GetIsObjectValid(oCreatorAOE))
    {
        oAOE_Center = GetLocalObject(oAOE, "AOE_CENTER");
        if (GetIsObjectValid(oAOE_Center))
        {
            int i;
            for (i = 0; i <= GetLocalInt(oAOE_Center, "storetotal"); i++)
            {
                object oCircle = GetLocalObject(oAOE_Center, "store" + IntToString(i));
                SetPlotFlag(oCircle, FALSE);
                DestroyObject(oCircle, 0.1);
            }
            SetPlotFlag(oAOE_Center, FALSE);
            DestroyObject(oAOE_Center, 0.1);
        }
    }
}

//void main() {}

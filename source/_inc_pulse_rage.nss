#include "_inc_fshop_barb"

///////////////////////////////////////////////////////////////////
//////////                  Constants                    //////////
///////////////////////////////////////////////////////////////////

const int PULSE_RAGE_TYPE_MIGHTY    = 1;
const int PULSE_RAGE_TYPE_CONFUSE   = 2;
const int PULSE_RAGE_TYPE_MURDERER  = 3;
const int PULSE_RAGE_TYPE_FEARLESS  = 4;

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// returns TRUE if barbarian has one of rage effects
int GetIsInRage(object oPC);

// returns TRUE if barbarian under defy death effect
int GetIsUnderDefyDeath(object oPC);

// calculates rage modifier
int GetRageModifier(object oPC);

// returns interval between pulse rage ticks
float GetBarbarianPulseInterval(object oPC);

// returns data string in format "<Rage_Pulse_Type>|<Rage_DC>|<Rage_Modifier>"
string GeneratePulseRageDataString(object oPC, int nRagePulseType, int nRageDC, int nRageModifier);

// applies pulse effect
void ApplyRagePulse(object oCaster, effect eRagePulse);

// remove all rages
void RemoveRageEffects(object oPC = OBJECT_SELF);

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

int GetIsInRage(object oPC)
{
    effect eLoop = GetFirstEffect(oPC);
    while(GetIsEffectValid(eLoop))
    {
        if(GetEffectSpellId(eLoop) == SPELL_BARBARIAN_RAGE_FEARLESS  ||
           GetEffectSpellId(eLoop) == SPELL_BARBARIAN_RAGE_CONFUSE   ||
           GetEffectSpellId(eLoop) == SPELL_BARBARIAN_RAGE_MIGHTY    ||
           GetEffectSpellId(eLoop) == SPELL_BARBARIAN_RAGE_MURDERER
          )
            return TRUE;
        eLoop = GetNextEffect(oPC);
    }
    return FALSE;
}

int GetIsUnderDefyDeath(object oPC)
{
    effect eLoop = GetFirstEffect(oPC);
    while(GetIsEffectValid(eLoop))
    {
        if(GetEffectSpellId(eLoop) == SPELL_BARBARIAN_DEFY_DEATH && !(GetEffectTag(eLoop) == CORMYR_SPELL_COOLDOWN_TAG))
            return TRUE;
        eLoop = GetNextEffect(oPC);
    }
    return FALSE;
}

int GetRageModifier(object oPC)
{
    return 1 + GetLevelByClass(CLASS_TYPE_BARBARIAN, oPC) / 20 +
               GetHasFeat(FEAT_MIGHTY_RAGE, oPC) +
               GetHasFeat(FEAT_EPIC_TERRIFYING_RAGE, oPC) +
               GetHasFeat(FEAT_EPIC_THUNDERING_RAGE, oPC);
}

float GetBarbarianPulseInterval(object oPC)
{
    float fCryInterval = 30.0;
    if(GetIsPC(oPC) && !GetIsDM(oPC))
    {
        int iPlayerID = players_GetPCPersistentID(oPC);
        if(iPlayerID > 0)
        {
            int iBonusIntervalLevel = GetRageBonusInterval(iPlayerID);
            if     (iBonusIntervalLevel == 1) fCryInterval = 24.0;
            else if(iBonusIntervalLevel == 2) fCryInterval = 18.0;
        }
    }
    return fCryInterval;
}

string GeneratePulseRageDataString(object oPC, int nRagePulseType, int nRageDC, int nRageModifier)
{
    return IntToString(nRagePulseType) + "|" + IntToString(nRageDC) + "|" + IntToString(nRageModifier);
}

void ApplyRagePulse(object oCaster, effect eRagePulse)
{
    if(GetArea(oCaster) == OBJECT_INVALID)
        return;

    // parse data from EffectString
    string sDataString = GetEffectString(eRagePulse, 0);
    int nRagePulseType = StringToInt(GetTokenByPosition(sDataString, "|", 0));
    int nRageDC = StringToInt(GetTokenByPosition(sDataString, "|", 1));
    int nRageModifier = StringToInt(GetTokenByPosition(sDataString, "|", 2));
    int nPulseEffectDuration = nRageModifier - 2;
    if(nPulseEffectDuration <= 0)
        return;
    // apply pulse effect
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(oCaster), TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(GetIsEnemy(oTarget, oCaster) && !GetIsDead(oTarget) &&
           !GetPlotFlag(oTarget) && !GetIsDM(oTarget) && !WillSave(oTarget, nRageDC, SAVING_THROW_TYPE_NONE, oCaster))
        {
            effect ePulse;
            effect eVis;
            switch(nRagePulseType)
            {
                case PULSE_RAGE_TYPE_MIGHTY:
                    ePulse = EffectLinkEffects(EffectSkillDecrease(SKILL_DISCIPLINE, nRageModifier), EffectSkillDecrease(SKILL_CONCENTRATION, nRageModifier));
                    eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
                break;
                case PULSE_RAGE_TYPE_CONFUSE:
                    ePulse = EffectSavingThrowDecrease(SAVING_THROW_WILL, nRageModifier);
                    eVis = EffectVisualEffect(VFX_IMP_DAZED_S);
                break;
                case PULSE_RAGE_TYPE_MURDERER:
                    ePulse = EffectSavingThrowDecrease(SAVING_THROW_FORT, nRageModifier);
                    eVis = EffectVisualEffect(VFX_IMP_DOMINATE_S);
                break;
                case PULSE_RAGE_TYPE_FEARLESS:
                    ePulse = EffectSavingThrowDecrease(SAVING_THROW_REFLEX, nRageModifier);
                    eVis = EffectVisualEffect(VFX_IMP_PULSE_COLD);
                break;
            }
            float fDelay = GetSpellEffectDelay(GetLocation(oCaster), oTarget);
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(ePulse), oTarget, RoundsToSeconds(nPulseEffectDuration)));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(oCaster), TRUE);
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_HOWL_MIND), oCaster);
}

void RemoveRageEffects(object oPC = OBJECT_SELF)
{
    effect eLoop = GetFirstEffect(oPC);
    while(GetIsEffectValid(eLoop))
    {
        int nSpellID = GetEffectSpellId(eLoop);
        if(nSpellID == SPELL_BARBARIAN_RAGE_FEARLESS  || nSpellID == SPELL_BARBARIAN_RAGE_CONFUSE   ||
           nSpellID == SPELL_BARBARIAN_RAGE_MIGHTY    || nSpellID == SPELL_BARBARIAN_RAGE_MURDERER  ||
           nSpellID == SPELL_BARBARIAN_RAGE_MURDERER  || nSpellID == SPELL_CORMYR_FEARLESS_RAGE_AC)
        {
            RemoveEffect(oPC, eLoop);
        }
        eLoop = GetNextEffect(oPC);
    }
}

//void main(){}

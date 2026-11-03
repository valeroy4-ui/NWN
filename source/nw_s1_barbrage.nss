#include "x2_i0_spells"
#include "nwnx_effect"
#include "_inc_pulse_rage"
#include "nwnx_object"

// get damage const Xd10
int GetDamageConstantFromRageModifier(int nRageMod);

// calculates rage duration
float GetRageDuration(object oPC = OBJECT_SELF);

// apply rage specific by spell ID
void ApplyRage(float fDuration, int nSpellId);


void main()
{
    object oPC = OBJECT_SELF;
    if(GetIsPC(oPC) && GetAlignmentLawChaos(oPC) != ALIGNMENT_CHAOTIC)
    {
        SendMessageToPC(oPC, "Rage is available only to characters with a chaotic alignment.");
        return;
    }
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if(GetIsObjectValid(oWeapon) && !GetMeleeWeapon(oWeapon))
    {
        SendMessageToPC(oPC, "Rage is available only to characters with a melee weapons.");
        return;
    }
    if(GetAbilityScore(oPC, ABILITY_DEXTERITY) > GetAbilityScore(oPC, ABILITY_STRENGTH))
    {
        SendMessageToPC(oPC, "Rage is not available for dex builds.");
        return;
    }
    int nRage = GetSpellId();
    int bRageOk = FALSE;
    float fDuration = GetRageDuration(oPC);
    SendMessageToPC(oPC, "Rage duration: " + FloatToString(fDuration/6, 0, 0) + " rounds.");

    string sMessageFailed = "Your character already has effects of this rage.";
    switch(nRage)
    {
        case SPELL_BARBARIAN_RAGE_MIGHTY:
            if(!GetHasSpellEffect(SPELL_BARBARIAN_RAGE_MIGHTY, oPC))
            {
                RemoveRageEffects();
                ApplyRage(fDuration, SPELL_BARBARIAN_RAGE_MIGHTY);
                bRageOk = TRUE;
            }
            break;
        case SPELL_BARBARIAN_RAGE_CONFUSE:
            if(!GetHasSpellEffect(SPELL_BARBARIAN_RAGE_CONFUSE, oPC))
            {
                RemoveRageEffects();
                ApplyRage(fDuration, SPELL_BARBARIAN_RAGE_CONFUSE);
                bRageOk = TRUE;
            }
            break;
        case SPELL_BARBARIAN_RAGE_MURDERER:
            if(!GetHasSpellEffect(SPELL_BARBARIAN_RAGE_MURDERER, oPC))
            {
                RemoveRageEffects();
                ApplyRage(fDuration, SPELL_BARBARIAN_RAGE_MURDERER);
                bRageOk = TRUE;
            }
            break;
        case SPELL_BARBARIAN_RAGE_FEARLESS:
            if(!GetHasSpellEffect(SPELL_BARBARIAN_RAGE_FEARLESS, oPC))
            {
                RemoveRageEffects();
                ApplyRage(fDuration, SPELL_BARBARIAN_RAGE_FEARLESS);
                bRageOk = TRUE;
            }
            break;
        default:
            if(!GetIsPC(oPC) || GetIsDMPossessed(oPC))
            {
                RemoveRageEffects();
                switch(d4())
                {
                        case 1: ApplyRage(fDuration, SPELL_BARBARIAN_RAGE_FEARLESS); break;
                        case 2: ApplyRage(fDuration, SPELL_BARBARIAN_RAGE_MURDERER); break;
                        case 3: ApplyRage(fDuration, SPELL_BARBARIAN_RAGE_CONFUSE); break;
                        case 4: ApplyRage(fDuration, SPELL_BARBARIAN_RAGE_MIGHTY); break;
                }
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectHaste()), oPC, fDuration);
                bRageOk = TRUE;
            }
            else
                SendMessageToPC(oPC, "Use the subfeats Luke!");
            break;
    }
    if(!bRageOk)
    {
        SendMessageToPC(oPC, sMessageFailed);
        return;
    }
    else
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE), oPC);
        switch(d4())
        {
            case 1: PlayVoiceChat(VOICE_CHAT_BATTLECRY1, oPC); break;
            case 2: PlayVoiceChat(VOICE_CHAT_BATTLECRY2, oPC); break;
            case 3: PlayVoiceChat(VOICE_CHAT_BATTLECRY3, oPC); break;
            case 4: PlayVoiceChat(VOICE_CHAT_TAUNT, oPC); break;
        }
    }
}

int GetDamageConstantFromRageModifier(int nRageMod)
{
    switch(nRageMod)
    {
        case 1: return DAMAGE_BONUS_1d10;
        case 2: return DAMAGE_BONUS_2d10;
        case 3: return 65 /* 3d10 */;
        case 4: return 66 /* 4d10 */;
        case 5: return 67 /* 5d10 */;
        case 6: return 68 /* 6d10 */;
        case 7: return 69 /* 7d10 */;
    }
    return DAMAGE_BONUS_1d10;
}

float GetRageDuration(object oPC = OBJECT_SELF)
{
    float fDuration;
    effect eRage = GetFirstEffect(oPC);
    while(GetIsEffectValid(eRage))
    {
        if(GetEffectDurationType(eRage) == DURATION_TYPE_TEMPORARY && GetEffectSubType(eRage) == SUBTYPE_EXTRAORDINARY)
        {
            if( GetEffectSpellId(eRage) == SPELL_BARBARIAN_RAGE_FEARLESS ||
                GetEffectSpellId(eRage) == SPELL_BARBARIAN_RAGE_CONFUSE ||
                GetEffectSpellId(eRage) == SPELL_BARBARIAN_RAGE_MIGHTY ||
                GetEffectSpellId(eRage) == SPELL_BARBARIAN_RAGE_MURDERER)
            {
               fDuration = IntToFloat(GetEffectDurationRemaining(eRage));
               break;
            }
        }
        eRage = GetNextEffect(oPC);
    }
    fDuration = (fDuration < 6.0) ? RoundsToSeconds(GetRageModifier(oPC) * GetAbilityModifier(ABILITY_CONSTITUTION, oPC)) : fDuration;
    return fDuration;
}

void ApplyRage(float fDuration, int nSpellId)
{
    int nRageModifier = GetRageModifier(OBJECT_SELF);
    effect eRage = EffectAttackIncrease(nRageModifier);
    eRage = EffectLinkEffects(EffectAbilityIncrease(ABILITY_STRENGTH, nRageModifier * 2), eRage);
    eRage = EffectLinkEffects(EffectAbilityIncrease(ABILITY_DEXTERITY, nRageModifier * 2), eRage);
    eRage = EffectLinkEffects(EffectAbilityIncrease(ABILITY_CONSTITUTION, nRageModifier * 2), eRage);
    float fRagePulseInterval = GetBarbarianPulseInterval(OBJECT_SELF);
    int nRageDC = GetHitDice(OBJECT_SELF) / 2 + nRageModifier - GetLevelByClass(CLASS_TYPE_PALEMASTER) +
                  GetSkillRank(SKILL_INTIMIDATE, OBJECT_SELF) / 5 + GetRageBonusDC(players_GetPCPersistentID(OBJECT_SELF));
    effect eRagePulse;
    //ServerShout(IntToString(nRageModifier));
    switch(nSpellId)
    {
        case SPELL_BARBARIAN_RAGE_MIGHTY:
            eRage = EffectLinkEffects(EffectDamageIncrease(GetDamageConstantFromRageModifier(nRageModifier), DAMAGE_TYPE_MAGICAL), eRage);
            eRage = EffectLinkEffects(EffectSavingThrowIncrease(SAVING_THROW_FORT, nRageModifier), eRage);
            eRagePulse = EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", fRagePulseInterval,
                                         GeneratePulseRageDataString(OBJECT_SELF, PULSE_RAGE_TYPE_MIGHTY, nRageDC, nRageModifier));
            eRage = EffectLinkEffects(eRagePulse, eRage);
            eRage = EffectLinkEffects(EffectIcon(EFFECT_ICON_SPELL_BARBARIAN_RAGE_MIGHTY), HideEffectIcon(eRage));
        break;
        case SPELL_BARBARIAN_RAGE_CONFUSE:
            eRage = EffectLinkEffects(EffectDamageIncrease(GetDamageConstantFromRageModifier(nRageModifier), DAMAGE_TYPE_COLD), eRage);
            eRagePulse = EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", fRagePulseInterval,
                                         GeneratePulseRageDataString(OBJECT_SELF, PULSE_RAGE_TYPE_CONFUSE, nRageDC, nRageModifier));
            eRage = EffectLinkEffects(eRagePulse, eRage);
            eRage = EffectLinkEffects(EffectIcon(EFFECT_ICON_SPELL_BARBARIAN_RAGE_CONFUSE), HideEffectIcon(eRage));
        break;
        case SPELL_BARBARIAN_RAGE_MURDERER:
            eRage = EffectLinkEffects(EffectDamageIncrease(GetDamageConstantFromRageModifier(nRageModifier), DAMAGE_TYPE_FIRE), eRage);
            eRagePulse = EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", fRagePulseInterval,
                                         GeneratePulseRageDataString(OBJECT_SELF, PULSE_RAGE_TYPE_MURDERER, nRageDC, nRageModifier));
            eRage = EffectLinkEffects(eRagePulse, eRage);
            eRage = EffectLinkEffects(EffectIcon(EFFECT_ICON_SPELL_BARBARIAN_RAGE_MURDERER), HideEffectIcon(eRage));
        break;
        case SPELL_BARBARIAN_RAGE_FEARLESS:
        {
            eRage = EffectLinkEffects(EffectDamageIncrease(GetDamageConstantFromRageModifier(nRageModifier), DAMAGE_TYPE_NEGATIVE), eRage);
            eRage = EffectLinkEffects(EffectSavingThrowIncrease(SAVING_THROW_WILL, nRageModifier), eRage);
            //eRage = EffectLinkEffects(EffectACIncrease((nRageModifier - GetLevelByClass(CLASS_TYPE_PALEMASTER)) * 2, AC_SHIELD_ENCHANTMENT_BONUS), eRage);
            eRagePulse = EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", fRagePulseInterval,
                                         GeneratePulseRageDataString(OBJECT_SELF, PULSE_RAGE_TYPE_FEARLESS, nRageDC, nRageModifier));
            eRage = EffectLinkEffects(eRagePulse, eRage);
            eRage = EffectLinkEffects(EffectIcon(EFFECT_ICON_SPELL_BARBARIAN_RAGE_FEARLESS), HideEffectIcon(eRage));
            // apply Shield AC as separate effect
            if(!(MatchShield(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, OBJECT_SELF)) ||
                 GetLevelByClass(CLASS_TYPE_MONK, OBJECT_SELF) > 2))
            {
                effect eShield = EffectACIncrease((nRageModifier - GetLevelByClass(CLASS_TYPE_PALEMASTER)) * 2, AC_SHIELD_ENCHANTMENT_BONUS);
                eShield = SetEffectSpellId(eShield, SPELL_CORMYR_FEARLESS_RAGE_AC);
                eShield = HideEffectIcon(eShield);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eShield), OBJECT_SELF, fDuration);
            }
        }
        break;
    }
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eRage), OBJECT_SELF, fDuration);
}




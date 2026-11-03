// executes on devast event
#include "nwnx_weapon"
#include "_inc_colortext"
#include "_inc_runes"
#include "_inc_fshop_spell"
#include "_inc_players"

void main()
{
    object oAttacker = OBJECT_SELF;
    struct NWNX_Weapon_DevastatingCriticalEvent_Data data = NWNX_Weapon_GetDevastatingCriticalEventData();
    object oWeapon = data.oWeapon;
    object oTarget = data.oTarget;

    NWNX_Weapon_BypassDevastatingCritical();

    // if immunity no devast
    if(GetLocalInt(oTarget, "IHAVEDEVASTIMMUNITY"))
        return;
    else if (GetIsObjectValid(oAttacker) && GetIsObjectValid(oTarget) && GetIsObjectValid(oWeapon))
    {
        int nDC = 10 + GetHitDice(oAttacker) / 2 + GetAbilityModifier(ABILITY_STRENGTH, oAttacker) +
                  runes_GetHasRune(oAttacker, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_III);
        if(GetLevelByClass(CLASS_TYPE_FIGHTER, oAttacker) >= 21)
            nDC += GetCustomOnhitFameBonus(oAttacker, SPELL_DEVASTATING_CRITICAL_1);
        int nFort = players_GetRealSavingThrowValue(oTarget, SAVING_THROW_FORT);
        int nRoll = d20();
        int nFortSave = nFort + nRoll;

        effect eDevast;

        float fRunicExtraDamage = 0.0;
        if     (runes_GetHasRune(oAttacker, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_II))
            fRunicExtraDamage = RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_II_VALUE;
        else if(runes_GetHasRune(oAttacker, RUNE_TYPE_EPIC_COMBAT, RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_I))
            fRunicExtraDamage = RUNE_EPIC_COMBAT_DEVASTATING_CRITICAL_I_VALUE;
        eDevast = EffectLinkEffects(EffectDamage(FloatToInt(GetMaxHitPoints(oTarget) * (0.5 + fRunicExtraDamage))), EffectBlindness());

        if(nFort < nDC)
            eDevast = SupernaturalEffect(EffectDeath());  // death ward dont works

        if (nFortSave >= nDC && nRoll != 1)
        {
            SendMessageToPC(oAttacker,  "Devastating Critical Hit on " + GetName(oTarget) + " failed. Fortitude Save :" +
                                        ColorText("*success*", TXT_COLOR_GREEN_L) + " : (" + IntToString(nRoll) + " + " +
                                        IntToString(nFort) + " = " + IntToString(nFortSave) + " vs. DC: " + IntToString(nDC) + ")");
            if (GetIsPC(oTarget)) SendMessageToPC(oTarget,
                                        "Devastating Critical Hit : Fortitude Save : " + ColorText("*success*", TXT_COLOR_GREEN_L) +
                                        " : ("+IntToString(nRoll) + " + " + IntToString(nFort) + " = "+IntToString(nFortSave) + " vs. DC: "
                                        + IntToString(nDC) + ")");
        }
        else
        {
            //generic_PlayAudioStreamForPlayerArea(oAttacker, "mus_devast", AUDIOSTREAM_IDENTIFIER_2);
            FloatingColorTextStringOnCreature("Devastating Critical Hit!", TXT_COLOR_SPECIAL_HIT, oAttacker, TRUE);
            SendMessageToPC(oAttacker, "Devastating Critical Hit on " + GetName(oTarget) + " success. Fortitude Save :" +
                                       ColorText("*failure*", TXT_COLOR_RED) + " : (" + IntToString(nRoll) + " + "      +
                                       IntToString(nFort) + " = " + IntToString(nFortSave) + " vs. DC: " + IntToString(nDC) + ")");
            if (GetIsPC(oTarget))
            {
                FloatingColorTextStringOnCreature("Devastating Critical Hit!", TXT_COLOR_SPECIAL_HIT, oTarget, TRUE);
                SendMessageToPC(oTarget, "Devastating Critical Hit : Fortitude Save : " + ColorText("*failure*", TXT_COLOR_RED)  +
                                         " : (" + IntToString(nRoll) + " + " + IntToString(nFort)+" = " + IntToString(nFortSave) +
                                         " vs. DC: " + IntToString(nDC) + ")");
            }
            DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDevast, oTarget, 6.0));
        }
    }
}


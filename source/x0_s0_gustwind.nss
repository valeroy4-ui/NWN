#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_generic"

// TRUE for local Windows tests without NWNX.
// FALSE on the server to restore original feedback/audio helpers.
const int GUST_LOCAL_WINDOWS_TEST = TRUE;

int GUST_HasEarthDomain(object oCaster)
{
    return GetDomain(oCaster, 1, CLASS_TYPE_CLERIC) == DOMAIN_EARTH
        || GetDomain(oCaster, 2, CLASS_TYPE_CLERIC) == DOMAIN_EARTH;
}

int GUST_GetFocusBonus(object oCaster)
{
    int nBonus = 0;

    if (GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION, oCaster))
        nBonus += 1;

    if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION, oCaster))
        nBonus += 2;

    if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION, oCaster))
        nBonus += 3;

    return nBonus;
}

float GUST_GetRadius(object oCaster)
{
    if (GetHasFeat(FEAT_EPIC_SPELL_FOCUS_CONJURATION, oCaster))
        return 13.3;

    if (GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION, oCaster))
        return 10.0;

    if (GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION, oCaster))
        return 8.0;

    return 6.7;
}

int GUST_GetBardBonus(int nClass, int nCL)
{
    if (nClass != CLASS_TYPE_BARD || nCL <= 29)
        return 0;

    int nBonus = nCL - 29;

    if (nBonus > 11)
        nBonus = 11;

    return nBonus;
}

int GUST_GetDomainBonus(object oCaster, int nClass, int nCL)
{
    if (nClass != CLASS_TYPE_CLERIC
        || !GUST_HasEarthDomain(oCaster)
        || nCL <= 23)
        return 0;

    int nBonus = (nCL - 23) / 2;

    if (nBonus > 8)
        nBonus = 8;

    return nBonus;
}

void main()
{
    spell.Range = 6.7;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
        return;

    // Initialize only once.
    spellsDeclareMajorVariables();

    int nClass = GetLastSpellCastClass();
    int nCL = spell.Level;
    int bEarth = GUST_HasEarthDomain(spell.Caster);

    // Restrict ordinary spellbook casts. Preserve item casting.
    if (!GetIsObjectValid(spell.Item))
    {
        if (nClass == CLASS_TYPE_CLERIC && !bEarth)
        {
            if (GetIsPC(spell.Caster))
                SendMessageToPC(spell.Caster,
                    "Gust of Wind: Earth domain required for Cleric.");

            return;
        }

        if (nClass != CLASS_TYPE_DRUID
            && nClass != CLASS_TYPE_CLERIC
            && nClass != CLASS_TYPE_SORCERER
            && nClass != CLASS_TYPE_BARD)
        {
            if (GetIsPC(spell.Caster))
                SendMessageToPC(spell.Caster,
                    "Gust of Wind: this spellcasting class is not allowed.");

            return;
        }
    }

    int nWisMod = GetAbilityModifier(ABILITY_WISDOM, spell.Caster);
    int nChaMod = GetAbilityModifier(ABILITY_CHARISMA, spell.Caster);
    int nAbilityMod = nWisMod;

    if (nChaMod > nAbilityMod)
        nAbilityMod = nChaMod;

    int nFocusBonus = GUST_GetFocusBonus(spell.Caster);
    int nBardBonus = GUST_GetBardBonus(nClass, nCL);
    int nDomainBonus = GUST_GetDomainBonus(
        spell.Caster, nClass, nCL);

        int nDruidBonus = 0;
    if (nClass == CLASS_TYPE_DRUID && nCL > 23)
    {
        nDruidBonus = (nCL - 23) / 2;

        if (nDruidBonus > 8)
            nDruidBonus = 8;
    }

    int nSorcBonus = 0;
    if (nClass == CLASS_TYPE_SORCERER && nCL > 29)
    {
        nSorcBonus = nCL - 29;

        if (nSorcBonus > 11)
            nSorcBonus = 11;
    }

    spell.DC = 10 + nAbilityMod + 3 + nFocusBonus
        + nDruidBonus + nDomainBonus + nBardBonus + nSorcBonus;

    spell.Range = GUST_GetRadius(spell.Caster);
    spell.SavingThrow = SAVING_THROW_REFLEX;

        if (GetIsPC(spell.Caster))
        {
        SetSpellTargetingData(
            spell.Caster,
            SPELL_GUST_OF_WIND,
            SPELL_TARGETING_SHAPE_SPHERE,
            spell.Range,
            0.0,
            StringToInt(Get2DAString(
                "spells", "TargetFlags", SPELL_GUST_OF_WIND)));

        SendMessageToPC(spell.Caster,
            "GUST PREVIEW v2: radius="
            + FloatToString(spell.Range, 1, 1)
            + " epic="
            + IntToString(GetHasFeat(
                FEAT_EPIC_SPELL_FOCUS_CONJURATION, spell.Caster)));
    }

    if (GetIsPC(spell.Caster))
    {
        SendMessageToPC(spell.Caster,
            "Gust of Wind setup: ID=" + IntToString(spell.Id)
            + " School=" + Get2DAString("spells", "School", spell.Id)
            + " Druid=" + Get2DAString("spells", "Druid", spell.Id)
            + " Cleric=" + Get2DAString("spells", "Cleric", spell.Id)
            + " Bard=" + Get2DAString("spells", "Bard", spell.Id)
            + " Wiz_Sorc=" + Get2DAString("spells", "Wiz_Sorc", spell.Id)
            + " Range=" + Get2DAString("spells", "Range", spell.Id));

        SendMessageToPC(spell.Caster,
            "Gust of Wind DC: Class=" + IntToString(nClass)
            + " CL=" + IntToString(nCL)
            + " EarthDomain=" + IntToString(bEarth)
            + " WIS=" + IntToString(nWisMod)
            + " CHA=" + IntToString(nChaMod)
            + " SpellLevel=3 Focus=" + IntToString(nFocusBonus)
            + " Druid=" + IntToString(nDruidBonus)
            + " Domain=" + IntToString(nDomainBonus)
            + " Bard=" + IntToString(nBardBonus)
            + " Sorc=" + IntToString(nSorcBonus)
            + " DC=" + IntToString(spell.DC)
            + " radius=" + FloatToString(spell.Range, 1, 1)
            + "m; duration=random 6 or 12 sec.");
    }

    effect eExplode = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_WIND);

    ApplyEffectAtLocation(
        DURATION_TYPE_INSTANT, eExplode, spell.Loc);

    int bAlarm = FALSE;
    object oAlarmTarget;

    object oTarget = GetFirstObjectInShape(
        SHAPE_SPHERE, spell.Range, spell.Loc, TRUE,
        OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR
        | OBJECT_TYPE_AREA_OF_EFFECT);

    while (GetIsObjectValid(oTarget))
    {
        if (GetObjectType(oTarget) == OBJECT_TYPE_AREA_OF_EFFECT)
        {
            // Preserve the original broad AoE removal rule.
            if (FindSubString(GetTag(oTarget), "VFX_PER_") != -1)
            {
                object oCreator = GetAreaOfEffectCreator(oTarget);

                if (GUST_LOCAL_WINDOWS_TEST)
                    FloatingTextStringOnCreature(
                        "AoE dispelled", spell.Caster, FALSE);
                else
                    FloatingColorTextStrRefOnCreature(
                        100929, TXT_COLOR_GREEN_L, spell.Caster);

                DestroySpellMarkerPlacebles(
                    GetLocation(oTarget),
                    GetLocalInt(oTarget, "AOE_INDEX"),
                    oCreator);

                DestroyObject(oTarget);
            }
        }
        else if (spellsIsTarget(
            oTarget, spell.TargetType, spell.Caster))
        {
            SignalEvent(oTarget,
                EventSpellCastAt(spell.Caster, spell.Id));

            float fDelay = GetDistanceBetweenLocations(
                spell.Loc, GetLocation(oTarget)) / 20.0;

            // Preserve unlocked-door interaction.
            if (GetObjectType(oTarget) == OBJECT_TYPE_DOOR)
            {
                if (!GetLocked(oTarget))
                {
                    if (!GetIsOpen(oTarget))
                        AssignCommand(oTarget,
                            ActionPlayAnimation(ANIMATION_DOOR_OPEN1));
                    else
                        AssignCommand(oTarget,
                            ActionPlayAnimation(ANIMATION_DOOR_CLOSE));
                }
            }

            if (!MyResistSpell(spell.Caster, oTarget, fDelay)
                && !MySavingThrow(
                    SAVING_THROW_REFLEX,
                    oTarget,
                    spell.DC,
                    SAVING_THROW_TYPE_NONE,
                    spell.Caster,
                    fDelay))
            {
                float fDuration = RoundsToSeconds(d2());

                ApplyEffectToObject(
                    DURATION_TYPE_TEMPORARY,
                    EffectKnockdown(),
                    oTarget,
                    fDuration);

                DelayCommand(fDelay, ApplyEffectToObject(
                    DURATION_TYPE_INSTANT, eVis, oTarget));

                if (GetIsPC(spell.Caster))
                    SendMessageToPC(spell.Caster,
                        "Gust of Wind: " + GetName(oTarget)
                        + " knockdown attempted; duration="
                        + FloatToString(fDuration, 1, 1)
                        + " sec.");

                if (GetIsPC(oTarget))
                {
                    bAlarm = TRUE;
                    oAlarmTarget = oTarget;
                }
            }
        }

        oTarget = GetNextObjectInShape(
            SHAPE_SPHERE, spell.Range, spell.Loc, TRUE,
            OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR
            | OBJECT_TYPE_AREA_OF_EFFECT);
    }

    if (bAlarm && !GUST_LOCAL_WINDOWS_TEST)
        generic_PlayAudioStreamForPlayerArea(
            oAlarmTarget, "mus_nicecatch");

    // Cooldown belongs to the separate spellhook.
}

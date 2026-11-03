#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "_inc_spells"
#include "_inc_generic"
#include "_inc_fshop_spell"

const float EQ_RADIUS = 10.0;
const float EQ_DURATION = 6.0;

// TRUE: local Windows test without NWNX.
// FALSE: server, original faction and Fame Shop functions.
const int EQ_LOCAL_WINDOWS_TEST = FALSE;

// Local mode only:
// -1 = read EARTHQUAKE_LVL cache.
// 0..3 = simulate the selected Fame Shop bonus.
const int EQ_LOCAL_FAME_OVERRIDE = -1;

// Original ability selection: CON is not included.
int EQ_GetMainAbility(object oTarget)
{
    int nAbility = ABILITY_STRENGTH;
    int nMaximum = 0;
    int nValue = GetAbilityModifier(ABILITY_STRENGTH, oTarget);

    if (nValue > nMaximum)
    {
        nMaximum = nValue;
        nAbility = ABILITY_STRENGTH;
    }

    nValue = GetAbilityModifier(ABILITY_DEXTERITY, oTarget);
    if (nValue > nMaximum)
    {
        nMaximum = nValue;
        nAbility = ABILITY_DEXTERITY;
    }

    nValue = GetAbilityModifier(ABILITY_INTELLIGENCE, oTarget);
    if (nValue > nMaximum)
    {
        nMaximum = nValue;
        nAbility = ABILITY_INTELLIGENCE;
    }

    nValue = GetAbilityModifier(ABILITY_WISDOM, oTarget);
    if (nValue > nMaximum)
    {
        nMaximum = nValue;
        nAbility = ABILITY_WISDOM;
    }

    nValue = GetAbilityModifier(ABILITY_CHARISMA, oTarget);
    if (nValue > nMaximum)
        nAbility = ABILITY_CHARISMA;

    return nAbility;
}

string EQ_AbilityName(int nAbility)
{
    if (nAbility == ABILITY_STRENGTH) return "STR";
    if (nAbility == ABILITY_DEXTERITY) return "DEX";
    if (nAbility == ABILITY_INTELLIGENCE) return "INT";
    if (nAbility == ABILITY_WISDOM) return "WIS";

    return "CHA";
}

int EQ_HasEarthDomain(object oCaster)
{
    return GetDomain(oCaster, 1, CLASS_TYPE_CLERIC) == DOMAIN_EARTH
        || GetDomain(oCaster, 2, CLASS_TYPE_CLERIC) == DOMAIN_EARTH;
}

int EQ_HasFreedom(object oTarget)
{
    if (GetHasSpellEffect(SPELL_FREEDOM_OF_MOVEMENT, oTarget))
        return TRUE;

    int nSlot = 0;

    while (nSlot < NUM_INVENTORY_SLOTS)
    {
        object oItem = GetItemInSlot(nSlot, oTarget);

        if (GetIsObjectValid(oItem)
            && GetItemHasItemProperty(
                oItem, ITEM_PROPERTY_FREEDOM_OF_MOVEMENT))
        {
            return TRUE;
        }

        nSlot++;
    }

    return FALSE;
}

void EQ_Report(object oCaster, object oTarget, string sMessage)
{
    if (GetIsPC(oCaster))
        SendMessageToPC(oCaster, sMessage);

    if (GetIsPC(oTarget) && oTarget != oCaster)
        SendMessageToPC(oTarget, sMessage);
}

int EQ_AreAllies(object oCaster, object oTarget)
{
    if (!EQ_LOCAL_WINDOWS_TEST)
        return players_GetFactionsEqual(oCaster, oTarget);

    int nCasterFaction = GetLocalInt(oCaster, "FACTION");
    int nTargetFaction = GetLocalInt(oTarget, "FACTION");

    if (nCasterFaction != FACTION_UNKNOWN
        && nTargetFaction != FACTION_UNKNOWN)
    {
        return nCasterFaction == nTargetFaction;
    }

    return GetFactionEqual(oCaster, oTarget);
}

int EQ_GetShopBonus(object oCaster, int nSpellId)
{
    int nBonus;

    if (!EQ_LOCAL_WINDOWS_TEST)
        nBonus = GetSpellUpgradeLevel(oCaster, nSpellId);
    else if (EQ_LOCAL_FAME_OVERRIDE >= 0)
        nBonus = EQ_LOCAL_FAME_OVERRIDE;
    else
        nBonus = GetLocalInt(oCaster, "EARTHQUAKE_LVL");

    if (nBonus < 0) nBonus = 0;
    if (nBonus > 3) nBonus = 3;

    return nBonus;
}

void main()
{
    spell.Range = EQ_RADIUS;
    spell.SavingThrow = SAVING_THROW_NONE;

    if (!X2PreSpellCastCode()) return;

    spellsDeclareMajorVariables();

    spell.Range = EQ_RADIUS;
    spell.Loc = GetLocation(spell.Caster);
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.DC = 0;
    spell.DamageCap = 20;
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_BLUDGEONING;

    int nCL = spell.Level;
    int nClass = GetLastSpellCastClass();

    if (nClass == CLASS_TYPE_INVALID)
        nClass = spell.Class;

    spell.Class = nClass;

    int bEarth = EQ_HasEarthDomain(spell.Caster);

    int bEnhanced = !GetIsObjectValid(spell.Item) && nCL >= 30
        && (nClass == CLASS_TYPE_DRUID
            || (nClass == CLASS_TYPE_CLERIC && bEarth));

    int nExtraLevels = nCL - 30;
    if (nExtraLevels < 0) nExtraLevels = 0;

    int nDamageCL = nCL;
    if (nDamageCL > spell.DamageCap)
        nDamageCL = spell.DamageCap;

    int nShop = 0;
    int bShopRead = FALSE;

    // Future glyph integration.
    int nGlyph = 0;

    if (GetLocalInt(spell.Caster, "EARTHQUAKE_GLYPH_CHANCE") == 1)
        nGlyph = 5;

    // Whole-area upgrade and CDR rune are not active.
    // Cooldown will be handled by the separate spellhook.

    if (GetIsPC(spell.Caster))
    {
        SendMessageToPC(spell.Caster,
            "Earthquake setup: ID=" + IntToString(spell.Id)
            + " School=" + Get2DAString("spells", "School", spell.Id)
            + " Cleric=" + Get2DAString("spells", "Cleric", spell.Id)
            + " Druid=" + Get2DAString("spells", "Druid", spell.Id)
            + " Range=" + Get2DAString("spells", "Range", spell.Id)
            + " MetaMagic=" + Get2DAString("spells", "MetaMagic", spell.Id)
            + " Timeout(table)="
            + Get2DAString("spells", "Timeout", spell.Id));

        SendMessageToPC(spell.Caster,
            "Earthquake: LocalWindowsTest="
            + IntToString(EQ_LOCAL_WINDOWS_TEST)
            + " Class=" + IntToString(nClass)
            + " CL=" + IntToString(nCL)
            + " EarthDomain=" + IntToString(bEarth)
            + " Enhanced=" + IntToString(bEnhanced)
            + " GlyphBonus=" + IntToString(nGlyph)
            + " ShopOverride=" + IntToString(EQ_LOCAL_FAME_OVERRIDE)
            + "; FameShop checked on allied knockdown"
            + "; radius=10m; Save=none; DC=none; friendly fire=ON.");
    }

    ApplyEffectAtLocation(
        DURATION_TYPE_INSTANT,
        EffectVisualEffect(PRCVFX_FNF_EARTHQUAKE),
        spell.Loc);

    object oTarget = GetFirstObjectInShape(
        SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);

    while (GetIsObjectValid(oTarget))
    {
        if (oTarget != spell.Caster && !GetIsDead(oTarget))
        {
            EQ_Report(spell.Caster, oTarget,
                "Earthquake target: " + GetName(oTarget)
                + " Plot=" + IntToString(GetPlotFlag(oTarget)));

            SignalEvent(oTarget,
                EventSpellCastAt(spell.Caster, spell.Id, TRUE));

            if (EQ_HasFreedom(oTarget))
            {
                EQ_Report(spell.Caster, oTarget,
                    "Earthquake: " + GetName(oTarget)
                    + " has Freedom of Movement: immune to all spell effects.");

                ApplyEffectToObject(
                    DURATION_TYPE_INSTANT,
                    EffectVisualEffect(VFX_IMP_GLOBE_USE),
                    oTarget);
            }
            else if (!MyResistSpell(spell.Caster, oTarget))
            {
                int bAlly = EQ_AreAllies(spell.Caster, oTarget);
                float fDuration = EQ_DURATION;

                int nAbility = EQ_GetMainAbility(oTarget);
                int nChance = 10 + nGlyph;

                if (bEnhanced)
                {
                    if (nAbility == ABILITY_DEXTERITY)
                        nChance += 2 * nExtraLevels;
                    else if (nAbility == ABILITY_STRENGTH)
                        nChance += nExtraLevels;
                }

                if (nChance > 100) nChance = 100;

                int nRoll = d100();
                string sResult = "miss";

                if (nRoll <= nChance)
                {
                    if (GetIsImmune(
                        oTarget, IMMUNITY_TYPE_KNOCKDOWN, spell.Caster))
                    {
                        sResult = "hit; knockdown immunity";
                    }
                    else
                    {
                        if (bAlly)
                        {
                            if (!bShopRead)
                            {
                                nShop = EQ_GetShopBonus(
                                    spell.Caster, spell.Id);

                                bShopRead = TRUE;
                            }

                            fDuration = EQ_DURATION - IntToFloat(nShop);
                        }

                        ApplyEffectToObject(
                            DURATION_TYPE_TEMPORARY,
                            EffectKnockdown(),
                            oTarget,
                            fDuration);

                        effect eShake = EffectLinkEffects(
                            EffectVisualEffect(VFX_IMP_PULSE_NATURE),
                            EffectVisualEffect(VFX_FNF_SCREEN_SHAKE2));

                        ApplyEffectToObject(
                            DURATION_TYPE_INSTANT, eShake, oTarget);

                        sResult = "hit; knockdown attempted";
                    }
                }

                string sSlow = "none";

                if (bEnhanced && !bAlly)
                {
                    ApplyEffectToObject(
                        DURATION_TYPE_TEMPORARY,
                        EffectMovementSpeedDecrease(25),
                        oTarget,
                        fDuration);

                    sSlow = "25% attempted";
                }

                int nDamage = MaximizeOrEmpower(
                    spell.Dice, nDamageCL, spell.Meta);

                if (nDamage > 0)
                {
                    ApplyEffectToObject(
                        DURATION_TYPE_INSTANT,
                        EffectDamage(nDamage, spell.DamageType),
                        oTarget);

                    ApplyEffectToObject(
                        DURATION_TYPE_INSTANT,
                        EffectVisualEffect(VFX_IMP_HEAD_NATURE),
                        oTarget);
                }

                EQ_Report(spell.Caster, oTarget,
                    "Earthquake: " + GetName(oTarget)
                    + " main=" + EQ_AbilityName(nAbility)
                    + " chance=" + IntToString(nChance) + "%"
                    + " d100=" + IntToString(nRoll) + " -> " + sResult
                    + "; ally=" + IntToString(bAlly)
                    + " duration=" + FloatToString(fDuration, 1, 1)
                    + " sec; slow=" + sSlow
                    + "; damageRoll=" + IntToString(nDamage)
                    + " bludgeoning.");
            }
        }

        oTarget = GetNextObjectInShape(
            SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}

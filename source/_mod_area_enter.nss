#include "_inc_telegraph"
#include "_inc_factions"
#include "_inc_areas"
#include "_inc_death"

void main()
{
    object oPC   = GetEnteringObject();
    object oArea = OBJECT_SELF;

    if (!GetIsPC(oPC) || GetIsDM(oPC)) return;

    int iPCID = players_GetPCPersistentID(oPC);
    if (iPCID <= 0) return;

    string sAreaRes = GetResRef(oArea);
    int iPCFaction  = players_GetFaction(oPC);

    // open minimap
    ExploreAreaForPlayer(oArea, oPC);

    // camera fix
    object oDestination = GetLocalObject(oPC, "CAMERA_FACING_FIX");
    if (GetIsObjectValid(oDestination))
    {
        effect eCameraFix = ExtraordinaryEffect(SetEffectSpellId(EffectRunScript("","","_mod_runscript",0.15), SPELL_CAMERA_FACING_FIX));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCameraFix, oPC, DURATION_SERVER_SESSION);
    }

    // fugue godmode
    int bGodMode = GetLocalInt(oPC, "GODMODE_ON");
    SetImmortal(oPC, (sAreaRes == CONST_AREA_ABYSS_RESREF || bGodMode));

    // true seeing in epic loot area
    if (sAreaRes == CONST_AREA_EPIC_LOOT_RESREF)
    {
        effect eTrueSeeing = ExtraordinaryEffect(SetEffectSpellId(EffectTrueSeeing(), SPELL_EPIC_LOOT_AREA_TRUESEEING));
        AssignCommand(oPC, DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTrueSeeing, oPC, DURATION_SERVER_SESSION)));
    }

    // death check
    if (death_GetDeadFlag(iPCID) > 0 && sAreaRes != CONST_AREA_ABYSS_RESREF)
    {
        DelayCommand(0.0, ExecuteScript("_port_abyss", oPC));
        SetLocalObject(death_GetCorpseHolder(), "DEAD_PLAYER_" + IntToString(iPCID), oPC);
    }

    // check area faction
    int iAreaFaction = players_GetFaction(oArea);
    if (iAreaFaction != FACTION_UNKNOWN && iAreaFaction != iPCFaction)
        SendColorMessageToPC(oPC, "You entered enemy territory.", TXT_COLOR_RED);

    // nature
    if (GetIsAreaNatural(oArea) && GetHasFeat(FEAT_NATURE_SENSE, oPC))
        SendColorMessageToPC(oPC, "Nature Sense: You have entered a wilderness area.", TXT_COLOR_GREEN_L);

    // timestop
    if (GetLocalInt(oArea, "TIMESTOP_IN_AREA"))
    {
        object oCaster = GetLocalObject(oArea, "TIMESTOP_CASTER");
        if (GetIsObjectValid(oCaster) && oPC != oCaster)
        {
            effect eEff = GetFirstEffect(oCaster);
            while (GetIsEffectValid(eEff))
            {
                if (GetEffectSpellId(eEff) == SPELL_TIME_STOP && GetEffectTag(eEff) != CORMYR_SPELL_COOLDOWN_TAG)
                {
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectTimeStopCustom(), oPC, IntToFloat(GetEffectDurationRemaining(eEff)));
                    break;
                }
                eEff = GetNextEffect(oCaster);
            }
        }
    }

    // save last location
    SetLocalLocation(oPC, "LAST_PLAYER_LOCATION", GetLocation(oPC));

    // save player count
    string sFaction = IntToString(iPCFaction);
    int iCount = GetLocalInt(oArea, "FACTION_" + sFaction + "_PLAYERS_COUNT");
    SetLocalInt(oArea, "FACTION_" + sFaction + "_PLAYERS_COUNT", iCount + 1);

    // clear cash
    DeleteLocalInt(oArea, AREA_FLAG_PLAYERS_COUNT_WITH_DMS);
    DeleteLocalInt(oArea, AREA_FLAG_PLAYERS_COUNT_WITHOUT_DMS);
    telegraph_UpdateShaderForPc(oPC, oArea);
}


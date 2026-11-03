#include "_inc_db_funcs"
#include "x0_i0_position"
#include "nwnx_util"
#include "_inc_sqlocals"
#include "nwnx_creature"

///////////////////////////////////////////////////////////////////
//////////                Constants                      //////////
///////////////////////////////////////////////////////////////////

// distance in meters between corpse and gravestone
const float RIP_DIST_AHEAD                          = 1.2;

// death types for penalty system
const int DEATH_TYPE_ALIVE                          = -1;
const int DEATH_TYPE_UNDEFINED                      =  0;
const int DEATH_TYPE_DEFAULT                        =  1;
const int DEATH_TYPE_VASELINED                      =  2;
const int DEATH_TYPE_ENEMY_PLAYER                   =  3;
const int DEATH_TYPE_BOSS                           =  4;
const int DEATH_TYPE_FRIENDLY_PLAYER                =  5;

const int DEATH_FUGUE_EXIT_COOLDOWN                 = 36; // six rounds

const string DEATH_TIME_MARKER                      = "DEATH_TIME_MARKER";

///////////////////////////////////////////////////////////////////
//////////                Declarations                   //////////
///////////////////////////////////////////////////////////////////

// resurrect oPC with full HP
void death_Ressurect(object oPC);

// create corpse and gravestone
void RipPlayerAfterDeath(object oPC, int iPlayerID, int nDeathType);

// resurrect player, if iFullHP is true then restore full HP
void DeathPlayerResurrection(object SpellTarget, object PlayerCaster, int iFullHP);

// create corpse item after use corpse placeable and destroy corpse placeable
void CreateCorpseInInventory(object oCorpse, object oPC);

// create corpse placeable after drop corpse item and destroy corpse item
void CreateCorpseOnGround(object oCorpseItem, object oPC);

// destroy non actual corpses or update corpse cash object if corpses is actual
void CheckAndDestroyNonActualCorpses(object oPC);

// return TRUE if corpse's player is online
int CheckMasterOfCorpseInGame(int iPlayerID);

// returns random blood resref
string ReturnBloodResref();

// applies pray action for oPC and oGraveStone
void OnPrayAtGraveStone(object oGraveStone, object oPC);

// activates after "Crash Gravestone" in dialog
void OnCrashGraveStone(object oGraveStone, object oPC);

// give XP reward after non interrupted pray
void AfterPrayerXPReward(object oGraveStone, object oPC, float fDirection);

// remove all effect, except effects with SPELL_INSTANT_CHARACTER_EFFECTS spell ID
void RemoveEffectsAfterDeath(object oPC);

// return random resref for corpse
string ReturnCorpseStrRef(int iRacialType, int iGender);

// get player death status, DEATH_TYPE_* constants
int death_GetDeadFlag(int iPlayerID);

// set player death status, iFlag in DEATH_TYPE_* constants
void death_SetDeadFlag(int iPlayerID, int iFlag);

// get death cash object
object death_GetCorpseHolder();

///////////////////////////////////////////////////////////////////
//////////               Implementation                  //////////
///////////////////////////////////////////////////////////////////

void death_Ressurect(object oPC)
{
    effect eRaisDead = EffectVisualEffect(VFX_IMP_RAISE_DEAD);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eRaisDead, oPC);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
    // restore HP
    int nHeal = GetMaxHitPoints(oPC) - GetCurrentHitPoints(oPC);
    nHeal = (nHeal > 0) ? nHeal : 0;
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nHeal), oPC);
}

void RipPlayerAfterDeath(object oPC, int iPlayerID, int nDeathType)
{
    location lPcLoc = GetLocation(oPC);
    if(!GetIsObjectValid(GetAreaFromLocation(lPcLoc)))
    {
        lPcLoc = GetLocalLocation(oPC, "sm_location");
        if(!GetIsObjectValid(GetAreaFromLocation(lPcLoc)))
            lPcLoc = GetLocalLocation(oPC, "LAST_PLAYER_LOCATION");
    }
    object oArea = GetAreaFromLocation(lPcLoc);
    // sanity check
    if(!GetIsObjectValid(oArea)) return;
    // get vars
    string sName    = NWNX_Util_StripColors(GetName(oPC));
    int iFaction    = players_GetFaction(oPC);
    // set main vars and db flags
    SetLocalObject(death_GetCorpseHolder(), "DEAD_PLAYER_" + IntToString(iPlayerID), oPC);
    death_SetDeadFlag(iPlayerID, nDeathType);
    SQLocals_SetInt(oPC, DEATH_TIME_MARKER, TRUE);
    db_SetPlayerTotalDeaths(iPlayerID);
    // create blood and vfx
    CreateObject(OBJECT_TYPE_PLACEABLE, ReturnBloodResref(), lPcLoc);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_RED_SMALL), lPcLoc);
    // create corpse
    object oOldCorpse = GetLocalObject(death_GetCorpseHolder(), "CORPSE_OF_" + IntToString(iPlayerID));
    // no multiple corpses
    if (GetIsObjectValid(oOldCorpse)) DestroyObject(oOldCorpse, 0.1);
    // dont create placeables if forbidden
    if (!GetLocalInt(oArea, "NO_CORPSE"))
    {
        // choose random corpse model
        string sCorpseType = ReturnCorpseStrRef(GetRacialType(oPC), GetGender(oPC));
        // create corpse
        object oCorpse = CreateObject(OBJECT_TYPE_PLACEABLE, sCorpseType, lPcLoc);
        // set placeable flags and event scripts
        SetUseableFlag(oCorpse, TRUE);
        SetPlotFlag(oCorpse, TRUE);
        SetEventScript(oCorpse, EVENT_SCRIPT_PLACEABLE_ON_USED, "_plc_corpse");
        // set name, tag and local vars
        SetTag(oCorpse, CONST_CORPSE_TAG);
        SetName(oCorpse, "Corpse of " + sName);
        SetLocalString(oCorpse, "CORPSENAME", sName);
        SetLocalString(oCorpse, "CORPSETYPE", sCorpseType);
        SetLocalInt(oCorpse, "TOTALDEATHS", db_GetPlayerTotalDeaths(iPlayerID));
        SetLocalInt(oCorpse, "PLAYERID", iPlayerID);
        players_SetFaction(oCorpse, iFaction);
        SetLocalObject(death_GetCorpseHolder(), "CORPSE_OF_" + IntToString(iPlayerID), oCorpse);
    }
    if (!GetLocalInt(oArea, "NO_GRAVESTONE"))
    {
        object oOldGravestone = GetLocalObject(death_GetCorpseHolder(), "GRAVESTONE_OF_" + IntToString(iPlayerID));
        if (GetIsObjectValid(oOldGravestone)) DestroyObject(oOldGravestone, 0.1); // no multiple gravestones
        // calculate gravestone position
        float fOrientation = GetFacingFromLocation(lPcLoc);
        vector vOldPos = GetPositionFromLocation(lPcLoc);
        vector vNewPos = GetChangedPosition(vOldPos, RIP_DIST_AHEAD, fOrientation);
        int nStep;
        for(; nStep <= 180; nStep+=5)
        {
            vNewPos = GetChangedPosition(vOldPos, RIP_DIST_AHEAD, fOrientation + IntToFloat(nStep));
            vNewPos = NWNX_Creature_ComputeSafeLocation(oPC, vNewPos, 5.0);
            if(vOldPos.z == vNewPos.z)
                break;
        }
        location lLoc = Location(oArea, vNewPos, fOrientation);
        // create gravestone, using random model
        object oGraveStone = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_gravestone" + IntToString(Random(25) + 1), lLoc);
        SetName(oGraveStone, "R.I.P. of " + sName);
        // set local vars
        SetLocalString(oGraveStone, "CORPSENAME", sName);
        SetLocalObject(oGraveStone, "DEAD_OPC", oPC);
        SetLocalInt(oGraveStone, "PLAYERID", iPlayerID);
        SetLocalObject(death_GetCorpseHolder(), "GRAVESTONE_OF_" + IntToString(iPlayerID), oGraveStone);
    }
}

void DeathPlayerResurrection(object SpellTarget, object PlayerCaster, int iResType)
{
    int iPlayerID = GetLocalInt(SpellTarget, "PLAYERID");

    // cant resurrect offline players!
    if (!CheckMasterOfCorpseInGame(iPlayerID)){
        SendColorMessageToPC(PlayerCaster, "Dead player is offline. Try later.", TXT_COLOR_RED);
        return;
    }
    object oDeadPlayer = GetLocalObject(death_GetCorpseHolder(), "DEAD_PLAYER_" + IntToString(iPlayerID));
    object oGraveStone = GetLocalObject(death_GetCorpseHolder(), "GRAVESTONE_OF_" + IntToString(iPlayerID));

    location lLoc = GetLocation(PlayerCaster);
    object oArea = GetAreaFromLocation(lLoc);
    float fOrientation = GetFacingFromLocation(lLoc) + 180.0;
    vector vNewPos = GetChangedPosition(GetPositionFromLocation(lLoc), -1.2, fOrientation);
    lLoc = Location(oArea, vNewPos, fOrientation);

    if(iResType)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oDeadPlayer)), oDeadPlayer);
        SetLocalInt(oDeadPlayer, "RESURRECTED_PLAYER", 1);
    }
    else
        SetLocalInt(oDeadPlayer, "RAISEDEAD_PLAYER", 1);

    AssignCommand(oDeadPlayer, ClearAllActions());
    AssignCommand(oDeadPlayer, ActionJumpToLocation(lLoc));
    ExportSingleCharacter(PlayerCaster);
}

void CreateCorpseInInventory(object oCorpsePlaceable, object oPC)
{
    // create corpse item
    object oItemCorpse = CreateItemOnObject(CONST_ITEM_CORPSE, oPC);
    // set name and vars
    SetName(oItemCorpse, "Corpse of " + GetLocalString(oCorpsePlaceable, "CORPSENAME"));
    players_CopyVars(oCorpsePlaceable, oItemCorpse);
    // update info about new corpse at corpse cash object
    SetLocalObject(death_GetCorpseHolder(), "CORPSE_OF_" + IntToString(GetLocalInt(oCorpsePlaceable, "PLAYERID")), oItemCorpse);
    // destroy corpse placeable and save char
    ExportSingleCharacter(oPC);
    DestroyObject(oCorpsePlaceable, 0.1);
}

void CreateCorpseOnGround(object oCorpseItem, object oPC)
{
    // create corpse placeable and set flags and event handlers
    object oCorpsePlaceable = CreateObject(OBJECT_TYPE_PLACEABLE, GetLocalString(oCorpseItem, "CORPSETYPE"), GetLocation(oPC));
    SetUseableFlag(oCorpsePlaceable, TRUE);
    SetPlotFlag(oCorpsePlaceable, TRUE);
    SetEventScript(oCorpsePlaceable, EVENT_SCRIPT_PLACEABLE_ON_USED, "_plc_corpse");
    // set name, tag and vars
    SetName(oCorpsePlaceable, "Corpse of " + GetLocalString(oCorpseItem, "CORPSENAME"));
    SetTag(oCorpsePlaceable, CONST_CORPSE_TAG);
    players_CopyVars(oCorpseItem, oCorpsePlaceable);
    // update info about new corpse at corpse cash object
    SetLocalObject(death_GetCorpseHolder(), "CORPSE_OF_" + IntToString(GetLocalInt(oCorpseItem, "PLAYERID")), oCorpsePlaceable);
    // destroy corpse placeable and save char
    ExportSingleCharacter(oPC);
    DestroyObject(oCorpseItem, 0.1);
}

void CheckAndDestroyNonActualCorpses(object oPC)
{
    object oItem = GetFirstItemInInventory(oPC);
    while (GetIsObjectValid(oItem))
    {
        if (GetResRef(oItem) == CONST_ITEM_CORPSE)
        {
            string sCorpseName = GetLocalString(oItem, "CORPSENAME");
            int iTotalDeathsCount = GetLocalInt(oItem, "TOTALDEATHS");
            int iPlayerID = GetLocalInt(oItem, "PLAYERID");
            if(db_GetPlayerTotalDeaths(iPlayerID) != iTotalDeathsCount || death_GetDeadFlag(iPlayerID) <= 0)
                DestroyObject(oItem, 0.1);
            else if(death_GetDeadFlag(iPlayerID) > 0)
                SetLocalObject(death_GetCorpseHolder(), "CORPSE_OF_" + IntToString(iPlayerID), oItem);
        }
        oItem = GetNextItemInInventory(oPC);
    }
}

int CheckMasterOfCorpseInGame(int iPlayerID)
{
    int iLoopID = 0;
    object oLoop = GetFirstPC();
    while(GetIsObjectValid(oLoop))
    {
        iLoopID = players_GetPCPersistentID(oLoop);
        if (iLoopID == iPlayerID)
            return TRUE;
        oLoop = GetNextPC();
    }
    return FALSE;
}

string ReturnBloodResref()
{
    int iRandom = Random(7);
    switch(iRandom)
    {
        case 0: return "zep_bloodstain1";
        case 1: return "zep_bloodstain2";
        case 2: return "zep_bloodstain3";
        case 3: return "zep_bloodstain4";
        case 4: return "zep_bloodstain5";
        case 5: return "zep_bloodstain6";
        case 6: return "zep_bloodstain7";
    }
    return "";
}

void OnPrayAtGraveStone(object oGraveStone, object oPC)
{
    object oDeadPC = GetLocalObject(oGraveStone, "DEAD_OPC");
    if (oPC == oDeadPC)
    {
        float fDelay = 12.0;
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_MEDITATE, 1.0, fDelay));
        float fDirection = GetFacing(oPC);
        DelayCommand(fDelay + 0.1, AssignCommand(oPC, ActionRandomWalk()));
        DelayCommand(fDelay + 0.2, AfterPrayerXPReward(oGraveStone, oPC, fDirection));
    }
    else
        SendColorMessageToPC(oPC, "Praying at someones grave is a bad idea now.", TXT_COLOR_RED);
}

void OnCrashGraveStone(object oGraveStone, object oPC)
{
    AssignCommand(oPC, ClearAllActions());
    DelayCommand(0.1, AssignCommand(oPC, PlayVoiceChat(VOICE_CHAT_BATTLECRY1)));
    DelayCommand(0.2, AssignCommand(oPC, DoPlaceableObjectAction(oGraveStone, PLACEABLE_ACTION_BASH)));
    effect eLink = EffectLinkEffects(EffectDamageIncrease(DAMAGE_BONUS_2d12, DAMAGE_TYPE_MAGICAL), EffectHaste());
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oPC, 7.0);
}

void AfterPrayerXPReward(object oGraveStone, object oPC, float fDirection)
{
    if(!GetIsDead(oPC) && GetCurrentAction(oPC) == ACTION_RANDOMWALK)
    {
        AssignCommand(oPC, ClearAllActions());
        AssignCommand(oPC, SetFacing(fDirection));
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION_GREATER), GetLocation(oGraveStone));

        int iXpPrayBonus = GetLocalInt(oGraveStone, "GRAVESTONE_XP_PRAY_BONUS");
        if (iXpPrayBonus > 0) GiveXPToCreature(oPC, iXpPrayBonus);

        DestroyObject(oGraveStone, 0.5);
        DelayCommand(0.2, ExportSingleCharacter(oPC));
    }
}

void RemoveEffectsAfterDeath(object oPC)
{
    effect eEffect = GetFirstEffect(oPC);
    while(GetIsEffectValid(eEffect))
    {
        if (GetEffectSpellId(eEffect) != SPELL_INSTANT_CHARACTER_EFFECTS && GetEffectSubType(eEffect) != SUBTYPE_UNYIELDING)
            RemoveEffect(oPC,eEffect);
        eEffect = GetNextEffect(oPC);
    }
}


string ReturnCorpseStrRef(int iRacialType, int iGender)
{
    string sResult = "";

    int iDice2 = d2();
    int iDice3 = d3();
    int iDice4 = d4();
    int iDice6 = d6();

    switch(iRacialType)
    {
        case RACIAL_TYPE_DWARF:
            switch(iGender)
            {
                case GENDER_FEMALE:
                    sResult = (iDice2 == 1) ? "zep_cps_dwf_001" :
                                              "zep_cps_dwf_002";
                break;
                case GENDER_MALE:
                    sResult = (iDice3 == 1) ? "zep_cps_dwm_001" :
                              (iDice3 == 2) ? "zep_cps_dwm_002" :
                                              "zep_cps_dws_001";
                break;
                default:
                    sResult = "zep_cps_dwm_001";
                break;
            }
        break;
        case RACIAL_TYPE_ELF:
        case RACIAL_TYPE_HALFELF:
            switch(iGender)
            {
                case GENDER_FEMALE:
                    sResult = (iDice2 == 1) ? "zep_cps_elff_001" :
                                              "zep_cps_elff_002";
                break;
                case GENDER_MALE:
                    sResult = (iDice3 == 1) ? "zep_cps_elfm_001" :
                              (iDice3 == 2) ? "zep_cps_elfm_002" :
                                              "zep_cps_elfs_001";
                break;
                default:
                    sResult = "zep_cps_elfm_001";
                break;
            }
        break;
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFLING:
            switch(iGender)
            {
                case GENDER_FEMALE:
                    sResult = (iDice2 == 1) ? "zep_cps_hlff_001" :
                                              "zep_cps_hlff_002";
                break;
                case GENDER_MALE:
                    sResult = (iDice3 == 1) ? "zep_cps_hlfm_001" :
                              (iDice3 == 2) ? "zep_cps_hlfm_002" :
                                              "zep_cps_hlfs_001";
                break;
                default:
                    sResult = "zep_cps_hlfm_001";
                break;
            }
        break;
        case RACIAL_TYPE_HALFORC:
            switch(iGender)
            {
                case GENDER_FEMALE:
                    sResult = (iDice2 == 1) ? "zep_cps_hof_001" :
                                              "zep_cps_hof_002";
                break;
                case GENDER_MALE:
                    sResult = (iDice4 == 1) ? "zep_cps_hom_001" :
                              (iDice4 == 2) ? "zep_cps_hom_002" :
                              (iDice4 == 3) ? "zep_cps_hom_003" :
                                              "zep_cps_hom_004";
                break;
                default:
                    sResult = "zep_cps_hom_001";
                break;
            }
        break;
        case RACIAL_TYPE_HUMAN:
            switch(iGender)
            {
                case GENDER_FEMALE:
                    sResult = (iDice4 == 1) ? "zep_cps_fem_001" :
                              (iDice4 == 2) ? "zep_cps_fem_002" :
                              (iDice4 == 3) ? "zep_cps_fem_003" :
                                              "zep_cps_fem_005";
                break;
                case GENDER_MALE:
                    sResult = (iDice6 == 1) ? "zep_cps_male_001" :
                              (iDice6 == 2) ? "zep_cps_male_006" :
                              (iDice6 == 3) ? "zep_cps_male_008" :
                              (iDice6 == 4) ? "zep_cps_male_009" :
                              (iDice6 == 5) ? "zep_cps_male_012" :
                                              "zep_cps_male_002";
                break;
                default:
                    sResult = "zep_cps_male_001";
                break;
            }
        break;
        default:
            sResult ="zep_cps_male_001";
        break;

    }
    return sResult;
}

int death_GetDeadFlag(int iPlayerID)
{
    object oHolder = death_GetCorpseHolder();
    int nDeadFlag = GetLocalInt(oHolder, "PC_DEAD_FLAG_" + IntToString(iPlayerID));
    if(nDeadFlag != DEATH_TYPE_UNDEFINED)
        return nDeadFlag;
    string sSQL = "SELECT dead FROM characters WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
    if(NWNX_SQL_ReadyToReadNextRow())
    {
        NWNX_SQL_ReadNextRow();
        nDeadFlag = StringToInt(NWNX_SQL_ReadDataInActiveRow());
    }
    if(nDeadFlag == DEATH_TYPE_UNDEFINED)
        nDeadFlag = DEATH_TYPE_ALIVE;
    SetLocalInt(oHolder, "PC_DEAD_FLAG_" + IntToString(iPlayerID), nDeadFlag);

    return nDeadFlag;
}

void death_SetDeadFlag(int iPlayerID, int iFlag)
{
    object oHolder = death_GetCorpseHolder();
    DeleteLocalInt(oHolder, "PC_DEAD_FLAG_" + IntToString(iPlayerID));
    string sSQL = "UPDATE characters SET dead = ? WHERE id = ?";
    NWNX_SQL_PrepareQuery(sSQL);
    NWNX_SQL_PreparedInt(0, iFlag);
    NWNX_SQL_PreparedInt(1, iPlayerID);
    NWNX_SQL_ExecutePreparedQuery();
}

object death_GetCorpseHolder()
{
    string sCashVar = "CORPSE_HOLDER";
    object oResult = GetLocalObject(GetModule(), sCashVar);
    if(GetIsObjectValid(oResult))
        return oResult;
    oResult = GetWaypointByTag(CONST_CORPSE_HOLDER);
    SetLocalObject(GetModule(), sCashVar, oResult);
    return oResult;
}

// void main() {}

#include "nwnx_creature"
#include "nwnx_util"
#include "_inc_death"

const float ULTIMATE_RADIUS_SIZE = 20.0;
const float ULTIMATE_COOLDOWN = 120.0;

void RemoveInventory(object oObject)
{
    object oItem = GetFirstItemInInventory(oObject);
    while(GetIsObjectValid(oItem))
    {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oObject);
    }
    TakeGoldFromCreature(GetGold(oObject), oObject, TRUE);
}

void SetEquipedItemsUndroppable(object oCreature)
{
    object oItem;
    int i;
    for(;i < NUM_INVENTORY_SLOTS; i++)
    {
        oItem = GetItemInSlot(i, oCreature);
        SetPlotFlag(oItem, TRUE);
        SetDroppableFlag(oItem, FALSE);
    }
}

void SetEventHandlers(object oCreature)
{
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_c2_default1");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, "nw_c2_default2");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND, "nw_c2_default3");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, "nw_c2_default4");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "nw_c2_default5");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "nw_c2_default6");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DEATH, "ai_destroy_self");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DISTURBED, "nw_c2_default8");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPAWN_IN, "nw_c2_default9");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_RESTED, "nw_c2_defaulta");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "nw_c2_defaultb");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT, "nw_c2_defaultd");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "nw_c2_defaulte");
}

void ApplyDeathArmor(object oCreature)
{
    effect eEff = EffectImmunity(IMMUNITY_TYPE_CRITICAL_HIT);
    eEff = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
    eEff = EffectLinkEffects(EffectDamageImmunityDecrease(DAMAGE_TYPE_DIVINE, 100), eEff);
    eEff = EffectLinkEffects(EffectTrueSeeing(), eEff);
    eEff = EffectLinkEffects(EffectDamageImmunityIncrease(DAMAGE_TYPE_NEGATIVE, 100), eEff);
    eEff = EffectLinkEffects(EffectDamageShield(30, DAMAGE_BONUS_1d6, DAMAGE_TYPE_NEGATIVE), eEff);
    eEff = EffectLinkEffects(EffectRegenerate(60, 6.0), eEff);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eEff), oCreature);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectTemporaryHitpoints(GetMaxHitPoints(oCreature))), oCreature);
}

void DamageLoop(object oCreature, int iRound)
{
    int iPlayerID = players_GetPCPersistentID(oCreature);
    if(!iPlayerID)
        return;
    // set deadflag state
    int bDeadFlag = death_GetDeadFlag(iPlayerID) > 0;

    int iDamage = GetMaxHitPoints(oCreature) / 100 * 20;
    int iSave;
    int iDice = d20();
    if(players_GetRealSavingThrowValue(oCreature, SAVING_THROW_FORT) + iDice < 60)
    {
        if(iDice == 1)
        {
            iDamage *= 3;
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DESTRUCTION), oCreature);
        }
        else
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_EVIL_HELP), oCreature);
            iDamage *= 2;
        }
    }

    if(bDeadFlag <= 0)
        DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(iDamage, IP_CONST_DAMAGETYPE_PHYSICAL), oCreature));

    if(iRound <= 10)
    {
        // create ghost if player is dead
        if(bDeadFlag)
        {
            DeleteLocalObject(OBJECT_SELF, "TARGET_UNDER_ULTIMATE");
            // play "your soul is mine"
            SpeakString("Your soul is mine!");
            object oArea = GetArea(OBJECT_SELF);
            object oPlayer = GetFirstObjectInArea(oArea, OBJECT_TYPE_CREATURE);
            while(GetIsObjectValid(oPlayer))
            {
                if(GetIsPC(oPlayer))
                    StartAudioStream(oPlayer, AUDIOSTREAM_IDENTIFIER_0, "mus_shangtsung");
                oPlayer = GetNextObjectInArea(oArea, OBJECT_TYPE_CREATURE);
            }

            // clone dead player
            object oClone = CopyObject(oCreature, GetLocation(OBJECT_SELF));

            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oClone);
            NWNX_Object_SetCurrentHitPoints(oClone, GetMaxHitPoints(oClone));
            SetEventHandlers(oClone);
            RemoveInventory(oClone);
            SetEquipedItemsUndroppable(oClone);
            ChangeToStandardFaction(oClone, STANDARD_FACTION_HOSTILE);
            SetSoundset(oClone, 202);
            NWNX_Creature_SetRacialType(oClone, RACIAL_TYPE_UNDEAD);
            NWNX_Creature_SetMovementRate(oClone, NWNX_CREATURE_MOVEMENT_RATE_PC);
            SetName(oClone, "Ghost of " + NWNX_Util_StripColors(GetName(oClone)));

            PlayVoiceChat(VOICE_CHAT_ATTACK, oClone);
            ApplyDeathArmor(oClone);
            // kill them all
            ExecuteScript("nw_c2_default3", OBJECT_SELF);

            ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectVisualEffect(925)), oClone);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HARM), oClone);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_EPIC_UNDEAD), oClone);
            DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DEATH_L), oClone));
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectVisualEffect(VFX_DUR_ICESKIN)), oClone);
            DestroyObject(oClone, 600.0);
        }
        else
        {
            iRound++;
            DelayCommand(6.0, DamageLoop(oCreature, iRound));
        }
    }
}

object GetBestTargetForUltimate()
{
    object oBestTarget = OBJECT_INVALID;

    object oBestAB = OBJECT_INVALID;
    int iBestAB;

    object oLowestHp = OBJECT_INVALID;
    int iLowestHp = 100000;
    int iTargetHp;
    location lLoc = GetLocation(OBJECT_SELF);
    object oLoop = GetFirstObjectInShape(SHAPE_SPHERE, ULTIMATE_RADIUS_SIZE, lLoc);
    while(GetIsObjectValid(oLoop))
    {
        if(GetIsEnemy(oLoop) && GetIsPC(oLoop) && !GetIsDM(oLoop))
        {

            if(iBestAB < GetBaseAttackBonus(oLoop))
            {
                iBestAB = GetBaseAttackBonus(oLoop);
                oBestAB = oLoop;
            }
            iTargetHp = GetCurrentHitPoints(oLoop);
            if(iLowestHp > iTargetHp)
            {
                iLowestHp = iTargetHp;
                oLowestHp = oLoop;
            }
        }
        oLoop = GetNextObjectInShape(SHAPE_SPHERE, ULTIMATE_RADIUS_SIZE, lLoc);
    }
    if(!GetIsObjectValid(oBestAB))
        return OBJECT_INVALID;

    if(oLowestHp == GetAttemptedAttackTarget())
        oBestTarget = oLowestHp;
    else
    {
        if(d100() > 65)
            oBestTarget = oBestAB;
        else
            oBestTarget = oLowestHp;
    }
    return oBestTarget;
}

void Ultimate(object oCreature)
{
    int iDamage = GetMaxHitPoints(oCreature) / 100 * 25;
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(iDamage, IP_CONST_DAMAGETYPE_PHYSICAL), oCreature);
    DelayCommand(6.0, DamageLoop(oCreature, 0));
}



void main()
{
    if(GetIsInCombat(OBJECT_SELF) && !GetLocalInt(OBJECT_SELF, "SatanaUltimateUsed"))
    {
        object oTarget = GetBestTargetForUltimate();
        if(GetIsObjectValid(oTarget))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(PRCVFX_FNF_VAMPIRIC_DRAIN), oTarget, 66.0);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(EffectVisualEffect(PRCVFX_DUR_MARK_OF_THE_HUNTER)), oTarget, 66.0);
            Ultimate(oTarget);
            ActionAttack(oTarget);
            SetLocalInt(OBJECT_SELF, "SatanaUltimateUsed", TRUE);
            DelayCommand(ULTIMATE_COOLDOWN, DeleteLocalInt(OBJECT_SELF, "SatanaUltimateUsed"));
            SetLocalObject(OBJECT_SELF, "TARGET_UNDER_ULTIMATE", oTarget);
            DelayCommand(ULTIMATE_COOLDOWN, DeleteLocalObject(OBJECT_SELF, "TARGET_UNDER_ULTIMATE"));
        }
    }
    ExecuteScript("ai_boss_onheart", OBJECT_SELF);
}

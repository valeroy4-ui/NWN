#include "dom_pc_heal"
void DOMAI_Reset(object oPC)
{
    DeleteLocalInt(oPC, "DAI_INIT");
    DeleteLocalInt(oPC, "DAI_COMMAND");
    DeleteLocalInt(oPC, "DAI_WAIT");
}

int DOMAI_IsEnemy(object oEnemy, object oCaster, object oPC)
{
    if (!GetIsObjectValid(oEnemy)
        || oEnemy == oPC
        || oEnemy == oCaster)
        return FALSE;

    if (GetIsDead(oEnemy) || GetIsDM(oEnemy))
        return FALSE;

    if (GetArea(oEnemy) != GetArea(oPC))
        return FALSE;

    if (!GetIsReactionTypeHostile(oEnemy, oCaster))
        return FALSE;

    return GetObjectSeen(oEnemy, oPC);
}

object DOMAI_FindEnemy(object oCaster, object oPC)
{
    int n = 1;
    object oEnemy = GetNearestObject(
        OBJECT_TYPE_CREATURE, oPC, n);

    while (GetIsObjectValid(oEnemy))
    {
        if (GetDistanceBetween(oPC, oEnemy) > 30.0)
            break;

        if (DOMAI_IsEnemy(oEnemy, oCaster, oPC))
            return oEnemy;

        n++;
        oEnemy = GetNearestObject(
            OBJECT_TYPE_CREATURE, oPC, n);
    }

    return OBJECT_INVALID;
}

int DOMAI_CategorySpell(int nCategory, object oPC)
{
    talent t = GetCreatureTalentBest(nCategory, 100, oPC);
    int nId = GetIdFromTalent(t);

    if (GetTypeFromTalent(t) == TALENT_TYPE_SPELL
        && nId >= 0
        && GetHasSpell(nId, oPC) > 0)
        return nId;

    int n = 0;

    while (n < 8)
    {
        t = GetCreatureTalentRandom(nCategory, oPC);
        nId = GetIdFromTalent(t);

        if (GetTypeFromTalent(t) == TALENT_TYPE_SPELL
            && nId >= 0
            && GetHasSpell(nId, oPC) > 0)
            return nId;

        n++;
    }

    return -1;
}

int DOMAI_HealSpell(object oPC, object oCaster)
{
    int nMissing = GetMaxHitPoints(oCaster)
        - GetCurrentHitPoints(oCaster);

    if (nMissing <= 0)
        return -1;

    if (GetRacialType(oCaster) == RACIAL_TYPE_UNDEAD)
        return -1;

    if (nMissing >= 50
        && GetHasSpell(SPELL_HEAL, oPC) > 0)
        return SPELL_HEAL;

    if (GetHasSpell(SPELL_CURE_CRITICAL_WOUNDS, oPC) > 0)
        return SPELL_CURE_CRITICAL_WOUNDS;

    if (GetHasSpell(SPELL_CURE_SERIOUS_WOUNDS, oPC) > 0)
        return SPELL_CURE_SERIOUS_WOUNDS;

    if (GetHasSpell(SPELL_CURE_MODERATE_WOUNDS, oPC) > 0)
        return SPELL_CURE_MODERATE_WOUNDS;

    if (GetHasSpell(SPELL_CURE_LIGHT_WOUNDS, oPC) > 0)
        return SPELL_CURE_LIGHT_WOUNDS;

    return DOMAI_CategorySpell(
        TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH, oPC);
}

int DOMAI_AttackSpell(object oPC, object oEnemy)
{
    if (!GetHasSpellEffect(SPELL_BLINDNESS_AND_DEAFNESS, oEnemy)
        && !GetIsImmune(oEnemy, IMMUNITY_TYPE_BLINDNESS)
        && GetHasSpell(SPELL_BLINDNESS_AND_DEAFNESS, oPC) > 0)
        return SPELL_BLINDNESS_AND_DEAFNESS;

    if (GetRacialType(oEnemy) != RACIAL_TYPE_UNDEAD
        && GetHasSpell(SPELL_HARM, oPC) > 0)
        return SPELL_HARM;

    int n = 0;
    int nStart = Random(3);

    while (n < 3)
    {
        int nCategory = 1 + ((nStart + n) % 3);
        int nSpell = DOMAI_CategorySpell(nCategory, oPC);

        if (nSpell >= 0)
        {
            if (nSpell != SPELL_HARM
                || GetRacialType(oEnemy) != RACIAL_TYPE_UNDEAD)
                return nSpell;
        }

        n++;
    }

    return -1;
}

void DOMAI_Step(object oCaster)
{
    object oPC = OBJECT_SELF;

    if (!GetLocalInt(oPC, "DOMPC_TEST_ACTIVE"))
        return;

    if (!GetIsPC(oPC) || !GetIsPC(oCaster))
        return;

    int nCommand = GetLastAssociateCommand(oPC);

    if (!GetLocalInt(oPC, "DAI_INIT")
        || GetLocalInt(oPC, "DAI_COMMAND") != nCommand)
    {
        SetLocalInt(oPC, "DAI_INIT", TRUE);
        SetLocalInt(oPC, "DAI_COMMAND", nCommand);
        SetLocalInt(oPC, "DAI_WAIT", 0);

        SendMessageToPC(oCaster,
            "Dominate AI: command=" + IntToString(nCommand)
            + " Heal=" + IntToString(GetHasSpell(SPELL_HEAL, oPC))
            + " Harm=" + IntToString(GetHasSpell(SPELL_HARM, oPC))
            + " Blind="
            + IntToString(GetHasSpell(SPELL_BLINDNESS_AND_DEAFNESS, oPC)));
    }

    int nWait = GetLocalInt(oPC, "DAI_WAIT");

    if (nWait > 0)
    {
        SetLocalInt(oPC, "DAI_WAIT", nWait - 1);
        return;
    }

    if (GetCurrentAction(oPC) == ACTION_CASTSPELL
        || GetCurrentAction(oPC) == ACTION_ITEMCASTSPELL)
        return;

    object oTarget = OBJECT_INVALID;
    int nSpell = -1;

       if (nCommand == ASSOCIATE_COMMAND_HEALMASTER)
    {
        SetLocalInt(oPC, "DAI_WAIT", 12);
        DOMH_Heal(oCaster);
        return;
    }
    else if (nCommand == ASSOCIATE_COMMAND_ATTACKNEAREST)
    {
        oTarget = DOMAI_FindEnemy(oCaster, oPC);

        if (GetIsObjectValid(oTarget))
        {
            SendMessageToPC(oCaster,
                "Dominate AI: enemy=" + GetName(oTarget)
                + " PC=" + IntToString(GetIsPC(oTarget))
                + " hostileToCaster="
                + IntToString(GetIsReactionTypeHostile(oTarget, oCaster))
                + " hostileToControlled="
                + IntToString(GetIsReactionTypeHostile(oTarget, oPC)));

            nSpell = DOMAI_AttackSpell(oPC, oTarget);
        }
    }
    else
        return;

    // Decisions every 6 seconds: 12 controller ticks.
    SetLocalInt(oPC, "DAI_WAIT", 12);

    if (!GetIsObjectValid(oTarget))
    {
        SendMessageToPC(oCaster,
            "Dominate AI: no visible enemy within 30 m.");
        return;
    }

    if (nSpell >= 0)
    {
        SendMessageToPC(oCaster,
            "Dominate AI: cast "
            + Get2DAString("spells", "Label", nSpell)
            + " on " + GetName(oTarget));

        ClearAllActions(TRUE);

        // Normal casting, using the controlled PC's available spells.
        ActionCastSpellAtObject(
            nSpell, oTarget, METAMAGIC_ANY, FALSE);
    }
    else if (nCommand == ASSOCIATE_COMMAND_ATTACKNEAREST)
    {
        if (GetAttackTarget(oPC) != oTarget)
        {
            ClearAllActions(TRUE);
            ActionAttack(oTarget);
        }
    }
    else if (GetCurrentHitPoints(oCaster) < GetMaxHitPoints(oCaster))
    {
        SendMessageToPC(oCaster,
            "Dominate AI: no available healing spell.");
    }
}

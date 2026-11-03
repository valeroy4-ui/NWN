void DOMH_Cast(object oCaster, int nSpell, object oTarget)
{
    object oPC = OBJECT_SELF;

    ClearAllActions(TRUE);

    if (oTarget == oPC)
        ActionMoveToObject(oCaster, TRUE, 3.0);

    int nPosition = 1;

    while (nPosition <= 3)
    {
        int nClass = GetClassByPosition(nPosition, oPC);

        if (nClass >= 0
            && Get2DAString("classes", "MemorizesSpells", nClass) == "1")
        {
            int nLevel = 0;

            while (nLevel <= 9)
            {
                int nCount = GetMemorizedSpellCountByLevel(
                    oPC, nClass, nLevel);

                int nSlot = 0;

                while (nSlot < nCount)
                {
                    if (GetMemorizedSpellId(
                            oPC, nClass, nLevel, nSlot) == nSpell
                        && GetMemorizedSpellReady(
                            oPC, nClass, nLevel, nSlot) == TRUE)
                    {
                        int nMeta = GetMemorizedSpellMetaMagic(
                            oPC, nClass, nLevel, nSlot);

                        int nDomain = 0;

                        if (GetMemorizedSpellIsDomainSpell(
                            oPC, nClass, nLevel, nSlot) == TRUE)
                        {
                            int nTry = 1;

                            while (nTry <= 9 && nDomain == 0)
                            {
                                if (GetSpellUsesLeft(
                                    oPC, nClass, nSpell, nMeta, nTry) > 0)
                                    nDomain = nTry;

                                nTry++;
                            }
                        }

                        SendMessageToPC(oCaster,
                            "Heal queue: "
                            + Get2DAString("spells", "Label", nSpell)
                            + " class=" + IntToString(nClass)
                            + " level=" + IntToString(nLevel)
                            + " domain=" + IntToString(nDomain)
                            + " meta=" + IntToString(nMeta));

                        ActionCastSpellAtObject(
                            nSpell,
                            oTarget,
                            nMeta,
                            FALSE,
                            nDomain,
                            PROJECTILE_PATH_TYPE_DEFAULT,
                            FALSE,
                            nClass);

                        return;
                    }

                    nSlot++;
                }

                nLevel++;
            }
        }

        nPosition++;
    }

    SendMessageToPC(oCaster,
        "Heal queue: "
        + Get2DAString("spells", "Label", nSpell)
        + " auto slot");

    ActionCastSpellAtObject(
        nSpell, oTarget, METAMAGIC_ANY, FALSE);
}

int DOMH_UseSpell(object oCaster, int nSpell)
{
    object oPC = OBJECT_SELF;

    if (nSpell < 0 || GetHasSpell(nSpell, oPC) <= 0)
        return FALSE;

    int nCategory = StringToInt(
        Get2DAString("spells", "Category", nSpell));

    object oTarget = oCaster;

    if (Get2DAString("spells", "Range", nSpell) == "P")
    {
        if (nCategory != TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT)
            return FALSE;

        oTarget = oPC;
    }
    else
    {
        string sMask = GetStringLowerCase(
            Get2DAString("spells", "TargetType", nSpell));

        int nMask = StringToInt(sMask);

        if (GetStringLeft(sMask, 2) == "0x")
            nMask = FindSubString(
                "0123456789abcdef", GetStringRight(sMask, 1));

        if (nMask < 0 || !(nMask & 2))
            return FALSE;
    }

    if (nSpell == SPELL_REGENERATE
        || nSpell == SPELL_MONSTROUS_REGENERATION)
    {
        if (GetHasSpellEffect(SPELL_REGENERATE, oCaster)
            || GetHasSpellEffect(
                SPELL_MONSTROUS_REGENERATION, oCaster))
            return FALSE;
    }

    DOMH_Cast(oCaster, nSpell, oTarget);
    return TRUE;
}

int DOMH_Category(object oCaster, int nCategory)
{
    object oPC = OBJECT_SELF;

    talent t = GetCreatureTalentBest(nCategory, 100, oPC);
    int nAttempt = 0;

    while (nAttempt < 9)
    {
        int nId = GetIdFromTalent(t);

        if (nId >= 0)
        {
            if (GetTypeFromTalent(t) == TALENT_TYPE_SPELL)
            {
                if (DOMH_UseSpell(oCaster, nId))
                    return TRUE;
            }
            else if (GetTypeFromTalent(t) == TALENT_TYPE_FEAT
                && GetHasFeat(nId, oPC))
            {
                ClearAllActions(TRUE);

                SendMessageToPC(oCaster,
                    "Heal queue: feat=" + IntToString(nId));

                ActionUseTalentOnObject(t, oCaster);
                return TRUE;
            }
        }

        nAttempt++;
        t = GetCreatureTalentRandom(nCategory, oPC);
    }

    return FALSE;
}

void DOMH_Heal(object oCaster)
{
    object oPC = OBJECT_SELF;

    if (!GetIsPC(oPC) || !GetIsPC(oCaster))
        return;

    if (!GetLocalInt(oPC, "DOMPC_TEST_ACTIVE"))
        return;

    if (GetIsDead(oPC) || GetIsDead(oCaster))
        return;

    if (GetArea(oPC) != GetArea(oCaster))
        return;

    if (GetCurrentHitPoints(oCaster) >= GetMaxHitPoints(oCaster))
        return;

    if (GetRacialType(oCaster) == RACIAL_TYPE_UNDEAD)
    {
        SendMessageToPC(oCaster,
            "Heal AI: positive healing skipped on undead.");
        return;
    }

    if (DOMH_UseSpell(oCaster, SPELL_HEAL))
        return;

    if (DOMH_UseSpell(oCaster, SPELL_GREATER_RESTORATION))
        return;

    if (DOMH_Category(
        oCaster, TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH))
        return;

    if (DOMH_Category(
        oCaster, TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT))
        return;

    if (DOMH_UseSpell(oCaster, SPELL_REGENERATE))
        return;

    if (DOMH_UseSpell(oCaster, SPELL_MONSTROUS_REGENERATION))
        return;

    SendMessageToPC(oCaster,
        "Heal AI: no available healing ability.");
}

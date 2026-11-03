/************************ [On User Defined] ************************************
    Filename: j_ai_onuserdef or nw_c2_defaultd
************************* [Workings] *******************************************/

#include "j_inc_constants"
#include "j_inc_seteffects"
#include "_inc_constants"
//#include "nwnx_creature"
#include "_inc_generic"
#include "_inc_areas"
#include "_inc_telegraph"

void boss_PrepareAndCast(object oCaster, object oTarget, int nSpell, int nSpellLevel);

void boss_ChaunteaAoE(object oBoss);

void boss_SpawnAngryOrbs(object oPC, string sCreatorUUID, string sAreaUUID, int nCount);

void main()
{
    switch (GetUserDefinedEventNumber())
    {
        case EVENT_USER_DEFINED_BOSS_CHAUNTEA:
        {
            int nRoll = d100();

            if (nRoll <= 70)
                break;
            if (GetCurrentHitPoints(OBJECT_SELF) < 500)
                break;

            int nEnemiesNumber = areas_GetNumberOfPlayersInArea(GetArea(OBJECT_SELF), FALSE);
            int nRandomEnemy = nEnemiesNumber > 1 ? Random(nEnemiesNumber) + 1 : 1;
            object oTarget = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF, nRandomEnemy, CREATURE_TYPE_IS_ALIVE, TRUE);

            if(!GetIsObjectValid(oTarget) && !GetObjectSeen(oTarget))
                break;

            SetAIObject(AI_LAST_MELEE_TARGET, oTarget);
            SetAIObject(AI_LAST_SPELL_TARGET, oTarget);
            SetAIObject(AI_LAST_RANGED_TARGET, oTarget);

            float fDistance = GetDistanceBetween(OBJECT_SELF, oTarget);

            int bResisted = ResistSpell(OBJECT_SELF, oTarget) >= 1;

            if(nRoll > 92) // AoE unic
            {
                SpeakString("Prick up your asses! You will be fucked by the forces of Nature!");
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(PRCVFX_FNF_AWAKEN, FALSE, 2.0f), OBJECT_SELF, 3.0);
                DelayCommand(2.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(PRCVFX_FNF_FEEBLEMIND, FALSE, 2.0f), OBJECT_SELF, 3.0));
                DelayCommand(3.1, boss_ChaunteaAoE(OBJECT_SELF));
            }
            else if(fDistance <= 2.25 && !bResisted && GetCurrentHitPoints(oTarget) <= 350)  // touch
                boss_PrepareAndCast(OBJECT_SELF, oTarget, SPELL_HARM, 6);
            else if(fDistance <= 8.0 && !bResisted && !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH)) // short
                boss_PrepareAndCast(OBJECT_SELF, oTarget, SPELL_IMPLOSION, 9);
            else if(fDistance <= 20.0 && Array_Size("SPELL_ARRAY_TAG", oTarget)) // medium
                boss_PrepareAndCast(OBJECT_SELF, oTarget, SPELL_GREATER_DISPELLING, 6);
            else
                boss_PrepareAndCast(OBJECT_SELF, OBJECT_SELF, SPELL_STORM_OF_VENGEANCE, 9);
        }
        break;
        case EVENT_USER_DEFINED_BOSS_MUTATED:
        {
            int nRoll = d100();
            if (nRoll <= 70)
                break;

            int nEnemiesNumber = areas_GetNumberOfPlayersInArea(GetArea(OBJECT_SELF), FALSE);
            int nRandomEnemy = nEnemiesNumber > 1 ? Random(nEnemiesNumber) + 1 : 1;
            object oTarget = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF, nRandomEnemy, CREATURE_TYPE_IS_ALIVE, TRUE);

            if(!GetIsObjectValid(oTarget))
                break;

            object oAttacked = GetAttemptedAttackTarget();
            ClearAllActions();
            ActionCastFakeSpellAtLocation(SPELL_HAMMER_OF_THE_GODS, GetLocation(oTarget));
            SetCommandable(FALSE);
            DelayCommand(3.0, SetCommandable(TRUE));
            DelayCommand(3.1, ActionDoCommand(ActionAttack(oTarget)));

            object oArea = GetArea(OBJECT_SELF);
            if(!GetIsObjectValid(oArea))
                break;

            if(nRoll > 95)
                boss_SpawnAngryOrbs(oTarget, GetObjectUUID(OBJECT_SELF), GetObjectUUID(oArea), 2 + d2());
            else
                boss_SpawnAngryOrbs(oTarget, GetObjectUUID(OBJECT_SELF), GetObjectUUID(oArea), 2 + d4());
        }
        break;
    }
    ExecuteScript("nw_c2_defaultd", OBJECT_SELF);
}

void boss_PrepareAndCast(object oCaster, object oTarget, int nSpell, int nSpellLevel)
{
    SetMemorizedSpell(oCaster, CLASS_TYPE_CLERIC, nSpellLevel, 0, nSpell);
    ClearAllActions(TRUE);
    ActionCastSpellAtObject(nSpell, oTarget);
    SetCommandable(FALSE, oCaster);
    DelayCommand(3.0, SetCommandable(TRUE));
    DelayCommand(3.1, ActionDoCommand(ActionAttack(oTarget)));
}

void boss_ChaunteaAoE(object oBoss)
{
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 10.0, GetLocation(oBoss));
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != oBoss)
        {
            effect eVis = EffectVisualEffect(VFX_IMP_NIGHTMARE_HEAD_HIT, FALSE, 3.5f);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            DelayCommand(1.0f, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectCutsceneImmobilize(), oTarget, 3.0f));
            DelayCommand(1.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_DUR_STONEHOLD), oTarget));
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, 8.0, GetLocation(oBoss));
    }
}

void boss_SpawnAngryOrbs(object oPC, string sCreatorUUID, string sAreaUUID, int nCount)
{
    vector vPos = GetPosition(oPC);
    Array_Clear("DMG_ZONE_X", oPC);
    Array_Clear("DMG_ZONE_Y", oPC);

    int i;
    for (i = 0; i < nCount; ++i)
    {
        float fRadius   = 5.0 + Random(25) / 10.0;
        float fDuration = 2.5 + Random(25) / 10.0;
        float x;
        float y;
        int nBreaker = TRUE;

        while(nBreaker)
        {
            x = vPos.x + Random(200) / 10.0f - 10.0f;
            y = vPos.y + Random(200) / 10.0f - 10.0f;
            int nPoolSize = Array_Size("DMG_ZONE_X", oPC);
            if(!nPoolSize)
                nBreaker = FALSE;
            vector vNew = Vector(x, y, 0.0);
            int j;
            for(j = 0; j < Array_Size("DMG_ZONE_X", oPC); j++)
            {
                float fLoopX = Array_At_Flt("DMG_ZONE_X", j, oPC);
                float fLoopY = Array_At_Flt("DMG_ZONE_Y", j, oPC);
                vector vLoop = Vector(fLoopX, fLoopY, 0.0);
                if(VectorMagnitude(vLoop - vNew) > 7.5)
                    nBreaker = FALSE;
            }
        }
        Array_PushBack_Flt("DMG_ZONE_X", x, oPC);
        Array_PushBack_Flt("DMG_ZONE_Y", y, oPC);

        effect telegraph = TelegraphCreate(TELEGRAPH_SHAPE_SPHERE, x, y, vPos.z, 0.0f, fRadius, 0.0f, fDuration, sCreatorUUID, sAreaUUID, "", "", "_on_boss_sphere");
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, telegraph, GetObjectByUUID(sCreatorUUID), fDuration);
    }
}

#include "_inc_citykeeper"
#include "_inc_fameshop"
#include "_inc_areas"
#include "nwnx_object"

const float TELEPORT_FAIL_CAST_TIME = 3.0f;
const float TELEPORT_VIS_STEP = 0.60f;
const float TELEPORT_DELAY = 9.0f;

// crypton -->
int GetKeeperAlive(object oPC, string sPotionTag)
{
     if(players_GetFaction(oPC)!= FACTION_EMPIRE && FindSubString(sPotionTag, "GDI") >= 0 && !GetIsKeeperDestroyed(FACTION_EMPIRE))
         return TRUE;
     if(players_GetFaction(oPC)!= FACTION_UNDERDARK && FindSubString(sPotionTag, "Kulg") >= 0 && !GetIsKeeperDestroyed(FACTION_UNDERDARK))
         return TRUE;
     if(players_GetFaction(oPC)!= FACTION_IRON_THRONE && FindSubString(sPotionTag, "Reno") >= 0 && !GetIsKeeperDestroyed(FACTION_IRON_THRONE))
         return TRUE;
     if(players_GetFaction(oPC)!= FACTION_DRAGON_CULT && FindSubString(sPotionTag, "Cult") >= 0 && !GetIsKeeperDestroyed(FACTION_DRAGON_CULT))
         return TRUE;
     // TPL check
     if(players_GetFaction(oPC)!= players_GetFaction(GetFactionLeader(oPC)) && FindSubString(sPotionTag, "party") >= 0)
         return TRUE;

     return FALSE;
}

int GetIsEnemyNear(object oPC, float fRadius = 100.0)
{
    location lLoc = GetLocation(oPC);
    object oEnemy = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLoc, FALSE);
    while(GetIsObjectValid(oEnemy))
    {
      if(!GetIsDead(oEnemy) && GetIsPC(oEnemy) && (GetIsEnemy(oPC, oEnemy) || GetIsEnemy(oEnemy, oPC)))
      {
          return TRUE;
      }
      oEnemy = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLoc, FALSE);
    }
    return FALSE;
}
//crypton <--

void Teleport(location lPC, location lLoc)
{
    object oPC = OBJECT_SELF;

    if(GetIsInCombat(oPC) || !GetLocalInt(oPC, "TELEPORTING") || GetIsEnemyNear(oPC) ||
    NWNX_Object_GetCurrentAnimation(oPC) != NWNX_ANIMATION_LOOPING_MEDITATE)
    {
        effect eVis1 = EffectLinkEffects(EffectVisualEffect(VFX_FNF_SPELL_FAIL_HEAD), EffectVisualEffect(VFX_FNF_PWSTUN));
        eVis1 = EffectLinkEffects(eVis1, EffectVisualEffect(VFX_FNF_PWSTUN));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, oPC);

        vector vOrigin = GetPositionFromLocation(lLoc);
        vOrigin.z += 0.5f;
        location lOrigin = Location(GetAreaFromLocation(lLoc), vOrigin, GetFacingFromLocation(lLoc));

        effect eVis2 = EffectLinkEffects(EffectVisualEffect(VFX_FNF_SPELL_FAIL_HEAD), EffectVisualEffect(VFX_FNF_PWSTUN));
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis2, lOrigin);

        AssignCommand(oPC, ActionDoCommand(PlayAnimation(ANIMATION_LOOPING_SPASM, 1.0, TELEPORT_FAIL_CAST_TIME)));
    }
    else
    {
        effect eVis1 = EffectVisualEffect(VFX_FNF_TELEPORT_IN);
        DelayCommand(0.3f, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis1, lLoc));

        location lPC = GetLocation(oPC);

        effect eVis2 = EffectVisualEffect(VFX_FNF_TELEPORT_OUT);
        DelayCommand(0.0f, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis2, lPC));

        effect eVis3 = EffectVisualEffect(VFX_IMP_UNSUMMON);
        DelayCommand(0.5f, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis3, lPC));

        DelayCommand(0.6f, JumpToLocation(lLoc));
        DelayCommand(1.3f, JumpToLocation(lLoc));
        DelayCommand(0.6f, SetLocalLocation(oPC, "sm_location", lLoc));
    }

    DeleteLocalInt(oPC, "TELEPORTING");
}

void TeleportPC(object oPC, string sPotionTag)
{
    string sAccount = GetPCPlayerName(oPC);
    object oPortal;

    if(FindSubString(sPotionTag, "party") >= 0)
    {
        oPortal = GetFactionLeader(oPC);
        FloatingTextStringOnCreature("Teleport to " + GetName(oPortal) + TXT_COLOR_END, oPC, 0);
        FloatingTextStringOnCreature(GetName(GetArea(oPortal)) + TXT_COLOR_END, oPC, 0);
    }
    else
        oPortal = GetObjectByTag("DST_" + sPotionTag);

    vector vPos = GetPosition(oPortal);
    object oArea = GetArea(oPortal);               vPos.x -= 0.5;
    location lOrigin = Location(oArea, vPos, 0.0); vPos.x += 1.0;
    location lOrigin2 = Location(oArea, vPos, 0.0);

    vector vPosPC = GetPosition(oPC);
    object oAreaPC = GetArea(oPC);                        vPosPC.x -= 0.5;
    location lOriginPC = Location(oAreaPC, vPosPC, 0.0);  vPosPC.x += 1.0;
    location lOriginPC2 = Location(oAreaPC, vPosPC, 0.0);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GOOD_HELP), lOriginPC);

     if(GetKeeperAlive(oPC, sPotionTag) ||
        GetIsInCombat(oPC) ||
        !GetIsObjectValid(oPortal) ||
        GetAreaFlag(GetArea(oPC), AREA_FLAG_NO_TELEPORT) ||
        players_InAbyss(oPC)  ||
        (GetAreaFlag(GetArea(GetFactionLeader(oPC)), AREA_FLAG_NO_ANCHOR) && FindSubString(sPotionTag, "party") >= 0)
       )
    {
        AssignCommand(oPC, ActionDoCommand(PlayAnimation(ANIMATION_LOOPING_SPASM, 1.0, TELEPORT_FAIL_CAST_TIME)));

        effect eVis = EffectLinkEffects(EffectVisualEffect(VFX_FNF_SPELL_FAIL_HEAD), EffectVisualEffect(VFX_FNF_PWSTUN));
        eVis = EffectLinkEffects(eVis, EffectVisualEffect(VFX_FNF_PWSTUN));
        DelayCommand(TELEPORT_FAIL_CAST_TIME + 0.1f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPC));
    }
    else
    {
        AssignCommand(oPC, PlayAnimation(ANIMATION_LOOPING_MEDITATE, 1.0f, TELEPORT_DELAY + 1.0));

        if(TELEPORT_VIS_STEP > 0.0f)
        {
            effect eVis = EffectVisualEffect(VFX_IMP_WIND);

            int nMax = FloatToInt(TELEPORT_DELAY / TELEPORT_VIS_STEP);
            int nMax2 = nMax / 2;

            int i = 0;
            for(; i < nMax; i++)
            {
                float fDelay = TELEPORT_VIS_STEP * IntToFloat(i);

                DelayCommand(fDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lOrigin));
                DelayCommand(fDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lOriginPC));

                DelayCommand(fDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lOrigin2));
                DelayCommand(fDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lOriginPC2));

                if(i < nMax2)
                {
                    DelayCommand(fDelay * 1.6f, AssignCommand(oPC, PlaySound("sca_outmind01")));
                    DelayCommand(fDelay * 1.6f, AssignCommand(oPortal, PlaySound("sca_outmind01")));
                }
            }
        }

        SetLocalInt(oPC, "TELEPORTING", 1);

        DelayCommand(TELEPORT_DELAY, AssignCommand(oPC, Teleport(lOriginPC, lOrigin)));
    }
}


//void main(){}


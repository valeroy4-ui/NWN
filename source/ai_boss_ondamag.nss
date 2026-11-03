/************************ [On Damaged] *****************************************
    Filename: nw_c2_default6 or j_ai_ondamaged
************************* [On Damaged] *****************************************/

#include "_inc_colortext"
#include "nwnx_creature"
#include "_inc_areas"
#include "_inc_spells"


const float BOSS_RAGE_TICK_INTERVAL = 2.5;
const float BOSS_RAGE_DURATION = 15.0;

void Heal()
{
    object oTarget = GetAttemptedAttackTarget();
    talent tPotionHealing = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_POTION, 20);
    ClearAllActions();
    ActionUseTalentOnObject(tPotionHealing, OBJECT_SELF);

    SetCommandable(FALSE);
    DelayCommand(3.0, SetCommandable(TRUE));
    DelayCommand(3.1, ActionDoCommand(ActionAttack(oTarget)));
}

void DoZankuRageDamage(object oZanku = OBJECT_SELF)
{
    effect eZankuVis = EffectVisualEffect(PRCVFX_FNF_HELLFIRE_2);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eZankuVis, oZanku);

    location lLoc = GetLocation(oZanku);
    object oLoop = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lLoc);
    while(GetIsObjectValid(oLoop))
    {
        if(GetIsEnemy(oLoop) && GetIsPC(oLoop) && !GetIsDM(oLoop))
        {
            effect eDamage = EffectDamage(Random(100)* (3 - GetLocalInt(oZanku, "BOSS_HEALS")),
                                          DAMAGE_TYPE_FIRE);
            DelayCommand(1.1, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oLoop));
            DelayCommand(1.1, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_HIT_FIRE), oLoop));
        }
        oLoop = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lLoc);
    }
}

void main()
{

    int iCurrHP = GetCurrentHitPoints();

    if(iCurrHP < 10 && !GetLocalInt(OBJECT_SELF, "HEAL_AND_RAGE_ACTIVATED"))
    {
        object oArea = GetArea(OBJECT_SELF);
        SetLocalInt(OBJECT_SELF, "HEAL_AND_RAGE_ACTIVATED", TRUE);
        SetPlotFlag(OBJECT_SELF, TRUE);
        SetLocalInt(OBJECT_SELF, "BOSS_AREA_PLAYERS_COUNT", areas_GetNumberOfPlayersInArea(oArea, FALSE));
        SetLocalFloat(OBJECT_SELF, "BOSS_RAGE_DURATION", BOSS_RAGE_DURATION);
        effect eRage = EffectRunScript("_mod_runscript", "_mod_runscript", "_mod_runscript", BOSS_RAGE_TICK_INTERVAL);
        eRage = SupernaturalEffect(eRage);
        eRage = SetEffectSpellId(eRage, SPELL_CORMYR_BOSS_RAGE);
        DelayCommand(0.1, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRage, OBJECT_SELF, BOSS_RAGE_DURATION));

        int iHeals = GetLocalInt(OBJECT_SELF, "BOSS_HEALS");
        if(iHeals <= 0)
            SetImmortal(OBJECT_SELF, FALSE);
        else
        {
            SetLocalInt(OBJECT_SELF, "BOSS_HEALS", iHeals - 1);
            CreateItemOnObject("nw_it_mpotion012"); // heal potion
            DelayCommand(0.1, Heal());
        }
        // zanku handler ==>
        if(GetResRef(OBJECT_SELF) == "cr_boss_zanku")
        {
            DelayCommand(3.5, DoZankuRageDamage());
            DelayCommand(6.5, DoZankuRageDamage());
            DelayCommand(9.5, DoZankuRageDamage());
        }
        // zanku handler <==
        // alarm ==>
        object oPlayer = GetFirstObjectInArea(oArea, OBJECT_TYPE_CREATURE);
        while(GetIsObjectValid(oPlayer))
        {
            if(GetIsPC(oPlayer))
            {
                if(iHeals <= 0)
                    FloatingColorTextStringOnCreature("FINISH HIM!", TXT_COLOR_GREEN_L, oPlayer, FALSE);
                else
                    FloatingColorTextStringOnCreature(IntToString(iHeals - 1) + " heals remaining.", TXT_COLOR_GREEN_L, oPlayer, FALSE);
            }
            oPlayer = GetNextObjectInArea(oArea, OBJECT_TYPE_CREATURE);
        }
        // alarm <==
    }
    DelayCommand(1.0, ExecuteScript("nw_c2_default6", OBJECT_SELF));
}



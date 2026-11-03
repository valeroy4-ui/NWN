#include "_inc_guard_spawn"
#include "_inc_citykeeper"
#include "_inc_appearance"
#include "_inc_obelisk"
#include "_inc_champ_boss"
#include "_inc_telegraph"
void CS_InitEncounters();
void main()
{
    object mod=GetModule();
    if(GetLocalInt(mod,"CS_WORLD_DONE")) return;
    int stage=GetLocalInt(mod,"CS_WORLD_STAGE");
    PrintString("[CS RESTORE BEGIN] stage="+IntToString(stage));
    switch(stage)
    {
        case 0: InitKeepers(); break;
        case 1: obelisk_Init(); break;
        case 2: SpawnGuardsOnModule(); break;
        case 3: guard_SpawnNpcBuffers(); break;
        case 4: guard_CreateFactionsWeaponShops(); break;
        case 5: appearance_Init(); break;
        case 6: champion_EliteInit(); break;
        case 7: CS_InitEncounters(); break;
        case 8:
        {
            // Original fame-dependent cleric level, without reopening classes or changing phase.
            int fame=factions_GetTotalFactionsFame();
            if(fame<0) fame=0;
            int level=FloatToInt(0.0448 * sqrt(IntToFloat(fame)) + 20.0);
            if(level>CORMYREAN_NPC_BUFFER_MAX_LVL) level=CORMYREAN_NPC_BUFFER_MAX_LVL;
            factions_SetFactionBufferLevel(FACTION_EMPIRE,level);
            factions_SetFactionBufferLevel(FACTION_UNDERDARK,level);
            factions_SetFactionBufferLevel(FACTION_IRON_THRONE,level);
            factions_SetFactionBufferLevel(FACTION_DRAGON_CULT,level);
            // Original weekday and shaders/player-list defaults. Preserve test phase T4.
            sqlquery q=SqlPrepareQueryObject(mod,"SELECT strftime('%w','now')");
            if(SqlStep(q)) SetLocalInt(mod,SERVER_WEEKDAY,SqlGetInt(q,0));
            SetCustomToken(8999,TXT_COLOR_END); SetCustomToken(9000,TXT_COLOR_GRAY_L);
            SetTlkOverride(67435,"<CUSTOM9000>Elsewhere<CUSTOM8999>");
            SetTlkOverride(6423,"<CUSTOM9000>Elsewhere<CUSTOM8999>");
            SetTlkOverride(6424,"<CUSTOM9000>Elsewhere<CUSTOM8999>");
            SetTlkOverride(6425,"<CUSTOM9000>Elsewhere<CUSTOM8999>");
            ExecuteScript("cs_shader_tick",mod);
            DelayCommand(60.0,ExecuteScript("cs_world_tick",mod));
            SetLocalInt(mod,"CS_WORLD_DONE",TRUE);
            PrintString("[CS RESTORE READY] world stages=9; test phase retained; scheduled shutdown disabled");
            return;
        }
    }
    PrintString("[CS RESTORE END] stage="+IntToString(stage));
    SetLocalInt(mod,"CS_WORLD_STAGE",stage+1);
    DelayCommand(0.2,ExecuteScript("cs_world_init",mod));
}

// Preserve Champion Rift instances and any later custom encounter hook.
void CS_InitEncounters()
{
    object area=GetFirstArea();
    while(GetIsObjectValid(area))
    {
        if(!GetLocalInt(area,"CRIFT_AREA"))
        {
            object encounter=GetFirstObjectInArea(area,OBJECT_TYPE_ENCOUNTER);
            while(GetIsObjectValid(encounter))
            {
                string hook=GetEventScript(encounter,EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER);
                if(hook=="" || hook=="_on_encounter")
                {
                    SetEncounterActive(FALSE,encounter);
                    NWNX_Encounter_SetCanReset(encounter,FALSE);
                    NWNX_Encounter_SetPlayerTriggeredOnly(encounter,TRUE);
                    SetEventScript(encounter,EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER,"_on_encounter");
                }
                encounter=GetNextObjectInArea(area,OBJECT_TYPE_ENCOUNTER);
            }
        }
        area=GetNextArea();
    }
}

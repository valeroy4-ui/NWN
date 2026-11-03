#include "_inc_fameshop"
#include "_inc_runes"
#include "_inc_reputation"

// Test accounts receive a starting budget; prices and purchase handlers remain
// those of the Cormyr catalog. Existing account balances are not reset.
const int CT_STARTING_FAME = 1000000;

void main()
{
    object p=OBJECT_SELF;
    if(!GetIsPC(p) || GetIsDM(p)) return;
    string account=GetPCPlayerName(p);
    string name=GetName(p,TRUE);
    NWNX_SQL_PrepareQuery("INSERT INTO players(name,fame_total) VALUES(?,?) ON DUPLICATE KEY UPDATE name=VALUES(name)");
    NWNX_SQL_PreparedString(0,account);NWNX_SQL_PreparedInt(1,CT_STARTING_FAME);
    if(!NWNX_SQL_ExecutePreparedQuery())
    { SendMessageToPC(p,"Cormyr: database login failed; see server log.");return; }
    int faction=FACTION_EMPIRE;
    string race=GetStringLowerCase(GetSubRace(p));
    if(race=="dragon") faction=FACTION_DRAGON_CULT;
    else if(race=="nigeria") faction=FACTION_UNDERDARK;
    else if(race=="ironthrone") faction=FACTION_IRON_THRONE;
    NWNX_SQL_PrepareQuery("INSERT INTO characters(account,name,faction) SELECT ?,?,? FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM characters WHERE account=? AND name=?)");
    NWNX_SQL_PreparedString(0,account);NWNX_SQL_PreparedString(1,name);NWNX_SQL_PreparedInt(2,faction);
    NWNX_SQL_PreparedString(3,account);NWNX_SQL_PreparedString(4,name);
    if(!NWNX_SQL_ExecutePreparedQuery()) return;
    NWNX_SQL_PrepareQuery("SELECT id,faction FROM characters WHERE account=? AND name=? ORDER BY id DESC LIMIT 1");
    NWNX_SQL_PreparedString(0,account);NWNX_SQL_PreparedString(1,name);
    if(!NWNX_SQL_ExecutePreparedQuery() || !NWNX_SQL_ReadyToReadNextRow()) return;
    NWNX_SQL_ReadNextRow();
    int id=StringToInt(NWNX_SQL_ReadDataInActiveRow(0));
    faction=StringToInt(NWNX_SQL_ReadDataInActiveRow(1));
    if(id<=0) return;
    SetSkinInt(p,CONST_PLAYER_ID,id);
    SetLocalInt(p,"FACTION",faction);
    SetLocalInt(p,"CT_LOGIN_READY",TRUE);
    NWNX_SQL_PrepareQuery("UPDATE characters SET last_login=CURRENT_TIMESTAMP,level=?,experience=?,last_ip=?,filename=? WHERE id=?");
    NWNX_SQL_PreparedInt(0,GetHitDice(p));NWNX_SQL_PreparedInt(1,GetXP(p));
    NWNX_SQL_PreparedString(2,GetPCIPAddress(p));NWNX_SQL_PreparedString(3,NWNX_Player_GetBicFileName(p));
    NWNX_SQL_PreparedInt(4,id);NWNX_SQL_ExecutePreparedQuery();
    RestoreReputation(p);
    SetGuiPanelDisabled(p,GUI_PANEL_JOURNAL,TRUE);
    DeleteLocalInt(p,"BANK_DEPOSIT_CASH");
    runes_LoadRunes(p);
    AssignCommand(p,DelayCommand(1.0,ExecuteScript("_mod_instant_eff",p)));
    ExecuteScript("ct_pdk_sync",p);
    ExecuteScript("pdk_srv_enter",p);
    PrintString("[CORMYR LOGIN] character="+name+" id="+IntToString(id)+" faction="+IntToString(faction)+" freeFame="+IntToString(GetFreeFame(p)));
}

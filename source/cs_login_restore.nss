#include "_inc_death"
#include "_inc_itemprop"
#include "nwnx_rename"
#include "cs_login_inc"
void main()
{
    object pc = OBJECT_SELF;
    if(!GetIsPC(pc) || GetIsDM(pc) || !GetLocalInt(pc,"CT_LOGIN_READY") || players_GetPCPersistentID(pc)<=0) return;
    CS_RestoreLogin(pc);
}

#include "inc_heal_range"

void main()
{
    PrintString("[MH282 CHECK] mode=existing_events base=114 baseRange="+Get2DAString("spells","Range",114)
        +" variant="+IntToString(MH282_DOMAIN_SPELL)
        +" variantRange="+Get2DAString("spells","Range",MH282_DOMAIN_SPELL)
        +" master="+Get2DAString("spells","Master",MH282_DOMAIN_SPELL));
    PrintString("[MH282 CHECK] radius2DA="+Get2DAString("spells","TargetSizeX",114));
    object pc=GetFirstPC();
    while(GetIsObjectValid(pc))
    {
        if(!GetIsDM(pc))
        {
            PrintString("[MH282 CHECK] name="+GetName(pc)+" HP="+IntToString(GetCurrentHitPoints(pc))
                +"/"+IntToString(GetMaxHitPoints(pc))+" domains="+IntToString(GetDomain(pc,1,CLASS_TYPE_CLERIC))
                +","+IntToString(GetDomain(pc,2,CLASS_TYPE_CLERIC))
                +" SF="+IntToString(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,pc))
                +" GSF="+IntToString(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT,pc))
                +" ESF="+IntToString(GetHasFeat(FEAT_EPIC_SPELL_FOCUS_ENCHANTMENT,pc)));
            int index;
            for(index=1;index<=3;index++)
            {
                int cls=GetClassByPosition(index,pc);
                if(cls==CLASS_TYPE_INVALID)continue;
                int shortRange=cls==CLASS_TYPE_CLERIC
                    && (GetDomain(pc,1,CLASS_TYPE_CLERIC)==DOMAIN_HEALING
                        || GetDomain(pc,2,CLASS_TYPE_CLERIC)==DOMAIN_HEALING);
                PrintString("[MH282 CHECK] name="+GetName(pc)+" bookClass="+IntToString(cls)
                    +" levels="+IntToString(GetLevelByClass(cls,pc))+" range="+(shortRange?"short":"touch"));
            }
        }
        pc=GetNextPC();
    }
    PrintString("[MH282 CHECK] READ ONLY; actual casts and native slot charge require in-game acceptance.");
}

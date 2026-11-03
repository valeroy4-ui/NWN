#include "inc_heal_range"

void main()
{
    PrintString("[CSW276 CHECK] mode=existing_events base=35 baseRange="+Get2DAString("spells","Range",35)
        +" variant="+IntToString(CSW276_DOMAIN_SPELL)
        +" variantRange="+Get2DAString("spells","Range",CSW276_DOMAIN_SPELL)
        +" master="+Get2DAString("spells","Master",CSW276_DOMAIN_SPELL));
    object pc=GetFirstPC();
    while(GetIsObjectValid(pc))
    {
        if(!GetIsDM(pc))
        {
            PrintString("[CSW276 CHECK] name="+GetName(pc)+" HP="+IntToString(GetCurrentHitPoints(pc))
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
                PrintString("[CSW276 CHECK] name="+GetName(pc)+" bookClass="+IntToString(cls)
                    +" levels="+IntToString(GetLevelByClass(cls,pc))+" range="+(shortRange?"short":"touch"));
            }
        }
        pc=GetNextPC();
    }
    PrintString("[CSW276 CHECK] READ ONLY; actual casts and native slot charge require in-game acceptance.");
}

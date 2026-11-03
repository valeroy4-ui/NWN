#include "pdk_battle"
void main()
{
 int spell=GetSpellId();object p=OBJECT_SELF;
 if(spell==806) PKB_Aura(p,1);
 else if(spell==807) PKB_Aura(p,2);
 else if(spell==1870) PKB_Aura(p,3,ALIGNMENT_GOOD);
 else if(spell==1871) PKB_Aura(p,3,ALIGNMENT_EVIL);
 else if(spell==1872) PKB_Smite(p,GetSpellTargetObject(),1);
 else if(spell==1873) PKB_Smite(p,GetSpellTargetObject(),2);
 else PKS_Feedback(p,"Choose Wrath vs Good or Wrath vs Evil in the radial menu.");
}

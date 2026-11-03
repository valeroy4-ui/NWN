#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
//#include "_inc_generic"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();
    //Get the object that is exiting the AOE
    object oTarget = GetExitingObject();
    if(GetHasSpellEffect(spell.Id, oTarget))
    {
        //Search through the valid effects on the target.
        effect eAOE = GetFirstEffect(oTarget);
        while(GetIsEffectValid(eAOE))
        {
            //ServerShout("GetEffectSpellId: " + IntToString(GetEffectSpellId(eAOE)));
            if(GetEffectCreator(eAOE) == aoe.Creator)
            {
                //If the effect was created by the Acid_Fog then remove it
                if(GetEffectSpellId(eAOE) == spell.Id)
                {
                    RemoveEffect(oTarget, eAOE);
                    break;
                }
            }
            //Get next effect on the target
            eAOE = GetNextEffect(oTarget);
        }
    }
}

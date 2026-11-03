#include "_inc_spellike"
#include "_inc_war_class"

void main()
{
    //Declare major variables
    spellsDeclareMajorVariables();

    switch(spell.Id)
    {
        case SPELL_THREATENING_CRY: //
            spellike_DoThreateningCry();
        break;
        case SPELL_OPEN_WOUNDS_ACTIVATE:
            spellike_DoOpenWoundsActivate();
        break;
        case SPELL_GREATER_INVISIBILITY:
            spellike_GreaterInvisibility();
        break;
        case SPELL_HEROIC_POWER:
            spellike_DoHeroicPower();
        break;
        case SPELL_HARPER_CLAIRVOYANCE:
            spellike_DoHarperClairvoyance();
        break;
        case SPELL_HARPER_INVISIBILITY:
            spellike_DoHarperInvisibility();
        break;
        case SPELL_HARPER_SHIELD:
            spellike_DoHarperHeroicShield();
        break;
        case SPELL_HARPER_MIGHT:
            spellike_DoHarperMight();
        break;
        case SPELL_WARLORD_FURY:
            ApplyWarlordsFury(spell.Caster, spell.Id);
        break;
        case SPELL_BATTLEFIELD_ECHO:
            ApplyBattlefieldEcho(spell.Caster, spell.Id, spell.Range, spell.Loc);
        break;
        case SPELL_WARLORD_GUARD:
            ApplyWarlordsGuard(spell.Caster, spell.Id);
        break;
    }
}

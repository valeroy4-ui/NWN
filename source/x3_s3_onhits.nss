#include "_inc_onhit"

void main()
{
    //Declare major variables
    spellsDeclareMajorVariables();

    // switch current spell
    switch(spell.Id)
    {
        case SPELL_ASSASSINATION_MARK: // TODO fameshop max +5  -- DONE
            onhit_DoAssasinationMark(spell.Caster, spell.Target, spell.Id);
        break;
        case SPELL_DARK_HIT: // TODO fameshop max +5 -- DONE
            onhit_DoDarkHit(spell.Caster, spell.Target, spell.Id);
        break;
        case SPELL_CANT_SEE_ME: // NO fameshop, but actualized
            onhit_DoCantSeeMe(spell.Caster, spell.Target);
        break;
        case SPELL_CRIPPLING_STRIKE_ROGUE: // NO fameshop, but actualized
            onhit_DoCripplingStrikeRogue(spell.Caster, spell.Target, spell.Id);
        break;
        case SPELL_OPEN_WOUNDS: // TODO fameshop max +5 -- DONE
            onhit_DoOpenWoundsMark(spell.Caster, spell.Target, spell.Id);
        break;
        case SPELL_LAST_HIT:  // NO fameshop
            SetLocalString(spell.Target, "LAST_HIT_VICTIM", ObjectToString(spell.Caster));
        break;
        case SPELL_PAINFUL_HIT: // TODO fameshop, max +2 -- DONE
            onhit_DoPainfulHit(spell.Caster, spell.Target, spell.Id);
        break;
        case SPELL_DARK_STRIKE: // TODO fameshop max +5  -- DONE
            onhit_DoDarkStrike(spell.Caster, spell.Target, spell.Id);
        break;
        case SPELL_PLAGUE: // target debuff stackable effects
        case SPELL_REND:
        case SPELL_WEAKEN:
            onhit_DoStackableEffect(spell.Caster, spell.Target, spell.Id);
        break;
        case SPELL_MADNESS: // self buff stackable effects
            onhit_DoStackableEffect(spell.Caster, spell.Target, spell.Id, TRUE);
        break;
    }
    // + Assassin Special hit done + actualized
}



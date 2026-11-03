// ============================================================================
// Общий механизм дальности Healing Domain для пяти заклинаний лечения.
// Ниже у каждого заклинания указаны название, строка таблицы и основной скрипт.
// Shared Healing Domain range routing. This is an include, not an impact script.
// Only the actual Cleric spellbook + Healing Domain receives native Short range.
// Other books/items keep their original range. Healing formulas live in impacts.
// The five constants below retain the EXISTING stand IDs; allocate free IDs when
// integrating into another module. Master keeps native original slot charging.
// ============================================================================
#include "nwnx_events"

// Cure Critical Wounds: строка275, основной ID31, скрипт nw_s0_curcrwn.
const int CCW275_DOMAIN_SPELL=2044;
// Cure Serious Wounds: строка276, основной ID35, скрипт nw_s0_curserw.
const int CSW276_DOMAIN_SPELL=2045;
// Greater Restoration: строка277, основной ID70, скрипт nw_s0_grrestore.
const int GR277_DOMAIN_SPELL=2046;
// Heal: строка279, основной ID79, скрипт nw_s0_heal.
const int HEAL279_DOMAIN_SPELL=2047;
// Mass Heal: строка282, основной ID114, скрипт nw_s0_masheal; цель или точка.
const int MH282_DOMAIN_SPELL=2048;

// Used by impact guards too. Items are still rejected by their existing guards.
int HealRange_HasDomain(object caster,int cls)
{
    return cls==CLASS_TYPE_CLERIC
        && (GetDomain(caster,1,CLASS_TYPE_CLERIC)==DOMAIN_HEALING
            || GetDomain(caster,2,CLASS_TYPE_CLERIC)==DOMAIN_HEALING);
}

// Resolve either a normal spell or its hidden variant to the normal spell ID.
int HealRange_BaseId(int id)
{
    switch(id)
    {
        // Cure Critical Wounds: Touch31 <-> Short alias with Master31.
        case SPELL_CURE_CRITICAL_WOUNDS: case CCW275_DOMAIN_SPELL:
            return SPELL_CURE_CRITICAL_WOUNDS;
        // Cure Serious Wounds: Touch35 <-> Short alias with Master35.
        case SPELL_CURE_SERIOUS_WOUNDS: case CSW276_DOMAIN_SPELL:
            return SPELL_CURE_SERIOUS_WOUNDS;
        // Greater Restoration: Touch70 <-> Short alias with Master70.
        case SPELL_GREATER_RESTORATION: case GR277_DOMAIN_SPELL:
            return SPELL_GREATER_RESTORATION;
        // Heal: Touch79 <-> Short alias with Master79.
        case SPELL_HEAL: case HEAL279_DOMAIN_SPELL:
            return SPELL_HEAL;
        // Mass Heal: Touch114 <-> Short alias with Master114.
        case SPELL_MASS_HEAL: case MH282_DOMAIN_SPELL:
            return SPELL_MASS_HEAL;
    }
    return -1;
}

int HealRange_ShortId(int base)
{
    switch(base)
    {
        case SPELL_CURE_CRITICAL_WOUNDS:return CCW275_DOMAIN_SPELL;
        case SPELL_CURE_SERIOUS_WOUNDS:return CSW276_DOMAIN_SPELL;
        case SPELL_GREATER_RESTORATION:return GR277_DOMAIN_SPELL;
        case SPELL_HEAL:return HEAL279_DOMAIN_SPELL;
        case SPELL_MASS_HEAL:return MH282_DOMAIN_SPELL;
    }
    return -1;
}

// Called ONCE from existing _ev_on_inp_cast, after slot checks and before runes.
// TRUE means stop processing this INPUT handler. It does not cancel a native
// Touch cast by itself. Only NWNX_Events_SkipEvent() cancels the input event.
int HealRange_RouteInput(int id,int cls,int meta,int domain,object target,int blocked)
{
    int base=HealRange_BaseId(id);
    if(base<0)return FALSE;
    int alias=HealRange_ShortId(base);
    int eligible=HealRange_HasDomain(OBJECT_SELF,cls)
        && GetLevelByClass(CLASS_TYPE_CLERIC,OBJECT_SELF)>0;
    int fake=StringToInt(NWNX_Events_GetEventData("FAKE"));

    // Greater Restoration, Heal, Mass Heal: own this input even when Touch stays
    // unchanged, so the older Rune III branch cannot grant Short to another book.
    // Cure Critical/Serious preserve their prior fall-through behavior exactly.
    int ownRuneRoute=base==SPELL_GREATER_RESTORATION || base==SPELL_HEAL
        || base==SPELL_MASS_HEAL;
    if(id==alias)
    {
        // Preserve existing forged-alias and already-blocked request guards.
        if(!eligible || fake || (ownRuneRoute && blocked))
        {NWNX_Events_SkipEvent();return TRUE;}
        return ownRuneRoute;
    }

    // Only Mass Heal accepts a selected ground point. The other four require
    // a valid object. This preserves its original object/area targeting mode.
    int areaTarget=FALSE;
    if(base==SPELL_MASS_HEAL)
        areaTarget=StringToInt(NWNX_Events_GetEventData("IS_AREA_TARGET"));
    if(blocked || !eligible || fake || (!GetIsObjectValid(target) && !areaTarget))
        return ownRuneRoute;

    // Preserve the native book, meta, domain slot, spontaneous flag and path.
    int instant=StringToInt(NWNX_Events_GetEventData("INSTANT"));
    int path=StringToInt(NWNX_Events_GetEventData("PROJECTILE_PATH"));
    if(path==5)path=4; // Native underwater5 is NWScript path4.
    int spontaneous=StringToInt(NWNX_Events_GetEventData("SPONTANEOUS"));
    NWNX_Events_SkipEvent();
    if(areaTarget)
    {
        // Mass Heal / row282: keep the exact selected center, never recenter self.
        vector pos=Vector(StringToFloat(NWNX_Events_GetEventData("POS_X")),
            StringToFloat(NWNX_Events_GetEventData("POS_Y")),
            StringToFloat(NWNX_Events_GetEventData("POS_Z")));
        ActionCastSpellAtLocation(alias,Location(GetArea(OBJECT_SELF),pos,0.0),
            meta,FALSE,path,instant,cls,spontaneous,domain);
    }
    else
    {
        // All five spells: normal object-target Short cast, original Master slot.
        ActionCastSpellAtObject(alias,target,meta,FALSE,domain,path,instant,cls,spontaneous);
    }
    return TRUE;
}

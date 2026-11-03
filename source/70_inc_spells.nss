//::///////////////////////////////////////////////
//:: Community Patch 1.70 New Spell Engine include
//:: 70_inc_spells
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This include file contains base functions for the New Spell Engine.
In order to use it in your spells put this line in the beginning of the script.

    spellsDeclareMajorVariables();

Then you will be able to access spell related informations by typing:

spell.Caster - caster
spell.Target - spell target object
spell.Item - spell cast item
spell.Level - caster level
spell.Id - spell ID constant
spell.DC - spell DC
spell.Meta - spell metamagic
spell.Loc - spell target location
spell.Class - spell cast class
1.72 addition:
spell.DamageCap - damage cap
spell.DamageType - damage type
spell.Dice - dice used by spell effects
spell.Limit - various spell limits like number of missiles or max bonus
spell.Range - AOE radius
spell.SavingThrow - saving throw
spell.SR - spell resistance check
spell.TargetType - target selection scheme refers to SPELL_TARGET_* constants
spell.SaveType, spell.DmgVfxS, spell.DmgVfxL - saving throw type, damage visual small and damage visual large - automatically filled variables based on spell.DamageType value

You can use them directly, but if you want to adjust them, like if the spell halves
the caster level, its a good practice to declare the caster level into new variable
beforehand like this.

int nCasterLevel = spell.Level/2;

Otherwise you do not have to do this. Take a look into few spells that have been
rewritten onto New Spell Engine and you will understand quicky.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: ?-11-2010
//:://////////////////////////////////////////////
#include "x2_inc_switches"
#include "_inc_constants"

const int SPELL_TARGET_SINGLETARGET   = 2;
const int SPELL_DURATION_TYPE_SECONDS = 1;
const int SPELL_DURATION_TYPE_ROUNDS  = 2;
const int SPELL_DURATION_TYPE_TURNS   = 3;
const int SPELL_DURATION_TYPE_HOURS   = 4;
const int SPELL_DURATION_TYPE_HOURS_2MINUTES = 65536;
const int YES = 1;
const int NO = -1;

//declare major variables for every spell
//start every spell script with this at top
void spellsDeclareMajorVariables();

//created as variation for AOE spells whose got different handling
void aoesDeclareMajorVariables();

// scales delay by range, so the closest creatures gets affected first
float GetDelayByRange(float fMinimumTime, float MaximumTime, float fRange, float fMaxRange);

//remove temporary hitpoints from certain spell
void RemoveTempHP(int nSpellId, object oCreature=OBJECT_SELF);//new function that replaces the one from nw_i0_spells
                                                              //was put here for compatibility reasons
//special workaround for AOEs in order to be able to get proper informations that
//cannot be acquired there
//nAreaEffectId - match row number in vfx_persistent.2da
//scriptHeartbeat - heartbeat script, if any
//numRounds - optional parameter to fix issue in some modules where AOEs last longer than should
object spellsSetupNewAOE(int nAreaEffectId, string scriptHeartbeat = "", int numRounds = -1);

//special workaround for destroying/dispelling AOE in order to remove AOE owner's effects
void aoesCheckStillValid(object oAOE, object oOwner, object oCreator, int nSpellId);

// * returns true if the creature belongs to nRacialType based on racial type and local override variable
int spellsIsRacialType(object oCreature, int nRacialType);

// * returns true if the creature doesn't have to breath or can breath water
int spellsIsImmuneToDrown(object oCreature);

// * returns true if the creature is immune to polymorphing
int spellsIsImmuneToPolymorph(object oCreature);

// * returns true if the creature is sightless
int spellsIsSightless(object oCreature);

// * returns true if the abrupt exposure to bright light is harmful to given creature
int spellsIsLightVulnerable(object oCreature);

// * Returns true if creature cannot hear: is silenced or deaf
int GetIsAbleToHear(object oCreature);

// * Returns true if creature cannot see: is blind or sightless
int GetIsAbleToSee(object oCreature);

// Convert nDuration into a number of seconds depending on the settings of spell.DurationType
float DurationToSeconds(int nDuration);

// Use this in spell scripts to get nDamage adjusted by oTarget's saving throws and
// evasion saves.
// - nDamage
// - oTarget
// - nDC: Difficulty check
// - nSavingThrow: SAVING_THROW_*
// - nSaveType: SAVING_THROW_TYPE_*
// - oSaveVersus
int GetSavingThrowAdjustedDamage(int nDamage, object oTarget, int nDC, int nSavingThrow, int nSaveType=SAVING_THROW_TYPE_NONE, object oSaveVersus=OBJECT_SELF);

// * Returns level of the spell for given nClass
int GetSpellLevel(int nSpell, int nClass);

// * Returns true if creature has enough base ability score to cast a speells of level nSpellLevel
int GetSpellMinAbilityMet(object oCreature, int nClass, int nSpellLevel);

// This function will casts a spell instantly. This is cheat/fake spell and caster doesn't need to have
// the spell prepared, thus this function will not decrement uses per day. Spell will have DC equal to
// 13+Innate Spell Level. Function will automatically exchange target for target's location if used with
// spell that is normally cast at location and not object.
// Note: this is actually not an action, it will fire the spell instantly thus
// bypassing usual action order, use ActionDoCommand to turn this into an action.
// The generated spell effects, if any, will have incorrect spell_id (either -1 or matching last spell cast).
// Without running with nwnx_patch or nwncx_patch, generated spell effects will also have incorrect caster level.
// Function parameters:
// - nSpell: SPELL_*
// - oTarget: Target for the spell, OBJECT_INVALID if you want to cast spell at location
// - nMetamagic: METAMAGIC_* supports also multiple metamagic at once
// - nLevel: caster level at which the spell will be cast
void ActionCastCheatSpellAtObject(int nSpell, object oTarget, int nMetaMagic, int nLevel);

// returns AOE radius
float GetAreaOfEffectRadius(int nAreaEffectId);

struct spells
{
    int
        Id,
        DC,
        Level,
        Class,
        DamageCap,
        Dice,
        DamageType,
        Meta,
        DurationType,
        Limit,
        SavingThrow,
        TargetType,
        SR,
        SaveType,
        DmgVfxS,
        DmgVfxL;
    float
        Range;
    object
        Caster,
        Target,
        Item;
    location
        Loc;
};

struct aoes
{
    object
        AOE,
        Creator,
        Owner;
};

struct aoes aoe;
struct spells spell;

void spellsDeclareMajorVariables()
{
    spell.Caster = OBJECT_SELF;
    spell.Target = GetSpellTargetObject();

    object overrideTarget = GetLocalObject(spell.Caster, "SPELL_TARGET_OVERRIDE");
    if(GetIsObjectValid(overrideTarget))
    {
        spell.Target = overrideTarget;
    }
    // %%%%костыль%%%
    // дефолтная функция почему-то глючит и периодически возвращает последнюю шмотку, банку и т д
    // которую юзал игрок на которого кастуют, пришлось добавить дополнительный чек, т. к. стандартная
    // функция работает нормально, если вызывается на самом кастере
    if (spell.Caster != spell.Target)
        spell.Item = GetLocalObject(spell.Caster, "SPELLCAST_ITEM");
    else
        spell.Item = GetSpellCastItem();

    spell.Level = GetCasterLevel(spell.Caster);
    spell.Loc = GetSpellTargetLocation();

    location overrideLocation = GetLocalLocation(spell.Caster,"SPELL_TARGET_OVERRIDE");
    if(GetIsObjectValid(GetAreaFromLocation(overrideLocation)))
    {
        spell.Loc = overrideLocation;
    }

    spell.Id = GetSpellId();
    spell.DC = GetSpellSaveDC();

    if(!spell.SR) spell.SR = TRUE;//unless SR is disabled, we assume its enabled
    //if(!spell.Class) spell.Class = GetLastSpellCastClass();//support for feats
    if(!spell.Class) spell.Class = GetLocalInt(spell.Caster, "LAST_CASTER_SPELL_CLASS");

    spell.Meta = GetMetaMagicFeat();

    if(GetLocalInt(spell.Caster, "CHEAT_SPELL") > 0)//Cheat spell
    {
        spell.Id = GetLocalInt(spell.Caster, "CHEAT_SPELL") - 1;
        spell.DC = 13 + StringToInt(Get2DAString("spells", "Innate", spell.Id));
        spell.Item = OBJECT_INVALID;
        spell.Class = CLASS_TYPE_INVALID;
        spell.Meta = METAMAGIC_NONE;
    }
    if(spell.DC > 126)//DC bug with negative primary ability
    {
        string primaryAbil = Get2DAString("classes", "PrimaryAbil", spell.Class);//gets the class' primary ability, using 2da for "globallity"
        int nAbility = ABILITY_CHARISMA;// default ability is charisma
        if(primaryAbil == "STR") nAbility = ABILITY_STRENGTH;
        else if(primaryAbil == "DEX") nAbility = ABILITY_DEXTERITY;
        else if(primaryAbil == "CON") nAbility = ABILITY_CONSTITUTION;
        else if(primaryAbil == "WIS") nAbility = ABILITY_WISDOM;
        else if(primaryAbil == "INT") nAbility = ABILITY_INTELLIGENCE;
        spell.DC = 10+GetLevelByClass(spell.Class,spell.Caster)+GetAbilityModifier(nAbility,spell.Caster);//lets recalculate the DC on our own
    }
    if(GetIsObjectValid(spell.Item) || spell.Meta == METAMAGIC_ANY || spell.Meta < 0)
    {  //odd behavior when spell was cast from item             //bug in actioncastspell
        spell.Meta = METAMAGIC_NONE;//spells from items won't have metamagic now
    }
    else if((spell.Meta == METAMAGIC_EMPOWER && !GetHasFeat(FEAT_EMPOWER_SPELL, spell.Caster)) || (spell.Meta == METAMAGIC_MAXIMIZE && !GetHasFeat(FEAT_MAXIMIZE_SPELL, spell.Caster)))
    {
        spell.Meta = METAMAGIC_NONE;//metamagic exploit with polymorph into Rakshasa
    }
    string sPrefix, sId = IntToString(spell.Id);
    object oSource = GetIsObjectValid(spell.Item) ? spell.Item : spell.Caster;
    //spell informations overrides on a local (caster/item) basis by spell id
    int overrideLevel = GetLocalInt(oSource,sId+"_CASTER_LEVEL_OVERRIDE");
    int overrideDC = GetLocalInt(oSource,sId+"_DC_OVERRIDE");
    int overrideMeta = GetLocalInt(oSource,sId+"_METAMAGIC_OVERRIDE");
    int overrideDamageCap = GetLocalInt(oSource,sId+"_DAMAGE_CAP_OVERRIDE");
    int overrideDurationType = GetLocalInt(oSource,sId+"_DURATION_TYPE_OVERRIDE");
    float overrideRange = GetLocalFloat(oSource,sId+"_RANGE_OVERRIDE");
    int overrideTargetType = GetLocalInt(oSource,sId+"_TARGET_TYPE_OVERRIDE");
    int overrideDamageType = GetLocalInt(oSource,sId+"_DAMAGE_TYPE_OVERRIDE");
    int overrideSavingThrow = GetLocalInt(oSource,sId+"_SAVING_THROW_OVERRIDE");
    int overrideSR = GetLocalInt(oSource,sId+"_SR_OVERRIDE");
    int overrideLimit = GetLocalInt(oSource,sId+"_LIMIT_OVERRIDE");
    int overrideDice = GetLocalInt(oSource,sId+"_DICE_OVERRIDE");

    if(oSource == spell.Item)
        sPrefix = "ITEM";
    else if(spell.Class == CLASS_TYPE_INVALID)
        sPrefix = "SPECIAL_ABILITY";
    else
        sPrefix = "SPELL";

    //spell informations overrides on a local (caster/item) basis by spell type (spell from item/special ability/regular spell)
    if(!overrideLevel) overrideLevel = GetLocalInt(oSource,sPrefix+"_CASTER_LEVEL_OVERRIDE");
    if(!overrideDC) overrideDC = GetLocalInt(oSource,sPrefix+"_DC_OVERRIDE");
    if(!overrideMeta) overrideMeta = GetLocalInt(oSource,sPrefix+"_METAMAGIC_OVERRIDE");
    if(!overrideDamageCap) overrideDamageCap = GetLocalInt(oSource,sPrefix+"_DAMAGE_CAP_OVERRIDE");
    if(!overrideDurationType) overrideDurationType = GetLocalInt(oSource,sPrefix + "_DURATION_TYPE_OVERRIDE");
    if(overrideRange == 0.0) overrideRange = GetLocalFloat(oSource,sPrefix+"_RANGE_OVERRIDE");
    if(!overrideTargetType) overrideTargetType = GetLocalInt(oSource,sPrefix+"_TARGET_TYPE_OVERRIDE");
    if(!overrideDamageType) overrideDamageType = GetLocalInt(oSource,sPrefix+"_DAMAGE_TYPE_OVERRIDE");
    if(!overrideSavingThrow) overrideSavingThrow = GetLocalInt(oSource,sPrefix+"_SAVING_THROW_OVERRIDE");
    if(!overrideSR) overrideSR = GetLocalInt(oSource,sPrefix+"_SR_OVERRIDE");
    if(!overrideLimit) overrideLimit = GetLocalInt(oSource,sPrefix+"_LIMIT_OVERRIDE");
    if(!overrideDice) overrideDice = GetLocalInt(oSource,sPrefix+"_DICE_OVERRIDE");

    //spell informations overrides on a global module basis by spell id
    object oModule = GetModule();
    if(!overrideDamageCap) overrideDamageCap = GetLocalInt(oModule,sId+"_DAMAGE_CAP_OVERRIDE");
    if(!overrideDurationType) overrideDurationType = GetLocalInt(oModule,sId+"_DURATION_TYPE_OVERRIDE");
    if(overrideRange == 0.0) overrideRange = GetLocalFloat(oModule,sId+"_RANGE_OVERRIDE");
    if(!overrideTargetType) overrideTargetType = GetLocalInt(oModule,sId+"_TARGET_TYPE_OVERRIDE");
    if(!overrideDamageType) overrideDamageType = GetLocalInt(oModule,sId+"_DAMAGE_TYPE_OVERRIDE");
    if(!overrideSavingThrow) overrideSavingThrow = GetLocalInt(oModule,sId+"_SAVING_THROW_OVERRIDE");
    if(!overrideSR) overrideSR = GetLocalInt(oModule,sId+"_SR_OVERRIDE");
    if(!overrideLimit) overrideLimit = GetLocalInt(oModule,sId+"_LIMIT_OVERRIDE");
    if(!overrideDice) overrideDice = GetLocalInt(oModule,sId+"_DICE_OVERRIDE");
    //pushing overriden values into the structure
    if(overrideLevel > 0) spell.Level = overrideLevel;
    if(overrideDC > 0) spell.DC = overrideDC;
    if(overrideMeta > 0) spell.Meta = overrideMeta;
    if(overrideDamageCap > 0) spell.DamageCap = overrideDamageCap;
    if(overrideDurationType > 0) spell.DurationType = overrideDurationType;
    if(overrideRange > 0.0) spell.Range = overrideRange;
    if(overrideTargetType > 0) spell.TargetType = overrideTargetType;
    if(overrideDamageType > 0) spell.DamageType = overrideDamageType;
    if(overrideSavingThrow > 0) spell.SavingThrow = overrideSavingThrow;
    if(overrideSR != 0) spell.SR = overrideSR;
    if(overrideLimit > 0) spell.Limit = overrideLimit;
    if(overrideDice > 0) spell.Dice = overrideDice;
    //spell informations modifier feature
    spell.Level+= GetLocalInt(oSource,sPrefix+"_CASTER_LEVEL_MODIFIER");
    spell.Meta|= GetLocalInt(oSource,sPrefix+"_METAMAGIC_MODIFIER");
    spell.DC+= GetLocalInt(oSource,sPrefix+"_DC_MODIFIER");
    spell.DC+= GetLocalInt(oModule,sId+"_DC_MODIFIER");
    spell.DamageCap+= GetLocalInt(oSource,sPrefix+"_DAMAGE_CAP_MODIFIER");
    spell.DamageCap+= GetLocalInt(oModule,sId+"_DAMAGE_CAP_MODIFIER");
    spell.DurationType+= GetLocalInt(oSource,sPrefix+"_DURATION_TYPE_MODIFIER");
    spell.Range+= GetLocalFloat(oSource,sPrefix+"_RANGE_MODIFIER");
    //support for new metamagic itemproperty, works as modifier
    if(spell.Item != OBJECT_INVALID)
    {
        if(GetItemHasItemProperty(spell.Item, 68))
        {
            itemproperty ip = GetFirstItemProperty(spell.Item);
            while(GetIsItemPropertyValid(ip))
            {
                if(GetItemPropertyType(ip) == 68)
                {
                    spell.Meta|= GetItemPropertySubType(ip);
                }
                ip = GetNextItemProperty(spell.Item);
            }
        }
    }

    if(spell.Level < 1)//sanity check, this should never happen
    {
        spell.Level = 1;
    }
    //preparing some damage-spell specific constants
    switch(spell.DamageType)
    {
        case DAMAGE_TYPE_ACID:
            spell.SaveType = SAVING_THROW_TYPE_ACID;
            spell.DmgVfxS = VFX_IMP_ACID_S;
            spell.DmgVfxL = VFX_IMP_ACID_L;
        break;
        case DAMAGE_TYPE_FIRE:
            spell.SaveType = SAVING_THROW_TYPE_FIRE;
            spell.DmgVfxS = VFX_IMP_FLAME_S;
            spell.DmgVfxL = VFX_IMP_FLAME_M;
        break;
        case DAMAGE_TYPE_ELECTRICAL:
            spell.SaveType = SAVING_THROW_TYPE_ELECTRICITY;
            spell.DmgVfxS = VFX_IMP_LIGHTNING_S;
            spell.DmgVfxL = VFX_IMP_LIGHTNING_S;
        break;
        case DAMAGE_TYPE_SONIC:
            spell.SaveType = SAVING_THROW_TYPE_SONIC;
            spell.DmgVfxS = VFX_IMP_SONIC;
            spell.DmgVfxL = VFX_IMP_SONIC;
        break;
        case DAMAGE_TYPE_COLD:
            spell.SaveType = SAVING_THROW_TYPE_COLD;
            spell.DmgVfxS = VFX_IMP_FROST_S;
            spell.DmgVfxL = VFX_IMP_FROST_L;
        break;
        case DAMAGE_TYPE_DIVINE:
            spell.SaveType = SAVING_THROW_TYPE_DIVINE;
            spell.DmgVfxS = VFX_IMP_SUNSTRIKE;
            spell.DmgVfxL = VFX_IMP_SUNSTRIKE;
        break;
        case DAMAGE_TYPE_NEGATIVE:
            spell.SaveType = SAVING_THROW_TYPE_NEGATIVE;
            spell.DmgVfxS = VFX_IMP_NEGATIVE_ENERGY;
            spell.DmgVfxL = VFX_IMP_NEGATIVE_ENERGY;
        break;
        case DAMAGE_TYPE_POSITIVE:
            spell.SaveType = SAVING_THROW_TYPE_POSITIVE;
            spell.DmgVfxS = VFX_IMP_SUNSTRIKE;
            spell.DmgVfxL = VFX_IMP_SUNSTRIKE;
        break;
        case DAMAGE_TYPE_MAGICAL:
            spell.SaveType = SAVING_THROW_TYPE_NONE;
            spell.DmgVfxS = VFX_IMP_MAGBLUE;
            spell.DmgVfxL = VFX_IMP_MAGBLUE;
        break;
        case DAMAGE_TYPE_PIERCING:
        case DAMAGE_TYPE_SLASHING:
        case DAMAGE_TYPE_BLUDGEONING:
            spell.SaveType = SAVING_THROW_TYPE_NONE;
            spell.DmgVfxS = VFX_COM_BLOOD_REG_RED;
            spell.DmgVfxL = VFX_COM_BLOOD_LRG_RED;
        break;
        default:
            spell.SaveType = SAVING_THROW_TYPE_NONE;
            spell.DmgVfxS = VFX_IMP_FEAR_S;
            spell.DmgVfxL = VFX_IMP_FEAR_S;
        break;
    }
}

void aoesDeclareMajorVariables()
{
    aoe.AOE = OBJECT_SELF;
    aoe.Creator = GetAreaOfEffectCreator(aoe.AOE);
    aoe.Owner = GetLocalObject(aoe.AOE, "AOE_OWNER");

    if(aoe.Owner == OBJECT_INVALID)
    {
        aoe.Owner = aoe.Creator;
    }

    spell.Id = GetSpellId();
    spell.Class = GetLocalInt(aoe.AOE, "AOE_CLASS") - 1;
    spell.DC = GetLocalInt(aoe.AOE, "AOE_DC");

    if(spell.DC < 1)
    {
        spell.DC = GetSpellSaveDC();
    }

    spell.Level = GetLocalInt(aoe.AOE, "AOE_LEVEL");

    if(spell.Level < 1)
    {
        spell.Level = GetCasterLevel(aoe.Creator);
    }

    spell.Meta = GetLocalInt(aoe.AOE, "AOE_META")-1;

    if(spell.Meta < 0)
    {
        spell.Meta = GetMetaMagicFeat();
    }

    if(spell.Level < 1)//sanity check, this should never happen
    {
        spell.Level = 1;
    }

    int aoeDamageCap = GetLocalInt(aoe.AOE, "AOE_DAMAGECAP");

    if(aoeDamageCap > 0)
    {
        spell.DamageCap = aoeDamageCap;
    }

    int aoeTargetType = GetLocalInt(aoe.AOE, "AOE_TARGETTYPE");

    if(aoeTargetType > 0)
    {
        spell.TargetType = aoeTargetType;
    }

    int aoeDurationType = GetLocalInt(aoe.AOE, "AOE_DURTYPE");

    if(aoeDurationType > 0)
    {
        spell.DurationType = aoeDurationType;
    }

    float aoeRange = GetLocalFloat(aoe.AOE, "AOE_RANGE");

    if(aoeRange > 0.0)
    {
        spell.Range = aoeRange;
    }

    int aoeLimit = GetLocalInt(aoe.AOE, "AOE_LIMIT");

    if(aoeLimit > 0)
    {
        spell.Limit = aoeLimit;
    }

    int aoeDamageType = GetLocalInt(aoe.AOE, "AOE_DAMAGETYPE");

    if(aoeDamageType > 0)
    {
        spell.DamageType = aoeDamageType;
    }

    int aoeSavingThrow = GetLocalInt(aoe.AOE, "AOE_SAVINGTHROW");

    if(aoeSavingThrow > 0)
    {
        spell.SavingThrow = aoeSavingThrow;
    }

    int aoeDice = GetLocalInt(aoe.AOE, "AOE_DICE");

    if(aoeDice > 0)
    {
        spell.Dice = aoeDice;
    }

    int aoeSR = GetLocalInt(aoe.AOE, "AOE_SR");

    if(aoeSR > 0)
    {
        spell.SR = aoeSR;
    }

    //preparing some damage-spell specific constants
    switch(spell.DamageType)
    {
        case DAMAGE_TYPE_ACID:
            spell.SaveType = SAVING_THROW_TYPE_ACID;
            spell.DmgVfxS = VFX_IMP_ACID_S;
            spell.DmgVfxL = VFX_IMP_ACID_L;
        break;
        case DAMAGE_TYPE_FIRE:
            spell.SaveType = SAVING_THROW_TYPE_FIRE;
            spell.DmgVfxS = VFX_IMP_FLAME_S;
            spell.DmgVfxL = VFX_IMP_FLAME_M;
        break;
        case DAMAGE_TYPE_ELECTRICAL:
            spell.SaveType = SAVING_THROW_TYPE_ELECTRICITY;
            spell.DmgVfxS = VFX_IMP_LIGHTNING_S;
            spell.DmgVfxL = VFX_IMP_LIGHTNING_S;
        break;
        case DAMAGE_TYPE_SONIC:
            spell.SaveType = SAVING_THROW_TYPE_SONIC;
            spell.DmgVfxS = VFX_IMP_SONIC;
            spell.DmgVfxL = VFX_IMP_SONIC;
        break;
        case DAMAGE_TYPE_COLD:
            spell.SaveType = SAVING_THROW_TYPE_COLD;
            spell.DmgVfxS = VFX_IMP_FROST_S;
            spell.DmgVfxL = VFX_IMP_FROST_L;
        break;
        case DAMAGE_TYPE_DIVINE:
            spell.SaveType = SAVING_THROW_TYPE_DIVINE;
            spell.DmgVfxS = VFX_IMP_SUNSTRIKE;
            spell.DmgVfxL = VFX_IMP_SUNSTRIKE;
        break;
        case DAMAGE_TYPE_NEGATIVE:
            spell.SaveType = SAVING_THROW_TYPE_NEGATIVE;
            spell.DmgVfxS = VFX_IMP_NEGATIVE_ENERGY;
            spell.DmgVfxL = VFX_IMP_NEGATIVE_ENERGY;
        break;
        case DAMAGE_TYPE_POSITIVE:
            spell.SaveType = SAVING_THROW_TYPE_POSITIVE;
            spell.DmgVfxS = VFX_IMP_SUNSTRIKE;
            spell.DmgVfxL = VFX_IMP_SUNSTRIKE;
        break;
        case DAMAGE_TYPE_MAGICAL:
            spell.SaveType = SAVING_THROW_TYPE_NONE;
            spell.DmgVfxS = VFX_IMP_MAGBLUE;
            spell.DmgVfxL = VFX_IMP_MAGBLUE;
        break;
        case DAMAGE_TYPE_PIERCING:
        case DAMAGE_TYPE_SLASHING:
        case DAMAGE_TYPE_BLUDGEONING:
            spell.SaveType = SAVING_THROW_TYPE_NONE;
            spell.DmgVfxS = VFX_COM_BLOOD_REG_RED;
            spell.DmgVfxL = VFX_COM_BLOOD_LRG_RED;
        break;
        default:
            spell.SaveType = SAVING_THROW_TYPE_NONE;
            spell.DmgVfxS = VFX_IMP_FEAR_S;
            spell.DmgVfxL = VFX_IMP_FEAR_S;
        break;
    }
}

float DurationToSeconds(int nDuration)
{
    if(spell.DurationType == SPELL_DURATION_TYPE_HOURS_2MINUTES)
    {
        nDuration*= 2;
    }
    float fOverride;
    if(spell.Item != OBJECT_INVALID)//spell cast from item, check variables on item then
    {
        fOverride = GetLocalFloat(spell.Item, IntToString(spell.Id) + "_DURATION_OVERRIDE");
    if(fOverride == 0.0)
    {
        fOverride = GetLocalFloat(spell.Item, "ITEM_DURATION_OVERRIDE");
    }
    nDuration += GetLocalInt(spell.Item, "ITEM_DURATION_MODIFIER");
    nDuration += GetLocalInt(spell.Item, IntToString(spell.Id) + "_DURATION_MODIFIER");
    }
    else if(spell.Class == CLASS_TYPE_INVALID)//special ability
    {
        fOverride = GetLocalFloat(OBJECT_SELF, IntToString(spell.Id) + "_DURATION_OVERRIDE");
        if(fOverride == 0.0)
        {
            fOverride = GetLocalFloat(OBJECT_SELF, "SPECIAL_ABILITY_DURATION_OVERRIDE");
        }
        nDuration += GetLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_DURATION_MODIFIER");
        nDuration += GetLocalInt(OBJECT_SELF,IntToString(spell.Id) + "_DURATION_MODIFIER");
    }
    else//normal spell
    {
        fOverride = GetLocalFloat(OBJECT_SELF, IntToString(spell.Id) + "_DURATION_OVERRIDE");
        if(fOverride == 0.0)
        {
            fOverride = GetLocalFloat(OBJECT_SELF, "SPELL_DURATION_OVERRIDE");
        }
        nDuration+= GetLocalInt(OBJECT_SELF, "SPELL_DURATION_MODIFIER");
        nDuration+= GetLocalInt(OBJECT_SELF, IntToString(spell.Id) + "_DURATION_MODIFIER");
    }
    if(fOverride > 0.0)
    {
        return fOverride;
    }
    if(spell.DurationType == SPELL_DURATION_TYPE_SECONDS)
    {
        return nDuration*1.0;
    }
    else if(spell.DurationType == SPELL_DURATION_TYPE_ROUNDS)
    {
        return RoundsToSeconds(nDuration);
    }
    else if(spell.DurationType == SPELL_DURATION_TYPE_TURNS || spell.DurationType == SPELL_DURATION_TYPE_HOURS_2MINUTES)
    {
        return TurnsToSeconds(nDuration);
    }
    else if(spell.DurationType >= SPELL_DURATION_TYPE_HOURS)
    {
        return HoursToSeconds(nDuration);
    }
    WriteTimestampedLogEntry("DurationToSeconds: ERROR, spell "+IntToString(spell.Id)+" doesn't have correctly initialized duration type, using rounds!");
    return RoundsToSeconds(nDuration);
}

int GetSavingThrowAdjustedDamage(int nDamage, object oTarget, int nDC, int nSavingThrow, int nSaveType=SAVING_THROW_TYPE_NONE, object oSaveVersus=OBJECT_SELF)
{
    if(nSavingThrow == SAVING_THROW_REFLEX)
    {
        /* cormyr fix
        if((!GetHasFeat(FEAT_EVASION, oTarget) && !GetHasFeat(FEAT_IMPROVED_EVASION, oTarget)) ||
            (GetModuleSwitchValue("72_HARDCORE_EVASION_RULES") && !GetEvasionApplicable(oTarget)))
        {
            nDC = ReflexSave(oTarget, nDC, nSaveType, oSaveVersus);
            if(nDC == 1)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE), oTarget);
                nDamage /= 2;
            }
            else if(nDC == 2)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE), oTarget);
            }
        }
        else
        {
            nDamage = GetReflexAdjustedDamage(nDamage, oTarget, nDC, nSaveType, oSaveVersus);
        }  */

        nDC = ReflexSave(oTarget, nDC, nSaveType, oSaveVersus);

        if     (nDC == 1) // 1/2 dmg for imp evasion or 3/4 for other on successful save
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE), oTarget);
            if(GetHasFeat(FEAT_IMPROVED_EVASION, oTarget))
                nDamage /= 2;
            else
                nDamage = 3 * nDamage / 4;
        }
        else if(nDC == 2)
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE), oTarget);
    }
    else if(nSavingThrow == SAVING_THROW_FORT)
    {
        nDC = FortitudeSave(oTarget,nDC,nSaveType,oSaveVersus);
        if(nDC == 1)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE),oTarget);
            nDamage /= 2;
        }
        else if(nDC == 2)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE),oTarget);
        }
        return nDamage;
    }
    else if(nSavingThrow == SAVING_THROW_WILL)
    {
        nDC = WillSave(oTarget,nDC,nSaveType,oSaveVersus);
        if(nDC == 1)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE),oTarget);
            nDamage /= 2;
        }
        else if(nDC == 2)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE),oTarget);
        }
    }
    return nDamage;
}

float GetDelayByRange(float fMinimumTime, float MaximumTime, float fRange, float fMaxRange)
{
    return fMinimumTime+(MaximumTime-fMinimumTime)*(fRange/fMaxRange);
}

void RemoveTempHP(int nSpellId, object oCreature=OBJECT_SELF)
{
    effect eSearch = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eSearch))
    {
        if(GetEffectType(eSearch) == EFFECT_TYPE_TEMPORARY_HITPOINTS && GetEffectSpellId(eSearch) == nSpellId)
        {
            RemoveEffect(oCreature,eSearch);
        }
        eSearch = GetNextEffect(oCreature);
    }
}

object spellsSetupNewAOE(int nAreaEffectId, string scriptHeartbeat = "", int numRounds = -1)
{
    int nTh;
    string sTag = GetStringUpperCase(Get2DAString("vfx_persistent", "label", nAreaEffectId));
    object oNew, oAOE = sTag != "" ? GetObjectByTag(sTag) : GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, spell.Loc, ++nTh);
    while(oAOE != OBJECT_INVALID)
    {
        if((sTag == "" || GetTag(oAOE) == sTag) && GetAreaOfEffectCreator(oAOE) == spell.Caster &&
            GetLocalObject(oAOE, "AOE_OWNER") == OBJECT_INVALID)
        {
            object oAoEOwner = spell.Target == OBJECT_INVALID ? spell.Caster : spell.Target;
            SetLocalObject(oAOE, "AOE_OWNER", oAoEOwner);
            SetLocalInt(oAOE, "AOE_ID", spell.Id);
            SetLocalInt(oAOE, "AOE_DC", spell.DC);
            SetLocalInt(oAOE, "AOE_META", spell.Meta + 1);
            SetLocalInt(oAOE, "AOE_LEVEL", spell.Level);
            SetLocalInt(oAOE, "AOE_CLASS", spell.Class + 1);
            SetLocalInt(oAOE, "AOE_DAMAGECAP", spell.DamageCap);
            SetLocalInt(oAOE, "AOE_DURTYPE", spell.DurationType);
            SetLocalInt(oAOE, "AOE_TARGETTYPE", spell.TargetType);
            SetLocalFloat(oAOE, "AOE_RANGE", GetAreaOfEffectRadius(nAreaEffectId));
            SetLocalInt(oAOE, "AOE_LIMIT", spell.Limit);
            SetLocalInt(oAOE, "AOE_DAMAGETYPE", spell.DamageType);
            SetLocalInt(oAOE, "AOE_SAVINGTHROW", spell.SavingThrow);
            SetLocalInt(oAOE, "AOE_DICE", spell.Dice);
            SetLocalInt(oAOE, "AOE_SR", spell.SR);
            SetLocalInt(oAOE, "AOE_DURATION", numRounds + 1);
            SetLocalObject(oAoEOwner, "OWNER_" + IntToString(spell.Id), oAOE);

            if(scriptHeartbeat != "")
                SetEventScript(oAOE, EVENT_SCRIPT_AREAOFEFFECT_ON_HEARTBEAT, scriptHeartbeat);

            int nAoeDelay = GetModuleSwitchValue("CORMYR_NO_1_ROUND_AOE_DELAY");
            if(nAoeDelay)
            {
                string sEventHeartBeatScript = GetEventScript(oAOE, EVENT_SCRIPT_AREAOFEFFECT_ON_HEARTBEAT);
                float fDelay = IntToFloat(nAoeDelay);
                AssignCommand(oAOE, DelayCommand(fDelay, ExecuteScript(sEventHeartBeatScript, oAOE)));
            }
            oNew = oAOE;
        }
        oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, spell.Loc, ++nTh);
    }
    int nLimit = GetModuleSwitchValue("72_DISABLE_AOE_SPELLS_STACKING");
    if(nLimit > 0 && oNew != OBJECT_INVALID)
    {
        nTh = 1;
        oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, spell.Loc, nTh);
        while(oAOE != OBJECT_INVALID)
        {
            if(oAOE != oNew && GetAreaOfEffectCreator(oAOE) == spell.Caster && GetLocalInt(oAOE, "AOE_ID") == spell.Id)
            {
                if(--nLimit < 1)
                {
                    ExecuteScript("_plc_aoe_destroy", oAOE);
                    DestroyObject(oAOE);
                }
            }
            oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, spell.Loc, ++nTh);
        }
    }
    return oNew;
}

void aoesCheckStillValid_continue(object oAOE, object oOwner, object oCreator, int nSpellId)//private
{
    if(!GetIsObjectValid(oAOE))
    {
        effect eSearch = GetFirstEffect(oOwner);
        while(GetIsEffectValid(eSearch))
        {
            if(GetEffectSpellId(eSearch) == nSpellId && GetEffectCreator(eSearch) == oCreator)
            {
                RemoveEffect(oOwner,eSearch);
            }
            eSearch = GetNextEffect(oOwner);
        }
    }
}

void aoesCheckStillValid(object oAOE, object oOwner, object oCreator, int nSpellId)
{
    object AOE = GetLocalObject(oOwner,"OWNER_"+IntToString(nSpellId));
    if(GetIsObjectValid(AOE) && AOE == oAOE)
    {
        effect eAOE = GetFirstEffect(oOwner);
        while(GetIsEffectValid(eAOE))
        {
            if(GetEffectSpellId(eAOE) == nSpellId && GetEffectCreator(eAOE) == oCreator &&
                GetEffectType(eAOE) == EFFECT_TYPE_AREA_OF_EFFECT)
            {
                AssignCommand(oOwner, DelayCommand(0.1,aoesCheckStillValid_continue(oAOE,oOwner,oCreator,nSpellId)));
                return;//new instance, its OK
            }
            eAOE = GetNextEffect(oOwner);
        }
    }
}

int GetIsAbleToHear(object oCreature)
{
    effect eSearch = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eSearch))
    {
        switch(GetEffectType(eSearch))
        {
            case EFFECT_TYPE_SILENCE:
            case EFFECT_TYPE_DEAF:
            return FALSE;
        }
        eSearch = GetNextEffect(oCreature);
    }
    return TRUE;
}

int GetIsAbleToSee(object oCreature)
{
    if(spellsIsSightless(oCreature)) return FALSE;
    int bSee,bDark;
    effect eSearch = GetFirstEffect(oCreature);
    while(GetIsEffectValid(eSearch))
    {
        switch(GetEffectType(eSearch))
        {
            case EFFECT_TYPE_DARKNESS:
                bDark = TRUE;
            break;
            case EFFECT_TYPE_ULTRAVISION:
            case EFFECT_TYPE_TRUESEEING:
                bSee = TRUE;
            break;
            case EFFECT_TYPE_BLINDNESS:
            return FALSE;
        }
        eSearch = GetNextEffect(oCreature);
    }
    return !bDark || bSee;
}

int spellsIsImmuneToDrown(object oCreature)
{//undead, construct and any creature that doesn't breath or can breath water are immune to the drown effect
    if(spellsIsRacialType(oCreature, RACIAL_TYPE_UNDEAD) || spellsIsRacialType(oCreature, RACIAL_TYPE_CONSTRUCT) ||
       spellsIsRacialType(oCreature, RACIAL_TYPE_ELEMENTAL) || spellsIsRacialType(oCreature, RACIAL_TYPE_OOZE))
    {
        return TRUE;
    }
    switch(GetAppearanceType(oCreature))
    {
    case APPEARANCE_TYPE_WYRMLING_BLACK:
    case APPEARANCE_TYPE_WYRMLING_GREEN:
    case APPEARANCE_TYPE_WYRMLING_BRONZE:
    case APPEARANCE_TYPE_WYRMLING_GOLD:
    case APPEARANCE_TYPE_DRAGON_BLACK:
    case APPEARANCE_TYPE_DRAGON_GREEN:
    case APPEARANCE_TYPE_DRAGON_BRONZE:
    case APPEARANCE_TYPE_DRAGON_GOLD:
    case APPEARANCE_TYPE_SAHUAGIN:
    case APPEARANCE_TYPE_SAHUAGIN_CLERIC:
    case APPEARANCE_TYPE_SAHUAGIN_LEADER:
    case APPEARANCE_TYPE_SEA_HAG:
    case APPEARANCE_TYPE_MEPHIT_OOZE:
    case APPEARANCE_TYPE_MEPHIT_WATER:
    case APPEARANCE_TYPE_SHARK_GOBLIN:
    case APPEARANCE_TYPE_SHARK_MAKO:
    case APPEARANCE_TYPE_SHARK_HAMMERHEAD:
        return TRUE;
    }
    return GetLocalInt(oCreature,"IMMUNITY_DROWN");
}

int spellsIsImmuneToPolymorph(object oCreature)
{//oozes, plants, incorporeal creatures and specific creatures are immune to polymorphing, shapeshifters aren't but are allowed to polymorph back
    if(spellsIsRacialType(oCreature, RACIAL_TYPE_OOZE))
    {
        return TRUE;
    }
    else if(GetLocalInt(oCreature,"X2_L_IS_INCORPOREAL") || GetAppearanceType(oCreature) == APPEARANCE_TYPE_SPECTRE)
    {
        return TRUE;
    }
    else if(FindSubString(GetStringLowerCase(GetSubRace(oCreature)),"plant") > -1)
    {
        return TRUE;
    }
    switch(GetAppearanceType(oCreature))
    {
    case APPEARANCE_TYPE_LICH:
    case APPEARANCE_TYPE_DEMI_LICH:
    case APPEARANCE_TYPE_DRACOLICH:
    case 464://Masterius
    case 465://Masterius, Full Power
    case 466://Witch King, Disguised
        return TRUE;
    }
    return GetLocalInt(oCreature,"IMMUNITY_POLYMORPH");
}

int spellsIsSightless(object oCreature)
{
    switch(GetAppearanceType(oCreature))
    {
    case APPEARANCE_TYPE_GELATINOUS_CUBE:
    case APPEARANCE_TYPE_GRAY_OOZE:
    case APPEARANCE_TYPE_OCHRE_JELLY_SMALL:
    case APPEARANCE_TYPE_OCHRE_JELLY_MEDIUM:
    case APPEARANCE_TYPE_OCHRE_JELLY_LARGE:
        return TRUE;
    }
    return GetLocalInt(oCreature,"SIGHTLESS");
}

int spellsIsLightVulnerable(object oCreature)
{
    switch(GetAppearanceType(oCreature))
    {
    case APPEARANCE_TYPE_SAHUAGIN:
    case APPEARANCE_TYPE_SAHUAGIN_LEADER:
    case APPEARANCE_TYPE_SAHUAGIN_CLERIC:
    case APPEARANCE_TYPE_DROW_CLERIC:
    case APPEARANCE_TYPE_DROW_FEMALE_1:
    case APPEARANCE_TYPE_DROW_FEMALE_2:
    case APPEARANCE_TYPE_DROW_FIGHTER:
    case APPEARANCE_TYPE_DROW_MATRON:
    case APPEARANCE_TYPE_DROW_SLAVE:
    case APPEARANCE_TYPE_DROW_WARRIOR_1:
    case APPEARANCE_TYPE_DROW_WARRIOR_2:
    case APPEARANCE_TYPE_DROW_WARRIOR_3:
    case APPEARANCE_TYPE_DROW_WIZARD:
    case APPEARANCE_TYPE_VAMPIRE_FEMALE:
    case APPEARANCE_TYPE_VAMPIRE_MALE:
    case APPEARANCE_TYPE_BODAK:
        return TRUE;
    }
    if(FindSubString(GetStringLowerCase(GetSubRace(oCreature)),"drow") > -1 || FindSubString(GetStringLowerCase(GetSubRace(oCreature)),"vampire") > -1)
    {   //drow or vampiure subrace, common on PCs
        return TRUE;
    }
    return GetLocalInt(oCreature,"LIGHTVULNERABLE");
}

int GetSpellLevel(int nSpell, int nClass)
{
    string sColumn, s2DA = "spells";
    switch(nClass)
    {
        case CLASS_TYPE_BARD: sColumn = "Bard"; break;
        case CLASS_TYPE_CLERIC: sColumn = "Cleric"; break;
        case CLASS_TYPE_DRUID: sColumn = "Druid"; break;
        case CLASS_TYPE_PALADIN: sColumn = "Paladin"; break;
        case CLASS_TYPE_RANGER: sColumn = "Ranger"; break;
        case CLASS_TYPE_SORCERER:
        case CLASS_TYPE_WIZARD: sColumn = "Wiz_Sorc"; break;
        default: sColumn = IntToString(nClass); s2DA = "spells_level"; break;
    }
    string sLevel = Get2DAString(s2DA,sColumn,nSpell);
    int nLevel = StringToInt(sLevel);
    if(!nLevel && sLevel != "0")
        return -1;

    return nLevel;
}

int GetSpellMinAbilityMet(object oCreature, int nClass, int nSpellLevel)
{
    string sAbility = Get2DAString("classes", "PrimaryAbil", nClass);
    int nAbilityScore;
    if(sAbility == "STR")
    {
        nAbilityScore = GetAbilityScore(oCreature, ABILITY_STRENGTH, TRUE);
    }
    else if(sAbility == "DEX")
    {
        nAbilityScore = GetAbilityScore(oCreature, ABILITY_DEXTERITY, TRUE);
    }
    else if(sAbility == "CON")
    {
        nAbilityScore = GetAbilityScore(oCreature, ABILITY_CONSTITUTION, TRUE);
    }
    else if(sAbility == "WIS")
    {
        nAbilityScore = GetAbilityScore(oCreature, ABILITY_WISDOM, TRUE);
    }
    else if(sAbility == "INT")
    {
        nAbilityScore = GetAbilityScore(oCreature, ABILITY_INTELLIGENCE, TRUE);
    }
    else
    {
        nAbilityScore = GetAbilityScore(oCreature, ABILITY_CHARISMA, TRUE);
    }
    return nAbilityScore >= 10 + nSpellLevel;
}

int spellsIsRacialType(object oCreature, int nRacialType)
{
    int nType = GetLocalInt(oCreature, "IsRacialType_" + IntToString(nRacialType));
    return !nType ? GetRacialType(oCreature) == nRacialType : nType > 0;
}

void ActionCastCheatSpellAtObject(int nSpell, object oTarget, int nMetaMagic, int nLevel)
{
    string sScript = Get2DAString("spells","ImpactScript",nSpell);
    if(sScript != "")
    {
        int prevCL = GetLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE");
        int prevMeta = GetLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_METAMAGIC_OVERRIDE");
        SetLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE", nLevel);
        SetLocalInt(OBJECT_SELF,"SPECIAL_ABILITY_METAMAGIC_OVERRIDE", nMetaMagic);
        SetLocalObject(OBJECT_SELF, "SPELL_TARGET_OVERRIDE", oTarget);
        SetLocalLocation(OBJECT_SELF, "SPELL_TARGET_OVERRIDE", GetLocation(oTarget));
        SetLocalInt(OBJECT_SELF, "CHEAT_SPELL", nSpell + 1);
        ExecuteScript(sScript, OBJECT_SELF);
        DeleteLocalInt(OBJECT_SELF, "CHEAT_SPELL");
        DeleteLocalLocation(OBJECT_SELF, "SPELL_TARGET_OVERRIDE");
        DeleteLocalObject(OBJECT_SELF, "SPELL_TARGET_OVERRIDE");
        SetLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE", prevCL);
        SetLocalInt(OBJECT_SELF, "SPECIAL_ABILITY_METAMAGIC_OVERRIDE", prevMeta);
    }
}

float GetAreaOfEffectRadius(int nAreaEffectId)
{
    float fRadius = StringToFloat(Get2DAString("vfx_persistent", "radius", nAreaEffectId));
    if(fRadius > 0.0) // circle AOE
        return fRadius;
    else // wall of fire etc
        return 5.0;
}

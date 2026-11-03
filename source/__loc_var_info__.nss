
﻿// установить локалку тэга мерчанта на непись, чтобы не плодить кучу однотипных
// скриптов и использовать один во всех диалогах
// SetLocalString(object oCreature, "STORE_TAG", "Store_Tag");

// Установить флаг о том, что существо - гвард какой-либо фракции
// SetLocalInt(object oCreature, "IMGUARD", 1);

// Установить флаг о том, что в локации запрещено использовать магию
// SetLocalInt(object oArea, "iNOMAGIC", 1);

// Установить флаг о том, что в локации нельзя умереть
// SetLocalInt(object oArea, "iNODEATH", 1);

// Установить флаг о том, что среди данной категории мобов может заспауниться чемпион
// SetLocalInt(oCreature, "IAMCHAMPION", 1)

// Установить флаг о том, что у моба иммун к девасту
// SetLocalInt(oCreature, "IHAVEDEVASTIMMUNITY", 1)

// Установить флаг о том, что цель имеет иммун к диспелу
// SetLocalInt(oSpellTarget, "IMMUNE_TO_DISPEL", 1)

// Установить TRUE если в локации нельзя спаунить могилку
// SetLocalInt(oArea, "NO_GRAVESTONE", 1)

// Установить TRUE если в локации нельзя спаунить труп
// SetLocalInt(oArea, "NO_CORPSE", 1)

// Установить коэффициент визуальной трансформации
// SetLocalFloat(oCreature, "VISUAL_TRANSFORM_COEFFICIENT", float 1.0)

// локалка с уровнем убитого чара на могилке
// SetLocalInt(oGraveStone, "DEAD_PC_LEVEL", GetHitDice(oPC));

/* Сундуки боссов необходимо создавать c тегами типа
 boss_chest_1, boss_chest_2, boss_chest_3 и т д
 при киле босса происходит поиск ящиков по этим тэгам
 далее нужно установить локалку на ящик типа int с названием "LOOT_TIER"
 возможные значения переменной определяют уровень лута в ящике

const int LOOT_BOSS_LEVEL_1     = 11;  - blue
const int LOOT_BOSS_LEVEL_2     = 12;  - green weapons
const int LOOT_BOSS_LEVEL_3     = 13;  - green equipment
const int LOOT_BOSS_LEVEL_4     = 14;  - green weapons + green equipment
const int LOOT_BOSS_LEVEL_5     = 15;  - purple weapons
const int LOOT_BOSS_LEVEL_6     = 16;  - purple equipment
const int LOOT_BOSS_LEVEL_7     = 17;  - purple weapons + purple equipment
const int LOOT_BOSS_LEVEL_8     = 18;  - red weapons
const int LOOT_BOSS_LEVEL_9     = 19;  - red equipment
const int LOOT_BOSS_LEVEL_10    = 20;  - red weapons + red equipment
const int LOOT_BOSS_LEVEL_11    = 21;  - artifacts

соответственно, если нам нужно получить 2 сундука с ящиком топ лута 5 боссоуровня,
создаем 2 ящика с тэгами "boss_chest_1" и "boss_chest_2" и ставим на них локальные
переменные int с именем LOOT_TIER и значениями 15.

Дополнительные локальные переменные:
int ITEMS_AMOUNT_IN_CHEST - определяет число шмоток в ящике
int GOLD_CHANCE_IN_CHEST  - определяет шанс генерации золота в ящике

// шанс фейма в сундуке
const string sFameChanceInChest = "FAME_CHANCE_IN_CHEST";
// возможный максимум фейма в сундуке при генерации
const string sMaxFameInChest    = "MAX_FAME_IN_CHEST";

*/

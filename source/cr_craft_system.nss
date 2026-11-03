// Cormyrean Craft System
// v0.1, 13.09.2009
// Crypton
#include "_inc_colortext"
#include "x2_inc_itemprop"

// >> CONSTANTS <<
const int COST_DAMAGE_1d4 = 3000;
const int COST_DAMAGE_1d6 = 8000;
const int COST_DAMAGE_1d8 = 19000;
const int COST_DAMAGE_1d10 = 28000;
const int COST_DAMAGE_2d6 = 35000;
const int COST_DAMAGE_2d8 = 44000;
const int COST_ENHANCE_1 = 4000;
const int COST_ENHANCE_2 = 15000;
const int COST_ENHANCE_3 = 32000;
const int COST_ENHANCE_4 = 60000;
const int COST_ENHANCE_5 = 100000;
const int COST_SAVE_1 = 4000;
const int COST_SAVE_2 = 10000;
const int COST_SAVE_3 = 20000;
const int COST_USAVE_1 = 10000;
const int COST_ABILITY_1 = 6000;
const int COST_ABILITY_2 = 12000;
const int COST_ABILITY_3 = 24000;
const int COST_ABILITY_4 = 48000;
const int COST_AB_1 = 2000;
const int COST_AB_2 = 7500;
const int COST_AB_3 = 16000;
const int COST_AB_4 = 30000;
const int COST_AB_5 = 50000;

const int CONST_MAX_DAMAGE_BONUS = 11; // int IP_CONST_DAMAGEBONUS_2d8 = 11; см. nwscript.nss
const int CONST_MAX_DAMAGE_SUM = 16; // сумма максимального дамага не должна быть больше 16
const int CONST_MAX_DAMAGE_TYPES = 2; //
const int CONST_MAX_ENCHANT_BONUS = 5; //
const int CONST_MAX_ABILITY_BONUS = 2; //
const int CONST_MAX_SAVINGS_BONUS = 1; //
const int CONST_M_UNISAVINGS_BONUS = 0; //
const int CONST_MAX_ITEMLVL = 40; // максимальная цена крафченой шмотки 20 лвл см. itemvalue.2da
const int CONST_ONLY_ELEMENTAL_DAMAGE = 1;// только cold, fire, electro и acid
const string CONST_SLOT = "SLOT"; // локалка в которой храницо нмоер шмотки которая щас крафтицо
const string CONST_DAMAGE = "DAMAGE"; // локалка в которой храницо тип дамага щас крафтицо
const string CONST_ABILITY = "ABILITY"; // локалка в которой храницо тип абилкиN"; //
const string CONST_SAVE = "SAVE";// локалка в которой храницо тип спаса
const string CONST_LVL = "LVL";// локалка в которой храницо лвл крафтера
const string CONST_TAG_TEMP_CHEST = "CRAFT_CHEST"; //тэг сундука в котором генерицо шмот
// >> FUNCTIONS <<
// тестовое добавление свойства на шмотку с целью узнать будущую стоимость, возвращает лвл на который будет новая шмотка
int TestAddIP2Item(int ipType, int ipSubType, int ipCostTable, int ipCostTableValue, object oItem);
int CheckIPType(int ipType, int ipSubType, int ipCostTable, int ipCostTableValue, object oItem);

int GetItemCost(object oItem)
{
    int iCost = GetGoldPieceValue(oItem)+1;
    SendColorMessageToAllPCs("Base cost: "+IntToString(iCost),TXT_COLOR_CYAN);
       return iCost;
}
// получает энчант
int GetWeaponEnchant(object oItem)
{
    itemproperty ip = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip))
    {
         if(GetItemPropertyType(ip)==6 && GetItemPropertyDurationType(ip)!=DURATION_TYPE_TEMPORARY)
         {
               return GetItemPropertyCostTableValue(ip);
         }
         ip = GetNextItemProperty(oItem);
    }
    return 0;
}


int GetMaxDamage(int ipCostTableValue)
{
        int iReturn = 0;
         switch(ipCostTableValue)
         {
            case DAMAGE_BONUS_1: iReturn=1;break;
            case DAMAGE_BONUS_2: iReturn=2;break;
            case DAMAGE_BONUS_3: iReturn=3;break;
            case DAMAGE_BONUS_4: iReturn=4;break;
            case DAMAGE_BONUS_5: iReturn=5;break;
            case DAMAGE_BONUS_1d4: iReturn=4;break;
            case DAMAGE_BONUS_1d6: iReturn=6;break;
            case DAMAGE_BONUS_1d8: iReturn=8;break;
            case DAMAGE_BONUS_1d10: iReturn=10;break;
            case DAMAGE_BONUS_2d6: iReturn=12;break;
            case DAMAGE_BONUS_2d8: iReturn=16;break;
            case DAMAGE_BONUS_2d4: iReturn=8;break;
            case DAMAGE_BONUS_2d10: iReturn=20;break;
            case DAMAGE_BONUS_1d12: iReturn=12;break;
            case DAMAGE_BONUS_2d12: iReturn=24;break;
            case DAMAGE_BONUS_6: iReturn=6;break;
            case DAMAGE_BONUS_7: iReturn=7;break;
            case DAMAGE_BONUS_8: iReturn=8;break;
            case DAMAGE_BONUS_9: iReturn=9;break;
            case DAMAGE_BONUS_10: iReturn=10;break;
            case DAMAGE_BONUS_11: iReturn=11;break;
            case DAMAGE_BONUS_12: iReturn=12;break;
            case DAMAGE_BONUS_13: iReturn=13;break;
            case DAMAGE_BONUS_14: iReturn=14;break;
            case DAMAGE_BONUS_15: iReturn=15;break;
            case DAMAGE_BONUS_16: iReturn=16;break;
            case DAMAGE_BONUS_17: iReturn=17;break;
            case DAMAGE_BONUS_18: iReturn=18;break;
            case DAMAGE_BONUS_19: iReturn=19;break;
            case DAMAGE_BONUS_20: iReturn=20;break;

         }
         return iReturn;
}
int TakeGoldForCraft(object oPC, int ipType, int ipCostTableValue, int iTake)
{
      int iPGold = GetGold(oPC);
      int iCost = 0;
      switch (ipType)
      {
            case ITEM_PROPERTY_DAMAGE_BONUS:
            {
                switch(ipCostTableValue)
                {
                    case IP_CONST_DAMAGEBONUS_1d4: iCost = COST_DAMAGE_1d4; break;
                    case IP_CONST_DAMAGEBONUS_1d6: iCost = COST_DAMAGE_1d6; break;
                    case IP_CONST_DAMAGEBONUS_1d8: iCost = COST_DAMAGE_1d8; break;
                    case IP_CONST_DAMAGEBONUS_1d10: iCost = COST_DAMAGE_1d10; break;
                    case IP_CONST_DAMAGEBONUS_2d6: iCost = COST_DAMAGE_2d6; break;
                    case IP_CONST_DAMAGEBONUS_2d8: iCost = COST_DAMAGE_2d8; break;
                }
                break;
            }
            case ITEM_PROPERTY_ENHANCEMENT_BONUS:
            {
                 switch(ipCostTableValue)
                {
                    case 1: iCost = COST_ENHANCE_1; break;
                    case 2: iCost = COST_ENHANCE_2; break;
                    case 3: iCost = COST_ENHANCE_3; break;
                    case 4: iCost = COST_ENHANCE_4; break;
                    case 5: iCost = COST_ENHANCE_5; break;
                }
                break;
            }
             case ITEM_PROPERTY_ATTACK_BONUS:
            {
                 switch(ipCostTableValue)
                {
                    case 1: iCost = COST_AB_1; break;
                    case 2: iCost = COST_AB_2; break;
                    case 3: iCost = COST_AB_3; break;
                    case 4: iCost = COST_AB_4; break;
                    case 5: iCost = COST_AB_5; break;
                }
                break;
            }
            case ITEM_PROPERTY_ABILITY_BONUS:
            {
                 switch(ipCostTableValue)
                {
                    case 1: iCost = COST_ABILITY_1; break;
                    case 2: iCost = COST_ABILITY_2; break;
                    case 3: iCost = COST_ABILITY_3; break;
                    case 4: iCost = COST_ABILITY_4; break;
                }
                break;
            }
            case ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC:
            {
                switch(ipCostTableValue)
                {
                    case 1: iCost = COST_SAVE_1; break;
                    case 2: iCost = COST_SAVE_2; break;
                    case 3: iCost = COST_SAVE_3; break;
                }
                break;
            }
            case ITEM_PROPERTY_SAVING_THROW_BONUS:
            {
               // iCost = COST_USAVE_1;
                break;
            }
      }
     // SendColorMessageToPC(GetPCSpeaker(),"iPGold: "+IntToString(iPGold),TXT_COLOR_NONE);
     // SendColorMessageToPC(GetPCSpeaker(),"iCost: "+IntToString(iCost),TXT_COLOR_NONE);
      if (iPGold >=iCost)
      {
        if(iTake==1){ TakeGoldFromCreature(iCost, oPC, TRUE); }
        return 1;
      }
      else
      {
        return 0;
      }
}


// проверка можно ли добавлять этот тип ipProperty
int CheckIPType(int ipType, int ipSubType, int ipCostTable, int ipCostTableValue, object oItem)
{

    int iAccept = TRUE;

    if(GetLocalString(oItem, "LOOT_CATEGORY") == "BLUE"     || GetLocalString(oItem, "LOOT_CATEGORY") == "GREEN"    ||
       GetLocalString(oItem, "LOOT_CATEGORY") == "PURPLE"   || GetLocalString(oItem, "LOOT_CATEGORY") == "RED"      ||
       GetLocalString(oItem, "LOOT_CATEGORY") == "ARTIFACT")
    {
         iAccept = FALSE;
    }

    int iNewLvl = TestAddIP2Item(ipType, ipSubType, ipCostTable, ipCostTableValue, oItem);
    if(iNewLvl > GetLocalInt(GetPCSpeaker(),CONST_LVL) || iNewLvl > CONST_MAX_ITEMLVL)
    {
        iAccept = FALSE;
    }
    if(TakeGoldForCraft(GetPCSpeaker(), ipType, ipCostTableValue, 0) == 0)
    {
        iAccept = FALSE;
    }

    string clr = TXT_COLOR_NONE;
    int iCountDmg = 0;
    int iSumDmg = GetMaxDamage(ipCostTableValue);
    int iSumAbi = ipCostTableValue;
    int iSumSaves = 0;
    if(ipType==ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC)
    {
          if(ipSubType==0)
          {
              iSumSaves = ipCostTableValue*3;
          }
          else
          {
              iSumSaves = ipCostTableValue;
          }
    }
    if(ipType==ITEM_PROPERTY_SAVING_THROW_BONUS)
    {
        iSumSaves = ipCostTableValue*3;
    }

    if(GetItemHasItemProperty(oItem,ipType))
    {
          itemproperty ip = GetFirstItemProperty(oItem);
          while(GetIsItemPropertyValid(ip))// перебираем все свойства шмотки в поисках нужной
          {
                if(GetItemPropertyType(ip)==ipType && GetItemPropertyDurationType(ip)!=DURATION_TYPE_TEMPORARY)// если совпадает тип свойства
                {
                    // если тип свойства - дамаг -----------------------------------------------------------
                    if(ipType==ITEM_PROPERTY_DAMAGE_BONUS)//
                    {
                        iCountDmg++;
                        clr = TXT_COLOR_RED;
                     //   SendColorMessageToAllPCs("====================",clr);

                        if(GetItemPropertySubType(ip)==ipSubType)// если тип дамага тотже
                        {
                          //  SendColorMessageToAllPCs("Совпадение SubType",clr);
                            clr = TXT_COLOR_GREEN_L;
                            if(GetItemPropertyCostTableValue(ip)>=CONST_MAX_DAMAGE_BONUS)
                            {

                                    clr = TXT_COLOR_ORANGE;
                                    iAccept = 0;
                           //         SendColorMessageToAllPCs("Уже максимум этого дамага",clr);
                            }
                            if(ipCostTableValue>0 && ipCostTableValue<=GetItemPropertyCostTableValue(ip)) // если хотим добавить меньше чем уже есть: 1д6, а уже есть 1д8 например....
                            {
                                 iAccept = 0;
                        //         SendColorMessageToAllPCs("Желаемый дамаг меньше существующего",clr);
                            }

                        }
                        else
                        {
                             iSumDmg = iSumDmg + GetMaxDamage(GetItemPropertyCostTableValue(ip));
                        }






                    //    SendColorMessageToAllPCs("IPType="+IntToString(GetItemPropertyType(ip)),clr);
                   //     SendColorMessageToAllPCs("IPSubType="+IntToString(GetItemPropertySubType(ip)),clr);
                   //     SendColorMessageToAllPCs("IPParam1="+IntToString(GetItemPropertyParam1(ip)),clr);
                   //     SendColorMessageToAllPCs("IPParam1Value="+IntToString(GetItemPropertyParam1Value(ip)),clr);
                   //     SendColorMessageToAllPCs("IPCostTable="+IntToString(GetItemPropertyCostTable(ip)),clr);
                    //    SendColorMessageToAllPCs("IPCostTableValue="+IntToString(GetItemPropertyCostTableValue(ip)),clr);
                  //      SendColorMessageToAllPCs("IPDurationType="+IntToString(GetItemPropertyDurationType(ip)),clr);
                  //      SendColorMessageToAllPCs("Valid="+IntToString(GetIsItemPropertyValid(ip)),clr);
                        if(iSumDmg>CONST_MAX_DAMAGE_SUM || iCountDmg>CONST_MAX_DAMAGE_TYPES) iAccept=FALSE; // если общий мксимальный дамаг больше 16 или кол-во дамагов больше 2- то нельзя добавлять
                    } // конец проверки дамага ----------------------------------------------------
                    else
                    // если тип свойства - энчант -----------------------------------------------------------
                    if(ipType==ITEM_PROPERTY_ENHANCEMENT_BONUS)//
                    {
                        if(GetItemPropertyCostTableValue(ip)>=ipCostTableValue)
                        {
                      //      SendColorMessageToAllPCs("существующий энчант больше или равен желаемого",clr);
                            iAccept=FALSE;
                        }

                    } // конец проверки энчанта ----------------------------------------------------
                    // если тип свойства - аб -----------------------------------------------------------
                    if(ipType==ITEM_PROPERTY_ATTACK_BONUS)//
                    {
                        if(GetItemPropertyCostTableValue(ip)>=ipCostTableValue)
                        {
                      //      SendColorMessageToAllPCs("существующий энчант больше или равен желаемого",clr);
                            iAccept=FALSE;
                        }

                    } // конец проверки аб ----------------------------------------------------
                    //
                    else
                    // если тип свойства - абилка -----------------------------------------------------------
                    if(ipType==ITEM_PROPERTY_ABILITY_BONUS)//
                    {

                        if(GetItemPropertySubType(ip)==ipSubType)// если абилка таже
                        {
                              if(GetItemPropertyCostTableValue(ip)>=ipCostTableValue)// если хчоу больше чем есть тойже абилки
                            {
                                    iAccept = FALSE;
                            }
                        }
                        else
                        {
                            iSumAbi = iSumAbi + GetItemPropertyCostTableValue(ip);
                        }

                       if(iSumAbi>CONST_MAX_ABILITY_BONUS) iAccept=FALSE;
                    } // конец проверки абилок ----------------------------------------------------
                    //
                    //
                    else
                    // если тип свойства - спасы -----------------------------------------------------------
                    if(ipType==ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC)//
                    {
                    //    SendColorMessageToAllPCs("СПАСЫ ЕСТЬ!",clr);
                       // iSumSaves = iSumSaves + GetItemPropertyCostTableValue(ip)
                     //   iSumAbi = iSumAbi + GetItemPropertyCostTableValue(ip);
                       //  if(GetItemPropertySubType(ip)==0)// если универсальные спасы то *3
                    //    {
                    ////       iSumSaves = iSumSaves + GetItemPropertyCostTableValue(ip)*3;
                    //    }
                        if(GetItemPropertySubType(ip)>0)
                        {
                            if(GetItemPropertySubType(ip)==ipSubType)
                            {
                                if(GetItemPropertyCostTableValue(ip)>=ipCostTableValue) iAccept=FALSE;
                            }
                            else
                            {
                            iSumSaves = iSumSaves + GetItemPropertyCostTableValue(ip);
                            }
                        }


                      //  if(GetItemPropertySubType(ip)==ipSubType && ipSubType>0)// если спас тотже но не универсал
                     //  {
                    //          if(GetItemPropertyCostTableValue(ip)>=ipCostTableValue)// если хчоу больше чем есть тогоже спаса
                    //        {
                    //                iAccept = FALSE;
                    //        }
                    //    }

                //       SendColorMessageToAllPCs("спасы: +"+IntToString(iSumSaves),clr);
                       if(iSumSaves>CONST_MAX_SAVINGS_BONUS) iAccept=FALSE;
                    } // конец проверки спасы ----------------------------------------------------
                     else
                    // если тип свойства - спасы -----------------------------------------------------------
                    if(ipType==ITEM_PROPERTY_SAVING_THROW_BONUS)//
                    {
                     //  SendColorMessageToAllPCs("СПАСЫ ЕСТЬ!",clr);
                       // iSumSaves = iSumSaves + GetItemPropertyCostTableValue(ip)
                     //   iSumAbi = iSumAbi + GetItemPropertyCostTableValue(ip);
                        if(GetItemPropertySubType(ip)==0)// если универсальные спасы то *3
                        {
                           iSumSaves = iSumSaves + GetItemPropertyCostTableValue(ip)*3;
                        }
                    //    if(GetItemPropertySubType(ip)>0)
                     //   {
                    //        iSumSaves = iSumSaves + GetItemPropertyCostTableValue(ip);
                    //    }

                      //  if(GetItemPropertySubType(ip)==ipSubType && ipSubType>0)// если спас тотже но не универсал
                     //  {
                    //          if(GetItemPropertyCostTableValue(ip)>=ipCostTableValue)// если хчоу больше чем есть тогоже спаса
                    //        {
                    //                iAccept = FALSE;
                    //        }
                    //    }

                   //     SendColorMessageToAllPCs("спасы: +"+IntToString(iSumSaves),clr);
                       if(iSumSaves>CONST_MAX_SAVINGS_BONUS) iAccept=FALSE;
                    } // конец проверки спасы ----------------
                    //
                }
                else
                {
                    clr = TXT_COLOR_NONE;
                //    SendColorMessageToAllPCs("====================",clr);
               //     SendColorMessageToAllPCs("IPType="+IntToString(GetItemPropertyType(ip)),clr);
               //     SendColorMessageToAllPCs("IPSubType="+IntToString(GetItemPropertySubType(ip)),clr);
               //     SendColorMessageToAllPCs("IPParam1="+IntToString(GetItemPropertyParam1(ip)),clr);
               //     SendColorMessageToAllPCs("IPParam1Value="+IntToString(GetItemPropertyParam1Value(ip)),clr);
               //     SendColorMessageToAllPCs("IPCostTable="+IntToString(GetItemPropertyCostTable(ip)),clr);
               //     SendColorMessageToAllPCs("IPCostTableValue="+IntToString(GetItemPropertyCostTableValue(ip)),clr);
               //     SendColorMessageToAllPCs("IPDurationType="+IntToString(GetItemPropertyDurationType(ip)),clr);
               //     SendColorMessageToAllPCs("Valid="+IntToString(GetIsItemPropertyValid(ip)),clr);
            //        SendColorMessageToAllPCs("типы не соответствуют - дальше.",TXT_COLOR_NONE);
                }
                ip = GetNextItemProperty(oItem);
          }// заканчиваем перебирать свойства
               //     SendColorMessageToAllPCs("Кол-во дамагов = "+IntToString(iCountDmg),clr);
              //      SendColorMessageToAllPCs("Макс дамаг ="+IntToString(iSumDmg),clr);
              //      SendColorMessageToAllPCs("Итог = "+IntToString(iAccept),clr);
    }
    else
    {
     //   SendColorMessageToAllPCs("IPType отсутствует на шмотке",TXT_COLOR_NONE);
    }
       return iAccept;
    //GetItemHasItemProperty(,)
}

// тестовое добавление свойства на шмотку с целью узнать будущую стоимость, возвращает лвл на который будет новая шмотка
int TestAddIP2Item(int ipType, int ipSubType, int ipCostTable, int ipCostTableValue, object oItem)
{
       object oTestChest = GetObjectByTag("CRAFT_CHEST");
       object oTestItem = CopyItem(oItem,oTestChest,1);
    //  if(CheckIPType(ipType,ipSubType,ipCostTable,ipCostTableValue,oTestItem)>0)
  //  {
        itemproperty ip;
        switch(ipType)
        {
            case ITEM_PROPERTY_DAMAGE_BONUS:
                ip = ItemPropertyDamageBonus(ipSubType,ipCostTableValue);
            break;
            case ITEM_PROPERTY_ENHANCEMENT_BONUS:
                ip = ItemPropertyEnhancementBonus(ipCostTableValue);
            break;
            case ITEM_PROPERTY_ABILITY_BONUS:
                ip = ItemPropertyAbilityBonus(ipSubType, ipCostTableValue);
            break;
            case ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC:
                ip = ItemPropertyBonusSavingThrow(ipSubType,ipCostTableValue);
            break;
            case ITEM_PROPERTY_SAVING_THROW_BONUS:
                ip = ItemPropertyBonusSavingThrowVsX(ipSubType,ipCostTableValue);
            break;
        }
        IPSafeAddItemProperty(oTestItem, ip);
 //   }
        AssignCommand(OBJECT_SELF, ActionWait(1.0));
    int iNewCost = GetGoldPieceValue(oTestItem);
   // SendColorMessageToAllPCs("новая цена шмотки = "+IntToString(iNewCost),TXT_COLOR_NONE);
    int n,iNewLvl = 0;
    for(n=0;n<40;n++)
    {
        if(StringToInt(Get2DAString("itemvalue","MAXSINGLEITEMVALUE",n))>=iNewCost)
        {
            iNewLvl = StringToInt(Get2DAString("itemvalue","LABEL",n));
            break;
        }
    }
    //SendColorMessageToAllPCs(" = "+IntToString(iNewLvl),TXT_COLOR_NONE);
    DestroyObject(oTestItem,2.0);
    return iNewLvl;
}

// Добавляет ipProperty на oItem. если успешно - возвращает 0,
// если нет то 1=максимальная цена превышена, 2=Превышено допустимое кол-во добавляемых ipProperty
int AddIP2Item(int ipType, int ipSubType, int ipCostTable, int ipCostTableValue, object oItem)//
{
    //itemproperty ipDamage = ItemPropertyDamageBonus(DAMAGE_TYPE_COLD,IP_CONST_DAMAGEBONUS_2d6);
    if(CheckIPType(ipType,ipSubType,ipCostTable,ipCostTableValue,oItem)>0)
    {
        itemproperty ip;
        switch(ipType)
        {
            case ITEM_PROPERTY_DAMAGE_BONUS: ip = ItemPropertyDamageBonus(ipSubType,ipCostTableValue); break;
            case ITEM_PROPERTY_ENHANCEMENT_BONUS: ip = ItemPropertyEnhancementBonus(ipCostTableValue); break;
            case ITEM_PROPERTY_ABILITY_BONUS: ip = ItemPropertyAbilityBonus(ipSubType, ipCostTableValue); break;
            case ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC: ip = ItemPropertyBonusSavingThrow(ipSubType,ipCostTableValue); break;
            case ITEM_PROPERTY_SAVING_THROW_BONUS: ip = ItemPropertyBonusSavingThrowVsX(ipSubType,ipCostTableValue); break;
            case ITEM_PROPERTY_ATTACK_BONUS: ip = ItemPropertyAttackBonus(ipCostTableValue); break;
        }
        TakeGoldForCraft(GetPCSpeaker(), ipType, ipCostTableValue, 1);
        IPSafeAddItemProperty(oItem, ip);
    }
    return 0;
}



//void main(){}

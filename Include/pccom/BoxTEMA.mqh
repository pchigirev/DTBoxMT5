//+------------------------------------------------------------------+
//|                                                       Box0.1.mq5 |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\Generic\\HashMap.mqh"

#include "Commons.mqh"
#include "BoxIndicatorData.mqh"
#include "IBoxIndicator.mqh"

class BoxTEMA : public IBoxIndicator
{
private:
   int _maPeriod;
   int _maShift;
   ENUM_APPLIED_PRICE _maAppliedPrice;
   color _maColor;

public:
   static bool CreateFromCmd(CHashMap<int, BoxIndicatorData*>& activeIndicators, string globalInstanceName, string& params[])
   {
      // params = [cmd_ai, MA, Symbol, TF, Period, Shift, AppliedPrice, Color]
      if (ArraySize(params) != 8)
         return false;
      
      string symbol = params[2];
      ENUM_TIMEFRAMES tf = StringToEnum<ENUM_TIMEFRAMES>(params[3]);
      int period = (int)StringToInteger(params[4]);
      int shift = (int)StringToInteger(params[5]);
      ENUM_APPLIED_PRICE appliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[6]);
      string clr = params[7];
      
      int handle = iCustom(symbol, tf, "pccom\\BoxTEMA", period, shift, appliedPrice, StrToColor(clr), globalInstanceName);
      
      string boxStr = symbol + "," + 
               IntegerToString(handle) + "," + 
               "TEMA," + 
               EnumToString(tf) + "," + 
               "Period=" + IntegerToString(period) + ";" + 
               "Shift=" + IntegerToString(shift) + ";" +
               "AppliedPrice=" + EnumToString(appliedPrice) + ";" + 
               "Color=" + params[7] + ";";
      
      BoxIndicatorData* biData = new BoxIndicatorData(handle, "TEMA", symbol, tf, globalInstanceName, boxStr);
      activeIndicators.Add(handle, biData);
      
      return true;
   }

   static bool ModifyFromCmd(BoxIndicatorData& biData, string& params[], string& gvName)
   {
      // params = [cmd, handle, Period, Shift, AppliedPrice, Color]
      if (ArraySize(params) != 6)
         return false;
      
      
         gvName = ">ch," + params[2] + // period
                     "," + params[3] + // shift
                     "," + params[4] + // app price
                     "," + params[5];  // color        
         
         string boxStr = biData.symbol + "," + 
                  IntegerToString(biData.handle) + "," + 
                  "TEMA," + 
                  EnumToString(biData.timeframe) + "," + 
                  "Period=" + params[2] + ";" + 
                  "Shift=" + params[3] + ";" +
                  "AppliedPrice=" + params[4] + ";" + 
                  "Color=" + params[5] + ";";
         
         biData.cmdString = boxStr;
   
      return true;
   }

   BoxTEMA
   (
      int pMAPeriod, 
      int pMAShift,
      ENUM_APPLIED_PRICE pMAAppliedPrice,
      color pMAColor
   ) : 
   _maPeriod(pMAPeriod),
   _maShift(pMAShift),
   _maAppliedPrice(pMAAppliedPrice),
   _maColor(pMAColor)
   {
      InitHandle();
   }   
   
   void InitHandle() override
   {
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, _maColor); 
      
      string short_name=StringFormat("TEMA(%d)", _maPeriod);
      IndicatorSetString(INDICATOR_SHORTNAME, short_name);
      
      IndicatorRelease(_handle);
      _handle = iTEMA(_Symbol, PERIOD_CURRENT, _maPeriod, _maShift, _maAppliedPrice);
   }

   bool ParseNewParams(string& params[]) override
   {
      if (ArraySize(params) == 5)
      {
         _maPeriod = (int)StringToInteger(params[1]);
         _maShift = (int)StringToInteger(params[2]);
         _maAppliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[3]);
         _maColor = StrToColor(params[4]);
   
         return true;
      }
      return false;
   }
};
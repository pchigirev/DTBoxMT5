//+------------------------------------------------------------------+
//|                                                       BoxAMA.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\Generic\\HashMap.mqh"

#include "Commons.mqh"
#include "BoxIndicatorData.mqh"
#include "IBoxIndicator.mqh"

class BoxAMA : public IBoxIndicator
{
private:
   int _period;
   int _fastEMA;
   int _slowEMA;
   int _maShift;
   ENUM_APPLIED_PRICE _maAppliedPrice;
   color _maColor;

public:
   static bool CreateFromCmd(CHashMap<int, BoxIndicatorData*>& activeIndicators, string globalInstanceName, string& params[])
   {
      // params = [cmd_ai, MA, Symbol, TF, Period, FastEMA, SlowEMA, Shift, AppliedPrice, Color]
      if (ArraySize(params) != 10)
         return false;
      
      string symbol = params[2];
      ENUM_TIMEFRAMES tf = StringToEnum<ENUM_TIMEFRAMES>(params[3]);
      int period = (int)StringToInteger(params[4]);
      int fastEMA = (int)StringToInteger(params[5]);
      int slowEMA = (int)StringToInteger(params[6]);
      int shift = (int)StringToInteger(params[7]);
      ENUM_APPLIED_PRICE appliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[8]);
      string clr = params[9];
      
      int handle = iCustom(symbol, tf, "pccom\\BoxAMA", period, fastEMA, slowEMA, shift, appliedPrice, StrToColor(clr), globalInstanceName);
      
      string boxStr = symbol + "," + 
               IntegerToString(handle) + "," + 
               "AMA," + 
               EnumToString(tf) + "," + 
               "Period=" + IntegerToString(period) + ";" + 
               "FastEMA=" + IntegerToString(fastEMA) + ";" + 
               "SlowEMA=" + IntegerToString(slowEMA) + ";" + 
               "Shift=" + IntegerToString(shift) + ";" +
               "AppliedPrice=" + EnumToString(appliedPrice) + ";" + 
               "Color=" + params[9] + ";";
      
      BoxIndicatorData* biData = new BoxIndicatorData(handle, "AMA", symbol, tf, globalInstanceName, boxStr);
      activeIndicators.Add(handle, biData);
      
      return true;
   }

   static bool ModifyFromCmd(BoxIndicatorData& biData, string& params[], string& gvName)
   {
      // params = [cmd, handle, Period, FastEMA, SlowEMA, Shift, AppliedPrice, Color]
      if (ArraySize(params) != 8)
         return false;
      
      
         gvName = ">ch," + params[2] + // period
                     "," + params[3] + // fast EMA
                     "," + params[4] + // slow EMA
                     "," + params[5] + // shift
                     "," + params[6] + // app price
                     "," + params[7];  // color        
         
         string boxStr = biData.symbol + "," + 
                  IntegerToString(biData.handle) + "," + 
                  "AMA," + 
                  EnumToString(biData.timeframe) + "," + 
                  "Period=" + params[2] + ";" + 
                  "FastEMA=" + params[3] + ";" + 
                  "SlowEMA=" + params[4] + ";" + 
                  "Shift=" + params[5] + ";" +
                  "AppliedPrice=" + params[6] + ";" + 
                  "Color=" + params[7] + ";";
         
         biData.cmdString = boxStr;
   
      return true;
   }

   BoxAMA
   (
      int pPeriod,
      int pFastEMA,
      int pSlowEMA, 
      int pMAShift,
      ENUM_APPLIED_PRICE pMAAppliedPrice,
      color pMAColor
   ) : 
   _period(pPeriod),
   _fastEMA(pFastEMA),
   _slowEMA(pSlowEMA),
   _maShift(pMAShift),
   _maAppliedPrice(pMAAppliedPrice),
   _maColor(pMAColor)
   {
      InitHandle();
   }   
   
   void InitHandle() override
   {
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, _maColor); 
      
      string short_name = StringFormat("AMA(%d,%d,%d)", _period, _fastEMA, _slowEMA);
      IndicatorSetString(INDICATOR_SHORTNAME, short_name);
      
      IndicatorRelease(_handle);
      _handle = iAMA(_Symbol, PERIOD_CURRENT, _period, _fastEMA, _slowEMA, _maShift, _maAppliedPrice);
   }

   bool ParseNewParams(string& params[]) override
   {
      if (ArraySize(params) == 7)
      {
         _period = (int)StringToInteger(params[1]);
         _fastEMA = (int)StringToInteger(params[2]);
         _slowEMA = (int)StringToInteger(params[3]);
         _maShift = (int)StringToInteger(params[4]);
         _maAppliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[5]);
         _maColor = StrToColor(params[6]);
   
         return true;
      }
      return false;
   }
};
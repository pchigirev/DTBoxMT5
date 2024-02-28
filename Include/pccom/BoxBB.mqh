//+------------------------------------------------------------------+
//|                                                        BoxBB.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\Generic\\HashMap.mqh"

#include "Commons.mqh"
#include "BoxIndicatorData.mqh"
#include "IBoxIndicator.mqh"

class BoxBB : public IBoxIndicator
{
private:
   int _period;
   int _shift;
   double _deviations; 
   ENUM_APPLIED_PRICE _appliedPrice;
   color _color;  

public:
   static bool CreateFromCmd(CHashMap<int, BoxIndicatorData*>& activeIndicators, string globalInstanceName, string& params[])
   {
      // params = [cmd_ai, BB, Symbol, TF, Period, Shift, Deviations, AppliedPrice, Color]
      if (ArraySize(params) != 9)
         return false;
      
      string symbol = params[2];
      ENUM_TIMEFRAMES tf = StringToEnum<ENUM_TIMEFRAMES>(params[3]);
      int period = (int)StringToInteger(params[4]);
      int shift = (int)StringToInteger(params[5]);
      double deviations = NormalizeDouble(StringToDouble(params[6]), 2);
      ENUM_APPLIED_PRICE appliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[7]);
      string clr = params[8];
      
      int handle = iCustom(symbol, tf, "pccom\\BoxBB", period, shift, deviations, appliedPrice, StrToColor(clr), globalInstanceName);
      
      string boxStr = symbol + "," + 
               IntegerToString(handle) + "," + 
               "BB," + 
               EnumToString(tf) + "," + 
               "Period=" + IntegerToString(period) + ";" + 
               "Shift=" + IntegerToString(shift) + ";" +
               "Deviations=" + DoubleToString(deviations, 2) + ";" + 
               "AppliedPrice=" + EnumToString(appliedPrice) + ";" + 
               "Color=" + params[8] + ";";
      
      BoxIndicatorData* biData = new BoxIndicatorData(handle, "BB", symbol, tf, globalInstanceName, boxStr);
      activeIndicators.Add(handle, biData);
      
      return true;
   }
   
   static bool ModifyFromCmd(BoxIndicatorData& biData, string& params[], string& gvName)
   {
      // params = [cmd, handle, Period, Shift, Deviations, AppliedPrice, Color]
      if (ArraySize(params) != 7)
         return false;
      
         gvName = ">ch," + params[2] + // period
                     "," + params[3] + // shift
                     "," + params[4] + // deviations
                     "," + params[5] + // app price
                     "," + params[6];  // color        
         
         string boxStr = biData.symbol + "," + 
                  IntegerToString(biData.handle) + "," + 
                  "BB," + 
                  EnumToString(biData.timeframe) + "," + 
                  "Period=" + params[2] + ";" + 
                  "Shift=" + params[3] + ";" +
                  "Deviations=" + params[4] + ";" + 
                  "AppliedPrice=" + params[5] + ";" + 
                  "Color=" + params[6] + ";";
         
         biData.cmdString = boxStr;
   
      return true;
   }
   
   BoxBB
   (
      int pPeriod,
      int pShift,
      double pDeviations,
      ENUM_APPLIED_PRICE pAppliedPrice,
      color pColor
   ) :
   _period(pPeriod), 
   _shift(pShift),
   _deviations(pDeviations),
   _appliedPrice(pAppliedPrice),
   _color(pColor)
   {
      InitHandle();
   }
   
   void InitHandle() override
   {
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, _color);
      PlotIndexSetInteger(1, PLOT_LINE_COLOR, _color);
      PlotIndexSetInteger(2, PLOT_LINE_COLOR, _color);
      
      string short_name = StringFormat("BB(%d,%f.2)", _period, _deviations);
      IndicatorSetString(INDICATOR_SHORTNAME, short_name);

      IndicatorRelease(_handle);
      _handle = iBands(_Symbol, PERIOD_CURRENT, _period, _shift, _deviations, _appliedPrice);
   }
   
   bool ParseNewParams(string& params[]) override
   {
      if (ArraySize(params) != 6)
         return false;
      
      _period = (int)StringToInteger(params[1]);
      _shift = (int)StringToInteger(params[2]);
      _deviations = StringToDouble(params[3]);
      _appliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[4]);
      _color = StrToColor(params[5]);

      return true;
   }
};
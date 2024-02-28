//+------------------------------------------------------------------+
//|                                                        BoxSD.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\Generic\\HashMap.mqh"

#include "Commons.mqh"
#include "BoxIndicatorData.mqh"
#include "IBoxIndicator.mqh"

class BoxSD : public IBoxIndicator
{
private:
   int _period;
   int _shift;
   ENUM_MA_METHOD _mode;
   ENUM_APPLIED_PRICE _appPrice;
   color _color;

public:
   static bool CreateFromCmd(CHashMap<int, BoxIndicatorData*>& activeIndicators, string globalInstanceName, string& params[])
   {
      // params = [cmd_ai, CCI, Symbol, TF, Period, Shift, Mode, AppliedPrice, Color]
      if (ArraySize(params) != 9)
         return false;
         
      string symbol = params[2];
      ENUM_TIMEFRAMES tf = StringToEnum<ENUM_TIMEFRAMES>(params[3]);
      int period = (int)StringToInteger(params[4]);
      int shift = (int)StringToInteger(params[5]);
      ENUM_MA_METHOD mode = StringToEnum<ENUM_MA_METHOD>(params[6]);
      ENUM_APPLIED_PRICE appliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[7]);
      string clr = params[8];
      
      // SD
      int handle = iCustom(symbol, tf, "pccom\\BoxSD", period, shift, mode, appliedPrice, StrToColor(clr), globalInstanceName);
      
      string boxStr = symbol + "," + 
               IntegerToString(handle) + "," + 
               "SD," + 
               EnumToString(tf) + "," + 
               "Period=" + IntegerToString(period) + ";" + 
               "Shift=" + IntegerToString(shift) + ";" +
               "Mode=" + EnumToString(mode) + ";" + 
               "AppliedPrice=" + EnumToString(appliedPrice) + ";" + 
               "Color=" + params[8] + ";";
      
      BoxIndicatorData* biData = new BoxIndicatorData(handle, "SD", symbol, tf, globalInstanceName, boxStr);
      activeIndicators.Add(handle, biData);
   
      return true;
   }

   static bool ModifyFromCmd(BoxIndicatorData& biData, string& params[], string& gvName)
   {
      // params = [cmd, handle, Period, Shift, Mode, AppliedPrice, Color]
      if (ArraySize(params) != 7)
         return false;
      
      
         gvName = ">ch," + params[2] + // period
                     "," + params[3] + // shift
                     "," + params[4] + // mode
                     "," + params[5] + // app price
                     "," + params[6];  // color        
         
         string boxStr = biData.symbol + "," + 
                  IntegerToString(biData.handle) + "," + 
                  "MA," + 
                  EnumToString(biData.timeframe) + "," + 
                  "Period=" + params[2] + ";" + 
                  "Shift=" + params[3] + ";" +
                  "Mode=" + params[4] + ";" + 
                  "AppliedPrice=" + params[5] + ";" + 
                  "Color=" + params[6] + ";";
         
         biData.cmdString = boxStr;
      
      return true;
   }

   BoxSD(int pPeriod, int pShift, ENUM_MA_METHOD pMode, ENUM_APPLIED_PRICE pAppPrice, color pColor)
      : _period(pPeriod), _shift(pShift), _mode(pMode), _appPrice(pAppPrice), _color(pColor)
   {
      InitHandle();
   }

   void InitHandle() override
   {
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, _color);
      
      string short_name = StringFormat("StDev(%d)", _period);
      IndicatorSetString(INDICATOR_SHORTNAME, short_name);

      IndicatorRelease(_handle);
      _handle = iStdDev(_Symbol, PERIOD_CURRENT, _period, _shift, _mode, _appPrice);
   }

   bool ParseNewParams(string& params[]) override
   {
      if (ArraySize(params) == 6) // [ch,del], period, shift, mode, app price, color
      {
         _period = (int)StringToInteger(params[1]);
         _shift = (int)StringToInteger(params[2]);
         _mode = StringToEnum<ENUM_MA_METHOD>(params[3]);
         _appPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[4]);
         _color = StrToColor(params[5]);
         
         return true;
      }
      return false;  
   }
};
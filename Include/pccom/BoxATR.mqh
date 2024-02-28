//+------------------------------------------------------------------+
//|                                                       BoxATR.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\Generic\\HashMap.mqh"

#include "Commons.mqh"
#include "BoxIndicatorData.mqh"
#include "IBoxIndicator.mqh"

class BoxATR : public IBoxIndicator
{
private:
   int _period;
   color _color;

public:
   static bool CreateFromCmd(CHashMap<int, BoxIndicatorData*>& activeIndicators, string globalInstanceName, string& params[])
   {
      // params = [cmd_ai, CCI, Symbol, TF, Period, Color]
      if (ArraySize(params) != 6)
         return false;
         
      string symbol = params[2];
      ENUM_TIMEFRAMES tf = StringToEnum<ENUM_TIMEFRAMES>(params[3]);
      int period = (int)StringToInteger(params[4]);
      string clr = params[5];
      
      // SD
      int handle = iCustom(symbol, tf, "pccom\\BoxATR", period, StrToColor(clr), globalInstanceName);
      
      string boxStr = symbol + "," + 
               IntegerToString(handle) + "," + 
               "ATR," + 
               EnumToString(tf) + "," + 
               "Period=" + IntegerToString(period) + ";" + 
               "Color=" + params[5] + ";";
      
      BoxIndicatorData* biData = new BoxIndicatorData(handle, "ATR", symbol, tf, globalInstanceName, boxStr);
      activeIndicators.Add(handle, biData);
   
      return true;
   }

   static bool ModifyFromCmd(BoxIndicatorData& biData, string& params[], string& gvName)
   {
      // params = [cmd, handle, Period, Color]
      if (ArraySize(params) != 4)
         return false;
      
         gvName = ">ch," + params[2] + // period
                     "," + params[3];  // color        
         
         string boxStr = biData.symbol + "," + 
                  IntegerToString(biData.handle) + "," + 
                  "ATR," + 
                  EnumToString(biData.timeframe) + "," + 
                  "Period=" + params[2] + ";" + 
                  "Color=" + params[3] + ";";
         
         biData.cmdString = boxStr;
      
      return true;
   }

   BoxATR(int pPeriod, color pColor)
      : _period(pPeriod), _color(pColor)
   {
      InitHandle();
   }

   void InitHandle() override
   {
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, _color);
      
      string short_name = StringFormat("ATR(%d)", _period);
      IndicatorSetString(INDICATOR_SHORTNAME, short_name);

      IndicatorRelease(_handle);
      _handle = iATR(_Symbol, PERIOD_CURRENT, _period);
   }

   bool ParseNewParams(string& params[]) override
   {
      if (ArraySize(params) == 3) // [ch,del], period, color
      {
         _period = (int)StringToInteger(params[1]);
         _color = StrToColor(params[2]);
         
         return true;
      }
      return false;  
   }
};
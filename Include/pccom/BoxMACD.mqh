//+------------------------------------------------------------------+
//|                                                      BoxMACD.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\Generic\\HashMap.mqh"

#include "Commons.mqh"
#include "BoxIndicatorData.mqh"
#include "IBoxIndicator.mqh"

class BoxMACD : public IBoxIndicator
{
private:
   int _fastEMA;
   int _slowEMA;
   int _signalSMA;
   ENUM_APPLIED_PRICE _appliedPrice;
   color _color1;
   color _color2;

public:
   static bool CreateFromCmd(CHashMap<int, BoxIndicatorData*>& activeIndicators, string globalInstanceName, string& params[])
   {
      // params = [cmd_ai, CCI, Symbol, TF, fastEMA, slowEMA, signalSMA, appliedPrice, color1, color2]
      if (ArraySize(params) != 10)
         return false;
         
       string symbol = params[2];
       ENUM_TIMEFRAMES tf = StringToEnum<ENUM_TIMEFRAMES>(params[3]);
       int fastEMA = (int)StringToInteger(params[4]);
       int slowEMA = (int)StringToInteger(params[5]); 
       int signalSMA = (int)StringToInteger(params[6]); 
       ENUM_APPLIED_PRICE appliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[7]);
       string color1 = params[8];
       string color2 = params[9];
      
      // MACD
      int handle = iCustom(symbol, tf, "pccom\\BoxMACD", fastEMA, slowEMA, signalSMA, appliedPrice, StrToColor(color1), StrToColor(color2), globalInstanceName);
      
      string boxStr = symbol + "," + 
               IntegerToString(handle) + "," + 
               "MACD," + 
               EnumToString(tf) + "," + 
               "FastEMA=" + IntegerToString(fastEMA) + ";" + 
               "SlowEMA=" + IntegerToString(slowEMA) + ";" + 
               "SignalSMA=" + IntegerToString(signalSMA) + ";" + 
               "AppliedPrice=" + EnumToString(appliedPrice) + ";" + 
               "Color1=" + params[8] + ";" + 
               "Color2=" + params[9] + ";";
      
      BoxIndicatorData* biData = new BoxIndicatorData(handle, "MACD", symbol, tf, globalInstanceName, boxStr);
      activeIndicators.Add(handle, biData);
   
      return true;
   }

   static bool ModifyFromCmd(BoxIndicatorData& biData, string& params[], string& gvName)
   {
      // params = [cmd, handle, fastEMA, slowEMA, signalSMA, appliedPrice, color1, color2]
      if (ArraySize(params) != 8) 
         return false;
      
      gvName = ">ch," + params[2] + "," + params[3] + "," + params[4] + "," + params[5] + "," + params[6] + "," + params[7]; 
    
      string boxStr = biData.symbol + "," + 
               IntegerToString(biData.handle) + "," + 
               "CCI," + 
               EnumToString(biData.timeframe) + "," + 
               "FastEMA=" + params[2] + ";" + 
               "SlowEMA=" + params[3] + ";" + 
               "SignalSMA=" + params[4] + ";" + 
               "AppliedPrice=" + params[5] + ";" + 
               "Color1=" + params[6] + ";" + 
               "Color2=" + params[7] + ";";
               
      biData.cmdString = boxStr;
      
      return true;
   }

   BoxMACD(int pFastEMA, int pSlowEMA, int pSignalSMA, ENUM_APPLIED_PRICE pAppliedPrice, color pColor1, color pColor2)
      : _fastEMA(pFastEMA), _slowEMA(pSlowEMA), _signalSMA(pSignalSMA), _appliedPrice(pAppliedPrice), _color1(pColor1), _color2(pColor2)
   {
      InitHandle();
   }

   void InitHandle() override
   {
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, _color1);
      PlotIndexSetInteger(1, PLOT_LINE_COLOR, _color2);
      
      string short_name = StringFormat("MACD(%d,%d,%d)",_fastEMA, _slowEMA, _signalSMA);
      IndicatorSetString(INDICATOR_SHORTNAME, short_name);

      IndicatorRelease(_handle);
      _handle = iMACD(_Symbol, PERIOD_CURRENT, _fastEMA, _slowEMA, _signalSMA, _appliedPrice);
   }

   bool ParseNewParams(string& params[]) override
   {
      if (ArraySize(params) == 7) // [ch,del], fastEMA, slowEMA, signalSMA, appliedPrice, color1, color2
      {
         _fastEMA = (int)StringToInteger(params[1]);
         _slowEMA = (int)StringToInteger(params[2]); 
         _signalSMA = (int)StringToInteger(params[3]); 
         _appliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[4]);
         _color1 = StrToColor(params[5]);
         _color2 = StrToColor(params[6]);
         
         return true;
      }
      return false;  
   }
};
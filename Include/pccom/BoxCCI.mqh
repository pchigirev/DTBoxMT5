//+------------------------------------------------------------------+
//|                                                       BoxCCI.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\Generic\\HashMap.mqh"

#include "Commons.mqh"
#include "BoxIndicatorData.mqh"
#include "IBoxIndicator.mqh"

class BoxCCI : public IBoxIndicator
{
private:
   int _cciPeriod;
   ENUM_APPLIED_PRICE _cciAppliedPrice;
   color _cciColor;

public:
   static bool CreateFromCmd(CHashMap<int, BoxIndicatorData*>& activeIndicators, string globalInstanceName, string& params[])
   {
      // params = [cmd_ai, CCI, Symbol, TF, Period, AppliedPrice, Color]
      if (ArraySize(params) != 7)
         return false;
         
      string symbol = params[2];
      ENUM_TIMEFRAMES tf = StringToEnum<ENUM_TIMEFRAMES>(params[3]);
      int period = (int)StringToInteger(params[4]);
      ENUM_APPLIED_PRICE appliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[5]);
      string clr = params[6];
      
      // CCI
      int handle = iCustom(symbol, tf, "pccom\\BoxCCI", period, appliedPrice, StrToColor(clr), globalInstanceName);
      
      string boxStr = symbol + "," + 
               IntegerToString(handle) + "," + 
               "CCI," + 
               EnumToString(tf) + "," + 
               "Period=" + IntegerToString(period) + ";" + 
               "AppliedPrice=" + EnumToString(appliedPrice) + ";" + 
               "Color=" + params[6] + ";";
      
      BoxIndicatorData* biData = new BoxIndicatorData(handle, "CCI", symbol, tf, globalInstanceName, boxStr);
      activeIndicators.Add(handle, biData);
   
      return true;
   }

   static bool ModifyFromCmd(BoxIndicatorData& biData, string& params[], string& gvName)
   {
      // params = [cmd, handle, period, appprice, color]
      if (ArraySize(params) != 5) 
         return false;
      
      gvName = ">ch," + params[2] + "," + params[3] + "," + params[4]; 
    
      string boxStr = biData.symbol + "," + 
               IntegerToString(biData.handle) + "," + 
               "CCI," + 
               EnumToString(biData.timeframe) + "," + 
               "Period=" + params[2] + ";" + 
               "AppliedPrice=" + params[3] + ";" + 
               "Color=" + params[4] + ";";
               
      biData.cmdString = boxStr;
      
      return true;
   }

   BoxCCI(int pCCIPeriod, ENUM_APPLIED_PRICE pCCIAppliedPrice, color pCCIColor)
      : _cciPeriod(pCCIPeriod), _cciAppliedPrice(pCCIAppliedPrice), _cciColor(pCCIColor)
   {
      InitHandle();
   }

   void InitHandle() override
   {
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, _cciColor);
      string short_name = StringFormat("CCI(%d)", _cciPeriod);
      IndicatorSetString(INDICATOR_SHORTNAME, short_name);

      IndicatorRelease(_handle);
      _handle = iCCI(_Symbol, PERIOD_CURRENT, _cciPeriod, _cciAppliedPrice);
   }

   bool ParseNewParams(string& params[]) override
   {
      if (ArraySize(params) == 4) // [ch,del], period, app price, color
      {
         _cciPeriod = (int)StringToInteger(params[1]);
         _cciAppliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[2]);
         _cciColor = StrToColor(params[3]);
         
         return true;
      }
      return false;  
   }
};
//+------------------------------------------------------------------+
//|                                                        BoxMA.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\Generic\\HashMap.mqh"

#include "Commons.mqh"
#include "BoxIndicatorData.mqh"
#include "IBoxIndicator.mqh"

class BoxMA : public IBoxIndicator
{
private:
   int _maPeriod;
   int _maShift;
   ENUM_MA_METHOD _maMethod;
   ENUM_APPLIED_PRICE _maAppliedPrice;
   color _maColor;

public:
   static bool CreateFromCmd(CHashMap<int, BoxIndicatorData*>& activeIndicators, string globalInstanceName, string& params[])
   {
      // params = [cmd_ai, MA, Symbol, TF, Period, Shift, Mode, AppliedPrice, Color]
      if (ArraySize(params) != 9)
         return false;
      
      string symbol = params[2];
      ENUM_TIMEFRAMES tf = StringToEnum<ENUM_TIMEFRAMES>(params[3]);
      int period = (int)StringToInteger(params[4]);
      int shift = (int)StringToInteger(params[5]);
      ENUM_MA_METHOD mode = StringToEnum<ENUM_MA_METHOD>(params[6]);
      ENUM_APPLIED_PRICE appliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[7]);
      string clr = params[8];
      
      int handle = iCustom(symbol, tf, "pccom\\BoxMA", period, shift, mode, appliedPrice, StrToColor(clr), globalInstanceName);
      
      string boxStr = symbol + "," + 
               IntegerToString(handle) + "," + 
               "MA," + 
               EnumToString(tf) + "," + 
               "Period=" + IntegerToString(period) + ";" + 
               "Shift=" + IntegerToString(shift) + ";" +
               "Mode=" + EnumToString(mode) + ";" + 
               "AppliedPrice=" + EnumToString(appliedPrice) + ";" + 
               "Color=" + params[8] + ";";
      
      BoxIndicatorData* biData = new BoxIndicatorData(handle, "MA", symbol, tf, globalInstanceName, boxStr);
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

   BoxMA
   (
      int pMAPeriod, 
      int pMAShift,
      ENUM_MA_METHOD pMAMethod,
      ENUM_APPLIED_PRICE pMAAppliedPrice,
      color pMAColor
   ) : 
   _maPeriod(pMAPeriod),
   _maShift(pMAShift),
   _maMethod(pMAMethod),
   _maAppliedPrice(pMAAppliedPrice),
   _maColor(pMAColor)
   {
      InitHandle();
   }   
   
   void InitHandle() override
   {
      string short_name;
      switch(_maMethod)
        {
         case MODE_EMA :
            short_name="EMA";
            break;
         case MODE_LWMA :
            short_name="LWMA";
            break;
         case MODE_SMA :
            short_name="SMA";
            break;
         case MODE_SMMA :
            short_name="SMMA";
            break;
         default :
            short_name="unknown ma";
        }
      
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, _maColor); 
      IndicatorSetString(INDICATOR_SHORTNAME, short_name + "(" + string(_maPeriod) + ")");
      
      IndicatorRelease(_handle);
      _handle = iMA(_Symbol, PERIOD_CURRENT, _maPeriod, _maShift, _maMethod, _maAppliedPrice);
   }

   bool ParseNewParams(string& params[]) override
   {
      if (ArraySize(params) == 6)
      {
         _maPeriod = (int)StringToInteger(params[1]);
         _maShift = (int)StringToInteger(params[2]);
         _maMethod = StringToEnum<ENUM_MA_METHOD>(params[3]);
         _maAppliedPrice = StringToEnum<ENUM_APPLIED_PRICE>(params[4]);
         _maColor = StrToColor(params[5]);
   
         return true;
      }
      return false;
   }
};
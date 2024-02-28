//+------------------------------------------------------------------+
//|                                                      BoxPSAR.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\Generic\\HashMap.mqh"

#include "Commons.mqh"
#include "BoxIndicatorData.mqh"
#include "IBoxIndicator.mqh"

class BoxPSAR : public IBoxIndicator
{
private:
   double _step;
   double _maximum;
   color _color;

public:
   static bool CreateFromCmd(CHashMap<int, BoxIndicatorData*>& activeIndicators, string globalInstanceName, string& params[])
   {
      // params = [cmd_ai, SAR, Symbol, TF, Step, Maximum, Color]
      if (ArraySize(params) != 7)
         return false;
      
      string symbol = params[2];
      ENUM_TIMEFRAMES tf = StringToEnum<ENUM_TIMEFRAMES>(params[3]);
      double step = StringToDouble(params[4]);
      double maximum = StringToDouble(params[5]);
      string clr = params[6];
      
      int handle = iCustom(symbol, tf, "pccom\\BoxPSAR", step, maximum, StrToColor(clr), globalInstanceName);
      
      string boxStr = symbol + "," + 
               IntegerToString(handle) + "," + 
               "SAR," + 
               EnumToString(tf) + "," + 
               "Step=" + DoubleToString(step, 2) + ";" + 
               "Maximum=" + DoubleToString(maximum, 2) + ";" +
               "Color=" + params[6] + ";";
      
      BoxIndicatorData* biData = new BoxIndicatorData(handle, "SAR", symbol, tf, globalInstanceName, boxStr);
      activeIndicators.Add(handle, biData);
      
      return true;
   }

   static bool ModifyFromCmd(BoxIndicatorData& biData, string& params[], string& gvName)
   {
      // params = [cmd, handle, Step, Maximum, Color]
      if (ArraySize(params) != 5)
         return false;
      
         gvName = ">ch," + params[2] + // step
                     "," + params[3] + // maximum
                     "," + params[4];  // color        
         
         string boxStr = biData.symbol + "," + 
                  IntegerToString(biData.handle) + "," + 
                  "SAR," + 
                  EnumToString(biData.timeframe) + "," + 
                  "Step=" + params[2] + ";" + 
                  "Maximum=" + params[3] + ";" +
                  "Color=" + params[4] + ";";
         
         biData.cmdString = boxStr;
   
      return true;
   }

   BoxPSAR
   (
      double pStep, 
      double pMaximum,
      color pColor
   ) : 
   _step(pStep),
   _maximum(pMaximum),
   _color(pColor)
   {
      InitHandle();
   }   
   
   void InitHandle() override
   {  
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, _color); 
      
      string short_name=StringFormat("SAR(%.2f,%.2f)", _step, _maximum);
      IndicatorSetString(INDICATOR_SHORTNAME, short_name);
      
      IndicatorRelease(_handle);
      _handle = iSAR(_Symbol, PERIOD_CURRENT, _step, _maximum);
   }

   bool ParseNewParams(string& params[]) override
   {
      if (ArraySize(params) == 4)
      {
         _step = StringToDouble(params[1]);
         _maximum = StringToDouble(params[2]);
         _color = StrToColor(params[3]);
   
         return true;
      }
      return false;
   }
};
//+------------------------------------------------------------------+
//|                                                        BoxSO.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\Generic\\HashMap.mqh"

#include "Commons.mqh"
#include "BoxIndicatorData.mqh"
#include "IBoxIndicator.mqh"

class BoxSO : public IBoxIndicator
{
private:
   int _kPeriod;
   int _dPeriod;
   int _slowing;
   ENUM_MA_METHOD _mode;
   ENUM_STO_PRICE _stoPrice;
   color _color1;
   color _color2;

public:
   static bool CreateFromCmd(CHashMap<int, BoxIndicatorData*>& activeIndicators, string globalInstanceName, string& params[])
   {
      // params = [cmd_ai, SO, Symbol, TF, KPeriod, DPeriod, Slowing, Mode, STOPrice, Color1, Color2]
      if (ArraySize(params) != 11)
         return false;
         
      string symbol = params[2];
      ENUM_TIMEFRAMES tf = StringToEnum<ENUM_TIMEFRAMES>(params[3]);
      int kPeriod = (int)StringToInteger(params[4]);
      int dPeriod = (int)StringToInteger(params[5]);
      int slowing = (int)StringToInteger(params[6]);
      ENUM_MA_METHOD mode = StringToEnum<ENUM_MA_METHOD>(params[7]);
      ENUM_STO_PRICE stoPrice = StringToEnum<ENUM_STO_PRICE>(params[8]);
      string clr1 = params[9];
      string clr2 = params[10];
      
      // SD
      int handle = iCustom(symbol, tf, "pccom\\BoxSO", kPeriod, dPeriod, slowing, mode, stoPrice, StrToColor(clr1), StrToColor(clr2), globalInstanceName);
      
      string boxStr = symbol + "," + 
               IntegerToString(handle) + "," + 
               "SO," + 
               EnumToString(tf) + "," + 
               "KPeriod=" + IntegerToString(kPeriod) + ";" + 
               "DPeriod=" + IntegerToString(dPeriod) + ";" + 
               "Slowing=" + IntegerToString(slowing) + ";" + 
               "Mode=" + EnumToString(mode) + ";" + 
               "STOPrice=" + EnumToString(stoPrice) + ";" + 
               "Color1=" + params[9] + ";" + 
               "Color2=" + params[10] + ";";
      
      BoxIndicatorData* biData = new BoxIndicatorData(handle, "SO", symbol, tf, globalInstanceName, boxStr);
      activeIndicators.Add(handle, biData);
   
      return true;
   }

   static bool ModifyFromCmd(BoxIndicatorData& biData, string& params[], string& gvName)
   {
      // params = [cmd, handle, KPeriod, DPeriod, Slowing, Mode, STOPrice, Color1, Color2]
      if (ArraySize(params) != 9)
         return false;
      
         gvName = ">ch," + params[2] + // KPeriod
                     "," + params[3] + // DPeriod        
                     "," + params[4] + // Slowing   
                     "," + params[5] + // Mode   
                     "," + params[6] + // STOPrice       
                     "," + params[7] + // Color1        
                     "," + params[8];  // Color2        
         
         string boxStr = biData.symbol + "," + 
                  IntegerToString(biData.handle) + "," + 
                  "SO," + 
                  EnumToString(biData.timeframe) + "," + 
                  "KPeriod=" + params[2] + ";" + 
                  "DPeriod=" + params[3] + ";" + 
                  "Slowing=" + params[4] + ";" +
                  "Mode=" + params[5] + ";" +
                  "STOPrice=" + params[6] + ";" +
                  "Color1=" + params[7] + ";" + 
                  "Color2=" + params[8] + ";";
         
         biData.cmdString = boxStr;
      
      return true;
   }

   BoxSO(int pKPeriod, int pDPeriod, int pSlowing, ENUM_MA_METHOD pMode, ENUM_STO_PRICE pSTOPrice, color pColor1, color pColor2)
      : _kPeriod(pKPeriod), _dPeriod(pDPeriod), _slowing(pSlowing), _mode(pMode), _stoPrice(pSTOPrice), _color1(pColor1), _color2(pColor2)
   {
      InitHandle();
   }

   void InitHandle() override
   {
      PlotIndexSetInteger(0, PLOT_LINE_COLOR, _color1);
      PlotIndexSetInteger(1, PLOT_LINE_COLOR, _color2);
      
      string short_name = StringFormat("SD(%d,%d,%d)", _kPeriod, _dPeriod, _slowing);
      IndicatorSetString(INDICATOR_SHORTNAME, short_name);

      IndicatorRelease(_handle);
      _handle = iStochastic(_Symbol, PERIOD_CURRENT, _kPeriod, _dPeriod, _slowing, _mode, _stoPrice);
   }

   bool ParseNewParams(string& params[]) override
   {
      if (ArraySize(params) == 8) // [ch,del], KPeriod, DPeriod, Slowing, Mode, STOPrice, Color1, Color2]
      {
         _kPeriod = (int)StringToInteger(params[1]);
         _dPeriod = (int)StringToInteger(params[2]);
         _slowing = (int)StringToInteger(params[3]);
         _mode = StringToEnum<ENUM_MA_METHOD>(params[4]);
         _stoPrice = StringToEnum<ENUM_STO_PRICE>(params[5]);
         _color1 = StrToColor(params[6]);
         _color1 = StrToColor(params[7]);
         
         return true;
      }
      return false;  
   }
};
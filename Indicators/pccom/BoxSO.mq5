//+------------------------------------------------------------------+
//|                                                        BoxSO.mq5 |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_DOT

#include "..\\..\\Include\\Generic\\HashMap.mqh"

#include "..\\..\\Include\\pccom\\Commons.mqh"
#include "..\\..\\Include\\pccom\\BoxSO.mqh"

//--- input parametrs
input int InpKPeriod = 5;
input int InpDPeriod = 3;
input int InpSlowing = 3;
input ENUM_MA_METHOD InpMode = MODE_SMA;
input ENUM_STO_PRICE InpSTOPrice = STO_LOWHIGH;
input color InpColor1 = C'255,255,128';
input color InpColor2 = C'192,192,192';
input string GlobalFlag = "IBoxSO01";

//--- indicator buffers
double    ExtMainBuffer[];
double    ExtSignalBuffer[];

BoxSO* _boxSO;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, ExtMainBuffer);
   SetIndexBuffer(1, ExtSignalBuffer);
   IndicatorSetInteger(INDICATOR_DIGITS, 2);

   _boxSO = new BoxSO(InpKPeriod, InpDPeriod, InpSlowing, InpMode, InpSTOPrice, InpColor1, InpColor2);

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (_boxSO.IsDeleted())
      return rates_total;

   //GlobalVariableSet(GlobalFlag + ">ch,200,PRICE_CLOSE,255-0-128", 0.0); // ch or del
   //GlobalVariableSet(GlobalFlag, 1.0);

   bool clearBuffers = false;
   _boxSO.ApplyNewParams(GlobalFlag, clearBuffers);

   if (clearBuffers)
   {
      ArrayFill(ExtMainBuffer, 0, ArraySize(ExtMainBuffer), NULL);
      ArrayFill(ExtSignalBuffer, 0, ArraySize(ExtSignalBuffer), NULL);
   }

   int handle = _boxSO.GetHandle();
   if (handle > 0)
   {
      int to_copy;
      //if (prev_calculated>rates_total || prev_calculated<=0) to_copy=rates_total;
      if (clearBuffers || prev_calculated > rates_total || prev_calculated <= 0) 
      {
         to_copy = rates_total;
      }
      else
      {
         to_copy=rates_total-prev_calculated;
         //--- last value is always copied
         to_copy++;
      }

      //--- try to copy
      if (CopyBuffer(handle, 0, 0, to_copy, ExtMainBuffer) <= 0)
         return(0);
      if (CopyBuffer(handle, 1, 0, to_copy, ExtSignalBuffer) <= 0)
         return(0);
   }
   return (rates_total);
}
//+------------------------------------------------------------------+

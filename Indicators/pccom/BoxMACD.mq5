//+------------------------------------------------------------------+
//|                                                      BoxMACD.mq5 |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type2   DRAW_LINE
#property indicator_color1  Silver
#property indicator_color2  Red
#property indicator_width1  2
#property indicator_width2  1
#property indicator_label1  "MACD"
#property indicator_label2  "Signal"

#include "..\\..\\Include\\Generic\\HashMap.mqh"

#include "..\\..\\Include\\pccom\\Commons.mqh"
#include "..\\..\\Include\\pccom\\BoxMACD.mqh"

//--- input parameters
input int InpFastEMA = 12;
input int InpSlowEMA = 26;
input int InpSignalSMA = 9;
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE;
input color InpColor1 = C'192,192,192';
input color InpColor2 = C'255,255,128';
input string GlobalFlag = "IBoxMACD01"; 

//--- indicator buffers
double ExtMacdBuffer[];
double ExtSignalBuffer[];

BoxMACD* _boxMACD;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, ExtMacdBuffer); 
   SetIndexBuffer(1, ExtSignalBuffer); 
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   _boxMACD = new BoxMACD(InpFastEMA, InpSlowEMA, InpSignalSMA, InpAppliedPrice, InpColor1, InpColor2);

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
   if (_boxMACD.IsDeleted())
      return rates_total;
   
   //GlobalVariableSet(GlobalFlag + ">ch,200,PRICE_CLOSE,255-0-128", 0.0); // ch or del
   //GlobalVariableSet(GlobalFlag, 1.0);

   bool clearBuffers = false;
   _boxMACD.ApplyNewParams(GlobalFlag, clearBuffers);
     
   if (clearBuffers)
   {
      ArrayFill(ExtMacdBuffer, 0, ArraySize(ExtMacdBuffer), NULL);
      ArrayFill(ExtSignalBuffer, 0, ArraySize(ExtSignalBuffer), NULL);
   }

   int handle = _boxMACD.GetHandle();
   if (handle > 0)
   {
      int to_copy;
      //if(prev_calculated>rates_total || prev_calculated<=0) to_copy=rates_total;
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
      if (CopyBuffer(handle, 0, 0, to_copy, ExtMacdBuffer) <= 0)
         return(0);
      if (CopyBuffer(handle, 1, 0, to_copy, ExtSignalBuffer) <= 0)
         return(0);
   }
   return (rates_total);
}

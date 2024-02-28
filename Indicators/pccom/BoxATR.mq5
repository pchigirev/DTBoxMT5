//+------------------------------------------------------------------+
//|                                                       BoxATR.mq5 |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE

#include "..\\..\\Include\\Generic\\HashMap.mqh"

#include "..\\..\\Include\\pccom\\Commons.mqh"
#include "..\\..\\Include\\pccom\\BoxATR.mqh"

//--- input parametrs
input int InpAtrPeriod = 14;
input color InpColor = C'255,255,128';
input string GlobalFlag = "IBoxSDI01"; // CmdString = "IBoxCCI01_cmd,P=50,AP=PRICE_MEDIAN"; cmd = {"ch", "del"}

//--- indicator buffers
double ExtATRBuffer[];

BoxATR* _boxATR;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, ExtATRBuffer);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   _boxATR = new BoxATR(InpAtrPeriod, InpColor);

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
   if (_boxATR.IsDeleted())
      return rates_total;

   //GlobalVariableSet(GlobalFlag + ">ch,200,PRICE_CLOSE,255-0-128", 0.0); // ch or del
   //GlobalVariableSet(GlobalFlag, 1.0);

   bool clearBuffers = false;
   _boxATR.ApplyNewParams(GlobalFlag, clearBuffers);

   if (clearBuffers)
   {
      ArrayFill(ExtATRBuffer, 0, ArraySize(ExtATRBuffer), NULL);
   }

   int handle = _boxATR.GetHandle();
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
      if (CopyBuffer(handle, 0, 0, to_copy, ExtATRBuffer) <= 0)
         return(0);
   }
   return (rates_total);
}
//+------------------------------------------------------------------+

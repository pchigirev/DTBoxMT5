//+------------------------------------------------------------------+
//|                                                      BoxPSAR.mq5 |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_ARROW

#include "..\\..\\Include\\pccom\\Commons.mqh"
#include "..\\..\\Include\\pccom\\BoxPSAR.mqh"

//--- input parameters
input double InpSARStep = 0.02;
input double InpSARMaximum = 0.2;
input color InpColor = C'255,255,128';
input string GlobalFlag = "IB-PSAR";

//--- indicator buffers
double ExtSARBuffer[];

BoxPSAR* _boxPSAR;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
   SetIndexBuffer(0, ExtSARBuffer, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   _boxPSAR = new BoxPSAR(InpSARStep, InpSARMaximum, InpColor);
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
   if (_boxPSAR.IsDeleted())
      return rates_total;
   
   //GlobalVariableSet(GlobalFlag + ">ch,200,0,MODE_EMA,PRICE_CLOSE,255-0-128", 0.0); // ch or del
   //GlobalVariableSet(GlobalFlag, 1.0);
   
   bool clearBuffers;
   _boxPSAR.ApplyNewParams(GlobalFlag, clearBuffers);
      
   if (clearBuffers)
   {
      ArrayFill(ExtSARBuffer, 0, ArraySize(ExtSARBuffer), NULL);
   }

   int handle = _boxPSAR.GetHandle();
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
      if (CopyBuffer(handle, 0, 0, to_copy, ExtSARBuffer) <= 0) 
         return(0);
   }
   return(rates_total);
}
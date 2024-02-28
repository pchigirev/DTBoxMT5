//+------------------------------------------------------------------+
//|                                                        BoxBB.mq5 |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_color1  LightSeaGreen
#property indicator_type2   DRAW_LINE
#property indicator_color2  LightSeaGreen
#property indicator_type3   DRAW_LINE
#property indicator_color3  LightSeaGreen
#property indicator_label1  "Bands middle"
#property indicator_label2  "Bands upper"
#property indicator_label3  "Bands lower"

#include "..\\..\\Include\\pccom\\Commons.mqh"
#include "..\\..\\Include\\pccom\\BoxBB.mqh"

//--- input parametrs
input int     InpBandsPeriod = 20; 
input int     InpBandsShift = 0;
input double  InpBandsDeviations = 2.0;
input ENUM_APPLIED_PRICE InpBandsAppliedPrice = PRICE_MEDIAN;
input color InpColor = C'255,255,128';
input string GlobalFlag = "BB01"; 

//--- indicator buffer
double        ExtMLBuffer[];
double        ExtTLBuffer[];
double        ExtBLBuffer[];

BoxBB* _boxBB;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, ExtMLBuffer);
   SetIndexBuffer(1, ExtTLBuffer);
   SetIndexBuffer(2, ExtBLBuffer);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   _boxBB = new BoxBB(InpBandsPeriod, InpBandsShift, InpBandsDeviations, InpBandsAppliedPrice, InpColor);
   
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
   if (_boxBB.IsDeleted())
      return rates_total;
   
   //GlobalVariableSet(GlobalFlag + ">ch,200,0,MODE_EMA,PRICE_CLOSE,255-0-128", 0.0); // ch or del
   //GlobalVariableSet(GlobalFlag, 1.0);
   
   bool clearBuffers;
   _boxBB.ApplyNewParams(GlobalFlag, clearBuffers);
      
   if (clearBuffers)
   {
      ArrayFill(ExtMLBuffer, 0, ArraySize(ExtMLBuffer), NULL);
      ArrayFill(ExtTLBuffer, 0, ArraySize(ExtTLBuffer), NULL);
      ArrayFill(ExtBLBuffer, 0, ArraySize(ExtBLBuffer), NULL);
   }

   int handle = _boxBB.GetHandle();
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
      if (CopyBuffer(handle, 0, 0, to_copy, ExtMLBuffer) <= 0) 
         return(0);
      if (CopyBuffer(handle, 1, 0, to_copy, ExtTLBuffer) <= 0) 
         return(0);
      if (CopyBuffer(handle, 2, 0, to_copy, ExtBLBuffer) <= 0) 
         return(0);
   }
   return(rates_total);
}
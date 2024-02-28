//+------------------------------------------------------------------+
//|                                                        BoxMA.mq5 |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red

#include "..\\..\\Include\\pccom\\Commons.mqh"
#include "..\\..\\Include\\pccom\\BoxMA.mqh"

//--- input parameters
input int            InpMAPeriod = 13;         // Period
input int            InpMAShift = 0;           // Shift
input ENUM_MA_METHOD InpMAMethod = MODE_SMA;  // Method
input ENUM_APPLIED_PRICE InpMAAppliedPrice = PRICE_MEDIAN;
input color InpColor = C'255,255,128';
input string GlobalFlag = "MA01"; // CmdString = "IBoxMA01_cmd,Period=50,Shift=0,Method=MODE_SMA,AppPrice=PRICE_MEDIAN,Color=255-255-80";

//--- indicator buffer
double ExtLineBuffer[];

BoxMA* _boxMA;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
   SetIndexBuffer(0, ExtLineBuffer, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   _boxMA = new BoxMA(InpMAPeriod, InpMAShift, InpMAMethod, InpMAAppliedPrice, InpColor);
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
   if (_boxMA.IsDeleted())
      return rates_total;
   
   //GlobalVariableSet(GlobalFlag + ">ch,200,0,MODE_EMA,PRICE_CLOSE,255-0-128", 0.0); // ch or del
   //GlobalVariableSet(GlobalFlag, 1.0);
   
   bool clearBuffers;
   _boxMA.ApplyNewParams(GlobalFlag, clearBuffers);
   //Print("Clear buffers: " + (clearBuffers ? "true" : "false"));
      
   if (clearBuffers)
   {
      ArrayFill(ExtLineBuffer, 0, ArraySize(ExtLineBuffer), NULL);
   }

   int handle = _boxMA.GetHandle();
   if (handle > 0)
   {
      int to_copy;
      //if (clearBuffers || prev_calculated > rates_total || prev_calculated <= 0) to_copy = rates_total;
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
      if (CopyBuffer(handle, 0, 0, to_copy, ExtLineBuffer) <= 0) 
         return(0);
   }
   return(rates_total);
}
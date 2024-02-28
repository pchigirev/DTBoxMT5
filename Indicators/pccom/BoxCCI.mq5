//+------------------------------------------------------------------+
//|                                                       BoxCCI.mq5 |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#property indicator_separate_window
#property indicator_buffers       1
#property indicator_plots         1
#property indicator_type1         DRAW_LINE
#property indicator_color1        LightSeaGreen
#property indicator_level1       -100.0
#property indicator_level2        100.0

#include "..\\..\\Include\\Generic\\HashMap.mqh"

#include "..\\..\\Include\\pccom\\Commons.mqh"
#include "..\\..\\Include\\pccom\\BoxCCI.mqh"

//--- input parametrs
input int InpCCIPeriod = 14; // Period
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_TYPICAL;
input color InpColor = C'255,255,128';
input string GlobalFlag = "IBoxCCI01"; // CmdString = "IBoxCCI01_cmd,P=50,AP=PRICE_MEDIAN"; cmd = {"ch", "del"}

//--- indicator buffers
double ExtCCIBuffer[];

BoxCCI* _boxCCI;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0,ExtCCIBuffer); 
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   _boxCCI = new BoxCCI(InpCCIPeriod, InpAppliedPrice, InpColor);

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
   if (_boxCCI.IsDeleted())
      return rates_total;
   
   //GlobalVariableSet(GlobalFlag + ">ch,200,PRICE_CLOSE,255-0-128", 0.0); // ch or del
   //GlobalVariableSet(GlobalFlag, 1.0);

   bool clearBuffers = false;
   _boxCCI.ApplyNewParams(GlobalFlag, clearBuffers);
     
   if (clearBuffers)
   {
      ArrayFill(ExtCCIBuffer, 0, ArraySize(ExtCCIBuffer), NULL);
   }

   int handle = _boxCCI.GetHandle();
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
      if (CopyBuffer(handle, 0, 0, to_copy, ExtCCIBuffer) <= 0)
         return(0);
   }
   return (rates_total);
}
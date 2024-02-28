//+------------------------------------------------------------------+
//|                                             BoxIndicatorData.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

class BoxIndicatorData
{
public:
   int handle;
   string type;
   string symbol;
   ENUM_TIMEFRAMES timeframe;
   string globalInstanceName;
   string cmdString;
   BoxIndicatorData(int pHandle, string pType, string pSymbol, ENUM_TIMEFRAMES pTimeframe, string pGlobalInstanceName, string pCMDString) 
      : handle(pHandle), type(pType), symbol(pSymbol), timeframe(pTimeframe), globalInstanceName(pGlobalInstanceName), cmdString(pCMDString)
   {
   }
};

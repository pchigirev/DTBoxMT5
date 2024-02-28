//+------------------------------------------------------------------+
//|                                                       Box0.1.mq5 |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\..\\Include\\Generic\\HashMap.mqh"
#include "..\\..\\Include\\pccom\\Sockets.mqh"
#include "..\\..\\Include\\pccom\\Commons.mqh"
#include "..\\..\\Include\\pccom\\Commands.mqh"
#include "..\\..\\Include\\pccom\\BoxIndicatorData.mqh"
#include "..\\..\\Include\\pccom\\AllIndicators.mqh"

SocketClient* _sc;

const ulong EXPERT_MAGIC = 4264821;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   bool isVisual = (bool)MQLInfoInteger(MQL_VISUAL_MODE);
   if (!isVisual)
   {
      Print("Please restart Box0.1 EA in visual mode");
      return(INIT_FAILED);
   }

   _sc = new SocketClient("127.0.0.1", 16500);
   _sc.Connect();
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   _sc.Disconnect();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int _lastCount = 0;
void OnTick()
{
   MqlRates rates[];
   CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, rates);
     
   // Heartbeat
   int countNow = (int)GetTickCount();
   if (MathAbs(countNow - _lastCount) > 1000)
   {
      if (!_sc.SendStr(cmd_heartbeat))
      {
         Print("Connection to DT-Box server has been lost");  
         TesterStop();
      }
      _lastCount = countNow;
   }
      
   CArrayList<string> recvCmds;
   _sc.ReceiveData(recvCmds);
   if (recvCmds.Count() > 0)
   {
      int cnt = recvCmds.Count();
      for (int i = 0; i < cnt; i++)
      {
         string cmd;
         if (recvCmds.TryGetValue(i, cmd))
         {
            if (StringFind(cmd, cmd_heartbeat, 0) < 0)
               Print(cmd);
               
            if (StringFind(cmd, cmd_send_new_order, 0) == 0)
               ProcessCMDNewOrder(cmd);
            if (StringFind(cmd, cmd_cancel_pending_order, 0) == 0)
               ProcessCMDCancelOrder(cmd);
            if (StringFind(cmd, cmd_close_position, 0) == 0)
               ProcessCMDClosePosition(cmd);
            if (StringFind(cmd, cmd_modify_pending_order, 0) == 0)
               ProcessCMDModifyOrder(cmd);
            if (StringFind(cmd, cmd_modify_open_position, 0) == 0)
               ProcessCMDModifyPosition(cmd);
            if (StringFind(cmd, cmd_part_close_position, 0) == 0)
               ProcessCMDPartClose(cmd);
            if (StringFind(cmd, cmd_new_indicator, 0) == 0)
               ProcessCMDAddIndicator(cmd);
            if (StringFind(cmd, cmd_change_indicator, 0) == 0)
               ProcessCMDModifyIndicator(cmd);
            if (StringFind(cmd, cmd_delete_indicator, 0) == 0)
               ProcessCMDDeleteIndicator(cmd);
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
 
}
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
{
  
}
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
string _lastCmdPO = "";
string _lastCmdOP = "";
void OnTradeTransaction
(
   const MqlTradeTransaction& trans,
   const MqlTradeRequest& request,
   const MqlTradeResult& result
)
{
   // Check orders
   string cmdPO = checkAllOrders();
   if (cmdPO != _lastCmdPO)
   {
      _lastCmdPO = cmdPO;
      _sc.SendStr(cmdPO);
   }
         
   string cmdOP = checkAllPositions();
   if (cmdOP != _lastCmdOP)
   {
      _lastCmdOP = cmdOP;
      _sc.SendStr(cmdOP);
   }
}
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
{
   _sc.Disconnect();
   return 0.0;
}
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
{
  
}
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
{
  
}
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
{
   
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
  
}
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
{
   
}

//+------------------------------------------------------------------+

void ProcessCMDNewOrder(string cmd)
{
   string params[];
   if (StringSplit(cmd, ',', params) == 8)
   {
      // cmd, Symbol, isLong, OrderType, Price, Size, SL, TP
      string symbol = params[1];
      bool isLong = params[2] == "true";
      string orderType = params[3];
      double price = StringToDouble(params[4]);
      double size = StringToDouble(params[5]);
      double sl = StringToDouble(params[6]); 
      double tp = StringToDouble(params[7]);
      
      // Send order
      if (orderType == "mkt")
         doSendMarketOrder(symbol, isLong, size, sl, tp);  
      else if (orderType == "lmt")
         doSendLimitOrder(symbol, isLong, price, size, sl, tp);
      else if (orderType == "stp")
         doSendStopOrder(symbol, isLong, price, size, sl, tp);
      else
         Print("Unknown order type in cmd from DT-Box: " + cmd);
   }
   else
      Print("Incorrect new order cmd from DT-Box: " + cmd);
}

//+------------------------------------------------------------------+

void ProcessCMDModifyOrder(string cmd)
{
   string params[];
   if (StringSplit(cmd, ',', params) == 6)
   {
      ulong id = (ulong)StringToInteger(params[1]);
      double volume = StringToDouble(params[2]);
      double price = StringToDouble(params[3]);
      double sl = StringToDouble(params[4]);
      double tp = StringToDouble(params[5]);

      doModifyPendingOrderById(id, price, volume, sl, tp);
   }
   else
      Print("Incorrect modify cmd from DT-Box: " + cmd);
}

//+------------------------------------------------------------------+

void ProcessCMDModifyPosition(string cmd)
{
   string params[];
   if (StringSplit(cmd, ',', params) == 4)
   {
      ulong id = (ulong)StringToInteger(params[1]);
      double sl = StringToDouble(params[2]);
      double tp = StringToDouble(params[3]);
   
      doModifyOpenPositionById(id, sl, tp);
   }
   else
      Print("Incorrect modify position cmd from DT-Box: " + cmd);
}

//+------------------------------------------------------------------+

void ProcessCMDCancelOrder(string cmd)
{
   string params[];
   if (StringSplit(cmd, ',', params) == 2)
   {
      ulong id = (ulong)StringToInteger(params[1]);
      
      doCancelPendingOrderById(id, "Cancel from DT-Box");
   }
   else
      Print("Incorrect cancel order cmd from DT-Box: " + cmd);
}

//+------------------------------------------------------------------+

void ProcessCMDClosePosition(string cmd)
{
   string params[];
   if (StringSplit(cmd, ',', params) == 2)
   {
      ulong id = (ulong)StringToInteger(params[1]);
      
      doClosePosition(id, "Close from DT-Box");
   }
   else
      Print("Incorrect close position cmd from DT-Box: " + cmd);
}

//+------------------------------------------------------------------+

void ProcessCMDPartClose(string cmd)
{
   string params[];
   if (StringSplit(cmd, ',', params) == 3)
   {
      ulong id = (ulong)StringToInteger(params[1]);
      double volumeToClose = StringToDouble(params[2]);
      
      doPartialClose(id, volumeToClose);
   }
   else
      Print("Incorrect partial close cmd from DT-Box: " + cmd);
}

//+------------------------------------------------------------------+

int _indicatorCnt = 0;
CHashMap<int, BoxIndicatorData*> _activeIndicators;
void ProcessCMDAddIndicator(string cmd)
{
   bool isCreated = false;
   string params[];
   StringSplit(cmd, ',', params);
   
   string type = params[1];
   if (type == "MA")
   {
      string globalInstanceName = "IB-MA" + IntegerToString(++_indicatorCnt);
      if (BoxMA::CreateFromCmd(_activeIndicators, globalInstanceName, params))
      {
         isCreated = true;
         GlobalVariableSet(globalInstanceName, -1.0);
      }
      else
         Print("Cannot create MA indicator from cmd " + cmd);
   }
   else if (type == "CCI")
   {    
      string globalInstanceName = "IB-CCI" + IntegerToString(++_indicatorCnt);
      if (BoxCCI::CreateFromCmd(_activeIndicators, globalInstanceName, params))
      {
         isCreated = true;
         GlobalVariableSet(globalInstanceName, -1.0);
      }
      else
         Print("Cannot create CCI indicator from cmd " + cmd);
   }
   else if (type == "BB")
   {    
      string globalInstanceName = "IB-BB" + IntegerToString(++_indicatorCnt);
      if (BoxBB::CreateFromCmd(_activeIndicators, globalInstanceName, params))
      {
         isCreated = true;
         GlobalVariableSet(globalInstanceName, -1.0);
      }
      else
         Print("Cannot create BB indicator from cmd " + cmd);
   }
   else if (type == "MACD")
   {    
      string globalInstanceName = "IB-MACD" + IntegerToString(++_indicatorCnt);
      if (BoxMACD::CreateFromCmd(_activeIndicators, globalInstanceName, params))
      {
         isCreated = true;
         GlobalVariableSet(globalInstanceName, -1.0);
      }
      else
         Print("Cannot create BB indicator from cmd " + cmd);
   }
   else if (type == "SD")
   {
      string globalInstanceName = "IB-SD" + IntegerToString(++_indicatorCnt);
      if (BoxSD::CreateFromCmd(_activeIndicators, globalInstanceName, params))
      {
         isCreated = true;
         GlobalVariableSet(globalInstanceName, -1.0);
      }
      else
         Print("Cannot create SD indicator from cmd " + cmd);
   }
   else if (type == "ATR")
   {
      string globalInstanceName = "IB-ATR" + IntegerToString(++_indicatorCnt);
      if (BoxATR::CreateFromCmd(_activeIndicators, globalInstanceName, params))
      {
         isCreated = true;
         GlobalVariableSet(globalInstanceName, -1.0);
      }
      else
         Print("Cannot create ATR indicator from cmd " + cmd);
   }
   else if (type == "SO")
   {
      string globalInstanceName = "IB-SO" + IntegerToString(++_indicatorCnt);
      if (BoxSO::CreateFromCmd(_activeIndicators, globalInstanceName, params))
      {
         isCreated = true;
         GlobalVariableSet(globalInstanceName, -1.0);
      }
      else
         Print("Cannot create SO indicator from cmd " + cmd);
   }
   else if (type == "SAR")
   {
      string globalInstanceName = "IB-SAR" + IntegerToString(++_indicatorCnt);
      if (BoxPSAR::CreateFromCmd(_activeIndicators, globalInstanceName, params))
      {
         isCreated = true;
         GlobalVariableSet(globalInstanceName, -1.0);
      }
      else
         Print("Cannot create SAR indicator from cmd " + cmd);
   }
   else if (type == "TEMA")
   {
      string globalInstanceName = "IB-TEMA" + IntegerToString(++_indicatorCnt);
      if (BoxTEMA::CreateFromCmd(_activeIndicators, globalInstanceName, params))
      {
         isCreated = true;
         GlobalVariableSet(globalInstanceName, -1.0);
      }
      else
         Print("Cannot create TEMA indicator from cmd " + cmd);
   }
   else if (type == "AMA")
   {
      string globalInstanceName = "IB-AMA" + IntegerToString(++_indicatorCnt);
      if (BoxAMA::CreateFromCmd(_activeIndicators, globalInstanceName, params))
      {
         isCreated = true;
         GlobalVariableSet(globalInstanceName, -1.0);
      }
      else
         Print("Cannot create AMA indicator from cmd " + cmd);
   }
   else
      Print("Unsupported indicator type: " + cmd);
      
   if (isCreated)
   {
      // Update
      string cmdAllIndicators = checkAllIndicators();
      _sc.SendStr(cmdAllIndicators);
   }
}

//+------------------------------------------------------------------+

void ProcessCMDModifyIndicator(string cmd)
{
   bool isUpdated = false;
   string params[]; 
   StringSplit(cmd, ',', params); // cmd,handle,[params]
   int handle = (int)StringToInteger(params[1]);
           
   BoxIndicatorData* biData;
   if (_activeIndicators.TryGetValue(handle, biData))
   {
      string gvName;
      if (biData.type == "MA")
      {
         if (BoxMA::ModifyFromCmd(biData, params, gvName))
            isUpdated = true;
         else
            Print("Incorrect modify cmd for MA indicator: " + cmd);
      }   
      else if (biData.type == "CCI")
      {
         if (BoxCCI::ModifyFromCmd(biData, params, gvName))
            isUpdated = true;
         else
            Print("Incorrect modify cmd for CCI indicator: " + cmd);
      }
      else if (biData.type == "BB")
      {
         if (BoxBB::ModifyFromCmd(biData, params, gvName))
            isUpdated = true;
         else
            Print("Incorrect modify cmd for BB indicator: " + cmd);
      }
      else if (biData.type == "MACD")
      {
         if (BoxMACD::ModifyFromCmd(biData, params, gvName))
            isUpdated = true;
         else
            Print("Incorrect modify cmd for MACD indicator: " + cmd);
      }
      else if (biData.type == "SD")
      {
         if (BoxSD::ModifyFromCmd(biData, params, gvName))
            isUpdated = true;
         else
            Print("Incorrect modify cmd for SD indicator: " + cmd);
      }
      else if (biData.type == "ATR")
      {
         if (BoxATR::ModifyFromCmd(biData, params, gvName))
            isUpdated = true;
         else
            Print("Incorrect modify cmd for ATR indicator: " + cmd); 
      }
      else if (biData.type == "SO")
      {
         if (BoxSO::ModifyFromCmd(biData, params, gvName))
            isUpdated = true;
         else
            Print("Incorrect modify cmd for SO indicator: " + cmd); 
      }
      else if (biData.type == "SAR")
      {
         if (BoxPSAR::ModifyFromCmd(biData, params, gvName))
            isUpdated = true;
         else
            Print("Incorrect modify cmd for SAR indicator: " + cmd); 
      }
      else if (biData.type == "TEMA")
      {
         if (BoxTEMA::ModifyFromCmd(biData, params, gvName))
            isUpdated = true;
         else
            Print("Incorrect modify cmd for TEMA indicator: " + cmd); 
      }
      else if (biData.type == "AMA")
      {
         if (BoxAMA::ModifyFromCmd(biData, params, gvName))
            isUpdated = true;
         else
            Print("Incorrect modify cmd for AMA indicator: " + cmd); 
      }
      
      if (isUpdated)
      {
         GlobalVariableSet(biData.globalInstanceName + gvName, 0.0); 
         GlobalVariableSet(biData.globalInstanceName, 1.0);
      }
   }
   else
      Print("Cannot find indicator with handle: " + IntegerToString(handle));
      
   if (isUpdated)
   {
      string cmdAllIndicators = checkAllIndicators();
      _sc.SendStr(cmdAllIndicators);
   }
}

//+------------------------------------------------------------------+

void ProcessCMDDeleteIndicator(string cmd)
{
   string params[];
   if (StringSplit(cmd, ',', params) == 2)
   {
      int handle = (int)StringToInteger(params[1]);
      
      BoxIndicatorData* biData;
      if (_activeIndicators.TryGetValue(handle, biData))
      {
         GlobalVariableSet(biData.globalInstanceName + ">del,", 0.0);
         GlobalVariableSet(biData.globalInstanceName, 1.0);
         
         _activeIndicators.Remove(handle);
         _sc.SendStr(checkAllIndicators());
      }
      else
         Print("Cannot find indicator with handle: " + IntegerToString(handle));
   }
   else
      Print("Incorrect delete indicator cmd from DT-Box: " + cmd);
}

//+------------------------------------------------------------------+

// GF
ulong doSendLimitOrder(string symbol, bool isBuy, double price, double size, double stopLoss, double takeProfit)
{
   // Limit order
   {
      MqlTradeRequest request = {};
      MqlTradeResult result = {};
   
      //--- parameters of request
      request.action = TRADE_ACTION_PENDING;
      request.symbol = symbol;
      request.volume = size;
      request.type = isBuy ? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
      request.price = price;
      request.deviation = 5;
      request.magic = EXPERT_MAGIC;   
      request.sl = stopLoss;
      request.tp = takeProfit;
   
      //--- send the request
      if (!OrderSend(request, result))
      {
         int lastError = GetLastError();
         PrintFormat(__FUNCTION__ + ": OrderSend error " + IntegerToString(lastError) + ", request return code " + IntegerToString(result.retcode) + ", result.order = " + IntegerToString(result.order));
         
         return 0;
      }
      
      return result.order;
   }
}

// GF
ulong doSendStopOrder(string symbol, bool isBuy, double price, double size, double stopLoss, double takeProfit)
{
   // Stop order
   {
      MqlTradeRequest request = {};
      MqlTradeResult result = {};
   
      //--- parameters of request
      request.action = TRADE_ACTION_PENDING;
      request.symbol = symbol;
      request.volume = size;
      request.type = isBuy ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
      request.price = price;
      request.deviation = 5;
      request.magic = EXPERT_MAGIC;  
      request.sl = stopLoss;
      request.tp = takeProfit; 
   
      //--- send the request
      if (!OrderSend(request, result))
      {
         int lastError = GetLastError();
         PrintFormat(__FUNCTION__ + ": OrderSend error " + IntegerToString(lastError) + ", request return code " + IntegerToString(result.retcode) + ", result.order = " + IntegerToString(result.order));
         
         return 0;
      }
      
      return result.order;
   }
}

// GF
ulong doSendMarketOrder(string symbol, bool isBuy, double size, double stopLoss, double takeProfit)
{
   // Market order
   {
      MqlTradeRequest request = {};
      MqlTradeResult result = {};
   
      //--- parameters of request
      request.action = TRADE_ACTION_DEAL;
      request.symbol = symbol;
      request.price = isBuy ? SymbolInfoDouble(symbol, SYMBOL_ASK) : SymbolInfoDouble(symbol, SYMBOL_BID);
      request.volume = size;
      request.type = isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      request.deviation = 5;
      request.magic = EXPERT_MAGIC;  
      request.sl = stopLoss;
      request.tp = takeProfit; 
      //request.type_filling = SYMBOL_FILLING_FOK;
      //request.type_filling = ORDER_FILLING_IOC;
   
      //--- send the request
      if (!OrderSend(request, result))
      {
         int lastError = GetLastError();
         PrintFormat(__FUNCTION__ + ": OrderSend error " + IntegerToString(lastError) + ", request return code " + IntegerToString(result.retcode) + ", result.order = " + IntegerToString(result.order));
         
         return 0;
      }
      
      return result.order;
   }
}

// GF
void doCancelPendingOrderById(ulong orderId, string reason)
{
   if (OrderSelect(orderId))
   {
      MqlTradeRequest request = {};
      MqlTradeResult result = {};

      request.action = TRADE_ACTION_REMOVE;
      request.order = orderId;
   
      if (!OrderSend(request, result))
      {
         Print("Cannot cancel order by id " + IntegerToString(orderId) + ". Cancellation reason is " + reason);
         StopEAOnError();
         return;
      }
      
      Print("Order has been cancelled " + IntegerToString(orderId) + ". Cancellation reason is " + reason);
   }
   else
   {
      Print("CancelOrderById: Warning: order with id=" + (string)orderId + " cannot be found among active orders");
   }
}

// GF
bool doClosePosition(ulong orderId, string reason)
{
   int total = PositionsTotal();
   for(int i = 0; i < total; ++i)
   {
      ulong ticket = PositionGetTicket(i);
      if (!PositionSelectByTicket(ticket))
      {
         PrintFormat("PositionSelectByTicket error %d", GetLastError()); 
         StopEAOnError();
         return false; 
      }
      
      ulong positionOrderId = PositionGetInteger(POSITION_IDENTIFIER);
      if (orderId == positionOrderId) 
      {
         MqlTradeRequest request = {};
         MqlTradeResult result = {};
         
         request.action = TRADE_ACTION_DEAL;        
         request.position = ticket;        
         request.symbol = PositionGetString(POSITION_SYMBOL);          
         request.volume = PositionGetDouble(POSITION_VOLUME);                   
         request.deviation = 5;                     
         request.magic = EXPERT_MAGIC;     
         //request.type_filling = SYMBOL_FILLING_FOK;        
         //request.type_filling = ORDER_FILLING_IOC;
  
         ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if(type == POSITION_TYPE_BUY)
         {
            request.price = SymbolInfoDouble(request.symbol, SYMBOL_BID);
            request.type = ORDER_TYPE_SELL;
         }
         else
         {
            request.price = SymbolInfoDouble(request.symbol,SYMBOL_ASK);
            request.type = ORDER_TYPE_BUY;
         }
         
         if(!OrderSend(request,result))
         {
            PrintFormat(__FUNCTION__ + ": OrderSend error %d", GetLastError()); 
            StopEAOnError();
            return false; 
         }
            
         return true;
      }
   }
   return false;
}

// GF
void doModifyPendingOrderById(ulong orderId, double newPrice, double newVolume, double newSL, double newTP)
{
   if (OrderSelect(orderId))
   {
      string orderSymbol = OrderGetString(ORDER_SYMBOL);
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      double orderVolume = OrderGetDouble(ORDER_VOLUME_CURRENT);
      bool needCancelReplace = MathAbs(newPrice - orderPrice) > FLT_EPSILON || MathAbs(newVolume - orderVolume) > FLT_EPSILON;
      if (needCancelReplace)
      {
         doCancelPendingOrderById(orderId, "Cancel/replace for modify volume cmd from grey box");
         newVolume = normalizeVolume(orderSymbol, newVolume);
         ENUM_ORDER_TYPE orderType = ENUM_ORDER_TYPE(OrderGetInteger(ORDER_TYPE));
         switch (orderType)
         {
            case ORDER_TYPE_BUY:
               doSendMarketOrder(orderSymbol, true, newVolume, newSL, newTP);
               break;
            
            case ORDER_TYPE_SELL:
               doSendMarketOrder(orderSymbol, false, newVolume, newSL, newTP);
               break;
               
            case ORDER_TYPE_BUY_LIMIT:
               doSendLimitOrder(orderSymbol, true, newPrice, newVolume, newSL, newTP);
               break;
            
            case ORDER_TYPE_SELL_LIMIT:
               doSendLimitOrder(orderSymbol, false, newPrice, newVolume, newSL, newTP);
               break;
              
            case ORDER_TYPE_BUY_STOP:
               doSendStopOrder(orderSymbol, true, newPrice, newVolume, newSL, newTP);
               break;
            
            case ORDER_TYPE_SELL_STOP:
               doSendStopOrder(orderSymbol, false, newPrice, newVolume, newSL, newTP);
               break;  

            default:
               PrintFormat(__FUNCTION__ + ": Unsupported order type in modify order cmd", GetLastError());
               break;
         }
         return;
      }
      
      // Check if sl and tp are the same
      if (newSL == OrderGetDouble(ORDER_SL) && newTP == OrderGetDouble(ORDER_TP))
         return; 
      
      string symbol = OrderGetString(ORDER_SYMBOL);
      
      MqlTradeRequest request = {};
      MqlTradeResult  result = {};
    
      request.action = TRADE_ACTION_MODIFY;
      request.order = orderId;
      request.symbol = symbol;
      request.magic = EXPERT_MAGIC;
            
      request.price = OrderGetDouble(ORDER_PRICE_OPEN);
      request.sl = newSL;
      request.tp = newTP;
            
      if (!OrderSend(request, result))
      {
         PrintFormat(__FUNCTION__ + ": Can't modify pending order by Id, error %d", GetLastError()); 
         return; 
      }
   }
   else
   {
      PrintFormat(__FUNCTION__ + ": Can't find pending by Id, error %d", GetLastError()); 
      return; 
   }
}

// GF
void doModifyOpenPositionById(ulong posId, double newSL, double newTP)
{
   if (PositionSelectByTicket(posId))
   {
      // Check if sl and tp are the same
      if (newSL == PositionGetDouble(POSITION_SL) && newTP == PositionGetDouble(POSITION_TP))
         return; 
      
      string symbol = PositionGetSymbol(POSITION_SYMBOL);
      
      MqlTradeRequest request = {};
      MqlTradeResult  result = {};
    
      request.action = TRADE_ACTION_SLTP;
      request.position = posId;
      request.symbol = symbol;
      request.magic = EXPERT_MAGIC;
            
      request.sl = newSL;
      request.tp = newTP;
            
      if(!OrderSend(request, result))
      {
         PrintFormat(__FUNCTION__ + ": Can't modify open position by Id, error %d", GetLastError()); 
         return; 
      }
   }
   else
   {
      PrintFormat(__FUNCTION__ + ": Can't find position by Id, error %d", GetLastError()); 
      return; 
   }
}

// GF
void doPartialClose(ulong positionTicket, double volumeToClose)
{
   if (PositionSelectByTicket(positionTicket))
   {
      string symbol = PositionGetString(POSITION_SYMBOL);
      double currentVolume = PositionGetDouble(POSITION_VOLUME); 
 
      MqlTradeRequest request = {};
      MqlTradeResult  result = {};
           
      request.action = TRADE_ACTION_DEAL;
      request.position = positionTicket;
      request.symbol = PositionGetString(POSITION_SYMBOL);
      request.magic = PositionGetInteger(POSITION_MAGIC);
           
      // Modify volume
      double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      if (volumeToClose < minVolume)
      {
         Print(__FUNCTION__ + ": Can't partially close position: requested volume " + DoubleToString(volumeToClose) + " is below min allowed volume " + DoubleToString(minVolume)); 
         return;
      }

      if (volumeToClose > currentVolume)
         volumeToClose = currentVolume;
            
      request.volume = normalizeVolume(symbol, volumeToClose);

      // Order side
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    
      if (type == POSITION_TYPE_BUY)
      {
         request.price = SymbolInfoDouble(symbol, SYMBOL_BID);
         request.type = ORDER_TYPE_SELL;
      }
      else
      {
         request.price = SymbolInfoDouble(symbol, SYMBOL_ASK);
         request.type = ORDER_TYPE_BUY;
      }
         
      if (!OrderSend(request, result))
      {
         PrintFormat(__FUNCTION__ + ": Can't partially close position by ticket, error %d", GetLastError()); 
         StopEAOnError();
         return; 
      }
   }
   else
   {
      // Warning
      Print(__FUNCTION__ + ": Cannot select position by ticket " + IntegerToString(positionTicket)); 
      return;
   }
}

// GF
double normalizeVolume(string symbol, double volValue)
{        
   double volStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double volMin = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double volMax = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
        	
   double result = volValue;
         
   if (volStep == 0.1)
      result = NormalizeDouble(result, 1);
   else if(volStep == 0.01)
      result = NormalizeDouble(result, 2);
   else if(volStep == 0.001)
      result = NormalizeDouble(result, 3);
       
   result = MathFloor(result / volStep) * volStep;
   result = MathMin(result, volMax);	
   result = MathMax(result, volMin);
         	
   return result;
}

// GF
string checkAllIndicators()
{
   int count = _activeIndicators.Count();
   if (count > 0)
   {
      int keys[]; 
      BoxIndicatorData* biData[];
      _activeIndicators.CopyTo(keys, biData);
      
      string cmd = cmd_all_indicators + "," + IntegerToString(count);
      for(int i = 0; i < count; ++i)
         cmd += "," + biData[i].cmdString;
      
      return cmd;
   }
   return cmd_all_indicators + ",0";
}

// GF
string checkAllOrders()
{
   int count = OrdersTotal();
   if (count > 0)
   {
      string cmd = cmd_all_pending_orders + "," + IntegerToString(count);
      for(int i = 0; i < count; ++i)
      {
         if (OrderSelect(OrderGetTicket(i)))
         {
            cmd += "," + OrderGetString(ORDER_SYMBOL);
            cmd += "," + IntegerToString(OrderGetInteger(ORDER_TICKET));
            cmd += "," + TimeToString(datetime(OrderGetInteger(ORDER_TIME_SETUP)), TIME_DATE|TIME_SECONDS);
            cmd += "," + (StringFind(EnumToString(ENUM_ORDER_TYPE(OrderGetInteger(ORDER_TYPE))), "BUY") > 0 ? "buy" : "sell");
            cmd += "," + DoubleToString(OrderGetDouble(ORDER_VOLUME_CURRENT), 2);
            cmd += "," + DoubleToString(OrderGetDouble(ORDER_PRICE_OPEN), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
            cmd += "," + DoubleToString(OrderGetDouble(ORDER_SL), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
            cmd += "," + DoubleToString(OrderGetDouble(ORDER_TP), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
         }
      }
      return cmd;
   }
   return cmd_all_pending_orders + ",0";
}

// GF
string checkAllPositions()
{
   int count = PositionsTotal();
   if (count > 0)
   {
      string cmd = cmd_all_open_positions + "," + IntegerToString(count);
      for(int i = 0; i < count; ++i)
      {
         if (PositionSelectByTicket(PositionGetTicket(i)))
         {
            cmd += "," + PositionGetString(POSITION_SYMBOL);
            cmd += "," + IntegerToString(PositionGetInteger(POSITION_TICKET));
            cmd += "," + TimeToString(datetime(PositionGetInteger(POSITION_TIME)), TIME_DATE|TIME_SECONDS);
            cmd += "," + (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? "buy" : "sell");
            cmd += "," + DoubleToString(PositionGetDouble(POSITION_VOLUME), 2);
            cmd += "," + DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
            cmd += "," + DoubleToString(PositionGetDouble(POSITION_SL), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
            cmd += "," + DoubleToString(PositionGetDouble(POSITION_TP), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
         }
      }
      return cmd;
   }
   return cmd_all_open_positions + ",0";
}

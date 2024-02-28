//+------------------------------------------------------------------+
//|                                                IBoxIndicator.mqh |
//|                                                   Pavel Chigirev |
//|                                        https://pavelchigirev.com |
//+------------------------------------------------------------------+
#property copyright "Pavel Chigirev"
#property link      "https://pavelchigirev.com"

#include "..\\Generic\\HashMap.mqh"
#include "Commons.mqh"

class IBoxIndicator
{
protected:
   int _handle;
   bool _isDeleted;
   
public:
   IBoxIndicator()
   {
      _isDeleted = false;
   }

   int GetHandle() { return _handle; }

   void virtual InitHandle() = 0;
   
   bool virtual ParseNewParams(string& params[]) = 0;
   
   void ApplyNewParams(string globalFlag, bool& clearBuffers)
   {
      double flag = GlobalVariableGet(globalFlag);
      if (flag <= 0)
         return;
      
      // New params are available   
      GlobalVariableSet(globalFlag, -1.0);
      Print("Ind------------------->");
   
      clearBuffers = false;
      string params[];
      IBoxIndicator::GetParams(globalFlag, params);
   
      string cmd = params[0]; 
      if (cmd == "del")
      {
         IndicatorRelease(_handle);
         _handle = INVALID_HANDLE;
         Print(globalFlag + "-------------------> Removed");
         _isDeleted = true;
         clearBuffers = true;
         return;
      }
      else if (cmd == "ch") 
      {
         if (ParseNewParams(params))
         {
            InitHandle();
            return;
         }
         else
         {
            // Print warning - incorrect params count
            Print(globalFlag + "------------------->");
         }
      }
   }   
   
   static void GetParams(string globalFlag, string& params[])
   {
      int total = GlobalVariablesTotal();
      for (int i = 0; i < total; i++)
      {
         string name = GlobalVariableName(i);
         if (StringFind(name, globalFlag + ">") == 0)
         {
            Print(globalFlag + "-------------------> Received: " + name);
            GlobalVariableDel(name);
   
            string parts[];
            StringSplit(name, '>', parts);
            if (ArraySize(parts) == 2)
            {
               StringSplit(parts[1], ',', params);
            }
            else
            {
               // Print warning
               Print(globalFlag + "------------------->");
            }
            
            return;
         }
      }
   }
   
   bool IsDeleted() { return _isDeleted; }
};

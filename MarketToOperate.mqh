//+------------------------------------------------------------------+
//|                                              MarketToOperate.mqh |
//|                                                          robocop |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "robocop"
#property link      "https://www.mql5.com"
#property strict
#include <constantes.mqh>
//Allowed Slippage
static double Slippage=3;
//We declare a function CloseOpenOrders of type int and we want to return
//the number of orders that are closed



bool TimeToOperate (int openhour = 1, int closehour = 24)
   {  bool RC_Dayoftheweek[7] = {false,true,true,true,true,true,false};
      if (VERBOSE) Print ("Day of the week ",RC_Dayoftheweek[DayOfWeek()]," Day ",DayOfWeek());
      if (VERBOSE) Print ("Open hour ",openhour," Close Hour ",closehour," Hour ",Hour());
      if (RC_Dayoftheweek[DayOfWeek()])
         if (closehour > Hour() && Hour() > openhour)
            {
            return (true);
            }
      return (false);
    }
      



int RC_CloseOpenOrders(int EA1_MAGICNUMBER = 10000)
   {
      int TotalClose=0;  //We want to count how many orders have been closed
//Normalization of the slippage
      if(Digits==3 || Digits==5)
      {
         Slippage=Slippage*10;
      }
//We scan all the orders backwards, this is required as if we start from the first we will have problems with the counters and the loop
      for( int i=OrdersTotal()-1;i>=0;i-- ) 
      {
//We select the order of index i selecting by position and from the pool of market/pending trades
//If the selection is successful we try to close it
         if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) && OrderMagicNumber()==EA1_MAGICNUMBER)
         {
//We define the close price, which depends on the type of order
//We retrieve the price for the instrument of the order using MarketInfo(OrderSymbol(),MODE_BID) or MODE_ASK
//And we normalize the price found
            double ClosePrice = 0;
            RefreshRates();
            if(OrderType()==OP_BUY) ClosePrice=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),Digits);
            if(OrderType()==OP_SELL) ClosePrice=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),Digits);
//If the order is closed correcly we increment the counter of closed orders
//If the order fails to be closed we print the error
            if(OrderClose(OrderTicket(),OrderLots(),ClosePrice,Slippage,CLR_NONE))
            {
               TotalClose++;
            }
            else
            {
               Print("Order failed to close with error - ",GetLastError());
            }
         }
//If the OrderSelect() fails we return the cause
         else
         {
            Print("Failed to select the order - ",GetLastError());
         }  
//We can have a delay if the execution is too fast, Sleep will wait x milliseconds before proceed with the code
         Sleep(300);
      }
//If the loop finishes it means there were no more open orders for that pair
   return(TotalClose);
}

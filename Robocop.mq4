///+------------------------------------------------------------------+
//|                                                  |
//|                    |
//|                                                                  |
//+------------------------------------------------------------------+
#include <constantes.mqh>
#include <stoploss.mqh>
#include <OpenMethods.mqh>
#include <MarketToOperate.mqh>
#property copyright   "robocop"
#property link        ""


  
input int MaxNumofParallelOrders =4; //Numb of parallel Orders
//Points
input double TakeProfit       = 100; 
input double TrailingStop     = 100; 
input double PointstoBE       = 150; //PointstoBE are calculated from OpenPrice()
input double InitialStopLoss  = 150; 
input int    EntryMethod      = 3;
input int    CheckStopLoss    = 60;  //timer to check stop loss in secs 
input int    OpenHour         = 0; //Hour to start trading 0:24
input int    CloseHour        = 24; //Hour to stop trading 0:24
 //risk, lot size
input double Lots             = 0.1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MinStopLevel;
double StopLoss;
extern int  EA1_MAGICNUMBER=10000;

void OnDeinit(const int reason)
{
 EventKillTimer();
}
void OnInit()
   { 
   
   StopLoss = InitialStopLoss; //StopLoss to be used in the EA
   double lote = LotCalculation(100);
//---
// initial data checks
// it is important to make sure that the expert works with a normal
// chart and the user did not make any mistakes setting external 
// variables (Lots, StopLoss, TakeProfit, 
// TrailingStop) in our casewe check chart of less than 100 bars
// and that TrailingStop is bigger than the minimum set by the system
//---
   EventSetTimer(CheckStopLoss);
   
   if(Bars<100)
     {
      Print("bars less than 100");
      return;
     }
   MinStopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD);
  
   Print ("Minim Stop Level = ",MinStopLevel);
   if (TrailingStop < MinStopLevel)
       StopLoss = MinStopLevel;
      

Print ("initiated");

   }
//TODO remove pending orders from checking breakeven and trailingStop



//Funtion to update existing orders   
void UpdateOpenOrders()
{

int cnt;
int total=OrdersTotal();  //open and pending orders 
if (VERBOSE) Print ("updating orders");
//Loop on Open and pending orders 
   for(cnt=0;cnt<total;cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
                  //Check if the order has passed the breakevent and stoploss needs to be updated, can be inlcuded in update trailing stop order
                  //if (PassBreakeven(EA1_MAGICNUMBER,PointstoBE))
//Adjust the trailing stop loss
         AdjustStopLoss(EA1_MAGICNUMBER,PointstoBE,StopLoss,VERBOSE);        
     }
}

//function to know if this is the first tick of a new bar
bool isNewBar(void)
   {
   static datetime Time0;    //Static==variable that persists out of the function time, inside function scope
   bool new_bar_int = false;
   
   if (Time0 != Time[0])
        new_bar_int=true;
   Time0 = Time[0];
   return (new_bar_int);
   }
   
void OnTimer()
{
if (VERBOSE) Print ("Total open orders",OrdersTotal());
//update orders
if (OrdersTotal() > 0)
      {
       if (TakeProfit == 0) UpdateOpenOrders();
       Print ("Total open orders",OrdersTotal());
       }
} 
 
 
void OnTick(void)
  {
   static int heiken_enable;
   int ticket,total,newbar,openposition;
   int HeikenAshi_shift = 1 ;

   total =OrdersTotal();
   newbar = isNewBar();
   
//we only check to set new orders inthe first tick of a new bar
   if (newbar)
    {
//update already open orders     
        if ((total>0) && (TakeProfit == 0)) UpdateOpenOrders();
//check if it is time to operate
//      if (TimeToOperate(OpenHour,CloseHour))
//      { 
        if(total<MaxNumofParallelOrders)  //Check num of open orders is < Max num of parallel orders
        {
//check if heiken can be reseted for use in semafor+vigilante+heiken
         heiken_enable = HeikenAshiHistogram_check(heiken_enable); 
         if (VERBOSE)
            if (heiken_enable == RC_HEIKEN_OPEN) Print ("Heiken allows trade: ",heiken_enable);
            else Print ("Heiken is already used and should be reset, result: ",heiken_enable);
         //--- 
         if(AccountFreeMargin()<(1000*Lots))
            {
            Print("We have no money. Free Margin = ",AccountFreeMargin());
            return;
            }
//Check if new orders can be opened
          if (heiken_enable==RC_HEIKEN_OPEN) openposition = OpenPositions (EntryMethod);
          else openposition = RC_NO_OP;
         //return RC_NO_OP   == no operation
         //return RC_BUY     == buy
         //return RC_SELL    == sell
          switch (openposition)
           {
            case RC_BUY: //buy
             {
               if (TakeProfit == 0) ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-StopLoss*Point,0,"Heiken Ashi EA",EA1_MAGICNUMBER,0,Green);
               else ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-StopLoss*Point,Ask+TakeProfit*Point,"Heiken Ashi EA",EA1_MAGICNUMBER,0,Green);
               if(ticket>0)
               {
                  //if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                     //Print("BUY order opened : ",OrderOpenPrice());
                  heiken_enable = RC_HEIKEN_BOUGHT;  //block heiken until bars are below of the line
               }
               else
                  Print("Error opening BUY order : ",GetLastError());
               return;
            }
           case RC_SELL:  //sell
            {  if (TakeProfit == 0) ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+StopLoss*Point,0,"Heiken Ashi EA",EA1_MAGICNUMBER,0,Red);
               else ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+StopLoss*Point,Bid-TakeProfit*Point,"Heiken Ashi EA",EA1_MAGICNUMBER,0,Red);
               if(ticket>0)
               {
                 // if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                    // Print("SELL order opened : ",OrderOpenPrice());
                  heiken_enable = RC_HEIKEN_SOLD; //block heiken until bars are below of the line
               }
               else
                  Print("Error opening SELL order : ",GetLastError());
               return;
            }  
            default :
               return;
          }       
      }
    }
  }
 
 double LotCalculation (int risk)
 {
 double priceperpoint;
 priceperpoint = SymbolInfoDouble(Symbol(),SYMBOL_POINT);
 Print ("Price per Point: ",priceperpoint);
 return (priceperpoint);
 }
//+------------------------------------------------------------------+


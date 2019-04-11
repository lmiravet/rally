//+------------------------------------------------------------------+
//|                                                       stoploss   |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property library



void AdjustStopLoss(double EAMagicNumber,double WhenToTrail = 0,double StopLoss_int = 0, bool Verbose = false)
{

  double newstoploss;
  if((OrderMagicNumber()==EAMagicNumber) && (OrderSymbol()==Symbol()))
   {
//buy order section
      
     if(OrderType()==OP_BUY)
     {
     newstoploss=NormalizeDouble((Bid-(Point*StopLoss_int)),Digits);

     if (Verbose) Print ("Order Type Buy :",OrderType(),"OpenPrice :", OrderOpenPrice()," Bid: ",Bid, "WhentoTrail: ",WhenToTrail*Point, "OrderStopLoss: ",OrderStopLoss(), "Trail Amount: ",Point*StopLoss_int);

//check that trailingstop should be increassed     
        if((Bid-OrderOpenPrice()>WhenToTrail*Point) && (OrderStopLoss()<newstoploss))
               {
                  if (Verbose) Print ("Change sell order:",OrderTicket(),"Past StopLoss",OrderStopLoss(),"New StopLoss",newstoploss);
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),newstoploss,OrderTakeProfit(),0,CLR_NONE))
                       Print("OrderModify_buy error ",GetLastError());
               }
      }                     
//sell order section
      else if(OrderType()==OP_SELL)
//check that trailingstop should be decreassed 
      {
      newstoploss=NormalizeDouble(Ask+(StopLoss_int*Point),Digits);

      if (Verbose)  Print ("Change Order Type Sell:",OrderType(),"OpenPrice :", OrderOpenPrice()," Ask: ",Ask," StopLoss: ",OrderStopLoss(), "TrailAmounbt: ", StopLoss_int*Point, "WhentoTrail: ",WhenToTrail*Point);
 //        if (Verbose) Print ("Order Type Sell: should be >0: ",(OrderOpenPrice()-Ask )- (WhenToTrail*Point),"Should be >0: ",OrderStopLoss()-(Ask+StopLoss*Point));

      if(((OrderOpenPrice()-Ask > WhenToTrail*Point) && ((OrderStopLoss()>newstoploss))))
          {
          if (Verbose) Print ("Change sell order:",OrderTicket(),"Past StopLoss",OrderStopLoss(),"New StopLoss",newstoploss);
          if (!OrderModify(OrderTicket(),OrderOpenPrice(),newstoploss,OrderTakeProfit(),0,CLR_NONE))
              Print("OrderModify_sell error ",GetLastError());
          }  
     }        
   }

}
bool PassBreakeven(double EAMagicNumber,double WhenToMoveToBE = 0)
{
   if((OrderMagicNumber()== EAMagicNumber)&&(OrderSymbol()==Symbol()))
   {
//buy order section   
      if(OrderType()==OP_BUY)   
         if((Bid-OrderOpenPrice()>WhenToMoveToBE*Point) && (OrderOpenPrice()>OrderStopLoss()))
            return (true);
         else
            return (false);     
//sell order section
       if(OrderType()==OP_SELL)
          if((OrderOpenPrice()-Ask>WhenToMoveToBE*Point) && (OrderOpenPrice()<OrderStopLoss()))   
            return (true);
          else     
            return (false);
     }
return (false);
}
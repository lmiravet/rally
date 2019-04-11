//+------------------------------------------------------------------+
//|                                                  OpenMethods.mqh |
//|                                                          robocop |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "robocop"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
//--- to simplify the coding and speed up access data are put into internal variables
#include <constantes.mqh>
//#define HEIKEN 1
//#define ELVIGILANTE 2
//#define NO_OP 0
//#define BUY   1
//#define SELL  2

int ElSemaforo ()
{  int resultado=RC_NO_OP;
   double greenbar = iCustom(Symbol(), 0, "Semaforo", 0, 1);
   double yellowbar = iCustom(Symbol(), 0, "Semaforo", 2, 1);
   double redbar = iCustom(Symbol(), 0, "Semaforo", 1, 1);
   if (VERBOSE) Print ("Green bar ",greenbar," Yellow bar: ",yellowbar, "Red bar: ",redbar);
   if (greenbar ==1)
      {
      if (VERBOSE) Print ("Semaforo BUY");
      resultado = RC_BUY;
      }
   else if (redbar == 1)
      {
      if (VERBOSE) Print ("Semaforo SELL");
      resultado = RC_SELL;
      }
   else
      {
      if (VERBOSE) Print ("Semaforo NO OP");
      resultado = RC_NO_OP;
      }
   if (VERBOSE) Print ("Value to return",resultado);
   return(resultado);
}

bool ElVigilante()
{  bool resultado=false;
   double Green_line = iCustom(Symbol(), 0, "El vigilante", 2, 1);
   double Grey_line = iCustom(Symbol(), 0, "El vigilante", 0, 1);
   double Red_line = iCustom(Symbol(), 0, "El vigilante", 1, 1);
   if (VERBOSE) Print ("El Vigilante Green Line ",Green_line," Grey line: ",Grey_line, "red Line: ",Red_line);
   if (Green_line > Grey_line)
   {
    resultado=true;
    if (VERBOSE) Print ("Allowed by EL Vigilante");
   }
   else
   {
    resultado=false;
    if (VERBOSE) Print ("blocked by El Vigilante");
   }
   return(resultado);
}

int HeikenAshiHistogram_check(int heikenenable = RC_HEIKEN_OPEN)
 {
  int valuetoreturn=RC_HEIKEN_OPEN;
  if (heikenenable == RC_HEIKEN_OPEN) valuetoreturn = RC_HEIKEN_OPEN;
  else
    {
      double HeikenAshi_line = iCustom(Symbol(), 0, "HeikenAshiHistogram", 2, 1);
      double HeikenAshi_neg = iCustom(Symbol(), 0, "HeikenAshiHistogram", 1, 1);
      double HeikenAshi_pos = iCustom(Symbol(), 0, "HeikenAshiHistogram", 0, 1);
      if (heikenenable == RC_HEIKEN_SOLD)
         {
            if (HeikenAshi_neg < HeikenAshi_line) 
                 valuetoreturn = RC_HEIKEN_OPEN;
            else 
                 valuetoreturn = RC_HEIKEN_SOLD;
         }
       else if (heikenenable == RC_HEIKEN_BOUGHT)
       {
            if (HeikenAshi_pos < HeikenAshi_line) 
               valuetoreturn = RC_HEIKEN_OPEN;
            else
               valuetoreturn = RC_HEIKEN_BOUGHT;
       }
   }
   if (VERBOSE) Print ("Hieken Check, already_in new alue: ",valuetoreturn);
   return (valuetoreturn);
}


int HeikenAshiHistogram(int ModeOfOperation =RC_HEIKEN_USUAL)
//return RC_NO_OP== no operation
//return RC_BUY== buy
//return RC_SELL== sell

{
   int HeikenAshi_shift = 1 ;

//load values from HeikenAshi Indicator

   double HeikenAshi_line = iCustom(Symbol(), 0, "HeikenAshiHistogram", 2, HeikenAshi_shift);
   double HeikenAshi_neg = iCustom(Symbol(), 0, "HeikenAshiHistogram", 1, HeikenAshi_shift);
   double HeikenAshi_pos = iCustom(Symbol(), 0, "HeikenAshiHistogram", 0, HeikenAshi_shift);
         
   double HeikenAshi_line_prev = iCustom(Symbol(), 0, "HeikenAshiHistogram", 2, HeikenAshi_shift+1);
   double HeikenAshi_neg_prev = iCustom(Symbol(), 0, "HeikenAshiHistogram", 1, HeikenAshi_shift+1);
   double HeikenAshi_pos_prev = iCustom(Symbol(), 0, "HeikenAshiHistogram", 0, HeikenAshi_shift+1);
 
   switch (ModeOfOperation)
    {
    case RC_HEIKEN_USUAL: //ModeOfOperation Heiken Ashi Histogram method
     {
//--- check for long position (BUY) possibility        
      if ( HeikenAshi_pos > HeikenAshi_line && HeikenAshi_pos_prev <= HeikenAshi_line_prev )
        {
         return (RC_BUY);
        }          
//--- check for short position (SELL) possibility
      else if( HeikenAshi_neg > HeikenAshi_line && HeikenAshi_neg_prev <= HeikenAshi_line_prev )
         {
            return (RC_SELL);
         }
//no position to open
      else
         return (RC_NO_OP);
     }
    case RC_HEIKEN_WITH_ENABLER:  //ModeOfOperation Only checking that last bar was ok, not checking for crossing over
     {
//--- check for long position (BUY) possibility        
         if (VERBOSE) Print ("Heiken Green bar: ",HeikenAshi_pos," Red Bar: ",HeikenAshi_neg," Line: ",HeikenAshi_line); 
         if ( HeikenAshi_pos > HeikenAshi_line )
             return (RC_BUY);          
//--- check for short position (SELL) possibility
         else if( HeikenAshi_neg > HeikenAshi_line)
            return (RC_SELL);
//no position to open
        else
            return (RC_NO_OP);
     }
     
    default:
      return (RC_NO_OP);
    }
 }
 
 
int OpenPositions (int method)

{
bool resultelvigilante=false;
int resultheiken,resultelsemaforo;
   
   switch (method)
   {
   case RC_HEIKEN :     //1==HeinkenAshiHistogram
       return (HeikenAshiHistogram(RC_HEIKEN_USUAL));
   case RC_ELVIGILANTE: //EL vigilante+HeikenAshiHistogram
      {
      resultelvigilante = ElVigilante();
      if (VERBOSE) Print ("Resultado El Vigilante: ",resultelvigilante);
      if (resultelvigilante) return (HeikenAshiHistogram(RC_ELVIGILANTE));
      else return (RC_NO_OP);
      }
   case RC_ALL :
      {
        resultelvigilante = ElVigilante();
        resultelsemaforo = ElSemaforo();
        resultheiken = HeikenAshiHistogram(RC_HEIKEN_WITH_ENABLER);
        if (VERBOSE) Print ("Resultado El Vigilante: ",resultelvigilante," El Semaforo: ",resultelsemaforo, " Heiken: ",resultheiken);
        if (resultelvigilante && (resultelsemaforo == RC_BUY) && resultheiken == RC_BUY)
           return (RC_BUY);   
        else if (resultelvigilante && resultelsemaforo == RC_SELL && resultheiken == RC_SELL)
           return (RC_SELL);      
        else
           return (RC_NO_OP);
       }     
   default:
       return (RC_NO_OP);
   }
}         
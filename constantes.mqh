//+------------------------------------------------------------------+
//|                                                   constantes.mqh |
//|                                                          robocop |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "robocop"
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define RC_NO_OP              0
#define RC_BUY                1
#define RC_SELL               2
#define RC_HEIKEN             1  //RoboCop will use Heiken Ashi Histogram for entering positions (only crossing)
#define RC_ELVIGILANTE        2  //RoboCop will use El Vigilante + Heiken Ashi Histogram for entering positions
#define RC_ALL                3  //RoboCop will use El Semaforo +El Vigilante + Heiken Ashi Histogram for entering positions

#define RC_HEIKEN_USUAL       1  //Constant used to call Heiken Ashi Histogram method in its usual way
#define RC_HEIKEN_WITH_ENABLER 2  //Heiken Ashi Histogram will be called as part of a entry method usage with an enabler (ie "Semaforo" or "el Vigilante")
#define RC_HEIKEN_CHECK       3  //Check if Heiken Ashi Histogram has already been used when part of an entry method usage with an enabler (ie "Semaforo" or "el Vigilante")
#define RC_HEIKEN_OPEN        0  
#define RC_HEIKEN_BOUGHT      1
#define RC_HEIKEN_SOLD        2
#define VERBOSE               true
//#define RC_TRAILING_STOP_MODE          true
//+------------------------------------------------------------------+
//|                                                      xtest01.mq5 |
//|                                   Copyright 2019, TSutomu Sakata |
//|                                  https://fuzzytrade.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"

int c,bar1,bar2;
datetime date1,date2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   c=0;
   bar1=0;
   bar2=0;
   date1=TimeCurrent();
   date2=TimeCurrent();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   date2=TimeCurrent();
   if(bar2==0)
     {
      bar1=1;
      bar2=bar1;
     }
     
   else if(bar2 !=0)
      {
      bar1 =1+Bars(_Symbol,_Period,date1,date2);
      if(bar1-bar2>0) c=1;
      }
    if(c !=1)return;
      
         printf(string(bar2));
         printf(string(bar1));
        
         bar2=bar1;
         c=0;
         if(bar2==10){bar1=1;bar2=1;date1=TimeCurrent();}
      
   
  }

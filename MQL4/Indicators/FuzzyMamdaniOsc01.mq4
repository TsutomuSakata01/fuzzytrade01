//+------------------------------------------------------------------+
//|                                            FuzzyMamdaniOsc01.mq4 |
//|                                    Copyright 2019,Tsutomu Sakata |
//|                                  https://fuzzytrade.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"
#property strict
#property indicator_separate_window
#property indicator_buffers    1
#property indicator_label1  "FuzzyMamdaniOsc01"
#property indicator_color1  Red

#include <MyFuzzy\Mamdani\FuzzyMamdani01.mqh>
input string  p1="-- parameters: -- ";
//common
input int visual=100;// Visual Period

input int rvi_period=10;
input int rsi_period=10;

double Buffer[];

double cBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  string signalName="FuzzyMamdaniOsc01";
  
   IndicatorBuffers(2);
   
   SetIndexBuffer(0,Buffer);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexLabel(0,signalName);

   SetIndexBuffer(1,cBuffer);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   ObjectsDeleteAll();
   return(0);
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
//---
   ArraySetAsSeries(Buffer,true);
   ArraySetAsSeries(cBuffer,true);
   ArraySetAsSeries(open,true);
   
   CMamdani ma;
   double a,b,c;
   int i;
//---  
      if(prev_calculated==0)
     {
     
      ArrayResize(Buffer, visual,visual);
      ArrayResize(cBuffer,visual,visual);
      
      //ArrayResize(Ac,visual,visual);
      
      ArrayInitialize(Buffer,EMPTY_VALUE);
      ArrayInitialize(cBuffer,EMPTY_VALUE);

     for(i=0;i<visual;i++)
        {
         a = iRVI(NULL,0,rvi_period,PRICE_OPEN,i);
         b = iRSI(NULL,0,rsi_period,PRICE_OPEN,i);
         c=  iAC(NULL,0,i);
         
         cBuffer[i]=ma.Mamdani(a,b,c);
         }
         ArrayCopy(Buffer,cBuffer,0,0,visual);
      }
//---

   int limit=rates_total-prev_calculated;

   if(limit==1)
     {
      a = iRVI(NULL,0,rvi_period,PRICE_OPEN,0);
      b = iRSI(NULL,0,rsi_period,PRICE_OPEN,0);
      c = iAC(NULL,0,0);
      
      cBuffer[0]=ma.Mamdani(a,b,c);
      
      ArrayCopy(Buffer,cBuffer,0,0,1);
      ArrayCopy(Buffer,cBuffer,1,0,visual-1);
       
     }      
      
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

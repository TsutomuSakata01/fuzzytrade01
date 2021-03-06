//+------------------------------------------------------------------+
//|                                         　  FuzzyMamdaniOsc01.mq5 |
//|                                   Copyright 2019,Tsutomu Sakata  |
//|                                   https://fuzzytrade.blogspot.com|         
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"
#property indicator_separate_window
#property indicator_buffers 5 
#property indicator_plots 1
//--- plot Result
#property indicator_label1  "FuzzyMamdaniOsc01"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#include <MyFuzzy\Mamdani\FuzzyMamdani01.mqh>
input string  p1="-- parameters: -- ";

//common
input int visual=100;// Visual Period

input int rvi_period=10;
input int rsi_period=10;
//
int rvi;
double Rvi[];

int rsi;
double Rsi[];

int ac;
double Ac[];

double Buffer[];

double cBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   rvi=iCustom(NULL,0,"Examples\\RVI",rvi_period,PRICE_OPEN);
   if(rvi==INVALID_HANDLE)
     {
      Print("iRVI = "+"ERROR");
      return(INIT_FAILED);
     }
   rsi=iCustom(NULL,0,"Examples\\RSI",rsi_period,PRICE_OPEN);
   if(rsi==INVALID_HANDLE)
     {
      Print("iRSI = "+"ERROR");
      return(INIT_FAILED);
     }

   ac=iCustom(NULL,0,"Examples\\Accelerator",PRICE_OPEN);
   if(ac==INVALID_HANDLE)
     {
      Print("iAC = "+"ERROR");
      return(INIT_FAILED);
     }

   string signalName="FuzzyMamdaniosc01";
   SetIndexBuffer(0,Buffer,INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME,signalName);
   IndicatorSetInteger(INDICATOR_DIGITS,2);//指標値描画の精度。
   PlotIndexSetInteger(0,PLOT_SHIFT,0);//プロット番号描画インジケータラインのシフト位置の指定
   PlotIndexSetString(0,PLOT_LABEL,signalName);//プロット番号描画インジケータラインの名前の指定
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);//プロットでの値が空のときの値の指定

   SetIndexBuffer(1,cBuffer,INDICATOR_CALCULATIONS);

   SetIndexBuffer(2,Rvi,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,Rsi,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,Ac,INDICATOR_CALCULATIONS);

   ArraySetAsSeries(Buffer,true);
   ArraySetAsSeries(cBuffer,true);

   ArraySetAsSeries(Rvi,true);
   ArraySetAsSeries(Rsi,true);
   ArraySetAsSeries(Ac,true);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   IndicatorRelease(rvi);
   IndicatorRelease(rsi);
   IndicatorRelease(ac);

   ChartRedraw(ChartID());
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-visual);

   CMamdani ma;
   double a,b,c;
   int i;
//---
   if(prev_calculated==0)
     {
      ArrayResize(Buffer,visual,visual);
      ArrayResize(cBuffer,visual,visual);

      ArrayResize(Rvi,visual,visual);
      ArrayResize(Rsi,visual,visual);
      ArrayResize(Ac,visual,visual);

      ArrayInitialize(Buffer, 0.0);
      ArrayInitialize(cBuffer,0.0);

      ArrayInitialize(Rvi,0.0);
      ArrayInitialize(Rsi,0.0);
      ArrayInitialize(Ac, 0.0);

      if(CopyBuffer(rvi,0,0,visual,Rvi)<0) Print("CopyBuffer(rvi) =  ERROR");

      if(CopyBuffer(rsi,0,0,visual,Rsi)<0) Print("CopyBuffer(rsi) =  ERROR");

      if(CopyBuffer(ac,0,0,visual,Ac)<0) Print("CopyBuffer(ac) =  ERROR");

      for(i=0;i<visual;i++)
        {
         a = Rvi[i];
         b =Rsi[i];
         c =Ac[i];

         cBuffer[i]= ma.Mamdani(a,b,c);
        }
      ArrayCopy(Buffer,cBuffer,0,0,visual);
     }

//---
   int limit=rates_total-prev_calculated;

   if(limit==1)
     {
      CopyBuffer(rvi,0,0,1,Rvi);
      CopyBuffer(rsi,0,0,1,Rsi);
      CopyBuffer(ac,0,0,1,Ac);

      a = Rvi[0];
      b = Rsi[0];
      c = Ac[0];

      cBuffer[0]=ma.Mamdani(a,b,c);

      ArrayCopy(Buffer,cBuffer,0,0,1);
      ArrayCopy(Buffer,cBuffer,1,0,visual-1);
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+

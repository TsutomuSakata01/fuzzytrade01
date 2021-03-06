//+------------------------------------------------------------------+
//|                                                FuzzyRviOsc01.mq5 |
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
#property indicator_label1  "FuzzyRviOsc01"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#include <MyFuzzy\Optimize\Fuzzy3Rvi01.mqh>

input string  p1="-- parameters: -- ";

//common
input int visual=100;// Visual Period

input int rvi_period1=10;
input int rvi_period2=15;
input int rvi_period3=20;
//
int rvi1;
double Rvi1[];

int rvi2;
double Rvi2[];

int rvi3;
double Rvi3[];

double Buffer[];

double cBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- indicator buffers mapping
   rvi1=iCustom(NULL,0,"Examples\\RVI",rvi_period1,PRICE_OPEN);
   if(rvi1==INVALID_HANDLE)
     {
      Print("iRVI1 = "+"ERROR");
      return(INIT_FAILED);
     }
   rvi2=iCustom(NULL,0,"Examples\\RVI",rvi_period2,PRICE_OPEN);
   if(rvi2==INVALID_HANDLE)
     {
      Print("iRVI2 = "+"ERROR");
      return(INIT_FAILED);
     }

   rvi3=iCustom(NULL,0,"Examples\\RVI",rvi_period3,PRICE_OPEN);
   if(rvi3==INVALID_HANDLE)
     {
      Print("iRVI3 = "+"ERROR");
      return(INIT_FAILED);
     }

   string signalName="FuzzyRviosc01";
   SetIndexBuffer(0,Buffer,INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME,signalName);
   IndicatorSetInteger(INDICATOR_DIGITS,2);//指標値描画の精度。
   PlotIndexSetInteger(0,PLOT_SHIFT,0);//プロット番号描画インジケータラインのシフト位置の指定
   PlotIndexSetString(0,PLOT_LABEL,signalName);//プロット番号描画インジケータラインの名前の指定
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);//プロットでの値が空のときの値の指定

   SetIndexBuffer(1,cBuffer,INDICATOR_CALCULATIONS);

   SetIndexBuffer(2,Rvi1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,Rvi2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,Rvi3,INDICATOR_CALCULATIONS);

   ArraySetAsSeries(Buffer,true);
   ArraySetAsSeries(cBuffer,true);

   ArraySetAsSeries(Rvi1,true);
   ArraySetAsSeries(Rvi2,true);
   ArraySetAsSeries(Rvi3,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   IndicatorRelease(rvi1);
   IndicatorRelease(rvi2);
   IndicatorRelease(rvi3);

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

      ArrayResize(Rvi1,visual,visual);
      ArrayResize(Rvi2,visual,visual);
      ArrayResize(Rvi3,visual,visual);

      ArrayInitialize(Buffer, 0.0);
      ArrayInitialize(cBuffer,0.0);

      ArrayInitialize(Rvi1,0.0);
      ArrayInitialize(Rvi2,0.0);
      ArrayInitialize(Rvi3,0.0);

      if(CopyBuffer(rvi1,0,0,visual,Rvi1)<0) Print("CopyBuffer(rvi1) =  ERROR");

      if(CopyBuffer(rvi2,0,0,visual,Rvi2)<0) Print("CopyBuffer(rvi2) =  ERROR");

      if(CopyBuffer(rvi3,0,0,visual,Rvi3)<0) Print("CopyBuffer(rvi3) =  ERROR");

      for(i=0;i<visual;i++)
        {
         a = Rvi1[i];
         b = Rvi2[i];
         c = Rvi3[i];

         cBuffer[i]=ma.Mamdani(a,b,c);
        }
      ArrayCopy(Buffer,cBuffer,0,0,visual);
     }
//---
   int limit=rates_total-prev_calculated;

   if(limit==1)
     {
      CopyBuffer(rvi1,0,0,1,Rvi1);
      CopyBuffer(rvi2,0,0,1,Rvi2);
      CopyBuffer(rvi3,0,0,1,Rvi3);

      a = Rvi1[0];
      b = Rvi2[0];
      c = Rvi3[0];

      cBuffer[0]=ma.Mamdani(a,b,c);
      ArrayCopy(Buffer,cBuffer,0,0,1);
      ArrayCopy(Buffer,cBuffer,1,0,visual-1);
      
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+

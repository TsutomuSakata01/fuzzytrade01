//+------------------------------------------------------------------+
//|                                             FuzzySugenoOsc01.mq5 |
//|                                   Copyright 2019,Tsutomu Sakata  |
//|                                   https://fuzzytrade.blogspot.com|         
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"

#property indicator_separate_window
#property indicator_buffers 7 
#property indicator_plots 1
//--- plot Result
#property indicator_label1  "FuzzySugenoOsc01"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1  

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#include <MyFuzzy\Sugeno\FuzzySugeno01.mqh>

input string  p1="-- parameters: -- ";
//common
input int visual=100;// Visual Period

input int adx_period=10;
input int mom_period=2;
input int rsi_period=10;

int max_period;
//
int adx;
double ADX[];
double PDI[];
double MDI[];

int mom;
double MOM[];

int rsi;
double RSI[];

double Buffer[];

double cBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
 
//--- indicator buffers mapping
   adx = iADXWilder(NULL,0,adx_period); 
   if(adx == INVALID_HANDLE)
     {
      Print("ADXW = "+"ERROR");
      return(INIT_FAILED);
     }
  mom = iCustom(NULL,0,"Fuzzy\\MomW",mom_period,PRICE_CLOSE);
   if(mom == INVALID_HANDLE)
     {
      Print("Mom_W = "+"ERROR");
      return(INIT_FAILED);
     }     
   rsi = iCustom(NULL,0,"Examples\\RSI",rsi_period,PRICE_CLOSE);
   if(rsi == INVALID_HANDLE)
     {
      Print("iRSI = "+"ERROR");
      return(INIT_FAILED);
     }
       
   string signalName="FuzzySugenoOsc01";
   SetIndexBuffer(0,Buffer,INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME,signalName);
   IndicatorSetInteger(INDICATOR_DIGITS,2);//指標値描画の精度。
   PlotIndexSetInteger(0,PLOT_SHIFT,0);//プロット番号描画インジケータラインのシフト位置の指定
   PlotIndexSetString(0,PLOT_LABEL,signalName);//プロット番号描画インジケータラインの名前の指定
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);//プロットでの値が空のときの値の指定

   SetIndexBuffer(1,cBuffer, INDICATOR_CALCULATIONS);
   
   SetIndexBuffer(2,ADX,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,PDI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,MDI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,MOM,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,RSI,INDICATOR_CALCULATIONS);   

   ArraySetAsSeries(Buffer,true);
   ArraySetAsSeries(cBuffer,true);   
   
   ArraySetAsSeries(ADX,true);
   ArraySetAsSeries(PDI,true);
   ArraySetAsSeries(MDI,true);   
   ArraySetAsSeries(MOM,true);
   ArraySetAsSeries(RSI,true);
   
   max_period=MathMax(adx_period,mom_period);
   max_period=MathMax(max_period,rsi_period);   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   IndicatorRelease(adx);
   IndicatorRelease(mom);
   IndicatorRelease(rsi);
   
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

   CSugeno su;
   double a,b,c,d,e,f;
   int i;
//---
   if(prev_calculated==0)
     {
      ArrayResize(Buffer, visual,visual);
      ArrayResize(cBuffer,visual,visual);
      
      ArrayResize(ADX,visual,visual);
      ArrayResize(PDI,visual,visual);
      ArrayResize(MDI, visual,visual);
      ArrayResize(MOM,visual,visual);
      ArrayResize(RSI, visual,visual);      
      
      ArrayInitialize(Buffer, 0.0);
      ArrayInitialize(cBuffer,0.0);
      
      ArrayInitialize(ADX,0.0);
      ArrayInitialize(PDI,0.0);
      ArrayInitialize(MDI,0.0);
      ArrayInitialize(MOM,0.0);
      ArrayInitialize(RSI,0.0);
      
      if(CopyBuffer(adx,0,0,visual,ADX)<0) Print("CopyBuffer(ADX) =  ERROR");
         
      if(CopyBuffer(adx,1,0,visual,PDI)<0) Print("CopyBuffer(PDI) =  ERROR");
         
      if(CopyBuffer(adx,2,0,visual,MDI)<0) Print("CopyBuffer(MDI) =  ERROR");
         
      if(CopyBuffer(mom,0,0,visual,MOM)<0) Print("CopyBuffer(MOM) =  ERROR");
      
      if(CopyBuffer(rsi,0,0,visual,RSI)<0) Print("CopyBuffer(RSI) =  ERROR");
     
      for(i=0;i<visual-max_period;i++)
        {
         a =ADX[i];
         b =PDI[i];
         c =MDI[i];
         d =a*(b-c)/100;
         e =MOM[i];
         f =RSI[i];
         
         cBuffer[i]=su.Sugeno(d,e,f);        
        }        
        ArrayCopy(Buffer,cBuffer,0,0,visual);       
     }
//---
   int limit=rates_total-prev_calculated;

   if(limit==1)
     {     
      CopyBuffer(adx,0,0,visual,ADX);
         
      CopyBuffer(adx,1,0,visual,PDI);
         
      CopyBuffer(adx,2,0,visual,MDI);
         
      CopyBuffer(mom,0,0,visual,MOM);
      
      CopyBuffer(rsi,0,0,visual,RSI);
      
      a = ADX[0];
      b = PDI[0];
      c = MDI[0];
      d =a*(b-c)/100;
      e =MOM[0];
      f =RSI[0];
      
      cBuffer[0]=su.Sugeno(d,e,f);
      
      ArrayCopy(Buffer,cBuffer,0,0,1); 
      ArrayCopy(Buffer,cBuffer,1,0,visual-1); 
          
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+

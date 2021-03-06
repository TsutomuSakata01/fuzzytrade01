//+------------------------------------------------------------------+
//|                                                      xtest02.mq5 |
//|                                    Copyright 2019,Tsutomu Sakata |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2019,Tsutomu Sakata."
#property link        "https://fuzzytrade.blogspot.com"
#property version   "2.01"
#property description "xtest02"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Silver
#property indicator_width1  1
//#property indicator_minimum  1.3
//#property indicator_maximum  1.33 
//--- input parameters
input int t_Period=13; // Period
input int   visual=100;// Visual Period
//--- indicator buffers
double    IBuffer[];//ExtBearsBuffer[];
double    CBuffer[];//ExtTempBuffer[];
double    Buffer[];
//--- handle of EMA 
int       handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,IBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,Buffer,INDICATOR_CALCULATIONS);

   ArraySetAsSeries(IBuffer,true);
   ArraySetAsSeries(CBuffer,true);
   ArraySetAsSeries(Buffer,true);
//ArraySetAsSeries(Buffer,true);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- sets first bar from what index will be drawn
//PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,t_Period-1);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"xtest02("+(string)t_Period+")");
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//--- get MA handle
   handle=iMA(NULL,0,t_Period,0,MODE_SMA,PRICE_OPEN);
//--- initialization done
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   IndicatorRelease(handle);
   ChartRedraw(ChartID());
   return(0);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
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
/*
   ArraySetAsSeries(low,true);

   ArrayResize(CBuffer,visual,visual);
 */
//handle=iMA(NULL,0,t_Period,0,MODE_SMA,PRICE_CLOSE);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-100);

   if(prev_calculated==0)
     {
      ArrayResize(IBuffer,visual,visual);
      ArrayResize(CBuffer,visual,visual);
      ArrayResize(Buffer,visual,visual);

      ArrayInitialize(IBuffer,0.0);
      ArrayInitialize(CBuffer,0.0);

      CopyBuffer(handle,0,0,visual,IBuffer);
      ArrayCopy(CBuffer,IBuffer,0,0,visual);
      
       double d=CBuffer[0];
      printf("CBuffer[0]="+(string)d);
      d=CBuffer[1];
      printf("CBuffer[1]="+(string)d);
      d=CBuffer[2];
      printf("CBuffer[2]="+(string)d);
            
     }

   int limit;
   limit=rates_total-prev_calculated;
//ArrayInitialize(Buffer,0.0);
//int copied=CopyBuffer(handle,2,0,visual,Buffer);
   
   
   if(limit==1)
     {
     //IBuffer一つずれるので更新する
      int copied=CopyBuffer(handle,0,0,1,IBuffer);

      ArrayCopy(CBuffer,IBuffer,0,0,1);
      ArrayCopy(IBuffer,CBuffer,0,0,visual);
      
      //ArrayCopy(CBuffer,IBuffer,1,0,visual-1);
      
      //-------
      double c=IBuffer[0];
      printf("IBuffer[0]="+(string)c);
      c=IBuffer[1];
      printf("IBuffer[1]="+(string)c);
      c=IBuffer[2];
      printf("IBuffer[2]="+(string)c);
      printf((string)copied);
      //--------

     }

   return(rates_total);
  }
//+------------------------------------------------------------------+

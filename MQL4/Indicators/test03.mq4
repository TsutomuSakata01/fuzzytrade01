//+------------------------------------------------------------------+
//|                                                       test03.mq4 |
//|                                    Copyright 2018,Tsutomu Sakata |
//|                                    http://mql5fuzzy.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018,Tsutomu Sakata"
#property link      "http://mql5fuzzy.blogspot.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
input int mPeriod=200;
double mBuffer[];
void OnInit(void)
{
IndicatorBuffers(1);
IndicatorDigits(Digits);
SetIndexStyle(0,DRAW_LINE,STYLE_DOT);
SetIndexBuffer(0,mBuffer);
}
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
int limit=rates_total-prev_calculated;
//---
if(rates_total<=mPeriod)
return(0);
//---
if(prev_calculated>0)
limit++;
for(int i=0; i<limit; i++)
{
mBuffer[i]=iCustom(NULL,0,"Indicators\\NewFolder\\test01",mPeriod,0,i);
}
//
return(rates_total);
}
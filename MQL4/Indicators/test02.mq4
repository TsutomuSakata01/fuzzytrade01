//+------------------------------------------------------------------+
//|                                                       test02.mq4 |
//|                                    Copyright 2018,Tsutomu Sakata |
//|                                    http://mql5fuzzy.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018,Tsutomu Sakata"
#property link      "http://mql5fuzzy.blogspot.com"
#property version   "1.00"
#property copyright "Copyright 2015, T.S."
#property link "http://"
#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Silver
input int mPeriod=200;
double mBuffer[];
void OnInit(void)
{
IndicatorBuffers(1);
IndicatorDigits(Digits);
//--- drawing style
SetIndexBuffer(0,mBuffer);
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
int draw_begin=mPeriod-1;
SetIndexDrawBegin(0,draw_begin);
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
if(rates_total<mPeriod-1 || mPeriod<2) return(0);
ArraySetAsSeries(mBuffer,false);
ArraySetAsSeries(close,false);
if(prev_calculated==0)
ArrayInitialize(mBuffer,0);
int i,limit;
if(prev_calculated==0)
{
limit=mPeriod;
double firstValue=0;
for(i=0; i<limit; i++)
firstValue+=close[i];
firstValue/=mPeriod;
mBuffer[limit-1]=firstValue;
}
else
limit=prev_calculated-1;
//--- main loop
for(i=limit; i<rates_total && !IsStopped(); i++)
mBuffer[i]=mBuffer[i-1]+(close[i]-close[i-mPeriod])/mPeriod;
//---
return(rates_total);
}
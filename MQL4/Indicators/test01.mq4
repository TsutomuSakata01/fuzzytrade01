//+------------------------------------------------------------------+
//|                                                       test01.mq4 |
//|                                    Copyright 2019,Tsutomu Sakata |
//|                                  https://fuzzytrade.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"
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
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
SetIndexBuffer(0,mBuffer);//,INDICATOR_CALCULATIONS
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
mBuffer[i]=iMA(NULL,0,mPeriod,0,MODE_SMA,PRICE_CLOSE,i);
}
//---
return(rates_total);
}
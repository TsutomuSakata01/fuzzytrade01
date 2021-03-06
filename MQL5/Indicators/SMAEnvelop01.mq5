//+------------------------------------------------------------------+
//|                                                 SMAEnvelop01.mq5 |
//|                                   Copyright 2019, Tsutomu Sakata |
//|                                  https://fuzzytrade.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue
input int InpPeriodSMA=20;
input int InpMAShift=0;
input double InpMABand=0.5;
double ExtMIBuffer[];
double ExtMIBufferH[];
double ExtMIBufferL[];
//+--------------------------------------
//| Custom indicator initialization function
//+--------------------------------------
void OnInit()
{
//bool x=ArrayGetAsSeries(ExtMIBuffer);
//Print("before = ",x);
SetIndexBuffer(0,ExtMIBuffer,INDICATOR_DATA);
SetIndexBuffer(1,ExtMIBufferH,INDICATOR_DATA);
SetIndexBuffer(2,ExtMIBufferL,INDICATOR_DATA);
IndicatorSetInteger(INDICATOR_DIGITS,_Digits+4);
//各プロット番号描画インジケータラインの開始位置の指定
PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpPeriodSMA);
PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpPeriodSMA);
PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpPeriodSMA);
//各プロット番号描画インジケータラインのシフト位置の指定
PlotIndexSetInteger(0,PLOT_SHIFT,InpMAShift);
PlotIndexSetInteger(1,PLOT_SHIFT,InpMAShift);
PlotIndexSetInteger(2,PLOT_SHIFT,InpMAShift);
//各プロット番号描画インジケータラインの名前の指定
PlotIndexSetString(0,PLOT_LABEL,"SMA");
PlotIndexSetString(1,PLOT_LABEL,"Upper");
PlotIndexSetString(2,PLOT_LABEL,"Lower");
string short_name="MySMA";
//このインジケータの名前
IndicatorSetString(INDICATOR_SHORTNAME,
short_name+"("+string(InpPeriodSMA)+")");
//各プロットでの値が空のときの値の指定
PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//bool y=ArrayGetAsSeries(ExtMIBuffer);
//Print("after = ",y);
}
//-------------------------------------------------
void OnDeinit(const int reason)
{
//Comment("","");
}
//
//----------------------------------------------
//+---------------------------------------------
//| Custom indicator iteration function
//+---------------------------------------------
//int OnCalculate(const int rates_total,
// const int prev_calculated,
// const int begin,
// const double &price[]) {　 }　の説明
//
//OnCalculateには２つの型がある。
//新規にインディケータを作るときは、２つのうち１つを選択する。
//price[]はチャート足の寄付き値、終わり値、最高値、最安値がセットになっている。
//各値の指定はチャートにアタッチしてからプロパティのパラメータで適用価格として
//指定。
//beginパラメータはプライス配列の最初の番号。
//関数PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, empty_first_values)を使用し
//配列の始の番号をセット。
//下のPrint("begin1 = ",begin);場合では０。
//次の　{　 }　の中では
//rates_total　が　InpPeriodSMA-1+beginより大きくなるまで
//return(0);でもとにもどる事をくり返す。
//次にArrayInitialize(ExtMIBuffer ,0);では配列を初期化。
//次の関数はCalculateSimpleMA(rates_total,prev_calculated,begin,price);では
//３本の単純移動平均線を計算し、インディケータ配列に入力。
//return(rates_total);でint OnCalculate（）の始に戻る。
//------------------------------
int OnCalculate(const int rates_total,
const int prev_calculated,
const int begin,
const double &price[])
{
//---
//Print("begin = ",begin);
if(rates_total<InpPeriodSMA-1+begin)
return(0);
//---
if(prev_calculated==0)
{
ArrayInitialize(ExtMIBuffer,0);
ArrayInitialize(ExtMIBufferH,0);
ArrayInitialize(ExtMIBufferL,0);
}
//---
PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpPeriodSMA-1+begin);
PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpPeriodSMA-1+begin);
PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpPeriodSMA-1+begin);
CalculateSimpleMA(rates_total,prev_calculated,begin,price);
return(rates_total);
}
//
void CalculateSimpleMA(int rates_total,int prev_calculated,
int begin,const double &price[])
{
int i,limit;
//--- 指標の計算が始めてのときの計算。
//プロットの0～2番に0.0を入力。
if(prev_calculated==0)
{
limit=InpPeriodSMA+begin;
//--- set empty value for first limit bars
for(i=0;i<limit-1;i++)
{
ExtMIBuffer [i]=0.0;
ExtMIBufferH[i]=0.0;
ExtMIBufferL[i]=0.0;
}
//プロットの0～2番の
//単純移動平均と、
//inputしたInpMABand=0.2（％）の上下エンベロープを計算。
double firstValue=0;
for(i=begin;i<limit;i++) firstValue+=price[i];
firstValue/=InpPeriodSMA;
ExtMIBuffer[limit-1]=firstValue;
ExtMIBufferH[limit-1]=firstValue*(1+0.01*InpMABand);
ExtMIBufferL[limit-1]=firstValue*(1-0.01*InpMABand);
}
//--- 指標の計算が１回目以降のときの計算はここから。
else limit=prev_calculated-1;
//---ここで大切なのはsum1 +=price[i-j]の計算。ここを押えておく必要がある。
//iはrates_totalへ増えていき、i-jはiの位置から減っていく。
for(i=limit;i<rates_total && !IsStopped();i++) //
{
double sum1=0;
double sum2=0;
double sum3=0;
for(int j=0;j<InpPeriodSMA;j++) sum1+=price[i-j];
sum1=sum1/InpPeriodSMA;
ExtMIBuffer[i]=sum1;
sum2 =sum1+(0.01)*InpMABand*sum1;
sum3 =sum1-(0.01)*InpMABand*sum1;
ExtMIBufferH[i]=sum2;
ExtMIBufferL[i]=sum3;
}
//---
}

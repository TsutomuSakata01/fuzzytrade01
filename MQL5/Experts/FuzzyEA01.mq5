//+------------------------------------------------------------------+
//|                                                    FuzzyEA01.mq5 |
//|                                   Copyright 2019, TSutomu Sakata |
//|                                   https://fuzzytrade.blogspot.com|
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"

#include <Trade/Trade.mqh>
#include <MyFuzzy\Mamdani\FuzzyMamdani01.mqh>

input string  p1="-- parameters: -- ";
input int     Magic=1001;
input double  Lots=0.1;
//input int     Slipage=10;
input int     Stop=500;
input int     TakeProfit=500;
input string  p2="-- parameters: -- ";
input int     calculate=4;
input double  buylev = 0.07;
input double  selllev=-0.07;
input string  p3="-- parameters: -- ";
input int     rvi_period=10;
input int     rsi_period=10;

input int ww=4;

//
int rvi;
double Rvi[];

int rsi;
double Rsi[];

int ac;
double Ac[];

double Buffer[];

uint n1,bar1,bar2;
datetime date1,date2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
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
//---
   ArraySetAsSeries(Buffer,true);
//ArraySetAsSeries(cBuffer,true);

   ArraySetAsSeries(Rvi,true);
   ArraySetAsSeries(Rsi,true);
   ArraySetAsSeries(Ac,true);

//---
   n1=0;
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
   IndicatorRelease(rvi);
   IndicatorRelease(rsi);
   IndicatorRelease(ac);

   ChartRedraw(ChartID());
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int Week()
  {
   MqlDateTime mqt1;
   TimeCurrent(mqt1);
   return(mqt1.day_of_week);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   int w;
   w=Week();
   if(w ==ww) return;
//---  
   date2=TimeCurrent();
   if(bar2==0) {bar1=1;bar2=bar1;}
   else if(bar2!=0){bar1=1+Bars(_Symbol,_Period,date1,date2);if(bar1-bar2>0)n1=1;}
   if(n1 !=1)return;
   bar2=bar1;
   n1=0;
   if(bar2==10){bar1=1;bar2=1;date1=TimeCurrent();}
//--- 
//------------------------------
   MqlTick mqtick;
   if(!SymbolInfoTick(_Symbol,mqtick))
     {
      Print("the latest price error");
      return;
     }
//---
   ArrayResize(Buffer,calculate,calculate);

   ArrayResize(Rvi,calculate,calculate);
   ArrayResize(Rsi,calculate,calculate);
   ArrayResize(Ac,calculate,calculate);

   ArrayInitialize(Buffer,0.0);

   ArrayInitialize(Rvi,0.0);
   ArrayInitialize(Rsi,0.0);
   ArrayInitialize(Ac, 0.0);

   if(CopyBuffer(rvi,0,0,calculate,Rvi)<0) Print("CopyBuffer(rvi) =  ERROR");
   if(CopyBuffer(rsi,0,0,calculate,Rsi)<0) Print("CopyBuffer(rsi) =  ERROR");
   if(CopyBuffer(ac,0,0,calculate,  Ac)<0) Print("CopyBuffer(ac)  =  ERROR");

   for(int i=0;i<calculate;i++)
     {
      double a1 = Rvi[i];
      double b1 =Rsi[i];
      double c1 =Ac[i];
      CMamdani ma;
      Buffer[i]=ma.Mamdani(a1,b1,c1);
      //Comment(Buffer[1]);
     }
//---entry signal calculate     
   bool Buy_sig=false;
   bool Sell_sig=false;
   if(Buffer[2]<=buylev && Buffer[1]>buylev)  Buy_sig=true;
   if(Buffer[2]>=selllev && Buffer[1]<selllev)Sell_sig=true;
//---exite signal calculate 
   bool BuyClose_sig =false;
   bool SellClose_sig=false;
   if( Buffer[2]>Buffer[1] && Buffer[3]>=Buffer[2])  BuyClose_sig =true;
   if( Buffer[2]<Buffer[1] && Buffer[3]<=Buffer[2])  SellClose_sig=true; 
//---position signal
   bool Buy_pos =false;
   bool Sell_pos=false;
   if(PositionSelect(_Symbol)==true)
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_pos=true;
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_pos=true;
        }
     }
//------  
   if(Buy_sig)
     {
      if(Buy_pos)  return;

      double l=Lots;
      double p = NormalizeDouble(mqtick.ask,_Digits);
      double s = NormalizeDouble(mqtick.ask - Stop*_Point,_Digits);
      double t = NormalizeDouble(mqtick.ask + TakeProfit*_Point,_Digits);

      CTrade m_trade;
      m_trade.SetExpertMagicNumber(Magic);
      m_trade.PositionOpen(Symbol(),ORDER_TYPE_BUY,l,p,0,0,"");
     }

   if(Sell_sig)
     {
      if(Sell_pos) return;

      double l = Lots;
      double p = NormalizeDouble(mqtick.bid,_Digits);
      double s = NormalizeDouble(mqtick.bid + Stop*_Point,_Digits);
      double t = NormalizeDouble(mqtick.bid - TakeProfit*_Point,_Digits);

      CTrade m_trade;
      m_trade.SetExpertMagicNumber(Magic);
      m_trade.PositionOpen(Symbol(),ORDER_TYPE_SELL,l,p,0,0,"");

     }

   if(Sell_pos && SellClose_sig)
     {
      CTrade m_trade;
      m_trade.PositionClose(Symbol());
      return;
     }

   if(Buy_pos && BuyClose_sig)
     {
      CTrade m_trade;
      m_trade.PositionClose(Symbol());
      return;
     }
  }
//------------------------------------

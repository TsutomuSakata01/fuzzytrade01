//+------------------------------------------------------------------+
//|                                                   FuzzyEArvi.mq5 |
//|                                   Copyright 2019, TSutomu Sakata |
//|                                   https://fuzzytrade.blogspot.com|
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"

#include <Trade/Trade.mqh>
#include <MyFuzzy\Optimize\Fuzzy3Rvi01.mqh>

input string  p1="-- parameters1: -- ";
input int     Magic=1001;
input double  Lots=0.1;
//input int     Slipage=10;
input int     Stop=500;
input int     TakeProfit=1000;
input string  p2="--EURUSD(0.07,-0.07)--GBPUSD(0.06,-0.12)--";
input double  buylev = 0.15; 
input double  selllev=-0.01; 

input double  buycloselev = 0.0; 
input double  sellcloselev=-0.0; 

input string  p3="-- parameters3: -- ";
input int     calculate=4;
input int     rvi_period1=10;
input int     rvi_period2=15;
input int     rvi_period3=20;

input int ww1=0;

int rvi1;
double Rvi1[];

int rvi2;
double Rvi2[];

int rvi3;
double Rvi3[];

double Buffer[];

uint n1,bar1,bar2;
datetime date1,date2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   rvi1=iCustom(NULL,0,"Examples\\RVI",rvi_period1,PRICE_CLOSE);
   if(rvi1==INVALID_HANDLE)
     {
      Print("iRVI1 = "+"ERROR");
      return(INIT_FAILED);
     }
   rvi2=iCustom(NULL,0,"Examples\\RVI",rvi_period2,PRICE_CLOSE);
   if(rvi2==INVALID_HANDLE)
     {
      Print("iRVI2 = "+"ERROR");
      return(INIT_FAILED);
     }

   rvi3=iCustom(NULL,0,"Examples\\RVI",rvi_period3,PRICE_CLOSE);
   if(rvi3==INVALID_HANDLE)
     {
      Print("iRVI3 = "+"ERROR");
      return(INIT_FAILED);
     }
//---
   ArraySetAsSeries(Buffer,true);
//ArraySetAsSeries(cBuffer,true);

   ArraySetAsSeries(Rvi1,true);
   ArraySetAsSeries(Rvi2,true);
   ArraySetAsSeries(Rvi3,true);

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
   IndicatorRelease(rvi1);
   IndicatorRelease(rvi2);
   IndicatorRelease(rvi3);

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
   if(w ==ww1)  return;
//---  
   date2=TimeCurrent();
   if(bar2==0) {bar1=1;bar2=bar1;}
   else if(bar2!=0){bar1=1 +Bars(_Symbol,_Period,date1,date2);if(bar1-bar2>0)n1=1;}
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

   ArrayResize(Rvi1,calculate,calculate);
   ArrayResize(Rvi2,calculate,calculate);
   ArrayResize(Rvi3,calculate,calculate);

   ArrayInitialize(Buffer,0.0);

   ArrayInitialize(Rvi1,0.0);
   ArrayInitialize(Rvi2,0.0);
   ArrayInitialize(Rvi3,0.0);

   if(CopyBuffer(rvi1,0,0,calculate,Rvi1)<0) Print("CopyBuffer(rvi1) =  ERROR");
   if(CopyBuffer(rvi2,0,0,calculate,Rvi2)<0) Print("CopyBuffer(rvi2) =  ERROR");
   if(CopyBuffer(rvi3,0,0,calculate,Rvi3)<0) Print("CopyBuffer(rvi3) =  ERROR");

   for(int i=0;i<calculate;i++)
     {
      double a1 = Rvi1[i];
      double b1 = Rvi2[i];
      double c1 = Rvi3[i];
      
      CMamdani ma;
      Buffer[i]=ma.Mamdani(a1,b1,c1);
      Comment(Buffer[1]);
     }
     
//---entry signal calculate     
   bool Buy_sig=false;
   bool Sell_sig=false;
   /*
   if(Buffer[2]<=buylev && Buffer[1]>buylev)  Buy_sig=true;
   if(Buffer[2]>=selllev && Buffer[1]<selllev)Sell_sig=true;
   */
   if(Buffer[1]>buylev)  Buy_sig=true;
   if(Buffer[1]<selllev)Sell_sig=true;
   
//---exite signal calculate 
   bool BuyClose_sig =false;
   bool SellClose_sig=false;
   /*
   if( Buffer[2]>Buffer[1] && Buffer[3]>=Buffer[2])  BuyClose_sig =true;
   if( Buffer[2]<Buffer[1] && Buffer[3]<=Buffer[2])  SellClose_sig=true; 
   */
   if( Buffer[1]<buycloselev )  BuyClose_sig =true;
   if( Buffer[1]>sellcloselev)  SellClose_sig=true; 
   
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

//+------------------------------------------------------------------+
//|                                               FuzzyEAMamdani.mq4 |
//|                                    Copyright 2019,Tsutomu Sakata |
//|                                  https://fuzzytrade.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Tsutomu Sakata"
#property link      "http://mql5fuzzy.blogspot.com"
#property version   "2.01"
//---no.1*
#property strict
//#include <Trade/Trade.mqh>
#include <MyFuzzy\Mamdani\FuzzyMamdani01.mqh>
//---
input string  p1="-- parameters: -- ";
input int     Magic=1001;
input double  Lots=1.0;
input int     Slipage=20;
input int     Stop=500;
input int     TakeProfit=1000;
input string  p2="-- parameters: -- ";
input int     calculate=4;
input double  buylev = 0.03;
input double  selllev=-0.19;
input string  p3="-- parameters: -- ";
//---no.2*
input int rvi_period=10;
input int rsi_period=10;

input int ww=4;

double Buffer[];

uint n1,bar1,bar2;
datetime date1,date2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ArraySetAsSeries(Buffer,true);

   n1=0;
   bar1=0;
   bar2=0;
   date1=TimeCurrent();
   date2=TimeCurrent();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---no.3
/*
   IndicatorRelease(rvi);
   IndicatorRelease(rsi);
   IndicatorRelease(ac);
   ChartRedraw(ChartID());
*/
//---   
   Comment("");
   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
//---no.4
/*
int Week()
  {
   MqlDateTime mqt1;
   TimeCurrent(mqt1);
   return(mqt1.day_of_week);
  }
*/
void OnTick()
  {
//---no.5*
/*
   int w;
   w=Week();
   if(w ==ww) return;
*/   
   if(DayOfWeek() == ww) return;
//--- 
 
   date2=TimeCurrent();
   if(bar2==0) {bar1=1;bar2=bar1;}
   else if(bar2!=0){bar1=1+Bars(_Symbol,_Period,date1,date2);if(bar1-bar2>0)n1=1;}
   if(n1 !=1)return;
   bar2=bar1;
   n1=0;
   if(bar2==10){bar1=1;bar2=1;date1=TimeCurrent();}
 
//---no.6*
/*
   MqlTick mqtick;
   if(!SymbolInfoTick(_Symbol,mqtick))
     {
      Print("the latest price error");
      return;
     } 
   
   ArrayResize(Buffer,calculate,calculate);
   ArrayResize(Rvi,calculate,calculate);
   ArrayResize(Rsi,calculate,calculate);
   ArrayResize(Ac,calculate,calculate);
   ArrayInitialize(Buffer,0.0);  
*/
   ArrayResize(Buffer,calculate);
   ArrayInitialize(Buffer,EMPTY_VALUE);
//---
   CMamdani ma;
   double a,b,c;
   int i;
      
   for(i=0;i<calculate;i++)
     {
//---no.7*
      a = iRVI(NULL,0,rvi_period,PRICE_OPEN,i);
      b = iRSI(NULL,0,rsi_period,PRICE_OPEN,i);
      c=  iAC(NULL,0,i);     
//---
      Buffer[i]=ma.Mamdani(a,b,c);
     }
//---entry signal calculate     
   bool Buy_sig=false;
   bool Sell_sig=false;
   if(Buffer[2]<=buylev && Buffer[1]>buylev)  Buy_sig=true;
   if(Buffer[2]>=selllev && Buffer[1]<selllev)Sell_sig=true;
    
//---exite signal calculate 
   bool BuyClose_sig =false;
   bool SellClose_sig=false;
   if( Buffer[2]>Buffer[1] && Buffer[3]>=Buffer[2])  BuyClose_sig =true;//
   if( Buffer[2]<Buffer[1] && Buffer[3]<=Buffer[2])  SellClose_sig=true;//

//---position signal
   bool Buy_pos =false;
   bool Sell_pos=false;
   if(CurrentPositions(Symbol())>0)Buy_pos=true;
   else if(CurrentPositions(Symbol())<0)Sell_pos=true;

   if(Buy_sig)
     {
      if(Buy_pos)  return;

      OpenBuy();
     }

   if(Sell_sig)
     {
      if(Sell_pos) return;

      OpenSell();
     }

   if(Sell_pos && SellClose_sig)
     {
      PositionClose();
      return;
     }

   if(Buy_pos && BuyClose_sig)
     {
      PositionClose();
      return;
     }

  }
//+------+
//---no.8*
void OpenBuy()
  {
   int    res;
   if(Volume[0]>1) return;
//--- 
   double sl=Bid-10*Stop*Point;
   double tp=Ask+10*TakeProfit*Point;
   int slip=Slipage;

   res=OrderSend(Symbol(),OP_BUY,Lots,Ask,0,0,0,"",Magic,0,Blue);
   return;
  }
//--------------------  
void OpenSell()
  {
   int    res;
   if(Volume[0]>1) return;
//--- 
   double sl=Ask+10*Stop*Point;
   double tp=Bid-10*TakeProfit*Point;
   int slip=Slipage;

   res=OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,sl,tp,"",Magic,0,Red);
   return;
  }
//--------------------
void PositionClose()
  {
   if(Volume[0]>1) return;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=Magic || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {

         if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
            Print("OrderClose error ",GetLastError());
         break;
        }
      if(OrderType()==OP_SELL)
        {

         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
            Print("OrderClose error ",GetLastError());

         break;
        }
     }

  }
//--------------------
int CurrentPositions(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }
//+------------------------------------------------------------------+

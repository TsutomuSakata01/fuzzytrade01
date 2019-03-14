//+------------------------------------------------------------------+
//|                                                       Myopen.mq5 |
//|                                  Copyright 2019, TTsutomu Sakata |
//|                                                     https://www. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"
#property description "Open Buy=0,Sell=1"
#property script_show_inputs

#include <Trade/Trade.mqh>

input string  p1="-- Buy=0,Sell=1 -- ";
input int BuyOrSell=0;
input int     Magic=1001;
input double  Lots=0.01;
//input int     Slipage=10;
input int     Stop=1000;
input int     TakeProfit=1000;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   MqlTick mqtick;
   if(!SymbolInfoTick(_Symbol,mqtick))
     {
      Print("the latest price error");
      return;
     }
   if(BuyOrSell==0)
     {
      double l=Lots;
      double p = NormalizeDouble(mqtick.ask,_Digits);
      double s =NormalizeDouble(mqtick.bid - 10*Stop*_Point,_Digits);
      double t =NormalizeDouble(mqtick.ask + 10*TakeProfit*_Point,_Digits);

      CTrade m_trade;
      m_trade.SetExpertMagicNumber(Magic);
      m_trade.PositionOpen(Symbol(),ORDER_TYPE_BUY,l,p,s,t,"");
     }
   else if(BuyOrSell==1)
     {
      double l = Lots;
      double p = NormalizeDouble(mqtick.bid,_Digits);
      double s = NormalizeDouble(mqtick.ask + 10*Stop*_Point,_Digits);
      double t = NormalizeDouble(mqtick.bid - 10*TakeProfit*_Point,_Digits);

      CTrade m_trade;
      m_trade.SetExpertMagicNumber(Magic);
      m_trade.PositionOpen(Symbol(),ORDER_TYPE_SELL,l,p,s,t,"");

     }

  }
//+------------------------------------------------------------------+

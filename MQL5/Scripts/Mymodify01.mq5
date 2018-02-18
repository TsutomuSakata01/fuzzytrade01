//+------------------------------------------------------------------+
//|                                                   Mymodify01.mq5 |
//|                                  Copyright 2017, Tsutomu Sakata. |
//|                                             https://www.         |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Tsutomu Sakata"
#property link      "https://"
#property version   "1.00"
#property description "Modify Of Posistion"
#property script_show_inputs

#include <Trade/Trade.mqh>

input int     Stop=50;
input int     TakeProfit=50;
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

   if(Sell_pos)
     {
      double s=NormalizeDouble(mqtick.bid+10*Stop*_Point,_Digits);
      double t=NormalizeDouble(mqtick.bid-10*TakeProfit*_Point,_Digits);

      CTrade m_trade;
      m_trade.PositionModify(Symbol(),s,t);

     }

   if(Buy_pos)
     {
      double s=NormalizeDouble(mqtick.ask - 10*Stop*_Point,_Digits);
      double t=NormalizeDouble(mqtick.ask + 10*TakeProfit*_Point,_Digits);

      CTrade m_trade;
      m_trade.PositionModify(Symbol(),s,t);

     }

  }
//+------------------------------------------------------------------+

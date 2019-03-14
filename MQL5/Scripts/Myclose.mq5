//+------------------------------------------------------------------+
//|                                                      Myclose.mq5 |
//|                                   Copyright 2019, Tsutomu Sakata |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"
#property description "Close Of Posistion"
#property script_show_inputs

#include <Trade/Trade.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
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

   if(Sell_pos || Buy_pos)
     {
      CTrade m_trade;
      m_trade.PositionClose(Symbol());
     }

  }
//+------------------------------------------------------------------+

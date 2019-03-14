//+------------------------------------------------------------------+
//|                                                       test11.mq5 |
//|                                   Copyright 2019, TSutomu Sakata |
//|                                   https://fuzzytrade.blogspot.com|
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"


#include <Trade/Trade.mqh>

//--- input parameters
input int      Stop=500;
input int      Take=1000;
input int      Magic=1001;
input double   Lots=0.01;
input int      Slipage=10;
//---------------------------
input int      MA_Period=10;

int maH;
double maV[3];
double sclose;
int STP,TKP,SL;
//+---------------------------+
// Expert initialization function   
//+---------------------------+
int OnInit()
  {
//---
   maH=iMA(_Symbol,_Period,MA_Period,0,MODE_EMA,PRICE_CLOSE);
//--- What if handle returns Invalid Handle
   if(maH==INVALID_HANDLE)
     {
      Print("Indicators error ");
      return(INIT_FAILED);
     }
//---
   STP = Stop;
   TKP = Take;
   SL  = Slipage;
   if(_Digits==5 || _Digits==3) //EURUSD=5
     {
      STP = STP*10;
      TKP = TKP*10;
      SL  = Slipage*10;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+----------------------------+
// Expert deinitialization function     
//+----------------------------+
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(maH);

  }
//+-----------------------------+
// Expert tick function        
//+-----------------------------+
void OnTick()
  {
//------------------------------
   MqlTick l_pr;
   MqlRates mrate[2];
//------------------------------

   if(!SymbolInfoTick(_Symbol,l_pr))
     {
      Print("the latest price  error");
      return;
     }

   if(CopyRates(_Symbol,_Period,0,2,mrate)!=2)
     {
      Print("CopyRates of ",_Symbol," failed, no history");
      return;
     }

//-----

   if(CopyBuffer(maH,0,0,3,maV)<0)  return;
//-----   

   bool Buy_sig =false;
   bool Sell_sig=false;

   if(PositionSelect(_Symbol)==true)
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_sig=true;
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_sig=true;
        }
     }

   sclose=mrate[0].close;

   bool Buy_S1=(sclose>maV[1]);

   if(Buy_S1)
     {
      if(Buy_sig)  return;
      if(Sell_sig) return;
      
      double l = Lots;
      double p=NormalizeDouble(l_pr.ask,_Digits);
      double s = NormalizeDouble(l_pr.bid - STP*_Point,_Digits);
      double t = NormalizeDouble(l_pr.ask + TKP*_Point,_Digits);
      
      CTrade m_trade;
      m_trade.SetExpertMagicNumber(Magic);
      m_trade.PositionOpen(Symbol(),ORDER_TYPE_BUY,l,p,s,t,"");
     }

   bool Sell_S1=(sclose<maV[1]);

   if(Sell_S1)
     {
      if(Sell_sig) return;
      if(Buy_sig)  return;
      
      double l = Lots;
      double p = NormalizeDouble(l_pr.bid,_Digits);
      double s = NormalizeDouble(l_pr.ask + STP*_Point,_Digits);
      double t = NormalizeDouble(l_pr.bid - TKP*_Point,_Digits);
      
      CTrade m_trade;
      m_trade.SetExpertMagicNumber(Magic);
      m_trade.PositionOpen(Symbol(),ORDER_TYPE_SELL,l,p,s,t,"");
     }
  }
//END
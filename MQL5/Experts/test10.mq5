//+------------------------------------------------------------------+
//|                                                       test10.mq5 |
//|                                   Copyright 2019, Tsutomu Sakata |
//|                                  https://fuzzytrade.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"
//--- input parameters
input int      Stop=500;
input int      Take=1000;
input int      Magic=1001;
input double   Lots=0.01;
input int      Slipage=10;
//---------------------------
input int      MA_Period =8;
int maH;
double maV[3]; 
double sclose;
int STP, TKP ,SL;   
int OnInit()
  {
   maH=iMA(_Symbol,_Period,MA_Period,0,MODE_SMA,PRICE_CLOSE);
   if( maH==INVALID_HANDLE)
     {
      Print("Indicators error ");
      return(INIT_FAILED);
     }
//---
   STP = Stop;
   TKP = Take;
   SL  = Slipage;
   
   if(_Digits==5 || _Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
      SL  = Slipage*10;
     }
//---
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(maH);
  }
void OnTick()
  {
//------------------------------
   MqlTradeRequest mreq;
   MqlTradeResult mresu;
   MqlTick l_pr;
   MqlRates mrate[2];
        
//------------------------------
    ZeroMemory(mreq);       
    ZeroMemory(mresu); 
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
    if(CopyBuffer(maH,0,0,3,maV)<0)  return;  
//-----  
     bool Buy_sig =false;  
     bool Sell_sig=false;  
    if (PositionSelect(_Symbol) ==true)  
    {
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         {
            Buy_sig = true;  
         }
         else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         {
            Sell_sig = true; 
         }
    }
     sclose=mrate[1].close;  
     bool Buy_S1 = (maV[1]>maV[2]) ;//&& (maV[2]>maV[3]); 
     bool Buy_S2 = (sclose > maV[1]); 
     if(Buy_S1 && Buy_S2)
      {
         if (Buy_sig)  return;
         if (Sell_sig) return;         
         mreq.action = TRADE_ACTION_DEAL;                                
         mreq.price = NormalizeDouble(l_pr.ask,_Digits);          
         mreq.sl = NormalizeDouble(l_pr.ask - STP*_Point,_Digits); 
         mreq.tp = NormalizeDouble(l_pr.ask + TKP*_Point,_Digits); 
         mreq.symbol = _Symbol;                                         
         mreq.volume = Lots;                                            
         mreq.magic = Magic;                                        
         mreq.type = ORDER_TYPE_BUY;                                     
         mreq.type_filling = ORDER_FILLING_FOK;                          
         mreq.deviation= SL ;      
         OrderSend(mreq,mresu);  
       }
      bool Sell_S1 = (maV[1]<maV[2]) ;//&& (maV[2]<maV[3]);  
      bool Sell_S2 = (sclose <maV[1]);  
      if(Sell_S1 && Sell_S2) 
       {
          if (Buy_sig)  return;
          if (Sell_sig) return;
          mreq.action = TRADE_ACTION_DEAL;                                 
          mreq.price = NormalizeDouble(l_pr.bid,_Digits);          
          mreq.sl = NormalizeDouble(l_pr.bid + STP*_Point,_Digits); 
          mreq.tp = NormalizeDouble(l_pr.bid - TKP*_Point,_Digits); 
          mreq.symbol = _Symbol;                                         
          mreq.volume = Lots;                                            
          mreq.magic = Magic;                                        
          mreq.type= ORDER_TYPE_SELL;                                     
          mreq.type_filling = ORDER_FILLING_FOK;                          
          mreq.deviation= SL  ;      
          OrderSend(mreq,mresu);
        }    
  }
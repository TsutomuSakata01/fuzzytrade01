//+------------------------------------------------------------------+
//|                                                  MamdaniRVI3.mq5 |
//|                                   Copyright 2019, Tsutomu Sakata |
//|                                  https://fuzzytrade.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
#include <Math\Fuzzy\membershipfunction.mqh> 
#include <Graphics\Graphic.mqh> 
//--- メンバシップ関数を作成する 
CZ_ShapedMembershipFunction func2(-1.0, 0.1);
CNormalMembershipFunction func0(0.0, 0.2); 
CNormalMembershipFunction func1(0.1, 0.26); 
CS_ShapedMembershipFunction func3(-0.1, 1.0);

//--- メンバシップ関数のラッパーを作成する 
double NormalMembershipFunction0(double x) { return(func0.GetValue(x)); } 
double NormalMembershipFunction1(double x) { return(func1.GetValue(x)); } 
double ZShapedMembershipFunction(double x) { return(func2.GetValue(x)); }
double SShapedMembershipFunction(double x) { return(func3.GetValue(x)); }
 

void OnStart() 
  { 
//--- グラフィックを作成する 
   CGraphic graphic; 
   if(!graphic.Create(0,"MamdaniRVI3",0,30,30,780,380)) 
     { 
      graphic.Attach(0,"MamdaniRVI3"); 
     } 
   graphic.HistoryNameWidth(70); 
   graphic.BackgroundMain("MamdaniRVI3"); 
   graphic.BackgroundMainSize(16); 
//--- 曲線を作成する 
   graphic.CurveAdd(NormalMembershipFunction0,-1.0,1.0,0.01,CURVE_LINES,"[0.0, 0.2]"); 
   graphic.CurveAdd(NormalMembershipFunction1,-1.0,1.0,0.01,CURVE_LINES,"[0.1, 0.26]"); 
   graphic.CurveAdd(ZShapedMembershipFunction,-1.0,1.0,0.01,CURVE_LINES,"[-1.0, 0.1]"); 
   graphic.CurveAdd(SShapedMembershipFunction,-1.0,1.0,0.01,CURVE_LINES,"[-0.1, 1.0]"); 
//--- X軸プロパティを設定する 
   graphic.XAxis().AutoScale(false); 
   graphic.XAxis().Min(-1.0); 
   graphic.XAxis().Max(1.0); 
   graphic.XAxis().DefaultStep(0.1); 
//--- Y軸プロパティを設定する 
   graphic.YAxis().AutoScale(false); 
   graphic.YAxis().Min(0.0); 
   graphic.YAxis().Max(1.1); 
   graphic.YAxis().DefaultStep(0.1); 
//--- プロットする 
   graphic.CurvePlotAll(); 
   graphic.Update(); 
  }
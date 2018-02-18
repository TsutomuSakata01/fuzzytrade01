//+------------------------------------------------------------------+
//|                                                FuzzySugeno01.mqh |
//|                                   Copyright 2018,Tsutomu Sakata  |
//|                                  https://fuzzytrade.blogspot.com |         
//+------------------------------------------------------------------+
#property copyright "Copyright 2018,Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Math\fuzzy\SugenoFuzzySystem.mqh>
#include <MyFuzzy\Sugeno\SugenoPlotsADXWS01.mqh>
#include <MyFuzzy\Sugeno\SugenoPlotsMOM_W01.mqh>
#include <MyFuzzy\Sugeno\SugenoPlotsRSI01.mqh>
#include <MyFuzzy\Sugeno\SugenoPlotsOutput01.mqh>
//---CSugeno  
class CSugeno
  {
   double            min_adxws;
   double            max_adxws;

   double            min_mom;
   double            max_mom;

   double            min_rsi;
   double            max_rsi;

public:
                     CSugeno(void);
                    ~CSugeno(void);

   double            Sugeno(double t,double u,double v);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSugeno::CSugeno(void)
  {
   min_adxws=  -25.0;
   max_adxws=   25.0;
   min_mom  =   -0.03;
   max_mom  =    0.03;
   min_rsi  =    0.0;
   max_rsi  =  100.0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSugeno::~CSugeno(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSugeno::Sugeno(double t,double u,double v)
  {
   double res=0;

//--- Sugeno Fuzzy System
   CSugenoFuzzySystem *fsSignal=new CSugenoFuzzySystem();
//--- Create input variables for the system
   CFuzzyVariable *fsadxws=new CFuzzyVariable("adxws",min_adxws,max_adxws);
   CFuzzyVariable *fsmom  =new CFuzzyVariable("mom",  min_mom,  max_mom);
   CFuzzyVariable *fsrsi  =new CFuzzyVariable("rsi",  min_rsi,  max_rsi);
   
//--- ADXWS
   fsadxws.Terms().Add(new CFuzzyTerm("aminus", new CTrapezoidMembershipFunction(adxwsa1, adxwsa2, adxwsa3, adxwsa4)));
   fsadxws.Terms().Add(new CFuzzyTerm("amid",   new CTrapezoidMembershipFunction(adxwsb1, adxwsb2, adxwsb3, adxwsb4)));
   fsadxws.Terms().Add(new CFuzzyTerm("aplus",  new CTrapezoidMembershipFunction(adxwsc1, adxwsc2, adxwsc3, adxwsc4)));
   fsSignal.Input().Add(fsadxws);

//--- MOM_W
   fsmom.Terms().Add(new CFuzzyTerm("mminus", new CTrapezoidMembershipFunction(moma1, moma2, moma3, moma4)));
   fsmom.Terms().Add(new CFuzzyTerm("mmid", new CTrapezoidMembershipFunction(momb1, momb2, momb3, momb4)));
   fsmom.Terms().Add(new CFuzzyTerm("mplus",new CTrapezoidMembershipFunction(momc1, momc2, momc3, momc4)));
   fsSignal.Input().Add(fsmom);

//--- RSI
   fsrsi.Terms().Add(new CFuzzyTerm("rlow", new CTrapezoidMembershipFunction(rsia1, rsia2, rsia3, rsia4)));
   fsrsi.Terms().Add(new CFuzzyTerm("rmed", new CTrapezoidMembershipFunction(rsib1, rsib2, rsib3, rsib4)));
   fsrsi.Terms().Add(new CFuzzyTerm("rhigh",new CTrapezoidMembershipFunction(rsic1, rsic2, rsic3, rsic4)));
   fsSignal.Input().Add(fsrsi);

//--- Create Output
   CSugenoVariable *svSignal=new CSugenoVariable("signal");

   svSignal.Functions().Add(fsSignal.CreateSugenoFunction("ominus", coeff1));
   svSignal.Functions().Add(fsSignal.CreateSugenoFunction("ommid", coeff2));
   svSignal.Functions().Add(fsSignal.CreateSugenoFunction("zero", coeff3));
   svSignal.Functions().Add(fsSignal.CreateSugenoFunction("opmid",coeff4));
   svSignal.Functions().Add(fsSignal.CreateSugenoFunction("oplus",coeff5));

   fsSignal.Output().Add(svSignal);

//--- Create Sugeno fuzzy rule
  //---adxws is aminus
   CSugenoFuzzyRule *rule1  = fsSignal.ParseRule("if (adxws is aminus) and (mom is mminus) and (rsi is rlow)   then (signal is ominus)");
   CSugenoFuzzyRule *rule2  = fsSignal.ParseRule("if (adxws is aminus) and (mom is mminus) and (rsi is rmed)    then (signal is ommid)");
   CSugenoFuzzyRule *rule3  = fsSignal.ParseRule("if (adxws is aminus) and (mom is mminus) and (rsi is rhigh)  then (signal is zero)");
   
   CSugenoFuzzyRule *rule4  = fsSignal.ParseRule("if (adxws is aminus) and (mom is mmid) and (rsi is rlow)   then (signal is ommid)");
   CSugenoFuzzyRule *rule5  = fsSignal.ParseRule("if (adxws is aminus) and (mom is mmid) and (rsi is rmed)    then (signal is zero)");
   CSugenoFuzzyRule *rule6  = fsSignal.ParseRule("if (adxws is aminus) and (mom is mmid) and (rsi is rhigh)  then (signal is zero)");

   CSugenoFuzzyRule *rule7  = fsSignal.ParseRule("if (adxws is aminus) and (mom is mplus) and (rsi is rlow)    then (signal is zero)");
   CSugenoFuzzyRule *rule8  = fsSignal.ParseRule("if (adxws is aminus) and (mom is mplus) and (rsi is rmed)     then (signal is zero)");
   CSugenoFuzzyRule *rule9  = fsSignal.ParseRule("if (adxws is aminus) and (mom is mplus) and (rsi is rhigh)   then (signal is zero)");
//---adxws is med
   CSugenoFuzzyRule *rule10  = fsSignal.ParseRule("if (adxws is amid) and (mom is mminus) and (rsi is rlow)   then (signal is ommid)");
   CSugenoFuzzyRule *rule11  = fsSignal.ParseRule("if (adxws is amid) and (mom is mminus) and (rsi is rmed)    then (signal is zero)");
   CSugenoFuzzyRule *rule12  = fsSignal.ParseRule("if (adxws is amid) and (mom is mminus) and (rsi is rhigh)  then (signal is zero)");
   
   CSugenoFuzzyRule *rule13  = fsSignal.ParseRule("if (adxws is amid) and (mom is mmid) and (rsi is rlow)   then (signal is zero)");
   CSugenoFuzzyRule *rule14  = fsSignal.ParseRule("if (adxws is amid) and (mom is mmid) and (rsi is rmed)    then (signal is zero)");
   CSugenoFuzzyRule *rule15  = fsSignal.ParseRule("if (adxws is amid) and (mom is mmid) and (rsi is rhigh)  then (signal is zero)");

   CSugenoFuzzyRule *rule16  = fsSignal.ParseRule("if (adxws is amid) and (mom is mplus) and (rsi is rlow)    then (signal is zero)");
   CSugenoFuzzyRule *rule17  = fsSignal.ParseRule("if (adxws is amid) and (mom is mplus) and (rsi is rmed)     then (signal is zero)");
   CSugenoFuzzyRule *rule18  = fsSignal.ParseRule("if (adxws is amid) and (mom is mplus) and (rsi is rhigh)   then (signal is opmid)");
//---adxws is plus   
   CSugenoFuzzyRule *rule19  = fsSignal.ParseRule("if (adxws is aplus) and (mom is mminus) and (rsi is rlow)   then (signal is zero)");
   CSugenoFuzzyRule *rule20  = fsSignal.ParseRule("if (adxws is aplus) and (mom is mminus) and (rsi is rmed)    then (signal is zero)");
   CSugenoFuzzyRule *rule21  = fsSignal.ParseRule("if (adxws is aplus) and (mom is mminus) and (rsi is rhigh)  then (signal is zero)");
   
   CSugenoFuzzyRule *rule22  = fsSignal.ParseRule("if (adxws is aplus) and (mom is mmid) and (rsi is rlow)   then (signal is zero)");
   CSugenoFuzzyRule *rule23  = fsSignal.ParseRule("if (adxws is aplus) and (mom is mmid) and (rsi is rmed)    then (signal is zero)");
   CSugenoFuzzyRule *rule24  = fsSignal.ParseRule("if (adxws is aplus) and (mom is mmid) and (rsi is rhigh)  then (signal is opmid)");

   CSugenoFuzzyRule *rule25  = fsSignal.ParseRule("if (adxws is aplus) and (mom is mplus) and (rsi is rlow)    then (signal is zero)");
   CSugenoFuzzyRule *rule26  = fsSignal.ParseRule("if (adxws is aplus) and (mom is mplus) and (rsi is rmed)     then (signal is opmid)");
   CSugenoFuzzyRule *rule27  = fsSignal.ParseRule("if (adxws is aplus) and (mom is mplus) and (rsi is rhigh)   then (signal is oplus)");

//--- Add Sugeno fuzzy rule
   fsSignal.Rules().Add(rule1);
   fsSignal.Rules().Add(rule2);
   fsSignal.Rules().Add(rule3);
   fsSignal.Rules().Add(rule4);
   fsSignal.Rules().Add(rule5);
   fsSignal.Rules().Add(rule6);
   fsSignal.Rules().Add(rule7);
   fsSignal.Rules().Add(rule8);
   fsSignal.Rules().Add(rule9);
   fsSignal.Rules().Add(rule10);
   fsSignal.Rules().Add(rule11);
   fsSignal.Rules().Add(rule12);
   fsSignal.Rules().Add(rule13);
   fsSignal.Rules().Add(rule14);
   fsSignal.Rules().Add(rule15);
   fsSignal.Rules().Add(rule16);
   fsSignal.Rules().Add(rule17);
   fsSignal.Rules().Add(rule18);
   fsSignal.Rules().Add(rule19);
   fsSignal.Rules().Add(rule20);
   fsSignal.Rules().Add(rule21);
   fsSignal.Rules().Add(rule22);
   fsSignal.Rules().Add(rule23);
   fsSignal.Rules().Add(rule24);
   fsSignal.Rules().Add(rule25);
   fsSignal.Rules().Add(rule26);
   fsSignal.Rules().Add(rule27);
   
//--- Set input value
   CList *in=new CList;

   CDictionary_Obj_Double *p_od_adxws  = new CDictionary_Obj_Double;
   CDictionary_Obj_Double *p_od_mom  = new CDictionary_Obj_Double;
   CDictionary_Obj_Double *p_od_rsi   = new CDictionary_Obj_Double;
//--- 
   double t1;
   double u1;
   double v1;

   if(t>=25.0) t1=25.0;
   else if(t<=-25.0) t1=-25.0;
   else t1=t;

   if(u>=0.03) u1=0.03;
   else if(u<=-0.03) u1=-0.03;
   else u1=u;

   if(v>=100.0) v1=100.0;
   else if(v<=0.0) v1=0.0;
   else v1=v;
//---   
   p_od_adxws.SetAll(fsadxws,t1);
   p_od_mom.SetAll(fsmom,u1);
   p_od_rsi.SetAll(fsrsi,v1);

//---
   in.Add(p_od_adxws);
   in.Add(p_od_mom);
   in.Add(p_od_rsi);
//---
   CList *result;
   CDictionary_Obj_Double *p_od_out;

   result=fsSignal.Calculate(in);
   p_od_out=result.GetNodeAtIndex(0);

   res=NormalizeDouble(p_od_out.Value(),_Digits);

   delete in;
   delete result;
 
   delete fsSignal;
   delete svSignal;
   delete fsadxws;
   delete fsmom;
   delete fsrsi;

   return res;
  }
//+------------------------------------------------------------------+

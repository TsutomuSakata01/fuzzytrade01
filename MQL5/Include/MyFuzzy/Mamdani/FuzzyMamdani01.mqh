//+------------------------------------------------------------------+
//|                                              FuzzyMammdani01.mqh |
//|                                   Copyright 2019,Tsutomu Sakata  |
//|                                   https://fuzzytrade.blogspot.com|         
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Math\fuzzy\MamdaniFuzzySystem.mqh>
#include <MyFuzzy\Mamdani\MamdaniPlots01.mqh>
//---CMamdani  
 class CMamdani
 {
   double min_rvi;
   double max_rvi;

   double min_rsi;
   double max_rsi;

   double min_ac;
   double max_ac;
   
   double min_tp ;
   double max_tp ;
 
 public:
           CMamdani(void);
          ~CMamdani(void);
   //void     Setadx(void);       
          
   double   Mamdani(double t,double u,double v);           
 }; 

CMamdani::CMamdani(void)
 {
   min_rvi=   -1.0;
   max_rvi=    1.0;
   min_rsi=    0.0;
   max_rsi=  100.0;
   min_ac =   -0.02;
   max_ac =    0.02;  
   
   min_tp=    -1.0;
   max_tp=     1.0; 
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMamdani::~CMamdani(void)
  {
  } 
double CMamdani::Mamdani(double t,double u,double v)
  {
   double res=0;
//--- Mamdani Fuzzy System
   CMamdaniFuzzySystem *fsSignal=new CMamdaniFuzzySystem();
//--- Create input variables for the system
   CFuzzyVariable *fsrvi=new CFuzzyVariable("rvx",min_rvi,max_rvi);
   CFuzzyVariable *fsrsi=new CFuzzyVariable("rsx",min_rsi,max_rsi);
   CFuzzyVariable *fsac =new CFuzzyVariable("acx",min_ac,max_ac); 
   
//--- RVI
   fsrvi.Terms().Add(new CFuzzyTerm("minus", new CTrapezoidMembershipFunction(rvia1, rvia2, rvia3, rvia4)));
   fsrvi.Terms().Add(new CFuzzyTerm("mid",   new CTrapezoidMembershipFunction(rvib1, rvib2, rvib3, rvib4)));
   fsrvi.Terms().Add(new CFuzzyTerm("plus",  new CTrapezoidMembershipFunction(rvic1, rvic2, rvic3, rvic4)));
   fsSignal.Input().Add(fsrvi);

//--- RSI
   fsrsi.Terms().Add(new CFuzzyTerm("low", new CTrapezoidMembershipFunction(rsia1, rsia2, rsia3, rsia4)));
   fsrsi.Terms().Add(new CFuzzyTerm("med", new CTrapezoidMembershipFunction(rsib1, rsib2, rsib3, rsib4)));
   fsrsi.Terms().Add(new CFuzzyTerm("high",new CTrapezoidMembershipFunction(rsic1, rsic2, rsic3, rsic4)));
   fsSignal.Input().Add(fsrsi);

//--- AC
   fsac.Terms().Add(new CFuzzyTerm("minus", new CTrapezoidMembershipFunction(aia1, aia2, aia3, aia4)));
   fsac.Terms().Add(new CFuzzyTerm("mid", new CTrapezoidMembershipFunction(aib1, aib2, aib3, aib4)));
   fsac.Terms().Add(new CFuzzyTerm("plus",new CTrapezoidMembershipFunction(aic1, aic2, aic3, aic4)));
   fsSignal.Input().Add(fsac);
   
   
//--- Create Output
   CFuzzyVariable *fvSignal=new CFuzzyVariable("signal",min_tp,max_tp);
   
   fvSignal.Terms().Add(new CFuzzyTerm("nfast", new CTrapezoidMembershipFunction(oa1, oa2, oa3, oa4)));
   fvSignal.Terms().Add(new CFuzzyTerm("nslow", new CTrapezoidMembershipFunction(ob1, ob2, ob3, ob4)));
   fvSignal.Terms().Add(new CFuzzyTerm("zero", new CTrapezoidMembershipFunction(oc1, oc2, oc3, oc4)));
   fvSignal.Terms().Add(new CFuzzyTerm("slow", new CTrapezoidMembershipFunction(od1, od2, od3, od4)));
   fvSignal.Terms().Add(new CFuzzyTerm("fast", new CTrapezoidMembershipFunction(oe1, oe2, oe3, oe4)));
   
    fsSignal.Output().Add(fvSignal);

//--- Create Mamdani fuzzy rule
  //---rvx is minus
   CMamdaniFuzzyRule *rule1  = fsSignal.ParseRule("if (rvx is minus) and (rsx is low) and (acx is minus)   then (signal is nfast)");
   CMamdaniFuzzyRule *rule2  = fsSignal.ParseRule("if (rvx is minus) and (rsx is low) and (acx is mid)    then (signal is nslow)");
   CMamdaniFuzzyRule *rule3  = fsSignal.ParseRule("if (rvx is minus) and (rsx is low) and (acx is plus)  then (signal is zero)");
   
   CMamdaniFuzzyRule *rule4  = fsSignal.ParseRule("if (rvx is minus) and (rsx is med) and (acx is minus)   then (signal is nslow)");
   CMamdaniFuzzyRule *rule5  = fsSignal.ParseRule("if (rvx is minus) and (rsx is med) and (acx is mid)    then (signal is zero)");
   CMamdaniFuzzyRule *rule6  = fsSignal.ParseRule("if (rvx is minus) and (rsx is med) and (acx is plus)  then (signal is zero)");

   CMamdaniFuzzyRule *rule7  = fsSignal.ParseRule("if (rvx is minus) and (rsx is high) and (acx is minus)    then (signal is zero)");
   CMamdaniFuzzyRule *rule8  = fsSignal.ParseRule("if (rvx is minus) and (rsx is high) and (acx is mid)     then (signal is zero)");
   CMamdaniFuzzyRule *rule9  = fsSignal.ParseRule("if (rvx is minus) and (rsx is high) and (acx is plus)   then (signal is zero)");
//---rvx is med
   CMamdaniFuzzyRule *rule10  = fsSignal.ParseRule("if (rvx is mid) and (rsx is low) and (acx is minus)   then (signal is nslow)");
   CMamdaniFuzzyRule *rule11  = fsSignal.ParseRule("if (rvx is mid) and (rsx is low) and (acx is mid)    then (signal is zero)");
   CMamdaniFuzzyRule *rule12  = fsSignal.ParseRule("if (rvx is mid) and (rsx is low) and (acx is plus)  then (signal is zero)");
   
   CMamdaniFuzzyRule *rule13  = fsSignal.ParseRule("if (rvx is mid) and (rsx is med) and (acx is minus)   then (signal is zero)");
   CMamdaniFuzzyRule *rule14  = fsSignal.ParseRule("if (rvx is mid) and (rsx is med) and (acx is mid)    then (signal is zero)");
   CMamdaniFuzzyRule *rule15  = fsSignal.ParseRule("if (rvx is mid) and (rsx is med) and (acx is plus)  then (signal is zero)");

   CMamdaniFuzzyRule *rule16  = fsSignal.ParseRule("if (rvx is mid) and (rsx is high) and (acx is minus)    then (signal is zero)");
   CMamdaniFuzzyRule *rule17  = fsSignal.ParseRule("if (rvx is mid) and (rsx is high) and (acx is mid)     then (signal is zero)");
   CMamdaniFuzzyRule *rule18  = fsSignal.ParseRule("if (rvx is mid) and (rsx is high) and (acx is plus)   then (signal is slow)");
//---rvx is plus   
   CMamdaniFuzzyRule *rule19  = fsSignal.ParseRule("if (rvx is plus) and (rsx is low) and (acx is minus)   then (signal is zero)");
   CMamdaniFuzzyRule *rule20  = fsSignal.ParseRule("if (rvx is plus) and (rsx is low) and (acx is mid)    then (signal is zero)");
   CMamdaniFuzzyRule *rule21  = fsSignal.ParseRule("if (rvx is plus) and (rsx is low) and (acx is plus)  then (signal is zero)");
   
   CMamdaniFuzzyRule *rule22  = fsSignal.ParseRule("if (rvx is plus) and (rsx is med) and (acx is minus)   then (signal is zero)");
   CMamdaniFuzzyRule *rule23  = fsSignal.ParseRule("if (rvx is plus) and (rsx is med) and (acx is mid)    then (signal is zero)");
   CMamdaniFuzzyRule *rule24  = fsSignal.ParseRule("if (rvx is plus) and (rsx is med) and (acx is plus)  then (signal is slow)");

   CMamdaniFuzzyRule *rule25  = fsSignal.ParseRule("if (rvx is plus) and (rsx is high) and (acx is minus)    then (signal is zero)");
   CMamdaniFuzzyRule *rule26  = fsSignal.ParseRule("if (rvx is plus) and (rsx is high) and (acx is mid)     then (signal is slow)");
   CMamdaniFuzzyRule *rule27  = fsSignal.ParseRule("if (rvx is plus) and (rsx is high) and (acx is plus)   then (signal is fast)");
   
//--- Add four Mamdani fuzzy rule in system
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
   CDictionary_Obj_Double *p_od_rvi  = new CDictionary_Obj_Double;
   CDictionary_Obj_Double *p_od_rsi  = new CDictionary_Obj_Double;
   CDictionary_Obj_Double *p_od_ac   = new CDictionary_Obj_Double;

//--- 
   double t1;
   double u1;
   double v1;

   if(t>=1.0) t1=1.0;
   else if(t<=-1.0) t1=-1.0;
   else t1=t;

   if(u>=100.0) u1=100.0;
   else if(u<=0.0) u1=0.0;
   else u1=u;

   if(v>=0.02) v1=0.02;
   else if(v<=-0.02) v1=-0.02;
   else v1=v;
   
//---   
   p_od_rvi.SetAll(fsrvi,t1);
   p_od_rsi.SetAll(fsrsi,u1);
   p_od_ac.SetAll(fsac,v1);
   
//---
   in.Add(p_od_rvi);
   in.Add(p_od_rsi);
   in.Add(p_od_ac);
   
//--- Get result
   CList *result;
   CDictionary_Obj_Double *p_od_out;
   
   result=fsSignal.Calculate(in);
   p_od_out=result.GetNodeAtIndex(0);
   
   res=NormalizeDouble(p_od_out.Value(),_Digits);

   delete in;
   delete result;
   
   delete fsSignal;
   
   return res;
  }  
//+------------------------------------------------------------------+

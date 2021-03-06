//+------------------------------------------------------------------+
//|                                                  Fuzzy3Rvi01.mqh |
//|                                   Copyright 2019,Tsutomu Sakata  |
//|                                   https://fuzzytrade.blogspot.com|         
//+------------------------------------------------------------------+
#property copyright "Copyright 2019,Tsutomu Sakata"
#property link      "https://fuzzytrade.blogspot.com"
#property version   "2.01"

input double Gposition= 0.1;
input double Gsigma   = 0.26;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Math\fuzzy\MamdaniFuzzySystem.mqh>
//---CMamdani  
class CMamdani
  {
   double            min_rvi1;
   double            max_rvi1;

   double            min_rvi2;
   double            max_rvi2;

   double            min_rvi3;
   double            max_rvi3;

   double            min_tp;
   double            max_tp;

public:
                     CMamdani(void);
                    ~CMamdani(void);
   //void     Setadx(void);       

   double            Mamdani(double t,double u,double v);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMamdani::CMamdani(void)
  {
   min_rvi1=   -1.0;
   max_rvi1=    1.0;
   min_rvi2=   -1.0;
   max_rvi2=    1.0;
   min_rvi3 =   -1.0;
   max_rvi3 =    1.0;

   min_tp=    -1.0;
   max_tp=     1.0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMamdani::~CMamdani(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMamdani::Mamdani(double t,double u,double v)
  {
   double res=0;
//--- Mamdani Fuzzy System
   CMamdaniFuzzySystem *fsSignal=new CMamdaniFuzzySystem();
//--- Create input variables for the system
   CFuzzyVariable *fsrvi1=new CFuzzyVariable("rvx1",min_rvi1,max_rvi1);
   CFuzzyVariable *fsrvi2=new CFuzzyVariable("rvx2",min_rvi2,max_rvi2);
   CFuzzyVariable *fsrvi3=new CFuzzyVariable("rvx3",min_rvi3,max_rvi3);

//--- RVI1
   fsrvi1.Terms().Add(new CFuzzyTerm("minus", new CZ_ShapedMembershipFunction(-1.0,0.1)));
   fsrvi1.Terms().Add(new CFuzzyTerm("zero",  new CNormalMembershipFunction(0,0.2)));
   fsrvi1.Terms().Add(new CFuzzyTerm("plus",  new CS_ShapedMembershipFunction(-0.1,1.0)));
   fsSignal.Input().Add(fsrvi1);

//--- RVI2
   fsrvi2.Terms().Add(new CFuzzyTerm("minus", new CZ_ShapedMembershipFunction(-1.0,0.1)));
   fsrvi2.Terms().Add(new CFuzzyTerm("zero", new CNormalMembershipFunction(0,0.2)));
   fsrvi2.Terms().Add(new CFuzzyTerm("plus",new CS_ShapedMembershipFunction(-0.1,1.0)));
   fsSignal.Input().Add(fsrvi2);

//--- RVI3
   fsrvi3.Terms().Add(new CFuzzyTerm("minus", new CZ_ShapedMembershipFunction(-1.0,0.1)));
   fsrvi3.Terms().Add(new CFuzzyTerm("zero", new CNormalMembershipFunction(0,0.2)));
   fsrvi3.Terms().Add(new CFuzzyTerm("plus",new CS_ShapedMembershipFunction(-0.1,1.0)));
   fsSignal.Input().Add(fsrvi3);

//--- Create Output
   CFuzzyVariable *fvSignal=new CFuzzyVariable("signal",min_tp,max_tp);

   fvSignal.Terms().Add(new CFuzzyTerm("minus",new CZ_ShapedMembershipFunction(-1.0,0.1)));
   fvSignal.Terms().Add(new CFuzzyTerm("zero", new CNormalMembershipFunction(Gposition,Gsigma)));
   fvSignal.Terms().Add(new CFuzzyTerm("plus", new CS_ShapedMembershipFunction(-0.1,1.0)));

   fsSignal.Output().Add(fvSignal);

//--- Create Mamdani fuzzy rule
   CMamdaniFuzzyRule *rule1  = fsSignal.ParseRule("if (rvx1 is minus) and (rvx2 is minus)and (rvx3 is minus)   then (signal is minus)");
   CMamdaniFuzzyRule *rule2  = fsSignal.ParseRule("if (rvx1 is plus)  and (rvx2 is plus) and (rvx3 is plus)    then (signal is plus)");
   CMamdaniFuzzyRule *rule3  = fsSignal.ParseRule("if (rvx1 is zero)  and (rvx2 is zero) and (rvx3 is zero)    then (signal is zero)");

   CMamdaniFuzzyRule *rule4  = fsSignal.ParseRule("if (rvx1 is minus) and (rvx2 is plus) and (rvx3 is minus)   then (signal is zero)");
   CMamdaniFuzzyRule *rule5  = fsSignal.ParseRule("if (rvx1 is plus)  and (rvx2 is plus) and (rvx3 is minus)   then (signal is zero)");
   CMamdaniFuzzyRule *rule6  = fsSignal.ParseRule("if (rvx1 is minus) and (rvx2 is minus)and (rvx3 is plus)    then (signal is zero)");

   CMamdaniFuzzyRule *rule7  = fsSignal.ParseRule("if (rvx1 is minus) and (rvx2 is minus)and (rvx3 is zero)    then (signal is minus)");
   CMamdaniFuzzyRule *rule8  = fsSignal.ParseRule("if (rvx1 is plus)  and (rvx2 is plus) and (rvx3 is zero)    then (signal is plus)");
   CMamdaniFuzzyRule *rule9  = fsSignal.ParseRule("if (rvx1 is minus) and (rvx2 is zero) and (rvx3 is minus)   then (signal is minus)");

   CMamdaniFuzzyRule *rule10  = fsSignal.ParseRule("if (rvx1 is plus) and (rvx2 is zero) and (rvx3 is plus)    then (signal is plus)");
   CMamdaniFuzzyRule *rule11  = fsSignal.ParseRule("if (rvx1 is zero) and (rvx2 is minus)and (rvx3 is minus)   then (signal is minus)");
   CMamdaniFuzzyRule *rule12  = fsSignal.ParseRule("if (rvx1 is zero) and (rvx2 is plus) and (rvx3 is plus)    then (signal is plus)");
//---
   CMamdaniFuzzyRule *rule13  = fsSignal.ParseRule("if (rvx1 is minus) and (rvx2 is plus)and (rvx3 is plus)    then (signal is zero)");
   CMamdaniFuzzyRule *rule14  = fsSignal.ParseRule("if (rvx1 is plus)  and (rvx2 is minus) and (rvx3 is minus) then (signal is zero)");
   CMamdaniFuzzyRule *rule15  = fsSignal.ParseRule("if (rvx1 is plus)  and (rvx2 is minus) and (rvx3 is plus)  then (signal is zero)");

   CMamdaniFuzzyRule *rule16  = fsSignal.ParseRule("if (rvx1 is plus) and (rvx2 is minus)and (rvx3 is zero)  　 then (signal is zero)");
   CMamdaniFuzzyRule *rule17  = fsSignal.ParseRule("if (rvx1 is minus)and (rvx2 is plus) and (rvx3 is zero)    then (signal is zero)");
   CMamdaniFuzzyRule *rule18  = fsSignal.ParseRule("if (rvx1 is plus) and (rvx2 is zero)and  (rvx3 is minus)   then (signal is zero)");

   CMamdaniFuzzyRule *rule19  = fsSignal.ParseRule("if (rvx1 is minus)and (rvx2 is zero)and (rvx3 is plus)     then (signal is zero)");
   CMamdaniFuzzyRule *rule20  = fsSignal.ParseRule("if (rvx1 is zero) and (rvx2 is plus) and (rvx3 is minus)   then (signal is zero)");
   CMamdaniFuzzyRule *rule21  = fsSignal.ParseRule("if (rvx1 is zero) and (rvx2 is minus) and (rvx3 is plus) 　 then (signal is zero)");

   CMamdaniFuzzyRule *rule22  = fsSignal.ParseRule("if (rvx1 is zero) and (rvx2 is zero) and (rvx3 is plus)    then (signal is plus)");
   CMamdaniFuzzyRule *rule23  = fsSignal.ParseRule("if (rvx1 is zero) and (rvx2 is zero)and (rvx3 is minus)    then (signal is minus)");
   CMamdaniFuzzyRule *rule24  = fsSignal.ParseRule("if (rvx1 is zero) and (rvx2 is plus) and (rvx3 is zero)    then (signal is plus)");

   CMamdaniFuzzyRule *rule25  = fsSignal.ParseRule("if (rvx1 is zero) and (rvx2 is minus) and (rvx3 is zero)   then (signal is minus)");
   CMamdaniFuzzyRule *rule26  = fsSignal.ParseRule("if (rvx1 is plus) and (rvx2 is zero)and (rvx3 is zero)     then (signal is plus)");
   CMamdaniFuzzyRule *rule27  = fsSignal.ParseRule("if (rvx1 is minus) and (rvx2 is zero) and (rvx3 is zero)   then (signal is minus)");
//---

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
   CDictionary_Obj_Double *p_od_rvi1  = new CDictionary_Obj_Double;
   CDictionary_Obj_Double *p_od_rvi2  = new CDictionary_Obj_Double;
   CDictionary_Obj_Double *p_od_rvi3  = new CDictionary_Obj_Double;

//--- 
   double v1;
   double v2;
   double v3;

   if(t>=1.0) v1=1.0;
   else if(t<=-1.0) v1=-1.0;
   else v1=t;

   if(u>=1.0) v2=1.0;
   else if(u<=-1.0) v2=-1.0;
   else v2=u;

   if(v>=1.0) v3=1.0;
   else if(v<=-1.0) v3=-1.0;
   else v3=v;

//---   
   p_od_rvi1.SetAll(fsrvi1,v1);
   p_od_rvi2.SetAll(fsrvi2,v2);
   p_od_rvi3.SetAll(fsrvi3,v3);

//---
   in.Add(p_od_rvi1);
   in.Add(p_od_rvi2);
   in.Add(p_od_rvi3);

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

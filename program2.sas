
libname exch "E:\ECON5820\FTA";

/*
Practice test 2

Purpose: estimate the effects of the exchange rate on imports and export.

Import data in SAS from Excel. */;


PROC IMPORT OUT= WORK.t 
            DATAFILE= "E:\ECON5820\FTA\fta.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

*(You can create proc exports in similar way);*/
* for a spreadsheet use Excel 95 format;


1.       Describe the data:

-          How many variables/character/numeric? How many observations/ years?

-          What happened to exchange rate during this period? */;

proc contents data=fta;
  run;

  * 3621 observations, 49 variables, LABEL_S4 is a character variable;

  * Note exchr variable doesn't vary by industry, only by year, there are only 17 distinct values;

data exchrate;
 set fta;
 if sic4=1011 then output;
 keep year exchr;
 run;

proc sgplot data=exchrate;
 series X=year Y=exchr / Markers;
 title 'Exchange rate movement';
 run;
 

/*
2.     Construct trade intensity variable: MW/(GDP*1000), XW/(GDP*1000), (MW+XW)/(GDP**1000)

NOTE: GDP is in thousands, so Multiply GDP*1000

-          What is the average share of trade to GDP? Merge it back to the data

-          Construct average trade intensity by year. Merge it back to the data. */;

data  fta;
  set fta;
  mw_sh=MW/(GDP*1000);
  xw_sh=XW/(GDP*1000);
  tr_sh=(MW+XW)/(GDP*1000);
  run;

 proc univariate data=fta;
   var mw_sh xw_sh tr_sh;
   run;

proc means data=fta noprint;
  output out=avg  mean(mw_sh xw_sh tr_sh)=mw_sh_a xw_sh_a tr_sh_a;
    run;

data fta;
 if _N_=1 then set avg;
 set fta;
 run;

proc sort data=fta;
 by year;
 run;

proc means data=fta noprint;
  by year;
  output out=avgy  mean(mw_sh xw_sh tr_sh)=mw_sh_ay xw_sh_ay tr_sh_ay;
    run;

data fta;
  merge fta avgy;
  by year;
  run;

* EXTRA*;
data exchrate;
  merge exchrate avgy;
  by year;
  run;

proc sgplot data=exchrate;
 reg X=mw_sh_ay Y=exchr ;
 title 'Exchange rate movement';
 run;

proc sgplot data=exchrate;
 reg X=xw_sh_ay Y=exchr ;
 title 'Exchange rate movement';
 run;

proc sgplot data=exchrate;
 reg X=tr_sh_ay Y=exchr ;
 title 'Exchange rate movement';
 run;


/*
3.       Construct industry dummy variables. (How many industries are there? Use an array to construct the dummy variables)*/;

proc sort data=fta;
  by sic4;
  run;

proc means data=fta noprint;
  by sic4;
  output out=ind sum(mw)=mw;
  run;
* NEW;

data ind;
 set ind;
 count+1;
 run;

*______________________________;

proc sort data=fta;
  by year sic4;
  run;

data fta;
 set fta;
 by year sic4;
 if first.year=1 and first.sic4=1 then count=0;
 if first.sic4=1 then  count+1;
 run;

 data fta;
  set fta;
  array dum [*] sic4_1 -sic4_213;

  do i=1 to 213;
   if count=i then dum[i]=1; else dum[i]=0;
   end;
  run;


  /*
4.       Construct log MA and log XA to use as controls. */;

   data fta;
     set fta;
	 lma=log(MA);
     lxa=log(XA);
     run;
* Don't use lma lxa as controls!!!

/*5.       Write a simple macro that will run a regression for 3 dependent variables  MW/GDP, XW/GDP, (MW+XW)/GDP and 3 sets of independent variables:
*/;

/*
-          Just the exchange rate
-          Exchange rate and industry dummy variables
-          Exchange rate and industry dummy variables, log MA and log XA, TW
-          How do the estimates on exchange rate change? Are the signs on the exchange rate coefficient as expected?
*/;

%MACRO runreg(dep, indep);

proc reg data=fta;
  model &dep. =  &indep.;
  run;

 %MEND;

%runreg(mw_sh ,exchr);
%runreg(mw_sh ,exchr tw);
%runreg(mw_sh ,exchr tw sic4_1-sic4_212);


*Note with this ranking we get different groups of industries in each rank in each year. Ideally we should constract avg trade intensity by industry
and rank by it. In this case we'll have same industries in the same year;



/*6.       Divide industries in 2 groups based on trade openness (use (MW+XW)/GDP).  What is the average (MW+XW)/GDP in each of the groups?

Run regressions for each group separately. Is there a difference in the exchange rate effects between the groups?

*/;

proc rank data=fta out=fta groups=2; 
  var tr_sh;
  ranks rank;
  run;
  
%MACRO runreg2(dep, indep);

proc sort data=fta;
  by rank;
  run;

proc reg data=fta;
  by rank;
  model &dep. =  &indep.;
  run;

 %MEND;

%runreg2(mw_sh ,exchr);
%runreg2(mw_sh ,exchr tw);
%runreg2(mw_sh ,exchr tw sic4_1-sic4_212);



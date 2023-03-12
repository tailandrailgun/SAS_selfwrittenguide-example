*MAIN REFERENCE FILES;
*PROC MEANS  is used to calculate summary statistics such as mean, count etc of numeric; 
*variables. It requires at least one numeric variable whereas Proc Freq does not have such; 
*limitation. In other words, if you have only one character variable to analyse, PROC FREQ; 
*is your friend and procedure to use.;

*****proc means|*****;
*Var      : to select numeric variables you want to analyze;
*Class    : returns analysis for a grouping (classification) variable in a single table
            *do not have to be presorted;
*by       : returns the analysis for a grouping variable in separate tables
            *must be presorted;
*|||||||||||||||||||||Statistical Options|||||||||||||||||||||;
*N        : # of observations ;
*NMISS    : # of missingobservations ;
*MEAN     : mean lorh the one generated when we dont use any option, the arithmetic average ;
*STD      : standard deviation ;
*MIN      : minimum ;
*MAX      : maximum ;
*SUM      : sum of observations ;
*MEDIAN   : 50th percentile ;
*P1       : 1st percentile ;
*P5       : 5th percentile ;
*P10      : 10th percentile ;
*P90      : 90th percentile ;
*P95      : 95th percentile ;
*P99      : 99th percentile ;
*Q1       : 1st quartile ;
*Q3       : 3rd quartile ;
*VAR      : variance ;
*RANGE    : range ;
*USS      : uncorrelared sum of squares ;
*CSS      : correlated sum of squares ;
*STDERR   : standard error ;
*T        : student's t value for testing H0: md = 0;
*PRT      : p-value associated with t-test above;
*SUMWGT   : 99th percentile ;
*QRANGE   : 1st quartile ;
*NOLABELS : delete label column;
*NONOBS   : delete N, Obs column;

*|||||||||||||||||||||MEAN ANALYSIS BY A GROUPING VARIABLE|||||||||||||||||||||;
*Example;
*PROC MEANS DATA=DATA1 N NMISS NOLABELS;
*Class AGE;  *<<<<<how to do it is by using "Class"<<<<<;
*Var q1-q5;
*run;

*Example for analysis based on descending order of "age" variable;
*PROC MEANS DATA=DATA1 N;
*Class Age/descending;
*Var q1-q5;
*run;

*Example for generating analysis result by frequency order;
*PROC MEANS DATA=DATA1 N;
*Class Age/descending; *<<<<<add "Order = FREQ" behind "Class"<<<<<;
*Var q1-q5;
*run;

*|||||||||||||||||||||filter or subset data|||||||||||||||||||||;
*PROC MEANS DATA=DATA1 noprint;
*Where Q1 > 1; *<<<<<keeping only the observations in whicch value of Q1 is greater than 1<<<<<;
*Var q1-q5;
*run;

*|||||||||||||||||||||Sample T-Test|||||||||||||||||||||;
*Null Hypothesis - Population Mean of Q1 is equal to 0                   ;
*Alternative Hypothesis - Population Mean of Q1 is not equal to 0.       ;


*Example for running a t-test using proc means;
*PROC MEANS DATA=DATA1 t prt; *lowest level of significance at which we can reject 
                               null hypothesis. Since p-value is less than 0.05, 
                               we can reject the null hypothesis and concludes that 
                               mean is significantly different from zero.
*var Q1;
*run;

*************************************************************PRACTICE TEST 1*************************************************************
*a. How many observations are in the data set?; 
*b. how many variables are in data set?;
*c. which variables are numeric?
*d. which variables are character?
*e. how many distinct countries are in the data?;
*f. how many distinct industries are in the data?;
*g. calculate means of prod_growth and init_tar overall;
*h. calculate means of prod_growth and init_tar by country;
*i. calculate means of prod_growth and init_tar by industry;
*j. merge overall means back to the data;
*k. merge country(industry) means back to the data;
*i. regress prod_growth pn init_tar;
*m. rank countries by average initial tariff in two groups;
*n. repeat regression of prod_growth on init_tar for coountries with low initial tariffs and for high initial tariffs;
options linesize=78;

libname PT1 "D:\Desktop\5820FE";

*Create temporary data set*;
data data1;              *create new data name*;
  set PT1.test1a;        *set libname_created_above.data_file_name_in_folder *;
  run;
*a. #of_observations, b. #ofvariables, c. & d. numeric/character ;
proc contents data=data1;
  run;

*e. & f. distinct xxxxx in the data ;
proc freq data=data1;
  run;

***g. calculate_overall_mean_of_a_variable ;
proc means data=data1; *noprint;
output out=mean_init_tar mean(init_tar)=m_init_tar;
  run;

proc means data=data1; *noprint;
output out=mean_prod_growth mean(init_tar)=m__prod_growth;
  run;

************or ask SAS to show only sum,mean,N, excluding std.dev., Min&Max;
proc means data=data1 sum mean N; *noprint;
output out=sum_prod_growth sum(init_tar)=m__prod_growth;
  run;

*calculate_mean_of_a_variable_using_a_selected_grouping_variable;
*h. by country -- variable is named "wbcode";
*prod_growth;
proc sort data=data1;
  by wbcode;
  run;

proc means data=data1; *noprint;
  by wbcode;
  output out=mean_prod_growth_cty mean(prod_growth)=m_prod_growth_cty;
  run;

*init_tar;
proc sort data=data1;
  by wbcode;
  run;

proc means data=data1; *noprint;
  by wbcode;
  output out=mean_init_tar_cty mean(init_tar)=m_init_tar_cty;
  run;

*i. by industry;
*prod_growth;
proc sort data=data1;
  by industry;
  run;

proc means data=data1; *noprint;
  by industry;
  output out=mean_prod_growth_ind mean(prod_growth)=m_prod_growth_ind;
  run;

*init_tar;
proc sort data=data1;
  by industry;
  run;

proc means data=data1; *noprint;
  by industry;
  output out=mean_init_tar_ind mean(init_tar)=m_init_tar_ind;
  run;

*j. merge_overall_mean_back_to_data_set; *<<<<<no need to proc sort<<<<<;
*prod_growth;
data data1;
  if _N_=1 then set mean_prod_growth;
  set final;
  drop _type_ _freq_;
  run;

*init_tar;
data data1;
  if _N_=1 then set mean_init_tar;
  set final;
  drop _type_ _freq_;
  run;

*k. merge_country/industry_means_back_to_data_set; *<<<<<need to proc sort<<<<<;  
*prod_growth, country;
proc sort data=data1;
  by wbcode;
  run;

data data1;
  merge final mean_prod_growth_cty;
  by  wbcode;
  drop _type_ _freq_;
  run;
*init_tar, country;
proc sort data=data1;
  by wbcode;
  run;

data data1;
  merge final mean_init_tar_cty;
  by  wbcode;
  drop _type_ _freq_;
  run;
*prod_growth, industry;
proc sort data=data1;
  by industry;
  run;

data data1;
  merge final mean_prod_growth_ind;
  by  industry;
  drop _type_ _freq_;
  run;
*init_tar, industry;
proc sort data=data1;
  by industry;
  run;

data data1;
  merge final mean_init_tar_ind;
  by  industry;
  drop _type_ _freq_;
  run;

*l. regress_"prod_growth"_on_"init_tar";
proc reg data=data1;
  model prod_growth= init_tar;
  run;

*m. rank_countries_by_average_initial_tariff_in_two_groups;
proc rank data=data1 out=data1 groups=2;
*var mean_init_tar;
var m_init_tar_cty ;
ranks rank_mean_init_tar;
run;

*n.repeat_regression_of_"prod_growth"_on_"init_tar" for_countries_with_low initial_tariffs;
*and_for_high_initial_tariffs;
proc sort data=data1;
  by rank_mean_init_tar;
  run;

proc reg data=final;
  by rank_mean_init_tar;
  model prod_growth = init_tar;
  run;

***********************************************************************************************************************************
1. Describe data: how many variable (Num/Char), observations, how many years, groups, unique students
2. Take means of test scores by year, and by group and year. Is there are change over a time?
   Merge means from 2 back to the data
3. calculate correlation between test scores and number of hours spent wathcing TV and exercising.
4. Estimate OLS: regress test score on  number of hours spent wathcing TV and exercising.
- repeat 4, add year fixed effects (this controls for time trends)
- repeat 4, add year and group fixed effects (this controls for time trends and group-specific effects)
- repeat 4, add year, and student fixed effects (this controls for time trends, group-specific effects and student-specific fixed effect)
5. Divide students into 2 groups: high-performing and low performing. Estimate 4 for each subgroup. Is there a difference?;

options linesize=78;

libname PT3 "D:\Desktop\5820FE";

*Import_csv_data_set_into_SAS;
PROC IMPORT OUT= test3a 
            DATAFILE= "D:\Desktop\5820FE\Test3\SAS example data.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

*Create temporary data set*;
data data3;              *create new data name*;
  set WORK.test3a;       *set libname_created_above.data_file_name_in_folder *;
  drop var7 var8 var9; 
  run;
*1. There are 6 variables (Num=5/Char=1), 40 observations, 2 years (2020,2022),;
  * 2 groups (A,B), and 20 unique students;
proc contents data=data3;
  run;
proc freq data=data3;
  run;

*2. Mean by year: There is an increase from 75.35to 78.95 over time;
proc sort data=data3;
  by year;
  run;

proc means data=data3; *noprint;
  by year;
  output out=mean_score_year mean(score)=m_score_year;
  run;

*2. Mean by group and year: ;
  *For group A: There is an increase from 69.5 to 83.5 over time;
  *For group B: There is an decrease from 79.25 to approximately 75.92 over time;
proc sort data=data3;
  by group year;
  run;

proc means data=data3; *noprint;
  by group year;
  output out=mean_score_group_year mean(score)=m_score_group_year;
  run;

  *Merge means from 2 back to the data;
  *Merge Mean by year into data set;
proc sort data=data3;
  by year;
  run;

data data3;
  merge data3 mean_score_year;
  by year;
  drop _type_ _freq_;
  run;

  *Merge Mean by group and year into data set;
proc sort data=data3;
  by group year;
  run;

data data3;
  merge data3 mean_score_group_year;
  by group year;
  drop _type_ _freq_;
  run;

*3. calculate correlation between test scores and number of hours spent wathcing TV and exercising.;
*Answer: All 3 variables have a statistically significant relationship. I used alpha=0.05 as significanc lvl.;
  *score & TV      : r =  -0.59805, p <0.001; *Direction of relationship is (-), i.e. negatively correlated;
  *score & exercise: r =  0.81417 , p <0.001; *Direction of relationship is (+), i.e. positively correlated;
  *TV    & exercise: r =  -0.51975, p <0.001; *Direction of relationship is (-), i.e. negatively correlated;
proc corr data=data3;
  VAR score TV exercise;
  run;

*4. Estimate OLS: regress test score on  number of hours spent wathcing TV and exercising.;
proc reg data=data3;
 model score = TV exercise;
 run;
**********************************************DUMMIES Var.************************************************;
data data3;
 set data3;
***"year" dummy variable***;
 if year=2020 then d_2022=0;
 else if year=2022 then d_2022=1;
***"group" dummy variable***;  *(put "" around A & B cuz group is a CHAR variable);
 if group="A" then d_A=1;
 else if group="B" then d_A=0;
***"stud_id" dummy variable***; *(use array because there's 20 diff. student id;
 array sd[20] d_1 - d_20;
 do i=1 to 20;
   if stud_id=7000+i then sd[i]=1; else sd[i]=0;
     end;
  run;
 *stud_id_c=substr(stud_id,9,4);   *convert numerical variable into character;
 *stud_id_n=stud_id_c*1;           *convert character variable into numerical;

************************************************REGRESSIONS***********************************************;
*- repeat 4, add year fixed effects (this controls for time trends);
proc reg data=data3;
 model score = TV exercise d_2022;
 run;
*- repeat 4, add year and group fixed effects (this controls for time trends and group-specific effects);
proc reg data=data3;
 model score = TV exercise d_2022 d_A;
 run;
*- repeat 4, add year, and student fixed effects (this controls for time trends, group-specific effects and student-specific fixed effect);
proc reg data=data3;
 model score = TV exercise d_2022 d_A d_1 - d_19;
 run;

*MACRO;
%macro regr(indep);

proc reg data=data3;
   model score =&indep. ;
   run;
%mend;
%regr(TV exercise);
%regr(TV exercise d_2022 );
%regr(TV exercise d_2022 d_A);
%regr(TV exercise d_2022 d_1 - d_19);
 
*5. Divide students into 2 groups: high-performing and low performing. Estimate 4 for each subgroup. Is there a difference?;
proc rank data=data3 out=question5 groups=2;
 var score;
 ranks rank_s;
 run;

proc sort data=question5;
 by rank_s;
 run;
**************REGRESSION USING RANK VARIABLE CREATED*********************;
*You will see in the regression output -> Rank for Variable score=1;
*Estimate this again using "rank" -- 4. Estimate OLS: regress test score on  number of hours spent wathcing TV and exercising.;
proc reg data=question5;
 by rank_s;
 model score = TV exercise;
 run;

 ****EXTRA -- RANK & TTEST****
 ***T tests: 1st extra exercise is before Q3, 2nd is after Q5.***;
 ***Rank   : This extra is right after the original "rank" exercise;

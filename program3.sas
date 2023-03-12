*Practice test #3
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

libname PT3 "D:\Desktop\5820FE\Test3";

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
 ranks rank_s; *create a rank based on score;
 run;

proc sort data=question5;
 by rank_s;
 run;
**************REGRESSION USING RANK VARIABLE CREATED*********************;
*You will see in the regression output -> Rank for Variable score=1;
*Estimate this again using "rank" -- 4. Estimate OLS: regress test score on  number of hours spent wathcing TV and exercising.;
*remaining sub questions from Q4 -- do it accordingly, just that now we need to use this "rank_s" created;

proc reg data=question5;
 by rank_s; 
 model score = TV exercise;
 run;

****EXTRA FOR PRACTICE TEST 3 -- RANK & TTEST****;
***Rank   : This extra is right after the original "rank" exercise;
***T tests: 1st extra exercise is before Q3, 2nd is after Q5.***;

***Rank***
*Instead of ranking by score like above, this time it is by "student id", ranking by avg.score over 2 yrs.;
*data=options is not data3 anymore as we are not doing same ranking as Q5;
proc sort data=data3;
 by stud_id;
 run;
*This step is to find "Average score over 2 years for each student" as instructed in question.;
proc means data=data3 noprint;
 by stud_id;
 output out=mean_score_stud_id mean(score)=m_score_stud_id;
 run;

*The ranking step -- the main procedure for this question.;
proc rank data=mean_score_stud_id out=mean_score_stud_id groups=2; 
*Output into same dataset as there is meaning of having another, groups=options is 2 as we are still dividing; 
*students into 2 groups based on Q5; 
 var m_score_stud_id; *ranking by "score", we produced this when we were generating the mean;
 ranks rank_id; *create a rank that is related to student id;
 run;

*Q5's regression (as it asks us to estimate 4 for each subgroup -- Doing only main but not sub questions here;
*merge the new output from this extra exercise into our original dataset;
data data3;
 merge data3 mean_score_stud_id; 
 by stud_id;
 run;

*Like always, before regression we need to proc sort;
proc sort data=data3;
 by rank_id; *sorting the the dataset using new rank variable;
 run;

*Finally the regression;
proc reg data=data3;
 by rank_id;
 model score = TV exercise;
 run;

*****************************;
 *****T TEST FOR EXTRA*******;
  ***************************;
*To test whether the diff. in coefficients between 2 samples is statistically significant;
*Below: We are regressing using full sample with interaction terms "int_rank_tv" & "int_rank_ex".;
*If interaction terms are significant, then the difference is statistically significant;
*As for both interaction term, p-value is greater than alpha, we failed to reject the null hypothesis;
*Therefore, the difference in coefficients are NOT statistically significant;
*Also, as t-value (absolute value) of both terms are small (e.g. int_rank_ex's 1.43 means the difference ratio is only 1.43 between;
*2 sample;
*Note:if your sample size is big enough you can say that a t-value is significant if the absolute t value is higher or equal to 1.96;

data data3;
   set data3;
   int_rank_tv=rank_id*TV;
   int_rank_ex=rank_id*exercise;
   run;

proc reg data=data3;
 model score =rank_id TV int_rank_tv exercise int_rank_ex;
 run;

*****************************;
 *****T TEST FOR BEFORE Q3***;
  ***************************;
*_____________________________________________*;
   *PROC TTEST;
*- use it to check if the differences between years
 (groups etc) are statistically significant ;
   * t value is below -2 or higher 2 indicates statistically significant
   difference;

   * difference across years;

   proc ttest data=test3.scores;
     class year;
	 var score;
	 run;

   * difference across groups;

   proc ttest data=test3.scores;
    class group;
	var score;
	run;


    * difference across groups by year;

	proc sort data=test3.scores;
	  by year;
	  run;

	proc ttest data=test3.scores;
	by year;
    class group;
	var score;
	run;


    * difference across years by groups;
	
	proc sort data=test3.scores;
	  by group;
	  run;

	proc ttest data=test3.scores;
	by group;
    class year;
	var score;
	run;




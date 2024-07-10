LIBNAME ClasData 'Class Data';

/* Skip
PROC IMPORT OUT= ClasData.SALESEXPERIMENT 
            DATAFILE= "Sales Information Advice Experiment Data.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 GUESSINGROWS=600;
RUN;
*/

/* Create a working dataset so that we don't accidently alter the original data */
data SalesExperiment;
 set ClasData.SalesExperiment;
run; 

/* Check the data under libraries to understand the data structure */

/* Summary Statistics using PROC means */
proc means data= SalesExperiment n mean stddev min p25 median p75 max maxdec= 2;
 var CustomerNeed SalesInfoAdvice CustomerDecision;
 title 'Summary Statistics1';
run;
* Customerneeds 25-75th percentiles are symmetric because this was generated;
* Salesinfoadvice: more mass on the righ;
* Customerdecision: more mass on the left;

* Now, we want to look at these summary statistics by 2 (report type) x 2 (repeated) conditions;
* Class has to be categorial;
proc means data= SalesExperiment n mean stddev min p25 median p75 max maxdec= 2;
 class ReportType Repeated;
 var CustomerNeed SalesInfoAdvice CustomerDecision;
 title 'Summary Statistics';
run;
* Salesinfoadvice may be statistically different --> check later;

* We want to check to see if these change from one round to another round;
proc means data= SalesExperiment n mean stddev min p25 median p75 max maxdec= 2;
 class ReportType Repeated Round;
 var CustomerNeed SalesInfoAdvice CustomerDecision;
 title 'Summary Statistics';
run;

* We might want to break up the table by certain variables. Then we need to sort by those variables first;
proc sort data=SalesExperiment;
 by Repeated ReportType; *Sort variables that will be used with "by" later;
run;
proc means data=SalesExperiment;
 var CustomerNeed SalesInfoAdvice CustomerDecision;
 by Repeated ReportType;
run;

* Try at home;
/* data must be sorted appropriately before using a 'by' statement in proc means or other procs */
proc sort data=SalesExperiment;;
 by Repeated;
run;
* Try at home;
/* by statement creates separate tables for all levels (and combinations) of the by variables */ 
proc means data= SalesExperiment n mean stddev min p25 median p75 max maxdec= 2;
 by Repeated; 
 class ReportType;
 var CustomerNeed SalesInfoAdvice CustomerDecision;
 title 'Summary Statistics';
run;

/* You can store output from any SAS command or set of commands in a RTF file to copy to another report */
ODS RTF FILE='Summary Stats.rtf';
proc means data= SalesExperiment n mean stddev min p25 median p75 max maxdec= 2;
 by Repeated;
 class ReportType;
 var CustomerNeed SalesInfoAdvice CustomerDecision;
 title 'Summary Statistics';
run;
ODS RTF CLOSE; 
* Show this file. And then convert RTF to Word file later.;

/* Another way for summary statistics that is more flexible than proc means ==> Summary Statistics using PROC tabulate */
* proc tabulate needs 'table' command;
proc tabulate data= SalesExperiment ;
 var CustomerDecision; *variables described by the table; 
 table CustomerDecision; /* Default is the sum if no statistics are defined*/
 title 'Sum of CustomerDecision';
run;

proc tabulate data= SalesExperiment ;
 var CustomerDecision; *variables described by the table; 
 table CustomerDecision*(N Mean StdDev Min p25 Median p75 Max); *same stats for the var;
 title 'Summary Statistics of CustomerDecision';
run;

* Variable name (CustomerDecision) from column to row using ',';
proc tabulate data= SalesExperiment ;
 var CustomerDecision; *variables described by the table; 
 table CustomerDecision,N Mean StdDev Min p25 Median p75 Max; 
 title 'Summary Statistics of CustomerDecision';
run;

* Add more vars, with variables in rows and statistics in columns;
proc tabulate data= SalesExperiment ;
 var CustomerNeed SalesInfoAdvice CustomerDecision; *variables described by the table; 
 table CustomerNeed SalesInfoAdvice CustomerDecision,N Mean StdDev Min p25 Median p75 Max; 
 title 'Summary Statistics';
run;

* Add class (think of this as "group by"). In table, add class vars with * (or break down by);
proc tabulate data= SalesExperiment ;
 class Repeated ReportType; 						*categorical variables for breakdown of variable summaries;
 var CustomerNeed SalesInfoAdvice CustomerDecision; *variables described by the table; 
 table Repeated*ReportType*(CustomerNeed SalesInfoAdvice CustomerDecision),N Mean StdDev Min p25 Median p75 Max; 
 title 'Summary Statistics';
run;

/* Bottom line: Use * to breakdown row or column further. Use , to split row and colum variables */

* Repeated across row, reporttype across columns;
proc tabulate data= SalesExperiment ;
 class Repeated ReportType; *categorical variables for breakdown of variable summaries;
 var CustomerNeed SalesInfoAdvice CustomerDecision; *variables described by the table; 
 table Repeated*(CustomerNeed SalesInfoAdvice CustomerDecision),ReportType*(N Mean StdDev Min p25 Median p75 Max); 
 title 'Summary Statistics';
run;

* Repated x round across row, reporttype across columns;
proc tabulate data= SalesExperiment ;
 class Repeated ReportType Round; *categorical variables for breakdown of variable summaries;
 var CustomerNeed SalesInfoAdvice CustomerDecision; *variables described by the table; 
 table Repeated*Round*(CustomerNeed SalesInfoAdvice CustomerDecision),ReportType*(N Mean StdDev Min p25 Median p75 Max); 
 title 'Summary Statistics';
run;


/* Try at home */
proc tabulate data= SalesExperiment ;
 class TreatmentId Round; *categorical variables for rows and columns;
 table TreatmentId, Round; 
 title 'Frequencies of Observations by Treatment and Round';
run;

proc tabulate data= SalesExperiment ;
 class TreatmentId Round; *categorical variables for rows and columns;
 var CustomerDecision; *variables described by the table; 
 table TreatmentId, CustomerDecision*Round; 
 title 'Total of CustomerDecision by Treatment and Round ';
run;


/* Descriptive Analysis using PROC univariate: all kinds of additional stats and histograms reported */
proc univariate data= SalesExperiment;
 var CustomerDecision;
 title 'Summary Statistics for Customer Decision-Class';
run;

/* class = "grouped by". You can also add histograms */
proc univariate data= SalesExperiment;
 *class Repeated ReportType;
 var CustomerDecision;
 histogram CustomerDecision; /* Plot histograms by classes */
 title 'Summary Statistics for Customer Decision-Class';
run;
/* Important: proc univarite provides much more information than proc means, such as skewness, kurtosis, interquantile range, etc. */
/* 
1) Skewness is a measure of symmetry, or more precisely, the lack of symmetry. A distribution, or data set, 
is symmetric if it looks the same to the left and right of the center point. 
Skewness of Normal distribution is 0 because it's symmetric.

2) Kurtosis is a measure of whether the data are heavy-tailed or light-tailed 
relative to Normal distribution. That is, data sets with high kurtosis 
tend to have heavy tails, or outliers.*/



/******************* PLOTTING ****************************************/
/* Descriptive Analysis using PROC sgplot and sgpanel; */

/* Box Plots */
* Need '/' here;
proc sgplot data= SalesExperiment;
 hbox SalesInfoAdvice / category= Repeated group= ReportType ; 
 title 'Sales Report';
run;
/* Circle in the box is the mean, and the line in the box is the median. The box itself 
is between Q1 (25th percentile) and Q3 (75th percentile) */

/* Histograms */
proc sgplot data= SalesExperiment;
 histogram CustomerDecision / binstart = 10 binwidth = 5 ; 
 density CustomerDecision; 						* Just Normal distribution;
 density CustomerDecision / type = kernel;		* Kernel smoothing;
 title 'Customer Decision';
run;
* Normal is normal distribution approximation. Kernel is smoothing of histogram;

/* (Time) Series plots */
/* Before that, we want to calculate the average of each individual round. But sort first.
And then calculate the averages and save it to a SAS table called "means" */
proc sort data= SalesExperiment; 
 by Repeated ReportType Round;
run;
proc means data= SalesExperiment mean maxdec= 2 noprint;
 by Repeated ReportType Round;
 var CustomerNeed SalesInfoAdvice CustomerDecision;
 output out=means 
  		mean= AvgCustomerNeed AvgSalesInfoAdvice AvgCustomerDecision;
run;
/* Check out means data table  under Work library first. */

/* Let's plot it over time. 
	Note that I calculate the average first, create means data, and then plot the average.
	We use sgpanel, not sgplot since it's a time series*/
proc sgpanel  data= means;
 panelby Repeated ReportType;
 series x=Round y=AvgCustomerDecision;
 title 'Customer Decision by Decision Round';
run;


/* Scatter Plots */
proc sgplot data = SalesExperiment;
 scatter X=CustomerNeed Y=SalesInfoAdvice; 
 title 'Customer Need and Sales Report';
 label SalesInfoAdvice = 'Sales Report' CustomerNeed = 'Customer Need'; 
run;
/* If you want multiple scatter plots, use sgpanel with 'panelby' */
proc sgpanel data= SalesExperiment;
 panelby ReportType Repeated;
 scatter X=CustomerNeed Y=SalesInfoAdvice ; 
 title 'Customer Need and Sales Report';
 label CustomerNeed= 'Customer Need' SalesInfoAdvice = 'Sales Report'; 
run;
* When giving advice (AP), the max. was 200. When giving info (IS), the max. was 80. 
* Although AP is inflated, the slope is more positive (i.e., more informative). Will formally test in hyp. tests;

* Skip;
proc sgpanel data= SalesExperiment;
 panelby ReportType Repeated;
 scatter X=SalesInfoAdvice Y=CustomerDecision ; 
 title 'Sales Report and Customer Decision';
 label CustomerDecision = 'Customer Decision' SalesInfoAdvice = 'Sales Report'; 
run;

* Scatter matrix (scatter plots with more than 2 variables);
proc sgscatter data= SalesExperiment;
 matrix CustomerNeed SalesInfoAdvice CustomerDecision ; /* / diagonal= (histogram)*/
 title 'Relation between Customer Need, Sales Report and Customer Decision';
run;

* A faster way to create scatter matrix + correlation matrix --> Use proc corr;
proc corr data= SalesExperiment plots=matrix(histogram);
 var CustomerNeed SalesInfoAdvice CustomerDecision;
 title 'Relation between Customer Need, Sales Report and Customer Decision';
run;


/* Fitted Lines */
* Take out reg first and run to show scatter. Then add 'reg';
proc sgpanel data= means;
 panelby ReportType;
 scatter x=AvgCustomerNeed y=AvgCustomerDecision /group= Repeated;
 reg X=AvgCustomerNeed Y=AvgCustomerDecision /group= Repeated ; 
 title 'Average Customer Decision by Decision Round';
run;
* Different slopes for AP, whereas they're similar for info (IS).

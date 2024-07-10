LIBNAME ClasData 'Class Data';

/* Create working dataset with additional variables */
data SalesExperiment;
 set ClasData.SalesExperiment;
 HiNeed = CustomerNeed > 45;
 HiInfoAdvice = SalesInfoAdvice > 45;
 HiOrder = CustomerDecision > 45;
run; 


/* Hypothesis Tests */

/* Contingency Table and Chi-Square Test of Independence */

/* Is HiInforAdvice related to HiNeed? (cross tab)*/
proc freq data=SalesExperiment;
 tables HiNeed * HiInfoAdvice;
run;


ODS RTF FILE='Chi-Sq.rtf';
proc freq data=SalesExperiment;
 tables HiNeed * HiInfoAdvice/ChiSq;
run;
ODS RTF CLOSE;

/*
If you have issues with showing table and plot outputs with the proc commands, it may be because the SAS server has graphics off. 
To fix this problem, simply add these three lines at the top of your code:

ODS HTML
ODS LISTING CLOSE
ODS GRAPHICS ON

To understand what ODS is, you can check out the following link:
https://documentation.sas.com/?docsetId=odsug&docsetTarget=part-5.htm&docsetVersion=9.4&locale=en
*/

/* Hypothesis test for each treatment / experimental condition
	Treatmentid = 1: 1 off /Information (IS)
	Treatmentid = 2: 1 off /Advice (AP)
	Treatmentid = 4: Repeated /Information (IS)
	Treatmentid = 5: Repeated /Advice (AP)
*/
proc freq data=SalesExperiment;
 tables TreatmentId * HiNeed * HiInfoAdvice/ChiSq;
run;


/* Correlation test */
/* Is SalesInfoAdvice related to CustomerNeed?... Customer Decision to SalesInfoAdvice? */
ODS RTF FILE='Correlation.rtf';
proc corr data=SalesExperiment;
 var CustomerNeed SalesInfoAdvice CustomerDecision;
run;
/* Check correlation for each Repeated-ReportType. Sort first. */
proc sort data=SalesExperiment;;
 by Repeated ReportType;
run;
proc corr data=SalesExperiment;
 var CustomerNeed SalesInfoAdvice CustomerDecision;
 by Repeated ReportType;
run;


/* By default SAS uses pearson correlation*/
/* Pearson correlation is ideally meant to test for linear relationships */
/* It can give incorrect or inconsistent results if there is a non-linear relationship - especially non-monotonic relationship*/
/* Do exploratory analysis first */

/* Spearman correlation is less sensitive to departures from linear relation (note 'spearman'). Good for ordinal variables */
/* But is not a complete solution - can still have problems with non-monotonic relationship */
proc corr data=SalesExperiment spearman;
 var CustomerNeed SalesInfoAdvice CustomerDecision;
 by Repeated ReportType;
run;
ODS RTF CLOSE;

ODS RTF FILE='T-Tests.rtf';

proc sort data=SalesExperiment; 
by Repeated ReportType;
run;

/* Single Sample T-Tests */
/* Ha: (avg of) CustomerNeed > 45? SalesInfoReport > 45? CustomerDecision > 45?
   	One-sided test. U means a parameter value is greater than the null value in the alternative hypothesis 
	(e.g., Ha: customerneed > 45) */
proc ttest data=SalesExperiment H0=45 sides=U; 
 var CustomerNeed SalesInfoAdvice CustomerDecision;
 *by Repeated ReportType; /* Test 3 vars simultaneously, by each of Repeated x ReportType conditions */
run;

/* Paired Sample T-Tests */
/* Is SalesInfoReport = CustomerNeed ? */
proc ttest data=SalesExperiment; 	*two-sided test as default. H0: CustomerNeed=SalesInfoAdvice;
 paired CustomerNeed*SalesInfoAdvice;  *paired;
 *by Repeated ReportType;
run;

/* Two-sample T-Tests */
/* Is SalesInfoReport for IS (Information Sharing) = SalesInfoReport for AP (Advice Provision)? */
proc ttest data=SalesExperiment;
 class ReportType;
 var SalesInfoAdvice;
 *by Repeated;
run;
* If Equality of variance p-value < 0.05, interpret Satterthwaite Method results. Otherwise, interpret Pooled Method results;
ODS RTF CLOSE;

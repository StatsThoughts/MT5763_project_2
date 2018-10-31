/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*This is a small SAS program to perform nonparametric bootstraps for a regression
/*The code has been modified to be more efficent than the previous version 								*/
/*Inputs: 																								*/
/*	- NumberOfLoops: the number of bootstrap iterations 												*/
/*	- Dataset: A SAS dataset containing the response and covariate										*/
/*	- XVariable: The covariate for our regression model (gen. continuous numeric)						*/
/*	- YVariable: The response variable for our regression model (gen. continuous numeric)				*/
/*Outputs:																								*/
/*	- RTF graphics that include the four following images 												*/
/*		* A table containing the estimate and 95%CI for the intercept coefficent 						*/
/*		* A table containing the estimate and 95%CI for the slope coefficent 							*/
/*		* A histogram of the intercept coefficent estimates												*/
/*		* A histogram of the slope coefficent estimates													*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
%macro regBoot(NumberOfLoops, DataSet, XVariable, YVariable);

	/*Number of rows in my dataset*/
 	DATA _null_;
  	SET &DataSet NOBS=size;
  	CALL symput("NROW",size);
 	STOP;
 	RUN;

	/*Gets rid of one sample to add in the original linear regression to the bootstrap */
	%LET NumberOfLoops = %eval(&NumberOfLoops - 1);
	
	/*Sampiling the data in one go*/
	PROC SURVEYSELECT DATA = &DataSet  OUT = sampleHolder
	METHOD = urs SAMPSIZE = &NROW REP = &NumberOfLoops NOPRINT OUTHITS;
	RUN;

	/*Building the models*/
	PROC REG DATA = sampleHolder outest = regEsts noprint;
	MODEL &YVariable = &XVariable;
	BY replicate;
	RUN;
	
	/*Original model based on data. No resampiling*/ 
	PROC REG DATA = sampleHolder outest = OGregEsts noprint;
	MODEL &YVariable = &XVariable;
	RUN;
	
	/*Append the original linear regression to resamples results*/
	PROC append base=regEsts data=OGregEsts;
	RUN;

	/*95%CIs of intercept and slope*/
	ods select Histogram;
	PROC UNIVARIATE DATA = regEsts NOPRINT;
	VAR &XVariable Intercept;
	OUTPUT out = CI95Per pctlpts=2.5, 97.5 pctlpre= &XVariable Intercept pctlname=Lower95 Upper95;
	RUN;
	
	/*Mean Estimates of intercept and slope*/
	DATA CI95Per; 
	MERGE CI95Per OGregEsts (keep = Intercept Age);
	RENAME Intercept = InterceptEstimate Age = AgeEstimate; 
	RUN;

	ODS RTF;

	/*Prints the Mean Estimates and CIs*/
	PROC PRINT DATA  = CI95Per;
	VAR AgeLower95 AgeUpper95  AgeEstimate;
	TITLE "95% CI for &XVariable coefficent";
	RUN;

	PROC PRINT DATA  = CI95Per;
	VAR InterceptLower95 InterceptUpper95 InterceptEstimate;
	TITLE '95% CI for Intercept coefficent';
	RUN;
	
	/*Histograms of intercept and slope*/
	PROC gchart DATA = regEsts; 
  	VBAR &XVariable;
	TITLE "Histogram for &XVariable coefficent";
 	RUN;

	PROC gchart DATA = regEsts;
	VBAR intercept;
	TITLE 'Histogram for Intercept coefficent';
	RUN;
	ODS RTF CLOSE;

	/*Cleans up temporary datasets*/ 
	PROC DATASETS library=work NOPRINT;
	DELETE ci95per ogregests regests sampleHolder;
	RUN;

%mend;


/* Start timer */
/*%let startTime = %sysfunc(datetime());*/
/*RUN;*/

options nonotes;
/*Run the macro*/
%regBoot(NumberOfLoops=100, DataSet=MT5763.Fittness, XVariable=Age, YVariable=Oxygen);


/* Stop timer */
/*data _null_;*/
/*  timeElapsed = datetime() - &startTime;*/
/*  put timeElapsed time13.2;*/
/*run;*/

/*Dataset is fittness, X = Age, Y = Oxygen, 100 iterations*/
/*Original base program takes 35.24s to run before changes*/
/*After the change, program takes 2.39s to run which includes generating but not outputing the RTF Files*/
/*Note with addition of RTF graphics, takes 6.41s*/

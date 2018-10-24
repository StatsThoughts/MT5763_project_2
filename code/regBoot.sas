/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*This is a small SAS program to perform nonparametric bootstraps for a regression
/*It is not efficient nor general*/
/*Inputs: 																								*/
/*	- NumberOfLoops: the number of bootstrap iterations
/*	- Dataset: A SAS dataset containing the response and covariate										*/
/*	- XVariable: The covariate for our regression model (gen. continuous numeric)						*/
/*	- YVariable: The response variable for our regression model (gen. continuous numeric)				*/
/*Outputs:																								*/
/*	- ResultHolder: A SAS dataset with NumberOfLoops rows and two columns, RandomIntercept & RandomSlope*/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
%macro regBoot(NumberOfLoops, DataSet, XVariable, YVariable);
	/*Number of rows in my dataset*/
 	DATA _null_;
  	SET &DataSet NOBS=size;
  	CALL symput("NROW",size);
 	STOP;
 	RUN;
	
	/*Sampiling the data in one go*/
	PROC SURVEYSELECT DATA = &DataSet  OUT = sampleHolder
	METHOD = urs SAMPSIZE = &NROW REP = &NumberOfLoops NOPRINT OUTHITS;
	RUN;
	
	/*Building the models*/
	PROC REG DATA = sampleHolder outest = regEsts noprint;
	MODEL &YVariable = &XVariable;
	BY replicate;
	RUN;
	
	/*Extracting the estiamtes*/
	DATA coeffs;
	SET regEsts;
	KEEP &XVariable Intercept;
	RUN; 

	/*outputs*/
	PROC UNIVARIATE DATA = coeffs;
	VAR &XVariable Intercept;
	OUTPUT out = CI95Per pctlpts=2.5, 97.5 pctlpre=CI;
	RUN;

	
%mend;


/* Start timer */
%let startTime = %sysfunc(datetime());
RUN;

options nonotes;
/*Run the macro*/
%regBoot(NumberOfLoops=100, DataSet=MT5763.Fittness, XVariable=Age, YVariable=Oxygen);


/* Stop timer */
data _null_;
  timeElapsed = datetime() - &startTime;
  put timeElapsed time13.2;
run;

/*Base program takes 35.24s to run before changes*/
/*Dataset is fittness, X = Age, Y = Oxygen, 100 iterations*/
/*After the change, program takes 00.36s to run */

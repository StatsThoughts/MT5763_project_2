# MT5763_project_2

Welcome to the repository for the MT5763 Group Project for team Sharknado 5: Global Swarming

## Documentation for R Script

## Documentation for SAS Script
The script for the code can be found linked [here](https://github.com/StatsThoughts/MT5763_project_2/blob/master/code/regBoot.sas). 

The purpose of this script is to generate a number of bootstrap resamples for a linear regression model for a single covariate. In the comments also contains the timing mechnisim to time how fast the SAS script ran. 

In this code, there is only a single function/SAS MACRO defined below. 

### regBoot
The purpose of this function is to generate bootstrap resamples for a linear regression model for a single covariate. The function has the following arguments 
* **NumberOfLoops** - an interger value containing the number of bootstrap resamples to be done in the function. Must be greater than 1.  Note one bootstrap resample will include the original data without resampiling with replacement. 
* **DataSet** - a SAS table containing observations for the response and covariate given in XVariable and YVariable 
* **XVariable** - The covariate of the regression model given as a variable name from DataSet table
* **YVariable** - The response of the regression model given as a variable name from DataSet table

To use the file, call the macro %regBoot() with parameters defined following the requirements stated above. 

## Speed increases in Code Changes

Below is a plot showing the changes in speed for our code after each major code change for SAS. For the SAS code, the code went through two major iterations. The "Original Version" is the orignal SAS bootstrapping code provided for the project. The  "Optimized Version" is the version after changing and enhancing the orignal SAS bootstrapping code. The "Added RTF Outputs" change added outputs the RTF outputs in the format specified for the project, and added an enhancement to ensure that at least one of the bootstrap resamples included the orginal linear model. 

![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/SAS%20Time%20Plots.png)



# MT5763_project_2

Welcome to the repository for the MT5763 Group Project for team Sharknado 5: Global Swarming

## Documentation for R Script
The script for the code can be found liked [here](https://github.com/StatsThoughts/MT5763_project_2/blob/master/code/lmBoot.R).

### lmBoot
The purpose of this function is to generate bootstraps for a linear regresion model for any number of covariates. The output of the function is a single matrix which contains covariate estimates for each bootstrapped resample of the data.

The function takes the following arguments:
* **inputData** - A dataframe containing observations for each of the covariates and the response
* **nBoot** - An integer detailing the number of bootstrapped resamples to generate
* **response** - String matching a column name from inputData dictating which variable should be treated as the response
* **myclust** - Optional argument, cluster defined using library(parallel) will run faster using multiple multiple cores from the specified cluster

The function performs a bootstrap by first sampling from the data with replacement, finding the parameter estimates for the resampled data and then storing these in a matrix, this is repeated 'nBoot' times and then the matrix is outputted. 

To use the function call lmBoot() with inputs as defined above. 

## Speed increase in Code Changes

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

Below is a plot showing the changes in speed for our code after each major code change for SAS. For the SAS code, the code went through two major iterations. The "Original Version" is the orignal SAS bootstrapping code provided for the project. The  "Optimized Version" is the version after changing and enhancing the orignal SAS bootstrapping code. The "Added RTF Outputs" change added the RTF outputs in the format specified for the project, and added an enhancement to ensure that at least one of the bootstrap resamples included the orginal linear model. 

![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/SAS%20Time%20Plots.png)

## Documentation for example analysis in R 
The purpose of the part is using an examaple data set to run our bootstrap function and using the result to illustrate how it works. 
In this part, we focus on R code. 

### Example data set 
We are using the data set provided by R base called "trees" in both R and SAS example analysis. The data is about the girth, height and volume for Black Cherry Trees, so there are three columns in the data are "Girth", "Height" and "Volume". 
 
  
### Analyse 
Firstly, we plot the data and we got the result as shown below. 

![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/trees_plot.png)

Then we used the data set and call our bootstrap, to run it 1000 times. The response variable we set is parameter "Height". So we can get the result - the coefficient value from our bootstrap. Firstly, we extracted the number for input data set which is the first line from the output. Then we can calculate the mean value for the rest of the data. Roughly, we can tell there is not a huge difference between the truth and estimated value. 

\documentclass[UTF8]{ctexart}
\begin{document}
\begin{tabular}{lr}
我是& 一只\\
表格君& 咿呀咿呀哟
\end{tabular}
\end{document}





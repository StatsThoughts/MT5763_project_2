# MT5763 Project 2

Welcome to the repository for the MT5763 Group Project for team Sharknado 5: Global Swarming

## Documentation for R Script
The script for the code can be found liked [here](https://github.com/StatsThoughts/MT5763_project_2/blob/master/code/lmBoot.r).

### lmBoot
The purpose of this function is to generate bootstraps for a linear regression model for any number of covariates. The output of the function is a single matrix which contains covariate estimates for each bootstrapped resample of the data.

The function takes the following arguments:
* **inputData** - A dataframe containing observations for each of the covariates and the response
* **nBoot** - An integer detailing the number of bootstrapped resamples to generate
* **response** - String matching a column name from inputData dictating which variable should be treated as the response
* **myclust** - Optional argument, cluster defined using library(parallel) will run faster using multiple multiple cores from the specified cluster

The function performs a bootstrap by first sampling from the data with replacement, finding the parameter estimates for the resampled data and then storing these in a matrix, this is repeated 'nBoot' times and then the matrix is outputted. 

To use the function call lmBoot() with inputs as defined above. 

## Speed increase in Code Changes

### Speed changes in different versions of lmBoot

The plot below shows the change in speed from the first iteration to the last as well as the boot function from R package 'boot'. Interestingly there is a large time increase when the for loop is changed to a sapply within the function and even larger time increase when the clusters are initially defined within the function. However once parallelisation was properly added, with the option to use clusters defined outside of the function, the function runs much faster (if the cluster used is defined outside of the function, otherwise there is no time change).

![lmBoot_timings](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/lmBoot_timings.png)


### Microbenchmarking

The plot below details the microbenchmark results comparing the lmBoot.R function to the boot function in the R package 'boot'. The timings were produced from running the functions 50 times producing 1000 bootstrap samples each time. 

![microbenchmark_plot](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/Microbenchmark.png)

## Documentation for SAS Script
The script for the code can be found linked [here](https://github.com/StatsThoughts/MT5763_project_2/blob/master/code/regBoot.sas). 

The purpose of this script is to generate a number of bootstrap resamples for a linear regression model for a single covariate. In the comments also contains the timing mechanism to time how fast the SAS script ran. 

In this code, there is only a single function/SAS MACRO defined below. 

### regBoot
The purpose of this function is to generate bootstrap resamples for a linear regression model for a single covariate. The function has the following arguments 
* **NumberOfLoops** - an integer value containing the number of bootstrap resamples to be done in the function. Must be greater than 1.  Note one bootstrap resample will include the original data without resampling with replacement. 
* **DataSet** - a SAS table containing observations for the response and covariate given in XVariable and YVariable 
* **XVariable** - The covariate of the regression model given as a variable name from DataSet table
* **YVariable** - The response of the regression model given as a variable name from DataSet table

To use the file, call the macro %regBoot() with parameters defined following the requirements stated above. 

## Speed increases in Code Changes

Below is a plot showing the changes in speed for our code after each major code change for SAS. For the SAS code, the code went through two major iterations. The "Original Version" is the orignal SAS bootstrapping code provided for the project. The “Optimized Version" is the version after changing and enhancing the orignal SAS bootstrapping code. The "Added RTF Outputs" change added the RTF outputs in the format specified for the project, and added an enhancement to ensure that at least one of the bootstrap resamples included the orginal linear model. 

![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/SAS%20Time%20Plots.png)

## Example Analyses 
The purpose of the part is to use an example data set to run our bootstrap function and illustrate how the bootstrap function works. 
We are using the data set provided by base R called "trees" in both R and SAS example analysis. The data is about the girth, height and volume for Black Cherry Trees. There are three columns in the data: "Girth", "Height" and "Volume”. The data can be found in the repo [here](https://github.com/StatsThoughts/MT5763_project_2/blob/master/data/trees.csv)

### R Analysis 
For our analysis, we modeled the Height based on a linear model with covariates Girth and Volume. The code used for the analysis below is found [here](https://github.com/StatsThoughts/MT5763_project_2/blob/master/code/Example%20analysis.R). 

Firstly, we plotted the data and obtained the result shown below. 

![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/trees_plot.png)

Then, using the dataset, we conducted a bootstrap with 1000 resamples on the model defined above. The output from the function was a dataframe containing all the coefficient estimates from each bootstrap resample. The histograms give us a visual representation of the shape of the distribution for the coefficients. 

![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/intercept.png)
![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/Grith_plot.png)
![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/Volume_plot.png)

From our bootstrap results, we can construct the two-sided 95% confidence interval for the Intercept, Girth and Volume coefficients. This is done by finding the 2.5% and 97.5% percentiles of the bootstrap results for Intercept, Girth and Volume coefficients respectively. These results are illustrated below:

 |     | 2.5% | 97.5% |
---   |     ---   | ---   | 
Intercept |   62.0259   | 102.5396 | 
Girth | -4.2716 | 0.8232 | 
Volume | 0.1122 | 1.0518 | 

From these results, we can conclude the 95% confidence intervals for the intercept to be [62.0259, 102.5396], Girth to be [-4.2716, 0.8232] and volume to be [0.1122, 1.0518]. Since the confidence interval for Girth contains 0, we can conclude that Girth does not appear to have a significant effect in the model. 


### SAS Analysis 

plotted the data overall
![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/trees_plot%20for%20SAS.png)

The histogram for Girth and Intercept
![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/Histogram%20for%20Girth%20coefficient.png)

![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/Histogram%20for%20Intercept%20coefficient(with%20Girth).png)

The histogram for Volume and Intercept
![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/Histogram%20for%20Volume%20coefficient.png)

![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/Histogram%20for%20Intercept%20coefficient(with%20Volume).png)

CI for Girth and Intercept
![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/95%25%20CI%20for%20Girth%20and%20Intercept.png)

CI for Volume and Intercept
![fig 1](https://github.com/StatsThoughts/MT5763_project_2/blob/master/Plots/95%25%20CI%20for%20Volume%20and%20Intercept.png)

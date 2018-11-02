#-------------------------------------- example analysis ----------------------------------#
library(tidyverse)
plot(trees, col = 'purple')
dataMean <- c(mean(trees[,1]), mean(trees[,2]), mean(trees[,3]))

testResult <- lmBoot(trees, 1000, response = "Height")
plot(testResult)
hist(testResult[,1], col = "slateblue4", main = 'intercept distribution')
hist(testResult[,2], col = "slateblue4", main = 'slope distribution')
hist(testResult[,3], col = "slateblue4", main = 'slope distribution')

inputCoef <- testResult[1, ]
testMean <- c(mean(testResult[,1]), mean(testResult[,2]), mean(testResult[,3]))











rbind(quantile(testResult[,1], probs = c(0.025, 0.975)),
      quantile(testResult[,2], probs = c(0.025, 0.975)),
      quantile(testResult[,3], probs = c(0.025, 0.975)))

plot(testResult[,1])
plot(testResult[,2])
plot(testResult[,3])



lmBoot <- function(inputData, nBoot, response = NA, myClust) {
  #Inputs: 
  #inputData - The data that you wish to boostrap on
  #nBoot - The number of bootstraps to use
  #response - The response variable that you are interested in. No input means first column
  #clusterType - Passes to type of cluster n makeCluster 
  #NOTE: Will fit a model of response against all other columns in the 
  #      inputted data frame, if you wish to fit more specific models
  #      then input a subsetted data frame
  
  
  
  
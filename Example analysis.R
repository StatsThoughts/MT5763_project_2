#-------------------------------------- example analysis ------------------------------------------#
library(tidyverse)
plot(trees, col = 'purple')
# dataMean <- c(mean(trees[,1]), mean(trees[,2]), mean(trees[,3]))

testResult <- lmBoot(trees, 1000, response = "Height")
plot(testResult)
hist(testResult[,1], col = "slateblue4", main = 'intercept distribution')
hist(testResult[,2], col = "slateblue4", main = 'slope distribution')
hist(testResult[,3], col = "slateblue4", main = 'slope distribution')

# coef number for input data
inputCoef <- testResult[1, ]

# mean coef number for resampled data
testMean <- c(mean(testResult[2:1000,1]), mean(testResult[2:1000,2]), mean(testResult[2:1000,3]))

# confidence interval
rbind(quantile(testResult[2:1000,1], probs = c(0.025, 0.975)),
      quantile(testResult[2:1000,2], probs = c(0.025, 0.975)),
      quantile(testResult[2:1000,3], probs = c(0.025, 0.975)))

plot(testResult[2:1000,1])
plot(testResult[2:1000,2])
plot(testResult[2:1000,3])


 
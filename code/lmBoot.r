library(parallel)

#For higher efficiency split calculations between cores
nCores <- detectCores()
myClust <- makeCluster(nCores-1, type = "PSOCK") 

lmBoot <- function(inputData, nBoot) {
  
  #Create matrix to store results
  bootResults <- matrix(nrow = nBoot, ncol = (ncol(inputData)))
  
  inputLM <- lm(inputData)
  bootResults[1,] <- coef(inputLM)
  
  bootResults[2:nBoot,1:ncol(inputData)] <- parSapply(myClust, 2:nBoot, function(i) {
    #resample data with replacement and fit model to this resample
    resample <- inputData[sample(1:nrow(inputData), nrow(inputData), replace = TRUE),]
    bootLM <- lm(data = resample)
    return(t(coef(bootLM)))})
  
  #Set column names of matrix to the estimated parameters
  colnames(bootResults) <- names(coef(inputLM))
  return(bootResults)
}



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

# Old Code

# lmBoot <- function(inputData, nBoot){
#   
#   for(i in 1:nBoot){
#     
#     # resample our data with replacement
#     bootData <- inputData[sample(1:nrow(inputData), nrow(inputData), replace = T),]
#     
#     # fit the model under this alternative reality
#     bootLM <- lm(y ~ x, data = bootData)
#     
#     # store the coefs
#     if(i == 1){
#       
#       bootResults <- matrix(coef(bootLM), ncol = 2)
#       
#     } else {
#       
#       bootResults<- rbind(bootResults, matrix(coef(bootLM), ncol = 2))
#       
#     }
#     
#     
#   } # end of i loop
#   
#   bootResults
# }
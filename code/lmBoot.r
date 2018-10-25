library(parallel)
# This line just in case anyone forgets to import data 
fitness <- read.csv("data/fitness.csv")

#For higher efficiency split calculations between cores
nCores <- detectCores()
myClust <- makeCluster(nCores-1, type = "PSOCK") 


lmBoot <- function(inputData, nBoot, response) {
  #Inputs: 
  #inputData - The data that you wish to boostrap on
  #nBoot - The number of bootstraps to use
  #response - The response variable that you are interested in
  #NOTE: Will fit a model of response against all other columns in the 
  #      inputted data frame, if you wish to fit more specific models
  #      then input a subsetted data frame
  
  #reorder data with response variable first
  #Do this as lm command will take first column as no response with no other
  #args given
  inputData <- inputData[,c(which(colnames(inputData)==response),which(colnames(inputData)!=response))]
  #Create matrix to store results
  bootResults <- matrix(nrow = nBoot, ncol = (ncol(inputData)))
  
  inputLM <- lm(inputData)
  bootResults[1,] <- coef(inputLM)
  
  clusterExport(myClust, "inputData")
  bootResults[2:nBoot,] <- t(parSapply(myClust, 2:nBoot, function(i) {
    #resample data with replacement and fit model to this resample
    resample <- inputData[sample(1:nrow(inputData), nrow(inputData), replace = TRUE),]
    bootLM <- lm(data = resample)
    return((coef(bootLM)))}))
  
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
#
#
# Set x and y variables for the old function for profiling:
#
# x <- fitness$Age
# y <- fitness$Oxygen
#
# Highlight the 2 lines below (adjust the function names first) then go to Profile -> Profile Selected Lines:
#
# lmBoot(fitness,1000)
# lmBootOld(fitness,1000)
#
#
#

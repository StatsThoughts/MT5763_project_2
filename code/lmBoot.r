
# Modified lmBoot ---------------------------------------------------------

lmBoot <- function(inputData, nBoot, response = NA, clusterType = "PSOCK") {
  #Inputs: 
  #inputData - The data that you wish to boostrap on
  #nBoot - The number of bootstraps to use
  #response - The response variable that you are interested in. No input means first column
  #clusterType - Passes to type of cluster n makeCluster 
  #NOTE: Will fit a model of response against all other columns in the 
  #      inputted data frame, if you wish to fit more specific models
  #      then input a subsetted data frame

  if(require(parallel) == FALSE){stop("Please install parallel package")}
  nCores <- detectCores()
  myClust <- makeCluster(nCores-1, type = clusterType)
  
  # Defaults to first column if no response is given 
  if(is.na(response)){response<-colnames(inputData)[1]}
  
  #reorder data with response variable first
  #Do this as lm command will take first column as no response with no other
  #args given
  inputData <- inputData[,c(which(colnames(inputData)==response),which(colnames(inputData)!=response))]
  #Create matrix to store results
  bootResults <- matrix(nrow = nBoot, ncol = (ncol(inputData)))
  
  inputLM <- lm(inputData)
  bootResults[1,] <- coef(inputLM)
  
  bootResults[2:nBoot,] <- t(parSapply(myClust, 2:nBoot, function(i) {
    #resample data with replacement and fit model to this resample
    resample <- inputData[sample(1:nrow(inputData), nrow(inputData), replace = TRUE),]
    bootLM <- lm(data = resample)
    return((coef(bootLM)))}))
  
  #Set column names of matrix to the estimated parameters
  colnames(bootResults) <- names(coef(inputLM))
  
  # Stop Clusters when not needed
  stopCluster(myClust)
  
  return(bootResults)
}


# Old Code ----------------------------------------------------------------

lmBootOld <- function(inputData, nBoot){

  for(i in 1:nBoot){

    # resample our data with replacement
    bootData <- inputData[sample(1:nrow(inputData), nrow(inputData), replace = T),]

    # fit the model under this alternative reality
    bootLM <- lm(y ~ x, data = bootData)

    # store the coefs
    if(i == 1){

      bootResults <- matrix(coef(bootLM), ncol = 2)

    } else {

      bootResults<- rbind(bootResults, matrix(coef(bootLM), ncol = 2))

    }


  } # end of i loop

  bootResults
}


# Profiling/Comparisions --------------------------------------------------
# Set x and y variables for the old function for profiling:

# This line just in case anyone forgets to import data
fitness <- read.csv("data/fitness.csv")

x <- fitness$Age
y <- fitness$Oxygen
test <- data.frame(x = x, y=y)

# Highlight the 2 lines below (adjust the function names first) then go to Profile -> Profile Selected Lines:

lmBoot(test,1000)
lmBootOld(test,1000)

# Microbenchmark tests------------------------------------------------------
# Packages for microbenchmark and boot.
##install.packages("microbenchmark")
##install.packages("boot")
library(microbenchmark)
library(boot)

# This defines the statistic function parameter required for the boot function.
BootStatistic <- function(dataframe, indices, responseCol)
{
  dataframe <- dataframe[indices,]
  colnames(dataframe)[responseCol]= "y"
  BootStatLM <- lm(y ~ . , data = dataframe)
  coef(BootStatLM)
}

# Just confirming that the bootstraps return similar results.
results1 <- boot(data = fitness, statistic = BootStatistic, R = 1000, responseCol = 1)
results2 <- lmBoot(fitness, 1000, "Age")
results1$t0
colMeans(results2)

# Microbenchmark comparing the improved bootstrap and the boot package boostrap.
microbenchmark(
  boot(fitness, BootStatistic, R = 100, responseCol = 1),
  lmBoot(fitness, 100, "Age")
)  


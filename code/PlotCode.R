
library(ggplot2)
# Plotting code for SAS timings -------------------------------------------

times <- data.frame(State = c("Original version", "Optimized Version", "Added RTF Outputs"), Time = c(35.24,0.36, 6.41))
times$State <- factor(times$State, levels = times$State)
ggplot(data = times, aes(x=State, y = Time, fill = State)) + geom_bar(stat="identity") + guides(fill=FALSE)


# Plotting code for R timings -------------------------------------------

timesR <- data.frame(State = c("Original version", "Optimized Version"), Time = c(2.00,1.24))
timesR$State <- factor(timesR$State, levels = timesR$State)
ggplot(data = timesR, aes(x = State, y = Time, fill = State)) + geom_bar(stat="identity") + guides(fill = FALSE)














#--------------------------------------- BOXPLOT CODE BELOW-------------------------------------------------------------------------------


# Microbenchmark tests------------------------------------------------------
# Packages for microbenchmark and boot.
library(microbenchmark)
library(boot)
library(parallel)


#--------------------------------------- BENCHMARK FOR THE VERSION WITH INTERNALLY DEFINED CLUSTER-------------------------------------------------------------



# Function code

lmBootInCluster <- function(inputData, nBoot, response = NA, clusterType = "PSOCK") {
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


# Benchmark Code
set.seed(1234)
Benchmark1<- microbenchmark(
  lmBootInCluster(fitness,1000,"Oxygen"),
  times = 100
)  
Benchmark1



#---------------------------------------BENCHMARK FOR FUNCTION ITERATION WITH EXTERNALLY DEFINED CLUSTER-------------------------------------------------------------


# Defining the cluster
nCores <- detectCores()
myClust <- makeCluster(nCores-1, type = "PSOCK")

#Function code

lmBootExCluster <- function(inputData, nBoot, response = NA, myClust) {
  #Inputs: 
  #inputData - The data that you wish to boostrap on
  #nBoot - The number of bootstraps to use
  #response - The response variable that you are interested in. No input means first column
  #clusterType - Passes to type of cluster n makeCluster 
  #NOTE: Will fit a model of response against all other columns in the 
  #      inputted data frame, if you wish to fit more specific models
  #      then input a subsetted data frame
  
  if(require(parallel) == FALSE){stop("Please install parallel package")}
  
  if(missing(myClust)) {
    nCores <- detectCores()
    myClust <- makeCluster(nCores-1, type = "PSOCK")
  }
  
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
  
  return(bootResults)
}

# Benchmark code.
set.seed(1234)
Benchmark2<- microbenchmark(
  lmBootExCluster,
  times = 100
)  
Benchmark2


# Terminating the cluster
stopCluster(myClust)




#--------------------------------------- BENCHMARK FOR THE BOOT PACKAGE FUNCTION-------------------------------------------------------------




# This defines the statistic function parameter required for the boot package function.
BootStatistic <- function(dataframe, indices, responseCol){
  dataframe <- dataframe[indices,]
  colnames(dataframe)[responseCol]= "y"
  BootStatLM <- lm(y ~ . , data = dataframe)
  coef(BootStatLM)
}


# Benchmark code. 
set.seed(1234)
Benchmark3<- microbenchmark(
  boot(fitness, BootStatistic, R = 1000, responseCol = 3, parallel = "multicore", ncpus= nCores-1),
  times = 100
)  
Benchmark3


#-------------------------------------- BENCHMARK PLOTS SHOWWING INCREASE IN SPEED ACROSS FUNCTION ITERATIONS--------------------------------


BenchmarkPlot <- rbind(Benchmark1, Benchmark2, Benchmark3)
boxplot(BenchmarkPlot, unit="ms", log = F, ylab = "Time (milliseconds)", xlab = "Function", names = c("lmBootInCluster", "lmBootExCluster", "boot"))


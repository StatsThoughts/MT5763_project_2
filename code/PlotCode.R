
library(ggplot2)


# Plotting code for SAS timings -------------------------------------------

times <- data.frame(State = c("Original version", "Optimized Version", "Added RTF Outputs"), Time = c(35.24,0.36, 6.41))
times$State <- factor(times$State, levels = times$State)
ggplot(data = times, aes(x=State, y = Time, fill = State)) + geom_bar(stat="identity") + guides(fill=FALSE)



#--------------------------------------- BOXPLOT CODE BELOW-------------------------------------------------------------------------


# Microbenchmark tests------------------------------------------------------
# Packages for the functions we are comparing.
library(microbenchmark)
library(parallel)
library(boot)
load(file = "RPlotFunctions.RData")


#-------------------------CODE FOR PREVIOUS FUnCTION WITH NO PARALLISATION

lmBootNoPara <- function(inputData, nBoot, response = NA, myClust) {
  #Inputs: 
  #inputData - The data that you wish to boostrap on
  #nBoot - The number of bootstraps to use
  #response - The response variable that you are interested in. No input means first column
  #clusterType - Passes to type of cluster n makeCluster 
  #NOTE: Will fit a model of response against all other columns in the 
  #      inputted data frame, if you wish to fit more specific models
  #      then input a subsetted data frame
  
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
  
  bootResults[2:nBoot,] <- t(sapply(2:nBoot, function(i) {
    #resample data with replacement and fit model to this resample
    resample <- inputData[sample(1:nrow(inputData), nrow(inputData), replace = TRUE),]
    bootLM <- lm(data = resample)
    return((coef(bootLM)))}))
  
  #Set column names of matrix to the estimated parameters
  colnames(bootResults) <- names(coef(inputLM))
  
  return(bootResults)
}

#-------------------------CODE FOR THE PREVIOUS FUNCTION ITERATION WITH INTERNALLY DEFINED CLUSTER----------------------------------


# Function code

lmBootInCluster <- function(inputData, nBoot, response = NA) {
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
  myClust <- makeCluster(nCores-1, type = "PSOCK")
  
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








#----------------------------------------------------------------- BENCHMARKS BOX PLOTS-----------------------------------------------------------------



# Benchmark Code for original function.
x <- FitnessTwoVars$Age
y <- FitnessTwoVars$Oxygen

set.seed(1234)
Benchmark1<- microbenchmark(
  lmBootOld(FitnessTwoVars,1000),
  times = 100
)  

# Benchmark code for second version (Using sapply)
set.seed(1234)
Benchmark2<- microbenchmark(
  lmBootNoPara(FitnessTwoVars,1000, "Oxygen"),
  times = 100
)  

# Benchmark Code for third version (internally defined clusters)
set.seed(1234)
Benchmark3<- microbenchmark(
  lmBootInCluster(FitnessTwoVars,1000,"Oxygen"),
  times = 100
)  


# Benchmark Code for second/final iteration (externally defined clusters).
nCores <- detectCores()
myClust <- makeCluster(nCores-1, type = "PSOCK")
set.seed(1234)
Benchmark4<- microbenchmark(
  lmBoot(FitnessTwoVars,1000, response = "Oxygen", myClust = myClust),
  times = 100
)  

stopCluster(myClust)


# Benchmark code for boot package function. 
set.seed(1234)
Benchmark5<- microbenchmark(
  boot(FitnessTwoVars, BootStatistic, R = 1000, responseCol = 2, parallel = "multicore", ncpus= nCores-1),
  times = 100
)  




#-------------------------------------- BENCHMARK PLOTS SHOWWING INCREASE IN SPEED ACROSS FUNCTION ITERATIONS------------------------


BenchmarkPlot <- rbind(Benchmark1, Benchmark2, Benchmark3, Benchmark4, Benchmark5)
boxplot(BenchmarkPlot, unit="ms", log = F, ylab = "Time (milliseconds)", xlab = "Function", 
        names = c("Original", "Second version", "Third version","Final version", "boot"),
        main = "lmBoot timings comparison")

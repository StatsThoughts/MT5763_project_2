
library(ggplot2)
# Plotting code for SAS timings -------------------------------------------

times <- data.frame(State = c("Original version", "Optimized Version", "Added RTF Outputs"), Time = c(35.24,0.36, 6.41))
times$State <- factor(times$State, levels = times$State)
ggplot(data = times, aes(x=State, y = Time, fill = State)) + geom_bar(stat="identity") + guides(fill=FALSE)


# Plotting code for R timings -------------------------------------------
system.time(lmBoot(fitness,1000,"Oxygen", myClust))# 1.24s
system.time(lmBootOld(fitness,1000))# 2.00s

timesR <- data.frame(State = c("Original version", "Optimized Version"), Time = c(2.00,1.24))
timesR$State <- factor(timesR$State, levels = timesR$State)
ggplot(data = timesR, aes(x=State, y = Time, fill = State)) + geom_bar(stat="identity") + guides(fill=FALSE)

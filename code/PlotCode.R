
library(ggplot2)
# Plotting code for SAS timings -------------------------------------------

times <- data.frame(State = c("Original version", "Optimized Version", "Added RTF Outputs"), Time = c(35.24,0.36, 6.41))
times$State <- factor(times$State, levels = times$State)
ggplot(data = times, aes(x=State, y = Time, fill = State)) + geom_bar(stat="identity") + guides(fill=FALSE)



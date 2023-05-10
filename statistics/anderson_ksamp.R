## install.packages('openxlsx')
## install.packages("nortest")
## install.packages("kSamples")
## install.packages("fBasics")
library(openxlsx)
library(nortest)
library(kSamples)
library(fBasics)

data <- read.xlsx("Path to NeutralComet.xlsx")
data <- head(data, -1) # Remove the last row, which contains NA in the 3rd column

u1 <- data$KDctrl_H2O2
u2 <- data$shSTN1_H2O2

ad.test(u1, u2, method = "exact", dist = FALSE, Nsim = 1000)

ks2Test(u1, u2)

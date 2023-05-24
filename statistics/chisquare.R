## Fig.S4A

## The number of class_1 nuclei for shSTN1 is 159
## The number of class_2 nuclei for shSTN1 is 50

## Estimated probability distribution by the KD contraol measurement
## is P(class_1)=0.89, P(class_2)=0.11

chisq.test(x=c(159,50), p=c(0.89,0.11))

########## Output ##########
## Chi-squared test for given probabilities

## data:  c(159, 50)
## X-squared = 35.655, df = 1, p-value = 2.355e-09

## Fig.S4B

## The number of class_1 nuclei for shSTN1 is 24
## The number of class_2 nuclei for shSTN1 is 74

## Estimated probability distribution by the KD contraol measurement
## is P(class_1)=0.69, P(class_2)=0.31

chisq.test(x=c(24,74), p=c(0.69,0.31))

########## Output ##########
## Chi-squared test for given probabilities

## data:  c(24, 74)
## X-squared = 90.768, df = 1, p-value < 2.2e-16
setwd("/Users/hchuang/Documents/ELASTIC_CHECK")

source("gensample.r")
source("OMPCheck.r")

RET <- gensample()
x <- RET$observations
y <- RET$reponse

myfit <- elasticcheck(x,y,6,intercept=F,nu=0.25,epsilon=0.0001)


#### EXAMPLE OF OUTPUT
# These are the coefficients selected by elasticcheck procedure:
[1] 1
[1] 9
[1] 5
[1] 2
[1] 10
[1] 6

# This is the ground truth 
> print(which(RET$Truebeta !=0))
[1]  1  2  5  6  9 10

# ===> Which means PERFECT RECOVERY !!!

# Now looking at the value of the coefficeints estimated by elasticcheck
> print(myfit$beta[,6])
 [1]  1.5455515 -1.4834173  0.0000000  0.0000000  1.2333126  0.5167034  0.0000000  0.0000000  1.2983545  1.1237023  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000
[16]  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000  0.0000000

# This is the ground truth 
> print(RET$Truebeta)
[1] 1.8 -1.2  0.0  0.0  1.0  0.5  0.0  0.0  1.0  1.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0

# ===> Which means THIS IS GREAT ACCURACY!!!

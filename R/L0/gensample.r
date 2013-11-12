library(mvtnorm)

genSample <- function() {

#sample size    
N = 550
#number of variables
d = 15

thrd1 <- qnorm(1/3, mean=0, sd=1)

thrd2 <- qnorm(2/3, mean=0, sd=1)

rmean <- rep(0,d)

cova <- matrix(0,d,d)

for (i in 1:d){
   for (j in 1:d){
       cova[i,j]<-0.5^abs(i-j)
       }
   }

## generate hidden variables: N sample from a 15-dim multivariate gaussian, with mean 0, var 1, an covariance cova
Z <- rmvnorm(N, rmean, cova)


## generate observations
X <- matrix(2,N,d)
X[Z<thrd1] <- 0;
X[Z>thrd2] <- 1;


# generate response variables  

Y = 1.8 * (X[, 1] == 1)  - 1.2 * (X[, 1] == 0) + (X[, 3] == 1) + 0.5 * (X[, 3] == 0) + (X[, 5] == 1) + (X[, 5] ==0);

noise <- rnorm(N, mean=0, sd=1.476)
Y = Y + noise;

truebeta <- rep(0,2*d);
truebeta[1] <- 1.8
truebeta[2] <- -1.2
truebeta[5] <- 1
truebeta[6] <- 0.5
truebeta[9] <- 1
truebeta[10] <- 1

# create the group vector.  variable with the same group number belong to the same group
G <- rep(0,2*d);
g <-1
for (i in 1:d){
   G[2*i-1]<-g;
   G[2*i]<- g;
   g <- g+1;
   }

#create the dummy observations
obs <- matrix (0,N,2*d);
for (i in 1:d){
   obs[, 2* i - 1] = (X[, i] == 1) * 1;
   obs[, 2 * i] = (X[, i] == 0) * 1;
     } 


RET <-  list(observations=obs[1:500,], reponse= Y[1:500], validX=obs[501:550,], validY=obs[501:550], Truebeta=truebeta)
return(RET)
}
 

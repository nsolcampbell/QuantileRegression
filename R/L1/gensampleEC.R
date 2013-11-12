library(mvtnorm)
library(Rlab)
library(VGAM)

#model = model type
#n=train + eval + test sample size
#p=dimensionality
#r correlation of X
genSample <- function(model=1,n=550,p=8) {

    
    r=0.5
    if (model==2) {r=0.95}
    

rmean=rep(0,p)
cova <- matrix(0,p,p)

for (i in 1:p){
   for (j in 1:p){
       cova[i,j]<-r^abs(i-j)
       }
   }

## generate obeservations
    
X <- rmvnorm(n, rmean, cova)




# generate response variables  

Y = 3 * X[, 1]  + 1.5 * X[, 2]  + 2 * X[, 5]

if((model==1)||(model==2))
    {
        noise <- rnorm(n, mean=0, sd=1)
        sigma=2
    }

if(model==3)
    
    {
        h=rbern(prob=0.9,n=n)
        noise <-(h*rnorm(n,mean=0,sd=1)+(1-h)*rnorm(n,mean=0,sd=sqrt(225)))/(sqrt(0.9*1+0.1*225))
        sigma=9.67
    }
    
    if(model==4)
    
    {
        sigma=9.67
        noise <-rlaplace(n, location=0, scale=1)/(sqrt(2))
        
    }
Y = Y + sigma* noise;

truebeta <- rep(0,p);
truebeta[1] <- 3
truebeta[2] <- 1.5
truebeta[5] <- 2


RET <-  list(X=X, Y=Y, Truebeta=truebeta, Sigma=cova)
return(RET)
}
 

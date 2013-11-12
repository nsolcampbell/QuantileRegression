# x: n x p input data matrix
# y: n x 1 response vector
# alpha: mixing coefficient for l_1 and squared loss
# lambda: parameter for l_1 penalty
# rho: parameter for ADMM
# epsilon: tolerance parameter for convergence
 
elasticcheck <- function(x,y,intercept=TRUE, alpha=0.25, lambda=0.1,rho=1,epsilon=1e-3) {
    
    n <- dim(x)[1]
    p <- dim(x)[2]
    
    if (alpha==0) {cat("Performing LAD Lasso \n")}
    if (alpha==1){cat("Performing regular Lasso \n")}
    # centering data
    if(intercept){
        meanx <- drop(colMeans(x))
        x <- scale(x, meanx, FALSE) # centers x
        meany <- mean(y)
        y <- drop(y - meany)
    }else{
        meanx <- rep(0,p)
        meany <- 0
        y <- drop(y)
    }
    xscale=sqrt(colSums(x*x))
    x <- scale(x,FALSE,xscale)
    names(meanx) <- dimnames(x)[[2]]
    cat("Scales = ", xscale , "\n")
    
    maxit=20
    u=rep(0,nrow(x))
    z=rep(0,nrow(x))
    betaold=rep(0,ncol(x))
    ite=1
    
    lambda1=lambda/rho
    
    #xtxi=solve(t(x)%*%x)
    #xty=t(x)%*%y
    while(ite<maxit){
        cat("Outer iteration = ", ite , "\n")
        beta=lasso(A=x,b=y-z+u,lambda=lambda1,rho=1)
        z=soft((rho/(alpha+rho)*(u+y-x%*%beta)) , (1-alpha)/(rho+alpha))
        #z=soft((x%*%beta-y+u) , (1-alpha)/rho)
        u=u+ y-z-x %*% beta
        if ((sum ((beta-betaold)^2)^(1/2))<epsilon) break
        betaold=beta
        ite=ite+1
        #cat("beta = ", z , "\n")
    }
    
    beta=beta/xscale
    object <- list(beta = beta, meanx = meanx, meany=meany)
    return (object)
}
   
 
# Soft Thresholding Operator 
soft <- function (a,eta){
 	for (i in 1:length(a)){
 		if(a[i]>eta){a[i]=a[i]-eta}
 		if(a[i]< (-eta)){a[i]=a[i]+eta}
 		if(abs(a[i])<=eta) {a[i]=0}
 	}
 	return(a)
}


# Lasso Operator

lasso <- function (A,b,epsilon=10^(-2),lambda,rho=1){
 	maxit=1000
    u=rep(0,ncol(A))
    z=rep(0,ncol(A))
    xold=rep(0,ncol(A))
    ite=1
    atai=solve(t(A)%*%A+rho*diag(ncol(A)))
    atb=t(A)%*%b
 	while(ite<maxit){
 		x=(atai)%*%(atb+rho*(z-u))
 		z=soft(x+u , lambda/rho)
 		u=u+x- z
 		if ((sum ((x-xold)^2)^(1/2))<epsilon) break
 	    xold=x
 		ite=ite+1
 		
 	}
 	return(z)
}

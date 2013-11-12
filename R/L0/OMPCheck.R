# x: n x p input data matrix
# y: n x 1 response vector
# steps: number of greedy steps
# nu: mixing coefficient for l_1 and squared loss
# epsilon: tolerance paramter for refitting step
 
 elasticcheck <-function(x,y,steps=0, intercept=TRUE, nu=0.25, epsilon=1e-2) {
   n <- dim(x)[1]
   p <- dim(x)[2]
 
   
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
 
   s=steps
   if (s==0) s=p;
 
   path=rep(0,s);
   beta=matrix(rep(0,s*p),ncol=s)
   
   #Initialization of the residual  
   r=y;
    for (k in 1:s) {
    	 # constructing the sign vector of the residual
    	 signr=2*(r>0)-1
    	 # finding the coordinate maximizes the projection onto the 'generalized residuals'
       genproj=(abs( ((1-nu)*t(signr)+nu*t(r))%*%x))
       ik=which.max(genproj)
 
      
       print(ik)
       #if this coordinate has been found before, then exit
       if (length(which(path[1:k]==ik))>0) {
         path=path[1:(k-1)]
         beta=beta[,1:(k-1)]
         print("Coordinate was already selected")
         break;
       }
 
       path[k]=ik;
       myfs=as.matrix(x[,(path[1:k])]);
       
       #Refitting via ADMM 
        w=myrefit(myfs,y,epsilon,nu,rho);
     
       
       #updating the residuals
       r=myfs%*%w-y;
       
       #storing model coefficients
       beta[(path[1:k]),k]=w/xscale[(path[1:k])]
     }
 
     object <- list(path=path, beta = beta, meanx = meanx, meany=meany)
     return (object)
   }
 
 # ADMM fits beautifully here (see
 # https://www.stanford.edu/~boyd/papers/pdf/admm_distr_stats.pdf pp 39-40)
 # It solves min (1-alpha)||z||_1 + alpha/2 ||z||_2^2 subject to xbeta - z = y
 # Proximity operator
 # z^{k+1}=(1-alpha)(X beta^{k+1}) - y + u^k) + alpha S(1/rho)(X beta^{k+1}-b + u^k)
 myrefit <- function(x,y,epsilon=10^(-6),nu,rho=1) {
 	maxit=1000
 	 u=rep(0,nrow(x))
 	 z=rep(0,nrow(x))
 	 betaold=rep(0,ncol(x))
 	 ite=1
 	 xtxi=solve(t(x)%*%x)
 	 xty=t(x)%*%y
 	while(ite<maxit){
 		beta=1/(nu+rho)*xtxi %*% (nu*xty + rho*t(x) %*% (z+y-u))
 		z=soft(x%*%beta-y+u , (1-nu)/rho)
 		u=u+x %*% beta - z - y
 		if ((sum ((beta-betaold)^2)^(1/2))<epsilon) break
 	    betaold=beta
 		ite=ite+1
 		
 	}
 	return(beta)
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

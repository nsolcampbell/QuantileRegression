setwd("/Users/hchuang/Documents/ELASTIC_CHECK")

source("gensampleEC.r")
source("ElasticLasso.r")

#-----------------------------------------------------
getAccuray <- function(beta,truebeta) {
    
    TP=0
    TN=0
    P=0
    N=0
    SEL=0
    
    p=length(beta)
    
    for (i in 1:p){
        if(beta[i]!=0){
            SEL=SEL+1
        }
        if(truebeta[i]!=0){
            P=P+1
            if(beta[i]!=0)
                TP=TP+1
                }
        if(truebeta[i]==0){
            N=N+1
            if(beta[i]==0)
                TN=TN+1
                }
        
    }
    
    prec=TP/SEL
    rec=TP/P
    f1=2*(prec*rec)/(prec+rec)
    return(list(prec=prec,rec=rec,f1=f1))
}

model=4
moderror=list()
prec=list()
rec=list()
f1=list()

length(moderror)=10
length(prec)=10
length(rec)=10
length(f1)=10

lambda=rep(0,100)

for (i in 1:10){
    moderror[[i]]=matrix(0,100,100)
    prec[[i]]=matrix(0,100,100)
    rec[[i]]=matrix(0,100,100)
    f1[[i]]=matrix(0,100,100)
}


moderror.cv=matrix(0,100,10)
prec.cv=matrix(0,100,10)
rec.cv=matrix(0,100,10)
f1.cv=matrix(0,100,10)



for (i in 1:100)
{
    
    #n =50, 100, 200
    RET <- genSample(model=model)
    x <- RET$X[1:100,]
    y <- RET$Y[1:100]
    xtest<-RET$X[101:nrow(RET$X),]
    ytest<-RET$Y[101:length(RET$Y)]
    
    truebeta <- RET$Truebeta
    Sigma <- RET$Sigma
    
    lam=seq(from=0,to=10,length=100)
    alpha=seq(from=0,to=1,length=10)
    
    for(a in 1:10){
        mybest=1; error=10^10;
        for (l in 1:100)
      {
          
         myfit <- elasticcheck(x,y,F,alpha=alpha[a],lambda=lam[l])
          beta=myfit$beta
          moderror[[a]][i,l]= sum(diag(t(beta-truebeta)%*%Sigma%*%(beta-truebeta)))
          prederro=sum((xtest %*% beta - ytest)^2)
          if(prederro <error) {
              error=prederro
              mybest=l
          }
          
          ac=getAccuray(beta,truebeta)
          prec[[a]][i,l]=ac$prec
          rec[[a]][i,l]=ac$rec
          f1[[a]][i,l]=ac$f1
          
          
          
      }
        moderror.cv[i,a]=moderror[[a]][i,mybest]
        prec.cv[i,a]=prec[[a]][i,mybest]
        rec.cv[i,a]=rec[[a]][i,mybest]
        f1.cv[i,a]=f1[[a]][i,mybest]
    }
}

moderror.oracle=matrix(0,100,10)
moderror.oracle.index=matrix(0,100,10)
for(i in 1:10){
    moderror.oracle[,i]=apply(moderror[[i]],1,min)
    moderror.oracle.index[,i]=apply(moderror[[i]],1,which.min)
}

prec.oracle=matrix(0,100,10)
rec.oracle=matrix(0,100,10)
f1.oracle=matrix(0,100,10)

for(i in 1:10){
    prec.oracle[,i]=apply(prec[[i]],1,max,na.rm = T)
    rec.oracle[,i]=apply(rec[[i]],1,max,na.rm = T)
    f1.oracle[,i]=apply(f1[[i]],1,max,na.rm=T)
}


prec.oracle.i=matrix(0,100,10)
rec.oracle.i=matrix(0,100,10)
f1.oracle.i=matrix(0,100,10)
for(i in 1:10){
    for (j in 1:100){
    prec.oracle.i[j,i]=(prec[[i]][j,moderror.oracle.index[j,i]])
    rec.oracle.i[j,i]=(rec[[i]][j,moderror.oracle.index[j,i]])
    f1.oracle.i[j,i]=(f1[[i]][j,moderror.oracle.index[j,i]])
    }
}


moderror.cv.summary=cbind(colMeans(moderror.cv),apply(moderror.cv,2,sd))
prec.cv.summary=cbind(colMeans(prec.cv),apply(prec.cv,2,sd))
rec.cv.summary=cbind(colMeans(rec.cv),apply(rec.cv,2,sd))
f1.cv.summary=cbind(colMeans(f1.cv),apply(f1.cv,2,sd))

moderror.oracle.summary=cbind(colMeans(moderror.oracle),apply(moderror.oracle,2,sd))
prec.oracle.summary=cbind(colMeans(prec.oracle),apply(prec.oracle,2,sd))
rec.oracle.summary=cbind(colMeans(rec.oracle),apply(rec.oracle,2,sd))
f1.oracle.summary=cbind(colMeans(f1.oracle),apply(f1.oracle,2,sd))

prec.oracle.i.summary=cbind(colMeans(prec.oracle.i),apply(prec.oracle.i,2,sd))
rec.oracle.i.summary=cbind(colMeans(rec.oracle.i),apply(rec.oracle.i,2,sd))
f1.oracle.i.summary=cbind(colMeans(f1.oracle.i),apply(f1.oracle.i,2,sd))


results=rbind(t(moderror.cv.summary),t(prec.cv.summary),t(rec.cv.summary),t(f1.cv.summary),t(moderror.oracle.summary),
t(prec.oracle.summary),t(rec.oracle.summary),t(f1.oracle.summary),t(prec.oracle.i.summary),t(rec.oracle.i.summary),t(f1.oracle.i.summary))
rownames(results)=c(rep("moderror.cv.summary",2),rep("prec.cv.summary",2),rep("rec.cv.summary",2),rep("f1.cv.summary",2),rep("moderror.oracle.summary",2),
rep("prec.oracle.summary",2),rep("rec.oracle.summary",2),rep("f1.oracle.summary",2),rep("prec.oracle.i.summary",2),rep("rec.oracle.i.summary",2),rep("f1.oracle.i.summary",2))
colnames(results)=alpha

write.csv(results,file=paste("results.exp",model,".csv",sep=""),quote=F)






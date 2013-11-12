% NOTE: First make sure CVX is setup
m=5;
n=10;
lambda=1;
alpha=.1;
tau=.5;

X=rand(m,n);
temp=rand(n,1)*5;
y=X*temp;

options=[];
options.maxiters=5000;
options.epsilon_smoothing=.1;
options.tol=.01;
options.info=100;
options.beta0=zeros(n,1);
options.rho=sqrt(n); % parameter for ADMM

[beta_cvx,primal_cvx]=elasticCheck_CVX(X,y,tau,alpha,lambda);
[beta_fista,primal_fista,dual_fista,gap_fista,iter_fista,beta_dual_fista,mu]=elasticCheck_FISTA(X,y,tau,alpha,lambda,options);
[beta_admm,primal_admm,dual_admm,gap_admm,iter_admm,beta_dual_admm]=elasticCheck_ADMM(X,y,tau,alpha,lambda,options);

[beta_cvx,beta_fista,beta_admm]
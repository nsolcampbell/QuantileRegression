% NOTE: First make sure CVX is setup
addpath(genpath('C:\Ronny Research\Software\minFunc_2012'));
addpath('..\IPsolve');
dir='../data/Cauchy/';
% X=csvread([dir,'X.csv'],1,0);
% y=csvread([dir,'Y.csv'],1,0);
% beta_true=csvread([dir,'truebeta.csv'],1,0);
% [m,n]=size(X);
% lambda=1;
% alpha=.1;
% tau=.5;

m=5;
n=20;
A=randn(m,n);
beta_true=randn(n,1);
A=normc(A);
b=A*beta_true+.001*randn(m,1);
temp=randperm(m);
b(temp(1:2))=b(temp(1:2))+10*rand(2,1);
% A=normc(A);

% % L1-regularized least-squares example
% %Generate problem data
% randn('seed', 0);
% rand('seed',0);
% 
% smooth = 1;
% wellCond = 0;
% m = 5;       % number of examples
% n = 20;       % number of features
% p = 100/n;      % sparsity density
% x0 = sprandn(n,1,p);
% A = randn(m,n);
% 
% if(~wellCond)
%     [L U] = lu(A);
%     ds = speye(m);
%     ds = spdiags((1:1:m)', 0, ds);
%     U = ds.^20*U;
%     A = L*U;    
% end
% 
% A = A*spdiags(1./sqrt(sum(A.^2))',0,n,n); % normalize columns
% 
% b = A*x0 + sqrt(0.001)*randn(m,1);
% b = b + 10*sprand(m,1,300/m);      % add sparse, large noise

params.procLinear = 0;
params.kappa = 1;
lambda_max = norm( A'*b, 'inf' );
lambda = 0.1*lambda_max;

options=[];
options.maxiters=1000;
options.epsilon_smoothing=.1;
options.tol=.01;
options.info=100;
options.beta0=zeros(n,1);
options.rho=sqrt(n); % parameter for ADMM
options.loss='huber';

% [beta_cvx,primal_cvx]=elasticCheck_CVX(X,y,tau,alpha,lambda);
% [beta_fista,primal_fista,dual_fista,gap_fista,iter_fista,beta_dual_fista,mu]=elasticCheck_FISTA(X,y,tau,alpha,lambda,options);
% [beta_admm,primal_admm,dual_admm,gap_admm,iter_admm,beta_dual_admm]=elasticCheck_ADMM(X,y,tau,alpha,lambda,options);
% [beta_lasso,primal_lasso] = L1Reg_L2Loss_FISTA(X,y,lambda,options);
% [beta_lasso1,primal_lasso] = L1Reg_L2Loss_CVX(X,y,lambda);
% [beta_sip] = run_quant_reg(X,y,1/lambda);
% [beta_cvx] = L1Reg_HuberLoss_CVX(A,b,lambda);
[beta_admm]=L1Reg_GenLoss_ADMM(A,b,lambda,options);
params.lambda=lambda;
[beta_ip]=run_example(A,b,'huber','l1Lam',params);
% [beta_cvx,beta_fista,beta_admm]
% [beta_cvx,beta_true,beta_fista,beta_lasso]

% plot(1:n, beta_cvx/norm(beta_cvx)-1, 1:n, beta_true/norm(beta_true) + .5);
% legend('cvx','true');
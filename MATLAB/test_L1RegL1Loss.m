% NOTE: First make sure CVX is setup
addpath('..\IPsolve');
addpath('C:\Program Files (x86)\IBM\ILOG\CPLEX_Studio125\cplex\matlab\x86_win32'); % if using CPLEX

m=1000;
n=100;
X=rand(m,n);
beta_true=rand(n,1);
y=X*beta_true+rand(m,1);
X=normc(X);

lambda=100;
params.lambda=lambda;
x_ipsolve=run_example(X,y,'l1','l1Lam',params);
tic;
x_cplex=L1Reg_L1Loss_cplex(X,y,lambda);
disp(['Cplex took ',num2str(toc),' seconds.']);
max(abs(x_ipsolve-x_cplex))
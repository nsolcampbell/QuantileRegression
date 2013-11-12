% Solve sparse elastic check problem: 
% Solves the problem
%
% minimize    (1-alpha)*check_tau(y-X*beta) + alpha*||y-X*beta||_2^2 + lambda*||beta||_1
%
% where check_tau(r)=sum_i{(tau-indicator(r_i<=0)*r}
%
% This code uses ADMM and solves the inner L1 regularized problem with
% FISTA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:  
% X:        m x n data matrix
% y:        m x 1 response vector
% tau:      slope for check function
% alpha:    tradeoff parameter between check and l2 loss (in [0,1])
% lambda:   tradeoff for L1 regularization
% options:  options.rho                     parameter for ADMM
%           options.epsilon_smoothing       parameter for smoothing the gradient           
%           options.tol                     tolerance for stopping criteria
%           options.maxiters:               maximum number of iterations
%           options.info                    number of iterations between checking convergence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs:  
% beta1:    primal solution for sparse elastic check problem
% primal:  vector storing primal objective values every iter iterations
% dual:    vector storing dual objective values every iter iterations
% gap:     vector storing duality gap every iter iterations
% iter:    vector storing iteration count corresponding to primal, dual, and gap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Ronny Luss, March 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: The tolerance used for stopping condition is the input tol*gap(1),
% where gap(1) is the initial gap computed in the first iteration, i.e.
% stopping tolerance is actually a relative tolerance.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [beta,primal,dual,gap,iter,beta_dual] = elasticCheck_ADMM(X,y,tau,alpha,lambda,options)

[m,n]=size(X);

% SET DEFAULTS
if ~exist('options'), options=[]; end
if ~isfield(options,'tol'), options.tol=.001; end
if ~isfield(options,'maxiters'), options.maxiters=500; end
if ~isfield(options,'info'), options.info=100; end
disp('Sparse Elastic Check using ADMM. MATLAB starting...');

% parameters needed for computing a dual bound
D=max(tau,(1-tau))^2*m/2;
mu=options.epsilon_smoothing/2/(1-alpha)/D; % smoothing parameter
L=(1-alpha)*norm(X,'fro')^2/mu+alpha*norm(X'*X,'fro'); % lipschitz constant of smoothed objective

% initialize the variables
z=zeros(m,1);
u=zeros(m,1);
beta=options.beta0;

notconverged=1; % indicator for convergence
count=0; % count for number iterations
primal=[];dual=[];gap=[];iter=[]; % storage for results

% RUN ADMM!
tic;
while (notconverged)
    % 1. COMPUTE NEW BETA BY SOLVING L1 REGULARIZED L2 LOSS!
    l1_options=[];
    l1_options.maxiters=1000;
    l1_options.tol=.005;
    l1_options.info=1000;
    l1_options.beta0=zeros(n,1);
    beta=L1Reg_L2Loss_FISTA(X,-z+y+u,lambda/options.rho,l1_options);
%     beta=L1Reg_L2Loss_CVX(X,-z+y+u,lambda/options.rho);
    
    % 2. COMPUTE Z
    kappa=(1-alpha)/(alpha+options.rho);
    param=(u+y-X*beta)*options.rho/(alpha+options.rho);
    z=(param-kappa*tau/options.rho).*(param>kappa*tau/options.rho)+(param+kappa*(1-tau)/options.rho).*(param<-kappa*(1-tau)/options.rho);

    % 3. COMPUTE U
    u=u+y-X*beta-z;
    
    % Check optimality criteria every info iterations or if reached maxiters,
    % and compute primal variables, record and display current state, etc.
    if mod(count,options.info)==0 || count>=options.maxiters % compute dual and gap
        
        primal=[primal;(1-alpha)*sum((tau-(y-X*beta<=0)).*(y-X*beta))+alpha*norm(y-X*beta)^2/2+lambda*sum(abs(beta))]; % Store the primal objective value

        % Compute a dual objective value
        ind=find(abs(beta)>.0001);
        u=(y-X(:,ind)*beta(ind))/mu;
        u=(u<tau-1)*(1-tau)+(u>tau)*tau+(u>=tau-1).*(u<=tau).*u;
        v=zeros(n,1);
        v(ind)=sign(beta(ind));

        dual_options=[];
        dual_options.maxiters=20000;
        dual_options.tol=.005;
        dual_options.info=1000;
        dual_options.x0=zeros(length(ind),1);
        beta_dual=zeros(n,1);

        % Different Quadratic programming solvers
        %         beta_cvx=quadprog_CVX(X,y,-(1-alpha)*X'*u+lambda*v,alpha);
        beta_dual(ind)=quadprog_nest83(X(:,ind),y,-(1-alpha)*X(:,ind)'*u+lambda*v(ind),alpha,dual_options);
%         beta_dual(ind)=inv(X(:,ind)'*X(:,ind))*((1-alpha)*X(:,ind)'*u+alpha*X(:,ind)'*y-lambda*v(ind))/alpha;
        dual=[dual;(1-alpha)*((y-X*beta_dual)'*u-mu*norm(u)^2/2)+alpha*norm(y-X*beta_dual)^2/2+lambda*beta_dual'*v]; % Store the dual objective value
        gap=[gap;primal(end)-dual(end)]; % Store the duality gap
        iter=[iter;count]; % Store the iteration counter
        disp(['Iter: ',num2str(count),'   Primal: ',num2str(primal(end)),'   Dual: ',num2str(dual(end)),'   Gap: ',num2str(gap(end)),'   Time: ',num2str(toc)]);
        if gap(end) < options.tol  || count>=options.maxiters % criterion for stopping
            notconverged=0;
        end
    end    
    count=count+1;
end


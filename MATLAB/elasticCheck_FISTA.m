% Solve sparse elastic check problem: 
% Solves the problem
%
% minimize    (1-alpha)*check_tau(y-X*beta) + alpha*||y-X*beta||_2^2 + lambda*||beta||_1
%
% where check_tau(r)=sum_i{(tau-indicator(r_i<=0)*r}
%
% This code smooths the check_tau() function and runs FISTA on resulting 
% smooth + L1 problem.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:  
% X:        m x n data matrix
% y:        m x 1 response vector
% tau:      slope for check function
% alpha:    tradeoff parameter between check and l2 loss (in [0,1])
% lambda:   tradeoff for L1 regularization
% options:  options.epsilon_smoothing       parameter for smoothing the gradient           
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

function [beta1,primal,dual,gap,iter,beta_dual,mu] = elasticCheck_FISTA(X,y,tau,alpha,lambda,options)

[m,n]=size(X);

% SET DEFAULTS
if ~exist('options'), options=[]; end
if ~isfield(options,'epsilon_smoothing'), options.epsilon_smoothing=.01; end
if ~isfield(options,'tol'), options.tol=.001; end
if ~isfield(options,'maxiters'), options.maxiters=500; end
if ~isfield(options,'info'), options.info=100; end
disp('Sparse Elastic Check using smoothing + FISTA. MATLAB starting...');

% initialize the variables
beta0=options.beta0;
gamma=beta0;
t1=1;

D=max(tau,(1-tau))^2*m/2;
mu=options.epsilon_smoothing/2/(1-alpha)/D; % smoothing parameter
L=(1-alpha)*norm(X,'fro')^2/mu+alpha*norm(X'*X,'fro'); % lipschitz constant of smoothed objective

notconverged=1; % indicator for convergence
count=0; % count for number iterations
primal=[];dual=[];gap=[];iter=[]; % storage for results

% The basic FISTA Algorithm is:
% 1. Compute gradient
% 2. Compute prox operator
% 3. Take a step using the specially chosen stepsizes of FISTA for "optimal" convergence rate.
tic;
while (notconverged)
    % 1. COMPUTE GRADIENT!
    u_mu=(-X*gamma+y)/mu;
    u_mu=-(1-tau)*(u_mu<-(1-tau))+u_mu.*(u_mu>=-(1-tau)).*(u_mu<=tau)+tau*(u_mu>tau); % projection onto Q={u: -(1-tau)<=u<=tau}
    grad_f = -(1-alpha)*X'*u_mu-alpha*X'*(y-X*gamma); % grad_f is now the gradient of the smoothed objective value
 
    % 2. COMPUTE PROX OPERATOR!
    p=gamma-grad_f/L; % input to the prox operator
    beta1=max(abs(p)-lambda/L,0).*sign(p);
    
    % 3. TAKE STEP!
    t2=(1+sqrt(1+4*t1^2))/2; % needed for the "optimal" stepsize for FISTA
    gamma=beta1+(t1-1)*(beta1-beta0)/t2; % compute the starting point for the next iteration

    beta0=beta1;t1=t2; % update remaining variables
    
    % Check optimality criteria every info iterations or if reached maxiters,
    % and compute primal variables, record and display current state, etc.
    if mod(count,options.info)==0 || count>=options.maxiters % compute dual and gap
        
        primal=[primal;(1-alpha)*sum((tau-(y-X*beta1<=0)).*(y-X*beta1))+alpha*norm(y-X*beta1)^2/2+lambda*sum(abs(beta1))]; % Store the primal objective value

        % Compute a dual objective value
        ind=find(abs(beta1)>.0001);
        u=(y-X(:,ind)*beta1(ind))/mu;
        u=(u<tau-1)*(1-tau)+(u>tau)*tau+(u>=tau-1).*(u<=tau).*u;
        v=zeros(n,1);
        v(ind)=sign(beta1(ind));

        dual_options=[];
        dual_options.maxiters=5000;
        dual_options.tol=.005;
        dual_options.info=1000;
        dual_options.x0=zeros(length(ind),1);
        beta_dual=zeros(n,1);
        % Different Quadratic programming solvers
%         beta_cvx=quadprog_CVX(X,y,-(1-alpha)*X'*u+lambda*v,alpha);
%         beta_dual(ind)=quadprog_nest83(X(:,ind),y,-(1-alpha)*X(:,ind)'*u+lambda*v(ind),alpha,dual_options);
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


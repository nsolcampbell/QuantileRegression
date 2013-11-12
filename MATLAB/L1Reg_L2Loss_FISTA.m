% Solves the problem
%
% minimize    ||y-X*beta||_2^2/2 + lamba||beta||_1
%
% This code runs FISTA.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:  
% X:        m x n data matrix
% y:        m x 1 response vector
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
% NOTE: The stopping criteria is currently only according to max iterations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [beta1,primal,dual,gap,iter] = L1Reg_L2Loss_FISTA(X,y,lambda,options)

[m,n]=size(X);

% SET DEFAULTS
if ~exist('options'), options=[]; end
if ~isfield(options,'epsilon_smoothing'), options.epsilon_smoothing=.01; end
if ~isfield(options,'tol'), options.tol=.001; end
if ~isfield(options,'maxiters'), options.maxiters=500; end
if ~isfield(options,'info'), options.info=100; end
% disp('L1 Regularized L2 Loss Minimization using FISTA. MATLAB starting...');

% initialize the variables
beta0=options.beta0;
gamma=beta0;
t1=1;

primal=norm(y-X*beta0)^2/2+lambda*sum(abs(beta0));

L=norm(X'*X,'fro'); % lipschitz constant of L2 Loss

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
    grad_f = X'*(X*gamma-y); % grad_f is the gradient of L2 Loss
 
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
        
        primal=[primal;norm(X*beta1-y)^2/2+lambda*sum(abs(beta1))]; % Store the primal objective value

        iter=[iter;count]; % Store the iteration counter
        if count>=options.maxiters % criterion for stopping
            notconverged=0;
        end
    end    
    count=count+1;
end


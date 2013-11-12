% Solves the problem
%
% minimize    GenHuber(b-A*x) + lamba||x||_1
%
% where GenHuber(x)=   x^2/2/delta if x in [-tau*delta,(1-tau)*delta
%                      (1-tau)*((abs(x)-delta*(1-tau)/2) if x < -delta*(1-tau)
%                      tau*(abs(x)-delta*tau/2) if x > delta*tau
%                     
% This code runs FISTA.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:  
% A:        m x n data matrix
% b:        m x 1 response vector
% delta:    delta parameter for generalized huber loss
% tau:      tau parameter for generalized huber loss
% lambda:   tradeoff for L1 regularization
% x0:       n x 1 initial point
% options:  options.epsilon_smoothing       parameter for smoothing the gradient           
%           options.tol                     tolerance for stopping criteria
%           options.maxiters:               maximum number of iterations
%           options.info                    number of iterations between checking convergence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs:  
% x1:      primal solution for sparse generalized huber 
% primal:  vector storing primal objective values every iter iterations
% dual:    vector storing dual objective values every iter iterations
% gap:     vector storing duality gap every iter iterations
% iter:    vector storing iteration count corresponding to primal, dual, and gap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Ronny Luss, March 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: The stopping criteria is currently only according to max iterations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x1,primal,dual,gap,iter] = L1Reg_GHuberLoss_FISTA(A,b,delta,tau,lambda,x0,options)

[m,n]=size(A);

% SET DEFAULTS
if ~exist('options'), options=[]; end
if ~isfield(options,'epsilon_smoothing'), options.epsilon_smoothing=.01; end
if ~isfield(options,'tol'), options.tol=.001; end
if ~isfield(options,'maxiters'), options.maxiters=500; end
if ~isfield(options,'info'), options.info=100; end
% disp('L1 Regularized Generalized Huber Loss Minimization using FISTA. MATLAB starting...');

% initialize the variables
y=x0;
t1=1;

options_loss=[]; options_loss.loss='gen_huber'; options_loss.delta=delta; options_loss.tau=tau;
primal=compute_loss(A*x0-b,options_loss)+lambda*sum(abs(x0));

L=norm(A'*A,'fro')/delta; % lipschitz constant of Generalized Huber Loss

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
    grad_f=compute_loss_gradient(A,b,y,options_loss);  % grad_f is the gradient of Generalized Huber Loss
 
    % 2. COMPUTE PROX OPERATOR!
    p=y-grad_f/L; % input to the prox operator
    x1=sparse(max(abs(p)-lambda/L,0).*sign(p));
    
    % 3. TAKE STEP!
    t2=(1+sqrt(1+4*t1^2))/2; % needed for the "optimal" stepsize for FISTA
    y=x1+(t1-1)*(x1-x0)/t2; % compute the starting point for the next iteration

    x0=x1;t1=t2; % update remaining variables
    
    % Check optimality criteria every info iterations or if reached maxiters,
    % and compute primal variables, record and display current state, etc.
    if mod(count,options.info)==0 || count>=options.maxiters % compute dual and gap
        
        primal=[primal;compute_loss(A*x1-b,options_loss)+lambda*sum(abs(x1))]; % Store the primal objective value

        iter=[iter;count]; % Store the iteration counter
        if count>=options.maxiters % criterion for stopping
            notconverged=0;
        end
    end    
    count=count+1;
end


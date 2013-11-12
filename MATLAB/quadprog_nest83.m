% Solves the problem
%
% minimize    lambda*||Ax-b||_2^2/2+c'x
%
% using Nesterov accelerated gradient method
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:  
% A:        m x n data matrix
% b:        m x 1 data vector
% c:        n x 1 data vector
% lambda:   parameter
% options:  options.tol                     tolerance for stopping criteria
%           options.maxiters:               maximum number of iterations
%           options.info                    number of iterations between checking convergence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs:  
% x1:      primal solution
% primal:  vector storing primal objective values every iter iterations
% iter:    vector storing iteration count corresponding to primal, dual, and gap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Ronny Luss, March 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE: The tolerance used for stopping condition is the input tol*gap(1),
% where gap(1) is the initial gap computed in the first iteration, i.e.
% stopping tolerance is actually a relative tolerance.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x1,primal,iter] = quadprog_nest83(A,b,c,lambda,options)

[m,n]=size(A);

% SET DEFAULTS
if ~exist('options'), options=[]; end
if ~isfield(options,'tol'), options.tol=.001; end
if ~isfield(options,'maxiters'), options.maxiters=500; end
if ~isfield(options,'info'), options.info=100; end

% initialize the variables
x0=options.x0;
y=x0;
t1=1;

L=lambda*norm(A'*A,'fro'); % lipschitz constant of smoothed objective
notconverged=1; % indicator for convergence
count=0; % count for number iterations
primal=[];dual=[];gap=[];iter=[]; % storage for results

% The basic Nesterov Algorithm is:
% 1. Compute gradient and step
% 2. Adjust using specially chosen stepsizes of FISTA for "optimal" convergence rate.
tic;
while (notconverged)
    % 1. COMPUTE GRADIENT AND STEP!
    grad_f=lambda*A'*(A*y-b)+c;
    x1=y-grad_f/L;
 
    % 2. TAKE STEP!
    t2=(1+sqrt(1+4*t1^2))/2; % needed for the "optimal" stepsize
    y=x1+(t1-1)*(x1-x0)/t2; % compute the starting point for the next iteration

    x0=x1;t1=t2; % update remaining variables
    
    % Check optimality criteria every info iterations or if reached maxiters,
    % and compute primal variables, record and display current state, etc.
    if mod(count,options.info)==0 || count>=options.maxiters % compute dual and gap
        
        if count==0 % if first iteration
            primaltemp=lambda*norm(A*x1-b)^2/2+c'*x1;
        else 
            primaltemp=min(lambda*norm(A*x1-b)^2/2+c'*x1,primal(end));
        end
        primal=[primal;primaltemp]; % Store the primal objective value

        grad_f=lambda*A'*(A*x1-b)+c;
        iter=[iter;count]; % Store the iteration counter
%         disp(['Iter: ',num2str(count),'   Primal: ',num2str(primal(end)),'   Grad Norm:',num2str(norm(grad_f)),'   Time: ',num2str(toc)]);
        
        if norm(grad_f)<=options.tol || count>=options.maxiters % criterion for stopping
            notconverged=0;
        end
    end    
    count=count+1;
end


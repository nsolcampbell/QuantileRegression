% Solve sparse regression problem: 
% Solves the problem
%
% minimize    f(Ax-b) + lambda*||x||_1
%
% where f is a loss function
%
% This code uses ADMM as done in 
% "Distributed Optimization and Statistical Learning via the Alternating
%  Direction Method of Multipliers" by Boyd, et. al. in Sectin 6.3 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:  
% A:        m x n data matrix
% b:        m x 1 response vector
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

function [x,primal,iter] = L1Reg_GenLoss_ADMM(A,b,lambda,options)

[m,n]=size(A);

% SET DEFAULTS
if ~exist('options'), options=[]; end
if ~isfield(options,'tol'), options.tol=.001; end
if ~isfield(options,'maxiters'), options.maxiters=500; end
if ~isfield(options,'info'), options.info=100; end
disp('Sparse Regression using ADMM. MATLAB starting...');


% initialize the variables
z=zeros(n,1);
u=zeros(n,1);
x=zeros(n,1);

notconverged=1; % indicator for convergence
count=0; % count for number iterations
primal=[];dual=[];gap=[];iter=[]; % storage for results

% RUN ADMM!
tic;
while (notconverged)
    
    options_minFunc = [];
    options_minFunc.display = 'none';
    options_minFunc.maxFunEvals = 100;
    options_minFunc.Method = 'lbfgs';

    x=minFunc(@compute_loss_ADMM_inner,zeros(n,1),options_minFunc,options.loss,A,b,options.rho,z-u); % primal update: argmin{f(Ax-b)+rho||x-z+u||_2^2/2}
%     x1=L2Reg_HuberLoss_CVX(A,b,z-u,options.rho);
    w=x+u;
    z=zeros(n,1)+(w-lambda/options.rho).*(w>lambda/options.rho)+(w+lambda/options.rho).*(w<-lambda/options.rho); % soft thresholding
    u=u+x-z; % dual update 
    
    % Check optimality criteria every info iterations or if reached maxiters,
    % and compute primal variables, record and display current state, etc.
    if mod(count,options.info)==0 || count>=options.maxiters % compute dual and gap
        
        primal=[primal;compute_loss(A*x-b,options)+lambda*sum(abs(x))]; % Store the primal objective value

        iter=[iter;count]; % Store the iteration counter
        disp(['Iter: ',num2str(count),'   Primal: ',num2str(primal(end)),'   Time: ',num2str(toc)]);
        if count>=options.maxiters % criterion for stopping
            notconverged=0;
        end
    end    
    count=count+1;
end


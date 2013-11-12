% Solve inner minimization to L1 Regularized Regression via ADMM:

% minimize f(Ax-b)+rho||x-c||_2^2/2
%
% using L-BGFS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs:  
% A:        m x n data matrix
% b:        m x 1 response vector
% rho:      ADMM paramter
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

function [x] = L1Reg_ADMM_inner(A,b,rho,c)

[m,n]=size(X);

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

rho=.5;
notconverged=1; % indicator for convergence
count=0; % count for number iterations
primal=[];dual=[];gap=[];iter=[]; % storage for results

% RUN ADMM!
tic;
while (notconverged)
 
    x=L1Reg_ADMM_inner(A,b,rho,z-u); % primal update: argmin{f(Ax-b)+rho||x-z+u||_2^2/2}
    w=x+u;
    z=zeros(n,1)+(w-lambda/rho).*(w>lambda/rho)+(w+lambda/rho).*(w<-lambda/rho); % soft thresholding
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


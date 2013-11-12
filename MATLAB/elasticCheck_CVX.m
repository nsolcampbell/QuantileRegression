% NOTE: This function requires CVX
%
% Solve sparse PCA problem of 
% "A Direct Formulation for Sparse PCA Using Semidefinite Programming,"
% SIAM Review, 49(3), 2007, pp. 434-448 by A. d’Aspremont, L. El Ghaoui, M.
% I. Jordan, G. R. G. Lanckriet 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute max Tr(AX) s.t. Tr(X)==1, ||X||_1 <= k, X psd 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Ronny Luss, April 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [beta,sol] = elasticCheck_CVX(X,y,tau,alpha,lambda)
disp('Sparse Elastic Check using CVX. MATLAB starting...');

[m,n]=size(X);
cvx_begin
    variable beta(n)
    variable t(m)
    
    minimize( (1-alpha)*sum(t)+alpha*sum((y-X*beta).^2)/2+lambda*sum(abs(beta)));
    subject to
        y-X*beta - t/tau <= 0;
        -y+X*beta - t/(1-tau) <= 0;
cvx_end

sol=(1-alpha)*sum(t)+alpha*sum((y-X*beta).^2)/2+lambda*sum(abs(beta));
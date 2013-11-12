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

function [beta,sol] = L1Reg_L2Loss_CVX(X,y,lambda)
cvx_quiet(true);

opts.disp=0;
% disp('L1 Regularized L2 Loss Minimization using CVX. MATLAB starting...');

[m,n]=size(X);
cvx_begin
    variable beta(n)
    
    minimize( sum((y-X*beta).^2)/2+lambda*sum(abs(beta)));

cvx_end

sol=sum((y-X*beta).^2)/2+lambda*sum(abs(beta));
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

function [x,sol] = quadprog_CVX(A,b,c,lambda)
disp('Quadratic program using CVX. MATLAB starting...');

[m,n]=size(A);
B=A'*A+eye(n)*.000001;
cvx_begin
    variable x(n)
%     variable u(1)
    
   minimize( lambda*sum((A*x-b).^2)/2 +c'*x );
%       minimize( lambda*(x'*B*x-2*x'*A'*b+b'*b)/2+c'*x);
%     subject to
%         norm(A*x-b) <= u;
    
cvx_end

sol=lambda*norm(A*x-b,2)^2/2+c'*x;

function [x] = L1Reg_L1Loss_cplex(A,b,lambda)
disp('Sparse L1 Regularization using Cplex.');

[m,n]=size(A);

f=[zeros(n,1);ones(m,1);lambda*ones(n,1)]; % coefficients for [x;w;t];
Aineq=sparse([A,-eye(m),zeros(m,n);
    -A,-eye(m),zeros(m,n);
    eye(n),zeros(n,m),-eye(n);
    -eye(n),zeros(n,m),-eye(n)]);
bineq=[b;-b;zeros(2*n,1)];

w=cplexlp(f,Aineq,bineq);
x=w(1:n);